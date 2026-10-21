# Windows installer delivery

## End-user installation

The current artifact is `LivingEarth3D-Setup-0.12.2.exe`: one per-user NSIS installer with desktop/Start menu shortcuts, installed-apps uninstall and no separate runtime. Install once; updater-enabled versions subsequently receive authenticated releases and apply them after normal app/screensaver exit. Preferences and bookmarks remain local. Native screensaver selection is optional.

The installer remains Windows publisher-unsigned. Authenticated update metadata uses the existing pinned RSA key independently of Windows Authenticode. Silent installs defer while matching app/screensaver processes are active; they do not force a running user process closed. Handled verification failures restore known previous files and version metadata. This is not a power-loss recovery guarantee.

## Current evidence

[0.12.2 validation](VALIDATION-0.12.2.md) records the exact release gates: 735 source checks; native layouts through 5K; fresh application/screensaver/installer icon and build checks; Windows installation and rollback against 0.5.2 and deployed 0.9.0; current-package embedded preview/render/resize/memory/lifecycle testing; actual exported photograph/model UI testing and a five-active-minute performance recording. Separate one-hour foundation runs are identified by their frozen source, rather than attributed to a different final binary.

Software-rendered disposable Windows/Linux CI does not establish physical Dell GPU/DPI, multiple-monitor, sleep/wake, fan/power or audible playback results. See [field observations](FIELD_CHECKS.md). The old general Windows installer workflow stays disabled, with no automatic push/tag triggers. Release-specific branch workflows validate one candidate without receiving the private release key or promoting the production feed themselves. Promotion follows verified published bytes and a detached signature over exact metadata.

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
makensis -DVERSION=0.12.2 -DBUILD_DIR=/absolute/repo/build/windows -DOUTPUT=/absolute/repo/dist/LivingEarth3D-Setup-0.12.2.exe packaging/windows/installer.nsi
python tests/windows_icon_test.py dist/LivingEarth3D-Setup-0.12.2.exe --installer
```

Version numbers in project.godot, scripts/earth.gd, export_presets.cfg and installer.nsi's fallback should agree. Windows build output names use the project version. Keep private signing material out of the checkout.

## Automatic updates (0.5.3 onward)

Install the updater-enabled version once. In Settings, Automatic updates is on by default; it checks at startup and every 30 minutes while the app is open. Updates download in the background, verify, and install silently when all app/screensaver instances close. Update and restart now requests a graceful close and restart. Turning the toggle off cancels/defer pending work. No forced process termination is used. New app launches may defer an update until the next check; files are never replaced while a matching process is running.

The helper verifies `main/updates/application.json` using the detached `application.sig` and a pinned 3072-bit RSA public key. The signature authenticates the installer URL, version, exact byte size, SHA-256 and expected installed app/helper hashes. It rejects other project origins/channels, unsupported protocol versions, tampered metadata and corrupted files. HTTPS, bounded downloads and a per-install mutex are additional safeguards. Windows Authenticode publisher signing is separate; these preview installers remain unsigned by Windows publisher standards.

The full NSIS installer runs internally with `/S /D=<existing installation>`; /D is last and unquoted as NSIS requires. There is no repeated download/install wizard. Bigger releases work through the same path up to the current 300 MiB package limit; a future protocol change requires explicit compatibility work. The helper writes non-modal status under `.updates`, keeps previous known program files, and restores them plus version metadata if installation or installed-file verification fails. Favorites/preferences stay outside the installation directory. Backup restoration is not a power-loss recovery guarantee.

Maintainers build and publish the installer plus `payload-hashes.json`, then use `packaging/windows/sign_release.py` with the private key held outside the repository. Publish application.json, application.sig and preview.json atomically after verifying the public artifact and Windows validation. Never upload the private key to a public branch, CI logs, installer or artifacts. Keep its private backup; losing it requires a new bootstrap trust migration.

Older versions (0.5.2 and earlier) cannot acquire this capability without one manual bootstrap installation. The existing failing workflow stays disabled. See docs/AUTO_UPDATE.md for the release process and tests.

## Screensaver

The installer includes `LivingEarth3D.scr`. The app's **Screen saver settings** action asks Windows to select it; installation does not change the user's screensaver automatically. `/s` uses fullscreen ambient rotation without UI and exits on input after a startup grace period. `/c` opens Explorer. `/p` exits without a preview: Windows preview embedding and multiple-monitor coverage remain unfinished.

See ROADMAP.md for prioritized release work and CHANGELOG.md for milestone changes.

## Native Windows display validation

On Windows with an interactive desktop, after building or installing the actual EXE:

```powershell
./tests/windows_display_test.ps1 -Application "$env:LOCALAPPDATA/Programs/Living Earth 3D/LivingEarth3D.exe"
```

The runner executes the packaged app at 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880. It requires fresh JSON evidence, a Windows platform result, exact viewport dimensions, a rendered globe, visible control bounds and an unobstructed center. It saves Earth/Command Center screenshots and GPU identity. A headless result cannot pass. A desktop or driver that clamps oversized windows fails the requested size instead of silently passing. Use an appropriately sized Windows desktop for those cases.

This harness is prepared, PowerShell-parsed locally, and exercised through the Linux native application for layout checks. It has **not executed on Windows**. Screenshots still need human review; frame timing, real monitor scaling, 60/120/144 Hz behavior, Windows 10/11 installation/upgrade and physical multi-monitor checks are separate. No Windows runner is available in the current instance, and GitHub API access is denied by the runtime network policy. The old workflow remains disabled.

Live service requests go only to USGS earthquake feeds and OpenStreetMap Nominatim when requested. Camera URLs open official provider pages. The current cloud proxy blocks these services; fixture tests cover response parsing and degraded states. Provider availability and embedded-camera rights are not established. Network additions were saved additively to the environment configuration draft; publishing the draft is separate from saving it.
