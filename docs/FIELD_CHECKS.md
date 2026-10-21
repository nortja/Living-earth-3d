# Windows field observations after 0.12.2

These observations complement automated tests; CI software rendering does not establish physical Dell GPU, DPI, power or monitor behavior. Continue using the normal installed app and screensaver. Automatic updates apply after a normal app/screensaver exit; no manual reinstall is needed for updater-enabled versions.

## Useful observations on return

1. Did the screensaver keep rendering throughout the unattended run? Which style was selected? Note any freeze, black screen, flashing or unexpected exit and its approximate time.
2. Did ordinary mouse/key input dismiss it? Did normal lock/sleep/wake restore the desktop correctly?
3. How many monitors were attached, at what resolutions and Windows scale percentages? Did the image cover each correctly?
4. Was fan noise, heat or battery consumption unusually high? Did the 30 FPS/power-saving option help?

## Local display report

Open Settings → Performance & support. The live display report identifies the GPU, monitor/viewport pixels, DPI, refresh rate, quality and frame cap. Optionally start a five-active-minute recording, use the app normally and export its local JSON report. Recording pauses in screensaver preview or while minimized and excludes sleep-size frame gaps. It does not upload anything. Engine memory is unavailable in exported release builds and is reported as null; the report is not a complete process/GPU-memory measurement or hardware benchmark.

## Feature checks

- Explore → Discover → visit a wonder: the destination card should show its story and photograph. Open the photograph and inspect its source/license credit. Escape returns to the destination.
- Cameras: search a name, enable image-only filtering and open a feed. Periodic camera photographs may be unchanged between provider captures; capture and retrieval times are different. Fill a Camera Wall with different sources.
- Live Earth → Weather around Earth: manually request the fixed public-place sample, select a point and inspect its model time and units. Stale results turn grey; this is not a continuous global weather map.
- History: change the era and inspect the sourced context. Globe and photographs stay modern; no ancient reconstruction is implied.

## Decisions for the next build

Preferred camera regions/themes; continuous video versus current cloud imagery priority; personal/community-only distribution versus future paid, advertising or commercial use (which affects source/API arrangements); intended project-wide code license and eventual Windows publisher identity. No paid service or certificate is purchased by this build.
