# 0.13.1 preview validation

Released 2026-10-31. Frozen application source `2365fe88307a1e3e370179d9080ad21596c6ecbd`, tree `48df35fbfa2dc41cccd5266be42631045012dc72`. [Full release pipeline](https://github.com/nortja/Living-earth-3d/actions/runs/41224574684) passed build, Windows installation/native screensaver, installed desktop and public installer publication. No failed or superseded candidate was signed.

## Delivered behavior

Includes the previous-day NASA GIBS NOAA-20/VIIRS dated satellite globe, immediate offline return, bounded ETag/304 camera revalidation, pre-decode JPEG bounds and repaired initial satellite Load visibility at small window sizes. Observation, retrieval and recheck times remain distinct. Clouds/night lights are hidden on the unshaded satellite surface. Requests remain explicit and native screensavers remain offline.

## Evidence

- All sixteen source suites: 807 behavior/layout checks plus 200 malformed JPEG cases, 1007 total; ten Python provenance/tampering checks.
- Eight actual camera sources retrieved; Yellowstone returned an actual conditional HTTP 304. Retrieval does not establish capture freshness.
- Actual previous-day NASA imagery retrieved and rendered natively at 800×600, 1920×1080, 3840×1080 and 5120×2880. Screenshots reviewed after the narrow-window repair.
- Build job 124605944077 passed source/security/package/icon and native rendering gates.
- Windows job 124607832614 passed upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status suites, actual Screen Saver Settings/dropdown, embedded preview and 605.2-second preview soak/lifecycle checks.
- The exported native preflight wrote fresh readiness JSON after an actual rendered Windows frame: 320×200 viewport, uptime 3379 ms. A visible window and normal close within five seconds were required.
- Installed desktop job 124607832644 passed exported photograph/model/satellite fixtures, initial narrow-window Load bounds and a 300.0103-second performance recording: 17,833 frames, mean 16.8233 ms, one frame above 50 ms. Unavailable engine-memory counters remain null.
- Publish job 124610911050 passed. The maintainer verifier independently checked successful workflow/source provenance, exact public updater URL, BUILD source, checksum, size and four installed-file hashes before signing.

## Exact delivery

Installer: `LivingEarth3D-Setup-0.13.1.exe`; 51,352,474 bytes; SHA-256 `10b6c30bb686384d071595fd8127a2123d1dd608a431a3b1c7a4843e37a9cced`.

The existing private key stayed outside git and CI. The exact manifest was signed and independently verified against the installed updater's pinned public key; application.json, application.sig and preview.json are promoted atomically with source. Windows publisher signing is separate; this remains a publisher-unsigned preview. [Production-feed Windows roundtrip 41226795602](https://github.com/nortja/Living-earth-3d/actions/runs/41226795602), job 124612517505, passed: live signature/download staging while the baseline remained open, cancellation without replacement, installation after normal exit, exact installed-file verification, no unwanted restart and cleanup uninstall.

## Superseded attempts and readiness repair

0.13.0 passed its corrected pipeline but was superseded before feed promotion after screenshot review exposed a partly clipped initial satellite Load action. A regression reproduced the 800×600 defect and passed after the sheet-height repair.

Runs 41220863193 and 41222250448 passed build/installed desktop gates but failed native standalone preflight before embedded preview. They are not release passes. Targeted frozen-binary diagnostic run 41223626432 showed responsive graphics processes closing normally with zero exit codes across settings/cache/working-directory variations; their frame-ready log text appeared after exit but was not readable live. The release logger buffered the signal. An unrelated post-exit diagnostic null field is not counted as a passing check.

The final opt-in validation hook flushes and closes readiness JSON after RenderingServer.frame_post_draw. Headless execution cannot produce it; ordinary app/saver operation never enables it. Final complete pipeline 41224574684 then passed. Close deadlines, signatures, hashes and running-app protection were preserved.

## Limits

Software-rendered CI does not establish physical Dell GPU/DPI, multiple-monitor, sleep/resume, power, audible playback or overnight behavior. Satellite gaps remain real no-data; this dated mosaic is not a complete current cloud layer or continuous video.
