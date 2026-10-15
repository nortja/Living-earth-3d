#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tools/install_windows_templates.sh
mkdir -p build/windows
staging=$(mktemp -d build/.windows-export.XXXXXX)
trap 'rm -rf "$staging"' EXIT
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/explorer_smoke.gd
godot --headless --path . --export-release 'Windows Desktop' "$PWD/$staging/LivingEarth3D.exe"
python3 - "$staging/LivingEarth3D.exe" <<'PYVERIFY'
import struct, sys
from pathlib import Path
import hashlib
binary = Path(sys.argv[1]).read_bytes()
assert binary[:2] == b'MZ', 'Missing Windows executable'
pe_offset = struct.unpack_from('<I', binary, 0x3c)[0]
assert binary[pe_offset:pe_offset + 4] == b'PE\0\0', 'Invalid PE header'
assert struct.unpack_from('<H', binary, pe_offset + 4)[0] == 0x8664, 'Not x86-64'
assert binary[-4:] == b'GDPC', 'Embedded Godot game pack is missing'
print('Verified Windows x86-64 executable and embedded game pack.')
PYVERIFY
cp "$staging/LivingEarth3D.exe" build/windows/LivingEarth3D.exe
cp assets/ATTRIBUTION.md build/windows/ATTRIBUTION.md
cp docs/WINDOWS_README.txt build/windows/README.txt
python3 - <<'PY'
from zipfile import ZipFile, ZIP_DEFLATED
from pathlib import Path
import hashlib
folder = Path('build/windows')
with ZipFile('build/LivingEarth3D-windows-x86_64.zip', 'w', ZIP_DEFLATED) as archive:
    for name in ('LivingEarth3D.exe', 'ATTRIBUTION.md', 'README.txt'):
        archive.write(folder / name, 'LivingEarth3D/' + name)
zip_path = Path('build/LivingEarth3D-windows-x86_64.zip')
with ZipFile(zip_path) as archive:
    assert archive.testzip() is None, 'ZIP integrity failure'
checksum = hashlib.sha256(zip_path.read_bytes()).hexdigest()
Path('build/SHA256SUMS.txt').write_text(f'{checksum}  {zip_path.name}\n')
print(f'Created {zip_path} and build/SHA256SUMS.txt')
PY
