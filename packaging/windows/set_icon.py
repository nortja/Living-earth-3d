"""Cross-build helper. Requires LIEF 1.0; Windows builds use set-icon.ps1."""
import argparse
import struct
from pathlib import Path

import lief


def embed_icon(executable: Path, icon: Path) -> None:
    data = executable.read_bytes()
    if data[-4:] == b'GDPC':
        raise ValueError('Patch the clean export template before Godot appends its pack')
    binary = lief.PE.parse(list(data))
    root = binary.resources
    for resource_id in (3, 14):
        root.delete_child(resource_id)
    icons = root.add_child(lief.PE.ResourceDirectory(3))
    groups = root.add_child(lief.PE.ResourceDirectory(14))
    group = lief.PE.ResourceDirectory()
    group.name = 'GODOT_ICON'
    group = groups.add_child(group)
    raw = icon.read_bytes()
    reserved, kind, count = struct.unpack_from('<HHH', raw)
    if reserved or kind != 1 or not count:
        raise ValueError('Invalid ICO')
    group_data = bytearray(raw[:6])
    for index in range(count):
        offset = 6 + index * 16
        width, height, colors, zero, planes, bits, length, position = struct.unpack_from('<BBBBHHII', raw, offset)
        content = raw[position:position + length]
        if len(content) != length:
            raise ValueError('Truncated icon image')
        entry = icons.add_child(lief.PE.ResourceDirectory(index + 1))
        image = lief.PE.ResourceData(list(content))
        image.id = 1033
        entry.add_child(image)
        group_data += struct.pack('<BBBBHHIH', width, height, colors, zero, planes, bits, length, index + 1)
    group_resource = lief.PE.ResourceData(list(group_data))
    group_resource.id = 1033
    group.add_child(group_resource)
    config = lief.PE.Builder.config_t()
    config.resources = True
    config.overlay = False
    builder = lief.PE.Builder(binary, config)
    builder.build()
    executable.write_bytes(builder.raw_bytes())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('executable', type=Path)
    parser.add_argument('icon', type=Path)
    args = parser.parse_args()
    embed_icon(args.executable, args.icon)
