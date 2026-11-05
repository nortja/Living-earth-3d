# Living Earth 3D — current roadmap

Updated 2026-11-05. Latest released baseline: 0.25.1 (synchronized Moon zoom and personal cinematic Scene Library, with pointer-out clean view, optional Moon, offline 4K Milky Way, lunar calendar, tours, regional infrared and explicit Windows idle setup). One Windows installer, then authenticated automatic updates; the base Earth remains useful offline.

## Release 0.25.1 — interruption reliability

- Manual Scene Library Next now obeys modal/minimize/screensaver interruption while playback is paused. The separately versioned candidate passed fresh 2,521 source assertions, seventeen native suites, legacy/current 0.25.0 upgrades, preservation after rollback, seven Windows framebuffers and a 605-second saver soak in run 41870662412.
- Exact public installer and pinned-key signed metadata verified before authenticated feed promotion. Production updater roundtrip pending. [Validation](docs/VALIDATION-0.25.1.md).

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

## Previous release — 0.12.2

- [x] Eight verified in-app periodic-image feeds and four official external venues; searchable camera catalog, image-only filter and different-camera wall fill.
- [x] Provider-specific refresh/backoff, slower-feed unchanged warnings and bounded wall textures.
- [x] Twelve licensed offline discovery photographs with visible creator/license/source credit and full viewer; ten sourced historical teaching contexts on modern imagery.
- [x] Optional sixteen-place Open-Meteo model layer, dated clickable points, units, cache validation and stale/offline states. Manual requests only; no device location or native-saver service.
- [x] Local five-active-minute performance recording and JSON display report; unavailable release engine-memory counters explicitly represented as null.
- [x] Interrupted-journey status and Full Earth destination cleanup. Existing destination and camera handoffs preserved.
- [x] Fresh export/native/Windows package gates, authenticated 0.12.2 feed promotion and production staging/cancellation/normal-exit update roundtrip (successful second attempt; initial filesystem deferral retained as open evidence).

## Previous release — 0.12.3

- [x] Actual Windows settings action, explicit per-user Earth selection, native dropdown name, visible failure states, fullscreen handoff and Start menu shortcut.
- [x] Ownership-aware screensaver unregister on uninstall; saved wait time/resume-password preferences retained.
- [x] Atomic updater status replacement, bounded reader-lock retries and advisory failure handling; 211 status checks and 16 security checks pass on each Windows PowerShell runtime.
- [x] Fresh source/native/build gates, actual Windows settings/dropdown and upgrade/rollback checks, installed desktop validation and ten-minute native preview/lifecycle soak.
- [x] Verified public installer and authenticated feed promotion. Production signed-feed download/staging, cancellation and normal-exit installation also passed; see [validation](docs/VALIDATION-0.12.3.md).

## Development follow-up — 2026-10-31

- Local display-report export now includes all attached monitors (pixel size, desktop position, DPI, scale and refresh), plus the active screen index. This is additive diagnostic evidence for mixed-DPI and monitor moves, not a hardware pass/fail result.
- Godot 4.6.3 import and 315 headless checks passed: performance (25), interface (47), explorer (56), UI scale (187). Native monitor-inventory assertions were added to the existing render harness but have not run in this environment. Windows/native packaging and release checks subsequently passed for 0.12.4; see its validation document.
- A daily continuation run is configured for around 8 AM America/Los_Angeles. It must skip overlapping work and promote updates only after the existing release gates.

## Previous release — 0.12.4

- [x] Reuse validated unchanged camera textures without changing retrieval, source-time, failure recovery or delayed-image warnings.
- [x] Refresh monitor details/frame budget after changes on the same monitor; handle non-finite and fractional refresh values safely.
- [x] Export attached-monitor geometry, DPI, scale, refresh and active screen index in the optional local report.
- [x] Fresh 757 source checks, native layouts through 5K, Windows upgrades/rollback/settings, actual installed desktop and a 605-second preview/lifecycle soak passed. Public installer downloaded and verified; exact manifest signed with the existing trust key. Production signed-feed staging/cancellation/normal-exit roundtrip also passed on Windows.
- [x] Continued into 0.13.1; 0.13.0 was superseded before feed promotion.

