# 0.14.0 candidate validation

Prepared 2026-10-31. Expands the optional Open-Meteo model sample to 32 fixed public places with a local place/country filter. A filtered choice retains the accepted source-point index, including after an earlier invalid row is omitted. Old dataset caches are ignored, not relabelled. Manual cooldown is ten minutes; no startup/native-saver requests or location tracking.

All sixteen local Godot suites pass 1036 checks (836 behavior/layout plus 200 malformed JPEG cases), including 83 weather-layer checks. The maintainer provenance suite retains ten passing failure-path checks. The optional actual-network test retrieved 32/32 dated model estimates and native graphics rendered that actual response at seven sizes from 800×600 through 5120×2880, including 3840×1080. Screenshots were reviewed. New city identity/coordinates and provider eligibility/terms were checked against primary provider sources; see WEATHER_COVERAGE_32.md.

The installed Windows validator now requires all 32 markers, filters Canada to Vancouver, verifies the mapped journey and restores all choices after clearing. The release-specific workflow retains all source/security/icon/native render, Windows upgrade/rollback/settings, ten-minute native saver/lifecycle and five-minute installed desktop gates. Frozen source/run, actual package hashes and results will be recorded after those gates; this is not yet a released build. The production feed is 0.13.1.

Software-rendered CI does not establish physical Dell GPU, mixed DPI/monitors, sleep/resume, power or overnight behavior. Model estimates are dated point samples, not continuous observations or a global cloud field.
