# Camera Wall recovery after long frame gaps

Reviewed November 14, 2026. Source change is proposed in [PR #8](https://github.com/nortja/Living-earth-3d/pull/8). This is a source/native reliability follow-up only; it does not change the application version, installer or authenticated update feed.

## Behavior

When the active Camera Wall receives a frame delta of at least 30 seconds, it treats the gap as a possible sleep or renderer interruption rather than replaying every missed refresh interval in one frame.

- In-flight requests are canceled through the existing camera suspension path, which invalidates their generation tokens and retains validated image textures, retrieval timestamps, failure explanations and unchanged-image age.
- Overdue automatic or explicitly requested refreshes are re-armed in deterministic two-second URL order.
- The existing two-simultaneous-request cap remains in force. Tests also confirm that a source which was not yet due keeps its remaining interval.
- Each source retains its current retry interval/backoff. Sources that were not yet due keep the remaining interval after the gap.
- Late responses from before the gap cannot replace retained data.

The 30-second threshold is a frame-gap heuristic. It is not a Windows power/session event detector and does not establish that physical sleep/wake behavior has been tested.

## Validation

[GitHub Actions run 43626827474](https://github.com/nortja/Living-earth-3d/actions/runs/43626827474) passed on November 14, 2026.

- Godot 4.6.3 project import passed on Linux and Windows.
- Linux and Windows each passed 393 targeted camera assertions: 57 camera viewer, 232 revalidation, 26 expansion and 78 Camera Wall.
- Linux native camera-viewer renders passed at 870×612, 2496×1664 and 3840×1080.
- Windows native camera-viewer render passed at 870×612 using checksum-pinned, test-only software OpenGL.
- Fixture images were used; the validation did not make live provider requests.

These are source/native CI results. They do not establish physical Dell GPU/DPI performance, mixed-monitor movement, actual Windows sleep/resume, lock/unlock or overnight behavior. The full installer, upgrade/rollback, public download, signature and production updater gates were not run because no release was prepared.
