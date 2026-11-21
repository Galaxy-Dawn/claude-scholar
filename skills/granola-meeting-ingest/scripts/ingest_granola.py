#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
from datetime import date
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit, urlunsplit
from uuid import UUID

KB_SCRIPTS = Path(__file__).resolve().parents[2] / 'obsidian-project-kb-core' / 'scripts'
sys.path.insert(0, str(KB_SCRIPTS))

import kb_common as common  # type: ignore
from project_kb import sync_registry  # type: ignore


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


def meeting_filename(meeting_id: str, meeting_date: str | None, title: str) -> str:
    topic = ''.join(
        char if char.isalnum() or unicodedata.category(char).startswith('M') else '-'
        for char in unicodedata.normalize('NFC', title)
    )
    topic = re.sub(r'-+', '-', topic).strip('-')
    # Leave space for the date and full UUID even when the title is multibyte.
    topic = topic.encode('utf-8')[:96].decode('utf-8', errors='ignore').rstrip('-') or 'note'
    short_date = meeting_date[2:] if meeting_date else 'undated'
    return f'Granola-{short_date}-{topic}-{meeting_id}.md'


def render_meeting(meeting: Any, binding: common.Binding) -> tuple[str, str, str | None, str]:
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
    chinese = binding.note_language.lower().startswith('zh')
    no_owner = '负责人未定' if chinese else 'Owner unspecified'
    no_due = '未设期限' if chinese else 'Due date unspecified'
    empty = '未记录' if chinese else 'None recorded'

    def bullet_items(field: str, *, prefix: str = '') -> list[str]:
        return [f'- {prefix}{plain_markdown(line(value, field))}' for value in items(meeting, field)]

    summary = bullet_items('summary')
    if not summary:
        raise ValueError('summary must contain at least one item')

    rendered_actions = []
    for action in items(meeting, 'action_items'):
        if not isinstance(action, dict):
            raise ValueError('each action item must be an object')
        task = plain_markdown(line(action.get('task'), 'action_items.task'))
        owner = plain_markdown(line(action['owner'], 'action_items.owner')) if action.get('owner') is not None else no_owner
        due = optional_date(action.get('due_date'), 'action_items.due_date') or no_due
        rendered_actions.append(f'- [ ] {task} ({owner}, {due})')

    timestamp = common.now_iso()
    frontmatter = [
        '---', 'type: source', 'source_type: interview',
        f'project: {json.dumps(binding.project_slug, ensure_ascii=False)}',
        'status: active', f'created: {timestamp}', f'updated: {timestamp}',
        'source_provider: granola',
        f'granola_meeting_id: {meeting_id}', f'source_kind: {source_kind}',
        f'title: {json.dumps(title, ensure_ascii=False)}',
    ]
    if meeting_date:
        frontmatter.append(f'meeting_date: {meeting_date}')
    if source_url:
        frontmatter.append(f'source_url: {source_url}')
    lines = [*frontmatter, '---', '', f'# {plain_markdown(title)}', '']

    source = f'[Granola]({source_url})' if source_url else 'Granola'
    kind = {
        'notes': '笔记' if chinese else 'Notes',
        'transcript': '逐字稿' if chinese else 'Transcript',
        'notes-and-transcript': '笔记和逐字稿' if chinese else 'Notes and transcript',
    }[source_kind]
    metadata = [f'- {"来源" if chinese else "Source"}: {source}',
                f'- {"依据" if chinese else "Material reviewed"}: {kind}']
    if meeting_date:
        metadata.append(f'- {"日期" if chinese else "Meeting date"}: {meeting_date}')

    def add_section(english: str, chinese_heading: str, bullets: list[str], level: int = 2) -> None:
        heading = chinese_heading if chinese else english
        lines.extend([f'{"#" * level} {heading}', '', *(bullets or [f'- {empty}']), ''])

    # Follow the source-interview template's headings in the project's language.
    add_section('Metadata', '会议信息', metadata)
    add_section('Project Relevance', '与项目的关系', bullet_items('project_relevance'))
    decision_label = '已定事项' if chinese else 'Decision'
    summary.extend(bullet_items('decisions', prefix=f'**{decision_label}** '))
    add_section('Summary', '摘要', summary)
    add_section('Participants', '参会者', bullet_items('participants'))
    add_section('Context', '背景', bullet_items('context'))
    add_section('Key Quotes', '关键原话', bullet_items('key_quotes'))
    add_section('Observed Needs', '观察到的需求', bullet_items('observed_needs'))

    lines.extend(['## 后续事项' if chinese else '## Follow-ups', ''])
    for english, chinese_heading, bullets in (
        ('Action items', '待办', rendered_actions),
        ('Open questions', '未决问题', bullet_items('open_questions')),
    ):
        add_section(english, chinese_heading, bullets, level=3)
    return meeting_id, title, meeting_date, '\n'.join(lines)


