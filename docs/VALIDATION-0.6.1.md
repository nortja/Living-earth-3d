# 0.6.1 preview validation

Source candidate, 2026-10-20. Automatic update discovery remains 0.5.4 until the new installer passes Windows installation checks and its exact metadata is signed.

- Godot 4.6.3: 400 behavior/data/layout checks across explorer, interface, scale, audio, updates, camera viewer, camera wall and solar position. Fixture camera images are used only in tests.
- Three real NPS camera images retrieved and decoded at 1920×1080. Retrieval does not establish camera capture freshness or future provider availability.
- Native Linux software OpenGL: twelve wall renders (1/4/9 views at 800×600, 1920×1080, 5120×1440 and 5120×2880); readable wall actions; exact framebuffer sizes; sunlight panel screenshot. Standard globe renders cover two texture presets at six sizes, plus intro renders. These do not establish physical Windows GPU/DPI performance.
- PowerShell 7.5.4: script parsing, resource-helper compilation and 16 update-security checks. Windows PowerShell 5.1 and real NSIS installation/rollback are separate release gates.
- Cross-exported Windows executable and installer: all seven embedded icon images match the source artwork; exported app retains its embedded project.

## Feature limits

Camera Wall has three distinct authorized image endpoints, configurable across 1/2/4/6/9 tiles. Repeated tiles share a source. Two downloads may run concurrently. Unselected, offscreen, minimized, focused-away, closed and screensaver-hidden feeds are stopped. Collections save source/layout choices locally, never camera images. There is no continuous embedded video.

Current UTC sunlight is opt-in. The approximate geometric subsolar point follows NOAA's fractional-year equations: https://gml.noaa.gov/grad/solcalc/solareqns.PDF . Device UTC is sampled every 30 seconds; atmospheric refraction, terrain and apparent solar-disk corrections are omitted. Clouds, Moon and stars remain cinematic. The Night lights screensaver deliberately overrides sunlight with artistic night lighting.

Physical Dell scaling, monitor moves, sleep/resume, visible-window updater restart and screensaver multi-monitor/Windows preview behavior remain field checks. No stable or complete-project claim is made.
