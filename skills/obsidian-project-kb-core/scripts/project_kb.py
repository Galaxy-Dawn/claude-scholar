#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import kb_common as common  # type: ignore


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Project-scoped Obsidian KB helper.')
    subparsers = parser.add_subparsers(dest='command', required=True)

    detect = subparsers.add_parser('detect', help='Detect repo binding and candidate status.')
    detect.add_argument('--cwd', default='.')

    bootstrap = subparsers.add_parser('bootstrap', help='Create or rebuild a bound project KB.')
    bootstrap.add_argument('--cwd', default='.')
    bootstrap.add_argument('--vault-path', default='')
    bootstrap.add_argument('--project-name', default='')
    bootstrap.add_argument('--project-id', default='')
    bootstrap.add_argument('--note-language', default='en')
    bootstrap.add_argument('--force', action='store_true')

    sync = subparsers.add_parser('sync', help='Refresh scaffold, registry, index, daily note, and runtime binding summary.')
    sync.add_argument('--cwd', default='.')
    sync.add_argument('--project-id', default='')
    sync.add_argument('--scope', default='auto')

    status = subparsers.add_parser('status', help='Return a compact project KB status summary.')
    status.add_argument('--cwd', default='.')
    status.add_argument('--project-id', default='')

    lifecycle = subparsers.add_parser('lifecycle', help='Manage project-level lifecycle state.')
    lifecycle.add_argument('--cwd', default='.')
    lifecycle.add_argument('--project-id', default='')
    lifecycle.add_argument('--mode', choices=['detach', 'archive', 'purge', 'rebuild'], required=True)
    lifecycle.add_argument('--vault-path', default='')
    lifecycle.add_argument('--force', action='store_true')

    query = subparsers.add_parser('query-context', help='Return note context candidates for the current project.')
    query.add_argument('--cwd', default='.')
    query.add_argument('--project-id', default='')
    query.add_argument('--kind', default='broad')
    query.add_argument('--query', default='')

    find = subparsers.add_parser('find-canonical-note', help='Find canonical notes by kind and query.')
    find.add_argument('--cwd', default='.')
    find.add_argument('--project-id', default='')
    find.add_argument('--kind', required=True)
    find.add_argument('--query', required=True)
    find.add_argument('--limit', type=int, default=5)

    note = subparsers.add_parser('note-lifecycle', help='Manage a single canonical note.')
    note.add_argument('--cwd', default='.')
    note.add_argument('--project-id', default='')
    note.add_argument('--mode', choices=['archive', 'purge', 'rename'], required=True)
    note.add_argument('--note', required=True)
    note.add_argument('--dest', default='')
    note.add_argument('--reason', default='manual')

    return parser.parse_args()


def repo_root_from(cwd: str) -> Path:
    return common.find_repo_root(Path(cwd).expanduser().resolve())


def registry_links(rows: dict[str, list[dict[str, str]]]) -> dict[str, str]:
    links: dict[str, str] = {}
    for section, entries in rows.items():
        if section == 'Archive':
            continue
        for row in entries:
            path = row.get('Path', '')
            if path:
                links[path] = section
    return links


def sync_registry(project_root: Path) -> dict[str, Any]:
    rels = common.scan_canonical_relpaths(project_root)
    rows = common.parse_registry_md(common.registry_path(project_root))
    existing = registry_links(rows)
    desired = {common.wikilink(rel): rel for rel in rels}

    added: list[str] = []
    removed: list[str] = []
    for rel in rels:
        result = common.registry_add_or_update(project_root, rel)
        if result.get('updated') and common.wikilink(rel) not in existing:
            added.append(rel)

    rows = common.parse_registry_md(common.registry_path(project_root))
    for section in list(rows):
        if section == 'Archive':
            continue
        keep: list[dict[str, str]] = []
        for row in rows[section]:
            link = row.get('Path', '')
            if link in desired:
                keep.append(row)
            else:
                removed.append(link)
        rows[section] = keep
    common.write_registry(project_root, rows)
    return {'canonical_paths': rels, 'added': added, 'removed': removed}


