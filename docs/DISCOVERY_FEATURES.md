# Living Earth 3D — Discovery Features

Approved direction (October 2026): add optional cinematic discovery experiences without interrupting the calm screensaver.

## Earth Serendipity
- Occasionally showcase an extraordinary place with name, location, and a short fact.
- Allow users to opt in, control frequency, save favorites, and revisit in Explorer.
- Start with globe-level camera transitions; close terrain flyovers require licensed imagery and appropriate 3D terrain assets.

## Today's Wonder
- Show the same curated destination of the day to users who enable this option.
- No accounts, tracking, or user location required; publish a lightweight date-to-destination catalog with offline fallback.
- Clearly label the date in UTC or user's local date consistently.

## Living Sky
- Sun, Moon, and planetary positions using astronomical calculations, with explicit accuracy and data-source attribution.
- Optional satellite orbits only with properly refreshed orbital elements; distinguish predictions from live tracking.
- Optional cinematic Earthrise-from-the-Moon scene; label artistic views where applicable.

## Time Travel (later milestone)
- Historical layers for archaeological sites, trade routes, and selected reconstructions.
- Label reconstructions, uncertainty, dates, and source citations. Never present speculative imagery as verified history.

## Earth Moments (later milestone)
- Curated eclipses, aurora activity, volcanic events, and other extraordinary natural events.
- No intrusive popups; allow users to disable event highlights.
- Respect feed licensing, freshness timestamps, and graceful offline behavior.

## Release priorities
1. Core rotating Earth and Explorer camera.
2. Earth Serendipity and a small curated destination catalog.
3. Today's Wonder, offline-safe and opt-in.
4. Living Sky with Sun/Moon calculations.
5. Rich terrain, Earth Moments, and Time Travel as resources permit.

Keep all of these features optional, low-power-aware, and compatible with ultrawide screens. No external website is planned; distribute via GitHub Releases.
