# 0.22.0 validation — regional infrared

Candidate only. Production remains 0.21.0 with successful Windows production updater run 41336561468. User explicitly approved continued public builds. No feed changes until every required gate passes.

The new regional infrared service, numerical color-map derivative, source identity/failure/cancellation tests and Live Earth navigation are described in [CLOUD_IMAGERY_PILOT.md](CLOUD_IMAGERY_PILOT.md). Both actual NOAA/NASA regional retrievals passed from the application on 2026-11-01, with maximum two tile requests and complete 2560×1280 scenes. These are timestamped regional false-color observations, not forecasts or worldwide clouds.

Native layout checks cover eight viewport sizes through 5120×2880, including 2496×1664 and 3840×1080, and verify all main controls and Live Earth actions. All 1,735 source checks passed, plus the 14-check native-host isolation run, 39 C++ command checks, actual generated Godot command checks and ten Python provenance tests. A fresh exported PCK smoke run resolved the lunar map, calendar, journey, infrared service, numeric color map and legend with zero failures. All source imports and whitespace checks passed. Windows gates must prove upgrades from 0.5.2 and 0.21.0, failure rollback, timer/settings, native preview/605-second lifecycle, installed infrared controls and the seven-size framebuffer matrix (including laptop 2496×1664 and Dell 3840×1080). Independent public installer/provenance/helper checks, exact release signature verification, atomic source/feed promotion and a fresh production updater test follow in that order.

Virtual graphics evidence is not physical Dell GPU/DPI, idle/sleep, mixed-monitor, audio listening or Windows publisher-signing validation.

Before the Windows stage started, source review caught the old upgrade-test parameter allowlist excluding 0.21.0. The test now accepts that version with its independently verified pinned installer SHA-256; no checksum bypass was introduced. The previous candidate run was superseded by the corrected harness and rerun in full.
