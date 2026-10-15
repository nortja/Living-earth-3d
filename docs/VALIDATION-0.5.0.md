# 0.5.0 preview validation

## Executed in the cloud instance

Godot 4.6.3 on Linux; native X11/OpenGL compatibility renderer using Mesa llvmpipe software rendering. No browser was used. These checks establish rendering and application behavior, not Windows hardware performance.

- Explorer regression suite: **56 checks, 0 failures**.
- Interface / search / camera catalog / USGS parser / disk cache / screensaver styles: **39 checks, 0 failures**. Public-data fixtures are isolated test inputs, never app observations.
- Intro: three captured stages, monotonically increasing center brightness, then interactive UI.
- Balanced 2K and Detailed 4K native rendering: **12 cases, 0 failures**.
- Native full-Earth / Command Center layout and screenshot capture: **six resolutions, 0 failures**.

| Viewport pixels | Balanced | Detailed | UI scale | Command Center layout |
| --- | --- | --- | --- | --- |
| 800×600 | Pass | Pass | 1.00 | Compact bottom panel |
| 1920×1080 | Pass | Pass | 1.00 | Side panel and optional overview |
| 3440×1440 | Pass | Pass | 1.33 | Side panel and optional overview |
| 3840×2160 | Pass | Pass | 1.75 | Side panel and optional overview |
| 5120×1440 | Pass | Pass | 1.33 | Side panel and optional overview |
| 5120×2880 | Pass | Pass | 1.75 | Side panel and optional overview |

Final signed-distance-field UI font rendering was additionally captured at 1080p and at 5K using the exported Windows EXE's embedded project loaded by the Linux Godot engine. This verifies packaged resource resolution; **it does not execute the Windows PE or Windows APIs**. The embedded project started successfully and seven native app icon sizes matched the source ICO. PowerShell syntax checks passed for build/update/icon/display scripts and the native icon C# helper compiled locally without invoking Windows APIs.

## Still required

- Execute `tests/windows_display_test.ps1` against the packaged EXE on an interactive Windows desktop. It rejects Linux/headless results, missing evidence and clamped viewport sizes.
- Review physical Dell monitor DPI, refresh, multi-monitor moves, sleep/resume, integrated-GPU frame times and memory. Software-rendered captures cannot establish these.
- Install, upgrade, launch shortcuts, verify shell icons, test screensaver activation/input exit and uninstall on Windows 10/11. The user's successful 0.3.0 installation is earlier-version evidence only.
- Real USGS/Nominatim and camera-provider availability checks: cloud proxy currently denies those destinations. Parser/cache/failure tests passed; no current feed availability or embedded playback is claimed.
- Production certificate provisioning and signed, same-publisher self-update execution on Windows. This preview remains unsigned and manual-install only.

The existing GitHub installer workflow remains disabled and has no push/tag triggers. A Windows display harness is prepared, but no remote Windows run was started. Network destinations were added to the environment draft for future provider checks; saved drafts do not change running-instance networking.
