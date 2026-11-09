# Windows field observations

Current preview: 0.19.0. Automated Windows software-rendered gates cover installation/rollback, actual settings/dropdown, native preview/lifecycle, installed resources/backup callbacks, five-minute reporting and exact framebuffer sizes through 5K. They do not establish physical Dell GPU, mixed DPI/monitors, sleep/power, audible playback or overnight behavior.

## When using the actual Dell

1. Observe whether the selected saver stays animated, covers each attached monitor and dismisses normally on mouse/key input.
2. Try ordinary lock/sleep/wake and monitor connect/disconnect. Note any freeze, black screen, flashing, unexpected exit and approximate time.
3. Compare 2K/4K and normal/power-saving settings during ordinary use; observe fan/heat/battery behavior. A frame cap is not a performance guarantee.
4. Check saved interface sizes and monitor moves at the actual Windows scale percentages. The virtual framebuffer matrix is separate from these physical checks.

## Local performance report

Settings → Performance & support identifies the actual GPU, viewport/monitor pixels, DPI, refresh, active screen and all attached monitor geometry/scale. Optionally record five active minutes while using the app normally and save its local JSON. Configuration segments retain quality/cap/viewport/scale/window changes; screen index comes from the latest display poll and can lag by about one active second. During an opt-in recording, `recording.topology_events` also captures a baseline and monitor changes (active screen, pixel geometry, position, DPI, scale and refresh) about once per active second, up to 32 events; brief changes between polls may be missed. The current `display.monitors` inventory remains a snapshot.

Nothing is uploaded. The report excludes usernames, file paths, bookmarks and camera images. Release engine-memory counters are unavailable/null and are not complete process/GPU-memory measurements. Recording pauses in saver preview/minimized state and excludes sleep-sized gaps. No hardware score is inferred.

## Feature observations

- Sunlight explorer: open from Live Earth or a selected destination, scrub time and inspect UTC/phase. Finish or enter screensaver preview; the previous lighting and dated satellite view should return. This geometric simulation does not predict visible sunrise through terrain or weather.

- Discover: visit a wonder, inspect its story/photo and source/license credit, then return with Escape.
- Cameras: search/filter, open a periodic image and use a different-source Camera Wall. Retrieval/recheck time is not verified camera capture time; unchanged images can be delayed.
- Weather globe: explicitly load the 32-place model sample, filter a city/country, select it and inspect model time/units. It is a point sample, not continuous observations/global clouds.
- Recent days from orbit: choose one of the previous seven UTC days, press Load, inspect its observation date/real gaps and return to Offline Earth. Date selection alone makes no request.
- Saved places: choose a backup file/location, save another place, then import the backup. Existing entries should remain and duplicate/capacity counts should be clear. Actual OS chooser interaction remains a physical field observation beyond callback fixtures.
- History: inspect the sourced era context while remembering the globe/photos remain modern imagery.

## Future decisions

Camera regions/themes, licensed continuous video versus current cloud refresh, future commercial/advertising distribution, project code license and eventual publisher identity remain planning topics. No paid service/certificate, telemetry or private-key upload was introduced by this sprint.
