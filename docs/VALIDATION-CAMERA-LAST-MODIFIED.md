# Last-Modified camera revalidation fallback

Status: merged into `main` in [PR #21](https://github.com/nortja/Living-earth-3d/pull/21), squash commit [1aff5a6](https://github.com/nortja/Living-earth-3d/commit/1aff5a61f7853363a38a21b45526e860e086eff2). Targeted Linux/Windows source and native-viewer validation passed in [workflow 45465869474](https://github.com/nortja/Living-earth-3d/actions/runs/45465869474).

## Behavior

The selected-camera viewer continues to prefer `If-None-Match` when a previously decoded image has a valid ETag. If no valid ETag is available, it may send `If-Modified-Since` only when the retained image/digest exists and the provider's Last-Modified value passes a fixed-width IMF-fixdate validator.

The validator rejects non-date display strings, obsolete formats, control/header-injection characters, invalid time fields, years before 1601, and impossible month/day combinations. Leap-year February 29 is accepted only in leap years. The Last-Modified value is sanitized for single-line display. ETag remains preferred, and the request sends at most one conditional validator.

The service records which validator was actually attached to the current request. A 304 is accepted only for that request and only while a validated image/digest remains available. A stale validator value, unsolicited 304, first-response 304, or 304 after switching cameras cannot create or relabel an image. An accepted 304 retains the original texture and image-retrieval timestamp, reports the check time separately, preserves monotonic unchanged-image age, and clears failure backoff without implying a new capture.

A 200 response, Last-Modified value, ETag, or 304 response is not a verified camera capture time. The viewer continues to say that capture time is not verified and distinguishes periodic imagery from continuous video. Existing source allowlists, request limits, retry/backoff, generation cancellation, cached-image retention and user-triggered networking are unchanged.

## Validation

Pinned Godot 4.6.3 targeted workflow [45465869474](https://github.com/nortja/Living-earth-3d/actions/runs/45465869474) completed successfully on both Linux and Windows:

- Camera viewer: 57 assertions per OS.
- Camera revalidation: 249 assertions per OS.
- Camera expansion: 26 assertions per OS.
- Camera Wall: 78 assertions per OS.
- Total: 410 assertions per OS, zero failures.
- Native camera-age viewer render: zero failures on both OSes.

Linux rendered the native camera-age viewer at 870×612, 2496×1664 and 3840×1080 under the workflow's virtual desktop. Windows rendered the native viewer at 870×612 with checksum-pinned, test-only software OpenGL. These are automated software-rendered checks, not physical GPU or monitor tests.

The first candidate attempts exposed test-harness issues: inferred types for values read from an untyped fixture object, then a native 304 fixture that did not model the real conditional request. Both harness issues were corrected. The final workflow above validates the final PR head.

## Release and field limits

This was a source/test-only change. No installer, payload hashes, update manifest, detached signature, updater helper, pinned public trust key, preferences or saved scenes changed. The authenticated production baseline remains 0.25.1. No production update was published.

This workflow does not satisfy installer publication, independent public-download verification, release signature or production updater-roundtrip gates. Physical camera-provider freshness, Dell GPU/DPI, mixed-DPI movement, monitor hot-plug, sleep/wake and overnight operation remain separate field checks.
