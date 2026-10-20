# 0.9.0 arrival experience validation

Candidate, 2026-10-20. Production remains 0.8.0 until Windows gates pass.

The previous journey stopped at a marker while context remained in the browsing page. Destination journeys now open a named card with the place’s original sourced summary (or a clear search-result fallback), approximate coordinates and actions. Completing the flight changes its status to “You’re here”. Repeated choices replace the card. Camera selection opens the image viewer immediately, retains destination context on close and reports external browser launch status. Saved known camera destinations resolve back to their existing official camera configuration.

Local validation: 464 existing behavior/layout checks, 24 new arrival checks, and native destination renders at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880. Reviewed desktop and compact renders. Screensaver journeys do not open browsing controls; invalid coordinates preserve the current destination. No new network requests are made for ordinary discovery arrivals. Camera imagery remains periodic provider imagery; source pages are external when no image endpoint is configured.

Windows installer upgrade/rollback, native screensaver lifecycle and production signed-feed round trip are release gates. Physical GPU/DPI, multiple-monitor hardware and provider availability remain field conditions.
