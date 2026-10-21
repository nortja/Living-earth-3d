# Living Earth 3D — current roadmap

Updated 2026-10-21. Latest released baseline: 0.12.2 (photographs, history, expanded cameras, optional weather points and local display recording). One Windows installer, then authenticated automatic updates; the base Earth remains useful offline.

## Completed

- [x] Single double-clickable, per-user Windows installer with desktop/Start menu shortcuts and uninstall support. No ZIP, terminal or separate Godot runtime for users.
- [x] User confirmed 0.5.3 installed and automatic updates enabled.
- [x] Authenticated updates: pinned release signature, bounded download, installer/file hashes, background checks, pause/resume, apply on normal exit and an Update and restart now action. Production-feed download/cancellation/normal-exit install passed Windows CI; handled-install failures restore previous files and version metadata. Private signing key stays outside git/CI.
- [x] Animated Earth introduction, slow startup rotation, drag inertia, wheel/double-click zoom, reset and fullscreen.
- [x] Genuine 2K/4K Earth imagery, night lights, atmosphere, independent artistic clouds, optional artistic stars and Moon.
- [x] Native-resolution proportional Earth and responsive controls. Saved Automatic/100–200% interface sizes, safe resizing, GPU/display reporting and 30/60 FPS caps. Physical Dell DPI/performance testing remains separate.
- [x] Optional original offline ambient sound, saved volume and smooth fades; off by default. Screensaver stays silent.
- [x] Offline atlas, coordinates, six curated destinations, favorites, surprise destinations and timed journeys.
- [x] On-request worldwide place search and USGS earthquakes, with retrieval/cache/error states. These are periodic/requested data, not a continuous live feed.
- [x] Six screensaver styles and returnable fullscreen preview. Native Windows preview and per-monitor hosts are implemented in 0.8.0; physical mixed-DPI coverage remains a field test.

## Previous release — 0.5.4

- [x] Replace app/installer/uninstaller artwork with a cleaner Earth icon and seven native icon sizes. Shortcuts use a versioned ICO path; installation notifies Windows that icons changed. Existing pinned taskbar icons may require field verification.
- [x] Fix camera selection: three NPS image cameras open an actual in-app viewer, rather than only moving the globe. Five video/seasonal entries visibly open official websites.
- [x] Add loading/error feedback, refresh, optional once-per-minute refresh while open, provider attribution, retrieval/source timestamp labels, retained-image warning and unchanged-frame warning.
- [x] Cancel requests on close/selection change/screensaver preview; prevent old responses from appearing under a different camera name. Keep network access opt-in through camera selection.
- [x] Publish the Windows-tested installer and signed 0.5.4 feed.
- [x] User reported the update installed nicely and Camera Wall/cameras work on Windows (2026-10-20).

## Previous release — 0.6.1

- [x] Failed-camera polling: 1/2/4/8-minute retries, recovery to one minute, correct manual/automatic state messages.
- [x] Camera Wall: 1/2/4/6/9-view responsive layouts, aspect-preserving tiles, focused viewer, eight saved collections, shared duplicate-source downloads and at most two concurrent requests. Three unique image sources currently available; no embedded video.
- [x] Stop offscreen, minimized, focused-away, closed and screensaver-hidden wall downloads.
- [x] Optional current UTC sunlight and seasonal day/night boundary. Offline approximate NOAA calculation; saved setting; geometric orientation remains correct during cinematic rotation. Device clock must be correct.
- [x] 400 headless behavior/layout checks, 16 update-security checks, native Linux wall/globe/intro renders, three real NPS image retrievals and Windows icon-resource verification.
- [x] Windows installation/rollback and updater-security checks passed; public installer verified and signed feed promoted. Production signed-feed staging, cancellation, normal-exit installation and file verification also passed on Windows; see release validation.

## Previous release — 0.7.0

- [x] Reuse the development-track wonder/history prototypes while preserving main's authenticated updater and working cameras.
- [x] Discover/Search/History/Saved sections, twelve sourced daily wonders, fifty local saved places and visible save feedback.
- [x] Historical-era site filtering for Giza/Rome/Tikal with persistent modern-imagery disclosure.
- [x] On-request Open-Meteo point-model weather, units, model/retrieval timestamps, bounded cache/expiry, retained-data context and request cancellation.
- [x] Six screensaver styles; expanded wonder journeys and saved-sunlight restoration.
- [x] Giant Forest in-app image camera; north-oriented polar navigation; readable favorite actions.
- [x] 464 local checks, 16 update-security checks, real weather/four-camera retrievals and native layouts through 5K.
- [x] Windows upgrades/rollback from 0.5.2 and 0.6.1, public installer verification and signed-feed promotion. Production-feed staging, cancellation, normal-exit installation and payload verification also passed on Windows.

