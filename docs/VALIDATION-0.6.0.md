# 0.6.0 development evidence

## Application checks executed

Godot 4.6.3, Linux X11, Mesa llvmpipe software OpenGL. These are native desktop application checks, not browser tests and not Windows hardware execution.

- Explorer regression: **56 checks, 0 failures**.
- Interface/public-data/cache regression: **41 checks, 0 failures**.
- Solar geometry, orientation, channel isolation, weather schema/units/time/context, camera markers/health labels, daily UTC rollover, historical atlas and screensaver math: **55 checks, 0 failures**.
- Combined behavior coverage: **152 checks, 0 failures**. Provider observations in tests are isolated fixtures and are never shipped as real product data.
- Balanced 2K and Detailed 4K rendering at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880: **12 cases, 0 failures**.
- Full-Earth/Command Center layout captures at 800×600, 3440×1440, 5120×1440 and 5120×2880 passed. Panels stayed in bounds and did not cover the globe center.
- Six page captures plus dated historical-atlas and UTC daylight views passed. Visual review caught collapsed favorite labels; the fix passed a new label-width check and fresh captures.
- Three intro stages passed: darkness, partial reveal, interactive Earth.
- Six native screensaver previews ran for **eight real seconds each**, restored the UI/preferences, and remained finite, with zero failures. Another deterministic test advanced **six simulated hours**. Neither is an actual hours-long soak or a performance guarantee.

## Delivery checks

The new shared PowerShell process runner executed actual Godot with paths/logs containing spaces, replaced a deliberately stale log, and rejected deliberate runtime errors despite exit 0, nonzero exit 7 and a timed-out engine. The negative fixture error in that log is expected test evidence. PowerShell parser checks passed for all build/update/display/runner scripts and the native icon C# helper compiled locally; Windows resource APIs were not invoked by compilation.

Workflow YAML parses and permits only manual dispatch with read-only repository content access. CI can install/start/uninstall the native Windows EXE and optionally execute graphics checks on a supported desktop. It reports skipped graphics checks as unrun, retains diagnostics, and cannot publish releases or update feeds. The existing disabled state remains unchanged. No new remote Windows workflow run was started.

The Windows application is cross-exported with the verified official template and branded native resources. Its embedded project is checked using Linux Godot; that does not execute the Windows PE or Windows APIs. The final NSIS archive passed integrity testing; application, screensaver, updater and license payloads match build/source byte for byte. App and installer each passed seven-size native icon checks. The public EXE was downloaded again and matched size/checksum:

- File: `LivingEarth3D-Setup-0.6.0.exe`
- Size: **41,276,899 bytes**
- SHA-256: `b44a18e68dc13c9accbd228478ab3b97094ab4c392e02331629439106559423a`
- App source: `9829963`
- Download commit: `e9563e0ed174415bc3243d65918935833062c865`

The embedded project also rendered a native Linux 5120×2880 frame and Command Center layout successfully. This still does not execute the Windows PE. The existing main app/preview metadata was independently checked to remain at 0.5.0. After publishing development metadata, a real HTTPS request through Godot accepted the development feed as version **0.6.0**, unsigned. This verifies update discovery/parsing, not signed installation or restart.

Development uses separate install/shortcut/registry/settings paths and a separate update feed. Initial preference migration reads the earlier preview but writes only to the development directory. Actual side-by-side install and migration execution on Windows remain unrun.

## Provider and platform blockers

- Public USGS and GitHub API probes are denied by the running cloud proxy (CONNECT/API 403). The provider allowlist and current startup instructions are saved in the environment draft with `requires_publish: true`. The product exposes no agent publication operation; the user must publish that configuration. No new provider secret is needed.
- Real Open-Meteo/Nominatim/camera availability checks remain unrun. Reachable camera HTML never counts as verified video. Player windows use the provider's page/browser; embedding and capture-time verification are unfinished.
- Actual Windows install/upgrade/uninstall, native 4K/ultrawide/5K/DPI/refresh, physical Dell monitor, GPU frame times, sleep/resume and hours-long soak remain required before stable promotion.
- Trusted production signatures, same-publisher update execution, recovery/rollback and a stable release feed remain required. This development installer is unsigned; no unsigned automatic execution is permitted.

The historical atlas uses approximate teaching intervals on explicitly modern imagery. It provides no historical satellite imagery, changing borders or reconstructed city geometry. Mountains still use surface imagery, not real terrain elevation. Clouds, stars and Moon remain labeled offline/artistic where appropriate.
