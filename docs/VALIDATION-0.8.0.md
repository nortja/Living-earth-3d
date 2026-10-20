# 0.8.0 native screensaver integration — validation

Released preview, 2026-10-20. The user confirmed the 0.7.0 update installed successfully and looks good. Authenticated update discovery now delivers 0.8.0.

## Changes

The installed `.scr` is now a small native Win32 launcher, rather than a duplicate Godot executable. It launches the existing adjacent Explorer executable with Godot's parent-window argument and explicit offline saver flags. The existing four-file signed-update protocol and pinned trust key are unchanged, so previous updater-enabled installs can receive it.

- `/p HWND` and `/p:HWND` validate the parent before launching. The actual Earth renders as a child of that window; parent resizing moves the child, and parent destruction stops it. Preview has no fullscreen fallback and ignores input without hiding the cursor.
- `/s` creates a physical-pixel black host covering each attached monitor and embeds one Earth per monitor, up to four animated views. Additional monitors stay black to bound resource use. A mutex prevents duplicate fullscreen sessions. Keyboard/button input or mouse movement beyond an eight-pixel grace threshold exits the whole session after a 1.2-second startup grace period.
- Display-change, session lock/disconnect/logoff and suspend notifications close saver views. Job-object lifetime prevents abandoned renderers if the launcher dies; graceful close is attempted first during normal shutdown. This manages only children started by this launcher.
- `/c`, `/c:HWND` and no arguments open the app's Screensavers page. Unknown or malformed arguments exit without opening Explorer/fullscreen.
- Hosted views use balanced 2K textures and at most 30 FPS; the small native preview uses 15 FPS. These limits do not modify saved Explorer settings. No intro, ambient playback, weather/earthquake request or updater startup occurs in hosted mode. Hosted renderers do not request keeping the display awake.
- The installer detects both Explorer and native saver hosts before replacement/removal. It includes the separately built, branded launcher; installed-file metadata hashes the actual `.scr`.

## Evidence and release gates

Local validation includes all 464 existing checks, 24 hosted-renderer checks, 25 native argument/renderer-budget checks, two actual Godot command-contract cases, 16 updater-security checks, native icon verification and software-OpenGL saver renders at 320×200, 580×330, 1920×1080 and 5120×1440.

[Windows release validation](https://github.com/nortja/Living-earth-3d/actions/runs/39513870934) passed against the exact published installer: silent upgrades/rollback from both 0.5.2 and 0.7.0, user-data and icon preservation, running-app protection, uninstall, actual rendered Earth inside a true preview child HWND, no visible top-level renderer, resize tracking, input suppression, two independent previews, parent-close cleanup, forced-controller job cleanup, and a silent installer blocked while a native preview was active. Fullscreen covered the runner's one attached monitor, rejected a duplicate session, exited on keyboard input and cleaned up after a simulated display-change message. The Windows preview screenshot was downloaded, checksum-verified and visually inspected.

The Windows test VM used a pinned Mesa 26.2.4 software OpenGL ICD. This driver setup is confined to disposable CI; no Mesa DLL, driver installer or machine graphics setting ships in the application installer. Initial per-app driver setup could not initialize its OpenGL window, so the official system-wide software-ICD deployment was used on the test VM. A standalone actual-Godot preflight verifies that graphics works before embedding is tested.

[Earlier Linux build evidence](https://github.com/nortja/Living-earth-3d/actions/runs/39510334193/job/118929475631) covers the application behavior/render matrix. The native correction build reused that frozen Godot executable only after verifying its exact installed-file hash, rebuilt the native launcher/installer, regenerated payload hashes, and repeated Windows upgrade/lifecycle gates. The launcher now uses generated argument vectors validated by Godot and explicitly adopts Godot 4.6's owned popup as a WS_CHILD. Renderers start offscreen until attached. This preserves the validated Earth resources and installed update protocol.

[Production updater validation](https://github.com/nortja/Living-earth-3d/actions/runs/39514718712) passed on Windows: the public signed installer staged while the app stayed open, cancellation preserved the installed app, resuming installed after natural exit, installed payload hashes matched, and an intentionally closed app stayed closed.

Physical multi-monitor mixed-DPI performance, lock/suspend/resume behavior on real hardware, visible updater restart and longer saver runs remain field tests. CI's attached-monitor count is recorded; a one-monitor runner does not establish multi-monitor hardware coverage. A screensaver is not an authentication or lock-screen security boundary. Continuous video remains future work.

## References

- Godot command-line `--wid`: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Godot 4.6.3 Windows backend parent-window handling: https://github.com/godotengine/godot/blob/4.6.3-stable/platform/windows/display_server_windows.cpp
- Test-only Mesa distribution: https://github.com/pal1000/mesa-dist-win/releases/tag/26.2.4

## Published package

Installer size: 36,636,950 bytes. SHA-256: `40077feb61b467f2bd540bc2f18d2fccde663760c39e10fa356fb137db13a4c0`. Downloaded public bytes matched the published checksum before signing exact metadata with the existing pinned release key. No private key entered git or CI. The four-file update protocol and older disabled general workflow were preserved.
