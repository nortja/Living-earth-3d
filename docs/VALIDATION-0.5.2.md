# 0.5.2 interface-size validation

User feedback: 0.5.1 installed and works on Windows. This is user-reported installation/operation evidence, not a measured display or performance matrix.

Godot 4.6.3 Linux headless checks:

- Explorer: 56 checks, zero failures.
- Interface/data: 39 checks, zero failures.
- Ambient sound lifecycle: six checks, zero failures.
- Interface size: 187 checks, zero failures. This exercises six presets at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880; actual container bounds, clear globe center, unchanged viewport dimensions, safe resize behavior, saved choice/restart restoration, and invalid preference recovery.

These headless checks establish application state and layout bounds, not native rendering, audible playback, Windows DPI accuracy or hardware performance. Physical Dell display testing and Windows 0.5.2 install/upgrade checks remain outstanding. Prior 0.5.1 ambient/favorites preferences remain in the same local configuration file.

The one-time 0.5.2 publication workflow repeats these checks and validates exported/installer icon resources before publishing. The feed is promoted only after installer publication. The old Windows workflow remains disabled. The new installer remains an unsigned preview with manual installation.
