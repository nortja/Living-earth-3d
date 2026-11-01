# Space Studio — 0.23.0

Open Live Earth → Space studio. Toggle Moon and Milky Way separately, use the three scene presets, and adjust galaxy brightness/orientation. Default Moon and galaxy remain off; existing Moon choices persist. Every screensaver style respects the Moon choice. The galaxy is bundled offline; desktop uses 4096×2048, native saver 2048×1024, with a 32px lighting-radiance budget independent of direct sky detail. Galaxy reflection lighting is disabled while shown so the photograph does not relight Earth. Generated decorative stars are suppressed behind the photographic sky.

The panorama is ESO/S. Brunier, photographic all-sky composite released in 2009. The public 6000×3000 TIFF was downsampled with Lanczos to JPEG quality 95 without chroma subsampling; no generative edits or upscaling. Source/derivative hashes and terms live under assets/space/. The unreleased 800-million-pixel original is not used. Credit stays visible with the picture, including clean exports. Image is our Milky Way seen from inside, not an exterior photo or accurate current/local-sky projection. Brightness/orientation, Moon/Earth relative sizes and placement are composed. Source: https://www.eso.org/public/images/eso0932a/ ; CC BY 4.0 https://creativecommons.org/licenses/by/4.0/ ; terms https://www.eso.org/public/copyright/ .

## Clean scene

Menus hide on native Window pointer-exit and focus-out; returning to the app restores the open page and typed values. Window events avoid child-control hover flicker. H or Clean view also hides menus while inside; pointer motion or H/Esc returns. Keyboard shortcuts do not intercept text entry. The saved Hide menus when pointer leaves switch disables auto hiding. Moon remains independently optional. UI hiding removes data/focus/tour markers without discarding retained source data. Native screensavers use their existing host lifecycle; hover cannot reveal their controls.

Camera refresh is paused/cancelled when hidden, retaining image identity; old callbacks are rejected. The camera wall is suspended. Return releases this visibility pause. Native backup/save dialogs defer automatic hiding, so file selection does not disappear when the pointer crosses the app window.

## Picture export

Save picture opens a native chosen-file PNG dialog. Capture temporarily hides menus/overlays/markers, waits for a fresh rendered frame, reads the current actual viewport pixels and restores the actual pointer policy. The resulting PNG includes any galaxy credit; no upscaling, new provider fetch, automatic wallpaper change or OS preference change occurs. Failures restore UI state. Maximum supported export is 7680×4320 and 33,177,600 pixels. Physical GPU/DPI/sleep behavior remains a separate field check.

## Validation

Source regression covers restoration, optional Moon across all six styles, preference recovery, bounded settings, modal behavior, request pause and invalid export paths. Native renders cover eight sizes through 5K, compare actual Moon-on/off pixels over the sky, and save/decode a clean native-resolution postcard. Normal visual validation explicitly pins controls visible; the separate installed Windows hover test uses real SetCursorPos calls over a header control, outside the window and back, and records fresh screenshots/state files. No synthetic Window signal stands in for that Windows OS test.
