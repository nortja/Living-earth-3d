# 0.18.0 preview validation

Released 2026-10-31. Frozen source `d0f881d0273a591c4c174b3f9ceb5c0cb749850f`, tree `364295a8b137a0660a3858cac67392932ac68954`. [Full pipeline41229309398](https://github.com/nortja/Living-earth-3d/actions/runs/41229309398) passed all four jobs.

Saved places gain explicit chosen-file JSON export and merge. Existing entries win; duplicates/over-capacity entries are reported, invalid files change nothing and the 50-place bound remains. File/text/type/finite-coordinate/source limits, flushed temporary exports, chooser cleanup and no automatic import/upload/provider request are covered. See SAVED_PLACES_BACKUP.md.

## Evidence

- Eighteen local suites passed1115 checks, including36 backup cases and200 malformed JPEG cases. Native backup controls fit without scrolling at800×600,1920×1080,3840×1080 and5120×2880; screenshots reviewed.
- Build124619948813 passed source/security/export/icon and native graphics/isolation gates.
- Windows124622308451 passed upgrades/rollback from0.5.2 and0.9.0, both PowerShell security/status suites, actual settings/dropdown and native preview/lifecycle. Actual preview soak lasted605 seconds; final OS private bytes214,425,600. Fresh Windows320×200 first-frame readiness arrived at2225ms.
- Installed desktop124622308483 exercised the exported file-selected callbacks, wrote an actual chosen backup, retained a place saved since export, merged without duplicate replacement and removed the fixture file. Chooser configuration/callbacks are covered; physical OS chooser interaction is a field observation.
- Exported photographs/atlas paging,32-point weather, satellite and preview isolation passed. The weather fixture now reopens Weather globe after checking navigation; reviewed screenshot is explicitly synthetic. Actual recording:300.0161 active seconds,16,058 frames, mean18.6833ms, one frame above50ms; context totals match. Release engine-memory counters remain null.
- Publish124625265515 passed. Independent verifier checked completed successful workflow/source, BUILD provenance, exact public updater URL, size/checksum and four installed-file hashes. Desktop/saver archives were digest-verified and relevant images reviewed.

## Delivery and follow-up

Installer `LivingEarth3D-Setup-0.18.0.exe`:51,381,610 bytes; SHA256 `44e2e4f9f895f478647efab7decf1db516c1665c13fcfee436fdddf5e9ed925b`.

Exact metadata was signed outside git/CI and independently checked against the pinned public key, then promoted atomically with source/all three discovery files after the successful0.17.0 production update. The0.18.0 production Windows roundtrip follows promotion. This remains a Windows publisher-unsigned preview.

A separate0.18.1 candidate improves first-result visibility and removes per-frame Windows monitor enumeration from optional recordings, explicitly describing one-second screen-index polling. It adds a current-package exact Windows framebuffer matrix to the installed desktop gate. Its earlier sourcefad1356 was cancelled to correct a test screenshot's query text, not counted as a release pass; final frozen source9515d27758b7325cd4153a6e09620fa49d19a202 is running fresh gates.

A one-hour native Linux soak against this exact0.18.0 source is still running; no completion is claimed yet. Physical Dell GPU/DPI, mixed monitors, sleep/power and overnight observations remain separate.
