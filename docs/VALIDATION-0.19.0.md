# 0.19.0 preview validation

Released 2026-11-01. Frozen application source `e4d37dc024c4cb9872b70feba12d8af1f695b8de`, tree `b8073edd24ee4a07d9b30dd97a2b725d1aa29619`, based on published main 408b481d7e348d1880d5bbb38dab8f71e4e9ecb6.

Optional offline sunlight simulation from Live Earth or a destination card. A bounded fifteen-minute slider spans twelve hours before/after opening; Now reanchors to the device UTC clock. Geometric Sun height and daylight/civil/nautical/astronomical twilight accompany the selected place (or an explicitly named equator reference). This is a calculation, not imagery or an observed sky. No sunrise, terrain, refraction or weather prediction is made.

The simulation overrides lighting only temporarily. It preserves the current-lighting preference and loaded dated-satellite identity; closing, navigating away or entering saver preview restores the prior surface/lighting and clears simulated time. No clock changes, provider requests or preference writes are made by the feature. Existing in-flight satellite work is cancelled on entry into the explicit offline preview.

Calculation source: [NOAA General Solar Position Calculations](https://gml.noaa.gov/grad/solcalc/solareqns.PDF), geometric zenith equation. Twilight categories use geometric solar-center thresholds of 0, −6, −12 and −18 degrees; visible sunrise/sunset can differ.

## Required evidence

- New analytic subsolar/antipodal/polar/date-line/leap-day checks; phase boundaries; preview bounds, UTC year transition and Now behavior.
- Temporary-state restoration, selected-place identity, satellite texture/date retention without retrieval and screensaver isolation.
- Existing eighteen behavior suites, update-security/status, installer/build parsing and native layouts.
- Seven sunlight render sizes through 5K, including 800×600 and 3840×1080; reviewed primary controls.
- Fresh Windows upgrade/rollback/settings, installed sunlight resources/isolation, full five-size framebuffer matrix and ten-minute preview lifecycle.
- Public installer provenance/checksum, pinned-key signature, atomic source/feed promotion and production Windows updater roundtrip.

Pending results are not passes. Physical Dell DPI/mixed-monitor, audible playback and sleep/overnight observations remain field checks.

## Candidate history

Initial source caf3c9cebd31f8581eb72dba937d2e34c04ea7e3 / run 41326150602 passed all source/security/export checks but failed the native timestamp clip assertion at all seven sizes. Its first Label extended one logical pixel above the scroll clip after native snapping. This candidate was not published or signed. The repaired panel adds a small top inset; strict bounds assertions remain unchanged. The native failure was also reproduced locally.

The initial 19 local source suites passed 1168 checks, including 50 new sunlight cases. Ten Python release-verifier tests and workflow YAML parsing passed. These are source checks, not Windows or release passes.

## Completed release evidence

[Full run 41326613347](https://github.com/nortja/Living-earth-3d/actions/runs/41326613347) passed all four jobs on corrected source; initial failed source was excluded.

- Build 124907786012: all 19 source suites / 1168 checks, release-verifier/security/status/build-script checks, fresh application/native-saver/icon/installer export, complete native render matrix and saver isolation passed.
- Desktop 124909370390: actual installed sunlight simulation and visible return, preference/satellite/saver isolation, photographs, offline atlas, backup callbacks and weather checks passed. Reviewed actual sunlight screenshot. Five-minute recording: 300.0189 active seconds, 13,313 frames, mean 22.5358 ms, one frame over 50 ms, unavailable engine-memory counters remain null. This VM timing is not a physical-PC rating or speedup claim.
- Actual installed Windows 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880 framebuffers/layouts passed. llvmpipe rendering with explicit post-start resize on a 1024×768 virtual desktop is not physical 5K/DPI evidence.
- Windows 124909370407: upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status runtimes, actual settings/dropdown, native preview/lifecycle and 605.2-second resize/private-memory soak passed. Final private bytes 210,931,712. Native first rendered frame was signalled at 2953 ms. Simulated display/suspend/session-lock notification cleanup passed; actual hardware sleep/lock/mixed-DPI remain field observations.
- Publish 124912597199 succeeded. [Independent public verification 41328300602](https://github.com/nortja/Living-earth-3d/actions/runs/41328300602) checked completed source/workflow/gates, the exact public updater URL, checksum/size, BUILD source and four-file/helper metadata. Downloaded verified bytes were digest-checked and validated locally against independently fetched public metadata and unchanged helpers.
- Pinned RSA key independently verified the exact generated signature outside git/CI. All 124 local runtime/data/assets/project/export/packaging files matched the frozen tree; documentation is additive. All three discovery files were promoted atomically with the tested application source.

[Raw evidence](evidence/0.19.0/) retains framebuffer reports, the actual recording, native readiness/soak samples and public delivery report. Installer: 51,388,338 bytes; SHA256 `33f01614f1cf9bba5b0165bb234c604a287eff91aa114afb7acb09c2be1d15ca`.

## Production updater

Final authenticated production download/cancellation/normal-exit install test is pending after feed promotion. No later release will move the feed before it passes. Windows publisher Authenticode and physical hardware observations remain separate.