## This release — 0.19.0

- [x] Temporary offline ±12-hour UTC sunlight simulation in fifteen-minute steps, with Now/Finish, selected-place geometric Sun height and daylight/twilight labels.
- [x] Preserve lighting preferences and retained satellite texture/date; restore on close/navigation and clear simulated time before screensaver preview. No feature-triggered provider requests, clock changes or preference writes.
- [x] 1168 source checks, seven strict native sunlight layouts through 5K, full Windows upgrade/rollback/settings/installed-desktop/framebuffer gates and 605.2-second native preview/lifecycle soak passed in run 41326613347.
- [x] Independent public verification run 41328300602 passed; exact installer and four-file metadata checked locally, signature independently verified against pinned key, authenticated source/feed promoted atomically.
- [x] Final production Windows updater roundtrip 41328629723 passed authenticated staging, cancellation, normal-exit installation and installed-file verification; see [validation](docs/VALIDATION-0.19.0.md).

## Previous release — 0.18.2

- [x] Loaded weather filter/picker fully visible at small sizes; compact primary actions preserve source/status, toggle, units and all request rules.
- [x] Reproduced the old 800×600 clipping, then passed all 1118 source checks, seven native layouts and actual installed Windows visibility checks.
- [x] Full source/security/export/native, Windows upgrades/rollback/settings, five-minute installed recording, exact 1080p/ultrawide/4K/5K framebuffers and 605.2-second native preview/lifecycle passed in run 41232467353.
- [x] Public installer/source provenance and pinned-key signature verified; authenticated source/feed promoted after successful 0.18.1 production update. 0.18.2 production Windows updater roundtrip passed; see release validation.
- [x] Supplemental one-hour frozen 0.16.0 and 0.18.0 native Linux runs completed with zero failures; current 0.18.2 thirty-minute run also completed with zero failures.

## Previous release — 0.18.1

- [x] First offline search result fully visible, compact first/middle-page controls and explicit input/fixture consistency.
- [x] Recording monitor index sampled at the report poll, with one-active-second latency stated; quality/cap/viewport/scale/window fields remain per-frame. No speedup claim is inferred from VM comparisons.
- [x] 1117 source checks; complete Windows upgrade/rollback/settings, installed resources/recording and exact 1080p/ultrawide/4K/5K framebuffer matrix; 605.1-second preview/lifecycle passed in run 41231442929.
- [x] Public installer/source provenance and pinned-key signature verified; authenticated source/feed promoted after successful 0.18.0 production update. 0.18.1 production Windows updater roundtrip passed; see release validation.
- [x] Compact weather patch 0.18.2 passed fresh loaded-place visibility and full release gates.

## Previous release — 0.18.0

- [x] Explicit chosen-file JSON backup and non-replacing merge of saved places, with duplicate/capacity feedback, strict validation and 50-place bound.
- [x] Failed imports preserve preferences; flushed temporary exports precede rename; no automatic import/upload/provider request; chooser released for preview.
- [x] 1115 source checks, native backup layouts and full Windows upgrades/rollback/settings, compiled chosen-file callbacks/actual file merge, five-minute recording and 605-second preview/lifecycle passed in run41229309398.
- [x] Public provenance/bytes and pinned-key signature verified; authenticated source/feed promoted after successful 0.17.0 production update. 0.18.0 production Windows updater roundtrip passed; see release validation.
- [x] Follow-up 0.18.1 passed fresh first-result, monitor-sampling and current-package Windows framebuffer gates.

## Previous release — 0.17.0

- [x] Natural Earth 243-city reference dataset merged with original atlas; original coordinates retained, matching aliases merged and nearby landmarks kept distinct.
- [x] Local country/code/diacritic terms, ranked results, complete eight-result paging and separate coordinate/online search. Public-domain source, pinned hash and reproducible conversion recorded.
- [x] 1079 source checks, seven native layouts through 5K and full Windows upgrades/rollback/settings, installed resources/paging/recording and 605.1-second native preview/lifecycle passed in run 41228250585.
- [x] Public source/bytes and pinned-key signature verified; authenticated source/feed promoted after successful 0.16.0 production roundtrip. 0.17.0 production Windows updater roundtrip passed; see release validation.
- [x] Supplementary frozen 0.16.0 actual Windows framebuffer matrix passed at 1080p, ultrawide, 4K and 5K using explicit post-start resizing on a small virtual desktop; physical monitor/DPI checks remain separate.

