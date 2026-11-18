# Native screensaver monitor extent validation

Validated follow-up merged on November 18, 2026. The native Windows screensaver now uses one checked rectangle-to-dimensions helper for initial monitor-host creation, WM_DISPLAYCHANGE rebuilds, and DPI-only WM_DPICHANGED handling.

## Implementation

earth_saver::monitor_dimensions validates positive/non-reversed bounds and dimensions no greater than INT_MAX before any Win32 size conversion. It computes extents with unsigned arithmetic after ordering checks, avoiding signed overflow for negative desktop origins on both Windows LLP64 and Linux LP64. Invalid inputs leave both output dimensions at zero. Initial host enumeration fails closed through the existing screensaver error path; DPI recovery stops safely if a target monitor rectangle cannot be represented.

## Dedicated no-publication validation

[GitHub Actions run 44373688324](https://github.com/nortja/Living-earth-3d/actions/runs/44373688324) completed successfully on November 18, 2026.

- Fresh Godot 4.6.3 application and native .scr builds completed.
- The full source suite passed; the screensaver argument/geometry suite reported 59 checks and zero failures.
- Native Linux render suites passed, including four saver render sizes.
- Windows installed-package checks passed for silent upgrade from 0.5.2 and 0.24.0, rollback after an injected installed-file failure, running-app protection, and user-data preservation.
- Windows Screen Saver Settings and Earth selection passed.
- The actual packaged Earth preview rendered inside the native parent window, resized correctly, and completed a ten-minute software-rendered preview soak.
- Synthetic Windows message tests passed for DPI-only changes, display-change burst/rebuild, suspend, session lock, cancelable end-session, and committed end-session.
- The installed desktop framebuffer matrix passed 1920×1080, 2496×1664, 3440×1440, 3840×1080, 3840×2160, 5120×1440, and 5120×2880 using test-only software OpenGL.

The companion camera regression run [44373688208](https://github.com/nortja/Living-earth-3d/actions/runs/44373688208) passed on Linux and Windows.

## Release and field-test limits

This was a no-publication validation. It did not publish a new installer, change the authenticated update manifest, alter the pinned trust key, or modify preferences/saved scenes. The production baseline remains 0.25.1.

Software-rendered CI and synthetic Windows messages do not establish physical Dell U4919DW GPU/DPI behavior, real mixed-DPI monitor movement, physical hot-plug, machine sleep/wake, fan/power behavior, or overnight operation. Those remain field checks.
