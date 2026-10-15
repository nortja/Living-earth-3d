# Windows installer delivery

## End-user installation

The 0.4.0 artifact is `LivingEarth3D-Setup-0.4.0.exe`: one self-contained NSIS installer, with no ZIP extraction, terminal, web bootstrapper, Godot installation, or separate runtime. It installs under `%LOCALAPPDATA%\Programs\Living Earth 3D` with desktop/Start menu shortcuts, an installed-apps uninstall entry, and a launch option. No administrator rights are requested. If the app is running, the interactive installer/uninstaller asks before closing it gracefully; cancellation or an unresponsive app aborts instead of forcing termination. This close-window path still needs Windows testing. Upgrades retain local favorites/preferences; uninstall removes only known app files and retains user data.

## Current evidence

The installer is cross-built on Linux and remains an unsigned preview. Fifty-six behavior checks passed. Graphical tests passed for the three intro stages and in both Balanced and Detailed modes at 800×600, 1920×1080, 3440×1440, and 3840×2160 using software OpenGL. Native PE resource checks compare every icon image to the ICO source, and the exported executable's embedded project starts successfully after branding. Installer payloads and checksums are checked separately.

PowerShell parsing and compilation of the native icon resource helper also passed locally using the verified official PowerShell distribution (`pwsh -File tests/windows_build_scripts_test.ps1`). The user reported successful Windows installation and launch of 0.3.0. Version 0.4.0 installation/upgrade behavior, Windows shell icon appearance, integrated-GPU performance, DPI scaling and signed update behavior are not established by the local checks. Earlier GitHub Windows runs failed because the script relied on `$LASTEXITCODE` from a GUI process. The revised script uses an explicitly waited process, its exit code, and runtime logs, but has not been rerun remotely.

The GitHub **Windows installer** workflow is disabled after unwanted failure emails. Its source now has only `workflow_dispatch` and no automatic tag/push triggers. Leave it disabled during local iteration. Do not re-enable it or change account-wide notification preferences as a workaround. A controlled Windows validation run remains in ROADMAP.md.

## Rebuild on Windows (maintainers only)

Use Godot 4.6.3 with matching official export templates, NSIS 3.11 or newer, and PowerShell:

```powershell
./packaging/windows/build.ps1 -Godot 'C:/tools/godot.exe' -Makensis 'C:/Program Files (x86)/NSIS/makensis.exe'
```

`build.ps1` copies the clean Windows export template into `build/windows/earth_template.exe`, updates its native `GODOT_ICON` resource using Windows resource APIs, and only then exports the embedded-data application. Modifying an already packed PE can lose or invalidate the embedded pack; do not do that. The installer and uninstaller use the same ICO. Godot's runtime/window icon uses `assets/icon.png` and `assets/icon.ico`.

For Linux cross-builds, install the pinned tools in `packaging/windows/requirements-build.txt`, copy the official clean Windows release template to `build/windows/earth_template.exe`, then run:

```sh
python packaging/windows/set_icon.py build/windows/earth_template.exe assets/icon.ico
godot --headless --path . --export-release 'Windows Desktop' build/windows/LivingEarth3D.exe
python tests/windows_icon_test.py build/windows/LivingEarth3D.exe
makensis -DVERSION=0.4.0 -DBUILD_DIR=/absolute/repo/build/windows -DOUTPUT=/absolute/repo/dist/LivingEarth3D-Setup-0.4.0.exe packaging/windows/installer.nsi
python tests/windows_icon_test.py dist/LivingEarth3D-Setup-0.4.0.exe --installer
```

Version numbers in project.godot, scripts/earth.gd, export_presets.cfg, installer.nsi's fallback, and update.ps1's fallback should agree. Windows build output names use the project version. Keep private signing material out of the checkout.

## Secure updates

The optional startup check and manual check query `https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/preview.json`. Version, channel, exact project installer path, checksum format, and signing flag are validated. Unsigned previews are announced with a **Download latest** action and require manual installation. The download branch is uploaded and verified before updating the main feed.

On a future signed update, the Windows helper independently fetches the fixed feed, validates its exact repository/version installer path, downloads, verifies SHA-256 and Authenticode trust, and requires the signer to match the installed app. It asks before closing the app, installs silently, and relaunches. A named mutex prevents overlapping helper instances. No unsigned installer is executed automatically. Favorites remain in user data. A feed checksum detects corruption; the matching trusted signature remains the execution trust boundary.
A real signing certificate is still needed. Configure `WINDOWS_SIGNING_PFX_BASE64` and `WINDOWS_SIGNING_PASSWORD` securely for CI, or use `-SigningPfx`/`-SigningPassword` with the maintainer build script. Both app and installer must be signed by the same certificate. Unsigned previews cannot self-replace. Certificate rotation currently requires a manually installed trusted release; rollback/recovery still needs work.

## Screensaver

The installer includes `LivingEarth3D.scr`. The app's **Screen saver settings** action asks Windows to select it; installation does not change the user's screensaver automatically. `/s` uses fullscreen ambient rotation without UI and exits on input after a startup grace period. `/c` opens Explorer. `/p` exits without a preview: Windows preview embedding and multiple-monitor coverage remain unfinished.

See ROADMAP.md for prioritized release work and CHANGELOG.md for milestone changes.
