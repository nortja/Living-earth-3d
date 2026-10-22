# 0.12.3 release validation

Preview released 2026-10-21 (Pacific). Fixes the reported Windows settings action
that did nothing and the absence of Living Earth 3D from the selected saver list.
The old action called `rundll32 desk.cpl,InstallScreenSaver` without visible error
handling; installation only placed the `.scr` beside the application.

## Behavior

The native helper opens the documented `control.exe desk.cpl,screensaver,@screensaver` entry point through an absolute system path.
The separate Use Living Earth 3D action registers the installed full path in
HKCU `Control Panel\Desktop\SCRNSAVE.EXE`, enables the saver using
`SystemParametersInfo`, and opens that dialog. Wait time and resume-password
preferences are retained. Selection is per-user and requires no elevation;
forced screensaver policy is respected. The app leaves fullscreen so settings
can be seen, and reports selection/launch failures. A Start menu shortcut offers
the same selection action. The launcher has a native display-name string.

Ordinary upgrades preserve the chosen saver. Uninstall unregisters only an exact
matching selection for that installation. The saved Earth style controls native
preview and fullscreen views. Updater status replacement is now atomic, with
bounded reader-lock retries and advisory failures; the pinned public key,
four-file manifest and signature/hash/running-app checks are preserved.
The original 0.12.2 production filesystem deferral cause remains unconfirmed.

## Frozen build and source checks

Binary source: commit `484bc4983a7f33223d07a60d07ee0ef96032bb84`, tree
`fc432be10d06a60ba03b5a0c8e9d611c483c1c57`.
[Build run 39712920710](https://github.com/nortja/Living-earth-3d/actions/runs/39712920710),
job 119608338607 passed all fourteen behavior/layout suites (735 checks),
29 launcher-argument checks, security/parser/icon/resource checks, fresh native
launcher/application/installer builds, native layouts through 5K, and native
preview/fullscreen budget/isolation tests. The launcher cross-compiles with
warnings treated as errors. Local hosted preview/fullscreen suites also pass.

The original run's Windows settings harness stopped before opening the dialog:
`Get-ItemPropertyValue` treats an absent SCRNSAVE.EXE property as a terminating
error on Windows PowerShell 5.1. This is not counted as a settings pass. The
corrected harness reads the optional value through the registry API. Only test
and validation-workflow files changed after the frozen binary source; application
and installer bytes were reused without rebuilding or relabeling.

## Actual installed Windows evidence

[Validation/delivery run 39714004462](https://github.com/nortja/Living-earth-3d/actions/runs/39714004462),
source `dd7b3825463b2aaebef7284c69148d298e3f0a97`, Windows job 119611692413 passed:

- Windows PowerShell 5.1 and PowerShell 7: 211 status and 16 signature/hash checks
  each, including persistent delete-sharing contention and transient-lock recovery.
- Real upgrades/handled-failure rollback from 0.5.2 and 0.9.0, installed-file hashes,
  preference preservation, versioned icon, running-app deferral and uninstall.
- Actual Screen Saver Settings opening in an install path containing spaces,
  read-only settings preserving selection, the dropdown selecting Living Earth 3D,
  active setting, and ownership-aware unregister/uninstall. The retained settings
  screenshot was visually inspected. Snapshot/restore keeps the VM's original
  screensaver preferences.
- Actual embedded Earth rendering, resize/parenting/input isolation, and a
  605.2-second preview/private-memory soak; independent previews, parent/controller
  cleanup, active-saver install deferral, one-monitor fullscreen and keyboard exit.
- Simulated display-change, suspend and session-lock cleanup. Physical sleep,
  mixed DPI and multiple-monitor behavior remain field observations.

The independent installed desktop job 119610749914 from the frozen build run also
passed: twelve exported photos, sixteen model points and saver isolation, plus
300.000043 active seconds / 17,337 frames of local report recording, zero failures.
The software VM mean interval was 17.304 ms, with unavailable release engine-memory
counters represented as null; this does not establish physical Dell performance.
The delivery job explicitly checks this independent desktop result and the frozen
BUILD source before publishing the reused installer.

## Publication and trust

Published `LivingEarth3D-Setup-0.12.3.exe`: 51,344,236 bytes, SHA-256
`4896552a712d39957d2725385d14cb85fef2c004a2705fee6887e8350c6895a8`.
The public refs/heads installer and checksum were downloaded and verified, its
BUILD source matched the frozen commit, and both helper hashes matched source.
Exact release metadata was signed outside git/CI with the existing private key,
then independently verified with the installed public key. The temporary private
copy was removed. Installer Windows publisher signing remains separate and absent.

Source was merged as `f50436e5d5be685245d51fc6109ae9b8a0a02e4d`. All three discovery
files were atomically promoted by `9bebb6fc3022c768dbb096ae44a758cac91677ad`.
No-query production application.json, application.sig and preview.json bytes each
matched the independently verified local files. The production download,
cancellation and normal-exit update roundtrip also passed; results follow below. The old general automatic installer workflow remains disabled.

## Production automatic-update roundtrip

[Live validation run 39715502588](https://github.com/nortja/Living-earth-3d/actions/runs/39715502588),
Windows job 119616510778, passed on its first attempt: the live production signature
and installer download stage while the old app remains open; cancellation leaves
it unchanged; resuming installs after normal exit; all four installed-file hashes
match the signed 0.12.3 manifest; the intentionally closed app stays closed and
fixture uninstall/cleanup succeeds. No private key was sent to this runner.
