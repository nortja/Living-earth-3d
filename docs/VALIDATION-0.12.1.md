# 0.12.1 validation

Candidate, 2026-10-20. Production remains 0.9.0 until authenticated promotion. This combined candidate includes the camera, local performance, photograph and history improvements from the validated 0.10.0 and 0.11.0 candidates.

732 local behavior/layout/integrity checks pass, including 54 weather-layer checks. Six native viewport sizes through 5K pass for the weather controls, accessible legend badge and point selection. An actual sixteen-point Open-Meteo response (7,720 bytes) was retrieved and decoded; its model estimate timestamps were retained separately from retrieval. The actual data rendered successfully at all six sizes. Synthetic test screenshots are explicitly labelled.

The layer is not constructed in native saver mode. In-app preview hides it and cancels requests; resume does not fetch. Stale data is grey, expired/future data is rejected/hidden, an invalid batch cannot shift place names, cached points begin hidden and cancelled responses cannot replace the cache. A ray/sphere occlusion check prevents backside points from intercepting input.

Release gates: fresh export; all source tests and native UI renders; actual Windows upgrades/rollback from 0.5.2 and deployed 0.9.0; a ten-minute actual current-package embedded preview/render/resize/memory soak and lifecycle notifications; a separate installed desktop test that loads the actual exported photographs/model layer and records five active minutes of display performance. Earlier frozen 0.10.0/0.11.0 foundation candidates also run one-hour Windows soaks, and 0.10.0 runs a one-hour Linux renderer/style soak. Their evidence is identified separately rather than presented as an exact one-hour run of 0.12.0.

Physical Dell GPU/DPI, multiple-monitor hardware, real lock/sleep/resume and fan/power behavior remain field checks. Simulated notifications and software-rendered CI do not establish those results. The four-file authenticated updater and pinned trust key are unchanged. The old general failing workflow remains disabled.

The exported desktop test uses its own preferences with background updates disabled, rather than the app’s separate --validate-display mode. The report explicitly marks the Godot engine-memory counter unavailable in release builds and exports null values instead of a false zero. OS private memory is measured independently by the Windows screensaver soak. Native renderer implementation is unchanged; 0.12.0 also has a separate thirty-minute current-renderer soak.
