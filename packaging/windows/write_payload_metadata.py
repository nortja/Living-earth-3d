"""Record hashes that must match after a verified installer runs."""
import argparse
import hashlib
import json
from pathlib import Path
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--application', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).parent
files = {'LivingEarth3D.exe': a.application, 'LivingEarth3D.scr': a.application,
         'update.ps1': root/'update.ps1', 'update-core.ps1': root/'update-core.ps1'}
a.output.write_text(json.dumps({name: hashlib.sha256(path.read_bytes()).hexdigest() for name,path in files.items()},sort_keys=True,indent=2)+'\n')
