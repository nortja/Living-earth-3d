# 0.10.0 validation

Candidate, 2026-10-20. Production remains 0.9.0 until release gates pass.

New behavior includes eight distinct periodic-image camera feeds, source-specific refresh cadence and delay warnings, bounded wall textures, local camera filtering, a local display/performance report and interrupted-journey feedback. No new data requests occur at startup or in screensaver mode. Camera images remain periodic; provider video pages remain external.

The performance report contains version, OS/engine, GPU/display dimensions/DPI/refresh, viewport, graphics settings, bounded frame-interval statistics and engine-tracked memory. Its five-minute recording counts active rendering time, pauses for minimized/screensaver states and excludes sleep gaps over two seconds. It excludes account names, paths, bookmarks, queries and camera images, and has no upload path. Engine memory excludes process/driver/GPU allocations; frame intervals include the cap. This is not a physical-hardware score.

550 local behavior/layout checks pass. Native report and arrival layouts through 5K pass; expanded wall renders are also checked. Actual JPEGs from all four new source endpoints returned HTTP 200, decoded at their documented dimensions and rendered in the actual in-app viewer. Native long-duration rendering and Windows preview/upgrade/rollback gates run before authenticated promotion. Software rendering and simulated suspend/session-lock messages do not establish physical sleep/resume or multi-monitor/DPI results.

Archived candidate outcome: the one-hour Linux renderer and one-hour Windows preview gates passed. This candidate was not promoted to the authenticated feed; its features ship in combined 0.12.2. That release also corrects the display report to represent the unavailable release-build engine-memory counter as null. See VALIDATION-0.12.2.md for final release evidence.