def update_hub_link_block(binding: common.Binding) -> None:
    hub_path = binding.project_root / '00-Hub.md'
    content = common.read_text(hub_path)
    required_lines = [
        '- [[01-Plan]]',
        '- [[02-Index]]',
        '- [[_system/registry]]',
        f'- [[Daily/{common.today_str()}]]',
    ]
    marker = '## Important Links\n'
    if marker not in content:
        content = content.rstrip() + '\n\n' + marker + '\n'.join(required_lines) + '\n'
    else:
        head, tail = content.split(marker, 1)
        rest_lines = tail.splitlines()
        collected: list[str] = []
        skipping = True
        idx = 0
        while idx < len(rest_lines):
            line = rest_lines[idx]
            if skipping and (line.startswith('- ') or not line.strip()):
                idx += 1
                continue
            skipping = False
            collected = rest_lines[idx:]
            break
        content = head + marker + '\n'.join(required_lines) + '\n\n' + '\n'.join(collected).lstrip('\n')
    common.write_text(hub_path, content.rstrip() + '\n')


def run_sync(binding: common.Binding, scope: str = 'auto') -> dict[str, Any]:
    common.ensure_project_scaffold(binding.project_root, binding.project_slug, common.titleize_slug(binding.project_slug))
    migrated = common.maybe_migrate_old_layout(binding.project_root)
    daily_path = common.ensure_today_daily(binding.project_root, binding.project_slug)
    registry_result = sync_registry(binding.project_root)
    common.update_index(binding.project_root)
    update_hub_link_block(binding)
    summary = f'scope={scope}; canonical={len(registry_result["canonical_paths"])}; added={len(registry_result["added"])}; migrated={len(migrated)}'
    common.update_project_memory(
        binding.repo_root,
        binding.project_id,
        binding.project_root,
        common.relative_note_path(binding.project_root / '00-Hub.md', binding.vault_path),
        binding.note_language,
        summary=summary,
    )
    common.prepend_recent_change(binding.project_root, f'{common.now_iso()}: sync refreshed scaffold, registry, index, and daily note ({scope}).')
    return {
        'project_id': binding.project_id,
        'project_root': str(binding.project_root),
        'daily_note': str(daily_path),
        'migrated_paths': migrated,
        'registry_added': registry_result['added'],
        'registry_removed': registry_result['removed'],
        'canonical_count': len(registry_result['canonical_paths']),
        'scope': scope,
    }


def load_binding(repo_root: Path, project_id: str | None) -> common.Binding:
    return common.resolve_binding(repo_root, project_id or None)


def update_binding_entry(repo_root: Path, project_id: str, **updates: Any) -> dict[str, Any]:
    reg_path = common.binding_registry_path(repo_root)
    registry = common.load_binding_registry(reg_path)
    entry = (registry.get('projects') or {}).get(project_id)
    if entry is None:
        raise SystemExit(f'Project {project_id!r} not found in binding registry')
    entry.update(updates)
    entry['updated_at'] = common.now_iso()
    common.save_binding_registry(reg_path, registry)
    return entry


def archive_project(binding: common.Binding) -> dict[str, Any]:
    archive_root = binding.vault_path / 'Research' / '_archived'
    archive_root.mkdir(parents=True, exist_ok=True)
    dest = archive_root / f'{binding.project_slug}-{common.today_str()}'
    counter = 1
    while dest.exists():
        counter += 1
        dest = archive_root / f'{binding.project_slug}-{common.today_str()}-{counter}'
    shutil.move(str(binding.project_root), str(dest))
    entry = update_binding_entry(
        binding.repo_root,
        binding.project_id,
        vault_root=str(dest),
        hub_note=common.relative_note_path(dest / '00-Hub.md', binding.vault_path),
        status='archived',
        auto_sync=False,
    )
    common.update_project_memory(
        binding.repo_root,
        binding.project_id,
        dest,
        entry['hub_note'],
        binding.note_language,
        summary=f'project archived to {dest}',
    )
    return {'project_id': binding.project_id, 'archived_to': str(dest)}


