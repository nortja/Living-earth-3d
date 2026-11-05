"""CI-only API authentication; public installer downloads remain unauthenticated."""
import importlib.util
import os
from pathlib import Path
import urllib.request
spec = importlib.util.spec_from_file_location("verifier", Path(__file__).resolve().parents[1] / "packaging/windows/verify_release_download.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
original_receive = module.receive
def receive(url, maximum):
    if not url.startswith("https://api.github.com/repos/nortja/Living-earth-3d/actions/runs/"):
        return original_receive(url, maximum)
    request = urllib.request.Request(url, headers={"User-Agent": "LivingEarth3D-release-verifier", "Authorization": "Bearer " + os.environ["GH_TOKEN"]})
    with urllib.request.urlopen(request, timeout=90) as response:
        if response.status != 200:
            raise ValueError("Unexpected authenticated API status")
        data = response.read(maximum + 1)
    if len(data) > maximum:
        raise ValueError("API response exceeds size limit")
    return data
module.receive = receive
module.main()
