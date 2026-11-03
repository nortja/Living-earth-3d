# Scene interruption reliability — unreleased source

Reviewed November 3, 2026. [PR #2](https://github.com/nortja/Living-earth-3d/pull/2) is merged into main; it is not distributed through automatic updates.

Manual Next starts a fade even when timed playback is paused. Previously `_process` returned when `playing` was false, bypassing modal/minimize/screensaver interruption handling. The guard now handles both playback and a running transition, then leaves timed advancement disabled when playback is paused. Cancellation kills the delayed callback and restores brightness without rewriting preferences.

The source regression reproduced two failures before the fix and passed all 673 Scene Library assertions afterward. The native regression opens a file dialog during manual Next, confirms the original composition/defaults remain, then closes the dialog and confirms a subsequent Next completes.

## Completed validation

Exact source `8a98cea6cf6adfaa05e5b27471de683054dd3962` passed all three jobs in [run 41485285747](https://github.com/nortja/Living-earth-3d/actions/runs/41485285747) on November 2. Main merge `8e5fbddd654292ca91aaa3a82abcd2c3031d2f02` has the identical tree. [Evidence summary](evidence/scene-interruption-2026-11-03.json).

- 2,521 application assertions across 26 suites; ten Python provenance tests; 39 screensaver argument checks; export/resource/icon/installer and PowerShell security/status/build gates.
- Seventeen native Linux rendering suites, including the dialog interruption regression, plus native saver preview/fullscreen isolation.
- Windows upgrades from 0.5.2 and published 0.24.0, handled-failure rollback, active-app deferral, 211 status checks and 16 security checks under each PowerShell runtime, and actual screensaver settings/timer checks.
- Installed Windows desktop/clean-view/pointer/export/scenes checks, 300.015 active seconds of recording, and exact 1920×1080, 2496×1664, 3440×1440, 3840×1080, 3840×2160, 5120×1440 and 5120×2880 framebuffers.
- A 605.1-second native preview soak and simulated Windows lifecycle checks.

These are hosted software-rendered checks. The new modal-specific interaction runs in native Linux; installed Windows provides regression coverage rather than a new modal-specific interaction test. No fresh screenshot review or physical Dell GPU/DPI/mixed-monitor/real sleep/overnight result is claimed.

## Publication status

The read-only validation workflow has no publication job. Its internal installer retains test version 0.25.0 and must not overwrite published 0.25.0 bytes. Public download/provenance verification, signing and production updater roundtrip were not performed for this patch. A separately versioned candidate must pass all documented gates before distribution. Production remains authenticated 0.25.0. The pinned key, discovery files, updater helpers, preferences and old disabled workflow are unchanged.