def purge_project(binding: common.Binding) -> dict[str, Any]:
    reg_path = common.binding_registry_path(binding.repo_root)
    registry = common.load_binding_registry(reg_path)
    registry.setdefault('projects', {}).pop(binding.project_id, None)
    common.save_binding_registry(reg_path, registry)
    memory_path = common.project_memory_path(binding.repo_root, binding.project_id)
    if memory_path.exists():
        memory_path.unlink()
    if binding.project_root.exists():
        shutil.rmtree(binding.project_root)
    return {
        'project_id': binding.project_id,
        'purged_project_root': str(binding.project_root),
        'removed_memory': str(memory_path),
    }


def detach_project(binding: common.Binding) -> dict[str, Any]:
    entry = update_binding_entry(binding.repo_root, binding.project_id, status='detached', auto_sync=False)
    common.update_project_memory(
        binding.repo_root,
        binding.project_id,
        binding.project_root,
        entry['hub_note'],
        binding.note_language,
        summary='project detached; vault content preserved',
    )
    return {'project_id': binding.project_id, 'status': 'detached', 'project_root': str(binding.project_root)}


def refresh_or_rebuild(repo_root: Path, project_id: str | None, vault_path: str, force: bool) -> dict[str, Any]:
    if project_id:
        binding = load_binding(repo_root, project_id)
        target_vault = Path(vault_path).expanduser().resolve() if vault_path else binding.vault_path
        result = common.bootstrap_binding(repo_root, target_vault, project_name=binding.project_slug, force=True, note_language=binding.note_language)
        result['rebuild'] = True
        return result
    target_vault = Path(vault_path or os.environ.get('OBSIDIAN_VAULT_PATH', '')).expanduser()
    if not str(target_vault):
        raise SystemExit('Rebuild requires --vault-path or OBSIDIAN_VAULT_PATH')
    return common.bootstrap_binding(repo_root, target_vault, force=force)


def broad_context(binding: common.Binding) -> dict[str, Any]:
    daily_path = binding.project_root / 'Daily' / f'{common.today_str()}.md'
    payload = {
        'project_id': binding.project_id,
        'project_root': str(binding.project_root),
        'hub': str(binding.project_root / '00-Hub.md'),
        'plan': str(binding.project_root / '01-Plan.md'),
        'index': str(binding.project_root / '02-Index.md'),
        'daily': str(daily_path) if daily_path.exists() else '',
    }
    return payload


def query_context(binding: common.Binding, kind: str, query: str) -> dict[str, Any]:
    if kind == 'broad':
        return broad_context(binding)
    candidates = common.search_note_candidates(binding.project_root, kind, query or kind, limit=8)
    return {
        'project_id': binding.project_id,
        'kind': kind,
        'query': query,
        'candidates': [str(path) for path in candidates],
    }


def replace_links_in_text(content: str, old_rel: str, new_rel: str | None) -> str:
    if new_rel is not None:
        return common.replace_wikilinks(content, old_rel, new_rel)

    old_variants = {old_rel, old_rel[:-3] if old_rel.endswith('.md') else old_rel}
    old_title = Path(old_rel).stem.replace('-', ' ')

    def repl(match: Any) -> str:
        inner = match.group(1)
        target, *rest = inner.split('|', 1)
        target_no_heading = target.split('#', 1)[0]
        if target_no_heading not in old_variants:
            return match.group(0)
        if rest:
            return rest[0]
        return old_title

    import re
    return re.sub(r'\[\[([^\]]+)\]\]', repl, content)


