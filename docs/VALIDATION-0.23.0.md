# 0.23.0 validation — clean view and Space Studio

Published 0.23.0 after all new build, Windows and independent-delivery gates passed. User authorized continued public builds and authenticated updates. Separate production updater roundtrip is pending. [Feature scope and image rights](SPACE_STUDIO.md).

Local source/native pixel/layout/PNG and exported-resource checks passed. Fresh Windows gates passed upgrades from 0.5.2 and 0.22.0 with pinned hashes, rollback, signatures, timer/settings, ten-minute native saver lifecycle, installed desktop, seven exact framebuffers and real native cursor exit/return plus PNG export. Independent public delivery and pinned-key signature verification passed before atomic source/discovery promotion. The final production updater roundtrip follows.

The Milky Way is an offline historical photographic composite with visible ESO/S. Brunier credit, not a current local sky or an exterior photo. Native framebuffer and virtual OS-cursor tests do not establish physical Dell GPU/DPI, mixed-monitor, lock/sleep or overnight behavior.

## Frozen candidate and completed local/build checks

Frozen application source `dfb5e70bb7deb06e0b3a48fd56bad19badb7f730`, tree `93377762c22ee93d911694094d36e122188619c2`. Full release pipeline https://github.com/nortja/Living-earth-3d/actions/runs/41347708600 . The build stage passed with 1,773 source checks across 24 suites, sixteen native rendering suites, native preview/fullscreen budget/isolation checks, packed-resource smoke, PowerShell/security/build parsing, C++ command tests and ten Python provenance tests. A separate local native-host run passed sixteen checks with 2K galaxy and no hover controller.

The pixel test checks actual Moon-on/off differences over the photographic sky, not just a visibility flag. A clean postcard is saved, decoded and checked for exact native dimensions; eight layouts verify all primary controls and Live Earth entries. The separate installed cursor validator compiles and rejects non-Windows/headless execution, while other visual harnesses explicitly pin controls visible for inspection.

All four release jobs completed successfully on the first attempt. Installer and exact signed discovery files are promoted together with unchanged validated application source.

## Completed Windows and delivery evidence

- Build job 124970991186, installed desktop job 124973261253, Windows upgrade/settings/lifecycle job 124973261369, publish job 124976714135: all succeeded in release run 41347708600.
- [Native cursor and PNG evidence](evidence/0.23.0/native-cursor.json): actual SetCursorPos calls, inside menus visible, outside menus hidden while Earth/Moon/sky remain, return restores page/typed values; installed Moon-off respected by Deep Space. A clean PNG was saved/decoded at the actual 870×612 test viewport. Outside/returned/export captures visually reviewed.
- [Seven exact Windows framebuffer and recording results](evidence/0.23.0/windows-desktop.json): 1920×1080, 2496×1664, 3440×1440, 3840×1080, 3840×2160, 5120×1440, 5120×2880 all passed. Recording completed 300.009 active seconds. Explicit resizing extends beyond a 1024×768 virtual desktop; these are framebuffers, not physical monitors.
- [Native saver evidence](evidence/0.23.0/windows-screensaver.json): twenty samples through 605.2 seconds at 320×200/580×330, private bytes 244,846,592–250,318,848, final 250,073,088. Parent/resize/input/process cleanup, fullscreen keyboard exit and simulated display/suspend/session-lock cleanup passed. No universal leak-free or hardware claim.
- Timer readback and installer preservation/rollback passed from both baselines. Current app does not inhibit idle screensaving; hover cannot reveal native saver UI.
- Independent public workflow https://github.com/nortja/Living-earth-3d/actions/runs/41349696038 passed. A separate local verifier downloaded the exact public installer URL and checked full source/workflow/job provenance, BUILD source, helper hashes, payload schema, size and SHA-256.
- Installer `LivingEarth3D-Setup-0.23.0.exe`: 73,303,552 bytes; SHA-256 `131d248c48440c5e9a4ba0a9b1c4f0ceeb2b028e3c9813c29653a09fcdf03217`.
- Exact UTF-8 manifest signature independently verified with the updater's pinned public key before atomic source/all-three-discovery promotion. Authenticode publisher signing remains separate/unavailable.
- Production Windows authenticated staging/cancellation/normal-exit installation: pending after promotion.
