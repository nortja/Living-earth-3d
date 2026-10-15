#!/usr/bin/env bash
set -euo pipefail
version=4.6.3
if [[ $(godot --version) != "$version.stable."* ]]; then
  echo "This build requires Godot $version stable." >&2
  exit 1
fi
template_dir="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$version.stable"
if [[ -s "$template_dir/windows_release_x86_64.exe" && -s "$template_dir/windows_debug_x86_64.exe" ]]; then
  exit 0
fi
template_tmp=$(mktemp -d)
trap 'rm -rf "$template_tmp"' EXIT
archive=Godot_v4.6.3-stable_export_templates.tpz
curl --fail --location --retry 2 "https://github.com/godotengine/godot-builds/releases/download/$version-stable/$archive" -o "$template_tmp/$archive"
# Official SHA512-SUMS.txt from the same 4.6.3-stable Godot release.
(cd "$template_tmp" && printf '%s  %s\n' da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68 "$archive" | sha512sum --check -)
python3 - "$template_tmp/$archive" "$template_dir" <<'PY'
import sys
from pathlib import Path
from zipfile import ZipFile
output = Path(sys.argv[2])
output.mkdir(parents=True, exist_ok=True)
with ZipFile(sys.argv[1]) as archive:
    for name in ('windows_release_x86_64.exe', 'windows_debug_x86_64.exe', 'version.txt'):
        (output / name).write_bytes(archive.read('templates/' + name))
PY
