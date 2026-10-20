# Next bounded integration work

The install-once preview path is `main` and its signed `updates/application.json`. The separate `development` branch has an older isolated 0.6.0 product with its own install folder/settings/update policy. Its installer is preserved at `downloads/windows-0.6.0`. Do not replace that binary or copy its old updater over the authenticated main updater.

## Reuse existing work

Inspect and port modules rather than rebuilding them: `development:scripts/discovery_catalog.gd`, `data/discoveries.json`, `data/history.json`, and `scripts/earth_observations.gd`. That branch contains twelve sourced wonders, an explicitly modern-imagery historical atlas, model-weather/cache handling and two extra screensaver styles. These are isolated prototypes, not features of the currently installed main preview. Preserve current preferences, the pinned trust key, camera images/wall, security tests and update lifecycle when integrating. Validate each source/license and requested-network/error/cache behavior; retain timestamps and model-versus-observation labels.

## Camera expansion research (2026-10-20)

- Official Giant Forest camera page: https://www.nps.gov/media/webcam/view.htm?id=81B461CE-1DD8-B71B-0B5150F44017DA05 . The page links to https://www.nps.gov/featurecontent/ard/webcams/images/sekilarge.jpg . This endpoint was observed through the official page; integrate only after native decoding, dimensions, source credit, current conditions and request cancellation tests. Keep its retrieval time separate from capture time.
- Yosemite Conservancy cameras require their usage agreement before featuring them: https://www.nps.gov/yose/learn/photosmultimedia/webcams.htm . Keep provider pages external until authorization and playback are resolved. A public webcam page alone does not establish permission to embed a stream.
- Godot 4.6.3 advertises `--wid` parent-window support. Investigate a small Windows screensaver launcher for `/p` and actual native embedding tests before replacing the current no-preview behavior. Reference: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html . Do not enable a fullscreen fallback for a Windows preview request.

## Field evidence still needed

Actual installed-version report after automatic upgrade, real camera display, visible-window update restart, Dell resolution/DPI/GPU/frame times, monitor movement, sleep/resume, Windows screensaver activation/input exit and multi-monitor coverage. CI installation/rollback and Linux software renders do not establish these results.
