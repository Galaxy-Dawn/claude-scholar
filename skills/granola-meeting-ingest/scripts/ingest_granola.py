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
from urllib.parse import quote, urlsplit, urlunsplit
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


def meeting_filename(meeting_date: str | None, title: str) -> str:
    topic = ''.join(
        char if char.isalnum() or unicodedata.category(char).startswith('M') else '-'
        for char in unicodedata.normalize('NFC', title)
    )
    topic = re.sub(r'-+', '-', topic).strip('-')
    topic = topic.encode('utf-8')[:96].decode('utf-8', errors='ignore').rstrip('-') or 'note'
    short_date = meeting_date[2:] if meeting_date else 'undated'
    return f'Granola-{short_date}-{topic}.md'


def create_meeting_note(project_root: Path, path: Path, content: bytes) -> Path:
    rows = common.parse_registry_md(common.registry_path(project_root))
    registered_links = {
        row['Path'].casefold()
        for section, entries in rows.items() if section != 'Archive'
        for row in entries
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    stem = path.stem
    number = 1
    while True:
        link = common.wikilink(path.relative_to(project_root).as_posix()).casefold()
        if link not in registered_links:
            try:
                stream = path.open('xb')
                break
            except FileExistsError:
                pass
        number += 1
        path = path.with_name(f'{stem}-{number}.md')
    try:
        with stream:
            stream.write(content)
    except OSError:
        path.unlink(missing_ok=True)
        raise
    return path


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


def legacy_filename_meeting_id(stem: str) -> str | None:
    if stem.casefold().startswith('granola-') and stem[-37:-36] == '-':
        try:
            return str(UUID(stem[-36:]))
        except ValueError:
            return None
    return None


def legacy_registry_link(
    root: Path, note: Path, meeting_id: str, previous_note: Path | None,
) -> str | None:
    """Find the displaced registry row by UUID or the caller's explicit old path."""
    if previous_note is not None:
        if previous_note.is_absolute() or '..' in previous_note.parts or previous_note.suffix != '.md':
            raise ValueError('--previous-note requires a project-relative Markdown path')
        if legacy_filename_meeting_id(previous_note.stem) not in (None, meeting_id):
            raise ValueError('--previous-note contains a different meeting UUID')

    registry = common.parse_registry_md(common.registry_path(root))
    key = f'granola:{meeting_id}'
    if any(row.get('Source Key') == key for rows in registry.values() for row in rows):
        return None

    missing_links = []
    for row in registry['Sources']:
        if row.get('Source Key') or row.get('Origin') != 'Granola':
            continue
        link = row['Path']
        if not link.startswith('[[Sources/') or not link.endswith(']]'):
            continue
        old_note = root / (link[2:-2] + '.md')
        if old_note.resolve().is_relative_to(root) and not old_note.is_symlink() and not old_note.exists():
            missing_links.append(link)

    candidates = [
        link for link in missing_links
        if legacy_filename_meeting_id(Path(link[2:-2]).name) == meeting_id
    ]
    if previous_note is not None:
        previous_link = common.wikilink(previous_note.as_posix())
        if missing_links.count(previous_link) != 1:
            raise ValueError('--previous-note must identify one unmarked Granola registry entry with a missing file')
        if candidates and previous_link not in candidates:
            raise ValueError('--previous-note conflicts with a legacy filename carrying this meeting UUID')
        return previous_link

    if len(candidates) > 1:
        raise ValueError('multiple missing legacy Granola registry entries carry this meeting UUID')
    if candidates:
        return candidates[0]

    current_link = common.wikilink(note.relative_to(root).as_posix())
    if missing_links and not any(row.get('Path') == current_link for rows in registry.values() for row in rows):
        raise ValueError('cannot identify the old Granola registry entry; use --previous-note with its old path')
    return None


def import_target(binding: common.Binding) -> dict[str, str]:
    if binding.status != 'active' or not binding.project_root.is_dir():
        raise ValueError('Granola import requires an active, existing Obsidian project binding')
    return {
        'project_id': binding.project_id, 'vault_path': str(binding.vault_path),
        'project_folder': binding.project_root.relative_to(binding.vault_path).as_posix(),
    }


def ingest_meeting(
    binding: common.Binding, meeting: Any, *, previous_note: Path | None = None,
) -> dict[str, str]:
    target = import_target(binding)
    meeting_id, title, meeting_date, content = render_meeting(meeting, binding)
    note_bytes = content.encode('utf-8')
    root = binding.project_root
    interviews = root / 'Sources' / 'Interviews'
    registry = common.registry_path(root)
    for path in (interviews, registry, root / '02-Index.md'):
        if not path.resolve().is_relative_to(root):
            raise ValueError('the import path must stay inside the bound Obsidian project')
    with common.project_write_lock(root):
        existing = existing_meeting(root, meeting_id)
        if previous_note is not None and (existing is None or existing.is_relative_to(root / 'Archive')):
            raise ValueError('--previous-note requires an existing, unarchived meeting note')
        if existing is None:
            note = create_meeting_note(root, interviews / meeting_filename(meeting_date, title), note_bytes)
            status = 'created'
        else:
            note = existing
            status = 'archived' if note.is_relative_to(root / 'Archive') else 'existing'
        relative = note.relative_to(root).as_posix()
        if status != 'archived':
            old_link = None
            if status == 'existing':
                title = saved_title(note, title)
                old_link = legacy_registry_link(root, note, meeting_id, previous_note)
            try:
                needs_registry_rebuild = registry.stat().st_size == 0
            except FileNotFoundError:
                needs_registry_rebuild = True
            if needs_registry_rebuild:
                sync_registry(root)
            result = common.registry_add_or_update(
                root, relative, title=title, origin='Granola',
                source_key=f'granola:{meeting_id}', previous_link=old_link,
            )
            if not result['updated']:
                if result['reason'] == 'path-owned-by-another-source':
                    raise ValueError(f'the note path is already registered to another source: {relative}')
                raise ValueError(f'the existing note cannot be registered at {relative}')
            common.update_index(root)
        return {
            **target, 'status': status, 'note': relative,
            'vault_note': note.relative_to(binding.vault_path).as_posix(),
            'obsidian_uri': 'obsidian://open?path=' + quote(str(note), safe=''),
        }


def resolve_granola_binding(repo_root: Path, project_id: str | None) -> common.Binding:
    registered = {key: entry for key, (_, entry) in common.registered_projects(repo_root).items()}
    if not registered:
        raise ValueError('Bind the project to the intended existing Obsidian vault before importing')
    if project_id is None:
        matches = [key for key, entry in registered.items()
                   if any(Path(p).expanduser().resolve() == repo_root for p in entry.get('repo_roots') or [])]
        if len(matches) == 1:
            project_id = matches[0]
        elif len(registered) > 1:
            raise ValueError('Choose a binding with --project-id: ' + ', '.join(sorted(matches or registered)))
        elif next(iter(registered.values())).get('repo_roots'):
            raise ValueError('The binding belongs to another repository. Confirm its vault and project before '
                             'selecting it with --project-id.')
    return common.resolve_binding(repo_root, project_id)


def main() -> None:
    parser = argparse.ArgumentParser(description='Import a summarized Granola meeting into a bound Obsidian project.')
    parser.add_argument('--cwd', type=Path, default=Path.cwd(), help='Repository bound to the Obsidian project.')
    parser.add_argument('--project-id', help='Select a specific registered project.')
    parser.add_argument('--expect-vault', type=Path, help='Require this vault folder to match the project binding.')
    parser.add_argument('--previous-note', type=Path, help='Missing project-relative path of an unmarked Granola entry.')
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--show-target', action='store_true', help='Show the bound vault and project without writing.')
    action.add_argument('--input', help='Meeting JSON file, or - for standard input.')
    args = parser.parse_args()
    if args.previous_note is not None and args.show_target:
        parser.error('--previous-note requires --input')

    try:
        repo_root = common.find_repo_root(args.cwd.expanduser().resolve())
        binding = resolve_granola_binding(repo_root, args.project_id)
        if args.expect_vault is not None and not args.expect_vault.expanduser().samefile(binding.vault_path):
            raise ValueError(f'Bound vault {binding.vault_path} does not match the requested vault {args.expect_vault}')
        if args.show_target:
            result = import_target(binding)
        else:
            if args.input == '-':
                meeting = json.load(sys.stdin.buffer)
            else:
                with Path(args.input).expanduser().open('rb') as stream:
                    meeting = json.load(stream)
            result = ingest_meeting(binding, meeting, previous_note=args.previous_note)
    except (OSError, ValueError) as exc:
        raise SystemExit(f'Granola import failed: {exc}') from exc
    output = json.dumps(result, ensure_ascii=False, indent=2)
    sys.stdout.buffer.write((output + '\n').encode('utf-8'))


if __name__ == '__main__':
    main()
