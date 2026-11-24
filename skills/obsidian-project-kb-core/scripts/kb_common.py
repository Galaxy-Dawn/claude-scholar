#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator

IGNORE_DIRS = {
    '.git', '.hg', '.svn', '.venv', 'venv', 'node_modules', '__pycache__',
    '.mypy_cache', '.pytest_cache', '.ruff_cache', '.idea', '.vscode',
    'dist', 'build', 'checkpoints', 'checkpoint', 'cache', '.cache',
    'temp', 'tmp', '.tmp'
}

SECTION_COLUMNS: dict[str, list[str]] = {
    'Sources': ['ID', 'Type', 'Title', 'Path', 'Status', 'Origin', 'Updated'],
    'Knowledge': ['ID', 'Type', 'Title', 'Path', 'Status', 'Sources', 'Updated'],
    'Experiments': ['ID', 'Title', 'Path', 'Status', 'Related Results', 'Updated'],
    'Results': ['ID', 'Title', 'Path', 'Status', 'Related Experiment', 'Sources', 'Updated'],
    'Writing': ['ID', 'Title', 'Path', 'Status', 'Related Notes', 'Updated'],
    'Maps': ['ID', 'Title', 'Path', 'Status', 'Type', 'Updated'],
    'Archive': ['ID', 'Title', 'Old Path', 'Archived Path', 'Reason', 'Archived At'],
}
SECTION_ORDER = list(SECTION_COLUMNS)
CANONICAL_DIRECTORIES = ('Sources', 'Knowledge', 'Experiments', 'Results', 'Writing', 'Maps')
SOURCE_TYPES = {
    'Papers': 'paper',
    'Web': 'web',
    'Docs': 'doc',
    'Data': 'data',
    'Interviews': 'interview',
    'Notes': 'note',
}
NOTE_KIND_TO_FOLDER = {
    'source': 'Sources',
    'paper': 'Sources/Papers',
    'knowledge': 'Knowledge',
    'experiment': 'Experiments',
    'result': 'Results',
    'report': 'Results/Reports',
    'writing': 'Writing',
    'daily': 'Daily',
    'map': 'Maps',
}

AUTO_INDEX_BEGIN = '<!-- BEGIN AUTO INDEX -->'
AUTO_INDEX_END = '<!-- END AUTO INDEX -->'


@dataclass(frozen=True)
class Binding:
    project_id: str
    project_slug: str
    repo_root: Path
    vault_name: str
    vault_path: Path
    project_root: Path
    hub_note: str
    status: str
    auto_sync: bool
    note_language: str


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def today_str() -> str:
    return datetime.now().strftime('%Y-%m-%d')


def slugify(value: str) -> str:
    slug = re.sub(r'[^A-Za-z0-9]+', '-', value).strip('-').lower()
    return slug or 'research-project'


def titleize_slug(slug: str) -> str:
    return ' '.join(part.capitalize() for part in slug.split('-'))


def normalize_note_token(value: str) -> str:
    return re.sub(r'[^a-z0-9]+', '-', value.lower()).strip('-')


def token_set(value: str) -> set[str]:
    return {token for token in re.split(r'[^a-z0-9]+', value.lower()) if token}


def find_repo_root(cwd: Path) -> Path:
    try:
        output = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], cwd=str(cwd), stderr=subprocess.DEVNULL)
        return Path(output.decode().strip())
    except Exception:
        cur = cwd.resolve()
        for candidate in [cur, *cur.parents]:
            if (candidate / '.git').exists():
                return candidate
        return cur


def binding_registry_path(repo_root: Path) -> Path:
    return repo_root / '.opencode' / 'project-memory' / 'registry.yaml'


def registered_projects(repo_root: Path) -> dict[str, tuple[Path, dict[str, Any]]]:
    paths = (binding_registry_path(repo_root),
             repo_root / '.claude' / 'project-memory' / 'registry.yaml')
    projects = {}
    for registry in paths:
        for project_id, entry in (load_binding_registry(registry).get('projects') or {}).items():
            projects.setdefault(project_id, (registry, entry))
    return projects


def project_memory_path(repo_root: Path, project_id: str) -> Path:
    project = registered_projects(repo_root).get(project_id)
    registry = project[0] if project else binding_registry_path(repo_root)
    return registry.with_name(f'{project_id}.md')


def load_binding_registry(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {'projects': {}}
    raw = path.read_text(encoding='utf-8').strip()
    if not raw:
        return {'projects': {}}
    if raw.startswith('{'):
        data = json.loads(raw)
        if 'projects' not in data:
            data = {'projects': {}}
        return data
    try:
        import yaml  # type: ignore
        data = yaml.safe_load(raw) or {}
        if 'projects' not in data:
            data = {'projects': {}}
        return data
    except Exception:
        raise SystemExit(f'Unsupported binding registry format: {path}')


def save_binding_registry(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        import yaml  # type: ignore
        path.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=True), encoding='utf-8')
    except Exception:
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def read_text(path: Path, default: str = '') -> str:
    if not path.exists():
        return default
    return path.read_text(encoding='utf-8')


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')


