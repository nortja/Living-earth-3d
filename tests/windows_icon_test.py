"""Verify native icon image payloads and the embedded Godot pack without running Windows."""
import argparse
import struct
from pathlib import Path

import pefile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('executable', type=Path)
parser.add_argument('--icon', type=Path, default=Path('assets/icon.ico'))
parser.add_argument('--installer', action='store_true')
args = parser.parse_args()
pe = pefile.PE(str(args.executable))
resources = {entry.id: entry for entry in pe.DIRECTORY_ENTRY_RESOURCE.entries}
groups = resources[14].directory.entries
assert groups, 'No Windows group icon'
if not args.installer:
    assert str(groups[0].name) == 'GODOT_ICON', 'Runtime icon resource must replace the Godot default'
entry = groups[0].directory.entries[0].data.struct
group = pe.get_data(entry.OffsetToData, entry.Size)
raw = args.icon.read_bytes()
count = struct.unpack_from('<H', raw, 4)[0]
assert struct.unpack_from('<H', group, 4)[0] == count
images = {entry.id: entry for entry in resources[3].directory.entries}
for index in range(count):
    source_size, source_offset = struct.unpack_from('<II', raw, 6 + index * 16 + 8)
    resource_id = struct.unpack_from('<H', group, 6 + index * 14 + 12)[0]
    data = images[resource_id].directory.entries[0].data.struct
    assert pe.get_data(data.OffsetToData, data.Size) == raw[source_offset:source_offset + source_size], f'Icon image {index} differs'
if not args.installer:
    data = args.executable.read_bytes()
    size, magic = struct.unpack_from('<QI', data, len(data) - 12)
    assert magic == 0x43504447 and data[len(data) - 12 - size:][:4] == b'GDPC', 'Embedded project missing'
print(f'PASS: {count} native icon sizes match artwork' + ('' if args.installer else '; embedded project intact'))
