# Living Earth 3D

An offline-first interactive Windows globe and screensaver, built with Godot 4. Released **0.23.0 preview**.

## Windows users

[Download LivingEarth3D-Setup-0.23.0.exe](https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.23.0/LivingEarth3D-Setup-0.23.0.exe), double-click, install, then open the desktop shortcut. No ZIP extraction, terminal, separate runtime, or Godot setup is needed. This is an unsigned preview. The user confirmed successful download and automatic updating on 2026-11-01, and working Camera Wall/cameras previously. Windows CI verifies installation and rollback; physical GPU/DPI checks remain outstanding.

The real globe emerges from darkness with illuminated Earth branding. Drag to spin with gentle inertia, scroll or double-click to zoom, and use **Full Earth** or Home to reset. F11 toggles fullscreen. Earth stays centered and proportional at native viewport resolution, including ultrawide and 4K/5K sizes. Compact controls scale automatically with window resolution. Panels adapt to smaller windows; an optional wide Command Center overview uses spare space.

The navigation bar opens **Explore**, **Live Earth**, **Cameras**, **Command Center**, and **Screensavers**. Settings contains display/GPU information, genuine 4K and lower-memory 2K texture presets, offline cloud/star/Moon toggles, and 30 FPS power saving. The normal 60 FPS limit also respects lower monitor refresh rates. This is a cap, not a promise of performance on every GPU. Preferences and favorites stay local.

Explore six curated destinations, an offline atlas, or coordinates. Worldwide search uses OpenStreetMap Nominatim only when requested. Selecting one of eight image cameras opens its actual camera image inside the app, with optional source-specific refresh and explicit retrieval/error states. Four external video/seasonal venues open official websites. These images are not continuous video; capture freshness and future availability are not guaranteed. The Command Center requests USGS M2.5+ past-day earthquakes, with event UTC times, retrieval timestamps, disk cache, and explicit unavailable/cached states. No observations are fabricated. **Live Earth** explains the difference between offline imagery, periodic data and external services.

Version 0.6.1 adds **Cameras → Open Camera Wall** with 1/2/4/6/9-view layouts and saved collections. Eight distinct image-camera sources are available; duplicate tiles share downloads, with at most two requests at once. Offscreen/hidden feeds pause. **Live Earth → Current UTC sunlight** enables an approximate seasonal day/night boundary, calculated offline from the device clock; it does not make clouds, Moon or stars current observations. The Windows installer passed installation/rollback checks; existing updater-enabled installs receive subsequent authenticated releases automatically.

Six offline screensaver styles offer Ambient Earth, Discovery journeys, Night lights, Deep space, Daylight Earth and Orbital drift. The in-app preview uses the current display and returns on input after a short grace period; the Windows screensaver manages per-monitor hosts. Windows screensaver selection is optional. Native Screen Saver Settings preview embeds the actual Earth, and fullscreen saver hosts cover each attached monitor: up to four animated Earth views, with additional displays black. Native saver views use 2K/30 FPS; small Windows preview uses 15 FPS. Physical mixed-DPI/multi-monitor performance remains a field check. Clouds drift as offline artwork. Lighting is cinematic by default, with optional approximate current UTC sunlight. Stars and Moon placement remain illustrative. The Moon uses a verified 4K NASA surface and dated phase geometry; its observatory distinguishes hourly 2026 NASA geometry from later estimated disks. Source detail remains 4K even on larger displays.

**Install once, then update from the app.** Version 0.5.3 includes automatic updates enabled by default. It checks at startup and every 30 minutes while open, downloads authenticated releases, and installs silently when you close the app. **Settings → Update and restart now** applies a ready release with a graceful restart; the Automatic updates toggle pauses/resumes updates. Both minor and major releases use the same process. Favorites, interface size, sound and other preferences remain local.

Releases require a valid signature from the public key pinned in the installed updater, plus matching installer and installed-file hashes. Windows publisher signing is separate: this bootstrap installer remains an unsigned preview. Versions 0.5.2 and older need this installer once to obtain the new updater. A Windows CI run verified silent installation, preservation of user data, running-app protection and restoration of previous files after a deliberately failed verification. Physical GPU/DPI and visible-app restart field tests remain separate. See [docs/AUTO_UPDATE.md](docs/AUTO_UPDATE.md).

## New in 0.23.0

**Move the pointer outside the app for an unobstructed scene.** Menus and map/tour markers disappear; returning restores the same page and typed values. Automatic hiding is on by default, with an opt-out in Space Studio. H or **Clean view** also hides controls while inside; pointer movement or H/Esc returns. Text entry and native save/backup dialogs remain usable. Hidden camera requests pause.

