"""Release provenance failures must stop signing preparation."""
import copy
import hashlib
import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.request import HTTPRedirectHandler

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('release_download', ROOT / 'packaging/windows/verify_release_download.py')
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class TransportTests(unittest.TestCase):
    def test_token_is_scoped_and_not_forwarded(self):
        run = VERIFY.RUN_API + '123'
        jobs = run + '/jobs?filter=latest&per_page=100'
        cases = [(run, True), (jobs, True),
                 (run + '/artifacts', False),
                 (run.replace('api.github.com', 'api.github.com.example.org'), False),
                 ('https://github.com/nortja/Living-earth-3d/raw/installer.exe', False),
                 ('https://raw.githubusercontent.com/nortja/Living-earth-3d/main/BUILD.txt', False)]
        with patch.dict('os.environ', {'EARTH_RELEASE_API_TOKEN': 'test-token'}):
            for url, allowed in cases:
                with self.subTest(url=url), patch.object(VERIFY.urllib.request, 'urlopen') as open_url:
                    response = open_url.return_value.__enter__.return_value
                    response.status = 200
                    response.read.return_value = b'{}'
                    self.assertEqual(VERIFY.receive(url, 2), b'{}')
                    response.read.assert_called_once_with(3)
                    request = open_url.call_args.args[0]
                    self.assertEqual(request.get_header('Authorization'), 'Bearer test-token' if allowed else None)
                    redirected = HTTPRedirectHandler().redirect_request(
                        request, None, 302, 'Found', {}, 'https://example.org/redirect')
                    self.assertIsNone(redirected.get_header('Authorization'))

    def test_anonymous_request_still_rejects_oversized_response(self):
        with patch.dict('os.environ', clear=True), patch.object(VERIFY.urllib.request, 'urlopen') as open_url:
            response = open_url.return_value.__enter__.return_value
            response.status = 200
            response.read.return_value = b'123'
            with self.assertRaisesRegex(ValueError, 'size limit'):
                VERIFY.receive(VERIFY.RUN_API + '123', 2)
            self.assertIsNone(open_url.call_args.args[0].get_header('Authorization'))


class ProvenanceTests(unittest.TestCase):
    def setUp(self):
        self.sha = 'a' * 40
        self.run = {'head_sha': self.sha, 'status': 'completed', 'conclusion': 'success',
                    'path': '.github/workflows/publish-preview-0131.yml'}
        self.jobs = {'total_count': 4, 'jobs': [{'name': name, 'status': 'completed', 'conclusion': 'success'}
                     for name in ['build', 'windows', 'desktop', 'publish']]}

    def test_complete_candidate(self):
        VERIFY.validate_run(self.run, self.jobs, '0.13.1', self.sha)

    def test_wrong_source_or_workflow(self):
        for key, value in [('head_sha', 'b' * 40), ('path', '.github/workflows/other.yml')]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                VERIFY.validate_run(dict(self.run, **{key: value}), self.jobs, '0.13.1', self.sha)

    def test_failed_or_pending_gate(self):
        for value in ['failure', 'skipped', None]:
            jobs = copy.deepcopy(self.jobs)
            jobs['jobs'][1]['conclusion'] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                VERIFY.validate_run(self.run, jobs, '0.13.1', self.sha)

    def test_missing_or_truncated_inventory(self):
        for inventory in [{'total_count': 4, 'jobs': self.jobs['jobs'][:3]},
                          {'total_count': 3, 'jobs': self.jobs['jobs'][:3]}]:
            with self.subTest(inventory=inventory), self.assertRaises(ValueError):
                VERIFY.validate_run(self.run, inventory, '0.13.1', self.sha)


class DeliveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.installer = self.root / 'candidate.part'
        self.installer.write_bytes(b'fixture' * 150000)
        self.digest = hashlib.sha256(self.installer.read_bytes()).hexdigest()
        self.checksum = self.digest + '  LivingEarth3D-Setup-0.13.1.exe\n'
        self.sha = 'a' * 40
        self.build = 'Source: ' + self.sha + '\nFresh build\n'
        self.metadata = {name: 'b' * 64 for name in VERIFY.FILE_NAMES}
        for name in ['update.ps1', 'update-core.ps1']:
            content = ('fixture ' + name).encode()
            (self.root / name).write_bytes(content)
            self.metadata[name] = hashlib.sha256(content).hexdigest()

    def validate(self, **overrides):
        args = dict(installer=self.installer, checksum=self.checksum, build=self.build,
                    metadata=self.metadata, version='0.13.1', source_sha=self.sha, helpers=self.root)
        args.update(overrides)
        return VERIFY.validate_delivery(**args)

    def test_matching_delivery(self):
        self.assertEqual(self.validate(), self.digest)

    def test_tampered_installer(self):
        self.installer.write_bytes(b'changed' * 150000)
        with self.assertRaises(ValueError):
            self.validate()

    def test_wrong_checksum_filename(self):
        with self.assertRaises(ValueError):
            self.validate(checksum=self.checksum.replace('0.13.1.exe', '0.13.0.exe'))

    def test_wrong_build_source(self):
        with self.assertRaises(ValueError):
            self.validate(build=self.build.replace(self.sha, 'c' * 40))

    def test_extra_payload_or_changed_helper(self):
        with self.assertRaises(ValueError):
            self.validate(metadata=dict(self.metadata, unexpected='c' * 64))
        (self.root / 'update-core.ps1').write_bytes(b'changed trust source')
        with self.assertRaises(ValueError):
            self.validate()

    def test_tiny_installer(self):
        self.installer.write_bytes(b'not a package')
        with self.assertRaises(ValueError):
            self.validate()


if __name__ == '__main__':
    unittest.main()
