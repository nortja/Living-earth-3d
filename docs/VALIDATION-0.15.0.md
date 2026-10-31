# 0.15.0 preview validation

Released 2026-10-31. Frozen source `f86591c34e8a148493af995595a7ab0944c5ab62`, tree `9086241fff934f44f0f8e4ed106ee82e5168d561`. [Release pipeline 41227218923](https://github.com/nortja/Living-earth-3d/actions/runs/41227218923) passed all four jobs.

Recent days from orbit offers the previous seven UTC dates, yesterday by default. Selection is local until Load; the displayed observation/texture changes only on successful retrieval. The selector is stable while loading, only one image stays in memory, and Offline Earth remains readable beside Load. No startup, timer or native-saver requests are added.

## Evidence

- Sixteen local suites cover 1049 checks, including 38 satellite cases and 200 malformed JPEG inputs. The final relevant satellite/native checks reran after offline-button placement/width repair. Ten maintainer provenance tests remain passing.
- Actual app-side retrieval of the oldest offered day, 2026-10-24, returned the valid 2048×1024 NASA GIBS mosaic. Actual-image native renders passed at 800×600, 1920×1080, 3840×1080 and 5120×2880. Reviewed screenshots show date, Load and offline return without scrolling.
- Build job 124613782988 passed source/security/export/icon and native render/isolation gates.
- Windows job 124615717331 passed upgrades/rollback from 0.5.2 and 0.9.0, security/status on both PowerShell runtimes, actual settings/dropdown and native preview/lifecycle. Actual preview soak lasted 605.1 seconds; final OS private bytes 209,068,032. The actual Windows 320×200 frame readiness file arrived at 3038 ms.
- Installed desktop job 124615717361 passed seven choices, unchanged displayed date/no request on selecting another day, visible/readable date/Load/offline controls, photographs/32-place weather/preview isolation and 300.0106 active seconds: 17,954 frames, mean 16.7100 ms, one frame above 50 ms. Engine-memory counters remain explicitly null. Synthetic images are labeled fixtures. The weather-fixture image still captures the selected Vancouver arrival; this known evidence-labeling issue is corrected in the later backup candidate without changing product navigation.
- Publish job 124618908057 passed. Independent maintainer verification checked complete workflow/source provenance, exact public updater URL, BUILD source, checksum/size and four installed-file hashes. Desktop/saver archives were digest-verified; installed satellite screenshot reviewed.

## Authenticated delivery

Installer `LivingEarth3D-Setup-0.15.0.exe`: 51,359,588 bytes; SHA256 `9c4f711b0e77d2d2c5bc714aec616d9d727650144eef394c36ea775ee060c6d4`.

Exact manifest signed outside git/CI and independently verified against the installed pinned public key. Source and all three discovery files are promoted atomically after the 0.14.0 production updater roundtrip passed. [Production Windows roundtrip 41229480105](https://github.com/nortja/Living-earth-3d/actions/runs/41229480105), job124620459639, passed authenticated staging while open, cancellation without replacement, installation after normal exit, exact installed-file verification, no unwanted restart and cleanup. Publisher signing remains separate; this is a publisher-unsigned preview.

Daily mosaics have real gaps and are not a simultaneous photograph/current cloud field. Software CI does not establish physical Dell GPU/DPI, mixed monitors, sleep/power or overnight behavior.
