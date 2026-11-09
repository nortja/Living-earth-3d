# Monitor topology recording validation

Validated source: `491f121af818c1d2feae7817ff47dff4d0994ac4` on `validation/monitor-topology-history`.

The first attempt, [run 42674572037](https://github.com/nortja/Living-earth-3d/actions/runs/42674572037), found that the render harness assumed `res://dist` already existed. The source assertions passed, but both native capture jobs emitted PNG-save errors. The harness was corrected to create the evidence directory before rendering; no application behavior or release security code was changed.

The corrected [run 42674713931](https://github.com/nortja/Living-earth-3d/actions/runs/42674713931) passed:

- Godot 4.6.3 import on Linux and Windows.
- 61 headless performance/report assertions with zero failures on Linux and Windows.
- Linux native rendering and report checks at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880, zero failures.
- Windows native rendering/report checks at 870×612, zero failures, using checksum-pinned test-only Mesa software OpenGL.
- Evidence: [Linux screenshots/logs](https://github.com/nortja/Living-earth-3d/actions/runs/42674713931/artifacts/13698978658) and [Windows screenshot/logs](https://github.com/nortja/Living-earth-3d/actions/runs/42674713931/artifacts/13699377979).

The headless assertions cover baseline-unavailable semantics, active-time offsets, monitor add/move detection, duplicate suppression, deep-copy isolation, the 32-event bound/overflow flag, reset between recordings, and additive schema-1 JSON export. The native renderer confirms the captured baseline matches the real display server's monitor inventory.

This is targeted source/native validation, not a fresh installer, Windows install/rollback, screensaver lifecycle soak, public-download/signature or production-updater release run. The application version and published 0.25.1 feed remain unchanged. Software-rendered CI does not test the physical Dell, mixed-DPI monitor moves, GPU frame times, sleep/wake or overnight behavior.
