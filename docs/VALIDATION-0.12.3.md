# 0.12.3 candidate — Windows screensaver selection

Fixes the reported Windows settings action that did nothing and the absence of
Living Earth 3D from the selected screensaver list. The previous action called
`rundll32 desk.cpl,InstallScreenSaver` without visible error handling. The
per-user installer only placed the `.scr` next to the application.

The native helper now opens the documented `control.exe
desk.cpl,screensaver,@screensaver` entry point using an absolute system path.
The separate, explicit Use Living Earth 3D action registers the installed helper
in HKCU `Control Panel\Desktop\SCRNSAVE.EXE`, enables it through
`SystemParametersInfo`, and opens that same settings dialog. It keeps wait time
and resume-password preferences. This is a per-user action with no elevation;
enforced screensaver policies are not overwritten. Settings and selection
failures have visible in-app feedback. A Start menu shortcut offers the same
selection action. The launcher has the native display-name string resource.

Ordinary installer/automatic updates do not change a different chosen saver.
Uninstall unregisters only an exact matching selection for its own installation;
it leaves other screensaver selections alone. The saved Earth style still
controls the native preview and fullscreen saver.

Includes the updater status resilience work described in
UPDATER_STATUS_RESILIENCE.md, preserving the pinned key and four-file protocol.

## Candidate checks

Local import and interface suite pass (47 checks), native saver mode suite passes
with hosted preview flags (12 checks), and C++ launcher arguments pass (29 checks).
The changed native Windows launcher cross-compiles with warnings treated as
errors. PowerShell script parsing, 205 local status tests and the existing
16 security checks pass. A previous native-saver invocation without the required
host flags failed its mode assertions; rerunning with its required flags passes.

The release-specific workflow builds fresh application/launcher/installer bytes,
runs existing source/native render gates, verifies Windows upgrade/rollback,
tests status locks on PowerShell 5.1 and 7, opens the real Screen Saver Settings
dialog in a path containing spaces, checks the selected dropdown says Living
Earth 3D, checks activation and ownership-aware uninstall, and retains a settings
screenshot. Existing ten-minute preview/lifecycle and installed desktop gates
remain required. These results are pending, not established by Linux checks.

Publication requires all candidate gates, verified installer bytes, and signing
the exact metadata with the existing private release key outside git/CI. The
old general automatic workflow remains disabled. Physical Dell, mixed DPI,
monitor moves and sleep/wake tests remain field observations.
