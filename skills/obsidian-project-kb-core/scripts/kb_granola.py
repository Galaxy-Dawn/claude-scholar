from __future__ import annotations

import json
import os
import re
from contextlib import contextmanager
from datetime import date
from pathlib import Path
from typing import Any, Iterator
from urllib.parse import urlsplit, urlunsplit
from uuid import UUID

import kb_common as common


SOURCE_DIRECTORIES = ('Sources', 'Archive/Sources')


def line(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f'{field} must be a non-empty string')
    return ' '.join(value.split())


def items(meeting: dict[str, Any], field: str) -> list[Any]:
    values = meeting.get(field, [])
    if not isinstance(values, list):
        raise ValueError(f'{field} must be an array')
    return values


def optional_date(value: Any, field: str) -> str | None:
    if value is None:
        return None
    try:
        text = line(value, field)
        if date.fromisoformat(text).isoformat() == text:
            return text
    except ValueError:
        pass
    raise ValueError(f'{field} must be a YYYY-MM-DD date or null')


def plain_markdown(text: str) -> str:
    text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    return re.sub(r'([\\\[\]_*~\x60])', r'\\\1', text)


def note_url(value: Any) -> str | None:
    if value is None:
        return None
    url = urlsplit(line(value, 'source_url'))
    if (
        url.scheme != 'https'
        or url.netloc.lower() != 'notes.granola.ai'
        or not re.fullmatch(r'/(?:d|t)/[A-Za-z0-9_-]+/?', url.path)
    ):
        raise ValueError('source_url must be a Granola note URL on notes.granola.ai')
    return urlunsplit(('https', 'notes.granola.ai', url.path, '', ''))


def render_meeting(meeting: Any, language: str) -> tuple[str, str, str]:
    if not isinstance(meeting, dict):
        raise ValueError('meeting JSON must be an object')
    try:
        meeting_id = str(UUID(line(meeting.get('meeting_id'), 'meeting_id')))
    except ValueError as exc:
        raise ValueError('meeting_id must be the meeting UUID from Granola') from exc
    title = line(meeting.get('title'), 'title')
    source_kind = line(meeting.get('source_kind'), 'source_kind')
    if source_kind not in {'notes', 'transcript', 'notes-and-transcript'}:
        raise ValueError('source_kind must be notes, transcript or notes-and-transcript')
    meeting_date = optional_date(meeting.get('meeting_date'), 'meeting_date')
    source_url = note_url(meeting.get('source_url'))
    chinese = language.lower().startswith('zh')
    labels = (
        ('参会者', '摘要', '已定事项', '待办', '未决问题', '负责人未定', '未设期限', '未记录')
        if chinese else
        ('Participants', 'Summary', 'Decisions', 'Action items', 'Open questions',
         'Owner unspecified', 'Due date unspecified', 'None recorded')
    )
    participants, summary, decisions, actions, questions, no_owner, no_due, empty = labels
    rendered_actions = []
    for action in items(meeting, 'action_items'):
        if not isinstance(action, dict):
            raise ValueError('each action item must be an object')
        task = plain_markdown(line(action.get('task'), 'action_items.task'))
        owner = plain_markdown(line(action['owner'], 'action_items.owner')) if action.get('owner') is not None else no_owner
        due = optional_date(action.get('due_date'), 'action_items.due_date') or no_due
        rendered_actions.append(f'- [ ] {task} ({owner}, {due})')

    frontmatter = [
        '---', 'type: source-interview', 'source_provider: granola',
        f'granola_meeting_id: {meeting_id}', f'source_kind: {source_kind}',
        f'title: {json.dumps(title, ensure_ascii=False)}',
    ]
    if meeting_date:
        frontmatter.append(f'meeting_date: {meeting_date}')
    if source_url:
        frontmatter.append(f'source_url: {source_url}')
    lines = [*frontmatter, '---', '', f'# {plain_markdown(title)}', '']
    if source_url:
        lines.extend([f'[Granola]({source_url})', ''])

    for key, heading in (
        ('participants', participants), ('summary', summary), ('decisions', decisions),
        ('action_items', actions), ('open_questions', questions),
    ):
        bullets = rendered_actions if key == 'action_items' else [
            f'- {plain_markdown(line(value, key))}' for value in items(meeting, key)
        ]
        if key == 'summary' and not bullets:
            raise ValueError('summary must contain at least one item')
        lines.extend([f'## {heading}', '', *(bullets or [f'- {empty}']), ''])
    return meeting_id, title, '\n'.join(lines)


@contextmanager
def lock_import(project_root: Path) -> Iterator[None]:
    # Lock this vault project's read/modify/write sequence across importer processes.
    with (project_root / '_system' / '.granola-ingest.lock').open('a+b') as lock:
        lock.seek(0)
        if os.name == 'nt':
            import msvcrt
            msvcrt.locking(lock.fileno(), msvcrt.LK_LOCK, 1)
        else:
            import fcntl
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        yield


def existing_meeting(project_root: Path, meeting_id: str) -> Path | None:
    candidates = []
    for folder in SOURCE_DIRECTORIES:
        for path in (project_root / folder).rglob('*.md'):
            if path.is_symlink() or not path.is_file():
                continue
            metadata = common.parse_frontmatter(common.read_text(path))
            if metadata.get('source_provider') == 'granola' and metadata.get('granola_meeting_id') == meeting_id:
                candidates.append(path)
    if len(candidates) > 1:
        raise ValueError('this Granola meeting already has multiple notes in the project')
    return candidates[0] if candidates else None


def ingest_meeting(binding: common.Binding, meeting: Any) -> dict[str, str]:
    meeting_id, title, content = render_meeting(meeting, binding.note_language)
    note_bytes = content.encode('utf-8')
    root = binding.project_root
    if binding.status != 'active' or not root.is_dir():
        raise ValueError('Granola import requires an active, existing Obsidian project binding')
    destination = root / 'Sources' / 'Interviews' / f'granola-{meeting_id}.md'
    source_directories = [root / folder for folder in SOURCE_DIRECTORIES]
    for path in (destination, common.registry_path(root), root / '02-Index.md', *source_directories):
        if not path.resolve().is_relative_to(root):
            raise ValueError('the import path must stay inside the bound Obsidian project')
    (root / '_system').mkdir(parents=True, exist_ok=True)
    with lock_import(root):
        existing = existing_meeting(root, meeting_id)
        if existing is None:
            destination.parent.mkdir(parents=True, exist_ok=True)
            # Exclusive creation preserves an unrelated note at the canonical path.
            stream = destination.open('xb')
            try:
                with stream:
                    stream.write(note_bytes)
            except OSError:
                destination.unlink(missing_ok=True)
                raise
            status = 'created'
            note = destination
        else:
            note = existing
            status = 'archived' if note.is_relative_to(root / 'Archive') else 'existing'
        relative = note.relative_to(root).as_posix()
        if status != 'archived':
            if status == 'existing':
                metadata = common.parse_frontmatter(common.read_text(note), json_string_fields=('title',))
                title = line(metadata.get('title', '').strip() or title, 'existing note title')
                try:
                    title.encode('utf-8')
                except UnicodeEncodeError as exc:
                    raise ValueError('existing note title must be valid UTF-8') from exc
            common.registry_add_or_update(root, relative, title=title, origin='Granola')
            common.update_index(root)
        return {'status': status, 'project_id': binding.project_id, 'note': relative}
