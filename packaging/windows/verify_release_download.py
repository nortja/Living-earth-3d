"""Verify a completed candidate run and its public delivery before release signing.

Read-only GitHub access; never executes the installer or receives a signing key.
"""
import argparse
import hashlib
import json
import re
import urllib.request
from pathlib import Path

REPOSITORY = 'nortja/Living-earth-3d'
FILE_NAMES = {'LivingEarth3D.exe', 'LivingEarth3D.scr', 'update.ps1', 'update-core.ps1'}


def validate_run(run, jobs, version, source_sha):
    expected_path = f'.github/workflows/publish-preview-{version.replace(".", "")}.yml'
    if (run.get('head_sha') != source_sha or run.get('status') != 'completed'
            or run.get('conclusion') != 'success' or run.get('path') != expected_path):
        raise ValueError('Candidate source, workflow or completed result does not match')
    rows = jobs.get('jobs', [])
    if jobs.get('total_count') != len(rows) or not rows:
        raise ValueError('Incomplete candidate job inventory')
    if not {'build', 'windows', 'desktop', 'publish'}.issubset({row.get('name') for row in rows}):
        raise ValueError('Required build/Windows/desktop/publication gates are absent')
    if any(row.get('status') != 'completed' or row.get('conclusion') != 'success' for row in rows):
        raise ValueError('Candidate contains an incomplete or unsuccessful gate')


def validate_delivery(installer, checksum, build, metadata, version, source_sha, helpers):
    expected_name = f'LivingEarth3D-Setup-{version}.exe'
    parts = checksum.split()
    if (len(parts) != 2 or not re.fullmatch('[0-9a-f]{64}', parts[0])
            or parts[1].lstrip('*') != expected_name):
        raise ValueError('Unexpected installer checksum document')
    if not 1_000_000 <= installer.stat().st_size <= 314_572_800:
        raise ValueError('Unsupported installer size')
    with installer.open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
    if digest != parts[0]:
        raise ValueError('Public installer checksum mismatch')
    sources = re.findall(r'^Source: ([0-9a-f]{40})$', build, re.MULTILINE)
    if sources != [source_sha]:
        raise ValueError('Public BUILD source differs from the validated candidate')
    if (not isinstance(metadata, dict) or set(metadata) != FILE_NAMES
            or not all(isinstance(value, str) and re.fullmatch('[0-9a-f]{64}', value)
                       for value in metadata.values())):
        raise ValueError('Invalid installed-file metadata')
    for name in ['update.ps1', 'update-core.ps1']:
        if hashlib.sha256((helpers / name).read_bytes()).hexdigest() != metadata[name]:
            raise ValueError(f'Published {name} differs from the local trust/helper source')
    return digest


def receive(url, maximum):
    request = urllib.request.Request(url, headers={'User-Agent': 'LivingEarth3D-release-verifier'})
    with urllib.request.urlopen(request, timeout=90) as response:
        if response.status != 200:
            raise ValueError('Public resource returned an unexpected HTTP status')
        body = response.read(maximum + 1)
    if len(body) > maximum:
        raise ValueError('Public resource exceeds the expected size limit')
    return body


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', required=True)
    parser.add_argument('--source-sha', required=True)
    parser.add_argument('--run-id', type=int, required=True)
    parser.add_argument('--output-directory', type=Path, required=True)
    args = parser.parse_args()
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', args.version):
        raise ValueError('Invalid version')
    if not re.fullmatch('[0-9a-f]{40}', args.source_sha) or args.run_id <= 0:
        raise ValueError('Invalid source SHA or run ID')
    api = f'https://api.github.com/repos/{REPOSITORY}/actions/runs/{args.run_id}'
    run = json.loads(receive(api, 262144))
    jobs = json.loads(receive(api + '/jobs?filter=latest&per_page=100', 1048576))
    validate_run(run, jobs, args.version, args.source_sha)
    folder = args.output_directory
    folder.mkdir(parents=True, exist_ok=True)
    name = f'LivingEarth3D-Setup-{args.version}.exe'
    raw = f'https://raw.githubusercontent.com/{REPOSITORY}/downloads/windows-{args.version}/'
    # Verify the exact URL that sign_release.py will put in the trusted manifest.
    installer_url = f'https://github.com/{REPOSITORY}/raw/refs/heads/downloads/windows-{args.version}/{name}'
    installer = folder / name
    partial = folder / (name + '.part')
    try:
        partial.write_bytes(receive(installer_url, 314572800))
        checksum = receive(raw + name + '.sha256', 1024).decode('utf-8')
        build = receive(raw + 'BUILD.txt', 8192).decode('utf-8')
        metadata_raw = receive(raw + 'payload-hashes.json', 65536)
        metadata = json.loads(metadata_raw)
        digest = validate_delivery(partial, checksum, build, metadata, args.version,
                                   args.source_sha, Path(__file__).parent)
        partial.replace(installer)
    finally:
        partial.unlink(missing_ok=True)
    (folder / (name + '.sha256')).write_text(checksum)
    (folder / 'BUILD.txt').write_text(build)
    (folder / 'payload-hashes.json').write_bytes(metadata_raw)
    print(json.dumps({'version': args.version, 'source_sha': args.source_sha,
                      'run_url': f'https://github.com/{REPOSITORY}/actions/runs/{args.run_id}',
                      'size': installer.stat().st_size, 'sha256': digest,
                      'installer': str(installer), 'payload_metadata': str(folder / 'payload-hashes.json')}, indent=2))


if __name__ == '__main__':
    main()
