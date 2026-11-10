# Camera refresh failure-state validation

Validated source: `cb85a8f94afbc79555df8093e1ca9dcd4ff6ba83` on `validation/camera-failure-states`.

The camera viewer now distinguishes:
- Network request failures.
- Non-success HTTP responses, including HTTP 304 when there is no validated cached image.
- Empty responses and bodies above the existing 8 MiB limit.
- Unsupported/malformed JPEG data, including dimensions outside the existing 4096-pixel edge limit.
- JPEG decode failures.

Failure text is additive to the existing retained-image behavior. A previously validated texture, its retrieval timestamp and any monotonic unchanged-age warning remain visible. The failure reason is cleared by a subsequent successful image response or valid 304. No request cadence, URL allowlist, body limit, decode bound, backoff, preference or updater behavior changed. No capture time is inferred.

The first validation attempt, [run 42878873804](https://github.com/nortja/Living-earth-3d/actions/runs/42878873804), correctly exposed a test expectation error: a 4097-pixel JPEG was rejected by the 4096-pixel dimension preflight, not by the separate 8 MiB compressed-body limit. The test was corrected to exercise the two limits independently; application behavior was unchanged by that correction.

The corrected [Linux and Windows run 42879035400](https://github.com/nortja/Living-earth-3d/actions/runs/42879035400) passed:
- Godot 4.6.3 project import on both platforms.
- Linux and Windows source suites: camera viewer 45, revalidation 232, expansion 26 and Camera Wall 59 assertions each (362 per platform), zero failures.
- Native camera viewer rendering: zero failures on both platforms. Linux captures 870×612, 2496×1664 and 3840×1080; Windows captures 870×612 using checksum-pinned test-only software OpenGL.
- Generated JPEG fixtures only; no live provider requests were made.

This is targeted source/native validation, not a new installer, upgrade/rollback, screensaver lifecycle soak, public-download/provenance, signature or production-updater test. The published 0.25.1 installer and authenticated feed remain unchanged. The pinned updater key and user preferences were not modified. Physical Dell GPU/DPI, mixed-monitor, sleep/wake and overnight testing remain field checks.
