# Windows prototype testing and publication

## Run the application

1. Download `LivingEarth3D-windows-x86_64.zip` and extract it with **Extract All**.
2. Open the extracted `LivingEarth3D` folder and double-click `LivingEarth3D.exe`.
3. Godot installation, a separate `.pck`, Python, and an internet connection are not required. The engine and game assets are embedded in the executable. The other files are instructions and attribution.

Target: Windows 10/11 x64 with an OpenGL 3.3-capable graphics driver. This is an unsigned testing build. Windows may show an unknown-publisher warning; use your normal policy for unsigned software. No installer, administrator privileges, or system configuration changes are intended.

## Test checklist on a Windows machine

- Launch from the extracted folder on a machine without Godot installed.
- Confirm the globe, coastlines, atmosphere, and text render correctly.
- Confirm automatic rotation, pause via the switch and Space, and resume.
- Drag to orbit in both directions. Release over the interface and confirm dragging stops.
- Zoom in/out with the mouse wheel; confirm the camera cannot enter the globe.
- Choose all six destinations; confirm smooth travel, marker positioning, and matching facts.
- Click Surprise me repeatedly; confirm no immediate repeats.
- Click Reset view or press Home; confirm the default zoom and rotation return.
- Resize the window; confirm controls remain usable. Record display resolution and scaling.
- Press Esc and confirm the process exits; relaunch and repeat offline.

Native Windows execution is not validated by a Linux headless run. Record Windows version, GPU/driver, resolution, scaling, and any error text when reporting results. On this cloud machine, automated interaction tests, software OpenGL rendering, PE dependency inspection, ZIP integrity checks, and embedded game-content startup have been validated.

## Publish a testing release

The build is already available locally at `build/LivingEarth3D-windows-x86_64.zip`. `build/SHA256SUMS.txt` contains its SHA-256 checksum. Verify the downloaded ZIP in PowerShell with:

```powershell
Get-FileHash .\LivingEarth3D-windows-x86_64.zip -Algorithm SHA256
```

For a public GitHub prerelease using the website:

1. Open https://github.com/nortja/Living-earth-3d/releases/new while signed in with permission to create releases.
2. Create a new, unused testing tag (for example `v0.1.0-test.1`), and select the source commit that contains this Explorer implementation. The local changes must be reviewed, committed, and pushed first if the release should match published source.
3. Set the title to **Living Earth 3D — Windows testing prototype**.
4. Copy the description from `docs/WINDOWS_RELEASE_NOTES.md`.
5. Attach `build/LivingEarth3D-windows-x86_64.zip` and `build/SHA256SUMS.txt`.
6. Select **Set as a pre-release**, then **Publish release**.

GitHub API and release-asset uploads require network access to `api.github.com` and `uploads.github.com`, plus GitHub release write authorization. These destinations have been enabled for this environment, and repository API write permissions were confirmed. If a future session receives proxy HTTP 403, check the applied network settings first and retry the repository API permission check before requesting additional authentication. Never paste tokens into chat.

Publishing a GitHub release and publishing the cloud environment snapshot are separate actions. Environment publication uses **Publish** in environment settings.

## Later milestones

This deliverable is the interactive Explorer application. Windows screensaver lifecycle/preview modes, live licensed public cameras, cinematic terrain, multi-monitor coordination, ultrawide-specific layouts, and signed automatic updates remain separate development milestones. The test build does not silently install or update itself.
