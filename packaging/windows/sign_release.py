"""Sign an already-built release. Private keys must never enter git or CI logs."""
import argparse
import base64
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key', type=Path, required=True)
    parser.add_argument('--installer', type=Path, required=True)
    parser.add_argument('--payload-metadata', type=Path, required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--output-directory', type=Path, required=True)
    args = parser.parse_args()
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', args.version):
        raise ValueError('Invalid version')
    if args.installer.name != f'LivingEarth3D-Setup-{args.version}.exe':
        raise ValueError('Installer name and version disagree')
    key = serialization.load_pem_private_key(args.key.read_bytes(), password=None)
    public_xml = re.search(r"\$script:UpdatePublicKey = '(.*?)'", Path(__file__).with_name('update-core.ps1').read_text())[1]
    root = ET.fromstring(public_xml)
    numbers = key.public_key().public_numbers()
    if numbers.n != int.from_bytes(base64.b64decode(root.findtext('Modulus')), 'big') or numbers.e != int.from_bytes(base64.b64decode(root.findtext('Exponent')), 'big'):
        raise ValueError('Signing key does not match the installed trust key')
    files = json.loads(args.payload_metadata.read_text())
    if set(files) != {'LivingEarth3D.exe', 'LivingEarth3D.scr', 'update.ps1', 'update-core.ps1'} or not all(re.fullmatch('[0-9a-f]{64}', digest) for digest in files.values()):
        raise ValueError('Invalid installed-file hashes')
    data = args.installer.read_bytes()
    if not 1000000 <= len(data) <= 314572800:
        raise ValueError('Unsupported installer size')
    manifest = dict(product='LivingEarth3D', channel='preview', protocol=1, version=args.version,
                    installer_url=f'https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-{args.version}/LivingEarth3D-Setup-{args.version}.exe',
                    sha256=hashlib.sha256(data).hexdigest(), size=len(data), files=files)
    raw = (json.dumps(manifest, sort_keys=True, indent=2) + '\n').encode()
    signature = key.sign(raw, padding.PKCS1v15(), hashes.SHA256())
    key.public_key().verify(signature, raw, padding.PKCS1v15(), hashes.SHA256())
    args.output_directory.mkdir(parents=True, exist_ok=True)
    (args.output_directory / 'application.json').write_bytes(raw)
    (args.output_directory / 'application.sig').write_text(base64.b64encode(signature).decode() + '\n')
    print(f'Signed version {args.version}; SHA-256 {manifest["sha256"]}')


if __name__ == '__main__':
    main()
