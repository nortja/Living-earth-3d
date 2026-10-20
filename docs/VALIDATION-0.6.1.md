# 0.6.1 preview validation

Candidate validated on Linux and Windows, 2026-10-20. Release run: https://github.com/nortja/Living-earth-3d/actions/runs/39496542551 . The public installer was downloaded and matched SHA-256 5471db38bb3e8b32e00bae53a42b298a386e47b13fe7f98b22071c644b8b79bf (36,439,352 bytes). Exact metadata was signed with the pinned release key and verified with the installed PowerShell reader before feed promotion.

- Godot 4.6.3: 400 behavior/data/layout checks across explorer, interface, scale, audio, updates, camera viewer, camera wall and solar position. Fixture camera images are used only in tests.
- Three real NPS camera images retrieved and decoded at 1920×1080. Retrieval does not establish camera capture freshness or future provider availability.
- Native Linux software OpenGL: twelve wall renders (1/4/9 views at 800×600, 1920×1080, 5120×1440 and 5120×2880); readable wall actions; exact framebuffer sizes; sunlight panel screenshot. Standard globe renders cover two texture presets at six sizes, plus intro renders. These do not establish physical Windows GPU/DPI performance.
- PowerShell 7.5.4: script parsing, resource-helper compilation and 16 update-security checks. Windows PowerShell 5.1 and real NSIS installation/rollback are separate release gates.
- Cross-exported Windows executable and installer: all seven embedded icon images match the source artwork; exported app retains its embedded project.

## Feature limits

Camera Wall has three distinct authorized image endpoints, configurable across 1/2/4/6/9 tiles. Repeated tiles share a source. Two downloads may run concurrently. Unselected, offscreen, minimized, focused-away, closed and screensaver-hidden feeds are stopped. Collections save source/layout choices locally, never camera images. There is no continuous embedded video.

Current UTC sunlight is opt-in. The approximate geometric subsolar point follows NOAA's fractional-year equations: https://gml.noaa.gov/grad/solcalc/solareqns.PDF . Device UTC is sampled every 30 seconds; atmospheric refraction, terrain and apparent solar-disk corrections are omitted. Clouds, Moon and stars remain cinematic. The Night lights screensaver deliberately overrides sunlight with artistic night lighting.

Physical Dell scaling, monitor moves, sleep/resume, visible-window updater restart and screensaver multi-monitor/Windows preview behavior remain field checks. No stable or complete-project claim is made.

## Windows release evidence

Windows PowerShell 5.1 passed script parsing and all 16 update-security checks. The actual silent installer upgraded a path containing spaces from 0.5.2, preserved a user-data sentinel, installed the versioned desktop icon, rejected replacement while the application was running, uninstalled successfully, and restored the previous application plus registry version after a deliberate post-install hash failure. This is installation/handled-rollback evidence, not a physical GPU/DPI or power-loss recovery guarantee.

## Production automatic-update round trip

Passed on Windows PowerShell 5.1 in https://github.com/nortja/Living-earth-3d/actions/runs/39497455307 . The real public signed feed and installer were staged while an older fixture app remained open; cancellation left the installed application unchanged. Resuming waited for normal app exit, installed silently, checked every signed installed-file hash and did not reopen an intentionally closed app. The test required the final production manifest to be exactly 0.6.1. Physical visible-window restart and first upgrade on the user's computer remain separate observations.

Two additional local regression checks passed after release: Night lights preview overrides current sunlight, and leaving that preview restores the saved UTC sunlight direction. The release build ran 400 behavior checks; these add two source regression assertions without changing the installed application.
