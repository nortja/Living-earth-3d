# Living Earth 3D — living roadmap

Build a beautiful offline-first Windows globe and calm screensaver. Keep installation to one EXE, interactions simple, network features optional, audio off by default, and every public release testable and traceable.

## Current milestone: 0.5.0 preview

Completed this cycle: compact navigation and responsive side/bottom panels; optional wide Command Center overview; native-resolution 3D viewport with proportional globe; automatic compact UI scaling through 5K; monitor/GPU reporting and refresh-aware frame cap; offline atlas and coordinates; optional worldwide place search; honest official-camera directory and globe journeys; on-request USGS earthquakes with UTC/cache/failure states; four screensaver styles and returnable fullscreen preview. Preserved the 4K/2K maps, independent clouds, branding, intro, controls, favorites, timed discovery, updater safeguards and one-file installer.

Validation separates Linux native rendering, packaged-data/resource checks, and actual Windows execution. The new packaged-app Windows display harness captures screenshots, GPU/platform identity and layout evidence at 1080p, ultrawide, 4K and 5K. It has not run on Windows yet. The user previously confirmed 0.3.0 installation and launch. Current Windows installation, physical Dell display/DPI/refresh, integrated-GPU frame times, and signed updates remain open.

## Next cycle — immersion and trustworthy live experiences (P0/P1)

- [ ] Execute `tests/windows_display_test.ps1` against the actual 0.5.0 Windows EXE on an interactive Windows runner; inspect screenshots and test physical Dell monitor DPI/refresh, fullscreen, sleep/resume and frame times. Cloud GitHub API access is currently denied; do not restart the old failure-email loop.
- [x] Add a saved interface-size override with safe window bounds. Version 0.5.2 adds Automatic and 100–200% choices; real Windows DPI/readability checks remain outstanding. Maximum source texture detail is still 4K.
- [ ] Verify provider pages from an allowed network, review embedding terms, then add authorized in-app camera playback with real availability/freshness checks. Current entries open official browser pages only.
- [ ] Exercise USGS and worldwide search against real services from an allowed network; fixture parser/cache tests do not establish current provider availability. Cloud destination additions are saved in environment settings but require publication before affecting runtime.
- [ ] Add optional weather estimates with source, coordinates, model time, units, cache expiry and explicit periodic labels. Do not represent modeled weather as live sensor observations.
- [ ] Add current UTC solar illumination, documented seasonal timing and an explicit cinematic/time mode switch.
- [ ] Add actual satellite orbits and astronomy positions with source timestamps and accuracy limits; current NASA/USGS shortcuts open external explorers.

## Next — make Windows delivery dependable (P0)

- [ ] Move recurring installer storage from dedicated Git branches to release assets or an artifact host while retaining fixed-origin and signature validation.

- [x] User confirmed 0.5.0 installs nicely and 0.5.1 installed and works on Windows. Detailed DPI/performance and upgrade-preservation evidence remain separate.
- [ ] Test 0.5.0 desktop/taskbar icon, intro, upgrades, favorite preservation, uninstall, and reinstall on Windows 10/11 x64.
- [ ] Test 1080p/4K/ultrawide displays with Windows DPI scaling and normal integrated GPUs. Measure frame time and memory, then tune quality settings.
- [ ] Provision an authentic code-signing certificate through secure CI settings. Sign both app and installer; never weaken signature checks for unsigned previews.
- [ ] Complete field verification of 0.5.3 authenticated updates: the pinned release signature replaces manual preview updates; Windows test automation covers silent installation/rollback, while visible-app restart, sleep/resume and physical field checks remain separate.
- [ ] Validate the revised Windows build script in a controlled manual run. The workflow remains disabled to prevent further unwanted emails. No development-tag triggers.
- [ ] Define a signed stable update channel before 1.0; preview feed currently serves opt-in development updates.
- [ ] Add upgrade rollback/recovery and a planned certificate-rotation path before calling auto-update production-ready.

## Next — living planet visual quality (P1)

- [ ] Add source-verified 8K satellite imagery beyond the delivered 4K maps. Retain attribution and distribution terms; do not upscale and call it new detail.
- [x] Separate offline cloud layer from surface imagery with independent drift.
- [ ] Add opt-in cloud refresh with provider attribution, timestamps, bounded downloads, cache expiry, and offline fallback.
- [ ] Add UTC-based solar illumination and seasonal changes with documented accuracy; distinguish simulated time from live data.
- [x] Add optional stars and Moon with restrained lighting and resource costs, clearly labeled as artistic backdrops.
- [ ] Add real astronomical positions as a separate, documented mode.
- [x] Improve atmosphere, coastline detail, night-light transition, and artistic cloud shade while preserving compatibility-renderer support.
- [ ] Investigate physically based scattering and terrain without making integrated GPUs unusable.

## Next — meaningful exploration (P2)

- [x] Add an offline city/landmark/natural-wonder atlas with selectable geographic markers.
- [ ] Add optional live weather through a licensed provider, with fresh/stale/offline states and no required account for the base globe.
- [ ] Expand Today's Wonder and curated journeys without intrusive popups.
- [ ] Add ancient sites and historical layers with explicit dates, citations, uncertainty, and reconstruction labels.

## Screensaver and reliability (P1/P2)

- [ ] Implement Windows `/p` preview embedding and test `/s` activation and input exit on Windows.
- [ ] Cover multiple monitors, lock/sleep/resume, low-power behavior, and background frame-rate reduction.
- [ ] Add long-duration soak tests, crash recovery, and offline/network-loss tests.

## Release discipline

Update CHANGELOG.md and this roadmap with each milestone. Preserve tested controls and preferences. Keep unsigned previews visibly separate from signed public releases. Prefer local tests while iterating; do not repeatedly trigger failing workflows or change the user's global GitHub notification settings.
