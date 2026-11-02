# 0.25.0 validation — shuffled cinematic scenes

All candidate, native, Windows and independent public-delivery gates passed. Exact signed discovery bytes are promoted with the validated source; the separate production updater roundtrip is the final rollout gate.

## Frozen source and completed checks

Application source `b1d32aae5c81ffa80182be9d820ce20857a14d61`, tree `b5a6a6d377061726474a9e150ff609b535cbc8df`. Full four-job release run [41364004217](https://github.com/nortja/Living-earth-3d/actions/runs/41364004217) passed. There are 2,519 application assertions across 26 suites, seventeen native rendering suites, 39 native screensaver argument checks, ten Python provenance tests and existing PowerShell security/status/build gates. [Local checks](evidence/0.25.0/local-checks.json) and [release build](evidence/0.25.0/build-gate.json).

Shuffle tests cover two through eight views over repeated rounds, finite bounded indices, no adjacent repeats or duplicate visits within a round, manual-selection queue reset, default sequential order, persistence and restart. The choice pauses playback when changed; list mutation rebuilds the bounded queue. Existing fade interruption, temporary preferences, discovery-timer ownership and native-saver exclusion are retained.

## Installed Windows and delivery

- The real installed EXE toggled Shuffle through its UI, persisted the choice, faded between scenes and crossed a round boundary without repeating the current view. Actual 870×612 controls were visually reviewed; Moon zoom, clean PNG and pointer exit/return also passed. [Native cursor/scenes](evidence/0.25.0/native-cursor.json).
- A five-active-minute performance recording and seven exact framebuffers passed: 1920×1080, 2496×1664, 3440×1440, 3840×1080, 3840×2160, 5120×1440 and 5120×2880. [Desktop](evidence/0.25.0/windows-desktop.json).
- Legacy 0.5.2 and current 0.24.0 upgrades, handled-failure rollback, running-app deferral, actual Windows settings/timer readback, 605.1-second preview soak and native lifecycle checks passed. [Screensaver](evidence/0.25.0/windows-screensaver.json).
- Independent public verifier [41366552874](https://github.com/nortja/Living-earth-3d/actions/runs/41366552874) passed. Downloaded public bytes were separately hashed locally; helper hashes and the exact detached signature were independently checked against the updater's existing pinned key. [Public delivery](evidence/0.25.0/public-delivery.json) and [signature](evidence/0.25.0/signature.json).
- Installer: 73,321,570 bytes, SHA-256 `1f0320b198a8fd3a8819e02725bb2af9a14b8c6a3e36063538bb0f002d85d841`. Temporary signing key was removed immediately after verification.
- Final production authenticated staging/cancellation/normal-exit installation and four-file verification follows promotion.

Software-rendered Windows/Linux results do not establish physical Dell/DPI, mixed-monitor, idle/sleep or overnight behavior. Scene Library remains desktop only. Continuous video, global/Asia clouds and publisher Authenticode remain separate roadmap work.
