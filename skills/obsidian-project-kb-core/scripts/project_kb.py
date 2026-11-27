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


def moved_meeting_sources(
    project_root: Path, desired: dict[str, str], rows: dict[str, list[dict[str, str]]],
    content_paths: dict[str, str],
) -> dict[str, str]:
    """Recover registered identities before a path-based sync drops their previous links."""
    keyed = {row['Source Key']: row['Path'] for entries in rows.values() for row in entries
             if row.get('Source Key')}
    if not keyed:
        return {}
    providers = {key.partition(':')[0] for key in keyed}

    def note_key(relative: str) -> str | None:
        note = project_root / content_paths.get(relative, relative)
        if Path(relative).suffix != '.md' or note.is_symlink() or not note.resolve().is_relative_to(project_root):
            return None
        try:
            return common.meeting_source_key(note, providers)
        except OSError:
            return None

    displaced = {key for key, link in keyed.items()
                 if link not in desired or note_key(desired[link]) != key}
    if not displaced:
        return {}
    owners = {row['Path'].casefold(): row.get('Source Key') for entries in rows.values()
              for row in entries if row.get('Path')}
    moves: dict[str, str] = {}
    for link, relative in desired.items():
        key = note_key(relative)
        if key is None or key not in displaced:
            continue
        if key in moves:
            raise SystemExit(f'Multiple notes have the same meeting identity: {moves[key]} and {relative}')
        if link.casefold() in owners and owners[link.casefold()] != key:
            raise SystemExit(f'The moved meeting path is already registered to another source: {relative}')
        moves[key] = relative
    return moves


def reconcile_registry(
    project_root: Path, rels: list[str], rows: dict[str, list[dict[str, str]]],
    *, renamed: tuple[str, str] | None = None, content_paths: dict[str, str] | None = None,
) -> dict[str, Any]:
    """Update the proposed registry in memory before writing any changes."""
    existing = registry_links(rows)
    desired = {common.wikilink(rel): rel for rel in rels}
    content_paths = content_paths or {}

    for key, relative in moved_meeting_sources(project_root, desired, rows, content_paths).items():
        update = common.registry_add_or_update(
            project_root, relative, source_key=key, rows=rows, content_path=content_paths.get(relative),
        )
        if not update['updated']:
            raise SystemExit(f"Cannot reconcile moved meeting {relative}: {update['reason']}")
    if renamed is not None:
        previous, current = renamed
        common.registry_add_or_update(project_root, current, rows=rows, content_path=content_paths.get(current))
        if previous != current:
            previous_link = common.wikilink(previous)
            for section, entries in rows.items():
                if section != 'Archive':
                    rows[section] = [row for row in entries if row['Path'] != previous_link]

    added: list[str] = []
    removed: list[str] = []
    for rel in rels:
        result = common.registry_add_or_update(project_root, rel, rows=rows, content_path=content_paths.get(rel))
        if result.get('updated') and common.wikilink(rel) not in existing:
            added.append(rel)

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
    return {'canonical_paths': rels, 'added': added, 'removed': removed}


def sync_registry(project_root: Path) -> dict[str, Any]:
    rows = common.parse_registry_md(common.registry_path(project_root))
    rels = common.scan_canonical_relpaths(project_root)
    result = reconcile_registry(project_root, rels, rows)
    common.write_registry(project_root, rows)
    return result


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
    with common.project_write_lock(binding.project_root):
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


def registry_for_existing_project(repo_root: Path, project_id: str) -> Path:
    project = common.registered_projects(repo_root).get(project_id)
    if project is None:
        raise SystemExit(f'Project {project_id!r} not found in binding registry')
    return project[0]


def update_binding_entry(repo_root: Path, project_id: str, **updates: Any) -> dict[str, Any]:
    reg_path = registry_for_existing_project(repo_root, project_id)
    registry = common.load_binding_registry(reg_path)
    entry = (registry.get('projects') or {}).get(project_id)
    if entry is None:
        raise SystemExit(f'Project {project_id!r} not found in binding registry')
    entry.update(updates)
    entry['updated_at'] = common.now_iso()
    common.save_binding_registry(reg_path, registry)
    return entry


def same_project_root(left: Path, right: Path) -> bool:
    if left == right:
        return True
    try:
        return left.samefile(right)
    except (FileNotFoundError, NotADirectoryError):
        return False


def require_exclusive_project_root(
    binding: common.Binding, projects: dict[str, Any], operation: str,
) -> None:
    for project_id, other in projects.items():
        if project_id == binding.project_id or not other.get('vault_root'):
            continue
        other_root = Path(other['vault_root']).expanduser().resolve()
        if same_project_root(other_root, binding.project_root):
            raise SystemExit(f'Cannot {operation} project {binding.project_id!r}: project {project_id!r} '
                             'also uses this project folder. Resolve the binding conflict first.')


