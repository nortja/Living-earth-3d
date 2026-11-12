# Camera window focus lifecycle validation

November 12, 2026. The selected image-camera viewer and Camera Wall now suspend network activity when the application window loses focus, as well as when it is minimized, hidden, closed or entering screensaver preview. Godot 4.6 Window focus signals drive the transition; no per-frame focus polling or new permissions are added.

For the selected viewer, focus loss cancels and releases an in-flight HTTPRequest, advances the request generation so late callbacks are ignored, and retains the last validated image, retrieval timestamp, failure reason and monotonic unchanged-image warning. Automatic retry wording says it resumes when Living Earth is active again. Focus return restores normal status and bounded retry scheduling. Minimize and focus states are combined, so returning focus while still minimized does not resume network work.

For Camera Wall, the manager owns window focus and stops every child request while the app is inactive. Child camera services do not subscribe independently, avoiding conflicting lifecycle owners. Existing validated tile images remain visible; on focus return the existing two-request scheduler restarts without a request fan-out. The wall status explains pause/resume. Per-tile offscreen handling, saved collections, request limits, provider allowlist and image bounds are unchanged.

The regressions simulate focus-out/focus-in with pending requests and generated JPEG fixtures. They verify cancellation, late-response rejection, retained-image identity/age, failure wording, restore behavior and Camera Wall scheduler limits. No live provider requests are made.

The dedicated workflow is .github/workflows/validate-camera-age.yml, triggered on validation/camera-focus-lifecycle and serialized with the existing camera lifecycle group. Linux runs the four camera source suites and native viewer renders at 870×612, 2496×1664 and 3840×1080. Windows runs the same source suites and a native 870×612 viewer render using checksum-pinned test-only software OpenGL. [Final Linux and Windows validation run 43279715216](https://github.com/nortja/Living-earth-3d/actions/runs/43279715216) passed:
- Godot 4.6.3 project import on both platforms.
- Per platform: camera viewer 57, revalidation 232, expansion 26, Camera Wall 65 assertions — 380 checks, zero failures.
- Native viewer render passed with zero failures. Linux captured 870×612, 2496×1664 and 3840×1080; Windows captured 870×612 using checksum-pinned test-only software OpenGL.
- Generated JPEG fixtures only; no live provider requests.

An initial run, 43278935914, exposed an outdated assertion that still expected the earlier “viewer is visible” retry wording. The test expectation was corrected, and the complete final Linux/Windows run above passed.

This is source/native validation only. It does not establish physical Dell GPU/DPI, mixed-monitor, real sleep/wake, lock/unlock, overnight, installed-screensaver or actual-provider behavior. A separately versioned installer, upgrade/rollback, installed Windows lifecycle, public download/provenance, pinned-key signature and production updater roundtrip have not been run for this source-only change. The published 0.25.1 installer and authenticated feed, pinned updater trust key, updater helper bytes, user preferences and disabled legacy automatic workflow remain unchanged.
