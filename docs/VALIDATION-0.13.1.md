# 0.13.1 candidate validation

Prepared 2026-10-31. Includes 0.13.0's dated NASA satellite globe and adds camera ETag revalidation and pre-decode JPEG dimension bounds. See CAMERA_REVALIDATION.md for behavior and protocol details.

Local camera revalidation tests pass 225 checks: 25 behavior/parser cases and 200 deterministic malformed-input cases. Existing camera-viewer checks pass. Fresh final source/native/Windows release gates remain required before publication and authenticated feed promotion. The optional real-provider test is being run separately; failures must be reported as provider evidence, not hidden by fixture passes.

The release/preview-0.13.1 workflow preserves all prior packaging, security, native render, Windows upgrade/rollback, settings, preview/lifecycle and installed desktop gates, and includes the new camera-revalidation suite. No signature/hash checks, pinned trust key, preference storage or Windows running-app protections change.

All sixteen local headless suites pass (804 behavior/layout cases plus 200 malformed JPEG inputs, 1004 counted checks). The optional live test retrieved all eight image sources through the final JPEG preflight and performed a real Yellowstone ETag request yielding HTTP 304. The retained image check time was separate from retrieval time. Retrieval does not establish capture freshness.

## Narrow-window repair before promotion

Inspection of the installed 0.13.0 Windows screenshot showed the initial Load action partially below the scroll viewport. A regression assertion reproduced this at 800×600 (25 satellite checks, one failure). The final 0.13.1 candidate gives Satellite view the same taller small-window sheet as Weather globe; source/native and installed Windows validation now require the initial Load action to be fully visible without scrolling. 0.13.0 is a superseded candidate and must not be promoted to the production feed; 0.13.1 includes its feature and this correction.

The maintainer-only release verifier has ten passing provenance/tampering tests and has independently verified the completed 0.12.4 run and public delivery. It is excluded from the user app and receives no signing key. Final 0.13.1 source/native/Windows gates must rerun after this repair.

Final repaired local source passes all sixteen Godot suites: 807 behavior/layout cases plus 200 malformed JPEG inputs (1007 counted checks), and ten Python provenance/tampering tests. Actual NOAA-20 native renders pass at four sizes including 800×600 and 3840×1080, with the initial Load action fully visible; screenshots were visually inspected. Fresh Windows/native CI will validate the final frozen candidate.

## Graphics preflight repair

Run 41220863193 built and passed native/source gates, Windows upgrades/rollback and settings, but its screensaver job stopped before embedded preview: standalone preflight did not close within five seconds after a fixed three-second startup delay. This is not counted as a preview pass. The old harness could enumerate windows before the engine was ready and then send no close message. The final candidate replaces the delay with an opt-in real first-frame signal plus a visible-window check (bounded 30 seconds), keeps the five-second close deadline and checks a zero exit code. It captures preflight logs on failure. Artifact names include run_attempt for safe diagnostic retention. A fresh application build is required because the readiness probe is compiled into the app; it runs only with the explicit native validation flag and never in ordinary user/saver operation. The original failure's precise cause remains unconfirmed until the corrected run finishes.

Local graphics validation confirms the opt-in native probe emits readiness after an actual frame and that headless execution cannot emit the marker. The live log reader permits existing writer/delete sharing. Ordinary application/saver arguments do not enable the probe. Final source regressions and a fresh complete CI run follow the probe change.

## Release-log buffering diagnosis and explicit readiness file

The first-frame/log-based candidate 441553991c4885902f2efba9f8db4750a730f097 still failed preflight in run 41222250448. The independent installed desktop again passed. Targeted diagnostic run 41223626432 reused those exact binaries across four combinations of prior settings/no settings and default/disabled Mesa cache. Direct installed-directory, direct repository-directory and shell launches all remained responsive and closed with exit code zero; each release log contained the first-frame marker only when read after process exit, while the live reader saw no marker. No script errors were present. Headless native processes exited, although an unrelated diagnostic process-inspection field raised a null-value error after exit; this is diagnostic evidence, not a release gate pass.

The final application therefore writes its explicitly requested readiness JSON only after RenderingServer.frame_post_draw, flushes and closes it, and refuses to overwrite an existing marker. The Windows harness removes its own old marker and validates fresh platform/display/frame/viewport data plus a visible window before its unchanged five-second close check. Buffered print output is diagnostic only. The file is written only with both native validation arguments, never in ordinary application/screensaver use. A new full build and all release gates are required for this final application change; failed earlier runs must not be signed.