@contextmanager
def project_write_lock(project_root: Path) -> Iterator[None]:
    root = project_root.resolve()
    lock_path = root / '_system' / '.kb-write.lock'
    if not lock_path.resolve().is_relative_to(root):
        raise ValueError('the write lock must stay inside the bound Obsidian project')
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    with lock_path.open('a+b') as lock:
        lock.seek(0)
        if os.name == 'nt':
            import msvcrt
            msvcrt.locking(lock.fileno(), msvcrt.LK_LOCK, 1)
        else:
            import fcntl
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        yield


def relative_note_path(target: Path, vault_path: Path) -> str:
    return str(target.relative_to(vault_path)).replace(os.sep, '/')


def wikilink(rel_path: str) -> str:
    rel = rel_path.replace('\\', '/').strip()
    if rel.endswith('.md'):
        rel = rel[:-3]
    return f'[[{rel}]]'


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith('---\n'):
        return {}
    try:
        _, block, _ = text.split('---\n', 2)
    except ValueError:
        return {}
    data: dict[str, str] = {}
    for line in block.splitlines():
        if ':' not in line or line.strip().startswith('- '):
            continue
        key, value = line.split(':', 1)
        data[key.strip()] = value.strip().strip('"')
    return data


# Escape sequences supported by YAML double-quoted scalars beyond JSON.
_YAML_JSON_ESCAPES = {
    '0': r'\u0000', 'a': r'\u0007', 'v': r'\u000b', 'e': r'\u001b',
    ' ': r'\u0020', '\t': r'\t', 'N': r'\u0085', '_': r'\u00a0',
    'L': r'\u2028', 'P': r'\u2029',
}


def _yaml_escape_as_json(match: re.Match[str]) -> str:
    escape = match[1]
    if len(escape) > 1:
        return json.dumps(chr(int(escape[1:], 16)))[1:-1]
    return _YAML_JSON_ESCAPES.get(escape, match[0])


def _frontmatter_scalar(value: str) -> str | None:
    if value.startswith("'"):
        quoted = re.fullmatch(r"'((?:[^']|'')*)'(?:[ \t]+#.*)?", value)
        return quoted[1].replace("''", "'") if quoted else None
    if value.startswith('"'):
        quoted = re.fullmatch(r'("(?:[^"\\]|\\.)*")(?:[ \t]+#.*)?', value)
        if quoted is None:
            return None
        try:
            return json.loads(re.sub(r'\\(x[0-9a-fA-F]{2}|U[0-9a-fA-F]{8}|.)', _yaml_escape_as_json, quoted[1]))
        except ValueError:
            return None
    return re.split(r'[ \t]+#', value, maxsplit=1)[0].rstrip()


def read_frontmatter_fields(path: Path, *fields: str) -> dict[str, str]:
    """Read selected top-level, single-line scalars without reading the note body."""
    names = {field.encode('utf-8'): field for field in fields}
    values: dict[str, str] = {}
    root_indent = None
    with path.open('rb') as stream:
        # The longest valid opener is a UTF-8 BOM followed by "---\r\n".
        if stream.readline(8).removeprefix(b'\xef\xbb\xbf').rstrip(b'\r\n') != b'---':
            return {}
        for line in stream:
            if line.rstrip(b'\r\n') in {b'---', b'...'}:
                return values
            content = line.lstrip(b' ')
            if not content.strip() or content.startswith(b'#'):
                continue
            indent = len(line) - len(content)
            if root_indent is None:
                root_indent = indent
            if indent != root_indent:
                continue
            raw_name, separator, raw_value = content.partition(b':')
            field = names.get(raw_name.rstrip())
            if separator and field:
                try:
                    value = _frontmatter_scalar(raw_value.decode('utf-8').strip())
                except UnicodeDecodeError:
                    continue
                if value is not None:
                    values[field] = value
    return {}


def set_frontmatter_value(text: str, key: str, value: str) -> str:
    value_text = str(value)
    if not text.startswith('---\n'):
        return f'---\n{key}: {value_text}\n---\n\n{text}'.rstrip() + '\n'
    try:
        _start, block, rest = text.split('---\n', 2)
    except ValueError:
        return text
    lines = block.splitlines()
    replaced = False
    out: list[str] = []
    for line in lines:
        if line.startswith(f'{key}:'):
            out.append(f'{key}: {value_text}')
            replaced = True
        else:
            out.append(line)
    if not replaced:
        out.append(f'{key}: {value_text}')
    return '---\n' + '\n'.join(out) + '\n---\n' + rest.lstrip('\n')


