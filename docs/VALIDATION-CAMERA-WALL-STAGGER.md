# Camera Wall startup and resume staggering

November 13, 2026. Camera Wall now spaces automatic image retrievals by a deterministic two-second interval when a wall is first opened and when suspended/offscreen services become eligible again. The source order is derived from sorted allowlisted image URLs, so the order is stable across runs. When only selected tiles are visible, the stagger is calculated over those eligible sources.

The existing global two-request concurrency limit remains the final resource bound. Explicit user-requested Refresh remains queued through the same scheduler and retains its existing behavior. This change does not add providers, background services, telemetry, persistent image caching or network permissions. It does not change retry backoff, image-size limits, URL allowlists, camera timestamps or the distinction between periodic images and continuous video.

## Validation

[Final Linux and Windows validation run 43480222929](https://github.com/nortja/Living-earth-3d/actions/runs/43480222929) passed on the pull-request head:

- Godot 4.6.3 project import on Linux and Windows.
- Linux and Windows each passed camera viewer (57), camera revalidation (232), camera expansion (26) and Camera Wall (69): **384 assertions per platform, zero failures**.
- Native camera viewer render passed with zero failures. Linux captured 870×612, 2496×1664 and 3840×1080. Windows captured 870×612 using checksum-pinned test-only software OpenGL.
- Generated JPEG fixtures only; no live provider requests.
- The new Camera Wall assertions verify first-source immediate eligibility, two-second spacing, a third source becoming eligible after the next slot frees, the two-request cap, and the same spacing after suspension/resume.

The initial run [43479881655](https://github.com/nortja/Living-earth-3d/actions/runs/43479881655) failed because the revised test fixture omitted its SceneTree entrypoint and left two arithmetic variables untyped. Both test-harness issues were corrected before the final passing run; application scheduling/security limits were not relaxed.

This is source/native validation only. No installer build, upgrade/rollback, installed screensaver lifecycle, public download verification, signature verification or production updater roundtrip was run for this change. The 0.25.1 installer/feed, pinned updater trust key, updater helpers and user preferences remain unchanged. Physical Dell GPU/DPI, mixed-monitor, lock/sleep/wake and overnight behavior remain field checks.
