"""Build the dependency-free native Windows screensaver launcher with MinGW-w64."""
import argparse
import subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler', default='x86_64-w64-mingw32-g++')
p.add_argument('--windres', default='x86_64-w64-mingw32-windres')
p.add_argument('--output',type=Path,required=True)
a=p.parse_args()
root=Path(__file__).resolve().parents[2]
a.output.parent.mkdir(parents=True,exist_ok=True)
rc=a.output.parent/'screensaver.rc'
obj=a.output.parent/'screensaver-resource.o'
icon=(root/'assets/icon.ico').as_posix()
rc.write_text(f'1 ICON "{icon}"\n')
subprocess.run([a.windres,str(rc),'-O','coff','-o',str(obj)],check=True)
subprocess.run([a.compiler,'-std=c++17','-O2','-Wall','-Wextra','-Werror','-municode','-mwindows','-static','-static-libgcc','-static-libstdc++',str(root/'packaging/windows/screensaver.cpp'),str(obj),'-o',str(a.output),'-luser32','-lgdi32','-lshell32','-lwtsapi32'],check=True)
print(f'Native screensaver ready: {a.output}')