def lifecycle_registries(binding: common.Binding, operation: str) -> list[tuple[Path, str]]:
    aliases = []
    for path in common.binding_registry_paths(binding.repo_root):
        registry = common.load_binding_registry(path)
        projects = registry.get('projects') or {}
        require_exclusive_project_root(binding, projects, operation)
        entry = projects.get(binding.project_id)
        if entry is None:
            continue
        root = Path(entry['vault_root']).expanduser().resolve()
        if same_project_root(root, binding.project_root):
            # After moving or deleting the folder, compare the registered value
            # captured here instead of trying to stat the old path.
            aliases.append((path, entry['vault_root']))
        elif operation == 'purge':
            raise SystemExit(
                f'Cannot purge project {binding.project_id!r}: its bindings point to different project folders '
                f'({binding.project_root} and {root}). Resolve the binding conflict first.'
            )
    if not aliases:
        raise SystemExit(f'Project {binding.project_id!r} is no longer bound to {binding.project_root}')
    return aliases


def read_lifecycle_entry(
    binding: common.Binding, path: Path, registered_root: str, operation: str,
) -> tuple[dict[str, Any], dict[str, Any] | None]:
    registry = common.load_binding_registry(path)
    projects = registry.get('projects') or {}
    require_exclusive_project_root(binding, projects, operation)
    entry = projects.get(binding.project_id)
    if entry is not None and entry['vault_root'] != registered_root:
        raise SystemExit(f'Cannot {operation} project {binding.project_id!r}: the binding changed in {path}')
    return registry, entry


def archive_project(binding: common.Binding) -> dict[str, Any]:
    aliases = lifecycle_registries(binding, 'archive')
    if binding.status == 'archived':
        if not binding.project_root.is_dir():
            raise SystemExit(f'Archived project folder is missing: {binding.project_root}')
        return {'project_id': binding.project_id, 'archived_to': str(binding.project_root)}

    archive_root = binding.vault_path / 'Research' / '_archived'
    archive_root.mkdir(parents=True, exist_ok=True)
    dest = archive_root / f'{binding.project_slug}-{common.today_str()}'
    counter = 1
    while dest.exists():
        counter += 1
        dest = archive_root / f'{binding.project_slug}-{common.today_str()}-{counter}'
    hub_note = common.relative_note_path(dest / '00-Hub.md', binding.vault_path)
    changed: dict[Path, bytes | None] = {}
    shutil.move(str(binding.project_root), str(dest))
    try:
        for path, registered_root in aliases:
            registry_target = path.resolve()
            expected_root = str(dest) if registry_target in changed else registered_root
            registry, entry = read_lifecycle_entry(binding, path, expected_root, 'archive')
            if entry is None:
                continue
            if registry_target not in changed:
                registry_before = registry_target.read_bytes()
                entry.update(vault_root=str(dest), hub_note=hub_note, status='archived',
                             auto_sync=False, updated_at=common.now_iso())
                common.save_binding_registry(registry_target, registry)
                changed[registry_target] = registry_before
            memory_target = path.with_name(f'{binding.project_id}.md').resolve()
            if memory_target in changed:
                continue
            try:
                memory_before = memory_target.read_bytes()
            except FileNotFoundError:
                memory_before = None
            common.update_project_memory(
                binding.repo_root, binding.project_id, dest, hub_note,
                entry.get('note_language', binding.note_language),
                summary=f'project archived to {dest}', memory_path=memory_target,
                status='archived', auto_sync=False, atomic=True,
            )
            changed[memory_target] = memory_before
    except (Exception, SystemExit):
        try:
            if binding.project_root.exists() or binding.project_root.is_symlink():
                raise OSError(f'Original project path was recreated: {binding.project_root}')
            for path, content in reversed(changed.items()):
                if content is None:
                    path.unlink(missing_ok=True)
                else:
                    common.write_atomic(path, content)
            shutil.move(str(dest), str(binding.project_root))
        except Exception as exc:
            raise SystemExit(f'Archive rollback failed. Check {dest} and {binding.project_root}: {exc}') from exc
        raise
    return {'project_id': binding.project_id, 'archived_to': str(dest)}


