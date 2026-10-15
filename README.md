# Living Earth 3D

An offline interactive desktop globe built with Godot 4. Version **0.2.0**.

## Windows users

Use **LivingEarth3D-Setup-0.2.0.exe**: double-click, install, then launch from the desktop shortcut. No terminal, Godot installation, or separate dependencies are required. The current build is an unsigned test installer; Windows installation still needs validation on a real Windows machine.

Drag to orbit, scroll for smooth zoom, and press F11 for fullscreen. **Explore & settings** opens optional discovery and update controls. The interface starts uncluttered; the window adapts to the monitor and expands to ultrawide aspect ratios.

The globe now includes bundled 2K Earth imagery, night lights, ocean highlights, and an atmosphere shader. Six offline destinations support smooth journeys, Surprise Me, and saved favorites. Timed discovery and update checking are opt-in. Automatic installation is implemented for signed Windows releases and asks before restarting; this unsigned build cannot replace itself automatically.

## Development

Open `project.godot` in Godot 4.6.3 or run `godot --path .`. There are no package dependencies or required accounts. Local preferences are saved to Godot's `user://preferences.cfg`.

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 120
# Use a fresh XDG_DATA_HOME on Linux to isolate test preferences.
godot --headless --path . --script res://tests/explorer_test.gd
# Requires a graphical display (or Xvfb); tests normal, ultrawide and 4K rendering.
godot --path . --audio-driver Dummy --script res://tests/render_test.gd
```

See [Windows build and delivery](docs/WINDOWS_RELEASE.md) for installer rebuilds, signing, update behavior, validation evidence, and the remaining release checklist. Texture sources and notices are in `assets/earth/`.

Higher-resolution maps, terrain streaming, Windows screensaver preview embedding, multiple-display coverage, audio, and live data feeds remain future work. The `.scr` build includes fullscreen rotation and exit-on-input. See `PROJECT_PLAN.md` and `docs/` for the feature roadmap.