def project_root_for(vault_path: Path, project_slug: str) -> Path:
    return vault_path / 'Research' / project_slug


def resolve_binding(repo_root: Path, project_id: str | None = None) -> Binding:
    projects = registered_projects(repo_root)
    if not projects:
        raise SystemExit('No registered projects found in .opencode/project-memory/registry.yaml')
    if project_id is None:
        if len(projects) == 1:
            project_id = next(iter(projects))
        else:
            detected = detect(repo_root)
            project = detected.get('project') or {}
            project_id = project.get('project_id')
            if not project_id:
                raise SystemExit('Multiple projects registered; pass --project-id')
    project = projects.get(project_id)
    if not project:
        raise SystemExit(f'Project {project_id!r} not found in binding registry')
    _, entry = project
    project_root = Path(entry['vault_root']).expanduser().resolve()
    vault_path = project_root.parent.parent
    return Binding(
        project_id=entry.get('project_id', project_id),
        project_slug=entry.get('project_slug', project_root.name),
        repo_root=repo_root,
        vault_name=entry.get('vault_name', vault_path.name),
        vault_path=vault_path,
        project_root=project_root,
        hub_note=entry.get('hub_note', relative_note_path(project_root / '00-Hub.md', vault_path)),
        status=entry.get('status', 'active'),
        auto_sync=bool(entry.get('auto_sync', True)),
        note_language=entry.get('note_language', 'en'),
    )


def detect_project_features(repo_root: Path) -> dict[str, Any]:
    feature_checks = {
        '.git': (repo_root / '.git').exists(),
        'README.md': (repo_root / 'README.md').exists(),
        'docs/*.md': (repo_root / 'docs').exists(),
        'notes/*.md': (repo_root / 'notes').exists(),
        'plan/': (repo_root / 'plan').exists(),
        'results/': (repo_root / 'results').exists(),
        'outputs/': (repo_root / 'outputs').exists(),
        'src/': (repo_root / 'src').exists(),
        'scripts/': (repo_root / 'scripts').exists(),
    }
    config_hits = []
    for name in ['pyproject.toml', 'requirements.txt', 'environment.yml', 'configs', 'conf', 'Makefile']:
        if (repo_root / name).exists():
            config_hits.append(name)
    score = sum(1 for value in feature_checks.values() if value) + min(len(config_hits), 2)
    return {
        'score': score,
        'matched': [name for name, value in feature_checks.items() if value],
        'config_hits': config_hits,
        'is_candidate': score >= 3,
    }


def detect(repo_root: Path) -> dict[str, Any]:
    features = detect_project_features(repo_root)
    project = None
    for project_id, (_, entry) in registered_projects(repo_root).items():
        roots = [Path(item).expanduser().resolve() for item in entry.get('repo_roots') or []]
        if repo_root.resolve() in roots:
            project = {
                'project_id': project_id,
                'project_slug': entry.get('project_slug', project_id),
                'vault_root': entry.get('vault_root', ''),
                'status': entry.get('status', 'active'),
                'auto_sync': bool(entry.get('auto_sync', True)),
                'note_language': entry.get('note_language', 'en'),
            }
            break
    return {
        'repo_root': str(repo_root),
        'features': features,
        'project': project,
        'should_bootstrap': bool(features['is_candidate'] and project is None),
    }


def template_root() -> Path:
    return Path(__file__).resolve().parents[3] / 'templates'


def render_template(rel_path: str, context: dict[str, str]) -> str:
    template = (template_root() / rel_path).read_text(encoding='utf-8')
    for key, value in context.items():
        template = template.replace('{{' + key + '}}', value)
    return template


def scaffold_context(project_slug: str, project_title: str) -> dict[str, str]:
    ts = now_iso()
    return {
        'project_slug': project_slug,
        'project_title': project_title,
        'timestamp': ts,
        'today': today_str(),
        'title': 'Untitled',
    }


def ensure_file_from_template(path: Path, template_rel: str, context: dict[str, str], force: bool = False) -> None:
    if path.exists() and not force:
        return
    write_text(path, render_template(template_rel, context))


def ensure_project_scaffold(project_root: Path, project_slug: str, project_title: str, force: bool = False) -> None:
    for rel in [
        'Sources/Papers', 'Sources/Web', 'Sources/Docs', 'Sources/Data', 'Sources/Interviews', 'Sources/Notes',
        'Knowledge', 'Experiments', 'Results/Reports', 'Writing', 'Daily', 'Maps', 'Archive', '_system'
    ]:
        (project_root / rel).mkdir(parents=True, exist_ok=True)
    context = scaffold_context(project_slug, project_title)
    ensure_file_from_template(project_root / '00-Hub.md', 'project/00-Hub.md', context, force=force)
    ensure_file_from_template(project_root / '01-Plan.md', 'project/01-Plan.md', context, force=force)
    ensure_file_from_template(project_root / '02-Index.md', 'project/02-Index.md', context, force=force)
    ensure_file_from_template(project_root / 'Daily' / f'{today_str()}.md', 'notes/daily.md', context, force=False)
    ensure_file_from_template(project_root / '_system' / 'registry.md', 'project/_system/registry.md', context, force=force)
    ensure_file_from_template(project_root / '_system' / 'schema.md', 'project/_system/schema.md', context, force=force)
    ensure_file_from_template(project_root / '_system' / 'lint-report.md', 'project/_system/lint-report.md', context, force=force)


