# Validation: bounded monitor-enumeration retry

Date: 2026-11-28

Candidate: PR [#24](https://github.com/nortja/Living-earth-3d/pull/24)  
Merge commit: [5892a7ca36118f72522e71f22dfce9b76226f7e3](https://github.com/nortja/Living-earth-3d/commit/5892a7ca36118f72522e71f22dfce9b76226f7e3)  
Full no-publication validation: [GitHub Actions run 46051895392](https://github.com/nortja/Living-earth-3d/actions/runs/46051895392)

## Change under test

The native Windows screensaver now retries transient `EnumDisplayMonitors` API failures and empty inventories up to three total attempts, waiting 50 ms after the first failure and 100 ms after the second. A callback failure (including invalid monitor geometry or native-host creation failure) aborts immediately. Empty native host windows from an incomplete API walk are destroyed before retrying. Renderers and session notifications are not started until a complete, non-empty inventory has been accepted. Exhausted retries remain fail-closed.

The four-renderer limit, 350 ms topology debounce, Windows job-object cleanup, installer behavior, user preferences and updater trust/verification are unchanged.

## Completed workflow evidence

All three jobs in run 46051895392 completed successfully:

- **build (Ubuntu 24.04):** pinned Godot 4.6.3 import; all 26 headless Godot source suites; release-download verifier failure-path tests; PowerShell updater/build-script tests; fresh Windows application export, embedded pack smoke test, native `.scr` build and unsigned no-publication NSIS test installer; native Linux exploration/camera/render suites; native screensaver preview and fullscreen budget/weather-isolation suites.
- **native policy tests:** compiled and executed with strict GCC C++17 warnings on Linux and MSVC `/std:c++17 /W4 /WX` on Windows.
- **Windows installer/updater:** Windows PowerShell 5.1 and PowerShell 7 updater/build checks; installer installation, rollback and upgrade test from baseline 0.24.0; checksum-pinned test-only Mesa software OpenGL; actual Windows Screen Saver Settings and Earth selection; installed embedded preview and `-SoakMinutes 10` lifecycle test.
- **installed desktop:** packaged UI full display matrix and monitor-query-cost test passed on the Windows runner.

The workflow's installed framebuffer test is the documented seven-size software-rendered matrix, including 3840×1080 and 5120×1440. The Windows rendering jobs use test-only software OpenGL; they are not physical GPU measurements.

## Limits and release decision

This workflow does not simulate physical monitor hot-plug, actual mixed-DPI movement, a physical Dell U4919DW GPU/refresh path, machine sleep/wake or overnight operation. The retry decision is covered by deterministic native policy tests; the workflow does not force the real Win32 enumeration API to fail on physical hardware.

This is a no-publication validation. It did not independently download a newly published candidate installer, sign new release metadata, or execute the production authenticated-updater roundtrip. No production release was made. The production 0.25.1 manifest/signature, pinned RSA trust key, updater integrity inventory, user preferences and saved scenes remain unchanged.
