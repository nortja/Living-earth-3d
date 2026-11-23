# DPI-only screensaver recovery fallback

Status: merged into `main` as [commit 2671cf3](https://github.com/nortja/Living-earth-3d/commit/2671cf3cfd37b4c2cbe9bac584f22d82e0c6f4d3); no-publication validation passed in [workflow 45054381856](https://github.com/nortja/Living-earth-3d/actions/runs/45054381856).

## Behavior

A fullscreen native saver host normally handles a DPI-only `WM_DPICHANGED` by resolving the suggested rectangle to its target monitor and restoring that monitor's complete physical-pixel bounds.

If monitor lookup, `GetMonitorInfoW`, checked extent conversion, or `SetWindowPos` fails, the host no longer terminates immediately. It schedules the same 350 ms quiet-period topology rebuild used for `WM_DISPLAYCHANGE`. The current host and renderer remain in place until that bounded recovery begins.

The rebuild still closes only owned renderers, recreates the job object, and requires successful, non-empty, complete `EnumDisplayMonitors` coverage before starting any renderer. An incomplete rebuild remains fail-closed. No partial monitor set is displayed as a successful recovery.

The embedded `/p` preview path is unchanged. No additional process, provider request, preference, installer payload, updater helper, trust key, or release metadata is introduced.

## Source and native validation

- 74 screensaver argument/policy assertions passed with GCC C++17 and zero failures. The added policy cases cover the complete successful DPI update and each failed prerequisite: monitor not found, monitor information unavailable, invalid bounds, and failed host reposition.
- The Linux build job cross-compiled the Windows native `.scr` launcher with MinGW-w64 and produced the unsigned test installer.
- The full Godot 4.6.3 source run completed 26 suites with zero failures, including screensaver setup, display/performance reporting, camera, Scene Library, Moon zoom and other product regressions.
- Linux native rendering completed the exploration, camera, display, and screensaver suites with zero failures. Native saver rendering passed at four test sizes. Desktop rendering covered six sizes through 5120×2880; Camera Wall fixtures covered 1/4/9 tiles at multiple sizes.

The policy helper was not compiled with MSVC in this run. The Windows native launcher was cross-compiled with MinGW-w64; the packaged Windows tests below exercised the installed binary.

## Installed Windows validation

The Windows job passed:

- PowerShell 5.1 updater status: 211 checks; updater security: 16 checks.
- Installer upgrade from 0.5.2 and 0.24.0, rollback after injected install failure, preservation of user data, install path with spaces, and deferral while the application is running.
- Actual Screen Saver Settings dialog and Living Earth selection.
- Actual packaged Godot Earth inside the native preview window, including resize and parent/child lifecycle checks.
- Ten-minute software-rendered preview/screensaver soak, completing at 605.1 seconds.
- Synthetic successful `WM_DPICHANGED`, debounced display-change burst, suspend, session lock, and canceled/committed end-session checks.
- Installed Windows desktop framebuffer tests at 1920×1080, 2496×1664, 3440×1440, 3840×1080, 3840×2160, 5120×1440 and 5120×2880 using llvmpipe software rendering.

The installed Windows harness did not inject failures into `MonitorFromRect`, `GetMonitorInfoW`, or `SetWindowPos` to force the new fallback path end-to-end. The failure decision is covered by the 74 native policy assertions; the Windows package/build and surrounding recovery lifecycle passed. This limitation is retained explicitly.

Camera regression suites also passed on Linux and Windows: 393 assertions per OS (57 viewer, 232 revalidation, 26 expansion, 78 Camera Wall), plus native camera rendering.

## Field limits

A passing software-rendered CI result does not establish physical Dell U4919DW GPU/DPI behavior, real mixed-DPI movement, physical hot-plug, Windows sleep/wake, or overnight operation. Those remain field checks.

## Release status

This was a no-publication validation. No production installer, detached release signature, or authenticated update manifest was created or promoted. The existing pinned updater key, user preferences and saved scenes remain unchanged.