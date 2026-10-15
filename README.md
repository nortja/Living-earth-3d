# Living Earth 3D

An offline-first interactive Windows globe and screensaver, built with Godot 4. Version **0.5.0 preview**.

## Windows users

[Download LivingEarth3D-Setup-0.5.0.exe](https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.5.0/LivingEarth3D-Setup-0.5.0.exe), double-click, install, then open the desktop shortcut. No ZIP extraction, terminal, separate runtime, or Godot setup is needed. This is an unsigned preview. The user confirmed installation and launch of 0.3.0 on Windows; 0.5.0 Windows hardware/upgrade testing is still outstanding.

The real globe emerges from darkness with illuminated Earth branding. Drag to spin with gentle inertia, scroll or double-click to zoom, and use **Full Earth** or Home to reset. F11 toggles fullscreen. Earth stays centered and proportional at native viewport resolution, including ultrawide and 4K/5K sizes. Compact controls scale automatically with window resolution. Side panels move below the center in smaller windows; an optional wide Command Center overview uses spare space.

The navigation bar opens **Explore**, **Live Earth**, **Cameras**, **Command Center**, and **Screensavers**. Settings contains display/GPU information, genuine 4K and lower-memory 2K texture presets, offline cloud/star/Moon toggles, and 30 FPS power saving. The normal 60 FPS limit also respects lower monitor refresh rates. This is a cap, not a promise of performance on every GPU. Preferences and favorites stay local.

Explore six curated destinations, an offline atlas, or coordinates. Worldwide search uses OpenStreetMap Nominatim only when requested. Camera venues fly the globe to approximate locations and open official provider pages in a browser; feeds are not embedded, and availability is not verified. The Command Center requests USGS M2.5+ past-day earthquakes, with event UTC times, retrieval timestamps, disk cache, and explicit unavailable/cached states. No observations are fabricated. **Live Earth** explains the difference between offline imagery, periodic data and external services.

Four offline screensaver styles offer Ambient Earth, Discovery journeys, Night lights, and Deep space. Preview returns to the app on input after a short grace period. Windows screensaver selection is optional; preview embedding and multi-monitor coverage are unfinished. Clouds drift as offline artwork. Lighting, Moon and stars are cinematic rather than current astronomical positions. Source detail remains 4K even on larger displays.

Optional update checks use the project's preview feed. **Settings → Check updates → Download latest installer** provides the next unsigned preview. Automatic replacement requires trusted matching-publisher signatures and SHA-256 verification; production signing and Windows end-to-end update testing remain outstanding. See [ROADMAP.md](ROADMAP.md) for weather, current solar illumination, embedded cameras, higher-resolution imagery and other next steps.

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
