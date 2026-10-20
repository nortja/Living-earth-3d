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

The released baseline is 0.5.4; 0.6.1 is undergoing release validation. The installer and authenticated automatic updater are implemented. The user confirmed 0.5.3 installation and enabled updates. Globe navigation, responsive native-resolution layout, original optional ambient audio, offline discovery, requested USGS observations and three in-app image cameras are implemented. The 0.6.1 candidate adds Camera Wall layouts/collections and approximate current UTC sunlight.

The original visual-theme and seven-channel ideas above are a concept backlog, not completed features. Current sources do not provide a broad news, weather, financial, sports or satellite-tracking service. Those channels need bounded requirements and source/access decisions before implementation. Continuous embedded video, Windows preview embedding and multiple-monitor screensavers remain unfinished. Physical GPU/DPI, monitor transitions and visible updater restart require a real Windows desktop. ROADMAP.md is authoritative for priorities; release evidence is in docs/VALIDATION-0.6.1.md.

The old failing Windows installer workflow remains disabled. Releases use a narrowly scoped, one-version validation branch that tests on Linux and Windows before publishing an installer. Signed automatic-update discovery is promoted separately only after the published bytes are verified.

## Principles
Keep the screensaver calm and nonintrusive. Preserve user privacy. Never require crypto wallets or donations. Do not store private keys. Support performance scaling and power-saving behavior.

## Support
This project is intended to remain free to use. Optional support links will be added after the creator supplies the exact public URLs and receiving addresses.
