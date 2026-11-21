import io
import json
import subprocess
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

import doctor


class DoctorTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix='scholar-doctor-')
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.codex_home = self.root / 'codex'
        self.codex_home.mkdir()

    def install_file(self, relative):
        path = self.codex_home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.touch()

    def test_same_named_skill_without_receipt(self):
        self.install_file(doctor.COMPONENTS[0])
        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'components_only')
        self.assertFalse(result['components'][0]['managed'])
        self.assertIsNone(result['source_revision'])

    def test_existing_installation_and_missing_component(self):
        for relative in doctor.COMPONENTS:
            self.install_file(relative)
        manifest = self.codex_home / doctor.MANIFEST
        manifest.write_text('\n'.join(doctor.COMPONENTS), encoding='utf-8')
        receipt = self.codex_home / doctor.RECEIPT
        receipt.write_text(json.dumps({
            'managedPaths': list(doctor.COMPONENTS),
            'sourceRevision': 'a' * 40, 'sourceModified': True,
        }), encoding='utf-8')
        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'installed')
        self.assertEqual(result['source_revision'], 'a' * 40)
        self.assertTrue(result['source_modified'])

        (self.codex_home / doctor.COMPONENTS[0]).unlink()
        self.assertEqual(doctor.installation(self.codex_home)['status'], 'incomplete')

        receipt.write_text('{broken json', encoding='utf-8')
        self.assertEqual(doctor.installation(self.codex_home)['status'], 'incomplete_receipt')

    def test_manifest_must_agree_with_receipt(self):
        for relative in doctor.COMPONENTS:
            self.install_file(relative)
        manifest = self.codex_home / doctor.MANIFEST
        manifest.write_text('', encoding='utf-8')
        receipt = self.codex_home / doctor.RECEIPT
        receipt.write_text(json.dumps({'managedPaths': list(doctor.COMPONENTS)}), encoding='utf-8')

        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'incomplete_receipt')
        self.assertFalse(result['manifest_valid'])
        self.assertTrue(result['receipt_valid'])
        self.assertFalse(any(item['managed'] for item in result['components']))

        receipt.write_text(json.dumps({'managedPaths': [[]]}), encoding='utf-8')
        self.assertFalse(doctor.installation(self.codex_home)['receipt_valid'])

        receipt.write_text(json.dumps({'managedPaths': []}), encoding='utf-8')
        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'installed')
        self.assertTrue(result['manifest_valid'])
        self.assertFalse(any(item['managed'] for item in result['components']))

    def test_configured_mcp_keeps_secrets_out_of_report(self):
        raw = [{
            'name': 'granola', 'enabled': False,
            'transport': {'headers': {'Authorization': 'fixture-private-value'}},
        }]
        completed = subprocess.CompletedProcess([], 0, json.dumps(raw), '')
        with patch('doctor.shutil.which', return_value='/example/bin/codex'), \
                patch('doctor.subprocess.run', return_value=completed) as run:
            result = doctor.mcp_status(self.codex_home, self.root)
        self.assertEqual(result['servers']['granola'], {'configured': True, 'enabled': False})
        self.assertEqual(result['servers']['zotero'], {'configured': False, 'enabled': None})
        self.assertNotIn('fixture-private-value', json.dumps(result))
        self.assertEqual(run.call_args.kwargs['env']['CODEX_HOME'], str(self.codex_home))

    def test_unavailable_mcp_is_separate_from_unconfigured(self):
        with patch('doctor.shutil.which', return_value='/example/bin/codex'), \
                patch('doctor.subprocess.run', side_effect=subprocess.TimeoutExpired('codex', 15)):
            result = doctor.mcp_status(self.codex_home, self.root)
        self.assertEqual(result, {'status': 'unavailable', 'servers': None})
        self.assertEqual(doctor.mcp_status(self.root / 'missing', self.root)['status'], 'codex_home_missing')

    def test_binding_uses_actual_kb_helper_path(self):
        cwd = self.root / 'research'
        cwd.mkdir()
        self.assertEqual(doctor.obsidian_binding(cwd)['status'], 'unbound')
        documented = cwd / '.codex/project-memory/registry.yaml'
        documented.parent.mkdir(parents=True)
        project = self.root / 'vault/Research/test-project'
        project.mkdir(parents=True)
        data = json.dumps({'projects': {'test-project': {'vault_root': str(project)}}})
        documented.write_text(data, encoding='utf-8')
        registry = documented
        result = doctor.obsidian_binding(cwd)
        if result['status'] == 'registry_not_used_by_helper':
            registry = cwd / '.claude/project-memory/registry.yaml'
            registry.parent.mkdir(parents=True)
            registry.write_text(data, encoding='utf-8')
            result = doctor.obsidian_binding(cwd)
        self.assertEqual(result['status'], 'bound')
        self.assertEqual(result['project_id'], 'test-project')

        for lifecycle in ('archived', 'detached'):
            binding = {'vault_root': str(project), 'status': lifecycle}
            registry.write_text(json.dumps({'projects': {'test-project': binding}}), encoding='utf-8')
            result = doctor.obsidian_binding(cwd)
            self.assertEqual(result['status'], lifecycle)
            self.assertEqual(result['binding_status'], lifecycle)
        stdout = io.StringIO()
        with patch('sys.argv', ['doctor.py', '--cwd', str(cwd), '--codex-home', str(self.codex_home)]), \
                patch('doctor.mcp_status', return_value={'status': 'unavailable', 'servers': None}), \
                redirect_stdout(stdout):
            doctor.main()
        self.assertIn('Obsidian: detached\n', stdout.getvalue())

        registry.write_text(data, encoding='utf-8')
        project.rmdir()
        self.assertEqual(doctor.obsidian_binding(cwd)['status'], 'vault_path_missing')

    def test_invalid_binding_registry_returns_unresolved(self):
        for prefix in ('.codex', '.claude'):
            registry = self.root / prefix / 'project-memory/registry.yaml'
            registry.parent.mkdir(parents=True)
            registry.write_text(json.dumps({'projects': ['not-a-project-map']}), encoding='utf-8')
        result = doctor.obsidian_binding(self.root)
        self.assertEqual(result['status'], 'binding_unresolved')


if __name__ == '__main__':
    unittest.main(verbosity=2)
