# Living Earth 3D — living roadmap

Build a beautiful offline-first Windows globe and calm screensaver. Keep installation to one EXE, interactions simple, network features optional, audio off by default, and every public release testable and traceable.

## Current milestone: 0.6.0 development

Delivered on `development`: five named navigation areas with compact Explore subnavigation; responsive translucent panels and blue outlines; monitor-sized startup and narrow-screen scale limits; approximate UTC sunlight/daylight line; six camera venues with selectable globe markers, viewer clock, surprise selection and external provider players; point weather model/cache/context handling; twelve daily wonders with sources; historical atlas timeline and explicitly modern imagery; six screensaver styles. Existing 4K/2K maps, independent clouds, intro, icons, controls, favorites and strict update trust remain.

Delivery maintenance was separately pushed to `main`: process-safe Windows build runner, fresh log/error detection, bounded execution, manual-only read-only CI with native EXE checks and retained diagnostics, and one verified updater restart after silent installation. These changes have local process/parser checks, not a successful Windows runner result. The old workflow remains disabled; no repeated failure runs were started.

## Next cycle — finish the external validation gate (P0)

- [ ] User publishes the saved cloud environment configuration; then retry actual GitHub API, USGS, Open-Meteo, Nominatim and provider-page checks. Draft saving does not change runtime access. No provider secrets are required.
- [ ] Once GitHub API works, run one controlled manual Windows build on `development`; inspect diagnostics and correct any platform-specific failure before enabling further runs. Do not restore push/tag triggers.
- [ ] Execute real Windows installer upgrade/uninstall, shell icons, native 1080p/ultrawide/4K/5K, Dell DPI/refresh and integrated-GPU frame-time tests. Existing evidence is Linux native/cross-package; user-confirmed 0.3 installation is historical.
- [ ] Execute an actual hours-long Windows screensaver soak, multi-monitor transitions, sleep/resume and input exit. A bounded native run and six simulated hours do not satisfy that gate.
- [ ] Provision a trusted signing certificate securely in CI and execute same-publisher signed update, cancellation, recovery and signature-rejection tests. Unsigned development previews remain manual-install only.
- [ ] Keep development feed separate; establish a stable feed and protected promotion only after all required evidence passes. No stable app is promoted in this cycle.

## Next cycle — depth and discovery (P1)

- [ ] Verify the six camera provider pages and permitted playback modes; then add authorized in-app playback with real stream health/capture timestamps. External browser player windows are the current delivery.
- [ ] Curate waterfalls, coastlines, mountain valleys, remote communities and ancient sites with explicit availability, privacy/rights review and sources. Expand the twelve-place loop toward a year of daily discoveries.
- [ ] Add licensed terrain elevation and source-verified 8K imagery; current globe has 4K maps and no real mountain geometry.
- [ ] Add attributed current cloud imagery with capture time, expiry and bounded offline cache. Drifting artwork stays labeled.
- [ ] Add real satellite/ISS positions from timestamped orbital elements with documented propagation accuracy, then pass predictions. No synthetic tracking labeled live.
- [ ] Add current weather-system overlays, volcano observations, aurora forecasts and astronomy events with explicit freshness and accuracy. Point weather is a model estimate.
- [ ] Extend Time Machine from dated site markers to sourced historical footprints/borders, uncertainty and reconstructions. Create a licensed imagery/reconstruction pipeline before transforming the rendered planet; modern imagery must stay labeled until then.
- [ ] Add a UI-scale override based on real Windows DPI findings and tune power presets from measured frame times.

## Next — make Windows delivery dependable (P0)

- [ ] Move recurring installer storage from dedicated Git branches to release assets or an artifact host while retaining fixed-origin and signature validation.

- [x] Basic 0.3.0 installation and launch confirmed by the user on Windows.
- [ ] Test 0.6.0 development desktop/taskbar icon, intro, upgrades, favorite preservation, uninstall, and reinstall on Windows 10/11 x64.
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
- [x] Add approximate UTC solar illumination and seasonal solar declination with documented model limits. Seasonal surface imagery remains planned.
- [x] Add optional stars and Moon with restrained lighting and resource costs, clearly labeled as artistic backdrops.
- [ ] Add real astronomical positions as a separate, documented mode.
- [x] Improve atmosphere, coastline detail, night-light transition, and artistic cloud shade while preserving compatibility-renderer support.
- [ ] Investigate physically based scattering and terrain without making integrated GPUs unusable.

## Next — meaningful exploration (P2)

- [x] Add an offline city/landmark/natural-wonder atlas with selectable geographic markers.
- [x] Implement optional Open-Meteo point weather with units, model time, cache and unavailable states; actual public-provider validation remains blocked.
- [ ] Expand Today's Wonder and curated journeys without intrusive popups.
- [x] Add a dated historical-site atlas foundation with source links and modern-imagery disclosure. Historical geography/reconstruction layers remain planned.

## Screensaver and reliability (P1/P2)

- [ ] Implement Windows `/p` preview embedding and test `/s` activation and input exit on Windows.
- [ ] Cover multiple monitors, lock/sleep/resume, low-power behavior, and background frame-rate reduction.
- [ ] Add long-duration soak tests, crash recovery, and offline/network-loss tests.

## Release discipline

Update CHANGELOG.md and this roadmap with each milestone. Preserve tested controls and preferences. Keep unsigned previews visibly separate from signed public releases. Prefer local tests while iterating; do not repeatedly trigger failing workflows or change the user's global GitHub notification settings.