def purge_project(binding: common.Binding) -> dict[str, Any]:
    aliases = lifecycle_registries(binding, 'purge')

    # Save the primary spelling for physical aliases before deletion. A retry
    # can then still identify the matching registry entries with no folder to stat.
    for i, (path, registered_root) in enumerate(aliases):
        if Path(registered_root).expanduser().resolve() == binding.project_root:
            continue
        registry, entry = read_lifecycle_entry(binding, path, registered_root, 'purge')
        if entry is not None:
            entry['vault_root'] = str(binding.project_root)
            common.save_binding_registry(path, registry)
            aliases[i] = (path, entry['vault_root'])

    # Keep bindings on disk until the project directory has been removed so a
    # failed deletion can be retried against the same project.
    if binding.project_root.exists():
        shutil.rmtree(binding.project_root)

    memory_name = f'{binding.project_id}.md'
    # Two symlinked registries can share one entry but have separate memory files.
    for path, registered_root in reversed(aliases):
        _, entry = read_lifecycle_entry(binding, path, registered_root, 'purge')
        if entry is not None:
            path.with_name(memory_name).unlink(missing_ok=True)
    for path, registered_root in reversed(aliases):
        # Other projects may have been registered during filesystem deletion.
        registry, entry = read_lifecycle_entry(binding, path, registered_root, 'purge')
        if entry is not None:
            registry['projects'].pop(binding.project_id)
            common.save_binding_registry(path, registry)

    return {
        'project_id': binding.project_id,
        'purged_project_root': str(binding.project_root),
        'removed_memory': str(aliases[0][0].with_name(memory_name)),
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


def on_disk_rename_path(project_root: Path, path: Path, *, keep_name: bool = False) -> Path:
    """Use actual filesystem spelling without conflating distinct names."""
    parts = path.relative_to(project_root).parts
    parent = project_root
    for index, name in enumerate(parts):
        entered = parent / name
        if (keep_name and index == len(parts) - 1) or not entered.exists():
            return parent.joinpath(*parts[index:])
        actual = entered
        try:
            if index == 0:
                for base in common.CANONICAL_DIRECTORIES:
                    canonical = parent / base
                    if name.casefold() == base.casefold() and canonical.exists() and entered.samefile(canonical):
                        actual = canonical
                        break
                if actual.name in common.CANONICAL_DIRECTORIES:
                    parent = actual
                    continue
            for sibling in parent.iterdir():
                if sibling.name == name:
                    actual = entered
                    break
                if sibling.name.casefold() == name.casefold() and entered.samefile(sibling):
                    actual = sibling
        except OSError:
            actual = entered
        parent = actual
    return parent


def canonical_paths_after_rename(
    project_root: Path, source: Path, target: Path,
) -> tuple[list[str], dict[str, str]]:
    sources = (path for path in source.rglob('*') if not path.is_dir()) if source.is_dir() else (source,)
    content_paths = {
        (target / path.relative_to(source)).relative_to(project_root).as_posix():
        path.relative_to(project_root).as_posix()
        for path in sources
    }
    rels = set(common.scan_canonical_relpaths(project_root))
    rels.difference_update(content_paths, content_paths.values())
    for rel in content_paths:
        base, separator, _ = rel.partition('/')
        extensions = {'.md', '.canvas'} if base == 'Maps' else {'.md'}
        if separator and base in common.CANONICAL_DIRECTORIES and Path(rel).suffix in extensions:
            rels.add(rel)
    ordered = sorted(rels, key=lambda rel: (common.CANONICAL_DIRECTORIES.index(rel.partition('/')[0]), Path(rel)))
    return ordered, content_paths


def note_lifecycle(binding: common.Binding, mode: str, note: str, dest: str = '', reason: str = 'manual') -> dict[str, Any]:
    with common.project_write_lock(binding.project_root):
        source = common.resolve_project_note(binding.project_root, note)
        if mode == 'rename':
            source = on_disk_rename_path(binding.project_root, source)
        source_rel = str(source.relative_to(binding.project_root)).replace(os.sep, '/')

        if mode == 'rename':
            if not dest:
                raise SystemExit('--dest is required for rename')
            requested = binding.project_root / dest
            target = requested.resolve()
            target_exists = target.exists()
            same_target = target_exists and source.samefile(target)
            if (same_target and requested.name != target.name
                    and requested.name.casefold() == target.name.casefold() and not requested.is_symlink()):
                # Keep an explicit case-only rename on platforms that normalize resolve().
                target = target.with_name(requested.name)
            # shutil.move places a note inside an existing destination directory.
            moved_path = target
            if target.is_dir() and not same_target:
                moved_path = target / source.name
            moved_path = on_disk_rename_path(binding.project_root, moved_path, keep_name=same_target)
            target_rel = moved_path.relative_to(binding.project_root).as_posix()
            source_link = common.wikilink(source_rel).casefold()
            target_link = common.wikilink(target_rel).casefold()
            rows = common.parse_registry_md(common.registry_path(binding.project_root))
            involved = [row for entries in rows.values() for row in entries
                        if row.get('Path', '').casefold() in (source_link, target_link)]
            if any(row.get('Source Key') for row in involved):
                occupied = target_exists and not same_target
                reserved = source_link != target_link and any(
                    row['Path'].casefold() == target_link for row in involved)
                if occupied or reserved:
                    raise SystemExit(f'The rename destination is occupied or reserved: {target_rel}')
            rels, content_paths = canonical_paths_after_rename(binding.project_root, source, moved_path)
            reconcile_registry(
                binding.project_root, rels, rows, renamed=(source_rel, target_rel), content_paths=content_paths,
            )
            ensure_parent(target)
            shutil.move(str(source), str(target))
            rewritten = rewrite_project_references(binding.project_root, source_rel, target_rel)
            common.write_registry(binding.project_root, rows)
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
    # Piped JSON may contain Unicode vault paths on a Windows legacy code page.
    if not sys.stdout.isatty():
        sys.stdout.reconfigure(encoding='utf-8')
    main()
