# 0.14.0 preview validation

Released 2026-10-31. Frozen source `1fbb7b162e62e0759c641c382ac2cdbf17c6ad76`, tree `a1da2c5e6d31a0f532397ba98f5399df36476874`. [Release pipeline 41226878053](https://github.com/nortja/Living-earth-3d/actions/runs/41226878053) passed all four jobs.

The optional Open-Meteo sample expands to 32 fixed public places, with local place/country filtering and correct accepted-point navigation after omitted rows. Original coordinates/preferences/bookmarks remain intact. Old sixteen-place caches are ignored. Manual cooldown is ten minutes; there are no startup/native-saver requests or location tracking. See WEATHER_COVERAGE_32.md for primary-source city identity and provider terms.

## Evidence

- Sixteen source suites: 1036 counted checks, including 83 weather cases and 200 malformed JPEG inputs. Ten maintainer provenance/tampering tests.
- Actual app-side 32/32 dated model estimates retrieved and rendered at seven native sizes, including 800×600, 3840×1080 and 5120×2880. Screenshots reviewed.
- Build job 124612758708 passed source/security/export/icon and native render/isolation gates.
- Windows job 124614715422 passed upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status suites, actual Screen Saver Settings/dropdown and native preview/lifecycle. Real preview soak lasted 605.1 seconds; final OS private bytes 209,223,680. Flushed first-frame readiness was actual Windows/320×200 at 3390 ms.
- Installed desktop job 124614715512 passed exported 32-point creation, Canada→Vancouver filtering, correct journey and restored 33 picker entries, photographs/satellite/preview isolation and a 300.0167-second recording: 17,996 frames, mean 16.6713 ms, one frame above 50 ms. Unavailable memory counters remain null. The weather-fixture screenshot captures the Vancouver destination opened by this navigation check; actual weather-panel layout is separately covered by source/native screenshots. A subsequent harness improvement will reopen the panel before that screenshot.
- Publish job 124617999783 passed. Independent maintainer verification checked complete successful CI/source provenance, public updater URL, BUILD source, size/checksum and exact four-file metadata. Windows desktop/native evidence archives were digest-verified and reviewed.

## Authenticated delivery

Installer `LivingEarth3D-Setup-0.14.0.exe`: 51,357,871 bytes; SHA256 `ff523640a184d938f5dd2cc9f92cae0800f1d82b42dbccc9d4e8fb04b888b4c2`.

Exact metadata signed with the existing key outside git/CI and independently verified against the installed pinned public key. Source, application.json, application.sig and preview.json are promoted atomically. Publisher signing remains separate: this is a Windows publisher-unsigned preview. Production Windows updater roundtrip follows promotion.

Software-rendered CI is not physical Dell GPU/DPI, mixed-monitor, sleep/resume, power or overnight validation. Model values are dated point estimates, not continuous observations or a global cloud field.
