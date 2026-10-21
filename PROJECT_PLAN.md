# Living Earth 3D

A free, open-source Windows screensaver and interactive Earth explorer.

## Vision
A cinematic 3D Earth that feels alive: day/night lighting, atmospheric effects, gentle camera journeys, and optional real-world information at meaningful geographic locations.

## Planned features
- Three switchable visual modes: Natural, Future, and Hybrid (default).
- Seven optional information channels: world events, weather, markets, crypto, space, sports, and discoveries.
- Personalized journeys to favorite locations, plus Surprise Me and ambient-only modes.
- Interactive Explorer for investigating events, exploring the globe, and bookmarking places.
- Automatic adaptation to standard, ultrawide, super-ultrawide, and multiple displays.
- Optional ambient audio, **off by default**.
- Offline-capable globe, graceful data caching, local preferences, no accounts or tracking.
- Discreet About & Support panel crediting Jaison Norton, linking to CarrierMSG.com, World Mobile referrals, and optional public-address crypto tips. No pop-ups or ads.
- One simple Windows installer bundling Explorer and screensaver.

## Development approach
Godot 4 is the proposed 3D engine. First milestone: working Windows Explorer with a smooth rotating globe, camera controls, atmospheric rendering, and resolution-aware layout. Then add data feeds, saved journeys, screensaver integration, packaging, and release testing.

## Current status

The released baseline is 0.9.0. The installer and authenticated automatic updater are implemented. The user confirmed 0.5.3 installation and enabled updates. Globe navigation, responsive native-resolution layout, original optional ambient audio, offline discovery, requested USGS observations and four in-app image cameras are implemented. Version 0.6.1 adds Camera Wall layouts/collections and approximate current UTC sunlight. Version 0.7.0 integrates daily wonders, saved places, a dated historical-site atlas, requested point-model weather, two more screensavers and Giant Forest camera imagery.

The original visual-theme and seven-channel ideas above are a concept backlog, not completed features. Current sources do not provide a broad news, global weather-layer, financial, sports or satellite-tracking service. Those channels need bounded requirements and source/access decisions before implementation. Version 0.8.0 adds native Windows preview embedding and per-monitor screensaver hosts, with software-rendered Windows lifecycle checks. Continuous embedded video and physical mixed-DPI/multi-monitor screensaver validation remain unfinished. Physical GPU/DPI, monitor transitions and visible updater restart require a real Windows desktop. ROADMAP.md is authoritative for priorities; Version 0.9.0 completes the destination arrival card and saved-camera viewer handoff. Release evidence is in docs/VALIDATION-0.9.0.md.

The old failing Windows installer workflow remains disabled. Releases use a narrowly scoped, one-version validation branch that tests on Linux and Windows before publishing an installer. Signed automatic-update discovery is promoted separately only after the published bytes are verified.

## Principles
Keep the screensaver calm and nonintrusive. Preserve user privacy. Never require crypto wallets or donations. Do not store private keys. Support performance scaling and power-saving behavior.

## Support
This project is intended to remain free to use. Optional support links will be added after the creator supplies the exact public URLs and receiving addresses.
