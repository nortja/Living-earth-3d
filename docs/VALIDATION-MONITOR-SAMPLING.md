# Monitor topology sampling diagnostics

Status: candidate validation pending.

## Change

The optional local five-minute display recording now reports:

- total topology samples, including the initial baseline;
- maximum active-time interval between samples;
- number of intervals greater than 1.5 seconds;
- the explicit 1.5-second warning threshold.

The nominal polling cadence remains one active second. Metrics use recorded active time, so minimized windows and sleep-sized frame gaps remain excluded by the existing recorder. A long interval is evidence of reduced sampling coverage, not proof that a topology change was missed. A change that begins and ends between samples cannot be reconstructed.

The report remains local and opt-in. The addition is backward-compatible within schema 1; it does not change preferences, network requests, app version, installer, updater trust key or release feed.

## Validation

The first candidate run, [44935376018](https://github.com/nortja/Living-earth-3d/actions/runs/44935376018), exposed one stale test assertion that still expected the previous sampling-limit sentence. The implementation and new boundary/export assertions ran, but both OS jobs correctly failed the full suite on that outdated wording check. The assertion now checks the replacement disclosure; the complete workflow is being rerun before this candidate can be accepted. The workflow runs the full performance source suite on Linux and Windows, Linux native rendering at six sizes through 5120x2880, and a Windows native render using checksum-pinned test-only software OpenGL. This is not an installer/release gate or physical Dell/mixed-monitor test.

## Field limitations

Physical Dell U4919DW GPU/DPI, real mixed-DPI moves/hot-plug, Windows sleep/wake and overnight operation remain separate field checks.

The stale wording assertion was corrected on the candidate branch before accepting validation; the failed first attempt remains recorded above and is not counted as a pass.
