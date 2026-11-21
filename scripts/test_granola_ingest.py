#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


HELPER = Path(__file__).resolve().parents[1] / 'skills/obsidian-project-kb-core/scripts/project_kb.py'
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

    def kb(self, action: str, *args: str, stdin: str | None = None, check: bool = True) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, '-B', str(HELPER), action, '--cwd', str(self.repo), *args],
            input=stdin, capture_output=True, text=True, encoding='utf-8', check=check,
        )

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

    def ingest(self, **updates: object) -> dict:
        response = self.kb('ingest-granola', '--input', '-', stdin=json.dumps(self.meeting(**updates)))
        return json.loads(response.stdout)

    def test_import_writes_note_registry_and_index(self) -> None:
        # Exercise the file input as well as the stdin route used by the skill.
        payload = self.repo / 'meeting-summary.json'
        payload.write_text(json.dumps(self.meeting(), ensure_ascii=False), encoding='utf-8')
        result = json.loads(self.kb('ingest-granola', '--input', str(payload)).stdout)
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
                    retry = self.kb('ingest-granola', '--input', '-', stdin=json.dumps(self.meeting()), check=False)
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
        self.ingest()
        original = self.note.relative_to(self.root).as_posix()
        renamed = 'Sources/Interviews/group-meeting.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', original, '--dest', renamed)
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

    def test_concurrent_imports_keep_both_meetings_and_deduplicate(self) -> None:
        with ThreadPoolExecutor(max_workers=3) as executor:
            results = list(executor.map(lambda uid: self.ingest(meeting_id=uid),
                                        [MEETING_ID, MEETING_ID, SECOND_ID]))
        self.assertCountEqual([item['status'] for item in results], ['created', 'existing', 'created'])
        self.assertEqual(len(list(self.note.parent.glob('*.md'))), 2)
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 2)

    def test_invalid_input_rejects_writes(self) -> None:
        for override in (
            {'meeting_id': 'invalid'},
            {'source_kind': 'guessed'},
            {'summary': []},
            {'source_url': 'https://example.org/d/meeting'},
            {'action_items': [{'task': 'Continue', 'due_date': '2026-02-30'}]},
        ):
            with self.subTest(override=override):
                failed = self.kb('ingest-granola', '--input', '-', stdin=json.dumps(self.meeting(**override)), check=False)
                self.assertNotEqual(failed.returncode, 0)
                self.assertIn('Granola import failed:', failed.stderr)
                self.assertFalse(self.note.exists())

    def test_invalid_unicode_leaves_note_available_for_retry(self) -> None:
        payload = json.dumps(self.meeting(summary=['A lone surrogate: \ud800']))
        failed = self.kb('ingest-granola', '--input', '-', stdin=payload, check=False)
        self.assertNotEqual(failed.returncode, 0)
        self.assertIn('Granola import failed:', failed.stderr)
        self.assertFalse(self.note.exists())
        self.assertEqual(self.ingest()['status'], 'created')

    def test_import_does_not_overwrite_unrelated_notes(self) -> None:
        self.note.write_text('# Existing note\n', encoding='utf-8')
        failed = self.kb('ingest-granola', '--input', '-', stdin=json.dumps(self.meeting()), check=False)
        self.assertNotEqual(failed.returncode, 0)
        self.assertEqual(self.note.read_text(encoding='utf-8'), '# Existing note\n')

    def test_binding_uses_codex_and_accepts_the_legacy_location(self) -> None:
        binding_file = self.repo / '.codex/project-memory/registry.yaml'
        self.assertTrue(binding_file.is_file())
        self.assertTrue(binding_file.with_name('granola-demo.md').is_file())
        legacy_file = self.repo / '.claude/project-memory/registry.yaml'
        legacy_file.parent.mkdir(parents=True)
        binding_file.rename(legacy_file)
        self.assertEqual(self.ingest()['status'], 'created')
        self.assertFalse(binding_file.exists())


if __name__ == '__main__':
    unittest.main(verbosity=2)
