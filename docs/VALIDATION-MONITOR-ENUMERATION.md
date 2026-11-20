# Native screensaver monitor-enumeration completeness

Status: candidate implementation; dedicated no-publication validation pending.

## Behavior

The Windows saver now checks the return value of `EnumDisplayMonitors` at both initial host creation and after a `WM_DISPLAYCHANGE` rebuild. A non-empty partial enumeration is not accepted as complete coverage. If the API fails, the callback stops because a monitor rectangle is invalid, or no monitors are returned, the saver follows its existing controlled shutdown path before starting any renderer for that enumeration.

The policy is isolated in `earth_saver::monitor_enumeration_complete` so it can be exercised with deterministic native tests on Linux and Windows. On a failed rebuild, any partially created host windows are left for the existing bounded shutdown cleanup; the job object remains the final guard for owned renderer processes.

This is fail-closed behavior: it avoids presenting a partially covered desktop as a successful monitor rebuild. It does not add retries or alter the 350 ms display-change debounce.

## Validation plan

- Strict C++17 argument/policy suite on Linux and native Windows MSVC.
- Fresh Godot 4.6.3 import, all source suites, application/native screensaver/installer build and Linux native rendering.
- Windows PowerShell 5.1 update-security, install/rollback, Screen Saver Settings, installed embedded preview and ten-minute software-rendered lifecycle soak.
- Windows installed desktop framebuffer matrix through 5120×2880, including 3840×1080.
- No installer publication, signature generation or authenticated feed promotion.

A synthetic policy test cannot force Windows' real `EnumDisplayMonitors` API to fail. The Windows integration suite validates successful installed enumeration, display-change recovery and cleanup; actual API failure remains covered by the deterministic helper contract rather than a physical display failure.

Physical Dell U4919DW GPU/DPI, real mixed-DPI movement/hot-plug, machine sleep/wake and overnight behavior remain separate field checks. No preferences, saved scenes, updater trust key, update manifest or production installer are changed.