## Previous release — 0.16.0

- [x] Bounded local recording contexts for quality, cap, viewport, UI scale, screen and window mode; exact frame/time totals and explicitly mixed overflow.
- [x] Readable Record/Save controls at small sizes; no upload, personal content or native-saver sampling.
- [x] 1058 source checks, six native layouts, Windows upgrades/rollback/settings, installed desktop/real five-minute export and 605.1-second native preview/lifecycle passed in run 41227593377.
- [x] Public bytes/source provenance and pinned-key signature verified; authenticated source/feed promoted after 0.15.0 production update passed. 0.16.0 production Windows updater roundtrip passed; see release validation.

## Previous release — 0.15.0

- [x] Previous seven UTC satellite days, yesterday by default, local selection until explicit Load and retained observation identity on failed/cancelled requests.
- [x] Readable, visible Offline Earth beside Load at small sizes; one-image memory bound and no automatic/native-saver requests.
- [x] 1049 source checks, actual October24 retrieval and four native layouts through 5K. Final Windows upgrade/rollback/settings, installed desktop and 605.1-second preview/lifecycle gates passed in run 41227218923.
- [x] Public installer provenance/bytes verified and pinned-key signed metadata promoted atomically. Production Windows updater roundtrip passed; see release validation.

## Previous release — 0.14.0

- [x] Expanded explicit Open-Meteo model sample to 32 sourced public places, local city/country filtering and correct navigation after filtering/omitted rows.
- [x] Ten-minute manual cooldown, fixed dataset/cache validation, no startup/native-saver downloads and preservation of preferences/bookmarks.
- [x] 1036 source checks, actual 32-place retrieval and seven native layouts through 5K. Final Windows upgrade/rollback/settings, installed desktop and 605.1-second native preview/lifecycle gates passed in run 41226878053.
- [x] Verified public installer/source provenance and pinned-key signed metadata promoted atomically; Production Windows updater roundtrip passed; see release validation.

## Previous release — 0.13.1

- [x] Optional requested previous-day NASA GIBS NOAA-20 / VIIRS surface, dated header/status, true no-data gaps, unshaded rendering, immediate offline return and native-saver exclusion.
- [x] Camera ETag/304 revalidation with original retrieval time, separate check time, retained source metadata and delay warnings; pre-decode bounded JPEG dimensions.
- [x] Initial satellite Load action visible in narrow windows, with source/native/installed-Windows assertions.
- [x] Native graphics preflight waits for a real frame plus a visible window, keeps its close deadline and retains failure logs. It runs only with an explicit validation flag.
- [x] Maintainer release-provenance/download verification with ten failure-path tests; no private key or installer execution in the verifier.
- [x] Local sixteen-suite coverage: 807 behavior/layout cases plus 200 malformed-image inputs. Actual eight-camera retrieval, conditional provider 304 and NOAA-20 retrieval/rendering passed.
- [x] Final complete Windows/native pipeline 41224574684 passed, public installer provenance/bytes verified and authenticated metadata promoted. Production Windows updater roundtrip passed; see release validation.

## Current continuation — 2026-11-01

User confirmed the download and automatic update worked and authorized further roadmap work and surprise additions. This is installed-delivery feedback; it does not establish mixed-DPI, sleep/resume or overnight behavior.

Released 0.19.0 adds **Sunlight explorer**: a temporary offline ±12-hour UTC lighting slider, geometric Sun height and selected-place daylight/twilight context. It restores the saved lighting choice and loaded satellite identity on close/navigation and excludes simulated time from screensaver preview. All release gates and independent public verification passed; the signed 0.19.0 feed is promoted. Production Windows updater roundtrip 41328629723 also passed.

