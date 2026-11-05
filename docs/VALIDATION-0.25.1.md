# 0.25.1 preview — interruption and upgrade reliability

Reviewed November 5, 2026. Frozen source `e76bac4497faab381b0819c155e4080507008a82`, tree `f03106c2968c723a55e1abf957396751cfabe779`. All four build/desktop/Windows/publication jobs passed in [41870662412](https://github.com/nortja/Living-earth-3d/actions/runs/41870662412). [Evidence](evidence/0.25.1/release-gates.json).

Manual Scene Library Next obeys the modal/minimize/screensaver interruption guard even while timed playback is paused. Cancellation retains the composition, kills its delayed callback and restores brightness without rewriting defaults. This release also tests upgrades from the exact published 0.25.0 installer and verifies user-data preservation immediately after handled rollback as well as successful installation.

## Completed checks

- 2,521 source assertions across 26 suites, seventeen native rendering suites, 39 screensaver arguments, generated launch-command checks, ten Python provenance tests and existing PowerShell status/security/build gates.
- Windows upgrades from 0.5.2 and 0.25.0, running-app deferral, real handled-failure rollback, metadata restoration, user-data preservation, icon/uninstall and actual screensaver settings/timer checks.
- Installed desktop/pointer/clean PNG/scene controls and a 300.006-active-second recording; seven exact Windows framebuffers including laptop 2496×1664 and Dell-shaped 3840×1080, plus 1080p, 3440×1440, 4K and two 5K sizes.
- Native Windows preview parenting/resizing, a 605-second soak and simulated display/suspend/session lifecycle checks. Hosted software rendering does not establish physical Dell GPU/DPI/mixed-monitor/real sleep/overnight behavior.

## Public bytes and signature

The unmodified public verifier checked the exact installer URL, successful workflow/job inventory, frozen BUILD provenance, checksum, size, payload schema and unchanged local helper hashes. Installer size: 73,322,045 bytes. SHA-256: `10aeac49cd31a23453a4c8d96aee04221e20313e5d3fb351e7f5bb572bedff60`.

Independent Windows public/signature verification [42062270994](https://github.com/nortja/Living-earth-3d/actions/runs/42062270994) passed. Exact manifest bytes were signed outside git/CI, independently verified using only the pinned public key, and checked by Windows using the installed `Read-EarthManifest` implementation. The temporary private key was removed. A validation-only Windows checkout initially changed LF signed bytes and correctly failed; disabling checkout conversion resolved the signature check without changing signed bytes, trust or verification rules. An independent public check encountered anonymous GitHub API rate limiting; its isolated wrapper authenticates only bounded API requests, leaving public installer downloads unauthenticated.

Discovery JSON, detached signature and legacy preview metadata are promoted atomically with the validated application source only after these gates. The old general failing workflow remains disabled. Windows publisher Authenticode is separate and still unavailable.

## Production updater

[Production Windows run 42062505671](https://github.com/nortja/Living-earth-3d/actions/runs/42062505671) passed on November 5. It verified the live signature and installer, staged while the app was open, cancelled without replacement, installed on normal exit, confirmed all four installed hashes and did not reopen the app. The three public discovery files matched the exact verified bytes. [Receipt](evidence/0.25.1/production-update.json).

Reviewed the installed Scene Library and 3840×1080 Live Earth captures: primary controls visible and Earth centered. Camera/data source scope and freshness limitations are unchanged.
