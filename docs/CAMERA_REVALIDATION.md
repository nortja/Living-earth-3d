# Camera request and decode efficiency

0.12.4 reuses already validated textures when a successful 200 response contains identical image bytes. 0.13.1 additionally sends If-None-Match when the selected source has provided a valid, bounded ETag for an already decoded image. Sources without usable ETags continue through the normal 200/JPEG/hash path.

A successful HTTP 304 retains the original texture and image-retrieval timestamp. Status reports the new check time separately, retains the last reported source Last-Modified value, and continues the elapsed unchanged-image warning. It clears failure backoff without implying a new capture. A 304 without a validated image and validator is unavailable. Camera changes clear validators, and generation tokens reject late responses. Pause/visibility suspension retain successful in-memory images and validators for their original source only; there is no disk camera cache or background service.

Unreleased source change, November 7, 2026: elapsed unchanged-image age uses monotonic engine ticks, independent of corrections to the computer's UTC clock. Retrieval and provider metadata remain separately labeled UTC/source values. Identical HTTP 200 bytes, HTTP 304 and failed refreshes retain the timer; a changed decoded frame resets it. The existing five-minute/provider-cadence thresholds and request behavior are unchanged. This is not a verified camera-capture age. See [targeted validation](VALIDATION-CAMERA-AGE.md).

ETags are restricted to bounded printable quoted ASCII values (including weak tags); malformed, newline/control, list or oversized values are ignored. They are sent only to the existing explicit image URL allowlist. Periodic-image source timestamps are not asserted to be verified capture times. The wall still deduplicates sources, pauses hidden work and caps simultaneous requests at two.

JPEG preflight scans bounded marker segments until a supported frame header supplies dimensions. Truncated, malformed, wrong-format or oversized dimensions are rejected before the image decoder allocates pixels. Existing 8 MiB compressed and 4096×4096 source limits are preserved; wall textures remain capped at 1920 pixels on the longest edge. The preflight accepts baseline/progressive markers and does not replace actual JPEG decoding/validation. HTTP errors retain the last good image with explicit error state.

Protocol reference: RFC 9110, entity validators/If-None-Match and 304 semantics, https://www.rfc-editor.org/rfc/rfc9110.html . No code or excerpts were copied from the standard.

Validation covers 25 behavior/parser cases plus 200 deterministic malformed inputs, retained texture identity/date, source-switch cancellation, rejected first-response 304, metadata replacement and real provider fallback. The optional live-camera harness now uses the actual image-source count and exercises one conditional request when a provider supplies a valid ETag.
