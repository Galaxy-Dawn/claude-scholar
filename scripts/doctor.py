#!/usr/bin/env python3
"""Report the local Codex Scholar installation and its optional integrations."""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path, PureWindowsPath


COMPONENTS = (
    'skills/research-ideation/SKILL.md',
    'skills/results-analysis/SKILL.md',
    'skills/ml-paper-writing/SKILL.md',
    'skills/obsidian-project-kb-core/SKILL.md',
    'skills/obsidian-source-ingestion/SKILL.md',
    'agents/paper-miner.toml',
    'skills/obsidian-project-kb-core/scripts/project_kb.py',
    'skills/obsidian-project-kb-core/scripts/kb_common.py',
)
RECEIPT = '.codex-scholar-install-state'
MANIFEST = '.codex-scholar-manifest.txt'


def is_install_path(value: object) -> bool:
    if not isinstance(value, str) or not value.isprintable() or '\\' in value or PureWindowsPath(value).anchor:
        return False
    return all(part not in ('', '.', '..') for part in value.split('/'))


def local_path(home: Path, relative: str) -> Path:
    path = (home / relative).resolve()
    path.relative_to(home)  # Also confine symlinks to the selected installation.
    return path


def installation(codex_home: Path) -> dict:
    codex_home = codex_home.resolve()
    receipt_file = codex_home / RECEIPT
    manifest_file = codex_home / MANIFEST
    try:
        state = json.loads(local_path(codex_home, RECEIPT).read_text(encoding='utf-8'))
        paths = state.get('managedPaths') if isinstance(state, dict) else None
        valid_state = isinstance(paths, list) and all(is_install_path(path) for path in paths)
    except (OSError, RuntimeError, ValueError):
        state, paths, valid_state = {}, None, False
    try:
        managed = set(local_path(codex_home, MANIFEST).read_text(encoding='utf-8').splitlines())
        valid_manifest = all(is_install_path(path) for path in managed) and (not valid_state or managed == set(paths))
    except (OSError, RuntimeError, ValueError):
        managed, valid_manifest = set(), False

    recorded_files = managed if valid_state and valid_manifest else set()
    missing = set()
    for relative in recorded_files.union(COMPONENTS):
        try:
            # Pre-existing, unowned core components can be user-managed symlinks.
            path = local_path(codex_home, relative) if relative in recorded_files else codex_home / relative
            if path.is_file():
                continue
        except (OSError, RuntimeError, ValueError):
            pass
        missing.add(relative)
    entries = [
        {'path': relative, 'present': relative not in missing, 'managed': valid_manifest and relative in managed}
        for relative in COMPONENTS
    ]
    if valid_state and valid_manifest:
        status = 'incomplete' if missing else 'installed'
    elif os.path.lexists(receipt_file) or os.path.lexists(manifest_file):
        status = 'incomplete_receipt'
    elif any(item['present'] for item in entries):
        status = 'components_only'
    else:
        status = 'not_detected'

    revision = state.get('sourceRevision') if valid_state else None
    return {
        'status': status,
        'manifest_valid': valid_manifest,
        'receipt_valid': valid_state,
        'source_revision': revision if isinstance(revision, str) and re.fullmatch(r'[0-9a-f]{40,64}', revision) else None,
        'source_modified': state.get('sourceModified') if valid_state and isinstance(state.get('sourceModified'), bool) else None,
        'components': entries,
        'missing_managed_paths': sorted(missing & recorded_files),
    }


