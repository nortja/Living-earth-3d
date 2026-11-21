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

Pending the dedicated workflow on the candidate branch. The workflow runs the full performance source suite on Linux and Windows, Linux native rendering at six sizes through 5120x2880, and a Windows native render using checksum-pinned test-only software OpenGL. This is not an installer/release gate or physical Dell/mixed-monitor test.

## Field limitations

Physical Dell U4919DW GPU/DPI, real mixed-DPI moves/hot-plug, Windows sleep/wake and overnight operation remain separate field checks.
