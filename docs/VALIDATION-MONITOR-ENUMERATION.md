# Native screensaver monitor-enumeration completeness

Status: validated and merged to main on November 20, 2026.

## Behavior

The Windows saver now checks the return value of `EnumDisplayMonitors` at both initial host creation and after a `WM_DISPLAYCHANGE` rebuild. A non-empty partial enumeration is not accepted as complete coverage. If the API fails, the callback stops because a monitor rectangle is invalid, or no monitors are returned, the saver follows its existing controlled shutdown path before starting any renderer for that enumeration.

The policy is isolated in `earth_saver::monitor_enumeration_complete` so it can be exercised with deterministic native tests on Linux and Windows. On a failed rebuild, any partially created host windows are left for the existing bounded shutdown cleanup; the job object remains the final guard for owned renderer processes.

This is fail-closed behavior: it avoids presenting a partially covered desktop as a successful monitor rebuild. It does not add retries or alter the 350 ms display-change debounce.

## Validation completed

The dedicated no-publication workflow passed in full on November 19, 2026: [run 44587850218](https://github.com/nortja/Living-earth-3d/actions/runs/44587850218).

- All 26 Godot headless source suites passed; fresh Godot 4.6.3 import and Windows application export passed.
- The native screensaver policy suite passed 69 assertions with strict C++17 warnings on Linux and native Windows MSVC.
- Linux native exploration, camera, screensaver and preview/fullscreen saver render suites passed; saver renders covered four test sizes.
- The native `.scr` launcher and 0.25.1 test installer built successfully.
- Windows PowerShell 5.1 update-status tests passed 211 checks; updater-security tests passed 16 checks.
- Windows installer install/rollback passed for a fresh install and an upgrade from 0.25.0, including user-data preservation.
- Actual Windows Screen Saver Settings selection and embedded preview passed; the ten-minute software-rendered screensaver lifecycle soak passed.
- Installed Windows desktop framebuffer matrix and monitor-query-cost checks passed.
- Camera regressions passed separately on Linux and Windows: [run 44588063036](https://github.com/nortja/Living-earth-3d/actions/runs/44588063036).

A duplicate no-publication run [44588062992](https://github.com/nortja/Living-earth-3d/actions/runs/44588062992) was canceled before its source-test stage to avoid overlapping the completed full validation; it is not evidence for this change.

A synthetic policy test cannot force Windows' real `EnumDisplayMonitors` API to fail. The Windows integration suite validates successful installed enumeration, display-change recovery and cleanup; actual API failure remains covered by the deterministic helper contract rather than a physical display failure.

## Field checks and release status

Physical Dell U4919DW GPU/DPI, real mixed-DPI movement/hot-plug, machine sleep/wake and overnight behavior remain separate field checks.

The workflow built a test installer only; it did not publish a production installer, generate a release signature or promote the authenticated update feed. Preferences, saved scenes, updater trust key and production manifest were not changed.