def rewrite_project_references(project_root: Path, old_rel: str, new_rel: str | None) -> list[str]:
    touched: list[str] = []
    for path in sorted(project_root.rglob('*')):
        if path.is_dir():
            continue
        rel = str(path.relative_to(project_root)).replace(os.sep, '/')
        if rel == '02-Index.md' or rel.startswith('_system/'):
            continue
        if path.suffix == '.md':
            before = common.read_text(path)
            after = replace_links_in_text(before, old_rel, new_rel)
            if after != before:
                common.write_text(path, after)
                touched.append(str(path))
        elif path.suffix == '.canvas':
            before = common.read_text(path)
            marker_old = old_rel.replace('\\', '/')
            marker_new = '' if new_rel is None else new_rel.replace('\\', '/')
            after = before.replace(marker_old, marker_new) if marker_old in before else before
            if after != before:
                common.write_text(path, after)
                touched.append(str(path))
    return touched


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def note_lifecycle(binding: common.Binding, mode: str, note: str, dest: str = '', reason: str = 'manual') -> dict[str, Any]:
    source = common.resolve_project_note(binding.project_root, note)
    source_rel = str(source.relative_to(binding.project_root)).replace(os.sep, '/')

    if mode == 'rename':
        if not dest:
            raise SystemExit('--dest is required for rename')
        target = (binding.project_root / dest).resolve()
        ensure_parent(target)
        shutil.move(str(source), str(target))
        target_rel = str(target.relative_to(binding.project_root)).replace(os.sep, '/')
        rewritten = rewrite_project_references(binding.project_root, source_rel, target_rel)
        common.registry_add_or_update(binding.project_root, target_rel)
        common.registry_remove_path(binding.project_root, source_rel, reason='renamed', record_archive=False)
        sync_registry(binding.project_root)
        common.update_index(binding.project_root)
        source_label = Path(source_rel).stem.replace('-', ' ')
        target_link = target_rel[:-3] if target_rel.endswith('.md') else target_rel
        common.prepend_recent_change(binding.project_root, f'{common.now_iso()}: renamed {source_label} -> [[{target_link}]].')
        return {'mode': mode, 'from': source_rel, 'to': target_rel, 'rewritten_paths': rewritten}

    if mode == 'archive':
        archived = binding.project_root / 'Archive' / source_rel
        ensure_parent(archived)
        shutil.move(str(source), str(archived))
        archived_rel = str(archived.relative_to(binding.project_root)).replace(os.sep, '/')
        rewritten = rewrite_project_references(binding.project_root, source_rel, archived_rel)
        common.registry_archive(binding.project_root, source_rel, archived_rel, reason=reason)
        common.update_index(binding.project_root)
        common.prepend_recent_change(binding.project_root, f'{common.now_iso()}: archived [[{source_rel[:-3] if source_rel.endswith(".md") else source_rel}]].')
        return {'mode': mode, 'from': source_rel, 'to': archived_rel, 'rewritten_paths': rewritten}

    if mode == 'purge':
        source.unlink()
        rewritten = rewrite_project_references(binding.project_root, source_rel, None)
        common.registry_remove_path(binding.project_root, source_rel, reason=reason)
        common.update_index(binding.project_root)
        common.prepend_recent_change(binding.project_root, f'{common.now_iso()}: purged {source_rel}.')
        return {'mode': mode, 'purged': source_rel, 'rewritten_paths': rewritten}

    raise SystemExit(f'Unsupported note lifecycle mode: {mode}')


