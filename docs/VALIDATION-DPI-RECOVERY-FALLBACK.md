# DPI-only screensaver recovery fallback

Status: implementation pushed; dedicated no-publication validation pending.

## Behavior

A fullscreen native saver host normally handles a DPI-only `WM_DPICHANGED` by resolving the suggested rectangle to its target monitor and restoring that monitor's complete physical-pixel bounds.

If monitor lookup, `GetMonitorInfoW`, checked extent conversion, or `SetWindowPos` fails, the host no longer terminates immediately. It schedules the same 350 ms quiet-period topology rebuild used for `WM_DISPLAYCHANGE`. The current host and renderer remain in place until that bounded recovery begins.

The rebuild still closes only owned renderers, recreates the job object, and requires successful, non-empty, complete `EnumDisplayMonitors` coverage before starting any renderer. An incomplete rebuild remains fail-closed. No partial monitor set is displayed as a successful recovery.

The embedded `/p` preview path is unchanged. No additional process, provider request, preference, installer payload, updater helper, trust key, or release metadata is introduced.

## Source policy tests

The native policy helper requires all four conditions for a direct DPI update to be considered complete: monitor found, monitor information read, bounds valid, and host reposition successful. Tests cover the successful path and each failure condition. The dedicated workflow compiles and runs these assertions with both GCC and native Windows MSVC, then builds the native `.scr` launcher.

## Full no-publication validation

The branch workflow runs the repository's full source/native and installed Windows pipeline: Godot 4.6.3 import and 26 source suites, Linux native render suites, Windows application and native saver builds, installer install/rollback and user-data preservation, updater status/security checks, Screen Saver Settings, embedded preview, ten-minute software-rendered saver soak, and the seven-size installed framebuffer matrix.

A passing software-rendered CI result does not establish physical Dell U4919DW GPU/DPI behavior, real mixed-DPI movement, physical hot-plug, Windows sleep/wake, or overnight operation.

## Release status

This candidate is not a production release. No public installer, detached release signature, or authenticated update manifest is created or promoted by this workflow. The existing pinned updater key, user preferences and saved scenes remain unchanged.
