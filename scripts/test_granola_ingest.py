#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager
from pathlib import Path


SKILLS = Path(__file__).resolve().parents[1] / 'skills'
KB_HELPER = SKILLS / 'obsidian-project-kb-core/scripts/project_kb.py'
GRANOLA_HELPER = SKILLS / 'granola-meeting-ingest/scripts/ingest_granola.py'
MEETING_ID = 'a5c6d001-fd66-4e9c-b002-010203040506'
SECOND_ID = 'a5c6d001-fd66-4e9c-b002-010203040507'


class GranolaIngestTest(unittest.TestCase):
    def setUp(self) -> None:
        workspace = tempfile.TemporaryDirectory(prefix='scholar-granola-')
        self.addCleanup(workspace.cleanup)
        self.repo = Path(workspace.name) / 'experiment-repo'
        self.vault = Path(workspace.name) / 'Lab vault'
        self.repo.mkdir()
        self.vault.mkdir()
        self.kb('bootstrap', '--vault-path', str(self.vault), '--project-name', 'Granola Demo',
                '--note-language', 'zh-CN')
        self.root = self.vault / 'Research' / 'granola-demo'
        self.note = self.root / 'Sources/Interviews' / f'granola-{MEETING_ID}.md'
        self.registry = self.root / '_system/registry.md'
        self.index = self.root / '02-Index.md'

    def run_cli(self, script: Path, *args: str, stdin: str | None = None, check: bool = True) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, '-B', str(script), *args, '--cwd', str(self.repo)],
            input=stdin, capture_output=True, text=True, encoding='utf-8', check=check,
        )

    def kb(self, action: str, *args: str) -> subprocess.CompletedProcess:
        return self.run_cli(KB_HELPER, action, *args)

    def meeting(self, **updates: object) -> dict:
        return {
            'meeting_id': MEETING_ID,
            'title': '组会 | --- 消融实验',
            'meeting_date': '2026-11-21',
            'source_kind': 'notes-and-transcript',
            'source_url': f'https://notes.granola.ai/d/{MEETING_ID}?temporary=fixture#preview',
            'participants': ['研究员 A', '研究员 B'],
            'summary': ['比较固定切分下的基线和新方法。'],
            'decisions': ['使用现有验证集。'],
            'action_items': [
                {'task': '补跑 baseline', 'owner': '研究员 A', 'due_date': '2026-11-28'},
                {'task': '核对种子列表', 'owner': None, 'due_date': None},
            ],
            'open_questions': ['最终汇报用几次重复实验？'],
            **updates,
        }

    def ingest(self, *, project_id: str | None = None, **updates: object) -> dict:
        selection = ('--project-id', project_id) if project_id is not None else ()
        response = self.run_cli(GRANOLA_HELPER, '--input', '-', *selection, stdin=json.dumps(self.meeting(**updates)))
        return json.loads(response.stdout)

    def test_import_writes_note_registry_and_index(self) -> None:
        # Exercise the file input as well as the stdin route used by the skill.
        payload = self.repo / 'meeting-summary.json'
        payload.write_text(json.dumps(self.meeting(), ensure_ascii=False), encoding='utf-8')
        result = json.loads(self.run_cli(GRANOLA_HELPER, '--input', str(payload)).stdout)
        self.assertEqual(result, {
            'status': 'created', 'project_id': 'granola-demo', 'note': self.note.relative_to(self.root).as_posix(),
        })
        note = self.note.read_text(encoding='utf-8')
        self.assertIn(f'granola_meeting_id: {MEETING_ID}', note)
        self.assertIn(f'https://notes.granola.ai/d/{MEETING_ID}', note)
        self.assertNotIn('temporary=fixture', note)
        self.assertNotIn('#preview', note)
        self.assertIn('## 已定事项\n\n- 使用现有验证集。', note)
        self.assertIn('- [ ] 补跑 baseline (研究员 A, 2026-11-28)', note)
        self.assertIn('- [ ] 核对种子列表 (负责人未定, 未设期限)', note)
        self.assertIn('## 未决问题', note)
        registry = self.registry.read_text(encoding='utf-8')
        self.assertIn('组会 ｜ --- 消融实验', registry)
        self.assertIn('| Granola |', registry)
        self.assertIn(f'[[Sources/Interviews/{self.note.stem}]]', self.index.read_text(encoding='utf-8'))
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 1)

    def test_documented_json_generates_the_documented_english_note(self) -> None:
        guide = SKILLS / 'granola-meeting-ingest/references/GRANOLA-MEETING-NOTES.md'
        examples = dict(re.findall(r'^```(json|markdown)\n(.*?)^```$', guide.read_text(encoding='utf-8'),
                                   flags=re.MULTILINE | re.DOTALL))
        binding = json.loads(self.kb('bootstrap', '--vault-path', str(self.vault),
                                     '--project-name', 'Guide example', '--note-language', 'en').stdout)
        result = json.loads(self.run_cli(GRANOLA_HELPER, '--project-id', binding['project_id'],
                                         '--input', '-', stdin=examples['json']).stdout)
        self.assertEqual(result['status'], 'created')
        expected_name = 'granola-' + json.loads(examples['json'])['meeting_id'] + '.md'
        self.assertEqual(result['note'], 'Sources/Interviews/' + expected_name)
        saved = Path(binding['project_root']) / result['note']
        self.assertEqual(saved.read_text(encoding='utf-8'), examples['markdown'])

    def test_retry_preserves_edits_and_repairs_registry(self) -> None:
        title = 'Pilot "A" \\ branch'
        self.ingest(title=title)
        self.assertIn(f'| {title} |', self.registry.read_text(encoding='utf-8'))
        manually_edited = self.note.read_text(encoding='utf-8') + '\n后续由研究员补充。'
        self.note.write_text(manually_edited, encoding='utf-8')
        self.assertEqual(self.ingest(title='Granola 上的重命名')['status'], 'existing')
        self.assertIn(f'| {title} |', self.registry.read_text(encoding='utf-8'))
        self.registry.unlink()
        result = self.ingest(title='Granola 上的重命名')
        self.assertEqual(result['status'], 'existing')
        self.assertEqual(self.note.read_text(encoding='utf-8'), manually_edited)
        self.assertIn(f'| {title} |', self.registry.read_text(encoding='utf-8'))
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 1)

    def test_retry_restores_paper_and_canvas_links_when_registry_is_missing_or_empty(self) -> None:
        paper = self.root / 'Sources/Papers/existing-paper.md'
        canvas = self.root / 'Maps/literature.canvas'
        paper.write_text('# Existing research paper\n', encoding='utf-8')
        canvas.write_text('{"nodes": [], "edges": []}\n', encoding='utf-8')
        self.kb('sync')
        self.ingest()
        before = {path: path.read_bytes() for path in (paper, canvas, self.note)}
        links = (
            '[[Sources/Papers/existing-paper]]', '[[Maps/literature.canvas]]',
            f'[[Sources/Interviews/{self.note.stem}]]',
        )
        for missing in (True, False):
            with self.subTest(registry='missing' if missing else 'empty'):
                if missing:
                    self.registry.unlink()
                else:
                    self.registry.write_bytes(b'')
                self.assertEqual(self.ingest()['status'], 'existing')
                self.assertEqual({path: path.read_bytes() for path in before}, before)
                registry = self.registry.read_text(encoding='utf-8')
                index = self.index.read_text(encoding='utf-8')
                for link in links:
                    self.assertIn(link, registry)
                    self.assertIn(link, index)

    def test_retry_validates_the_saved_title_before_updating_derived_files(self) -> None:
        self.ingest(title='Fixture original')
        original = self.note.read_text(encoding='utf-8')
        self.ingest(meeting_id=SECOND_ID, title='Another meeting')
        for edited_title, normalized in (
            ('Pilot "A" \\ branch\nRetrospective', 'Pilot "A" \\ branch Retrospective'),
            ('A lone surrogate: \ud800', None),
        ):
            with self.subTest(edited_title=edited_title):
                edited = original.replace('title: "Fixture original"', f'title: {json.dumps(edited_title)}', 1)
                self.note.write_text(edited, encoding='utf-8')
                note_before = self.note.read_bytes()
                registry_before = self.registry.read_bytes()
                index_before = self.index.read_bytes()
                if normalized is None:
                    retry = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(self.meeting()), check=False)
                    self.assertNotEqual(retry.returncode, 0)
                    self.assertIn('existing note title must be valid UTF-8', retry.stderr)
                    self.assertEqual(self.registry.read_bytes(), registry_before)
                    self.assertEqual(self.index.read_bytes(), index_before)
                else:
                    self.assertEqual(self.ingest()['status'], 'existing')
                    self.assertIn(f'| {normalized} |', self.registry.read_text(encoding='utf-8'))
                self.assertEqual(self.note.read_bytes(), note_before)
                self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 2)
                index = self.index.read_text(encoding='utf-8')
                for meeting_id in (MEETING_ID, SECOND_ID):
                    self.assertIn(f'[[Sources/Interviews/granola-{meeting_id}]]', index)

    def test_renamed_and_archived_notes_remain_unique(self) -> None:
        title = 'Discussion of the evaluation split'
        self.ingest(title=title)
        original = self.note.relative_to(self.root).as_posix()
        renamed = 'Sources/Interviews/group-meeting.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', original, '--dest', renamed)
        self.kb('sync')
        row = next(row for row in self.registry.read_text(encoding='utf-8').splitlines()
                   if '[[Sources/Interviews/group-meeting]]' in row)
        self.assertIn(f'| {title} |', row)
        self.assertIn('| Granola |', row)
        self.assertEqual(self.ingest()['note'], renamed)
        moved = 'Sources/Notes/discussions/group-meeting.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', renamed, '--dest', moved)
        retry = self.ingest()
        self.assertEqual(retry['status'], 'existing')
        self.assertEqual(retry['note'], moved)
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 1)
        self.kb('note-lifecycle', '--mode', 'archive', '--note', moved)
        archived = self.ingest()
        self.assertEqual(archived['status'], 'archived')
        self.assertEqual(archived['note'], f'Archive/{moved}')
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 0)
        self.assertFalse(self.note.exists())

    def test_cross_category_move_and_archive_keep_the_same_meeting(self) -> None:
        self.ingest(title='Fixture research discussion')
        original = self.note.relative_to(self.root).as_posix()
        note_bytes = self.note.read_bytes()
        moved = 'Knowledge/discussions/team-review.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', original, '--dest', moved)
        private = self.root / 'Private'
        private.mkdir()
        (private / 'synthetic-copy.md').write_bytes(note_bytes)
        (self.root / 'README.md').write_bytes(note_bytes)
        retry = self.ingest()
        self.assertEqual((retry['status'], retry['note']), ('existing', moved))
        self.assertEqual((self.root / moved).read_bytes(), note_bytes)
        self.assertIn('[[Knowledge/discussions/team-review]]', self.index.read_text(encoding='utf-8'))

        self.kb('note-lifecycle', '--mode', 'archive', '--note', moved)
        archived = self.ingest()
        self.assertEqual((archived['status'], archived['note']), ('archived', f'Archive/{moved}'))
        self.assertEqual((self.root / archived['note']).read_bytes(), note_bytes)
        self.assertFalse(self.note.exists())

    def test_manually_renamed_note_accepts_quoted_frontmatter(self) -> None:
        self.ingest(title='Original fixture')
        original = self.note.read_text(encoding='utf-8')
        renamed = self.root / 'Sources/Interviews/manually-renamed.md'
        self.note.rename(renamed)
        for uuid_value, provider, title_value, title in (
            (f"'{MEETING_ID.upper()}'", "'granola'", "'Researcher''s check' # comment", "Researcher's check"),
            (json.dumps(MEETING_ID).replace('-', r'\x2d'), r'"\x67ranola"',
             r'"Second\x3a \"Demo\""', 'Second: "Demo"'),
        ):
            with self.subTest(uuid_value=uuid_value):
                text = original.replace(f'granola_meeting_id: {MEETING_ID}', f'granola_meeting_id: {uuid_value}')
                text = text.replace('source_provider: granola', f'source_provider: {provider}')
                text = text.replace('title: "Original fixture"', f'title: {title_value}')
                renamed.write_text(text + '\nA manual edit.\n', encoding='utf-8')
                before = renamed.read_bytes()
                self.kb('sync')
                result = self.ingest(title='New upstream title')
                self.assertEqual((result['status'], result['note']), ('existing', 'Sources/Interviews/manually-renamed.md'))
                self.assertEqual(renamed.read_bytes(), before)
                self.assertFalse(self.note.exists())
                row = next(row for row in self.registry.read_text(encoding='utf-8').splitlines()
                           if '[[Sources/Interviews/manually-renamed]]' in row)
                self.assertIn(f'| {title} |', row)
                self.assertIn('| Granola |', row)

    def test_indented_frontmatter_preserves_root_fields_and_ignores_nested_keys(self) -> None:
        self.ingest()
        title = 'Reviewer\'s "Lab Notes"'
        edited = '\n'.join([
            '---', '# Unindented comment before the mapping.', '',
            '  type: source-interview',
            '  source_provider: "granola"',
            f"  granola_meeting_id: '{MEETING_ID}'",
            """  title: 'Reviewer''s "Lab Notes"'""",
            '  details:',
            f'    granola_meeting_id: {SECOND_ID}',
            '    source_provider: nested',
            '    title: Nested title',
            '---', '', 'User-authored note body.', '',
        ])
        self.note.write_text(edited, encoding='utf-8')
        before = self.note.read_bytes()
        decoy = self.note.parent / 'nested-metadata.md'
        decoy.write_text(
            f'---\n  details:\n    source_provider: granola\n    granola_meeting_id: {MEETING_ID}\n---\n',
            encoding='utf-8',
        )

        result = self.ingest(title='Remote title')
        self.assertEqual((result['status'], result['note']), ('existing', self.note.relative_to(self.root).as_posix()))
        self.assertEqual(self.note.read_bytes(), before)
        self.registry.unlink()
        self.kb('sync')
        row = next(row for row in self.registry.read_text(encoding='utf-8').splitlines() if MEETING_ID in row)
        self.assertIn(f'| {title} |', row)
        self.assertIn('| Granola |', row)

    def test_rebuilding_registry_recovers_all_meeting_titles_and_origins(self) -> None:
        titles = {MEETING_ID: 'Fixture Atlas review', SECOND_ID: 'Fixture seminar'}
        for meeting_id, title in titles.items():
            self.ingest(meeting_id=meeting_id, title=title)
        for action in ('sync', 'import'):
            with self.subTest(action=action):
                self.registry.write_bytes(b'')
                if action == 'sync':
                    self.kb('sync')
                else:
                    self.assertEqual(self.ingest()['status'], 'existing')
                rows = self.registry.read_text(encoding='utf-8').splitlines()
                for meeting_id, title in titles.items():
                    row = next(row for row in rows if meeting_id in row)
                    self.assertIn(f'| {title} |', row)
                    self.assertIn('| Granola |', row)

    def test_retry_registers_a_note_in_a_custom_sources_subfolder(self) -> None:
        self.ingest(title='Custom folder meeting')
        moved = 'Sources/Meetings/team-review.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', self.note.relative_to(self.root).as_posix(), '--dest', moved)
        self.registry.unlink()
        result = self.ingest()
        self.assertEqual((result['status'], result['note']), ('existing', moved))
        link = '[[Sources/Meetings/team-review]]'
        self.assertIn(link, self.index.read_text(encoding='utf-8'))
        row = next(row for row in self.registry.read_text(encoding='utf-8').splitlines() if link in row)
        self.assertIn('| interview | Custom folder meeting |', row)
        self.assertIn('| Granola |', row)

    def test_concurrent_imports_keep_both_meetings_and_deduplicate(self) -> None:
        with ThreadPoolExecutor(max_workers=3) as executor:
            results = list(executor.map(lambda uid: self.ingest(meeting_id=uid),
                                        [MEETING_ID, MEETING_ID, SECOND_ID]))
        self.assertCountEqual([item['status'] for item in results], ['created', 'existing', 'created'])
        self.assertEqual(len(list(self.note.parent.glob('*.md'))), 2)
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 2)

    def test_concurrent_sync_and_import_preserve_registry_and_index(self) -> None:
        paper = self.root / 'Sources/Papers/fixture.md'
        paper.write_text('# Fixture paper\n', encoding='utf-8')
        meeting_file = self.repo / 'fixture-meeting.json'
        meeting_file.write_text(json.dumps(self.meeting()), encoding='utf-8')
        pause_sync = """
import sys
from pathlib import Path

script, cwd = sys.argv[1:]
sys.path.insert(0, str(Path(script).parent))
import project_kb

scan = project_kb.common.scan_canonical_relpaths

def pause_after_scan(root):
    snapshot = scan(root)
    print('snapshot', flush=True)
    if sys.stdin.readline().strip() != 'resume':
        raise SystemExit('sync was not released')
    return snapshot

project_kb.common.scan_canonical_relpaths = pause_after_scan
sys.argv = [script, 'sync', '--cwd', cwd]
project_kb.main()
"""
        notify_import = """
import sys
from pathlib import Path

script, cwd, meeting = sys.argv[1:]
sys.path.insert(0, str(Path(script).parent))
import ingest_granola

ingest = ingest_granola.ingest_meeting

def report_started(binding, payload):
    print('importing', flush=True)
    return ingest(binding, payload)

ingest_granola.ingest_meeting = report_started
sys.argv = [script, '--cwd', cwd, '--input', meeting]
ingest_granola.main()
"""

        @contextmanager
        def worker(code: str, script: Path, *args: Path):
            command = [sys.executable, '-B', '-c', code, str(script), str(self.repo), *map(str, args)]
            with subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE, text=True, encoding='utf-8') as process:
                try:
                    yield process
                finally:
                    if process.poll() is None:
                        process.kill()

        with worker(pause_sync, KB_HELPER) as syncing:
            self.assertEqual(syncing.stdout.readline().strip(), 'snapshot')
            with worker(notify_import, GRANOLA_HELPER, meeting_file) as importing:
                try:
                    self.assertEqual(importing.stdout.readline().strip(), 'importing')
                    with self.assertRaises(subprocess.TimeoutExpired):
                        importing.wait(timeout=0.5)
                finally:
                    _, sync_error = syncing.communicate(input='resume\n', timeout=10)
                import_output, import_error = importing.communicate(timeout=10)
                self.assertEqual(syncing.returncode, 0, sync_error)
                self.assertEqual(importing.returncode, 0, import_error)
                self.assertEqual(json.loads(import_output)['status'], 'created')

        self.assertTrue(self.note.is_file())
        registry = self.registry.read_text(encoding='utf-8')
        index = self.index.read_text(encoding='utf-8')
        for link in ('[[Sources/Papers/fixture]]', f'[[Sources/Interviews/{self.note.stem}]]'):
            self.assertIn(link, registry)
            self.assertIn(link, index)

    def test_invalid_input_rejects_writes(self) -> None:
        for override in (
            {'meeting_id': 'invalid'},
            {'source_kind': 'guessed'},
            {'summary': []},
            {'source_url': 'https://example.org/d/meeting'},
            {'action_items': [{'task': 'Continue', 'due_date': '2026-02-30'}]},
        ):
            with self.subTest(override=override):
                failed = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(self.meeting(**override)), check=False)
                self.assertNotEqual(failed.returncode, 0)
                self.assertIn('Granola import failed:', failed.stderr)
                self.assertFalse(self.note.exists())

    def test_invalid_unicode_leaves_note_available_for_retry(self) -> None:
        payload = json.dumps(self.meeting(summary=['A lone surrogate: \ud800']))
        failed = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=payload, check=False)
        self.assertNotEqual(failed.returncode, 0)
        self.assertIn('Granola import failed:', failed.stderr)
        self.assertFalse(self.note.exists())
        self.assertEqual(self.ingest()['status'], 'created')

    def test_import_does_not_overwrite_unrelated_notes(self) -> None:
        self.note.write_text('# Existing note\n', encoding='utf-8')
        failed = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(self.meeting()), check=False)
        self.assertNotEqual(failed.returncode, 0)
        self.assertEqual(self.note.read_text(encoding='utf-8'), '# Existing note\n')

    def test_preview_binding_supports_standard_obsidian_commands(self) -> None:
        standard = self.repo / '.claude/project-memory'
        preview = self.repo / '.codex/project-memory'
        self.assertTrue((standard / 'registry.yaml').is_file())
        self.assertTrue((standard / 'granola-demo.md').is_file())
        preview.parent.mkdir()
        standard.rename(preview)
        registry = preview / 'registry.yaml'
        before = registry.read_bytes()

        self.assertEqual(json.loads(self.kb('detect').stdout)['project']['project_id'], 'granola-demo')
        self.assertEqual(json.loads(self.kb('status').stdout)['project_root'], str(self.root.resolve()))
        self.assertEqual(self.ingest()['status'], 'created')
        self.assertEqual(json.loads(self.kb('sync').stdout)['project_id'], 'granola-demo')
        self.assertIn('scope=auto;', (preview / 'granola-demo.md').read_text(encoding='utf-8'))
        self.assertEqual(registry.read_bytes(), before)
        self.assertFalse(standard.exists())

        self.assertEqual(json.loads(self.kb('lifecycle', '--mode', 'detach').stdout)['status'], 'detached')
        self.assertEqual(json.loads(self.kb('status').stdout)['status'], 'detached')
        self.assertTrue(self.note.is_file())
        self.assertFalse(standard.exists())

    def test_existing_binding_has_priority_and_specific_preview_project_can_be_selected(self) -> None:
        other_project = self.vault / 'Research/another-project'
        other_project.mkdir()
        preview = self.repo / '.codex/project-memory/registry.yaml'
        preview.parent.mkdir(parents=True)
        preview_binding = {'vault_root': str(other_project)}
        preview.write_text(json.dumps({'projects': {
            'another-project': preview_binding, 'granola-demo': preview_binding,
        }}), encoding='utf-8')
        binding = self.repo / '.claude/project-memory/registry.yaml'
        before = {path: path.read_bytes() for path in (binding, preview)}
        self.assertEqual(json.loads(self.kb('detect').stdout)['project']['project_id'], 'granola-demo')
        self.assertEqual(json.loads(self.kb('status').stdout)['project_root'], str(self.root.resolve()))
        self.kb('sync')
        self.assertIn('scope=auto;', binding.with_name('granola-demo.md').read_text(encoding='utf-8'))
        self.assertEqual(self.ingest()['project_id'], 'granola-demo')
        self.assertTrue(self.note.is_file())
        self.assertEqual(self.ingest(project_id='granola-demo')['status'], 'existing')
        self.assertEqual(list(other_project.iterdir()), [])
        selected = self.ingest(project_id='another-project')
        self.assertEqual(selected['project_id'], 'another-project')
        self.assertTrue((other_project / selected['note']).is_file())
        self.assertEqual({path: path.read_bytes() for path in before}, before)

    def test_import_keeps_existing_paper_canvas_and_curated_index(self) -> None:
        paper = self.root / 'Sources/Papers/existing-paper.md'
        canvas = self.root / 'Maps/literature.canvas'
        paper.write_text('# Existing research paper\n', encoding='utf-8')
        canvas.write_text('{"nodes": [], "edges": []}\n', encoding='utf-8')
        self.kb('sync')
        registry = self.registry.read_text(encoding='utf-8')
        self.assertIn('| Existing Paper |', registry)
        title = r'Existing \| Paper \\\| --- Draft'
        registry = registry.replace('| Existing Paper |', f'| {title} |', 1)
        registry = registry.replace('|---|---|---|---|---|---|---|', '|:---|---|---|---|---|---|---:|', 1)
        paper_row = next(row for row in registry.splitlines() if f'| {title} |' in row)
        prefix, updated = paper_row.rsplit(' | paper | ', 1)
        origin = r'Paper library\\'
        registry = registry.replace(paper_row, f'{prefix} | {origin}| {updated}', 1)
        self.registry.write_text(registry, encoding='utf-8')
        curated = 'My curated navigation for the existing project.'
        content = self.index.read_text(encoding='utf-8')
        self.index.write_text(content.replace('## Curated Index\n', f'## Curated Index\n\n{curated}\n', 1), encoding='utf-8')
        before = {path: path.read_bytes() for path in (paper, canvas)}

        self.assertEqual(self.ingest()['status'], 'created')
        self.assertEqual({path: path.read_bytes() for path in before}, before)
        self.assertIn(f'{prefix} | {origin} | {updated}', self.registry.read_text(encoding='utf-8'))
        index = self.index.read_text(encoding='utf-8')
        self.assertIn(curated, index)
        self.assertIn('[[Sources/Papers/existing-paper]]', index)
        self.assertIn('[[Maps/literature.canvas]]', index)
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 2)

    def test_import_preserves_literal_aliased_links_in_both_index_formats(self) -> None:
        paper = self.root / 'Sources/Papers/existing-paper.md'
        paper.write_text('# Existing research paper\n', encoding='utf-8')
        self.kb('sync')
        link = '[[Sources/Papers/existing-paper]]'
        aliased = r'[[Sources/Papers/existing-paper\|Formula \lambda and \1]]'
        registry = self.registry.read_text(encoding='utf-8')
        self.assertIn(link, registry)
        self.registry.write_text(registry.replace(link, aliased, 1), encoding='utf-8')

        marked = self.index.read_text(encoding='utf-8')
        older = '# Index\n\n## Curated Index\n\n- Keep this entry.\n\n## Auto Index\n\n- Stale automatic entry.\n'
        for layout, original, status in (('marked', marked, 'created'), ('older', older, 'existing')):
            with self.subTest(layout=layout):
                self.index.write_text(original, encoding='utf-8')
                self.assertEqual(self.ingest()['status'], status)
                refreshed = self.index.read_text(encoding='utf-8')
                self.assertIn(f'- {aliased}\n', refreshed)
                self.assertIn(f'- [[Sources/Interviews/{self.note.stem}]]\n', refreshed)
                if layout == 'older':
                    self.assertIn('- Keep this entry.\n', refreshed)
                    self.assertNotIn('- Stale automatic entry.\n', refreshed)


if __name__ == '__main__':
    unittest.main(verbosity=2)
