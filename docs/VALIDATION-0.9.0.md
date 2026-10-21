# 0.9.0 arrival experience validation

Released preview, 2026-10-21. Authenticated production update now delivers 0.9.0.

The previous journey stopped at a marker while context remained in the browsing page. Destination journeys now open a named card with the place’s original sourced summary (or a clear search-result fallback), approximate coordinates and actions. Completing the flight changes its status to “You’re here”. Repeated choices replace the card. Camera selection opens the image viewer immediately, retains destination context on close and reports external browser launch status. Saved known camera destinations resolve back to their existing official camera configuration.

Local validation: 464 existing behavior/layout checks, 24 new arrival checks, and native destination renders at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880. Reviewed desktop and compact renders. Screensaver journeys do not open browsing controls; invalid coordinates preserve the current destination. No new network requests are made for ordinary discovery arrivals. Camera imagery remains periodic provider imagery; source pages are external when no image endpoint is configured.

Windows installer upgrade/rollback, native screensaver lifecycle and production signed-feed round trip are release gates. Physical GPU/DPI, multiple-monitor hardware and provider availability remain field conditions.

## Windows and publication evidence

Release workflow 39517861702 built the application from source, passed 488 behavior/layout checks, 16 updater-security checks, native exploration/camera/globe/intro/arrival renders and native launcher argument/command validation. Windows passed real upgrade/rollback from 0.5.2 and 0.8.0 and actual embedded screensaver preview/render/lifecycle checks using a pinned software OpenGL ICD on the disposable test VM. No test driver is shipped. Physical mixed-DPI and multiple-monitor hardware remain separate.

Public installer: 36,640,289 bytes; SHA-256 `b26c5f434d1e55f76311aeba441290f16b8971dc2b906b4dd0c2668c437fe668`. Public bytes matched the published checksum before signing exact metadata with the existing pinned release key. The four-file protocol is unchanged and the private key never entered git or CI. Production-feed staging, cancellation and normal-exit installation are checked after promotion.
