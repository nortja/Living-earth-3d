# 0.13.0 candidate validation

Prepared 2026-10-31. Adds the optional dated NASA GIBS / NOAA-20 VIIRS satellite surface; includes the 0.12.4 camera/display improvements. See SATELLITE_SNAPSHOT.md for behavior, source documentation and limits.

Local official Godot 4.6.3 import and fifteen headless suites pass after correcting an obsolete future-version fixture in explorer_test: the previous 757 checks plus 22 satellite behavior checks (779 total). Native actual-image rendering and control layouts passed; the next frozen build must rerun the final NOAA-20 source and all release gates. No production-feed promotion is claimed by these local results.

The release/preview-0.13.0 workflow builds fresh application/screensaver/installer binaries, tests source/security and native rendering, and checks actual installed Windows upgrade/rollback, settings, native preview/lifecycle and desktop behavior. Windows desktop validation additionally exercises a labeled synthetic satellite surface, date context, preview exclusion and offline return before the five-active-minute performance recording. Only complete validation permits public artifact delivery and separately signed update metadata.

Physical Dell/mixed-monitor/sleep checks, continuous embedded video, publisher Authenticode and a complete current global cloud feed remain distinct open work. A previous-day true-color mosaic does not satisfy a continuous weather feed.

The first CI attempt stopped at the future-version fixture before any installer was built. The corrected fixture derives newer minor/major versions from the running app. An actual app-side NASA GIBS request also passed for 2026-10-30, with a 2048×1024 NOAA-20 / VIIRS image. Native NOAA-20 rendering passed at 800×600, 1920×1080, 3840×1080 and 5120×2880; screenshots were inspected. Native-saver headless isolation passes 13 checks.
