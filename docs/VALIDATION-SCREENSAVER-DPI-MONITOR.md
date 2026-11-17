# Native Windows screensaver DPI-only monitor changes

Status: candidate implementation; validation pending.

## Behavior

A fullscreen host may receive WM_DPICHANGED without a topology/resolution WM_DISPLAYCHANGE. The host uses the suggested rectangle only to identify the target monitor, reads the monitor's full physical-pixel bounds, validates positive dimensions and Win32 integer range before conversion, and restores the host with SetWindowPos. The normal host tick then resizes the embedded Godot renderer to the updated client area.

The embedded /p preview is unchanged. WM_DISPLAYCHANGE continues to use the separate 350 ms quiet-period rebuild path.

## Validation plan

- Cross-platform C++ assertions cover ordinary landscape and negative-origin monitor bounds, zero/reversed rectangles, and dimensions that overflow Win32 int.
- The installed Windows lifecycle test sends a synthetic WM_DPICHANGED to every active fullscreen host with a deliberately smaller suggested rectangle, then verifies that every host retains its original physical monitor bounds and that the saver and renderer remain alive.
- The existing Windows test also verifies native preview resize, renderer cleanup, display-change recovery, suspend, session lock and the end-session handshake.

CI uses a software-rendered virtual desktop. The synthetic message test is not a physical DPI transition and does not establish Dell U4919DW GPU/DPI, mixed-monitor movement, physical hot-plug, sleep/wake or overnight behavior.

No installer, updater manifest/feed, trust key, signing material, preference or saved scene is changed.
