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
