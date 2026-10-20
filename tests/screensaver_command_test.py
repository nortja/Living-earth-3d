"""Exercise the launcher's actual generated argument vector against the pinned Godot CLI."""
import argparse
from pathlib import Path
import subprocess,tempfile
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('argument_test');p.add_argument('godot');a=p.parse_args()
with tempfile.TemporaryDirectory(prefix='earth-command-') as temp:
    Path(temp,'project.godot').write_text('config_version=5\n[application]\nconfig/name="Launcher command contract"\n')
    for width,height,mode in [(320,200,'preview'),(5120,1440,'full')]:
        args=subprocess.check_output([a.argument_test,'--engine-args',str(width),str(height),mode],text=True).splitlines()
        result=subprocess.run([a.godot,'--headless','--editor','--quit','--path',temp]+args,capture_output=True,text=True,timeout=30)
        log=result.stdout+result.stderr
        assert result.returncode==0 and 'Invalid resolution' not in log and 'ERROR:' not in log,log
        print(f'PASS: Godot accepts generated {mode} command at {width}x{height}')
