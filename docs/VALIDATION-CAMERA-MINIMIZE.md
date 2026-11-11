# Camera viewer minimize/resume validation

November 11, 2026. The selected single-camera viewer now polls the native window mode and suspends its service when the app is minimized. Suspending invalidates the request generation, cancels and releases an in-flight HTTPRequest, and prevents a late response from replacing the retained image. The viewer keeps the last validated texture, original retrieval timestamp, previous failure reason and monotonic unchanged-image warning. A suspended failure message says that automatic retry resumes when the viewer becomes visible; restore returns the normal retry/status wording. The image-camera allowlist, request cadence, retry backoff, response/decode limits, user preferences, camera-wall scheduler and updater are unchanged.

The source regression simulates minimize/restore transitions, a pending request, a late response, repeated minimized polls and retained stale-image warnings. The native viewer regression exercises the same transition path with a generated JPEG fixture and confirms that the UI retains the last-good image and its elapsed-age warning. No live provider requests are made.

[Linux and Windows validation run 43077965673](https://github.com/nortja/Living-earth-3d/actions/runs/43077965673) passed:
- Godot 4.6.3 project import on both platforms.
- Linux and Windows source suites: camera viewer 52, revalidation 232, expansion 26 and Camera Wall 59 assertions each (369 per platform), zero failures.
- Native camera viewer rendering: zero failures on both platforms. Linux captures 870×612, 2496×1664 and 3840×1080; Windows captures 870×612 using checksum-pinned test-only Mesa software OpenGL (Microsoft Basic Render Driver).
- Generated JPEG fixtures only; no live camera/provider requests.
- The validation workflow uses a non-cancelling concurrency group so candidate runs do not overlap.

This is targeted source/native validation. The transition tests exercise the same minimize-state handler but do not constitute physical Dell, mixed-DPI, multi-monitor, sleep/wake, overnight or hardware-GPU testing. The Windows CI renderer is software-rendered. A separately versioned installer, upgrade/rollback, installed screensaver lifecycle, public download/provenance, pinned-key signature and production updater roundtrip have not been run for this source-only change.

The published 0.25.1 installer and authenticated update feed remain unchanged. The pinned updater trust key, updater helper bytes, existing preferences and old disabled automatic workflow were not modified. No release was published.
