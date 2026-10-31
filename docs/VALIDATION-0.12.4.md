# 0.12.4 release validation

Preview released 2026-10-31 (Pacific). Camera refreshes reuse validated textures when provider bytes match. Monitor polling handles refresh/DPI changes on the same screen; invalid driver values retain a bounded cap, and fractional 60 Hz displays no longer truncate to 59 FPS. Local JSON diagnostics include all attached monitors and the active screen index.

## Frozen source and local checks

Binary source `1f533f122da43f8f06a81146ee6a19d0b039c7d4`, tree `0b4d995bb82b91820348725d6d3f3e5009021437`.
Official Godot 4.6.3 archive verified against its published SHA-512; clean import and all fourteen local headless suites passed, 757 checks. Native local camera and performance-report renders passed through 5K, including attached-monitor assertions and visual inspection. These are software graphics checks, not Dell GPU/DPI evidence.

## Fresh build and Windows evidence

[Release run 41218154079](https://github.com/nortja/Living-earth-3d/actions/runs/41218154079) passed all jobs:

- Build `124586922448`: fresh source/security/status/parser/launcher/icon checks; new application, native screensaver and installer; native exploration/cameras/weather/photos/report layouts through 5K and preview/fullscreen budgets/isolation.
- Windows `124588742342`: PowerShell 5.1/7 updater security/status checks, real upgrades and handled-failure rollback from 0.5.2 and 0.9.0, running-app deferral, preference preservation and uninstall. Actual Screen Saver Settings/dropdown passed. Native embedded preview retained rendering, resize/parenting/input isolation and bounded private memory for 605.2 seconds; independent preview/parent/controller cleanup, one-monitor fullscreen/keyboard exit and simulated display-change/suspend/session-lock cleanup passed. Physical mixed-DPI/multi-monitor/sleep behavior remains a field check.
- Installed desktop `124588742419`: exported photographs/model points/preview isolation and local report passed. Recording completed 300.0066 active seconds, 13,439 frames, mean 22.3236 ms, one frame over 50 ms; release engine-memory counters were null as required. This software VM result is not physical hardware performance.
- Publish `124591878711` delivered the installer only after build, Windows and desktop gates passed.

## Public bytes and authentication

`LivingEarth3D-Setup-0.12.4.exe`: 51,343,270 bytes; SHA-256 `5fc16c96e5ca3a561aa6650935323cd76168600c315d3a4e02dbdb495277d65b`.
The public installer, checksum, BUILD source and installed-file metadata were retrieved. The exact installer URL used by the updater was independently downloaded and verified. Both helper hashes match source. The exact UTF-8 manifest was signed outside git/CI with the existing private key and independently verified using the installed public key. All three discovery files are promoted together; no trust, hash, process-protection or preference rules changed. The installer remains Windows publisher-unsigned.

Production signed-feed staging/cancellation/normal-exit validation is pending immediately after promotion. The old general automatic workflow stays disabled.
