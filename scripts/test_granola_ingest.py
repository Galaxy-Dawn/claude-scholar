#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager
from datetime import datetime
from pathlib import Path
from unittest.mock import patch
from urllib.parse import parse_qs, urlsplit


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
        binding = json.loads(self.kb('bootstrap', '--vault-path', str(self.vault),
                                     '--project-name', 'Granola Demo', '--note-language', 'zh-CN').stdout)
        self.binding_registry = Path(binding['binding_registry'])
        self.root = self.vault / 'Research' / 'granola-demo'
        self.note = self.root / 'Sources/Interviews/Granola-26-11-21-组会-消融实验.md'
        self.registry = self.root / '_system/registry.md'
        self.index = self.root / '02-Index.md'

    def run_cli(self, script: Path, *args: str, stdin: str | None = None, check: bool = True) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, '-B', str(script), *args, '--cwd', str(self.repo)],
            input=stdin, capture_output=True, text=True, encoding='utf-8', check=check,
        )

    def kb(self, action: str, *args: str) -> subprocess.CompletedProcess:
        return self.run_cli(KB_HELPER, action, *args)

    def place_binding(self, host_directory: str) -> Path:
        directory = self.repo.resolve() / host_directory / 'project-memory'
        if self.binding_registry.parent != directory:
            directory.parent.mkdir(exist_ok=True)
            self.binding_registry.parent.rename(directory)
            self.binding_registry = directory / 'registry.yaml'
        return directory

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

    def ingest(
        self, *, project_id: str | None = None, previous_note: str | None = None, **updates: object,
    ) -> dict:
        args = ['--input', '-']
        if project_id is not None:
            args.extend(('--project-id', project_id))
        if previous_note is not None:
            args.extend(('--previous-note', previous_note))
        response = self.run_cli(GRANOLA_HELPER, *args, stdin=json.dumps(self.meeting(**updates)))
        return json.loads(response.stdout)

    def test_import_writes_note_registry_and_index(self) -> None:
        # Exercise the file input as well as the stdin route used by the skill.
        payload = self.repo / 'meeting-summary.json'
        fixture = self.meeting(
            project_relevance=['帮助复核验证集。'],
            context=['组会上讨论了实验安排。'],
            key_quotes=['研究员 A：“用现有验证集。”'],
            observed_needs=['对齐种子列表。'],
        )
        payload.write_text(json.dumps(fixture, ensure_ascii=False), encoding='utf-8')
        result = json.loads(self.run_cli(GRANOLA_HELPER, '--input', str(payload)).stdout)
        self.assertEqual(result['status'], 'created')
        self.assertEqual(result['project_id'], 'granola-demo')
        self.assertEqual(result['note'], self.note.relative_to(self.root).as_posix())
        self.assertEqual(result['vault_path'], str(self.vault.resolve()))
        self.assertEqual(result['vault_note'], self.note.relative_to(self.vault).as_posix())
        uri = urlsplit(result['obsidian_uri'])
        self.assertEqual((uri.scheme, uri.netloc), ('obsidian', 'open'))
        self.assertEqual(parse_qs(uri.query), {'path': [str(self.note.resolve())]})
        self.assertNotIn(' ', result['obsidian_uri'])
        note = self.note.read_text(encoding='utf-8')
        self.assertIn('type: source\nsource_type: interview\nproject: "granola-demo"\nstatus: active\n', note)
        self.assertIn(f'granola_meeting_id: {MEETING_ID}', note)
        self.assertIn(f'https://notes.granola.ai/d/{MEETING_ID}', note)
        self.assertNotIn('temporary=fixture', note)
        self.assertNotIn('#preview', note)
        self.assertEqual(re.findall(r'^## (.+)$', note, flags=re.MULTILINE), [
            '会议信息', '与项目的关系', '摘要', '参会者', '背景', '关键原话', '观察到的需求', '后续事项',
        ])
        self.assertIn('## 与项目的关系\n\n- 帮助复核验证集。', note)
        self.assertIn('## 背景\n\n- 组会上讨论了实验安排。', note)
        self.assertIn('## 关键原话\n\n- 研究员 A：“用现有验证集。”', note)
        self.assertIn('## 观察到的需求\n\n- 对齐种子列表。', note)
        summary = note.split('## 摘要\n', 1)[1].split('\n## 参会者', 1)[0]
        follow_ups = note.split('## 后续事项\n', 1)[1]
        self.assertIn('- **已定事项** 使用现有验证集。', summary)
        self.assertNotIn('已定事项', follow_ups)
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
        expected_name = 'Granola-26-11-21-Lab-meeting-baseline-experiment.md'
        self.assertEqual(result['note'], 'Sources/Interviews/' + expected_name)
        self.assertIn(f'`{expected_name}`', guide.read_text(encoding='utf-8'))
        saved = Path(binding['project_root']) / result['note']
        note = saved.read_text(encoding='utf-8')
        timestamp_pattern = r'^(created|updated): (.+)$'
        timestamps = dict(re.findall(timestamp_pattern, note, flags=re.MULTILINE))
        self.assertEqual(set(timestamps), {'created', 'updated'})
        self.assertEqual(timestamps['created'], timestamps['updated'])
        self.assertIsNotNone(datetime.fromisoformat(timestamps['created'].replace('Z', '+00:00')).tzinfo)
        self.assertEqual(
            re.sub(timestamp_pattern, r'\1: <timestamp>', note, flags=re.MULTILINE),
            re.sub(timestamp_pattern, r'\1: <timestamp>', examples['markdown'], flags=re.MULTILINE),
        )
        template = (SKILLS.parent / 'templates/notes/source-interview.md').read_text(encoding='utf-8')
        self.assertEqual(re.findall(r'^## (.+)$', note, flags=re.MULTILINE),
                         re.findall(r'^## (.+)$', template, flags=re.MULTILINE))

    def test_legacy_note_and_an_ordinary_interview_share_the_folder(self) -> None:
        legacy = self.note.parent / f'granola-{MEETING_ID}.md'
        legacy.write_text(f'---\ntype: source-interview\nsource_provider: granola\n'
                          f'granola_meeting_id: {MEETING_ID}\ntitle: "Old recording"\n---\n'
                          '# Old recording\n\nMy edits after the first import.\n', encoding='utf-8')
        ordinary = self.note.parent / 'lab-interview.md'
        ordinary.write_text('---\ntype: source\nsource_type: interview\n---\n# Revised title\n',
                            encoding='utf-8')
        before = {path: path.read_bytes() for path in (legacy, ordinary)}
        self.kb('sync')

        retry = self.ingest(title='Revised title', meeting_date='2026-11-22')
        self.assertEqual((retry['status'], retry['note']), ('existing', f'Sources/Interviews/{legacy.name}'))
        new = self.ingest(meeting_id=SECOND_ID, title='Revised title')
        self.assertEqual(new['note'], 'Sources/Interviews/Granola-26-11-21-Revised-title.md')
        self.kb('sync')
        self.assertEqual({path: path.read_bytes() for path in before}, before)
        self.assertFalse(self.note.exists())
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 3)
        for listing in (self.registry, self.index):
            entries = listing.read_text(encoding='utf-8')
            for path in (ordinary, legacy, self.root / new['note']):
                self.assertEqual(entries.count(f'[[Sources/Interviews/{path.stem}]]'), 1)

    def test_undated_and_punctuation_only_import_has_a_stable_name(self) -> None:
        payload = self.meeting(title='!?…')
        del payload['meeting_date']
        result = json.loads(self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(payload)).stdout)
        expected = 'Sources/Interviews/Granola-undated-note.md'
        self.assertEqual(result['note'], expected)
        retry = self.ingest(title='Date and topic now known')
        self.assertEqual((retry['status'], retry['note']), ('existing', expected))

    def test_lecture_title_is_safe_for_filenames_and_obsidian_links(self) -> None:
        topic = '讲座/[[研究方法]] #训练|复习：' + '模型' * 80
        result = self.ingest(title=topic, source_kind='transcript', participants=['主讲人'],
                             decisions=[], action_items=[], open_questions=[])
        path = self.root / result['note']
        self.assertEqual(path.parent, self.note.parent)
        self.assertTrue(path.name.startswith('Granola-26-11-21-讲座-研究方法-训练-复习-'))
        self.assertNotIn(MEETING_ID, path.name)
        filename_topic = path.stem.removeprefix('Granola-26-11-21-')
        self.assertLessEqual(len(filename_topic.encode('utf-8')), 96)
        link = f'[[Sources/Interviews/{path.stem}]]'
        self.assertIn(link, self.index.read_text(encoding='utf-8'))
        content = path.read_text(encoding='utf-8')
        self.assertIn(f'title: {json.dumps(topic, ensure_ascii=False)}', content)
        self.assertNotIn('**已定事项**', content)
        self.assertIn('### 待办\n\n- 未记录', content)

    def test_utf8_json_pipes_on_a_legacy_windows_code_page(self) -> None:
        payload = json.dumps(self.meeting(), ensure_ascii=False)
        with patch.dict(os.environ, {'PYTHONIOENCODING': 'cp1252'}):
            saved = json.loads(self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=payload).stdout)
            self.assertEqual(saved['note'], self.note.relative_to(self.root).as_posix())
            renamed = 'Sources/Interviews/手动改名.md'
            moved = json.loads(self.kb('note-lifecycle', '--mode', 'rename', '--note', saved['note'],
                                       '--dest', renamed).stdout)
            self.assertEqual((moved['from'], moved['to']), (saved['note'], renamed))
            self.assertEqual(self.ingest()['note'], renamed)

    def test_utf8_bom_meeting_file_and_stdin_resolve_the_same_note(self) -> None:
        payload = '\ufeff' + json.dumps(self.meeting(source_kind='notes'), ensure_ascii=False)
        source = self.repo.parent / 'bom-meeting.json'
        source.write_bytes(payload.encode('utf-8'))
        created = json.loads(self.run_cli(GRANOLA_HELPER, '--input', str(source)).stdout)
        self.assertEqual(created['status'], 'created')
        note = self.root / created['note']
        before = note.read_bytes()
        retry = json.loads(self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=payload).stdout)
        self.assertEqual((retry['status'], retry['note']), ('existing', created['note']))
        self.assertEqual(note.read_bytes(), before)
        self.assertIn('source_kind: notes', before.decode('utf-8'))

    def granola_registry_entries(self) -> list[tuple[str, str]]:
        rows = self.registry.read_text(encoding='utf-8').splitlines()
        cells = [row.split('|') for row in rows if '| Granola |' in row]
        return [(row[1].strip(), row[4].strip()) for row in cells]

    def test_bom_on_saved_markdown_preserves_note_registry_id_and_link(self) -> None:
        first = self.ingest()
        entries = self.granola_registry_entries()
        self.assertEqual(len(entries), 1)
        edited = ('\ufeff' + self.note.read_text(encoding='utf-8') + '\nMy follow-up.\n').replace('\n', '\r\n')
        self.note.write_bytes(edited.encode('utf-8'))
        retry = self.ingest(title='Updated title in Granola')
        self.assertEqual((retry['status'], retry['note']), ('existing', first['note']))
        self.assertEqual(list(self.note.parent.glob('*.md')), [self.note])
        self.assertEqual(self.note.read_bytes(), edited.encode('utf-8'))
        self.assertEqual(self.granola_registry_entries(), entries)
        self.assertEqual(self.index.read_text(encoding='utf-8').count(entries[0][1]), 1)

    def test_immediate_reimport_after_manual_rename_preserves_original_id(self) -> None:
        first = self.ingest()
        [(original_id, original_link)] = self.granola_registry_entries()
        renamed = self.note.rename(self.note.with_name('My edited meeting.md'))
        edited = renamed.read_bytes() + b'\nHandwritten follow-up.\n'
        renamed.write_bytes(edited)
        retry = self.ingest(title='A different remote title')
        expected = renamed.relative_to(self.root).as_posix()
        self.assertNotEqual(first['note'], expected)
        self.assertEqual((retry['status'], retry['note']), ('existing', expected))
        self.assertEqual(renamed.read_bytes(), edited)
        self.assertEqual(list(renamed.parent.glob('*.md')), [renamed])
        current_link = f'[[{expected.removesuffix(".md")}]]'
        self.assertEqual(self.granola_registry_entries(), [(original_id, current_link)])
        index = self.index.read_text(encoding='utf-8')
        self.assertNotIn(original_link, index)
        self.assertEqual(index.count(current_link), 1)

    def test_same_title_manual_renames_keep_distinct_registry_ids(self) -> None:
        expected = {}
        for uid in (MEETING_ID, SECOND_ID):
            result = self.ingest(meeting_id=uid)
            original = self.root / result['note']
            link = f'[[{result["note"].removesuffix(".md")}]]'
            registry_id = next(key for key, path in self.granola_registry_entries() if path == link)
            expected[uid] = (original, registry_id)
        for original, registry_id in expected.values():
            original.rename(original.with_name(f'Manual {registry_id}.md'))
        for uid in (SECOND_ID, MEETING_ID):
            self.assertEqual(self.ingest(meeting_id=uid)['status'], 'existing')
        links = [(key, f'[[Sources/Interviews/Manual {key}]]') for _, key in expected.values()]
        self.assertCountEqual(self.granola_registry_entries(), links)
        for _, link in links:
            self.assertEqual(self.index.read_text(encoding='utf-8').count(link), 1)

    def test_explicit_old_path_repairs_stale_retry_without_rewriting_the_note(self) -> None:
        first = self.ingest()
        [(key, old_link)] = self.granola_registry_entries()
        old_registry = re.sub(r' <!-- source-key: [^>]+ -->', '', self.registry.read_text(encoding='utf-8'))
        row = next(row for row in old_registry.splitlines() if old_link in row)
        renamed = self.note.rename(self.note.with_name('Review.md'))
        before = renamed.read_bytes()
        link = '[[Sources/Interviews/Review]]'
        # Older retries could already have appended a second row.
        duplicate = row.replace(key, 'interview-999', 1).replace(old_link, link)
        self.registry.write_text(old_registry.replace(row, row + '\n' + duplicate), encoding='utf-8')
        before_registry = self.registry.read_bytes()
        before_index = self.index.read_bytes()
        for invalid in ('../outside.md', str(renamed), 'Sources/Interviews/Review.md', 'Sources/Interviews/wrong.md'):
            with self.subTest(previous_note=invalid):
                rejected = self.run_cli(GRANOLA_HELPER, '--input', '-', '--previous-note', invalid,
                                        stdin=json.dumps(self.meeting()), check=False)
                self.assertNotEqual(rejected.returncode, 0)
                self.assertIn('--previous-note', rejected.stderr)
                self.assertEqual(self.registry.read_bytes(), before_registry)
                self.assertEqual(self.index.read_bytes(), before_index)
        self.assertEqual(self.ingest(previous_note=first['note'])['status'], 'existing')
        # An interrupted index update must be repairable with the same command.
        self.index.write_bytes(before_index)
        self.assertEqual(self.ingest(previous_note=first['note'])['status'], 'existing')
        self.assertEqual(renamed.read_bytes(), before)
        self.assertEqual(self.granola_registry_entries(), [(key, link)])
        self.assertNotIn(old_link, self.index.read_text(encoding='utf-8'))
        self.assertEqual(self.index.read_text(encoding='utf-8').count(link), 1)

    def test_legacy_retry_keeps_other_same_title_source(self) -> None:
        self.ingest()
        second = self.root / self.ingest(meeting_id=SECOND_ID)['note']
        entries = self.granola_registry_entries()
        self.registry.write_text(re.sub(r' <!-- source-key: [^>]+ -->', '',
                                        self.registry.read_text(encoding='utf-8')), encoding='utf-8')
        second.rename(second.with_name('Other meeting.md'))
        self.ingest()
        self.assertEqual(self.granola_registry_entries(), entries)
        self.ingest(meeting_id=SECOND_ID, previous_note=second.relative_to(self.root).as_posix())
        self.assertEqual(self.granola_registry_entries(),
                         [entries[0], (entries[1][0], '[[Sources/Interviews/Other meeting]]')])

    def test_unmarked_rename_cannot_claim_another_meeting_with_the_same_title(self) -> None:
        first = self.ingest()
        second = self.root / self.ingest(meeting_id=SECOND_ID)['note']
        custom = 'Sources/Interviews/Retitled meeting.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', first['note'], '--dest', custom)
        self.registry.write_text(re.sub(r' <!-- source-key: [^>]+ -->', '',
                                        self.registry.read_text(encoding='utf-8')), encoding='utf-8')
        before = {file: file.read_bytes() for file in (self.registry, self.index)}
        renamed = (self.root / custom).rename(self.note.with_name('Renamed again.md'))
        second.rename(second.with_name('Different meeting.md'))

        rejected = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(self.meeting()), check=False)

        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn('--previous-note', rejected.stderr)
        self.assertEqual({file: file.read_bytes() for file in before}, before)
        self.assertEqual(self.ingest(previous_note=custom)['note'], renamed.relative_to(self.root).as_posix())

    def test_legacy_uuid_filename_repairs_a_missing_link(self) -> None:
        self.ingest()
        [(registry_id, link)] = self.granola_registry_entries()
        old_link = f'[[Sources/Interviews/granola-{MEETING_ID}]]'
        registry = re.sub(r' <!-- source-key: [^>]+ -->', '', self.registry.read_text(encoding='utf-8'))
        row = next(line for line in registry.splitlines() if link in line)
        other_paths = (f'Sources/Interviews/granola-{SECOND_ID}.md', 'Sources/Interviews/Another discussion.md')
        other_links = [f'[[{path.removesuffix(".md")}]]' for path in other_paths]
        other_ids = ['interview-998', 'interview-999']
        unrelated_rows = [row.replace(registry_id, key, 1).replace(link, other)
                          for key, other in zip(other_ids, other_links)]
        self.registry.write_text(registry.replace(row, '\n'.join([row.replace(link, old_link), *unrelated_rows])),
                                 encoding='utf-8')
        renamed = self.note.rename(self.note.with_name('Research discussion.md'))
        before = {file: file.read_bytes() for file in (renamed, self.registry, self.index)}

        for path, error in zip(other_paths, ('different meeting UUID', 'conflicts with a legacy filename')):
            with self.subTest(previous_note=path):
                rejected = self.run_cli(GRANOLA_HELPER, '--input', '-', '--previous-note', path,
                                        stdin=json.dumps(self.meeting()), check=False)
                self.assertNotEqual(rejected.returncode, 0)
                self.assertIn(error, rejected.stderr)
                self.assertEqual({file: file.read_bytes() for file in before}, before)

        self.assertEqual(self.ingest()['status'], 'existing')
        self.assertEqual(renamed.read_bytes(), before[renamed])
        expected = [(registry_id, '[[Sources/Interviews/Research discussion]]'), *zip(other_ids, other_links)]
        self.assertEqual(self.granola_registry_entries(), expected)

    def test_cross_category_reimport_preserves_status_and_reserves_id(self) -> None:
        first = self.ingest()
        [(registry_id, old_link)] = self.granola_registry_entries()
        registry = self.registry.read_text(encoding='utf-8')
        lines = [row.replace('| active |', '| draft |') if old_link in row else row for row in registry.splitlines()]
        self.registry.write_text('\n'.join(lines) + '\n', encoding='utf-8')
        moved = 'Knowledge/Review meeting.md'
        (self.root / first['note']).rename(self.root / moved)

        self.assertEqual(self.ingest()['note'], moved)
        self.ingest(meeting_id=SECOND_ID)

        registry = self.registry.read_text(encoding='utf-8')
        row = next(line for line in registry.splitlines() if '[[Knowledge/Review meeting]]' in line)
        self.assertIn(f'| {registry_id} |', row)
        self.assertIn('| draft |', row)
        self.assertNotEqual(self.granola_registry_entries()[0][0], registry_id)
        coverage = json.loads(self.run_cli(KB_HELPER.with_name('kb_registry_check.py')).stdout)
        self.assertTrue(coverage['coverage_ok'], coverage)

    def test_new_meeting_reserves_a_missing_registered_path_case_insensitively(self) -> None:
        first = self.ingest(title='Pilot Review')
        previous = self.root / first['note']
        renamed = previous.rename(previous.with_name('Review notes.md'))

        second = self.ingest(meeting_id=SECOND_ID, title='pilot review')
        self.assertTrue(second['note'].endswith('-2.md'), second)
        self.assertEqual(self.ingest()['note'], renamed.relative_to(self.root).as_posix())

        self.assertFalse(previous.exists())
        entries = self.granola_registry_entries()
        self.assertEqual(len(entries), 2)
        index = self.index.read_text(encoding='utf-8')
        self.assertNotIn(f'[[{first["note"].removesuffix(".md")}]]', index)
        self.assertTrue(all(index.count(link) == 1 for _, link in entries))

    def test_existing_meeting_cannot_take_a_path_registered_to_another_meeting(self) -> None:
        first = self.root / self.ingest(title='First meeting')['note']
        second = self.root / self.ingest(meeting_id=SECOND_ID, title='Another meeting')['note']
        first.rename(first.with_name('First meeting edited.md'))
        second.rename(first)
        before = {file: file.read_bytes() for file in (first, self.registry, self.index)}

        rejected = self.run_cli(GRANOLA_HELPER, '--input', '-',
                                stdin=json.dumps(self.meeting(meeting_id=SECOND_ID)), check=False)
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn('already registered to another source', rejected.stderr)
        self.assertEqual({file: file.read_bytes() for file in before}, before)

        self.ingest()
        self.assertEqual(self.ingest(meeting_id=SECOND_ID)['note'], first.relative_to(self.root).as_posix())
        self.assertEqual(len(self.granola_registry_entries()), 2)

    def test_retry_preserves_edits_and_repairs_registry(self) -> None:
        title = 'Pilot "A" \\ branch'
        self.note = self.root / self.ingest(title=title)['note']
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
        self.note = self.root / self.ingest(title='Fixture original')['note']
        original = self.note.read_text(encoding='utf-8')
        second = self.root / self.ingest(meeting_id=SECOND_ID, title='Another meeting')['note']
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
                for note in (self.note, second):
                    self.assertIn(f'[[Sources/Interviews/{note.stem}]]', index)

    def test_renamed_and_archived_notes_remain_unique(self) -> None:
        title = 'Discussion of the evaluation split'
        self.note = self.root / self.ingest(title=title)['note']
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
        self.note = self.root / self.ingest(title='Fixture research discussion')['note']
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
        self.note = self.root / self.ingest(title='Original fixture')['note']
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
        link = f'[[Sources/Interviews/{self.note.stem}]]'
        row = next(row for row in self.registry.read_text(encoding='utf-8').splitlines() if link in row)
        self.assertIn(f'| {title} |', row)
        self.assertIn('| Granola |', row)

    def test_rebuilding_registry_recovers_all_meeting_titles_and_origins(self) -> None:
        titles = {MEETING_ID: 'Fixture Atlas review', SECOND_ID: 'Fixture seminar'}
        links = {}
        for meeting_id, title in titles.items():
            note_path = self.ingest(meeting_id=meeting_id, title=title)['note']
            links[meeting_id] = f'[[{note_path.removesuffix(".md")}]]'
        for action in ('sync', 'import'):
            with self.subTest(action=action):
                self.registry.write_bytes(b'')
                if action == 'sync':
                    self.kb('sync')
                else:
                    self.assertEqual(self.ingest()['status'], 'existing')
                rows = self.registry.read_text(encoding='utf-8').splitlines()
                for meeting_id, title in titles.items():
                    row = next(row for row in rows if links[meeting_id] in row)
                    self.assertIn(f'| {title} |', row)
                    self.assertIn('| Granola |', row)

    def test_retry_registers_a_note_in_a_custom_sources_subfolder(self) -> None:
        self.note = self.root / self.ingest(title='Custom folder meeting')['note']
        moved = 'Sources/Meetings/team-review.md'
        self.kb('note-lifecycle', '--mode', 'rename', '--note', self.note.relative_to(self.root).as_posix(), '--dest', moved)
        legacy = self.root / 'Sources/Fieldwork/previous-meeting.md'
        legacy.parent.mkdir()
        legacy.write_text(
            f'---\ntype: source-interview\nsource_provider: granola\n'
            f'granola_meeting_id: {SECOND_ID}\ntitle: "Previous fieldwork"\n---\n\nResearcher annotations.\n',
            encoding='utf-8',
        )
        legacy_before = legacy.read_bytes()
        self.registry.unlink()
        result = self.ingest()
        self.assertEqual((result['status'], result['note']), ('existing', moved))
        registry = self.registry.read_text(encoding='utf-8').splitlines()
        index = self.index.read_text(encoding='utf-8')
        for link, title in (('[[Sources/Meetings/team-review]]', 'Custom folder meeting'),
                            ('[[Sources/Fieldwork/previous-meeting]]', 'Previous fieldwork')):
            self.assertIn(link, index)
            row = next(row for row in registry if link in row)
            self.assertIn(f'| interview | {title} |', row)
            self.assertIn('| Granola |', row)
        self.assertEqual(self.ingest(meeting_id=SECOND_ID)['status'], 'existing')
        self.assertEqual(legacy.read_bytes(), legacy_before)

    def test_concurrent_imports_keep_both_meetings_and_deduplicate(self) -> None:
        with ThreadPoolExecutor(max_workers=3) as executor:
            results = list(executor.map(lambda uid: self.ingest(meeting_id=uid),
                                        [MEETING_ID, MEETING_ID, SECOND_ID]))
        self.assertCountEqual([item['status'] for item in results], ['created', 'existing', 'created'])
        first, repeated, second = [item['note'] for item in results]
        self.assertEqual(first, repeated)
        self.assertEqual({first, second}, {self.note.relative_to(self.root).as_posix(),
                                         'Sources/Interviews/Granola-26-11-21-组会-消融实验-2.md'})
        for uid, path in ((MEETING_ID, first), (SECOND_ID, second)):
            self.assertIn(f'granola_meeting_id: {uid}', (self.root / path).read_text(encoding='utf-8'))
            self.assertEqual(self.ingest(meeting_id=uid, title='Changed title')['note'], path)
            for listing in (self.registry, self.index):
                self.assertEqual(listing.read_text(encoding='utf-8').count(f'[[{path.removesuffix(".md")}]]'), 1)
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

