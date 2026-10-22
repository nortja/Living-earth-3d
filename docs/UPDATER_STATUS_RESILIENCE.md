# Updater status resilience — development

The released 0.12.2 helper uses `Move-Item -Force` to overwrite `status.json`.
The first production roundtrip attempt reported “Cannot create a file when that
file already exists.” The second attempt passed unchanged. The original failure
is not yet reproduced conclusively; this change addresses a plausible status
replacement failure path, without claiming that it explains that incident.

The development helper writes complete UTF-8 JSON to a unique adjacent temporary
file, then uses `File.Replace` for an existing status or `File.Move` for the first
status. An I/O replacement failure gets at most six attempts, 100 ms apart. A
failed write preserves the previous status, cleans its temporary file, emits a
warning and returns false. The updater treats status as advisory and continues
its existing signature/hash/cancellation/running-app checks. A prolonged reader
lock can leave the displayed status stale; subsequent status transitions retry.
No installer payload, signature protocol, trust key or published feed changes.

## Validation

Local PowerShell 7.5.4 on Linux: 205 status checks pass (first write, Unicode,
timestamp, 100 replacements with JSON reads, unavailable-directory failure and
temporary-file cleanup). The existing 16 release-security checks pass, and the
Windows script parser/native helper compilation checks pass. Linux does not
establish Windows delete-sharing behavior.

`tests/update_status_test.ps1` additionally holds a real Windows reader without
delete sharing, checks bounded failure and preservation/cleanup, then verifies
recovery after release and release during the retry window. The narrow PR workflow
runs these tests and existing signature/hash checks on Windows PowerShell 5.1
and PowerShell 7. The existing manual installer workflow also runs both suites;
its automatic triggers remain disabled.

Windows contention results and full installed-package gates are still required
before a release. This source change is not an automatic update to 0.12.2.
