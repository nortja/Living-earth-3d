# 0.5.4 validation

Local checks: Explorer 56, interface/data 43, ambient 6, interface sizes 187, automatic-update controls 6, camera viewer 22, update signature/security 16. Unit/layout tests passed. Separate real HTTPS requests fetched and decoded the three NPS camera images at 1920×1080. Retrieval success does not prove camera capture freshness or future availability.

The image viewer tests cover opt-in startup, allowlisted sources, visible selection outcome, decoded texture, source/retrieval labels, failed refresh retention, repeated-image warning, late response rejection, clearing an old image on selection change, 800×600 through 5K viewer bounds and screensaver cancellation.

The release workflow repeats source tests, validates every native icon image against the new ICO and runs real Windows silent-update/rollback tests before installer publication. The signed manifest is promoted only after re-downloading the published installer and matching its checksum. Physical Dell/GPU, visible-browser outcomes, taskbar cache refresh and user-facing camera field checks remain separate.

Visual review of the first native candidate caught collapsed action labels. The final candidate gives Close, Refresh and Official source their full text widths; native render checks assert those widths before screenshots are saved. The unsigned/unpromoted candidate was replaced before signing or advancing the auto-update feed.

Final release gate: GitHub Actions run 39471828841 passed source, native-render, Windows PowerShell 5.1 signature, actual silent installation/rollback, preserved-user-data, running-process protection, versioned-shortcut icon and publication checks. The exact published installer was re-downloaded from binary commit 26b43b2dbbd329fb537c95f5ea7470a2a19341d1 and matched SHA-256 770a28e4cc551895fb0fa052d42e8be154653c3c3aa2e914db0eb22a4756018c. Installed helper hashes matched source. The manifest was signed locally with the retained release key and verified with the installed public trust key; no private key entered git or CI.