def maybe_migrate_old_layout(project_root: Path) -> list[dict[str, str]]:
    migrated: list[dict[str, str]] = []
    old_papers = project_root / 'Papers'
    new_papers = project_root / 'Sources' / 'Papers'
    if old_papers.exists():
        new_papers.parent.mkdir(parents=True, exist_ok=True)
        if new_papers.exists():
            for path in sorted(old_papers.glob('*.md')):
                target = new_papers / path.name
                if not target.exists():
                    shutil.move(str(path), str(target))
                    migrated.append({'from': str(path), 'to': str(target)})
            if old_papers.is_dir() and not any(old_papers.iterdir()):
                old_papers.rmdir()
        else:
            shutil.move(str(old_papers), str(new_papers))
            migrated.append({'from': str(old_papers), 'to': str(new_papers)})
    return migrated


def bootstrap_binding(repo_root: Path, vault_path: Path, project_name: str | None = None, force: bool = False, note_language: str = 'en') -> dict[str, Any]:
    project_slug = slugify(project_name or repo_root.name)
    project_title = project_name or titleize_slug(project_slug)
    vault_path = vault_path.expanduser().resolve()
    project_root = project_root_for(vault_path, project_slug)
    project_root.mkdir(parents=True, exist_ok=True)
    ensure_project_scaffold(project_root, project_slug, project_title, force=force)
    migrated = maybe_migrate_old_layout(project_root)

    reg_path = binding_registry_path(repo_root)
    previous_memory = project_memory_path(repo_root, project_slug)
    registry = load_binding_registry(reg_path)
    registry.setdefault('projects', {})
    registry['projects'][project_slug] = {
        'project_id': project_slug,
        'project_slug': project_slug,
        'repo_roots': [str(repo_root.resolve())],
        'vault_name': os.environ.get('OBSIDIAN_VAULT_NAME', vault_path.name),
        'vault_root': str(project_root),
        'hub_note': relative_note_path(project_root / '00-Hub.md', vault_path),
        'status': 'active',
        'auto_sync': True,
        'note_language': note_language,
        'updated_at': now_iso(),
    }
    if previous_memory.parent != reg_path.parent:
        legacy = load_binding_registry(previous_memory.with_name(reg_path.name))
        prior_root = (legacy.get('projects') or {}).get(project_slug, {}).get('vault_root')
        if not prior_root or Path(prior_root).expanduser().resolve() != project_root:
            # An identically named project in another vault has its own memory.
            previous_memory = reg_path.with_name(previous_memory.name)
    save_binding_registry(reg_path, registry)

    memory = reg_path.with_name(f'{project_slug}.md')
    content = f'''---
project_id: {project_slug}
project_slug: {project_slug}
repo_root: {repo_root.resolve()}
vault_root: {project_root}
hub_note: {relative_note_path(project_root / '00-Hub.md', vault_path)}
language: {note_language}
last_sync_at: {now_iso()}
status: active
auto_sync: true
---

# Project Memory: {project_slug}

## Current Focus
- TODO

## Active Tasks
- Review project scaffold
- Fill current sources, experiments, and results
- Keep registry and index updated

## Recent Sync Summary
- Bootstrap completed at {now_iso()}.
'''
    if previous_memory != memory and previous_memory.is_file() and not memory.exists():
        shutil.copyfile(previous_memory, memory)
    else:
        write_text(memory, content)
    return {
        'project_id': project_slug,
        'project_slug': project_slug,
        'project_root': str(project_root),
        'memory_path': str(memory),
        'binding_registry': str(reg_path),
        'migrated_paths': migrated,
    }


def registry_path(project_root: Path) -> Path:
    return project_root / '_system' / 'registry.md'


def default_registry_tables() -> dict[str, list[dict[str, str]]]:
    return {section: [] for section in SECTION_ORDER}


def split_table_cells(line: str) -> list[str]:
    line = line.rstrip()
    cells = []
    start = 1  # The caller has checked the opening pipe.
    backslashes = 0
    for index, char in enumerate(line[1:], start=1):
        if char == '|' and backslashes % 2 == 0:
            cells.append(line[start:index].strip())
            start = index + 1
        backslashes = backslashes + 1 if char == '\\' else 0
    if start < len(line):
        cells.append(line[start:].strip())
    return cells


