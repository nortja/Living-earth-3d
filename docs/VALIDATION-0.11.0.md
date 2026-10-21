# 0.11.0 validation

Candidate, 2026-10-20. Signed production remains 0.9.0 during release validation. Version 0.11.0 includes the camera, diagnostic and journey improvements from the 0.10.0 validation candidate, together with twelve licensed offline photographs and ten historical teaching contexts.

676 local behavior/layout/integrity checks pass. Every photograph is checked against its committed SHA-256, decoded dimensions, per-file source/creator/license and modification credit. Saved discoveries resolve through the trusted catalog instead of accepting arbitrary asset paths. The viewer rejects non-photo paths, clears full-photo references on close, returns to destination context with Escape and closes before screensaver preview. All twelve actual photographs were visually inspected; Kakadu uses a wetland landscape and Tikal a color forest/temple view.

Native arrival and full-photo layouts are verified from 800×600 through 5K, including attribution bounds. Historical markers use original notes with source links and deliberately broad editorial windows. Modern photographs are not labelled as ancient reconstructions. See DISCOVERY_PHOTOS.md and HISTORY_ATLAS.md for provenance and scope.

Release gates include fresh Windows export and packaging, actual upgrades/rollback from 0.5.2 and the deployed 0.9.0, an actual one-hour embedded Windows preview/render/resize/memory soak, lifecycle cleanup, and production authenticated update staging/cancellation/normal-exit install. Software-rendered CI and simulated power/session messages do not establish physical Dell, multiple-monitor or sleep/resume results. The general failing automatic workflow remains disabled.