| Stage | Deliverable | Completion condition |
| --- | --- | --- |
| Released | Sunlight explorer and clear simulation/return controls | Source/native/Windows/framebuffer/lifecycle gates, public bytes/signature and production updater passed |
| Next | Authorized continuous in-app video prototype | One documented-permission feed, supported Windows playback, bounded resources, pause/close/saver cleanup and network failure recovery |
| Released 0.22.0 | Requested regional NOAA infrared | Provenance and permitted redistribution, actual observation time/coverage, bounded opt-in retrieval, stale/offline fallback and GPU budget |
| Reliability alongside features | Physical Dell and mixed-display field checks; longer screensaver observation | Record actual scaling/monitor-move/sleep evidence without inferring hardware results from VM rendering |
| Later | Astronomical accuracy, verified higher-detail textures and distribution hardening | Documented accuracy/licenses, ordinary-PC targets, publisher signing and update-key migration plan |

See the bounded [video pilot](docs/VIDEO_PILOT.md) and [cloud imagery pilot](docs/CLOUD_IMAGERY_PILOT.md) for implementation and acceptance gates.

## Previous release — 0.21.0

- [x] Journey studio, Windows idle timer/secure-resume setup and removal of desktop keep-screen-on inhibition, NASA 4K lunar rendering and north-up Moon viewer, dated lunar cycles, traditional Hebrew festivals with sunset-date semantics and Israel/Diaspora schemes, and sourced celestial calendar. [Coverage/limits](docs/LUNAR_OBSERVATORY.md).
- [x] All 1,689 source checks and fourteen native render suites passed. Fresh Windows source/security/export, upgrades/rollback/settings, ten-minute/secure-resume readback, installed lunar/tour/calendar resources, five-minute recording, exact five-size framebuffer matrix and native preview/lifecycle soak passed in run 41333845054. Physical Dell/DPI/sleep/sign-in behavior remains field work.
- [x] Independent public delivery run 41335986912 and a separate local download/provenance/helper/checksum verification passed. Exact metadata signed outside git/CI and independently checked against the pinned key before atomic source/feed promotion. Production Windows updater roundtrip 41336561468 passed on its first attempt. [Validation](docs/VALIDATION-0.21.0.md).
- Initial automatic-approval publication block was explicitly resolved by the user's approval of this exact public repository and validated updater rollout. The source-only 0.20.0 draft was superseded, never feed-promoted.

## Next priorities


1. **Field validation:** user confirmed the download and automatic update worked on 2026-11-01; next observe new screensaver behavior, new desktop/taskbar icon, all camera states, visible-window restart, physical Dell scaling, frame times, memory, fullscreen, sleep/resume and monitor moves.
2. **Continuous video:** add authorized in-app streaming playback. Current NPS views are periodically refreshed camera images; other streams open the provider website. No continuous embedded video is delivered yet.
3. **Camera Wall:** eight image sources and bounded textures are implemented; prioritize authorized continuous-video playback and optimize further after actual Dell measurement.
4. **Living planet:** UTC sunlight is released; requested point-model weather is released in 0.7.0. Sixteen-place model weather points are released in 0.12.2. A requested, dated previous-day NASA satellite mosaic is implemented in 0.13.1. Expanded to 32 model points in 0.14.0. Next: licensed current cloud refresh and coverage guided by actual use. Default clouds/Moon/stars remain cinematic; the satellite view shows observed imagery only for its stated date.
5. **Screensaver integration:** Native /p preview and per-monitor hosts are released. Next: physical /s mixed-DPI/monitor checks, lock/sleep/resume, performance and overnight hardware tests. One-hour Linux renderer and Windows preview foundation tests supplement the current-package gates; they do not establish physical hardware behavior.

## Updater resilience follow-up

- [ ] Reproduce the intermittent production-roundtrip staging filesystem deferral from run 39536745077 attempt 1. Attempt 2 passed unchanged. Investigate transient file contention and bounded atomic status-write replacement without weakening signature/hash checks or active-app protection.
- Released in 0.12.3: atomic status replacement, bounded I/O retries and advisory failure handling. 205 local status checks and 211 Windows status checks per runtime pass, alongside 16 security checks. Windows reader-contention, package and release gates passed; see [status resilience](docs/UPDATER_STATUS_RESILIENCE.md). Original production deferral cause remains unconfirmed.

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