def existing_meeting(project_root: Path, meeting_id: str) -> Path | None:
    candidates = []
    for collection in (project_root, project_root / 'Archive'):
        for name in (*common.CANONICAL_DIRECTORIES, 'Daily'):
            folder = collection / name
            if not folder.resolve().is_relative_to(project_root):
                continue
            for path in folder.rglob('*.md'):
                if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(project_root):
                    continue
                metadata = common.read_frontmatter_fields(path, 'source_provider', 'granola_meeting_id')
                if metadata.get('source_provider', '').strip().casefold() != 'granola':
                    continue
                try:
                    saved_id = str(UUID(metadata.get('granola_meeting_id', '').strip()))
                except ValueError:
                    continue
                if saved_id == meeting_id:
                    candidates.append(path)
    if len(candidates) > 1:
        raise ValueError('this Granola meeting already has multiple notes in the project')
    return candidates[0] if candidates else None


def saved_title(note: Path, fallback: str) -> str:
    title = common.read_frontmatter_fields(note, 'title').get('title', '')
    title = line(title.strip() or fallback, 'existing note title')
    try:
        title.encode('utf-8')
    except UnicodeEncodeError as exc:
        raise ValueError('existing note title must be valid UTF-8') from exc
    return title


def ingest_meeting(binding: common.Binding, meeting: Any) -> dict[str, str]:
    meeting_id, title, meeting_date, content = render_meeting(meeting, binding)
    note_bytes = content.encode('utf-8')
    root = binding.project_root
    if binding.status != 'active' or not root.is_dir():
        raise ValueError('Granola import requires an active, existing Obsidian project binding')
    destination = root / 'Sources' / 'Interviews' / meeting_filename(meeting_id, meeting_date, title)
    registry = common.registry_path(root)
    for path in (destination, registry, root / '02-Index.md'):
        if not path.resolve().is_relative_to(root):
            raise ValueError('the import path must stay inside the bound Obsidian project')
    with common.project_write_lock(root):
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
                title = saved_title(note, title)
            try:
                needs_registry_rebuild = registry.stat().st_size == 0
            except FileNotFoundError:
                needs_registry_rebuild = True
            if needs_registry_rebuild:
                sync_registry(root)
            result = common.registry_add_or_update(root, relative, title=title, origin='Granola')
            if not result['updated']:
                raise ValueError(f'the existing note cannot be registered at {relative}')
            common.update_index(root)
        return {'status': status, 'project_id': binding.project_id, 'note': relative}


def resolve_granola_binding(repo_root: Path, project_id: str | None) -> common.Binding:
    # Explicit Granola requests may select a preview project alongside the standard binding.
    registry = common.binding_registry_path(repo_root)
    preview = repo_root / '.codex' / 'project-memory' / 'registry.yaml'
    if project_id is not None and registry != preview and preview.is_file():
        registered = common.load_binding_registry(registry).get('projects') or {}
        if project_id not in registered:
            preview_projects = common.load_binding_registry(preview).get('projects') or {}
            if project_id in preview_projects:
                return common.resolve_binding(repo_root, project_id, registry_file=preview)
    return common.resolve_binding(repo_root, project_id)


def main() -> None:
    parser = argparse.ArgumentParser(description='Import a summarized Granola meeting into a bound Obsidian project.')
    parser.add_argument('--cwd', type=Path, default=Path.cwd(), help='Repository bound to the Obsidian project.')
    parser.add_argument('--project-id', help='Select a specific registered project.')
    parser.add_argument('--input', required=True, help='Meeting JSON file, or - for standard input.')
    args = parser.parse_args()

    try:
        if args.input == '-':
            meeting = json.load(sys.stdin.buffer)
        else:
            with Path(args.input).expanduser().open('rb') as stream:
                meeting = json.load(stream)
        repo_root = common.find_repo_root(args.cwd.expanduser().resolve())
        binding = resolve_granola_binding(repo_root, args.project_id)
        result = ingest_meeting(binding, meeting)
    except (OSError, ValueError) as exc:
        raise SystemExit(f'Granola import failed: {exc}') from exc
    output = json.dumps(result, ensure_ascii=False, indent=2)
    sys.stdout.buffer.write((output + '\n').encode('utf-8'))


if __name__ == '__main__':
    main()
