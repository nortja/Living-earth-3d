# 0.12.1 validation

Candidate, 2026-10-20. Production remains 0.9.0 until authenticated promotion. This combined candidate includes the camera, local performance, photograph and history improvements from the validated 0.10.0 and 0.11.0 candidates.

732 local behavior/layout/integrity checks pass, including 54 weather-layer checks. Six native viewport sizes through 5K pass for the weather controls, accessible legend badge and point selection. An actual sixteen-point Open-Meteo response (7,720 bytes) was retrieved and decoded; its model estimate timestamps were retained separately from retrieval. The actual data rendered successfully at all six sizes. Synthetic test screenshots are explicitly labelled.

The layer is not constructed in native saver mode. In-app preview hides it and cancels requests; resume does not fetch. Stale data is grey, expired/future data is rejected/hidden, an invalid batch cannot shift place names, cached points begin hidden and cancelled responses cannot replace the cache. A ray/sphere occlusion check prevents backside points from intercepting input.

Release gates: fresh export; all source tests and native UI renders; actual Windows upgrades/rollback from 0.5.2 and deployed 0.9.0; a ten-minute actual current-package embedded preview/render/resize/memory soak and lifecycle notifications; a separate installed desktop test that loads the actual exported photographs/model layer and records five active minutes of display performance. Earlier frozen 0.10.0/0.11.0 foundation candidates also run one-hour Windows soaks, and 0.10.0 runs a one-hour Linux renderer/style soak. Their evidence is identified separately rather than presented as an exact one-hour run of 0.12.1.

Physical Dell GPU/DPI, multiple-monitor hardware, real lock/sleep/resume and fan/power behavior remain field checks. Simulated notifications and software-rendered CI do not establish those results. The four-file authenticated updater and pinned trust key are unchanged. The old general failing workflow remains disabled.

The exported desktop test uses its own compiled --validate-packaged-desktop entry point and isolated preferences with background updates disabled, rather than the app’s separate --validate-display mode. The report explicitly marks the Godot engine-memory counter unavailable in release builds and exports null values instead of a false zero. OS private memory is measured independently by the Windows screensaver soak. Native renderer implementation is unchanged; 0.12.0 also has a separate thirty-minute current-renderer soak.

## Foundation endurance evidence

- 0.10.0 Windows run [39525423238](https://github.com/nortja/Living-earth-3d/actions/runs/39525423238) passed its real 60-minute embedded preview soak, repeated Earth-pixel checks, 320×200/580×330 resizes, true child parenting and OS private-memory bound, followed by controller/parent cleanup, keyboard exit and simulated display/suspend/session-lock notifications. Software-rendered on a disposable one-monitor VM.
- 0.10.0 Linux run [39526379944](https://github.com/nortja/Living-earth-3d/actions/runs/39526379944) passed 3,609.493 seconds across six styles with zero failures, 15 FPS preview cap, baseline 48,564,730 and peak 48,699,088 engine-tracked bytes. This debug engine counter is distinct from complete process memory and from the unavailable release counter. Node count stayed 430–431. Native saver UI remained hidden, audio silent and public-data requests inactive.

The interrupted local Linux attempt is not counted as a completed endurance run.

## Final package source/build evidence

Initial source commit `833d370f77c3bb6dbd68267d075786d336d52bd1`, tree `e14e49316580472733bade44dbcc75a2da0b4674`; [initial release run 39532316743](https://github.com/nortja/Living-earth-3d/actions/runs/39532316743). Its build job passed all fourteen behavior suites (732 checks), updater security/build scripts, 25 native launcher-argument checks, generated Godot launch commands, fresh export, seven-size icon checks and installer packaging. Eight native graphics suites passed, including all six viewport sizes for weather/discovery/report/arrival layouts, plus separate native preview/fullscreen budget and isolation tests.

The external-script desktop check timed out without executing its evidence steps, so publication was blocked. It was replaced with a compiled opt-in validation module, invoked through the same explicit app mechanism as the existing display validator. The validator uses isolated preferences with background updates disabled, loads the actual exported resources and writes progress evidence. It never runs during ordinary app/screensaver use.

Final frozen binary source: commit `5bc61593bb230e75be00f98267bc936357b848c7`, tree `2b22fe0721a5045a0c01979568cdcb836f73ba01`; [release run 39534019102](https://github.com/nortja/Living-earth-3d/actions/runs/39534019102). All 732 local checks pass again after this change. Only release documentation and authenticated discovery metadata change after this final binary source; private signing material never enters git or CI.

The 0.11.0 photograph/history foundation also passed its real sixty-minute Windows embedded preview soak and lifecycle tests in [39527917531](https://github.com/nortja/Living-earth-3d/actions/runs/39527917531). Its unsigned candidate installer was published for verification, but its features are delivered to the authenticated production channel together in 0.12.1.

The corrected compiled validator passed on the actual installed Windows 0.12.1 package in run 39534019102: all twelve exported photographs, sixteen model points, preview isolation and a five-active-minute local recording/export. This candidate was superseded by 0.12.2 before authenticated promotion, to normalize an unknown/non-finite display refresh discovered in native rehearsal.

The corrected 0.12.1 package also passed its ten-minute Windows native preview/private-memory/lifecycle gate and was published as an unsigned candidate. Its authenticated feed was not promoted; 0.12.2 supersedes it.
