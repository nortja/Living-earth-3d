# 0.5.4 validation

Local checks: Explorer 56, interface/data 43, ambient 6, interface sizes 187, automatic-update controls 6, camera viewer 22, update signature/security 16. Unit/layout tests passed. Separate real HTTPS requests fetched and decoded the three NPS camera images at 1920×1080. Retrieval success does not prove camera capture freshness or future availability.

The image viewer tests cover opt-in startup, allowlisted sources, visible selection outcome, decoded texture, source/retrieval labels, failed refresh retention, repeated-image warning, late response rejection, clearing an old image on selection change, 800×600 through 5K viewer bounds and screensaver cancellation.

The release workflow repeats source tests, validates every native icon image against the new ICO and runs real Windows silent-update/rollback tests before installer publication. The signed manifest is promoted only after re-downloading the published installer and matching its checksum. Physical Dell/GPU, visible-browser outcomes, taskbar cache refresh and user-facing camera field checks remain separate.

Visual review of the first native candidate caught collapsed action labels. The final candidate gives Close, Refresh and Official source their full text widths; native render checks assert those widths before screenshots are saved. The unsigned/unpromoted candidate was replaced before signing or advancing the auto-update feed.