def parse_table_row(line: str, columns: list[str]) -> dict[str, str] | None:
    if not line.startswith('|'):
        return None
    parts = split_table_cells(line)
    if len(parts) != len(columns):
        return None
    if all(re.fullmatch(r':?-{3,}:?', part) for part in parts):
        return None
    return dict(zip(columns, parts))


def parse_registry_md(path: Path) -> dict[str, list[dict[str, str]]]:
    if not path.exists():
        return default_registry_tables()
    content = path.read_text(encoding='utf-8')
    rows = default_registry_tables()
    current_section = None
    columns: list[str] | None = None
    for raw_line in content.splitlines():
        line = raw_line.rstrip()
        if line.startswith('## '):
            section = line[3:].strip()
            current_section = section if section in SECTION_COLUMNS else None
            columns = None
            continue
        if current_section is None or not line.startswith('|'):
            continue
        if columns is None:
            header = split_table_cells(line)
            if header == SECTION_COLUMNS[current_section]:
                columns = header
            continue
        row = parse_table_row(line, columns)
        if not row:
            continue
        if current_section == 'Archive':
            if row.get('Old Path', '') or row.get('Archived Path', ''):
                rows[current_section].append(row)
            continue
        if row.get(columns[0], ''):
            stamp, marker, key = row['Updated'].rpartition(' <!-- source-key: ')
            if marker and re.fullmatch(r'[\w.:-]+ -->', key):
                row['Updated'] = stamp
                row['Source Key'] = key.removesuffix(' -->')
            rows[current_section].append(row)
    return rows


def render_registry_md(rows: dict[str, list[dict[str, str]]], last_updated: str | None = None) -> str:
    lines = ['# Registry', '', f'Last updated: {last_updated or now_iso()}', '']
    for section in SECTION_ORDER:
        columns = SECTION_COLUMNS[section]
        lines.append(f'## {section}')
        lines.append('')
        lines.append('| ' + ' | '.join(columns) + ' |')
        lines.append('|' + '|'.join(['---'] * len(columns)) + '|')
        for row in rows.get(section, []):
            cells = [row.get(col, '') for col in columns]
            if row.get('Source Key'):
                # Keep the visible columns readable by older KB installations.
                cells[columns.index('Updated')] += f" <!-- source-key: {row['Source Key']} -->"
            lines.append('| ' + ' | '.join(cells) + ' |')
        lines.append('')
    return '\n'.join(lines).rstrip() + '\n'


def write_registry(project_root: Path, rows: dict[str, list[dict[str, str]]]) -> None:
    write_text(registry_path(project_root), render_registry_md(rows))


def section_and_row_for_relpath(
    rel_path: str, *, imported_source_type: str | None = None,
) -> tuple[str, dict[str, str]] | None:
    rel = rel_path.replace('\\', '/')
    updated = now_iso()
    title = Path(rel).stem.replace('-', ' ')
    if rel.startswith('Sources/'):
        parts = rel.split('/', 2)
        source_folder = parts[1] if len(parts) >= 2 else ''
        source_type = SOURCE_TYPES.get(source_folder) or imported_source_type
        if not source_type:
            return None
        return 'Sources', {
            'ID': '', 'Type': source_type, 'Title': title.title(), 'Path': wikilink(rel),
            'Status': 'active', 'Origin': source_type, 'Updated': updated,
        }
    if rel.startswith('Knowledge/'):
        return 'Knowledge', {
            'ID': '', 'Type': 'knowledge', 'Title': title.title(), 'Path': wikilink(rel),
            'Status': 'active', 'Sources': '', 'Updated': updated,
        }
    if rel.startswith('Experiments/'):
        return 'Experiments', {
            'ID': '', 'Title': title.title(), 'Path': wikilink(rel), 'Status': 'active',
            'Related Results': '', 'Updated': updated,
        }
    if rel.startswith('Results/'):
        return 'Results', {
            'ID': '', 'Title': title.title(), 'Path': wikilink(rel), 'Status': 'active',
            'Related Experiment': '', 'Sources': '', 'Updated': updated,
        }
    if rel.startswith('Writing/'):
        return 'Writing', {
            'ID': '', 'Title': title.title(), 'Path': wikilink(rel), 'Status': 'draft',
            'Related Notes': '', 'Updated': updated,
        }
    if rel.startswith('Maps/'):
        return 'Maps', {
            'ID': '', 'Title': title.title(), 'Path': wikilink(rel), 'Status': 'active',
            'Type': Path(rel).suffix.lstrip('.') or 'map', 'Updated': updated,
        }
    return None


def next_registry_id(rows: list[dict[str, str]], prefix: str) -> str:
    nums = []
    for row in rows:
        rid = row.get('ID', '')
        if rid.startswith(prefix + '-'):
            try:
                nums.append(int(rid.split('-')[-1]))
            except ValueError:
                pass
    return f'{prefix}-{max(nums, default=0) + 1:03d}'


