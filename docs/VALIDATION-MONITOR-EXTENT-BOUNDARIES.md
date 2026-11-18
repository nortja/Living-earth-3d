# Monitor extent boundary regression

This follow-up strengthens the arithmetic contract used by initial native screensaver host creation, display-topology rebuilds, and DPI-only monitor recovery.

## Behavior under test

- A width or height exactly equal to `INT_MAX` is accepted.
- A width or height of `INT_MAX + 1` is rejected before conversion to Win32 `int`.
- Invalid results leave both output dimensions at zero; callers never observe a partially converted rectangle.
- The cases use negative desktop origins and are valid on both LP64 test hosts and Windows LLP64.

## Local validation

On the development LP64 host, the complete screensaver argument test was compiled with:

```sh
g++ -std=c++17 -Wall -Wextra -Werror -pedantic
```

Result: 63 assertions, zero failures.

The same source was rebuilt and run with UndefinedBehaviorSanitizer and signed-integer-overflow instrumentation:

```sh
g++ -std=c++17 -Wall -Wextra -Werror -pedantic \
  -fsanitize=undefined,signed-integer-overflow -fno-sanitize-recover=all
```

Result: 63 assertions, zero failures, no sanitizer report.

## Existing native/Windows baseline

The immediately preceding monitor-hardening change passed the dedicated no-publication pipeline in [run 44373688324](https://github.com/nortja/Living-earth-3d/actions/runs/44373688324). It built the fresh Godot application and native screensaver, ran the full source/native suite (including 59 screensaver argument assertions), installed and exercised the Windows package, verified update/rollback and user-data preservation, ran the native preview and a ten-minute software-rendered saver soak, and exercised synthetic DPI, display-change, suspend, session-lock, and session-end messages.

That run validates the shared monitor-extent implementation and its Windows host integration; it predates the four additional exact-boundary assertions in this follow-up. The four assertions were subsequently merged in [PR #17](https://github.com/nortja/Living-earth-3d/pull/17), commit [200eff4](https://github.com/nortja/Living-earth-3d/commit/200eff4a6be4ae809f370f62fec3203ee3338b22). They passed locally on LP64 with the strict C++17 build and UBSan. A second Windows workflow was not run specifically for these test-only additions; the runtime helper remains covered by run 44373688324.

## Scope and limitations

The follow-up does not change runtime behavior, installer contents, update metadata, trust keys, signing material, user preferences, or saved scenes. The dedicated Linux/native and installed Windows validation for this exact test extension is pending. Software-rendered CI does not establish physical Dell U4919DW GPU/DPI, mixed-monitor movement, hot-plug, sleep/wake, or overnight behavior.
