# 0.22.0 validation — regional infrared

Published 0.22.0 after every required build/Windows/public-delivery gate passed. User explicitly approved continued public builds. Exact signed source/discovery promotion follows independent signature verification. The separate production updater roundtrip 41340742001 passed; the preceding 0.21.0 roundtrip 41336561468 passed.

The new regional infrared service, numerical color-map derivative, source identity/failure/cancellation tests and Live Earth navigation are described in [CLOUD_IMAGERY_PILOT.md](CLOUD_IMAGERY_PILOT.md). Both actual NOAA/NASA regional retrievals passed from the application on 2026-11-01, with maximum two tile requests and complete 2560×1280 scenes. These are timestamped regional false-color observations, not forecasts or worldwide clouds.

Native layout checks cover eight viewport sizes through 5120×2880, including 2496×1664 and 3840×1080, and verify all main controls and Live Earth actions. All 1,735 source checks passed, plus the 14-check native-host isolation run, 39 C++ command checks, actual generated Godot command checks and ten Python provenance tests. A fresh exported PCK smoke run resolved the lunar map, calendar, journey, infrared service, numeric color map and legend with zero failures. All source imports and whitespace checks passed. Windows gates passed upgrades from 0.5.2 and 0.21.0, failure rollback, timer/settings, native preview/605-second lifecycle, installed infrared controls and the seven-size framebuffer matrix (including laptop 2496×1664 and Dell 3840×1080). Independent public installer/provenance/helper checks and exact release signature verification passed before atomic source/feed promotion. The final production updater test 41340742001 also passed.

Virtual graphics evidence is not physical Dell GPU/DPI, idle/sleep, mixed-monitor, audio listening or Windows publisher-signing validation.

Before the Windows stage started, source review caught the old upgrade-test parameter allowlist excluding 0.21.0. The test now accepts that version with its independently verified pinned installer SHA-256; no checksum bypass was introduced. The previous candidate run was superseded by the corrected harness and rerun in full.

## Frozen source and completed release gates

- Frozen source `ac0d298d070d62f3782340c5c001f0c0ca101b67`, tree `7430b3ca1fa9ee7cad9946a0112c50a3ed0888c5`.
- Full corrected pipeline: https://github.com/nortja/Living-earth-3d/actions/runs/41338329092 . All build, Windows, desktop and publish jobs succeeded; the earlier run 41337857638 was cancelled after the test-harness correction, before publication.
- All fifteen local native rendering suites passed, including eight weather layouts and all primary Live Earth actions. A separate real West/East render check passed; the human review caught SVG text omission and verified the final native-text temperature labels.
- Actual provider identity, nominal scan, retrieval time, dimensions, concurrency and image hashes are retained in [regional-retrievals.json](evidence/0.22.0/regional-retrievals.json).

The corrected run passed all stages. The actual selected-Earth dialog, installed 4K Moon, ten-minute secure-resume controls, infrared fixture and Dell Live Earth screenshots were reviewed. Native-text legend labels were separately checked against an actual provider scene. The fixture is explicitly synthetic and separate from the actual observed retrieval evidence.

## Windows evidence and verified delivery

- Build job 124943030726; installed desktop job 124945807628; Windows upgrade/settings/lifecycle job 124945807574. All successful under run 41338329092.
- [Seven exact framebuffers and five-minute active recording](evidence/0.22.0/windows-desktop.json): all passed; 300.005 active seconds, 12,963 frames. The software-rendered virtual desktop was 1024×768, with explicit framebuffer resizing.
- [Native saver evidence](evidence/0.22.0/windows-screensaver.json): actual embedded frame, twenty samples through 605.2 seconds, 320×200/580×330 resizing, private bytes 243,666,944–249,962,496; final 249,593,856. Parent/input/session cleanup, full saver input, and simulated display/suspend/lock cleanup passed. No universal memory-leak claim.
- Native timer readback verified 600 seconds/secure=1 and 300 seconds/secure=0; installed UI defaults to ten minutes/secure resume without applying OS changes until Apply. The app does not inhibit Windows idle screensaving.
- Independent public workflow https://github.com/nortja/Living-earth-3d/actions/runs/41340562973 passed; a separate local verifier downloaded the exact installer URL and checked the full candidate workflow/source, BUILD source, payload schema, helper hashes, size and SHA-256.
- Installer: `LivingEarth3D-Setup-0.22.0.exe`, 59,453,438 bytes, SHA-256 `741a7db096aadc1bb4db8ead36287c00af3c0ec9f9c1583b6c8168efa8a2038b`.
- Detached manifest signature independently verified with the public key pinned in the updater, using the exact UTF-8 bytes. All three discovery files are promoted together with unchanged validated application source. Windows Authenticode publisher signing remains separate/unavailable.
- Final production Windows authenticated staging/cancellation/normal-exit roundtrip: [41340742001](https://github.com/nortja/Living-earth-3d/actions/runs/41340742001) passed on its first attempt from source `705486f7bd24216503eb23bf3e6f5e18dc5ea489`. The helper verified the live signature/download, staged while the old app stayed open, cancelled without replacing files, installed after normal exit, verified all four installed-file hashes and did not reopen the intentionally closed app. Actual public manifest/signature/legacy discovery bytes also exactly matched the signed local bytes after promotion.