def prefix_for_section_row(section: str, row: dict[str, str]) -> str:
    if section == 'Sources':
        return row['Type']
    return {
        'Knowledge': 'knowledge',
        'Experiments': 'exp',
        'Results': 'result',
        'Writing': 'writing',
        'Maps': 'map',
        'Archive': 'archive',
    }[section]


def imported_source_metadata(project_root: Path, relative: str) -> dict[str, str]:
    path = project_root / relative
    if path.suffix != '.md' or path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(project_root.resolve()):
        return {}
    try:
        fields = read_frontmatter_fields(path, 'type', 'source_type', 'source_provider', 'title')
    except OSError:
        return {}
    note_type = fields.get('type', '')
    if note_type.startswith('source-'):
        fields['source_type'] = note_type.removeprefix('source-')
    elif note_type != 'source':
        return {}
    if not fields.get('source_type') or not fields.get('source_provider', '').strip():
        return {}
    return fields


def _metadata_cell(value: str) -> str | None:
    value = ' '.join(value.split())
    try:
        value.encode('utf-8')
    except UnicodeEncodeError:
        return None
    return value or None


def registry_add_or_update(
    project_root: Path, rel_path: str, *, status: str | None = None,
    title: str | None = None, origin: str | None = None, source_key: str | None = None,
    previous_link: str | None = None,
) -> dict[str, Any]:
    metadata = None
    payload = section_and_row_for_relpath(rel_path)
    if payload is None and rel_path.replace('\\', '/').startswith('Sources/'):
        metadata = imported_source_metadata(project_root, rel_path)
        source_type = metadata.get('source_type')
        if source_type in SOURCE_TYPES.values():
            payload = section_and_row_for_relpath(rel_path, imported_source_type=source_type)
    if payload is None:
        return {'updated': False, 'reason': 'path-not-registrable'}
    section, row = payload
    rows = parse_registry_md(registry_path(project_root))
    if source_key:
        link = row['Path'].casefold()
        path_rows = [(name, item) for name, entries in rows.items() if name != 'Archive'
                     for item in entries if item['Path'].casefold() == link]
        if len(path_rows) > 1 or any(
            name != section
            or item.get('Source Key') not in (None, source_key)
            or (item.get('Source Key') is None and item['Path'] not in (row['Path'], previous_link))
            for name, item in path_rows
        ):
            return {'updated': False, 'reason': 'path-owned-by-another-source'}
        existing = path_rows[0][1] if path_rows else None
    else:
        existing = next((item for item in rows[section] if item.get('Path') == row['Path']), None)
    if source_key:
        for old_section, entries in rows.items():
            prior = next((item for item in entries if item.get('Source Key') == source_key), None)
            if prior is None and previous_link is not None:
                prior = next((item for item in entries
                              if item.get('Path') == previous_link and not item.get('Source Key')), None)
            if prior is None:
                continue
            if prior is existing:
                break
            if existing is not None:
                if prior.get('Source Key') and not existing.get('Source Key'):
                    return {'updated': False, 'reason': 'path-owned-by-another-source'}
                rows[section].remove(existing)
            if old_section == section:
                existing = prior
            else:
                entries.remove(prior)
                existing = {**row, 'ID': prior['ID'], 'Status': prior['Status']}
                rows[section].append(existing)
            break
    if existing is None:
        active_rows = [item for name, entries in rows.items() if name != 'Archive' for item in entries]
        row['ID'] = next_registry_id(active_rows, prefix_for_section_row(section, row))
        if status:
            row['Status'] = status
        rows[section].append(row)
        if metadata is None:
            metadata = imported_source_metadata(project_root, rel_path)
        if metadata:
            if title is None:
                title = _metadata_cell(metadata.get('title', ''))
            if origin is None:
                provider = _metadata_cell(metadata['source_provider'])
                if provider is not None:
                    origin = provider[0].upper() + provider[1:]
    else:
        existing['Path'] = row['Path']
        existing['Updated'] = row['Updated']
        if status is not None:
            existing['Status'] = status
        row = existing
    if title is not None:
        row['Title'] = title.replace('|', '｜')
    if origin is not None and section == 'Sources':
        row['Origin'] = origin.replace('|', '｜')
    if source_key is not None:
        row['Source Key'] = source_key
    write_registry(project_root, rows)
    return {'updated': True, 'section': section, 'path': rel_path}


