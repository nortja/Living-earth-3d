# Next bounded integration work

The install-once preview path is `main` and its signed `updates/application.json`. The separate `development` branch has an older isolated 0.6.0 product with its own install folder/settings/update policy. Its installer is preserved at `downloads/windows-0.6.0`. Do not replace that binary or copy its old updater over the authenticated main updater.

## Integrated in 0.7.0

The development-track discovery/history data and catalog have been integrated with new bookmark, exploration and weather modules. Daily wonders, modern-imagery historical-site filtering, requested point-model weather and two additional screensaver styles now ship on main. The pinned updater and existing preferences were preserved. Giant Forest is the fourth tested in-app image camera. Do not re-port the old development updater or rebuild these features.

Native Windows screensaver preview and per-monitor lifecycle integration shipped in 0.8.0. Next bounded work is physical mixed-DPI/multi-monitor validation and a longer-duration lifecycle soak. Continuous video requires an authorized source and a suitable playback integration. Physical GPU/DPI and visible restart evidence remain separate from CI.

## Camera expansion research (2026-10-20)

- Official Giant Forest camera page: https://www.nps.gov/media/webcam/view.htm?id=81B461CE-1DD8-B71B-0B5150F44017DA05 . The page links to https://www.nps.gov/featurecontent/ard/webcams/images/sekilarge.jpg . This endpoint was observed through the official page; Integrated in 0.7.0 after native decoding, dimensions, source credit and request cancellation tests. Keep its retrieval time separate from capture time.
- Yosemite Conservancy cameras require their usage agreement before featuring them: https://www.nps.gov/yose/learn/photosmultimedia/webcams.htm . Keep provider pages external until authorization and playback are resolved. A public webcam page alone does not establish permission to embed a stream.
- Godot 4.6.3 advertises `--wid` parent-window support. Implemented the native `/p` launcher and actual Windows parent/resize/render/cleanup tests in 0.8.0. Reference: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html . Do not enable a fullscreen fallback for a Windows preview request.

## Field evidence still needed

The user confirmed the 0.6.1 update and working Camera Wall/cameras. The user also confirmed the 0.7.0 and 0.8.0 updates. Version 0.9.0 repairs destination arrival context and saved-camera viewing. Still needed: native screensaver behavior, visible-window update restart, Dell resolution/DPI/GPU/frame times, monitor movement, sleep/resume, Windows screensaver activation/input exit and multi-monitor coverage. CI installation/rollback and Linux software renders do not establish these results.
