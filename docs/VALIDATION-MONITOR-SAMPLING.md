# Monitor topology sampling diagnostics

Status: validated and merged to main on November 21, 2026.

## Change

The optional local five-minute display recording now reports:

- total topology samples, including the initial baseline;
- maximum active-time interval between samples;
- number of intervals greater than 1.5 seconds;
- the explicit 1.5-second warning threshold.

The nominal polling cadence remains one active second. Metrics use recorded active time, so minimized windows and sleep-sized frame gaps remain excluded by the existing recorder. A long interval is evidence of reduced sampling coverage, not proof that a topology change was missed. A change that begins and ends between samples cannot be reconstructed.

The report remains local and opt-in. The addition is backward-compatible within schema 1; it does not change preferences, network requests, app version, installer, updater trust key or release feed.

## Validation

The first candidate run, [44935376018](https://github.com/nortja/Living-earth-3d/actions/runs/44935376018), exposed one stale test assertion that still expected the previous sampling-limit sentence. That failed attempt is not counted as a pass. The assertion was corrected, and the final dedicated no-publication workflow [44935590020](https://github.com/nortja/Living-earth-3d/actions/runs/44935590020) passed:

- Godot 4.6.3 import on Linux and Windows.
- 66 performance source assertions with zero failures on each OS.
- Linux native display-report renders at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880, zero failures.
- Windows native display-report render at 870×612, zero failures, using checksum-pinned test-only software OpenGL.

Camera lifecycle regression [44935594818](https://github.com/nortja/Living-earth-3d/actions/runs/44935594818) also passed on Linux and Windows: 57 viewer, 232 revalidation, 26 expansion and 78 Camera Wall assertions per OS, plus native camera-age rendering with zero failures.

This is source/native validation, not an installer/release gate or physical Dell/mixed-monitor test.

## Field limitations

Physical Dell U4919DW GPU/DPI, real mixed-DPI moves/hot-plug, Windows sleep/wake and overnight operation remain separate field checks.

The stale wording assertion was corrected on the candidate branch before accepting validation; the failed first attempt remains recorded above and is not counted as a pass.
