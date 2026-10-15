# Living Earth 3D — development

**0.6.0 development preview**, an interactive Windows Earth and cinematic screensaver built with Godot 4.6.3. Next-cycle app changes stay on `development`; `main` retains the existing 0.5 preview plus delivery repairs. No production stable release has been declared.

[Download the development Windows installer](https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.6.0/LivingEarth3D-Setup-0.6.0.exe). One EXE: double-click, install, open the desktop shortcut. No ZIP, terminal, separate Godot/runtime installation or account. Development installs have their own folder, shortcut, uninstall entry and settings directory. Existing preview choices are read once when development preferences do not exist; future saves stay separate. Development builds are labeled in the interface and installer; this preview is unsigned and requires manual installation.

## This cycle

Five clear areas: **Explore Earth**, **Live Earth**, **Global Cameras**, **Command Center**, **Screensaver Settings**. The default view keeps the full planet centered with compact controls. Dark translucent panels, restrained blue borders, smooth transitions, native viewport rendering, signed-distance-field fonts and proportional layout adapt through ultrawide, 4K and 5K sizes. Initial window sizing uses the available monitor; narrow/portrait windows limit UI scale to keep controls reachable. Display/GPU information, 2K/4K maps and a 30 FPS power option remain under Settings. Normal animation caps at 60 FPS and respects lower monitor refresh rates.

Drag to spin with gentle inertia, wheel or double-click to zoom, **Full Earth** or Home to reset, F11 for fullscreen. Existing favorites and timed journeys remain local.

- **Discover:** a sourced, offline editorial catalog of twelve wonders, a deterministic daily UTC selection, surprise destinations and camera connections where curated. The initial rotation repeats after twelve days. Discover, Search and Time Machine have separate compact sections.
- **Live Earth:** optional approximate UTC solar illumination and daylight boundary, calculated locally from the system clock using NOAA-style solar geometry. Cinematic lighting stays available. The 4K imagery is offline, clouds drift as artwork, and Moon/stars use artistic positions. No live cloud or terrain-height data is claimed.
- **Global Cameras:** six official provider venues, clickable globe markers, selection journeys, UTC viewer clock and surprise selection. Provider players open externally, using installed Edge app mode on Windows when available, otherwise the browser. Manual provider-page checks distinguish page reachability from unverified video status. Capture time comes from the provider; embedded playback and verified stream availability are unfinished.
- **Command Center:** requested Open-Meteo point weather estimates with model UTC time and explicit Celsius/km/h units, and USGS M2.5+ past-day observations. Retrieval/cache/failure states preserve location context. Requests never populate invented observations. Satellite orbits, weather-system overlays, auroras, ISS passes, volcano alerts and astronomy events remain planned; official NASA/USGS explorers are linked.
- **Earth Time Machine foundation:** a draggable dated historical atlas for Giza, Imperial Rome and Classic-period Tikal, with source links, approximate teaching intervals and a persistent modern-imagery disclosure. It does not reconstruct cities, redraw borders or display historical satellite imagery.
- **Screensavers:** peaceful rotation, global discovery, night lights, deep space, current-UTC day/night and cinematic orbit. Preview returns on input. Windows preview embedding, multiple-monitor coverage and hours-long hardware soak testing remain open.

## Delivery and validation

Development update metadata uses a separate feed on the `development` branch. It does not advance the `main` preview feed. Automatic replacement still requires a matching trusted Authenticode publisher, valid package signature and SHA-256 verification. Production signing and actual signed-update Windows execution remain outstanding. Silent installers no longer launch the app twice; the signed helper performs one verified restart.

The manual Windows workflow now uses a tested process runner with argument-safe paths, real exit codes, fresh logs and timeouts. It retains diagnostics and has no release-publication permission or push/tag triggers. It remains disabled pending a controlled Windows run, since current cloud access to GitHub API is denied. Linux rendering, cross-built packages and parser fixtures do not establish Windows GPU/DPI behavior or live provider availability. See [release policy](docs/RELEASE_POLICY.md), [validation](docs/VALIDATION-0.6.0.md) and [roadmap](ROADMAP.md).

## Development checks

Set writable XDG data/config/cache directories in restricted cloud environments. From this checkout:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/explorer_test.gd
godot --headless --path . --script tests/interface_test.gd
godot --headless --path . --script tests/cycle06_test.gd
# Native graphics required:
godot --path . --audio-driver Dummy --script tests/render_test.gd
godot --path . --audio-driver Dummy --script tests/intro_render_test.gd
godot --path . --audio-driver Dummy --script tests/experience_render_test.gd
godot --path . --audio-driver Dummy --script tests/screensaver_soak.gd
```

On Windows, run `tests/windows_display_test.ps1` against the actual installed EXE; see [Windows delivery](docs/WINDOWS_RELEASE.md). Check nonzero test counts, exit codes and runtime logs. Godot script errors alone may not produce a failing exit code. Do not label headless or Linux checks as Windows execution.

Attribution and original texture/source records remain under `assets/`; discoveries and historical entries cite sources in `data/`. No public provider API keys are needed. Environment-network draft publication is a user-facing product operation, separate from saving the allowlist.
