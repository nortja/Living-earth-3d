# 0.24.0 validation — synchronized Moon and Scene Library

Candidate in progress. [Feature details](SCENE_LIBRARY.md). Keep the production update on 0.23.0 until the frozen candidate passes fresh source/native/Windows gates and independent public delivery/signature verification. Publication and final production updater results will be recorded here after completion.

Moon checks use projected tangent geometry across seven zoom distances and five viewport sizes, verify stable relative size/spacing and final tween state. Scene behavior tests cover strict finite profiles, local persistence/restart, temporary versus explicitly saved choices, navigation/manual/saver interruption and reversible removal.

The native scene test saves and decodes real bounded thumbnails, checks primary controls at eight sizes, plays an actual timed fade, compares Moon-on/off rendered pixels at two zoom distances and reloads saved metadata and thumbnails from disk; the source suite separately restarts the full application. The installed Windows cursor/PNG validator also saves two scenes, measures Moon shrinkage and plays a transition. Six native saver styles remain unchanged; no library is constructed in native saver mode.

Virtual Windows/Linux software framebuffers do not establish physical Dell GPU/DPI, mixed-monitor, idle/sign-in, sleep or overnight reliability. Current UTC and lunar accuracy retain the existing published source/date limits.
