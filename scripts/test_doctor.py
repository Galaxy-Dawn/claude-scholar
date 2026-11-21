import io
import json
import os
import shutil
import subprocess
import sys
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

    def record_paths(self, paths):
        (self.codex_home / doctor.MANIFEST).write_text('\n'.join(paths), encoding='utf-8')
        (self.codex_home / doctor.RECEIPT).write_text(json.dumps({'managedPaths': paths}), encoding='utf-8')

    def run_doctor(self, *options):
        args = ['doctor.py', '--codex-home', str(self.codex_home), '--cwd', str(self.root), *options]
        with patch('sys.argv', args), redirect_stdout(io.StringIO()) as stdout:
            doctor.main()
        return stdout.getvalue()

    def test_missing_installation_reports_not_detected_without_creating_the_directory(self):
        self.codex_home.rmdir()
        report = json.loads(self.run_doctor('--json'))
        self.assertEqual(report['installation']['status'], 'not_detected')
        self.assertEqual(report['mcp']['status'], 'codex_home_missing')
        self.assertIn('Codex Scholar: not_detected', self.run_doctor())
        self.assertFalse(self.codex_home.exists())

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

    def test_recorded_files_and_unowned_components(self):
        core = 'skills/obsidian-project-kb-core/scripts/project_kb.py'
        template = 'templates/example.md'
        self.record_paths([template, core])
        for relative in (*doctor.COMPONENTS, template):
            self.install_file(relative)
        report = json.loads(self.run_doctor('--json'))
        self.assertFalse(report['mcp']['servers']['granola']['configured'])
        result = report['installation']
        self.assertEqual(result['status'], 'installed')
        self.assertIsNone(result['source_revision'])  # Older receipts have no revision.
        self.assertEqual([entry['path'] for entry in result['components'] if entry['managed']], [core])

        (self.codex_home / core).unlink()
        (self.codex_home / template).unlink()
        (self.codex_home / template).mkdir()
        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'incomplete')
        self.assertEqual(result['missing_managed_paths'], [core, template])
        self.assertEqual(json.loads(self.run_doctor('--json'))['installation'], result)
        text = self.run_doctor()
        for relative in (core, template):
            self.assertIn(f'  {relative}: missing\n', text)

    def test_unowned_required_helpers_can_be_user_symlinks(self):
        self.record_paths([])
        for relative in doctor.COMPONENTS:
            self.install_file(relative)
        for name in ('project_kb.py', 'kb_common.py'):
            relative = f'skills/obsidian-project-kb-core/scripts/{name}'
            link = self.codex_home / relative
            link.unlink()
            result = doctor.installation(self.codex_home)
            self.assertEqual(result['status'], 'incomplete')
            self.assertIn({'path': relative, 'present': False, 'managed': False}, result['components'])
            self.assertEqual(result['missing_managed_paths'], [])
            (self.root / name).touch()
            link.symlink_to(self.root / name)
            self.assertEqual(doctor.installation(self.codex_home)['status'], 'installed')

    def test_invalid_paths_are_not_checked(self):
        for relative in ('../outside', str(self.root / 'outside'), 'C:/outside', r'..\outside', 'file\0name', '.'):
            with self.subTest(relative=relative):
                self.record_paths([relative])
                with patch('doctor.local_path', wraps=doctor.local_path) as check:
                    result = doctor.installation(self.codex_home)
                self.assertNotIn(relative, [call.args[1] for call in check.call_args_list])
                self.assertEqual(result['status'], 'incomplete_receipt')
                self.assertFalse(result['receipt_valid'])
                self.assertFalse(result['manifest_valid'])

    def test_symlinks_stay_within_the_installation(self):
        self.install_file('inside/file')
        for relative in doctor.COMPONENTS:
            self.install_file(relative)
        alias = self.codex_home / 'alias'
        alias.symlink_to(self.codex_home / 'inside', target_is_directory=True)
        self.record_paths(['alias/file'])
        self.assertEqual(doctor.installation(self.codex_home)['status'], 'installed')

        (self.root / 'file').touch()
        alias.unlink()
        alias.symlink_to(self.root, target_is_directory=True)
        result = doctor.installation(self.codex_home)
        self.assertEqual(result['status'], 'incomplete')
        self.assertEqual(result['missing_managed_paths'], ['alias/file'])

        receipt = self.codex_home / doctor.RECEIPT
        receipt.rename(self.root / 'outside-receipt')
        receipt.symlink_to(self.root / 'outside-receipt')
        self.assertFalse(doctor.installation(self.codex_home)['receipt_valid'])

    def test_configured_mcp_keeps_secrets_out_of_report(self):
        (self.codex_home / 'config.toml').write_text(
            '[mcp_servers.granola]\nenabled = false\n'
            '[mcp_servers.granola.http_headers]\nAuthorization = "fixture-private-value"\n'
            '[mcp_servers.other]\ncommand = "some-program"\n', encoding='utf-8')
        result = doctor.mcp_status(self.codex_home)
        self.assertEqual(result['servers']['granola'], {'configured': True, 'enabled': False})
        self.assertEqual(result['servers']['zotero'], {'configured': False, 'enabled': None})
        self.assertNotIn('fixture-private-value', json.dumps(result))
        self.assertNotIn('other', result['servers'])

    def test_unavailable_mcp_is_separate_from_unconfigured(self):
        self.assertEqual(doctor.mcp_status(self.codex_home)['status'], 'configured_servers_read')
        self.assertEqual(doctor.mcp_status(self.root / 'missing')['status'], 'codex_home_missing')
        for data in ('[broken', 'mcp_servers = 1', '[mcp_servers.zotero]\nenabled = "yes"'):
            with self.subTest(data=data):
                (self.codex_home / 'config.toml').write_text(data, encoding='utf-8')
                report = json.loads(self.run_doctor('--json'))
                self.assertEqual(report['mcp'], {'scope': 'user_config', 'status': 'unavailable', 'servers': None})
                self.assertEqual(report['installation']['status'], 'not_detected')

    def test_missing_toml_reader_only_affects_mcp_status(self):
        (self.codex_home / 'config.toml').write_text('[mcp_servers]\n', encoding='utf-8')
        with patch.dict(sys.modules, {'tomllib': None, 'tomli': None}):
            report = json.loads(self.run_doctor('--json'))
        self.assertEqual(report['mcp']['status'], 'toml_reader_missing')
        self.assertIsNone(report['mcp']['servers'])
        self.assertEqual(report['installation']['status'], 'not_detected')
        self.assertEqual(report['obsidian']['status'], 'unbound')

    def test_documented_command_preserves_installation_and_project(self):
        source = Path(doctor.__file__).resolve()
        entry = self.codex_home / 'scripts/doctor.py'
        entry.parent.mkdir()
        shutil.copyfile(source, entry)
        relative = Path('skills/obsidian-project-kb-core/scripts/kb_common.py')
        (self.codex_home / relative).parent.mkdir(parents=True)
        shutil.copyfile(source.parents[1] / relative, self.codex_home / relative)
        config = self.codex_home / 'config.toml'
        config.write_text('[mcp_servers.zotero]\ncommand = "example"\n', encoding='utf-8')
        project = self.root / 'project'
        (project / '.codex').mkdir(parents=True)
        (project / '.codex/config.toml').write_text('[mcp_servers.granola]\ncommand = "example"\n', encoding='utf-8')
        env = dict(os.environ, CODEX_HOME=str(self.codex_home))
        env.pop('PYTHONDONTWRITEBYTECODE', None)
        env.pop('PYTHONPYCACHEPREFIX', None)

        def snapshot():
            return {p.relative_to(self.root): p.read_bytes() if p.is_file() else None for p in self.root.rglob('*')}

        before = snapshot()
        output = subprocess.check_output([sys.executable, str(entry), '--cwd', '.', '--json'], cwd=project, env=env)
        report = json.loads(output)
        self.assertEqual(report['obsidian']['status'], 'unbound')
        self.assertEqual(report['mcp']['scope'], 'user_config')
        self.assertEqual(report['mcp']['servers']['zotero'], {'configured': True, 'enabled': True})
        self.assertFalse(report['mcp']['servers']['granola']['configured'])
        self.assertEqual(snapshot(), before)

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