## Previous release — 0.22.0

- [x] Two explicitly requested NOAA/NASA regional infrared products with exact scan/age/source identity, native-text temperature legend, retained observation on failure, immediate Return and preview isolation.
- [x] Main Live Earth actions appear first and fit small/laptop windows.
- [x] Fresh source/native/packed-resource checks and full Windows pipeline 41338329092 passed. Upgrades from 0.5.2 and 0.21.0, rollback, timer/settings, installed controls, seven exact framebuffers and the 605-second lifecycle soak passed.
- [x] Public delivery verifier 41340562973 and a separate local public download/provenance/helper/hash check passed. Exact signed discovery files verified against the pinned key before atomic source/feed promotion.
- [x] Separate production Windows updater roundtrip 41340742001 passed: authenticated staging, cancellation without replacement, normal-exit install and four installed-file hashes; no unwanted restart.

Global/Asia clouds, continuous video, Authenticode publisher signing and physical Dell/mixed-DPI/sleep tests remain open. [Validation](docs/VALIDATION-0.22.0.md) and [product scope](docs/CLOUD_IMAGERY_PILOT.md).

## This release — 0.23.0

- [x] Pointer-out clean scene, preserved UI values, manual H recovery, saved opt-out, modal handling and paused hidden camera work.
- [x] Optional Moon respected in all six styles; real licensed 4K/2K Milky Way, brightness/orientation, scene presets and visible credit.
- [x] Native-resolution chosen-file PNG postcards with clean controls and state restoration.
- [x] Source/native/packed-resource checks and full Windows pipeline 41347708600 passed: current 0.22.0 and legacy 0.5.2 upgrades, rollback, timer/settings, actual OS pointer exit/return, PNG, seven exact framebuffers and 605-second saver soak.
- [x] Independent public verifier 41349696038 and separate local exact-URL/source/helper/hash verification passed; pinned-key detached signature verified before atomic source/discovery promotion.
- [x] Separate production Windows updater roundtrip 41349982349 passed on its first attempt: signed staging, cancellation without replacement, normal-exit install, four file hashes and no unwanted restart.

Physical Dell/DPI/mixed-monitor/sleep tests, continuous video, global/Asia cloud coverage and Authenticode publisher signing remain separate work. [Validation](docs/VALIDATION-0.23.0.md).

## This release — 0.24.0

- [x] Moon apparent size and relative spacing follow Earth's actual camera zoom, including the final tween frame; optional visibility and default composition retained.
- [x] Eight persisted offline compositions, bounded clean thumbnails, Use/Remove/Undo and timed fading playback. Temporary visual defaults and competing-discovery ownership are tested; desktop only, no new native saver style or provider service.
- [x] All 1,885 source checks, seventeen native suites, actual installed Windows scene capture/transition/Moon zoom, seven exact framebuffers, upgrades/rollback/settings and ten-minute saver lifecycle passed in 41356762602.
- [x] Independent public provenance/download check 41358905420, separate local verifier and pinned-key signature verification passed before atomic source/feed promotion.
- [x] Final production Windows staging/cancellation/normal-exit updater roundtrip 41359112627 passed. See [validation](docs/VALIDATION-0.24.0.md).


## Release 0.25.0 — shuffled cinematic scenes

- Opt-in persisted shuffle with a bounded no-adjacent-repeat queue; original saved-order playback remains the default. Manual selection and list changes reset the queue safely; changing order pauses playback.
- 2,519 source assertions across 26 suites, seventeen native suites, actual installed Windows toggle/transitions, seven framebuffers, current/legacy upgrades, rollback/settings and 605-second saver lifecycle passed in 41364004217.
- Independent public download/provenance run 41366552874 and pinned-key signature checks passed before automatic-update promotion. Production Windows updater roundtrip 41366725051 passed staging/cancellation/normal-exit installation and four-file verification. [Validation](docs/VALIDATION-0.25.0.md).