def registry_archive(project_root: Path, old_rel: str, archived_rel: str, reason: str = 'archive') -> dict[str, Any]:
    rows = parse_registry_md(registry_path(project_root))
    old_link = wikilink(old_rel)
    removed_row = None
    removed_section = None
    for section in SECTION_ORDER:
        if section == 'Archive':
            continue
        for idx, row in enumerate(list(rows[section])):
            if row.get('Path') == old_link:
                removed_row = row
                removed_section = section
                rows[section].pop(idx)
                break
        if removed_row:
            break
    archive_row = {
        'ID': removed_row.get('ID', '') if removed_row else '',
        'Title': removed_row.get('Title', Path(old_rel).stem.title()) if removed_row else Path(old_rel).stem.title(),
        'Old Path': wikilink(old_rel),
        'Archived Path': wikilink(archived_rel),
        'Reason': reason,
        'Archived At': now_iso(),
    }
    rows['Archive'].append(archive_row)
    write_registry(project_root, rows)
    return {'updated': True, 'section': removed_section or 'Archive'}


def registry_remove_path(project_root: Path, rel_path: str, reason: str = 'purge', *, record_archive: bool = True) -> None:
    rows = parse_registry_md(registry_path(project_root))
    target = wikilink(rel_path)
    removed_row = None
    for section in SECTION_ORDER:
        if section == 'Archive':
            continue
        keep_rows = []
        for row in rows[section]:
            if row.get('Path') == target:
                removed_row = row
                continue
            keep_rows.append(row)
        rows[section] = keep_rows
    if record_archive:
        rows['Archive'].append({
            'ID': removed_row.get('ID', '') if removed_row else '',
            'Title': removed_row.get('Title', Path(rel_path).stem.title()) if removed_row else Path(rel_path).stem.title(),
            'Old Path': wikilink(rel_path),
            'Archived Path': '',
            'Reason': reason,
            'Archived At': now_iso(),
        })
    write_registry(project_root, rows)


def scan_canonical_relpaths(project_root: Path) -> list[str]:
    rels: list[str] = []
    for base in CANONICAL_DIRECTORIES:
        path = project_root / base
        if not path.exists():
            continue
        for child in sorted(path.rglob('*')):
            if child.is_dir():
                continue
            if base == 'Maps' and child.suffix not in {'.canvas', '.md'}:
                continue
            if base != 'Maps' and child.suffix != '.md':
                continue
            rels.append(str(child.relative_to(project_root)).replace(os.sep, '/'))
    return rels


def update_index(project_root: Path) -> None:
    rows = parse_registry_md(registry_path(project_root))
    auto_lines: list[str] = []
    for title, section in [('Sources', 'Sources'), ('Knowledge', 'Knowledge'), ('Experiments', 'Experiments'), ('Results', 'Results'), ('Writing', 'Writing'), ('Maps', 'Maps')]:
        auto_lines.append(f'### {title}')
        active = [row['Path'] for row in rows.get(section, []) if row.get('Status', '') != 'archived']
        if active:
            auto_lines.extend(f'- {item}' for item in active)
        else:
            auto_lines.append('- None yet.')
        auto_lines.append('')

    managed_note = 'Managed block. Refresh with `/kb-sync` or `/kb-index`. Put hand-written navigation in **Curated Index**, not inside the markers below.'
    auto_block = AUTO_INDEX_BEGIN + '\n' + '\n'.join(auto_lines).rstrip() + '\n' + AUTO_INDEX_END
    index_path = project_root / '02-Index.md'
    content = read_text(index_path)

    if not content.strip():
        content = '\n'.join([
            '---',
            'type: project-index',
            f'updated: {now_iso()}',
            '---',
            '',
            '# Index',
            '',
            '## Curated Index',
            '- Add human-maintained entry points here.',
            '',
            '## Auto Index',
            '',
            managed_note,
            auto_block,
            '',
        ]).rstrip() + '\n'
    else:
        content = set_frontmatter_value(content, 'updated', now_iso())
        # Keep link backslashes literal when inserting the generated index text.
        if AUTO_INDEX_BEGIN in content and AUTO_INDEX_END in content:
            content = re.sub(
                rf'{re.escape(AUTO_INDEX_BEGIN)}[\s\S]*?{re.escape(AUTO_INDEX_END)}',
                lambda _: auto_block,
                content,
                count=1,
            )
        else:
            auto_section = '\n'.join([
                '## Auto Index',
                '',
                managed_note,
                auto_block,
                '',
            ]).rstrip() + '\n'
            if re.search(r'(?m)^## Auto Index\s*$', content):
                content = re.sub(
                    r'(?ms)^## Auto Index\s*\n.*?(?=^## |\Z)',
                    lambda _: auto_section,
                    content,
                    count=1,
                ).rstrip() + '\n'
            else:
                content = content.rstrip() + '\n\n' + auto_section

    write_text(index_path, content.rstrip() + '\n')


def ensure_today_daily(project_root: Path, project_slug: str, force: bool = False) -> Path:
    path = project_root / 'Daily' / f'{today_str()}.md'
    if not path.exists() or force:
        context = scaffold_context(project_slug, titleize_slug(project_slug))
        write_text(path, render_template('notes/daily.md', context))
    return path


