# 0.12.4 candidate validation

Candidate prepared 2026-10-31. Production remains 0.12.3 until fresh Windows/native checks, public-download verification and signed-feed promotion succeed.

## Scope

Unchanged camera bytes retain their already validated texture, avoiding repeated JPEG decoding, resizing and GPU allocation. New bytes retain the same decode/dimension checks, source timing disclosure and error recovery. Monitor refresh polling handles changes on the same display and bounds unknown/non-finite refresh values. Fractional 60 Hz refresh no longer truncates to 59 FPS. The local report includes the complete display inventory, with no network upload.

## Local checks

Official Godot 4.6.3 Linux engine archive verified against its published SHA-512. Clean import passes. Fourteen headless suites pass, 757 checks total: explorer 56, interface 47, ambient 6, UI scale 187, updater 6, camera 41, wall 59, sunlight 20, exploration 61, arrival 26, performance 42, camera expansion 26, photographs/history 126, weather layer 54. Changed-image and oversize rejection retain correct camera state; unchanged texture identity and refreshed source status are checked. Invalid and fractional refresh values preserve bounded desktop/native-saver budgets.

## Required release gates

The release/preview-0.12.4 branch runs fresh source/security/launcher checks, native Linux render/layout suites through 5K and native-saver budgets; a new Windows application, native screensaver and installer; actual Windows upgrades/rollback, Screen Saver Settings, preview/lifecycle soak, and exported desktop/photo/weather/report validation. Publication is gated on all jobs. Exact installer and installed-file hashes must be verified before signing metadata outside git/CI and promoting the feed. Physical Dell GPU/DPI, mixed-monitor and sleep behavior remain field checks.