def mcp_status(codex_home: Path) -> dict:
    result = {'scope': 'user_config', 'servers': None}
    if not codex_home.is_dir():
        return {**result, 'status': 'codex_home_missing'}
    config = codex_home / 'config.toml'
    try:
        with config.open('rb') as stream:
            try:
                import tomllib
            except ImportError:  # Python < 3.11
                import tomli as tomllib
            servers = tomllib.load(stream).get('mcp_servers', {})
    except FileNotFoundError:
        if config.is_symlink():
            return {**result, 'status': 'unavailable'}
        servers = {}
    except ImportError:
        return {**result, 'status': 'toml_reader_missing'}
    except (OSError, ValueError):
        return {**result, 'status': 'unavailable'}

    if not isinstance(servers, dict):
        return {**result, 'status': 'unavailable'}
    reported = {}
    for name in ('zotero', 'granola'):
        entry = servers.get(name, {})
        if not isinstance(entry, dict) or not isinstance(entry.get('enabled', True), bool):
            return {**result, 'status': 'unavailable'}
        configured = name in servers
        reported[name] = {'configured': configured, 'enabled': entry.get('enabled', True) if configured else None}
    return {**result, 'status': 'configured_servers_read', 'servers': reported}


def obsidian_binding(cwd: Path) -> dict:
    helpers = Path(__file__).resolve().parents[1] / 'skills/obsidian-project-kb-core/scripts'
    if not (helpers / 'kb_common.py').is_file():
        return {'status': 'helper_unavailable'}
    sys.path.insert(0, str(helpers))
    try:
        import kb_common as kb
    finally:
        sys.path.pop(0)

    repo = kb.find_repo_root(cwd)
    registry = kb.binding_registry_path(repo)
    documented = repo / '.codex/project-memory/registry.yaml'
    if not registry.is_file():
        if registry != documented and documented.is_file():
            return {'status': 'registry_not_used_by_helper', 'registry': str(documented)}
        return {'status': 'unbound'}
    try:
        binding = kb.resolve_binding(repo)
    except (OSError, ValueError, KeyError, TypeError, AttributeError, SystemExit):
        return {'status': 'binding_unresolved', 'registry': str(registry)}
    if binding.status == 'active':
        status = 'bound' if binding.project_root.is_dir() else 'vault_path_missing'
    elif binding.status in ('archived', 'detached'):
        status = binding.status
    else:
        return {'status': 'binding_unresolved', 'registry': str(registry)}
    return {
        'status': status,
        'registry': str(registry),
        'project_id': binding.project_id,
        'binding_status': binding.status,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--codex-home', type=Path, default=Path(os.environ.get('CODEX_HOME') or Path.home() / '.codex'))
    parser.add_argument('--cwd', type=Path, default=Path.cwd(), help='Research repository to check.')
    parser.add_argument('--json', action='store_true', help='Print structured status.')
    args = parser.parse_args()
    codex_home = args.codex_home.expanduser().resolve()
    cwd = args.cwd.expanduser().resolve()
    report = {
        'client': 'codex',
        'codex_home': str(codex_home),
        'installation': installation(codex_home),
        'mcp': mcp_status(codex_home),
        'obsidian': obsidian_binding(cwd),
    }
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return
    installed = report['installation']
    print(f'Codex Scholar: {installed["status"]} ({codex_home})')
    revision = installed['source_revision']
    source = 'unknown' if revision is None else revision + (' (modified source at install time)' if installed['source_modified'] else '')
    print(f'Installed source revision: {source}')
    for entry in installed['components']:
        label = 'missing' if not entry['present'] else 'installed by Scholar' if entry['managed'] else 'present, no recorded ownership'
        print(f'  {entry["path"]}: {label}')
    for relative in installed['missing_managed_paths']:
        if relative not in COMPONENTS:
            print(f'  {relative}: missing')
    print(f'MCP in user config.toml: {report["mcp"]["status"]}')
    for name, status in (report['mcp']['servers'] or {}).items():
        label = 'not configured' if not status['configured'] else 'enabled' if status['enabled'] else 'disabled'
        print(f'  {name}: {label}')
    print(f'Obsidian: {report["obsidian"]["status"]}')


if __name__ == '__main__':
    sys.dont_write_bytecode = True  # Keep the installed KB helper directory read-only.
    main()
