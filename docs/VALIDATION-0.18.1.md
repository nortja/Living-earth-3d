# 0.18.1 preview validation

Released 2026-10-31. Frozen source `9515d27758b7325cd4153a6e09620fa49d19a202`, tree `0d2a518bc2d519fde7b0779ac726ddd3a600681c`. [Full pipeline 41231442929](https://github.com/nortja/Living-earth-3d/actions/runs/41231442929) passed all four jobs.

Offline search removes its redundant heading and keeps previous/next paging in one row, making the first result fully visible at small sizes. A native assertion reproduced one failure before repair, then first/middle pages passed through 5K. Recording contexts use the screen index from the existing report poll instead of a native Windows monitor enumeration per frame. Other configuration fields remain per-frame; the saved report states the approximate one-active-second screen-index latency.

## Gates

- Eighteen local source suites: 1117 checks, including 52 performance, 22 atlas, 36 backup and 200 malformed JPEG cases. Final native atlas/performance layouts passed and images were reviewed.
- Build 124626506696 passed source/security/export/icon and native rendering/isolation.
- Windows 124628418769 passed upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status suites, actual settings/dropdown and preview/lifecycle. Actual native preview soak: 605.1 seconds; final OS private bytes 211,709,952. Flushed Windows 320×200 first-frame readiness arrived at 3278 ms.
- Desktop 124628418801 passed installed photos, atlas first-result visibility/paging, chosen-file backup/merge callbacks, 32-point weather, satellite, preview isolation and exact recording context totals. Actual recording: 300.0179 active seconds, 13,423 frames, mean 22.3510 ms, one frame over 50 ms; unavailable engine-memory counters remain null.
- That same installed package also passed exact native Windows 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880 framebuffer reports/images, detailed textures and unobstructed layout under Windows PowerShell 5.1. GPU identity was llvmpipe (LLVM 23.1.2, 256 bits). Post-start resizing may extend beyond the 1024×768 virtual desktop; this is software framebuffer evidence, not physical monitor/DPI testing.
- Publish 124631575877 passed. Independent verification checked successful source/workflow/BUILD provenance, public URL, checksum/size and four installed-file hashes. Desktop/native archives were digest-verified; installed search and 5K images were reviewed.

## Timing evidence and limits

The native monitor-query probe ran five batches of 200 MonitorFromWindow + EnumDisplayMonitors calls, measuring 0.001578–0.005205 ms per call. This inexpensive API probe does not explain the earlier multi-millisecond VM frame-time variation, isolate Godot/renderer scheduling, or establish a speedup. The code now bounds unnecessary query frequency; all measured frame numbers and limits are retained. [Raw API probe](evidence/windows-monitor-query-0.18.1.json).

The initial source `fad1356` / run 41231390016 was cancelled before publication to correct a native middle-page screenshot's query text; no failed/cancelled source was signed. The earlier frozen-0.16.0 display clamp failure and successful follow-up remain documented separately in WINDOWS_DISPLAY_MATRIX.md.

## Authenticated delivery

Installer `LivingEarth3D-Setup-0.18.1.exe`: 51,383,323 bytes; SHA256 `ed017bd586efc6477ada9ffcc120cf04b5024e1a3bbf1ca15067d491c764fb70`.

Exact metadata was signed outside git/CI, independently checked against the installed pinned public key and promoted atomically with source/all three discovery files after the successful 0.18.0 production Windows updater. The 0.18.1 production roundtrip follows promotion. Publisher Authenticode remains separate; this is a publisher-unsigned preview.

Physical Dell GPU/DPI, mixed monitors, sleep/power and overnight observations remain field work. Source 0.16.0's completed one-hour Linux soak and the still-running 0.18.0/0.18.2 runs are supplementary, not substitutes for current Windows gates.
