# Native Windows screensaver end-session cleanup

Updated 2026-11-15.

## Behavior

The native screensaver host explicitly handles the Windows session-end handshake:

- `WM_QUERYENDSESSION` returns success so the saver does not veto logoff or shutdown. It does not stop yet because Windows or another application may cancel the request.
- `WM_ENDSESSION` with a true `wParam` means the session is actually ending and enters the existing stop path.
- `WM_ENDSESSION` with a false `wParam` means the end-session request was canceled; the saver and renderer remain active.
- Committed shutdown uses the existing bounded graceful child close and job-object cleanup. Existing display-change, suspend, lock/logoff, disconnect and user-input handling is unchanged.

This is deliberately separate from the power-suspend path: suspend already stops the saver, while the end-session handshake must not stop on a query that can be canceled.

## Validation

The cross-platform C++ argument/policy test checks both committed and canceled decisions. The installed Windows lifecycle harness sends the native messages synchronously to a real saver host and verifies:

1. The query is accepted and does not stop the process.
2. A canceled end-session leaves the saver and renderer running.
3. A committed end-session exits the native host and owned renderer.

The dedicated no-publication workflow also rebuilds the application, native `.scr` launcher and test installer, runs source/native suites, exercises Windows installation/update rollback, and performs the existing ten-minute software-rendered preview soak.

The message tests simulate the Windows protocol; they are not an actual interactive user logoff or machine shutdown. Physical Dell GPU/DPI, mixed-monitor, sleep/resume and overnight checks remain field work.

No user preference, saved scene, updater trust key, update manifest, installer release or production feed is changed.
