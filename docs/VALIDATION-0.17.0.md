# 0.17.0 preview validation

Released 2026-10-31. Frozen source `b3cc279f7e1e34b9f402b5073d29564a37e15c17`, tree `564f8da235fb77e65b00cd1b78cece621886e145`. [Full pipeline 41228250585](https://github.com/nortja/Living-earth-3d/actions/runs/41228250585) passed all four jobs.

The selected offline atlas merges Natural Earth's 243 reference cities with the original places, preserving existing names/coordinates. Local country/ASCII/diacritic aliases, exact supplied country codes, ranked eight-result pages and visible paging controls remain separate from coordinate entry and explicit online search. More than 250 combined reference places are available; this is not all settlements or street-level imagery. See OFFLINE_ATLAS.md for pinned primary-source bytes, public-domain terms and reproducible conversion.

## Evidence

- Seventeen local suites passed 1079 checks, including 21 atlas semantic cases and 200 malformed JPEG cases. Source conversion reproduced the bundled dataset exactly; pinned upstream commit/hash matched an independent download.
- Native graphics at seven sizes from 800×600 through 5K, including 3840×1080, verified search width/paging and selected city arrival. Screenshots reviewed; result lists may require vertical scrolling at small sizes.
- Build 124616835686 passed source/security/export/icon/native gates.
- Windows 124618904675 passed upgrades/rollback from 0.5.2 and 0.9.0, both PowerShell security/status suites, actual settings/dropdown, embedded preview and lifecycle. Actual preview soak lasted 605.1 seconds; final OS private bytes 209,657,856. Fresh Windows 320×200 first-frame readiness arrived at 3457 ms.
- Installed desktop 124618904681 searched exported Vancouver, verified its correct source/context, paged USA locally without a request, and retained photographs/32-point weather/satellite/preview behavior. Actual recording: 300.0045 active seconds, 13,130 frames, mean 22.8488 ms, one frame above 50 ms; exported context accounts for all frames/time. Release engine-memory counters remain null. The older weather screenshot still captures the filter-opened arrival; a subsequent candidate reopens that panel before capture.
- Publish 124622102693 passed. Independent public verifier checked successful workflow/source, BUILD provenance, exact updater URL, checksum/size and four installed-file hashes. Desktop/saver archives were digest-verified; installed offline search screenshot reviewed.

## Delivery

Installer `LivingEarth3D-Setup-0.17.0.exe`: 51,376,198 bytes; SHA256 `8e8f73a2e82d4ddc1fc043cfc21704900c9ef71d033eb78d9fd21d493e0bc4f5`.

Exact manifest signed outside git/CI and independently checked against the installed pinned public key; source and all three discovery files promoted atomically after 0.16.0's production update passed. [Production Windows roundtrip41230795180](https://github.com/nortja/Living-earth-3d/actions/runs/41230795180), job124624410881, passed authenticated staging while open, cancellation without replacement, normal-exit installation, exact installed-file verification, no unwanted restart and cleanup. Publisher Authenticode remains separate; this is a publisher-unsigned preview.

Maintainer-only Windows display-runner improvements/documentation are merged after their independent frozen-0.16.0 matrix passed; they are excluded from the application/installer payload. See WINDOWS_DISPLAY_MATRIX.md. Physical Dell GPU/DPI, mixed monitors, sleep/power and overnight checks remain separate; software CI does not establish them.