def report_started(binding, payload, **options):
    print('importing', flush=True)
    return ingest(binding, payload, **options)

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
        occupied = self.note.with_stem(self.note.stem + '-2')
        occupied.write_text('# Another interview\n', encoding='utf-8')
        result = self.ingest()
        self.assertEqual(result['status'], 'created')
        self.assertEqual(self.root / result['note'], self.note.with_stem(self.note.stem + '-3'))
        self.assertEqual(self.ingest()['note'], result['note'])
        self.assertEqual(self.note.read_text(encoding='utf-8'), '# Existing note\n')
        self.assertEqual(occupied.read_text(encoding='utf-8'), '# Another interview\n')

    def test_dated_uuid_note_can_be_reused_then_renamed_without_losing_edits(self) -> None:
        legacy = self.note.with_stem(f'{self.note.stem}-{MEETING_ID}')
        original = f'---\nsource_provider: granola\ngranola_meeting_id: {MEETING_ID}\n---\n# Group meeting\nMy edits.\n'
        legacy.write_text(original, encoding='utf-8')
        old_path = legacy.relative_to(self.root).as_posix()
        self.assertEqual(self.ingest()['note'], old_path)
        self.assertFalse(self.note.exists())
        new_path = self.note.relative_to(self.root).as_posix()
        self.kb('note-lifecycle', '--mode', 'rename', '--note', old_path, '--dest', new_path)
        result = self.ingest(title='A different title on retry')
        self.assertEqual((result['status'], result['note']), ('existing', new_path))
        self.assertEqual(self.note.read_text(encoding='utf-8'), original)
        for listing in (self.registry, self.index):
            entries = listing.read_text(encoding='utf-8')
            self.assertIn(f'[[{new_path.removesuffix(".md")}]]', entries)
            self.assertNotIn(legacy.stem, entries)

    def test_target_check_distinguishes_same_named_vaults_before_writing(self) -> None:
        other_vault = self.repo.parent / 'Other' / self.vault.name
        other_vault.mkdir(parents=True)
        before = {p: p.read_bytes() for p in self.root.rglob('*.md')}
        target = json.loads(self.run_cli(GRANOLA_HELPER, '--show-target').stdout)
        self.assertEqual(target, {'project_id': 'granola-demo', 'vault_path': str(self.vault.resolve()),
                                  'project_folder': 'Research/granola-demo'})
        failed = self.run_cli(GRANOLA_HELPER, '--expect-vault', str(other_vault), '--input', '-',
                              stdin=json.dumps(self.meeting()), check=False)
        self.assertNotEqual(failed.returncode, 0)
        self.assertIn('does not match', failed.stderr)
        self.assertEqual({p: p.read_bytes() for p in self.root.rglob('*.md')}, before)
        self.assertEqual(list(other_vault.iterdir()), [])
        self.assertFalse((self.vault / '.obsidian').exists())
        saved = json.loads(self.run_cli(GRANOLA_HELPER, '--expect-vault', target['vault_path'],
                                        '--input', '-', stdin=json.dumps(self.meeting())).stdout)
        self.assertEqual(saved['status'], 'created')
        self.assertEqual(saved['vault_note'], self.note.relative_to(self.vault).as_posix())

    def test_ambiguous_project_requires_an_explicit_binding(self) -> None:
        other = json.loads(self.kb('bootstrap', '--vault-path', str(self.vault),
                                   '--project-name', 'Another project').stdout)
        for args in (('--show-target',), ('--input', '-')):
            rejected = self.run_cli(GRANOLA_HELPER, *args, stdin=json.dumps(self.meeting()), check=False)
            self.assertNotEqual(rejected.returncode, 0)
            self.assertIn('--project-id', rejected.stderr)
        selected = json.loads(self.run_cli(GRANOLA_HELPER, '--project-id', other['project_id'], '--show-target').stdout)
        self.assertEqual(selected['project_folder'], 'Research/another-project')
        self.assertFalse(self.note.exists())
        self.assertEqual(list((Path(other['project_root']) / 'Sources/Interviews').iterdir()), [])

    def test_unbound_repo_does_not_create_a_trial_vault(self) -> None:
        self.repo = self.repo.parent / 'New repo'
        self.repo.mkdir()
        for args in (('--show-target',), ('--input', '-')):
            rejected = self.run_cli(GRANOLA_HELPER, *args, stdin=json.dumps(self.meeting()), check=False)
            self.assertNotEqual(rejected.returncode, 0)
            self.assertIn('existing Obsidian vault', rejected.stderr)
        self.assertEqual(list(self.repo.iterdir()), [])

    def test_copied_binding_does_not_silently_import_to_original_repo(self) -> None:
        original_registry = self.binding_registry
        relative_registry = original_registry.relative_to(self.repo.resolve())
        self.repo = self.repo.parent / 'Copied repo'
        copy = self.repo / relative_registry
        copy.parent.mkdir(parents=True)
        copy.write_bytes(original_registry.read_bytes())
        rejected = self.run_cli(GRANOLA_HELPER, '--input', '-', stdin=json.dumps(self.meeting()), check=False)
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn('another repository', rejected.stderr)
        self.assertFalse(self.note.exists())
        target = json.loads(self.run_cli(GRANOLA_HELPER, '--project-id', 'granola-demo', '--show-target').stdout)
        self.assertEqual(target['vault_path'], str(self.vault.resolve()))

    def test_binding_supports_standard_obsidian_commands(self) -> None:
        registry = self.binding_registry
        self.assertEqual(registry, self.repo.resolve() / '.opencode/project-memory/registry.yaml')
        memory = registry.with_name('granola-demo.md')
        self.assertTrue(memory.is_file())
        before = registry.read_bytes()

        self.assertEqual(json.loads(self.kb('detect').stdout)['project']['project_id'], 'granola-demo')
        self.assertEqual(json.loads(self.kb('status').stdout)['project_root'], str(self.root.resolve()))
        self.assertEqual(self.ingest()['status'], 'created')
        self.assertEqual(json.loads(self.kb('sync').stdout)['project_id'], 'granola-demo')
        self.assertIn('scope=auto;', memory.read_text(encoding='utf-8'))
        self.assertEqual(registry.read_bytes(), before)

        self.assertEqual(json.loads(self.kb('lifecycle', '--mode', 'detach').stdout)['status'], 'detached')
        self.assertEqual(json.loads(self.kb('status').stdout)['status'], 'detached')
        self.assertTrue(self.note.is_file())

    def test_native_binding_is_read_without_a_legacy_registry(self) -> None:
        self.place_binding('.opencode')
        target = json.loads(self.run_cli(GRANOLA_HELPER, '--show-target').stdout)
        self.assertEqual(target['vault_path'], str(self.vault.resolve()))
        self.assertEqual(self.ingest()['status'], 'created')
        self.assertEqual(json.loads(self.kb('status').stdout)['sources'], 1)
        self.assertFalse((self.repo / '.claude/project-memory').exists())

    def test_import_sync_and_lifecycle_follow_a_legacy_binding(self) -> None:
        legacy = self.place_binding('.claude')
        memory = legacy / 'granola-demo.md'
        self.assertEqual(self.ingest()['status'], 'created')
        self.kb('sync')
        self.assertIn('scope=auto;', memory.read_text(encoding='utf-8'))
        self.kb('lifecycle', '--mode', 'detach')
        self.assertEqual(json.loads(self.kb('status').stdout)['status'], 'detached')
        self.assertNotEqual(self.run_cli(GRANOLA_HELPER, '--show-target', check=False).returncode, 0)
        self.assertTrue(self.note.is_file())
        self.kb('lifecycle', '--mode', 'purge')
        self.assertFalse(memory.exists())
        self.assertFalse((self.repo / '.opencode/project-memory').exists())

    def test_mixed_bindings_require_a_choice_and_prefer_native_for_the_same_id(self) -> None:
        native = self.place_binding('.opencode')
        primary = native / 'registry.yaml'
        old = self.repo / '.claude/project-memory/registry.yaml'
        old.parent.mkdir(parents=True, exist_ok=True)
        other_root = self.repo.parent / 'Other vault/Research/old-study'
        other_root.mkdir(parents=True)
        entry = {'vault_root': str(other_root), 'repo_roots': [str(self.repo.resolve())]}
        old.write_text(json.dumps({'projects': {'granola-demo': entry, 'old-study': entry}}), encoding='utf-8')
        before = {path: path.read_bytes() for path in (primary, old)}
        ambiguous = self.run_cli(GRANOLA_HELPER, '--show-target', check=False)
        self.assertNotEqual(ambiguous.returncode, 0)
        self.assertIn('--project-id', ambiguous.stderr)
        self.assertEqual(self.ingest(project_id='granola-demo')['vault_path'], str(self.vault.resolve()))
        self.assertEqual(list(other_root.iterdir()), [])
        self.assertEqual(self.ingest(project_id='old-study')['vault_path'], str(other_root.resolve().parent.parent))
        self.assertEqual({path: path.read_bytes() for path in before}, before)

    def test_bootstrap_keeps_a_legacy_memory_with_its_original_vault(self) -> None:
        legacy = self.place_binding('.claude')
        old_memory = legacy / 'granola-demo.md'
        old_memory.write_text(old_memory.read_text(encoding='utf-8') + '\nVault-specific notes.\n', encoding='utf-8')
        old_bytes = old_memory.read_bytes()
        other = self.repo.parent / 'Other vault'
        other.mkdir()
        result = json.loads(self.kb('bootstrap', '--vault-path', str(other), '--project-name', 'Granola Demo').stdout)
        new_memory = Path(result['memory_path']).read_text(encoding='utf-8')
        self.assertIn(f"vault_root: {result['project_root']}", new_memory)
        self.assertNotIn('Vault-specific notes.', new_memory)
        self.assertEqual(old_memory.read_bytes(), old_bytes)
        self.assertEqual(self.ingest()['vault_path'], str(other.resolve()))

    def test_rebinding_the_same_vault_retains_legacy_project_notes(self) -> None:
        memory = self.place_binding('.claude') / 'granola-demo.md'
        edited = memory.read_bytes() + '\n手动补记。\n'.encode('utf-8')
        memory.write_bytes(edited)
        result = json.loads(self.kb('bootstrap', '--vault-path', str(self.vault), '--project-name',
                                    'Granola Demo', '--note-language', 'zh-CN').stdout)
        new_memory = Path(result['memory_path'])
        self.assertEqual(new_memory.parent, self.repo.resolve() / '.opencode/project-memory')
        self.assertEqual(new_memory.read_bytes(), edited)
        self.assertEqual(memory.read_bytes(), edited)

    def test_binding_is_not_redirected_by_codex_preview(self) -> None:
        other_project = self.vault / 'Research/another-project'
        other_project.mkdir()
        preview = self.repo / '.codex/project-memory/registry.yaml'
        preview.parent.mkdir(parents=True)
        preview_binding = {'vault_root': str(other_project)}
        preview.write_text(json.dumps({'projects': {
            'another-project': preview_binding, 'granola-demo': preview_binding,
        }}), encoding='utf-8')
        before = {path: path.read_bytes() for path in (self.binding_registry, preview)}
        self.assertEqual(json.loads(self.kb('detect').stdout)['project']['project_id'], 'granola-demo')
        self.assertEqual(self.ingest()['project_id'], 'granola-demo')
        self.assertEqual(self.ingest(project_id='granola-demo')['status'], 'existing')
        rejected = self.run_cli(GRANOLA_HELPER, '--project-id', 'another-project', '--show-target', check=False)
        self.assertNotEqual(rejected.returncode, 0)
        self.assertEqual(list(other_project.iterdir()), [])
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