## Previous release — 0.9.0

- [x] Discovery, curated, saved and search journeys automatically show a named destination card, story/context, approximate coordinates, arrival confirmation and clear next actions.
- [x] Camera journeys and saved known camera destinations open their viewer; closing it retains destination context. External camera pages report launch status and offer an official-source retry.
- [x] 488 behavior/layout checks and six native arrival render sizes; fresh application export, Windows upgrade/rollback from 0.5.2 and 0.8.0 and native screensaver lifecycle gates.
- [x] Published verified installer and authenticated update; production staging, cancellation, normal-exit installation and installed-file verification passed on Windows.

## Previous release — 0.8.0

- [x] Native screensaver launcher, strict preview argument handling, embedded-mode budget and per-monitor host implementation.
- [x] Actual Windows embedded preview/render/lifecycle tests and upgrade/rollback from 0.5.2 and 0.7.0.
- [x] Published verified installer and authenticated update. Production signed-feed staging, cancellation, normal-exit installation and payload verification passed on Windows.

## This release — 0.12.2

- [x] Eight verified in-app periodic-image feeds and four official external venues; searchable camera catalog, image-only filter and different-camera wall fill.
- [x] Provider-specific refresh/backoff, slower-feed unchanged warnings and bounded wall textures.
- [x] Twelve licensed offline discovery photographs with visible creator/license/source credit and full viewer; ten sourced historical teaching contexts on modern imagery.
- [x] Optional sixteen-place Open-Meteo model layer, dated clickable points, units, cache validation and stale/offline states. Manual requests only; no device location or native-saver service.
- [x] Local five-active-minute performance recording and JSON display report; unavailable release engine-memory counters explicitly represented as null.
- [x] Interrupted-journey status and Full Earth destination cleanup. Existing destination and camera handoffs preserved.

## Next priorities

1. **Field validation:** user confirmed the 0.7.0 automatic upgrade; next confirm new screensaver behavior, new desktop/taskbar icon, all camera states, visible-window restart, physical Dell scaling, frame times, memory, fullscreen, sleep/resume and monitor moves.
2. **Continuous video:** add authorized in-app streaming playback. Current NPS views are periodically refreshed camera images; other streams open the provider website. No continuous embedded video is delivered yet.
3. **Camera Wall:** eight image sources and bounded textures are implemented; prioritize authorized continuous-video playback and optimize further after actual Dell measurement.
4. **Living planet:** UTC sunlight is released; requested point-model weather is released in 0.7.0. Sixteen-place model weather points are released in 0.12.2. Next: licensed current cloud refresh and broader weather coverage. Clouds/Moon/stars remain cinematic.
5. **Screensaver integration:** Native /p preview and per-monitor hosts are released. Next: physical /s mixed-DPI/monitor checks, lock/sleep/resume, performance and overnight hardware tests. One-hour Linux renderer and Windows preview foundation tests supplement the current-package gates; they do not establish physical hardware behavior.

## Later / dependent work

- [ ] Actual satellite orbits and accurate astronomical positions, with timestamps and accuracy limits.
- [ ] Source-verified 8K imagery, documented distribution rights and integrated-GPU performance targets. No upscaling marketed as new detail.
- [ ] Terrain/scattering improvements without compromising ordinary PCs.
- [ ] Extend the ten sourced historical contexts and twelve photographed discoveries with further documented sources and explicit uncertainty.
- [ ] Windows publisher Authenticode certificate, signed stable channel and signing-key rotation/migration plan. Preview release authentication is implemented; the installer still lacks Windows publisher signing.
- [ ] Stronger power-loss/crash recovery and recovery launcher. Current handled-failure rollback is not a power-loss guarantee.
- [ ] Move recurring binary delivery from Git branches to release assets/hosting while preserving update trust and compatibility.

## Release rules

Build/test first, publish installer, verify its download, sign the exact release metadata, then atomically promote discovery feed and signature. Preserve preferences and the pinned trust key. Keep the old failing automatic Windows workflow disabled. Separate source/headless/native renders, Windows installation tests, and real hardware observations; never label periodic imagery as continuous live video or a retrieval timestamp as capture time.
