# 0.19.0 candidate — sunlight explorer

Prepared 2026-11-01 from published main 408b481d7e348d1880d5bbb38dab8f71e4e9ecb6. Not promoted to the authenticated feed until all release gates and independent public-byte verification pass.

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
