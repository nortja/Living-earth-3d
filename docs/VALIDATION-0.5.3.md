# 0.5.3 automatic-update validation

Local Godot 4.6.3 Linux headless checks: Explorer 56, interface/data 39, ambient audio 6, interface size 187, automatic-update preferences/screensaver safety 6; all passed. PowerShell 7 security checks: 16 passed. Build/update/Windows test scripts parsed successfully and the native icon helper compiled without executing Windows APIs on Linux.

The security tests cover valid signatures, tampered metadata/signatures, wrong project origin/channel/product/protocol/version/size/hash, extra/missing files, installed-file modifications and rejection of a foreign signing key. Windows installation/rollback checks are required by the dedicated release workflow before it can publish the installer. Field tests for visible-app restart and physical hardware remain separate.

Release metadata is signed only after the public installer is re-downloaded and verified. The private release key remains outside git and CI; only its public key is included in the installed core. Backups restore known program files and version metadata on handled installation/verification failure. No guarantee against power loss or abrupt termination during installation is claimed.
