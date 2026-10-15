# Living Earth 3D — living roadmap

Build a beautiful offline-first Windows globe and calm screensaver. Keep installation to one EXE, interactions simple, network features optional, audio off by default, and every public release testable and traceable.

## Current milestone: 0.4.0

Completed: genuine 4K daytime/night maps with a lower-memory 2K mode; independent offline clouds; optional stars and Moon; persistent visual and power-saving settings; fixed-project preview update discovery; illuminated Earth branding; real-time Earth-from-darkness intro; drag, inertia, wheel and double-click zoom; full-Earth reset; offline destinations and favorites; simple collapsible controls; 4K and ultrawide rendering; one-file installer packaging; signature-checked updater implementation.

Validated in this milestone: 56 behavior checks; three rendered intro stages; eight quality/resolution render cases; native PE icon payloads; exported embedded project startup; installer contents and checksums. The user confirmed successful 0.3.0 installation and launch on Windows. Version 0.4.0 hardware/installation testing and production signing remain separate requirements.

## Next — make Windows delivery dependable (P0)

- [x] Basic 0.3.0 installation and launch confirmed by the user on Windows.
- [ ] Test 0.4.0 desktop/taskbar icon, intro, upgrades, favorite preservation, uninstall, and reinstall on Windows 10/11 x64.
- [ ] Test 1080p/4K/ultrawide displays with Windows DPI scaling and normal integrated GPUs. Measure frame time and memory, then tune quality settings.
- [ ] Provision an authentic code-signing certificate through secure CI settings. Sign both app and installer; never weaken signature checks for unsigned previews.
- [ ] Verify signed self-update end to end: download, same-publisher verification, consent, close, install, restart, cancellation, and rejection of bad signatures.
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

- [ ] Add an attributed offline landmark/natural-wonder catalog with selectable geographic markers.
- [ ] Add optional live weather through a licensed provider, with fresh/stale/offline states and no required account for the base globe.
- [ ] Expand Today's Wonder and curated journeys without intrusive popups.
- [ ] Add ancient sites and historical layers with explicit dates, citations, uncertainty, and reconstruction labels.

## Screensaver and reliability (P1/P2)

- [ ] Implement Windows `/p` preview embedding and test `/s` activation and input exit on Windows.
- [ ] Cover multiple monitors, lock/sleep/resume, low-power behavior, and background frame-rate reduction.
- [ ] Add long-duration soak tests, crash recovery, and offline/network-loss tests.

## Release discipline

Update CHANGELOG.md and this roadmap with each milestone. Preserve tested controls and preferences. Keep unsigned previews visibly separate from signed public releases. Prefer local tests while iterating; do not repeatedly trigger failing workflows or change the user's global GitHub notification settings.
