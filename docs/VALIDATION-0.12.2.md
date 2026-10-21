# 0.12.2 release validation

Combined preview, 2026-10-20. This release combines camera, performance, photograph, history and opt-in weather work validated through the 0.10.0–0.12.1 candidates. Those intermediate candidates were not promoted to the authenticated automatic-update feed.

Frozen binary source: commit `85476e12bee59e3a16a156189b79b3a86d9c2982`, tree `d7f964e8f6e68dcff040ec639e3e50e615431d04`; [release run 39534786180](https://github.com/nortja/Living-earth-3d/actions/runs/39534786180). Only release documentation and signed discovery metadata change after this binary source.

## Local/source and real-data evidence

735 local checks pass across fourteen suites. Coverage includes camera source/cadence/backoff/filter/wall limits, arrivals, photographs and trusted saved-place resolution, history filtering, local report timing/privacy and weather response/schema/location/freshness/cache/cancellation/picking/isolation. Three additional refresh checks reject NaN/infinite/nonpositive values and preserve fractional refresh. A native virtual-display reproduction verifies an explicit unavailable label and valid null JSON without the prior stringify warning.

Actual JPEGs from all four new camera endpoints were downloaded, decoded at documented dimensions and rendered in the in-app viewer. All twelve licensed offline photographs were visually inspected and checked against their committed hashes/credits. Native photo/arrival/report/weather layouts were checked at six sizes from 800×600 through 5K. An actual sixteen-location Open-Meteo response was decoded and rendered at all six sizes, keeping model estimate times separate from retrieval time. Synthetic fixtures are labelled in screenshots.

A native Linux rehearsal of the compiled desktop validator opened every photograph, created sixteen model points, checked screensaver cancellation/isolation and completed 300.008 active seconds (10,539 frames) of recording/export with zero failures. It exposed an unknown virtual-display refresh represented as NaN; 0.12.2 normalizes it to null and displays unavailable. This rehearsal is source/native evidence, not a Windows installed-package result.

## Gates and endurance scope

Fresh export, launcher/installer/icon checks, updater security, native UI and native saver preview/fullscreen budget/isolation checks are required. Windows gates install the actual exported package, upgrade/rollback from 0.5.2 and deployed 0.9.0, run a ten-minute embedded preview/render/resize/private-memory soak and lifecycle notifications, and independently load installed photographs/model points and record five active minutes of desktop performance. The compiled --validate-packaged-desktop module uses isolated preferences and durable progress evidence, never ordinary app/saver startup. The external-script harness failures in earlier candidates blocked publication and are documented in VALIDATION-0.12.1.md.

Longer frozen foundations passed separately: [0.10.0 Windows sixty-minute soak](https://github.com/nortja/Living-earth-3d/actions/runs/39525423238), [0.11.0 Windows sixty-minute soak](https://github.com/nortja/Living-earth-3d/actions/runs/39527917531) and [0.10.0 Linux six-style 3,609.493-second soak](https://github.com/nortja/Living-earth-3d/actions/runs/39526379944). Linux baseline/peak engine-tracked memory was 48,564,730/48,699,088 bytes, nodes 430–431 and preview cap 15 FPS, zero failures. The interrupted local soak is not counted as a pass. The 0.12.0 weather foundation also passed its separate thirty-minute Windows preview/lifecycle gate in [39530945967](https://github.com/nortja/Living-earth-3d/actions/runs/39530945967); its desktop harness failure prevented publication. These are not one-hour tests of a different final binary.

Physical Dell GPU/DPI, multiple monitors, real sleep/lock/wake and fan/power behavior remain field observations. CI uses disposable software-rendered VMs; simulated notifications do not establish physical hardware results. See FIELD_CHECKS.md.

## Update trust

The four installed payload filenames, protocol 1 and pinned trust key are preserved. Private signing material stays outside git/CI and temporary working copies are removed after signing. Published installer bytes must match the CI checksum before exact manifest bytes are signed and all three discovery files are promoted atomically. Windows Authenticode publisher signing remains separate and absent. A production live-helper staging/cancellation/normal-exit install roundtrip follows promotion. The old failing general workflow remains disabled.

Final build job 119008809638 passed: all fourteen suites (735 checks), updater security/build checks, 25 launcher-argument checks, generated native commands, fresh application/native saver export, seven-size PE icon/resource checks, NSIS packaging and native graphics suites through 5K. Separate native preview/fullscreen saver budget/isolation checks passed.

Final installed Windows desktop job 119010422314 passed: twelve actual PCK photographs decoded, sixteen synthetic model points and preview isolation verified, local JSON exported after 300.014921 active seconds / 17,995 frames, with zero failures. Release memory counters were correctly null. The software VM mean frame interval was 16.672 ms; this is not a Dell hardware performance promise. Screenshot/report evidence is attached to the release run as Windows-packaged-desktop-0.12.2.

Final Windows job 119010422265 passed upgrades/rollback against 0.5.2 and deployed 0.9.0, real embedded rendering, the ten-minute OS private-memory/resize/parenting/input-isolation soak, active-saver install deferral, independent previews, parent/controller-death cleanup, one-monitor fullscreen and keyboard exit, plus simulated display/suspend/session-lock cleanup. All four release jobs, including installer publication, completed successfully.

Published installer: `LivingEarth3D-Setup-0.12.2.exe`, 51,339,954 bytes, SHA-256 `0471ce0b33b7463e99eab58be821203a2b8a46ec3d164234f53a2f03e4a8356e`. The public refs/heads download was verified against the published checksum and BUILD source commit before signing. The signed manifest was independently verified against the installed pinned public key and all four payload hashes; the temporary private-key copy was removed. Source, application.json, application.sig and preview.json are promoted together. Production live-helper roundtrip evidence follows.

## Production live-update roundtrip

The no-query raw production manifest, detached signature and backward-compatible preview metadata matched the local verified bytes after atomic promotion `a1da99c4d1284e47ffb46ad6f09c2be6f129444e`. Independent pinned-key verification passed again.

[Live run 39536745077, attempt 2](https://github.com/nortja/Living-earth-3d/actions/runs/39536745077/attempts/2), Windows job 119015531135, passed: production signed download stages while the old app remains open; cancellation leaves it unchanged; resume installs after normal exit; all four installed-file hashes match; the intentionally closed app does not reopen; fixture cleanup succeeds.

Attempt 1 reported a staging filesystem deferral, “Cannot create a file when that file already exists,” and failed the gate. It is not counted as a pass. A fresh Windows retry completed with the unchanged production helper. The exact cause remains unconfirmed; investigate transient file contention and add deterministic coverage before changing status-file replacement behavior. This is a pending resilience item, not a claim that every filesystem condition is repaired.
