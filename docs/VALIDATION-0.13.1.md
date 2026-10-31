# 0.13.1 candidate validation

Prepared 2026-10-31. Includes 0.13.0's dated NASA satellite globe and adds camera ETag revalidation and pre-decode JPEG dimension bounds. See CAMERA_REVALIDATION.md for behavior and protocol details.

Local camera revalidation tests pass 225 checks: 25 behavior/parser cases and 200 deterministic malformed-input cases. Existing camera-viewer checks pass. Fresh final source/native/Windows release gates remain required before publication and authenticated feed promotion. The optional real-provider test is being run separately; failures must be reported as provider evidence, not hidden by fixture passes.

The release/preview-0.13.1 workflow preserves all prior packaging, security, native render, Windows upgrade/rollback, settings, preview/lifecycle and installed desktop gates, and includes the new camera-revalidation suite. No signature/hash checks, pinned trust key, preference storage or Windows running-app protections change.

All sixteen local headless suites pass (804 behavior/layout cases plus 200 malformed JPEG inputs, 1004 counted checks). The optional live test retrieved all eight image sources through the final JPEG preflight and performed a real Yellowstone ETag request yielding HTTP 304. The retained image check time was separate from retrieval time. Retrieval does not establish capture freshness.
