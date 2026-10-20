# 0.7.0 exploration update — validation

Released preview, 2026-10-20. The signed automatic-update baseline is 0.7.0. The user reported that the 0.6.1 update installed well and its Camera Wall/cameras work on Windows.

## Implemented

- Explore tabs: Discover, Search, History and Saved, retaining the five main navigation areas and existing curated favorites.
- Twelve sourced wonders with daily UTC selection and surprise journeys. The daily cycle repeats after twelve days. Expanded Discovery screensaver journeys use this catalog.
- Up to fifty saved places, local persistence, duplicate-coordinate handling, immediate save/unsave feedback and invalid-coordinate rejection.
- Historical-site era slider and presets for Giza, Rome and Tikal. These are broad editorial teaching intervals and site markers on modern imagery, not reconstructions, historical borders or a complete ancient-world map.
- Explicitly requested Open-Meteo point-model estimates with Fahrenheit/mph or Celsius/km/h, model time, retrieval time, place context, cached/expired/unavailable states and late-response cancellation. No weather request occurs at startup, on ordinary navigation or in screensavers. Cache reads are bounded to 2 MiB and discard records older than 24 hours; stale/future-clock conditions are labeled. The request button is limited to once per minute.
- Daylight Earth and Orbital drift bring the screensaver menu to six styles, preserving sunlight/audio preferences on preview exit.
- Fourth in-app image source: Sequoia's Giant Forest, observed at 3840×2160. Camera Wall shares duplicate-source downloads and retains its two-request concurrency limit. Source image resolution does not establish capture freshness.
- Exact-pole navigation keeps a valid north-oriented camera; Night lights remains valid at a pole.

## Local evidence

- Godot 4.6.3 import and 464 behavior/data/layout checks passed across nine suites. PowerShell parsing, native resource-helper compilation and 16 update-security checks passed.
- Actual Open-Meteo response for Three Rivers parsed with explicit model UTC and units. All four NPS image sources returned decodable images; retrieval does not establish capture time.
- Native Linux software OpenGL: Discover/Search/History/Saved/Weather at 800×600, 1920×1080, 3440×1440, 3840×2160, 5120×1440 and 5120×2880; six short screensaver smoke checks; real model-weather screenshot; camera-wall, globe texture-preset and introduction regressions. Screenshots were inspected, and collapsed favorite actions plus save feedback were corrected. These are not physical Windows GPU/DPI benchmarks or hours-long screensaver soak results.

## Source and service notes

Discovery/history data reuse existing original explanatory text from the isolated development track, with UNESCO/NPS links retained in-app. Source pages were checked on 2026-10-20. No new third-party photographs were bundled. Historical intervals are editorial filters; source links describe the sites and should not be presented as exact founding-date citations.

Open-Meteo API documentation: https://open-meteo.com/en/docs . Current terms: https://open-meteo.com/en/terms . This remains a free, non-commercial, no-advertising app; no API key or paid plan is embedded. Reassess provider access before adding commercial/promotional features. Attribution appears in the weather panel.

Giant Forest source page: https://www.nps.gov/media/webcam/view.htm?id=81B461CE-1DD8-B71B-0B5150F44017DA05 . Its official image link is https://www.nps.gov/featurecontent/ard/webcams/images/sekilarge.jpg . Yosemite Conservancy streams remain external pending appropriate permission and playback work.

## Release gates

[Release validation run](https://github.com/nortja/Living-earth-3d/actions/runs/39507272694) passed Linux build/render checks and real Windows silent upgrades from both 0.5.2 and 0.6.1. Both baselines passed deliberate post-install failure rollback, previous-file/version restoration, user-data preservation, versioned desktop icons, running-process protection and uninstall.

The published installer was downloaded and verified before signing exact metadata with the existing pinned release key. Size: 36,457,608 bytes. SHA-256: `6353f718972d3255a46aa414a3e7df2b050d3bd6b259a8e472ade54495936595`. Discovery metadata, raw signed application manifest and detached signature were promoted together. Private signing material did not enter git or CI. The older failing general workflow remains disabled.

[Production updater run](https://github.com/nortja/Living-earth-3d/actions/runs/39508409043) passed on Windows: the live signed release downloaded while the app stayed open, cancellation left it unchanged, resuming installed after natural app exit, final payload hashes matched and an intentionally closed app stayed closed.

Physical monitor/DPI/performance, visible restart, Windows preview embedding, multi-monitor screensavers and embedded continuous video remain separate work. The project is still a preview.
