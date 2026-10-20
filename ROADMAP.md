# Living Earth 3D — current roadmap

Updated 2026-10-20. Latest released baseline: 0.6.1 (Camera Wall, collections and current UTC sunlight). One Windows installer, then authenticated automatic updates; the base Earth remains useful offline.

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
- [x] Four screensaver styles and returnable fullscreen preview. Full Windows multi-monitor/preview integration is unfinished.

## Previous release — 0.5.4

- [x] Replace app/installer/uninstaller artwork with a cleaner Earth icon and seven native icon sizes. Shortcuts use a versioned ICO path; installation notifies Windows that icons changed. Existing pinned taskbar icons may require field verification.
- [x] Fix camera selection: three NPS image cameras open an actual in-app viewer, rather than only moving the globe. Five video/seasonal entries visibly open official websites.
- [x] Add loading/error feedback, refresh, optional once-per-minute refresh while open, provider attribution, retrieval/source timestamp labels, retained-image warning and unchanged-frame warning.
- [x] Cancel requests on close/selection change/screensaver preview; prevent old responses from appearing under a different camera name. Keep network access opt-in through camera selection.
- [x] Publish the Windows-tested installer and signed 0.5.4 feed.
- [ ] Observe the first automatic upgrade on the user's Windows machine (0.6.1 is now the target release).

## This release — 0.6.1

- [x] Failed-camera polling: 1/2/4/8-minute retries, recovery to one minute, correct manual/automatic state messages.
- [x] Camera Wall: 1/2/4/6/9-view responsive layouts, aspect-preserving tiles, focused viewer, eight saved collections, shared duplicate-source downloads and at most two concurrent requests. Three unique image sources currently available; no embedded video.
- [x] Stop offscreen, minimized, focused-away, closed and screensaver-hidden wall downloads.
- [x] Optional current UTC sunlight and seasonal day/night boundary. Offline approximate NOAA calculation; saved setting; geometric orientation remains correct during cinematic rotation. Device clock must be correct.
- [x] 400 headless behavior/layout checks, 16 update-security checks, native Linux wall/globe/intro renders, three real NPS image retrievals and Windows icon-resource verification.
- [x] Windows installation/rollback and updater-security checks passed; public installer verified and signed feed promoted. Production signed-feed staging, cancellation, normal-exit installation and file verification also passed on Windows; see release validation.

## Next priorities

1. **Field validation:** confirm automatic upgrade, new desktop/taskbar icon, all camera states, visible-window restart, physical Dell scaling, frame times, memory, fullscreen, sleep/resume and monitor moves.
2. **Continuous video:** add authorized in-app streaming playback. Current NPS views are periodically refreshed camera images; other streams open the provider website. No continuous embedded video is delivered yet.
3. **Camera Wall expansion:** more source-verified image endpoints and authorized continuous-video playback. Initial responsive 1/2/4/6/9 layouts are implemented in 0.6.1; optimize further after actual Dell measurement.
4. **Living planet:** current UTC sunlight is implemented in the 0.6.1 candidate. Next: optional weather with model/source times and licensed cloud refresh with explicit stale/offline states. Clouds/Moon/stars remain cinematic.
5. **Screensaver integration:** Windows /p preview, /s field checks, multiple monitors, lock/sleep/resume, background power limits and longer-duration tests.

## Later / dependent work

- [ ] Actual satellite orbits and accurate astronomical positions, with timestamps and accuracy limits.
- [ ] Source-verified 8K imagery, documented distribution rights and integrated-GPU performance targets. No upscaling marketed as new detail.
- [ ] Terrain/scattering improvements without compromising ordinary PCs.
- [ ] Ancient-site/history layers with citations, dates and uncertainty; more curated discoveries and journeys.
- [ ] Windows publisher Authenticode certificate, signed stable channel and signing-key rotation/migration plan. Preview release authentication is implemented; the installer still lacks Windows publisher signing.
- [ ] Stronger power-loss/crash recovery and recovery launcher. Current handled-failure rollback is not a power-loss guarantee.
- [ ] Move recurring binary delivery from Git branches to release assets/hosting while preserving update trust and compatibility.

## Release rules

Build/test first, publish installer, verify its download, sign the exact release metadata, then atomically promote discovery feed and signature. Preserve preferences and the pinned trust key. Keep the old failing automatic Windows workflow disabled. Separate source/headless/native renders, Windows installation tests, and real hardware observations; never label periodic imagery as continuous live video or a retrieval timestamp as capture time.
