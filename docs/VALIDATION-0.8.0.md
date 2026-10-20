# 0.8.0 native screensaver integration — validation

Candidate, 2026-10-20. The user confirmed the 0.7.0 update installed successfully and looks good. Published update discovery stays on 0.7.0 until release gates pass.

## Changes

The installed `.scr` is now a small native Win32 launcher, rather than a duplicate Godot executable. It launches the existing adjacent Explorer executable with Godot's parent-window argument and explicit offline saver flags. The existing four-file signed-update protocol and pinned trust key are unchanged, so previous updater-enabled installs can receive it.

- `/p HWND` and `/p:HWND` validate the parent before launching. The actual Earth renders as a child of that window; parent resizing moves the child, and parent destruction stops it. Preview has no fullscreen fallback and ignores input without hiding the cursor.
- `/s` creates a physical-pixel black host covering each attached monitor and embeds one Earth per monitor, up to four animated views. Additional monitors stay black to bound resource use. A mutex prevents duplicate fullscreen sessions. Keyboard/button input or mouse movement beyond an eight-pixel grace threshold exits the whole session after a 1.2-second startup grace period.
- Display-change, session lock/disconnect/logoff and suspend notifications close saver views. Job-object lifetime prevents abandoned renderers if the launcher dies; graceful close is attempted first during normal shutdown. This manages only children started by this launcher.
- `/c`, `/c:HWND` and no arguments open the app's Screensavers page. Unknown or malformed arguments exit without opening Explorer/fullscreen.
- Hosted views use balanced 2K textures and at most 30 FPS; the small native preview uses 15 FPS. These limits do not modify saved Explorer settings. No intro, ambient playback, weather/earthquake request or updater startup occurs in hosted mode. Hosted renderers do not request keeping the display awake.
- The installer detects both Explorer and native saver hosts before replacement/removal. It includes the separately built, branded launcher; installed-file metadata hashes the actual `.scr`.

## Evidence and release gates

Local validation includes all 464 existing checks, 24 hosted-renderer checks, 25 native argument/renderer-budget checks, 16 updater-security checks, native icon verification and software-OpenGL saver renders at 320×200, 580×330, 1920×1080 and 5120×1440.

Windows release validation must exercise the actual packaged Godot renderer inside a real preview HWND: parenting, no visible top-level renderer, resizing, nonblank screenshot, two independent previews, parent-close cleanup and forced-controller job cleanup. It must also cover all monitors attached to the runner, duplicate fullscreen prevention, keyboard exit, simulated display-change cleanup, plus upgrades/rollback from 0.5.2 and 0.7.0 and payload verification. Mesa software OpenGL is downloaded with a pinned digest solely for CI; its DLLs are never included in the installer.

Physical multi-monitor mixed-DPI performance, lock/suspend/resume behavior on real hardware, visible updater restart and longer saver runs remain field tests. CI's attached-monitor count is recorded; a one-monitor runner does not establish multi-monitor hardware coverage. A screensaver is not an authentication or lock-screen security boundary. Continuous video remains future work.

## References

- Godot command-line `--wid`: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Godot 4.6.3 Windows backend parent-window handling: https://github.com/godotengine/godot/blob/4.6.3-stable/platform/windows/display_server_windows.cpp
- Test-only Mesa distribution: https://github.com/pal1000/mesa-dist-win/releases/tag/26.2.4