**Live Earth → Space studio** makes Moon and galaxy independently optional, with scene presets and galaxy brightness/orientation controls. The Moon choice now applies to all six screensaver styles, including Deep Space. The bundled Milky Way uses ESO/S. Brunier's photographic panorama: native 4K on desktop, 2K in native savers, with visible CC BY 4.0 credit. It is a historical all-sky composite, not an exterior photo or a current/local-sky map. [Source/rights and feature details](docs/SPACE_STUDIO.md).

**Save picture** exports a chosen-file PNG of the clean scene at the actual viewport resolution. Menus/dialogs are excluded; any galaxy credit remains. No upscaling, startup image downloads, location tracking or automatic wallpaper change.

All 1,773 source checks, sixteen native rendering suites, packed resources and fresh Windows release gates passed. Actual OS cursor exit/return, preserved page/typed values, optional Moon and clean PNG export passed in the installed EXE; seven exact framebuffers, upgrades from 0.5.2/0.22.0, rollback, timer/settings and the 605-second native saver soak also passed. Independent public delivery/signature checks passed before promotion. Separate production updater roundtrip is pending. [Validation](docs/VALIDATION-0.23.0.md).

## New in 0.22.0

**Live Earth → Satellite weather · regional infrared → Load** requests a supported NOAA GOES-West or GOES-East scene through NASA GIBS. **Region** centers the selected/retained coverage; **Return** restores your previous offline Earth or dated NASA mosaic. Recent and one/three/twelve-hour earlier choices use actual advertised scans, with an explicit thirty-minute arrival buffer for the recent choice.

The view shows the nominal scan UTC date/time, retrieval time, age/old-scene warning and NASA false-color brightness-temperature legend. It shows cloud tops and land/ocean temperature patterns, not natural-color clouds, rainfall, forecasts or surface air temperature. Coverage is regional: Pacific/Americas/western Atlantic, not the Philippines or all Earth. Transparent areas remain outside-coverage/unavailable. Failed or cancelled loads retain the old image with its original identity. No automatic imagery downloads or location tracking.

Moon, infrared, Journey studio and Sunlight explorer now appear together at the top of Live Earth and stay visible in small/laptop windows. The 4K Moon/calendar and direct ten-minute/optional-sign-in screensaver setup from 0.21.0 remain included.

