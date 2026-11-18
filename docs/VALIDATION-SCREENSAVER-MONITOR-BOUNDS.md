# Native Windows screensaver monitor-bound validation

Status: candidate implementation; dedicated validation pending.

## Behavior

The native host now uses one checked conversion for monitor rectangles in both places that create or resize fullscreen hosts:

- Initial and post-display-change monitor enumeration validates the callback rectangle before calculating the Win32 integer width and height.
- DPI-only recovery uses the same checked conversion after resolving the target monitor.

The helper calculates dimensions in a wider signed type, rejects zero/reversed or out-of-range rectangles, and only writes output dimensions after both axes pass. This prevents signed overflow in the previous rectangle subtraction and avoids partially updated output values.

Invalid monitor geometry fails closed with the existing native screensaver error path. No fallback dimensions are invented.

## Validation

- Cross-platform C++ assertions cover 3840×1080, a negative-origin 3840×2160 monitor, zero/reversed rectangles, integer overflow, and unchanged output parameters on failure.
- The dedicated installed Windows screensaver workflow rebuilds the .scr host and exercises initial monitor enumeration, display-change reconstruction, DPI-only notification, preview resizing, renderer cleanup, and session lifecycle.
- Windows CI uses a software-rendered virtual desktop. It does not establish physical Dell U4919DW GPU/DPI, mixed-monitor movement, hot-plug, sleep/wake or overnight behavior.

No installer, updater manifest/feed, trust key, signing material, user preference or saved scene is changed.
