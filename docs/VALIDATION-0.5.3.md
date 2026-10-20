# 0.5.3 automatic-update validation

Local Godot 4.6.3 Linux headless checks: Explorer 56, interface/data 39, ambient audio 6, interface size 187, automatic-update preferences/screensaver safety 6; all passed. PowerShell 7 security checks: 16 passed. Build/update/Windows test scripts parsed successfully and the native icon helper compiled without executing Windows APIs on Linux.

The security tests cover valid signatures, tampered metadata/signatures, wrong project origin/channel/product/protocol/version/size/hash, extra/missing files, installed-file modifications and rejection of a foreign signing key. Windows installation/rollback checks are required by the dedicated release workflow before it can publish the installer. Field tests for visible-app restart and physical hardware remain separate.

Release metadata is signed only after the public installer is re-downloaded and verified. The private release key remains outside git and CI; only its public key is included in the installed core. Backups restore known program files and version metadata on handled installation/verification failure. No guarantee against power loss or abrupt termination during installation is claimed.

## Executed on Windows

GitHub Actions run 39463327803 completed successfully on Windows PowerShell 5.1: all 16 signature/security checks passed; the real NSIS installer silently upgraded a 0.5.2 installation at a path containing spaces; an intentionally wrong installed-file hash triggered restoration of the old application and registry version; user-data sentinel remained intact; an active app process deferred replacement; uninstall succeeded. These are actual Windows installer checks, not GPU/display evidence.

Published installer SHA-256: 86788ac0104fa3c2cecdbfc77dba02b68bb38c701f3a74e2ba4c74f50ea6d1ff. The public installer was downloaded again, matched its published checksum, and its helper hashes matched source. The production-key signature created by the Python signer was verified by PowerShell before feed publication. A separate live-helper workflow exercises the public signed feed and normal-exit behavior.