All 1,735 source checks, fifteen native rendering suites, packed resources, fresh Windows upgrades from 0.5.2/0.21.0, rollback, timer/settings, installed controls, seven exact framebuffer sizes and the 605-second native preview soak passed. Independent public delivery and release-signature verification passed before promotion. The separate production updater roundtrip also passed ([run 41340742001](https://github.com/nortja/Living-earth-3d/actions/runs/41340742001)). [Validation and limits](docs/VALIDATION-0.22.0.md).

## New in 0.21.0

**Live Earth → Moon & Hebrew calendar** opens a large NASA 4K lunar viewer with Now/date/event controls, dated phases, traditional Hebrew festival tags, Israel/Diaspora choice and sourced lunar/solar dates through 2030. Hebrew civil dates show the preceding sunset date. NASA hourly geometry covers 2026; later disks are explicitly estimated between published phase events. Placement is illustrative, with no local-sky/terrain/eclipse claim.

**Screensavers** now offers a direct idle-time selector (ten minutes by default), optional Windows sign-in on resume, and **Apply timer · enable Living Earth 3D**. Preview alone does not activate Windows idle screensaving. The desktop app no longer inhibits idle screensaving. Organization policy and other applications/power settings can still affect activation.

**Live Earth → Journey studio** builds an eight-stop offline tour with city lookup, editable stops, great-circle paths, approximate distances and Play/Pause/Next. Tours are session-only and stop for manual exploration, backgrounding, navigation or screensaver preview.

All 1,689 source checks, native rendering, actual Windows upgrades/rollback/settings and timer readback, installed desktop resources, exact display sizes through 5K and a ten-minute native preview/lifecycle soak passed. Public delivery/source and the pinned-key signature were independently verified. Production Windows updater roundtrip 41336561468 passed authenticated staging, cancellation and normal-exit installation; see [validation](docs/VALIDATION-0.21.0.md).

## New in 0.19.0

**Live Earth → Sunlight explorer** or **Sunlight here** on a destination card opens a temporary offline sunlight simulation. Scrub ±12 hours in fifteen-minute steps, see geometric Sun height and daylight/twilight for the selected place, and use **Now** or **Finish preview**. UTC and simulation status stay visible. Closing, navigating away or previewing the screensaver restores the previous lighting and loaded satellite view without fetching it again. Approximate geometry excludes terrain, atmospheric refraction and weather. All 1,168 source checks and fresh native/Windows/framebuffer/lifecycle release gates passed. See [validation](docs/VALIDATION-0.19.0.md).

## New in 0.18.2

Weather globe keeps Load/refresh and Cancel together, with its loaded-place filter and picker fully visible in small windows. Data, units, freshness, privacy and request behavior stay the same. All 1,118 source checks, fresh Windows/native release gates and exact 1080p–5K software framebuffer checks passed. See [validation](docs/VALIDATION-0.18.2.md).

## New in 0.18.1

Small-window offline search now keeps its first result fully visible and puts paging controls in one row. Performance recordings take the screen index from the one-second report poll; other configuration fields stay per-frame, and the report states the screen-index latency. The current Windows installer also passed exact 1080p, ultrawide, 4K and 5K software framebuffer gates. This is validation evidence, not a frame-rate or physical-monitor guarantee. See [validation](docs/VALIDATION-0.18.1.md).

## New in 0.18.0

**Explore → Saved** can export a chosen JSON backup and import/merge it later. Existing entries win, duplicate coordinates are skipped and the 50-place limit remains. Invalid files change nothing; nothing is uploaded or fetched. Backups contain saved names, coordinates, notes and source links, so choose where to keep them. Fresh Windows/native package gates and actual exported-file/merge callbacks passed. See [backup details](docs/SAVED_PLACES_BACKUP.md) and [validation](docs/VALIDATION-0.18.0.md).

## New in 0.17.0

**Explore → Search → Search offline atlas** now includes Natural Earth’s 243-city reference dataset merged with the original places. Search city/country names, common country codes or Latin accent variants and browse eight-result pages without downloading anything. Original names/coordinates are retained; the result is a selected atlas of more than 250 places, not every settlement or street-level imagery. Fresh Windows/native release gates passed. See [atlas sources](docs/OFFLINE_ATLAS.md) and [validation](docs/VALIDATION-0.17.0.md).

## New in 0.16.0

Local performance recordings now retain configuration changes beside their measurements: quality, frame cap, viewport size, interface scale, screen and window mode. Bounded segments keep every frame/active second, with a clearly mixed bucket after many changes. Record and Save stay visible in small windows. This remains a local diagnostic, with no upload or hardware rating. Fresh Windows package/desktop/screensaver gates passed; see [validation](docs/VALIDATION-0.16.0.md) and [report details](docs/PERFORMANCE_CONTEXTS.md).

## New in 0.15.0

**Live Earth → Recent days from orbit** offers the previous seven UTC days of NASA mosaics, defaulting to yesterday. Choosing a day stays local until Load; any retained image keeps its own observation date. Offline Earth remains beside Load in small windows. Only one mosaic stays in session memory. Actual older-day retrieval, native renders and the complete Windows package/desktop/screensaver gates passed. See [validation](docs/VALIDATION-0.15.0.md).

## New in 0.14.0

Weather around Earth now loads 32 public model points. Find loaded places by city, country or common country code; filtering stays local and a selection keeps its correct source identity. Requests remain manual with a ten-minute cooldown. Old sixteen-place caches are ignored; preferences and bookmarks stay intact. Actual 32-place retrieval, native layouts through 5K and fresh Windows package/desktop/screensaver gates passed. See [validation](docs/VALIDATION-0.14.0.md) and [coverage sources](docs/WEATHER_COVERAGE_32.md).

## New in 0.13.1

**Live Earth → Yesterday from orbit** loads the previous UTC day's NASA GIBS NOAA-20 / VIIRS true-color mosaic directly onto Earth. Its observation date stays in the header, retrieval time is separate, and black gaps remain visible as unavailable imagery. The optional 2048×1024 mosaic is unshaded and hides artistic cloud drift/night lights; atmosphere and stars remain artistic. **Return to offline Earth** restores the normal globe. It downloads only when requested, stays in memory for the session, and never runs in native screensavers. See [satellite details and credits](docs/SATELLITE_SNAPSHOT.md).

Camera refreshes can use provider ETags to avoid downloading unchanged images. A successful recheck keeps the original retrieval time and delayed-image warning. JPEG dimensions are checked before decoding; wall downloads remain deduplicated and capped at two. Narrow-window satellite controls now show the initial Load action without scrolling. The release also adds an opt-in native first-frame probe for accurate Windows test readiness; ordinary app/saver behavior is unchanged. See [validation](docs/VALIDATION-0.13.1.md). The intermediate 0.13.0 candidate was superseded before automatic-update promotion.

## New in 0.12.4

Camera refreshes reuse validated textures when image bytes are unchanged, preserving current retrieval/source status and delayed-image warnings. Display polling now follows refresh/DPI changes on the same screen, with safe bounded frame budgets and correct fractional-60-Hz handling. Local display reports include all attached monitors and the active screen index. Fresh Windows installation/rollback, settings/dropdown, installed desktop and ten-minute native preview/lifecycle checks passed before authenticated publication. See [validation](docs/VALIDATION-0.12.4.md).

## New in 0.12.3

**Screensavers → Use Living Earth 3D · open Windows settings** selects the installed saver for your Windows account and opens the actual settings dialog. Choose a wait time and click Apply. The separate Windows screensaver settings button opens the dialog without changing your selection, with visible error feedback. Fullscreen Earth returns to a window so settings can be seen. A Start menu shortcut offers the selection action; uninstall clears its own selected saver. Updater status writes now use atomic replacement and bounded reader-lock retries. Actual Windows settings/dropdown, upgrade/rollback, installed desktop and ten-minute native preview/lifecycle checks passed. See [validation](docs/VALIDATION-0.12.3.md).

## New in 0.12.2

Eight image-camera feeds now include Grand Canyon, Look Rock, Alpine Visitor Center and Kīlauea, with local filtering, different-camera wall fill, provider refresh schedules and bounded wall textures. Twelve discoveries include credited offline photographs and a full photo viewer; ten historical contexts retain modern globe imagery. Arrivals open their destination context and camera viewer, and interrupted journeys show a paused state.

**Live Earth → Weather around Earth** adds an optional sixteen-place Open-Meteo model sample: dated temperature points, units, selection, source credit and stale/offline handling. It is requested manually, with no location tracking or startup refresh. **Settings → Performance & support** offers an optional five-active-minute recording and local JSON display report. No report is uploaded. Native screensavers remain silent and do not construct the weather service. See [validation](docs/VALIDATION-0.12.2.md), [photograph credits](docs/DISCOVERY_PHOTOS.md), [historical sources](docs/HISTORY_ATLAS.md) and [weather behavior](docs/WEATHER_MODEL_LAYER.md).

## New in 0.7.0

Explore gains Discover, Search, History and Saved tabs: twelve sourced wonders, daily/surprise journeys, fifty local bookmarks and a Giza/Rome/Tikal era slider on explicitly modern imagery. Command Center adds requested Open-Meteo model weather with units, model/retrieval times and cache/error handling. Daylight Earth and Orbital drift expand screensavers to six. Giant Forest becomes a fourth in-app image camera. Windows upgrades from 0.5.2 and 0.6.1, rollback and installer checks passed before the authenticated update feed was promoted. See [validation](docs/VALIDATION-0.7.0.md).

## New in 0.9.0

Journeys now open a destination card with a name, story, arrival confirmation, approximate coordinates, save and weather actions, and another discovery to continue exploring. Camera journeys automatically open the image viewer or official provider page; closing an image leaves the destination card available. Saved camera destinations reopen their viewer. Ordinary arrivals work offline and screensaver journeys keep browsing controls hidden. See [validation](docs/VALIDATION-0.9.0.md).

## New in 0.8.0

Windows Screen Saver Settings now has an embedded, resizing Earth preview. The native launcher manages per-monitor fullscreen hosts, shared input exit and child-process cleanup. Configuration opens the Screensavers page directly. Actual Windows preview rendering/lifecycle and upgrades from 0.5.2 and 0.7.0 passed before publication. See [validation](docs/VALIDATION-0.8.0.md).

## Development

Use Godot 4.6.3. `godot --path .` starts the app; `project.godot` opens it in the editor.

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/explorer_test.gd
godot --headless --path . --script res://tests/interface_test.gd
# Optional real-network check:
godot --headless --path . --script res://tests/live_update_feed_test.gd
# Native graphics required (not a browser):
godot --path . --audio-driver Dummy --script res://tests/intro_render_test.gd
godot --path . --audio-driver Dummy --script res://tests/render_test.gd
```

[Windows delivery and actual EXE display tests](docs/WINDOWS_RELEASE.md) document platform-specific verification. Behavior tests isolate their preferences. Source/render checks on Linux do not establish Windows GPU, DPI, installation or refresh behavior. The failing GitHub workflow remains disabled with no push/tag triggers, to prevent unwanted failure emails.

See [CHANGELOG.md](CHANGELOG.md), [ROADMAP.md](ROADMAP.md), and `assets/` for credits and progress.
