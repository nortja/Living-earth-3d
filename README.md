# Living Earth 3D

An offline interactive desktop globe for Windows, built with Godot 4. Version **0.4.0**.

## Windows users

Download **LivingEarth3D-Setup-0.4.0.exe**, double-click, install, then use the desktop shortcut. No terminal, separate runtime, or Godot setup is required. This is an unsigned preview; the user confirmed the previous 0.3.0 installer works on Windows. This 0.4.0 build still needs Windows hardware/upgrade validation.

The new illuminated Earth icon replaces the generic branding. On launch, the real globe emerges from darkness before the controls appear. Drag to spin with gentle inertia, scroll or double-click to zoom, and use **Reset Earth** or Home to return to the full globe. Input skips the intro; F11 toggles fullscreen.

Earth now includes genuine 4K daytime/night-light maps (select **Detailed · 4K**), a lower-memory **Balanced · 2K** mode, independently drifting offline clouds, refined atmosphere, optional stars, and an optional Moon backdrop. A 30 FPS power-saving option is available. Visual choices are saved locally. **Explore & settings** opens six offline destinations, smooth journeys, Surprise Me, favorites, and opt-in timed discovery. The window adapts to the monitor and fills ultrawide aspect ratios. Preferences stay local; no account is needed.

Optional startup checks use a project-controlled preview feed; **Check updates → Download latest** provides the next preview installer. Future signed updates additionally require a matching trusted publisher and SHA-256 checksum before replacement, then ask before restarting. Unsigned previews require manual installation. Clouds are offline artwork; Moon/stars are artistic backdrops, not live astronomy. Live cloud/weather updates, seasons, historical sites, screensaver preview embedding, and multiple displays remain in [ROADMAP.md](ROADMAP.md).

## Development

Use Godot 4.6.3. `godot --path .` starts the app; `project.godot` opens it in the editor.

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/explorer_test.gd
godot --headless --path . --quit-after 240
# Requires a graphical display or Xvfb:
godot --path . --audio-driver Dummy --script res://tests/intro_render_test.gd
godot --path . --audio-driver Dummy --script res://tests/render_test.gd
```

Behavior tests use their own preferences file and remove it after completion. Windows resource checks and packaging instructions are in [docs/WINDOWS_RELEASE.md](docs/WINDOWS_RELEASE.md). The failing GitHub installer workflow is disabled, and automatic tag triggers have been removed to stop unwanted failure emails.

See [CHANGELOG.md](CHANGELOG.md), [ROADMAP.md](ROADMAP.md), and `docs/` for progress and upcoming milestones. Texture and branding credits are under `assets/`.
