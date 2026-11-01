# 0.21.0 release validation

Released 2026-11-01. User requested continued large builds plus an HD Moon/lunar calendar and working timed Windows screensaving. Includes unreleased 0.20.0's Journey studio and idle-timer repair; supersedes that draft as the intended rollout.

- Journey studio source suite: 55 checks; native primary controls and geometry at seven render sizes through 5K passed.
- Lunar/calendar suite: 442 checks; native seven-size layouts and five phase/date screenshots passed initially. Screenshot review caught a clipped View date button; explicit width/readability guard added, then the complete native/source suites rerun.
- Native helper argument contract: 39 checks; release-download/provenance negative tests: ten passed.
- Current full source/native run results will be appended after completion.

Automatic approval review rejected both source pushes to `https://github.com/nortja/Living-earth-3d` as unverified publication, including the retry after connected GitHub confirmed repository identity, push access and the matching prior build/release note. No GitHub write workaround, CI publication or signed-feed promotion was attempted after the second rejection. The user explicitly approved that exact public destination and rollout in the next turn on 2026-11-01; the prior block is resolved. Production remains 0.19.0. Windows release gates have not run on these changes. Never treat Linux source/native results as Windows or physical Dell validation.

## Completed local evidence

- Twenty-two Godot behavior/layout suites: **1,689 checks, zero failures** (includes 56 Journey studio, 447 lunar/calendar and 18 screensaver setup checks). Revised calendar boundary includes the first 2031 phase event solely to bracket the final supported 2030 date. Explicit sub-meter/date-line duplicate rejection prevents empty tour mesh surfaces.
- All fourteen native render suites passed: lunar/tour/sunlight/backup/atlas/satellite/weather/photo/performance/arrival/exploration/wall/standard Earth/intro. New lunar and tour panels passed seven exact sizes from 800×600 through 5120×2880; date button readabilty is guarded. Five extra waxing/waning/new/full/future-date Moon images reviewed. The timer UI builder separately passed native visibility checks at four sizes without applying any Windows settings.
- Thirty-nine native launcher argument cases and ten release-provenance tests passed; both candidate workflow YAML files parse and retain all four release jobs.
- Windows-target Godot resource-pack export succeeded locally. A separate engine invocation loaded the exported PCK and resolved all calendar years/schemes, NASA raw geometry, actual 4K texture/shader, final supported future date and offline tour atlas with zero failures. This proves packaged resource inclusion; it is not a Windows EXE/NSIS, upgrade/rollback, secure-resume or hardware idle test.
- Actual Windows timer active/timeout/secure readback, installed lunar/tour control assertions and the existing complete Windows release gates are added to the proposed 0.21.0 pipeline. They await the newly authorized fresh CI run. The private update key was not retrieved.

No new installer or authenticated update is published. Current production remains 0.19.0. The saved Moon preview shows the locally rendered candidate, not an installed Windows release.

Astronomical event selection uses its published UTC instant, while a manually chosen civil date uses noon. Two checks distinguish event-time preview and the expected quarter-phase label. Timer UI native layout and preview/full native saver resource isolation both passed locally (four sizes per saver mode).

## Completed release gates — 2026-11-01

Frozen remote source `a0e8d9bca4fcc6f33d25d75dd6a2a0f80d78d76d`, tree `8261d9f783501b8ce00da6040c3b2fe2f7a79bc4`, is byte-identical to the reviewed local candidate tree including the documented explicit publication approval. Full run https://github.com/nortja/Living-earth-3d/actions/runs/41333845054 passed build 124929379062, Windows 124931929180, installed desktop 124931929201 and publication.

The Windows settings gate actually read back 600-second timeout, active screensaving and secure resume, then 300-second timeout with optional direct-desktop resume. Installed lunar 4K texture/geometry, dated/future estimated distinction, Israel/Diaspora calendar behavior, tour resources/cleanup, visible compact timer and date controls passed. Reviewed actual installed Windows Moon and timer screenshots. Existing upgrades/rollback, signed updater security/status checks, five-minute recording, exact five-size framebuffer matrix through 5K, real native preview/lifecycle and ten-minute soak all passed. These are software-rendered disposable Windows results, not a physical idle/sign-in, Dell DPI or sleep/wake observation.

Independent public check https://github.com/nortja/Living-earth-3d/actions/runs/41335986912 passed. A separate local verifier also downloaded the exact updater URL, checked completed gate/source/workflow/BUILD provenance, installed-file schema and unchanged helper hashes. Installer size **59,430,979 bytes**, SHA256 `513630a9c8923cfaa30e5f82320be2324bc93575088e77e9759acf6450f1fc44`. Exact update metadata was signed outside git/CI and independently verified using the unchanged installed public key. The private key never entered the checkout, CI, public artifacts or installer.

All three discovery files and the tested source are being promoted atomically. Production staging/cancellation/normal-exit install is pending and must pass before any next feed promotion.

## Production updater completed

https://github.com/nortja/Living-earth-3d/actions/runs/41336561468 passed on its first attempt: authenticated public staging while the old application remained open, cancellation without replacing it, normal-exit installation, all four installed-file hashes, no unwanted restart and cleanup. All three public discovery files matched the independently signed bytes. The tested runtime source is unchanged.
