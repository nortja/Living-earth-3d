# Living Earth 3D

An offline-first interactive Windows globe and screensaver, built with Godot 4. Released **0.12.3 preview**.

## Windows users

[Download LivingEarth3D-Setup-0.12.3.exe](https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.12.3/LivingEarth3D-Setup-0.12.3.exe), double-click, install, then open the desktop shortcut. No ZIP extraction, terminal, separate runtime, or Godot setup is needed. This is an unsigned preview. The user confirmed the 0.8.0 automatic update and working Camera Wall/cameras. Windows CI verifies installation and rollback; physical GPU/DPI checks remain outstanding.

The real globe emerges from darkness with illuminated Earth branding. Drag to spin with gentle inertia, scroll or double-click to zoom, and use **Full Earth** or Home to reset. F11 toggles fullscreen. Earth stays centered and proportional at native viewport resolution, including ultrawide and 4K/5K sizes. Compact controls scale automatically with window resolution. Side panels move below the center in smaller windows; an optional wide Command Center overview uses spare space.

The navigation bar opens **Explore**, **Live Earth**, **Cameras**, **Command Center**, and **Screensavers**. Settings contains display/GPU information, genuine 4K and lower-memory 2K texture presets, offline cloud/star/Moon toggles, and 30 FPS power saving. The normal 60 FPS limit also respects lower monitor refresh rates. This is a cap, not a promise of performance on every GPU. Preferences and favorites stay local.

Explore six curated destinations, an offline atlas, or coordinates. Worldwide search uses OpenStreetMap Nominatim only when requested. Selecting one of eight image cameras opens its actual camera image inside the app, with optional source-specific refresh and explicit retrieval/error states. Four external video/seasonal venues open official websites. These images are not continuous video; capture freshness and future availability are not guaranteed. The Command Center requests USGS M2.5+ past-day earthquakes, with event UTC times, retrieval timestamps, disk cache, and explicit unavailable/cached states. No observations are fabricated. **Live Earth** explains the difference between offline imagery, periodic data and external services.

Version 0.6.1 adds **Cameras → Open Camera Wall** with 1/2/4/6/9-view layouts and saved collections. Eight distinct image-camera sources are available; duplicate tiles share downloads, with at most two requests at once. Offscreen/hidden feeds pause. **Live Earth → Current UTC sunlight** enables an approximate seasonal day/night boundary, calculated offline from the device clock; it does not make clouds, Moon or stars current observations. The Windows installer passed installation/rollback checks; existing updater-enabled installs receive subsequent authenticated releases automatically.

Six offline screensaver styles offer Ambient Earth, Discovery journeys, Night lights, Deep space, Daylight Earth and Orbital drift. The in-app preview uses the current display and returns on input after a short grace period; the Windows screensaver manages per-monitor hosts. Windows screensaver selection is optional. Native Screen Saver Settings preview embeds the actual Earth, and fullscreen saver hosts cover each attached monitor: up to four animated Earth views, with additional displays black. Native saver views use 2K/30 FPS; small Windows preview uses 15 FPS. Physical mixed-DPI/multi-monitor performance remains a field check. Clouds drift as offline artwork. Lighting is cinematic by default, with optional approximate current UTC sunlight. Moon and stars remain cinematic. Source detail remains 4K even on larger displays.

**Install once, then update from the app.** Version 0.5.3 includes automatic updates enabled by default. It checks at startup and every 30 minutes while open, downloads authenticated releases, and installs silently when you close the app. **Settings → Update and restart now** applies a ready release with a graceful restart; the Automatic updates toggle pauses/resumes updates. Both minor and major releases use the same process. Favorites, interface size, sound and other preferences remain local.

Releases require a valid signature from the public key pinned in the installed updater, plus matching installer and installed-file hashes. Windows publisher signing is separate: this bootstrap installer remains an unsigned preview. Versions 0.5.2 and older need this installer once to obtain the new updater. A Windows CI run verified silent installation, preservation of user data, running-app protection and restoration of previous files after a deliberately failed verification. Physical GPU/DPI and visible-app restart field tests remain separate. See [docs/AUTO_UPDATE.md](docs/AUTO_UPDATE.md).

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
