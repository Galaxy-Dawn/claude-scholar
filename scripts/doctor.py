#!/usr/bin/env python3
"""Report the local Codex Scholar installation and its optional integrations."""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


COMPONENTS = (
    'skills/research-ideation/SKILL.md',
    'skills/results-analysis/SKILL.md',
    'skills/ml-paper-writing/SKILL.md',
    'skills/obsidian-project-kb-core/SKILL.md',
    'skills/obsidian-source-ingestion/SKILL.md',
    'agents/paper-miner.toml',
)
RECEIPT = '.codex-scholar-install-state'
MANIFEST = '.codex-scholar-manifest.txt'


def installation(codex_home: Path) -> dict:
    receipt_file = codex_home / RECEIPT
    manifest_file = codex_home / MANIFEST
    try:
        state = json.loads(receipt_file.read_text(encoding='utf-8'))
        paths = state.get('managedPaths') if isinstance(state, dict) else None
        valid_state = isinstance(paths, list) and all(isinstance(path, str) and path for path in paths)
    except (OSError, ValueError):
        state, paths, valid_state = {}, None, False
    try:
        managed = set(manifest_file.read_text(encoding='utf-8').splitlines())
        valid_manifest = not valid_state or managed == set(paths)
    except (OSError, ValueError):
        managed, valid_manifest = set(), False

    entries = [
        {'path': relative, 'present': (codex_home / relative).is_file(), 'managed': valid_manifest and relative in managed}
        for relative in COMPONENTS
    ]
    if valid_state and valid_manifest:
        status = 'installed' if all(item['present'] for item in entries) else 'incomplete'
    elif receipt_file.exists() or manifest_file.exists():
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
    }


def mcp_status(codex_home: Path, cwd: Path) -> dict:
    if not codex_home.is_dir():
        return {'status': 'codex_home_missing', 'servers': None}
    codex = shutil.which('codex')
    if codex is None:
        return {'status': 'codex_cli_missing', 'servers': None}
    try:
        call = subprocess.run(
            [codex, 'mcp', 'list', '--json'],
            cwd=cwd, env={**os.environ, 'CODEX_HOME': str(codex_home)},
            capture_output=True, text=True, encoding='utf-8', check=True, timeout=15,
        )
        rows = json.loads(call.stdout)
        if not isinstance(rows, list):
            return {'status': 'unavailable', 'servers': None}
    except (OSError, ValueError, subprocess.SubprocessError):
        return {'status': 'unavailable', 'servers': None}

    enabled = {
        row.get('name'): bool(row.get('enabled', True)) for row in rows
        if isinstance(row, dict) and row.get('name') in ('granola', 'zotero')
    }
    return {
        'status': 'configured_servers_read',
        'servers': {name: {'configured': name in enabled, 'enabled': enabled.get(name)}
                    for name in ('zotero', 'granola')},
    }


def obsidian_binding(cwd: Path) -> dict:
    helpers = Path(__file__).resolve().parents[1] / 'skills/obsidian-project-kb-core/scripts'
    if not (helpers / 'kb_common.py').is_file():
        return {'status': 'helper_unavailable'}
    sys.path.insert(0, str(helpers))
    import kb_common as kb

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
        'mcp': mcp_status(codex_home, cwd),
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
    print(f'Local MCP: {report["mcp"]["status"]}')
    for name, status in (report['mcp']['servers'] or {}).items():
        label = 'not configured' if not status['configured'] else 'enabled' if status['enabled'] else 'disabled'
        print(f'  {name}: {label}')
    print(f'Obsidian: {report["obsidian"]["status"]}')


if __name__ == '__main__':
    main()
