# Windows installer delivery

End-user artifact: `LivingEarth3D-Setup-0.2.0.exe`. This is one self-contained NSIS installer, not a ZIP and not a web installer. It installs the embedded-data Godot executable, the screensaver copy, updater helper, and license notices. End users do not install Godot, use a terminal, or download dependencies.

Installation is per-user under `%LOCALAPPDATA%\Programs\Living Earth 3D`, with desktop and Start menu shortcuts, an installed-apps uninstall entry, and an option to launch on the final installer page. No administrator rights are requested. An ordinary upgrade uses the same directory; local preferences under Godot's user data directory are retained. Uninstall intentionally retains those preferences and deletes only known installed files.

## Rebuild

On Windows, use Godot 4.6.3 with matching official export templates, NSIS 3.11 or newer, and PowerShell:

```powershell
./packaging/windows/build.ps1 -Godot 'C:/tools/godot.exe' -Makensis 'C:/Program Files (x86)/NSIS/makensis.exe'
```

The repository's **Windows installer** GitHub Actions workflow prepares those tools, verifies Godot downloads with the official SHA-512 manifest, builds the executable installer, and defines Windows install/launch/shortcut/uninstall smoke tests. It runs manually or on a version tag. It uploads build artifacts without publishing a release. The CI artifact container is for maintainers; distribute the EXE inside it directly to users.

The workflow has not been run in this development session. The local build was cross-compiled on Linux, not installed on Windows. The 28,187,316-byte installer passed archive integrity verification, and its extracted application, screensaver, and updater matched the build inputs exactly. The exported executable's embedded project also passed headless startup and software-rendered graphical startup. Thirty behavior checks passed. A SHA-256 sidecar is emitted for the installer.

Version numbers in `project.godot`, `scripts/earth.gd`, and `export_presets.cfg` must be bumped together before a release. The installer filename and metadata are derived from the project version by `build.ps1`.

## Signed automatic updates

The existing update preference is opt-in. Startup checks and the manual check use only the repository's official GitHub latest stable release. For a newer stable version, the Windows helper downloads `LivingEarth3D-Setup-X.Y.Z.exe`, verifies Windows Authenticode trust and that the signer certificate thumbprint matches the installed application, asks before closing the app, then runs the installer silently and relaunches the app. No terminal appears. It never runs an unsigned installer. Preferences and favorites survive updates.

For a signed build, supply an authentic Windows code-signing PFX and password to `build.ps1` using `-SigningPfx` and `-SigningPassword`, or configure the CI repository secrets `WINDOWS_SIGNING_PFX_BASE64` and `WINDOWS_SIGNING_PASSWORD`. Both the application and installer are signed with the same certificate. The timestamp uses DigiCert's Authenticode timestamp service. Never commit signing material. Certificate rotation currently requires a manually installed signed release; it is intentionally not trusted automatically.

This development build is **unsigned**. Automatic replacement is therefore unavailable and Windows may show an unknown-publisher/SmartScreen warning. Update checking still works on an unrestricted Windows network. Actual signed download/install/restart behavior requires a signed published release and Windows testing; mocked API tests do not establish that it works end to end. Release assets are not published by the workflow or by the app.

## Screensaver

The installer includes `LivingEarth3D.scr`. From the app's Explore & settings panel, **Screen saver settings** asks Windows to select it. The app does not change the user's screensaver automatically. `/s` starts fullscreen ambient rotation without controls; movement or input exits after a one-second startup grace period. `/c` opens the normal Explorer. `/p` currently exits without showing a preview; Windows settings preview embedding and multi-monitor screensaver coverage remain unfinished. Validate actual activation and wake-up behavior on Windows before shipping.

## Release checklist

- Install from the EXE using a standard Windows 10/11 x64 user account. Confirm desktop shortcut, launch, offline use, and clean uninstall.
- Test upgrading while the app is running, preserve favorites, and test the signed update consent/download/install/relaunch flow, including cancellation and bad signature rejection.
- Test 1080p, 4K, Windows DPI scaling, ultrawide, multiple monitors, and GPU compatibility. Linux software rendering passed at 800×600, 1920×1080, 3440×1440, and 3840×2160; it is not a substitute for Windows hardware testing.
- Replace the current 2K maps with higher-resolution source-verified imagery for close-up presentation, retaining attribution and distribution terms.
- Finish screensaver preview embedding and multi-monitor behavior.