def project_status(binding: common.Binding) -> dict[str, Any]:
    rows = common.parse_registry_md(common.registry_path(binding.project_root))
    daily_path = binding.project_root / 'Daily' / f'{common.today_str()}.md'
    lint_path = binding.project_root / '_system' / 'lint-report.md'
    archived_refs = {row.get('Archived Path', '')[2:-2] for row in rows.get('Archive', []) if row.get('Archived Path', '').startswith('[[')}
    active_notes_referencing_archived_notes = 0
    experiments_with_only_archived_results = 0
    for path in sorted(binding.project_root.rglob('*.md')):
        rel = str(path.relative_to(binding.project_root)).replace(os.sep, '/')
        if rel.startswith('Archive/') or rel.startswith('_system/'):
            continue
        refs = {match.strip() for match in re.findall(r'\[\[([^\]|#]+)', path.read_text(encoding='utf-8'))}
        archived_hits = refs & archived_refs
        if archived_hits:
            active_notes_referencing_archived_notes += len(archived_hits)
        if rel.startswith('Experiments/'):
            has_active_result = bool(re.search(r'\[\[(Results/[^\]|#]+)', path.read_text(encoding='utf-8')))
            has_archived_result = bool(re.search(r'\[\[(Archive/Results/[^\]|#]+)', path.read_text(encoding='utf-8')))
            if has_archived_result and not has_active_result:
                experiments_with_only_archived_results += 1
    return {
        'project_id': binding.project_id,
        'project_root': str(binding.project_root),
        'status': binding.status,
        'auto_sync': binding.auto_sync,
        'sources': len(rows.get('Sources', [])),
        'knowledge': len(rows.get('Knowledge', [])),
        'experiments': len(rows.get('Experiments', [])),
        'results': len(rows.get('Results', [])),
        'writing': len(rows.get('Writing', [])),
        'maps': len(rows.get('Maps', [])),
        'archive': len(rows.get('Archive', [])),
        'experiments_with_only_archived_results': experiments_with_only_archived_results,
        'active_notes_referencing_archived_notes': active_notes_referencing_archived_notes,
        'daily_note': str(daily_path) if daily_path.exists() else '',
        'lint_report': str(lint_path) if lint_path.exists() else '',
    }


def main() -> None:
    args = parse_args()
    repo_root = repo_root_from(getattr(args, 'cwd', '.'))

    if args.command == 'detect':
        print(json.dumps(common.detect(repo_root), ensure_ascii=False, indent=2))
        return

    if args.command == 'bootstrap':
        vault_arg = args.vault_path or os.environ.get('OBSIDIAN_VAULT_PATH', '')
        if not vault_arg:
            raise SystemExit('bootstrap requires --vault-path or OBSIDIAN_VAULT_PATH')
        result = common.bootstrap_binding(
            repo_root,
            Path(vault_arg),
            project_name=args.project_name or None,
            force=args.force,
            note_language=args.note_language,
        )
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    binding = load_binding(repo_root, getattr(args, 'project_id', '') or None)

    if args.command == 'sync':
        print(json.dumps(run_sync(binding, scope=args.scope), ensure_ascii=False, indent=2))
        return

    if args.command == 'status':
        print(json.dumps(project_status(binding), ensure_ascii=False, indent=2))
        return

    if args.command == 'lifecycle':
        if args.mode == 'detach':
            result = detach_project(binding)
        elif args.mode == 'archive':
            result = archive_project(binding)
        elif args.mode == 'purge':
            result = purge_project(binding)
        elif args.mode == 'rebuild':
            result = refresh_or_rebuild(repo_root, binding.project_id, args.vault_path, args.force)
        else:
            raise SystemExit(f'Unsupported lifecycle mode: {args.mode}')
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.command == 'query-context':
        print(json.dumps(query_context(binding, args.kind, args.query), ensure_ascii=False, indent=2))
        return

    if args.command == 'find-canonical-note':
        candidates = common.search_note_candidates(binding.project_root, args.kind, args.query, limit=args.limit)
        payload = {
            'project_id': binding.project_id,
            'kind': args.kind,
            'query': args.query,
            'candidates': [str(path.relative_to(binding.project_root)).replace(os.sep, '/') for path in candidates],
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return

    if args.command == 'note-lifecycle':
        print(json.dumps(note_lifecycle(binding, args.mode, args.note, args.dest, args.reason), ensure_ascii=False, indent=2))
        return

    raise SystemExit(f'Unhandled command: {args.command}')


if __name__ == '__main__':
    main()
