# Living Earth 3D

An offline Godot 4 Earth Explorer prototype with a rotating globe, simplified real coastlines, and six curated destinations. Choose a destination or **Surprise me** to travel smoothly to a geographic marker and read a short fact.

- Drag the globe to orbit; scroll to zoom.
- **Space** toggles rotation; **Home** resets the view; **Esc** quits.
- Visiting a destination pauses rotation. **Reset view** resumes the ambient globe.
- All map data and destination facts are bundled. No accounts, credentials, or runtime network access are required.

## Develop and test

Use Godot **4.6.3 stable** for the reproducible export. The project uses the GL Compatibility renderer. Open `project.godot` in Godot, or run from the checkout:

```sh
godot --editor --path .
godot --path .
```

In the cloud environment, first use writable application directories:

```sh
export XDG_CONFIG_HOME=/workspace/.living-earth-env/config
export XDG_CACHE_HOME=/workspace/.living-earth-env/cache
export XDG_DATA_HOME=/workspace/.living-earth-env/data
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
```

Headless checks:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/explorer_smoke.gd
godot --headless --path . --quit-after 120
```

The smoke suite checks rotation and pause, camera alignment with every destination on a rotated globe, random-selection non-repetition, zoom and pitch limits, drag release, reset, and invalid destination indices. Headless checks do not validate graphics or native Windows behavior.

## Windows build

On Linux with Bash, curl, Python 3, sha512sum, and Godot 4.6.3:

```sh
bash tools/build_windows.sh
```

This installs missing Windows x86-64 export templates from the official Godot release and verifies the pinned SHA-512 checksum before extracting them. The first download is approximately 1.2 GB; installed templates are reused. It runs the smoke suite, exports the release executable with embedded assets, verifies the Windows binary and embedded game pack, and creates `build/LivingEarth3D-windows-x86_64.zip` plus `build/SHA256SUMS.txt`. The ZIP includes the executable, first-run instructions, and map attribution.

Extract the zip on Windows and run `LivingEarth3D.exe`. This is an unsigned Explorer prototype, not an installer or a Windows `.scr` screensaver. Native Windows behavior still needs testing on Windows. No code-signing configuration is required for local prototype builds.

## Scope and credits

The map uses public-domain Natural Earth polygons; see [attribution](assets/ATTRIBUTION.md). Coastlines and polar shading are simplified artistic rendering, not satellite imagery or navigation data. Destination selection highlights the globe; it does not provide terrain flyovers. Automatic discovery scheduling, favorites, live data, screensaver integration, and installer packaging remain future work described in [the project plan](PROJECT_PLAN.md).

For native Windows test steps and GitHub prerelease publication instructions, see [Windows testing and publication](docs/WINDOWS_TESTING.md).
