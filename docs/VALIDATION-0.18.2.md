# 0.18.2 preview validation

Released 2026-10-31. Frozen source `da9f06f4267cf896dfb576d18402946e74f7eb15`, tree `7667ba4c360842965b8691ed744d4b97371ab38f`. [Full pipeline 41232467353](https://github.com/nortja/Living-earth-3d/actions/runs/41232467353) passed all four jobs.

Weather globe compacts Load/refresh and Cancel into one row and removes its redundant heading. The loaded-place filter and picker are fully visible at small sizes. Source/status, toggle, units, 32-place dataset/hash, model/retrieval times, ten-minute cooldown, cancellation and no-startup/native-saver requests remain unchanged.

## Evidence

- The new 800×600 assertion reproduced the prior clipping (84 weather cases, one failure), then all 84 passed after repair.
- All eighteen local suites passed 1118 checks: 84 weather, 52 performance, 22 atlas, 36 backup cases and retained earlier coverage including 200 malformed JPEG cases. Seven native weather layouts through 5K, including 3840×1080, require filter/picker visibility; final screenshots reviewed.
- Build 124629329716 passed source/security/export/icon and native rendering/isolation.
- Windows 124631103658 passed upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status suites, actual settings/dropdown and native preview/lifecycle. Actual preview soak: 605.2 seconds; final OS private bytes 211,853,312. Fresh Windows 320×200 first-frame readiness arrived at 3594 ms.
- Desktop 124631103649 passed exported photos, offline atlas/paging/first-result visibility, chosen-file backup/merge callbacks, 32-point weather/filter/picker visibility, satellite and preview isolation. The reviewed weather screenshot is explicitly synthetic. Actual recording: 300.0043 active seconds, 17,988 frames, mean 16.6780 ms, one frame over 50 ms; context totals match and unavailable engine-memory counters remain null.
- The same installed package passed exact native Windows 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880 framebuffer/image/layout checks under Windows PowerShell 5.1 using llvmpipe (LLVM 23.1.2, 256 bits). Post-start resizing can extend beyond the small virtual desktop; this is not physical 5K-monitor/DPI evidence.
- Publish 124634176606 passed. Independent verification checked completed successful workflow/source, BUILD provenance, public updater URL, checksum/size and exact four-file metadata. Desktop/native archives were digest-verified and relevant images reviewed.

## Delivery

Installer `LivingEarth3D-Setup-0.18.2.exe`: 51,380,944 bytes; SHA256 `b92be7b7aedf3dd83bb263fee12f3b09bfec759f5250a0bcccf69edd0e3c010d`.

Exact metadata was signed outside git/CI, independently checked against the installed pinned public key and promoted atomically with source/all three discovery files after 0.18.1's successful production updater. The 0.18.2 production Windows roundtrip follows promotion. Publisher Authenticode remains separate; this is a publisher-unsigned preview.

## Supplementary checks and limits

Near 19:06 UTC, manual Linux source checks retrieved all eight real camera images, exercised an actual unchanged conditional response, accepted all 32 dated Open-Meteo model points and decoded the 2026-10-30 NASA 2048×1024 mosaic. This does not establish capture freshness, ongoing provider availability or Windows networking; see PROVIDER_CHECKS-2026-10-31.md.

Frozen 0.16.0 and 0.18.0 real-time native Linux saver runs each completed about one hour with zero failures. The exact 0.18.2 source is running a separate thirty-minute six-style native check; it is not yet counted complete. See SCREENSAVER_LONG_RUNS.md.

VM frame intervals vary and include cap/scheduling/renderer work. The inexpensive direct monitor-API probe does not establish a cause for earlier variation or a speedup; no hardware rating is inferred. Physical Dell GPU/DPI, mixed monitors, sleep/power, audible playback and overnight observations remain separate.