def prepend_recent_change(project_root: Path, message: str) -> None:
    hub = project_root / '00-Hub.md'
    content = read_text(hub)
    marker = '## Recent Changes\n'
    if marker not in content:
        content = content.rstrip() + f'\n\n{marker}- {message}\n'
    else:
        head, tail = content.split(marker, 1)
        existing_lines = [line for line in tail.splitlines() if line.startswith('- ')]
        merged = [f'- {message}', *[line for line in existing_lines if line != f'- {message}']]
        content = head + marker + '\n'.join(merged[:8]) + '\n'
    write_text(hub, content)


def update_project_memory(repo_root: Path, project_id: str, project_root: Path, hub_note: str, note_language: str, summary: str | None = None) -> None:
    path = project_memory_path(repo_root, project_id)
    content = read_text(path, f'---\nproject_id: {project_id}\nproject_slug: {project_id}\nrepo_root: {repo_root}\nvault_root: {project_root}\nhub_note: {hub_note}\nlanguage: {note_language}\nstatus: active\nauto_sync: true\n---\n\n# Project Memory: {project_id}\n')
    content = set_frontmatter_value(content, 'last_sync_at', now_iso())
    content = set_frontmatter_value(content, 'vault_root', str(project_root))
    content = set_frontmatter_value(content, 'hub_note', hub_note)
    if summary:
        block = f'## Recent Sync Summary\n- {summary}\n'
        if '## Recent Sync Summary\n' in content:
            content = re.sub(r'## Recent Sync Summary\n(?:- .*\n?)*', block, content, count=1)
        else:
            content = content.rstrip() + '\n\n' + block
    write_text(path, content)


def list_kind_notes(project_root: Path, kind: str) -> list[Path]:
    rel = NOTE_KIND_TO_FOLDER.get(kind)
    if not rel:
        return []
    base = project_root / rel
    if not base.exists():
        return []
    suffixes = {'.md'} if kind != 'map' else {'.md', '.canvas'}
    return sorted([p for p in base.rglob('*') if p.is_file() and p.suffix in suffixes])


def project_note_ref(path: Path, project_root: Path) -> str:
    rel = path.relative_to(project_root).as_posix()
    return rel[:-3] if rel.endswith('.md') else rel


def search_note_candidates(project_root: Path, kind: str, query: str, limit: int = 5) -> list[Path]:
    notes = list_kind_notes(project_root, kind)
    if not notes:
        return []
    raw_query = query.strip()
    exact = project_root / raw_query
    if exact.exists():
        return [exact]
    if raw_query.endswith('.md'):
        exact_md = project_root / raw_query
        if exact_md.exists():
            return [exact_md]
    query_norm = normalize_note_token(raw_query[:-3] if raw_query.endswith('.md') else raw_query)
    query_tokens = token_set(raw_query)
    scored: list[tuple[tuple[int, int, int], Path]] = []
    for note in notes:
        ref = project_note_ref(note, project_root)
        ref_norm = normalize_note_token(ref)
        note_norm = normalize_note_token(note.stem)
        score = None
        if ref == raw_query or note.stem == raw_query:
            score = (0, len(ref), len(note.stem))
        elif ref_norm == query_norm or note_norm == query_norm:
            score = (1, len(ref_norm), len(note_norm))
        elif query_norm and query_norm in ref_norm:
            score = (2, len(ref_norm), len(note_norm))
        elif query_tokens & token_set(ref):
            score = (3, -len(query_tokens & token_set(ref)), len(ref_norm))
        if score is not None:
            scored.append((score, note))
    scored.sort(key=lambda item: (item[0], project_note_ref(item[1], project_root)))
    return [item[1] for item in scored[:limit]]


def resolve_project_note(project_root: Path, note: str) -> Path:
    candidate = (project_root / note).resolve()
    if candidate.exists():
        return candidate
    if not note.endswith('.md'):
        candidate_md = (project_root / f'{note}.md').resolve()
        if candidate_md.exists():
            return candidate_md
    raise SystemExit(f'Note not found: {note}')


def replace_wikilinks(content: str, old_rel: str, new_rel: str | None = None) -> str:
    old_variants = {old_rel, old_rel[:-3] if old_rel.endswith('.md') else old_rel}
    new_target = None if new_rel is None else (new_rel[:-3] if new_rel.endswith('.md') else new_rel)

    def repl(match: re.Match[str]) -> str:
        inner = match.group(1)
        target, *rest = inner.split('|', 1)
        target_no_heading = target.split('#', 1)[0]
        if target_no_heading not in old_variants:
            return match.group(0)
        if new_target is None:
            return match.group(0)
        replaced = target.replace(target_no_heading, new_target, 1)
        if rest:
            return f'[[{replaced}|{rest[0]}]]'
        return f'[[{replaced}]]'

    return re.sub(r'\[\[([^\]]+)\]\]', repl, content)
