# Live Cameras — planned channel

Add an optional **Live Cameras** channel to Living Earth 3D Explorer.

## Experience
- Public camera icons at verified geographic coordinates on the globe.
- Select a camera to open a stream in Explorer with place name, provider attribution, live/offline indicator, and source link.
- Offer categories: wildlife, oceans, mountains, cities, and space where authorized feeds exist.
- Optional curated 'Camera of the Day' and saved favorites.
- For the passive screensaver, use nonintrusive previews only where licensing, bandwidth, and power settings permit; default to no streaming.

## Constraints
- Use only explicitly public, authorized embeds/streams with terms permitting third-party integration; never scrape or expose private/security cameras.
- Respect geolocation precision, privacy, copyright, advertising/branding requirements, rate limits, and stream availability.
- Some feeds permit linking but not embedding: open provider site instead.
- Stop streaming when closed, locked, sleeping, or on low-power mode as appropriate. Do not ship a giant video-feed dependency or compromise the single-installer experience.

## Rollout
Start with a handful of permission-checked cameras and graceful offline fallback, then expand a curated directory. No camera integrations are implemented yet.

## Ultrawide multi-camera viewing — priority feature
- Add a **Camera Wall** in Explorer: choose 1, 2, 4, 6, or 9 simultaneous cameras, with layouts optimized for 16:9, 21:9, and 32:9 displays.
- On 32:9 Dell-style super-ultrawide, use a large featured stream plus smaller live tiles, or a configurable equal-size grid. Preserve each stream's aspect ratio: crop intentionally or letterbox, never stretch.
- Select a tile to feature it, swap sources, mute/unmute a selected feed when permitted, or return to the globe; save favorite camera collections locally.
- Use adaptive streaming, configurable resolution, a simultaneous-stream limit, and automatic pause for hidden/offscreen feeds to avoid saturating bandwidth and GPU decode capacity.
- Respect camera provider embed rules and source attribution; some feeds must open on their official websites.
- Treat video wall as Explorer functionality, not an always-running screensaver. Multi-camera streaming is opt-in and off by default.
- Test on the user's Dell ultrawide after its exact model and resolution are known.
