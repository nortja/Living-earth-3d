# Scene Library and synchronized Moon zoom

Live Earth → Scene library saves up to eight personal offline compositions on this PC. Enter an optional name, then Save view. Each entry has a clean 384-pixel preview, Use view and Remove. The most recent removal can be undone until the app closes; an older removed thumbnail is discarded when replaced by another undo. Missing or damaged thumbnails do not prevent valid saved views from working.

Each scene stores camera angle/distance, Earth rotation, Moon/cloud/star choices, cinematic or current UTC sunlight, galaxy visibility/brightness/orientation. Use applies the saved visual defaults. Play uses temporary choices without rewriting those defaults; Pause retains the current composition. Moon phase and optional UTC sunlight remain current, rather than pretending to reproduce historical observations. Names and profiles are bounded and validated; thumbnails are local PNGs with pre-decode file/dimension limits. Scene previews retain applicable ESO/S. Brunier attribution.

Play cycles at 15, 30, 60 or 120 seconds with a short fade. It temporarily suspends the older timed-discovery mode and restores that choice with a fresh timer on pause. Next advances explicitly. Manual drag/zoom, other pages, minimized windows, file dialogs and in-app screensaver preview entry stop playback. Closing the panel or moving the pointer out lets explicit playback continue with the existing clean-view policy. There are still six native screensaver styles; this library is a desktop feature. No provider requests, automatic screenshots or cloud upload.

Save view requires offline Earth: finish simulated sunlight, turn off requested satellite/infrared imagery and weather points before saving. Use restores the offline base and clears observation overlays. Scene metadata is stored in the existing local preferences, with an owned companion thumbnail directory. Never delete arbitrary user files. Individual scenes are not portable backup bundles; Saved places backup remains separate.

## Moon size fix

The Moon is a camera-facing, NASA-textured illustrative companion. Previously its size/offset were fixed in camera space while the Earth changed apparent size, so zoom broke their relationship. Both Moon size and its lateral spacing now follow Earth's exact perspective silhouette scale, proportional to `1 / sqrt(d² − 1)` for the unit Earth sphere. The normal distance 3.6 retains the existing composition. Position updates use actual camera distance, including the final tween frame, camera resets, journeys and restored scenes.

The optional Moon switch remains authoritative. Very close framing can crop the Moon along with Earth. This is proportional cinematic composition, not physical Earth–Moon distance, an orbital simulator or an actual local sky.

See [validation](VALIDATION-0.24.0.md) for native pixels, source geometry and installed Windows evidence. Milky Way source and rights remain in [Space Studio](SPACE_STUDIO.md).

## Shuffle scenes (0.25.0)

Enable **Shuffle scenes** before Play for a fresh order of saved compositions. Each round visits every other view once, excluding its starting view; the next round never repeats the last view immediately. A single saved scene remains usable. The choice stays on this PC, defaults off, and changing it pauses playback. Save/Remove/Undo rebuild the bounded sequence safely. No imagery downloads or uploads.
