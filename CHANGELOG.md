# Changelog

## 0.5.0 — A spacious Earth workspace

- Replaced the bottom settings tray with compact navigation, a clear full-Earth launch view, animated page transitions, a single close action, and dedicated Explore, Live Earth, Cameras, Command Center, Screensavers and Settings pages.
- Kept the globe proportional at native framebuffer resolution. UI adapts to 800×600 through 4K, 5K and ultrawide windows; smaller windows use a bottom panel, and wide layouts optionally add a compact mission overview opposite the Command Center.
- Added monitor resolution/DPI/refresh and GPU reporting, a frame cap that respects lower refresh rates, and monitor-change detection. Retained 2K/4K presets and 30 FPS power saving; no hardware performance benchmark is implied.
- Added an offline city/nature/heritage atlas, latitude/longitude search and explicit worldwide Nominatim search with OpenStreetMap attribution and request throttling. New locations animate into view with a surface marker. Curated favorites and timed journeys remain intact.
- Added four official camera-provider entries with globe journeys. Watching opens the provider page in a browser; availability, seasonal streams and periodic imagery are labeled. No embedded playback or verified-live status is claimed.
- Added on-request USGS M2.5+ past-day earthquake observations, filtered coordinates, event UTC times, retrieval timestamps, versioned disk cache and unavailable/cached states. No fabricated observations or automatic polling.
- Added four saved screensaver styles and an in-app fullscreen preview that returns on input. Screensaver startup skips update checks; previews cancel active requests.
- Added a native packaged-app display validation mode and PowerShell runner for 1080p, ultrawide, 4K and 5K Windows checks with screenshots, platform/GPU identity and fresh JSON evidence. Windows execution remains outstanding because no Windows runner is available in the current cloud instance.
- Preserved the branded intro, globe interactions, source attributions, single-EXE installer and strict signed-update requirements. Passed 95 behavior/interface/data checks, three intro stages, 12 quality/resolution renders, six layout runs, packaged-resource/icon/payload checks, and published download/checksum/HTTPS-feed verification. These are Linux-native and cross-package checks; Windows execution remains outstanding. Automatic GitHub builds remain disabled.

## 0.4.0 — Clouds, detail, and deep space

- Replaced the daytime/night-light surface maps with attributed Solar System Scope imagery: genuine 4K detail mode and 2K Balanced maps, with no upscaling.
- Added an independent moving cloud shell and subtle cloud shade; this is offline artwork, not live weather.
- Added optional instanced stars and an optional textured Moon backdrop. Both are artistic rather than live astronomical data.
- Refined the atmospheric rim, ocean response, and night-light transition.
- Saved cloud/star/Moon toggles, texture quality, and a 30 FPS power-saving preference locally.
- Added a fixed-project preview update feed with strict installer URL and checksum validation. Future previews can be discovered inside the app and downloaded directly; unsigned previews still cannot self-replace. The Windows helper additionally verifies package SHA-256 and same-publisher Authenticode signatures, and prevents overlapping updater instances.
- Installer/uninstaller now ask to close the running app gracefully before replacing or removing files; no forced termination.
- Preserved intro, native icons, favorites, discoveries, and controls. Fifty-six behavior checks, three intro render stages, and eight quality/resolution rendering cases passed locally.
- User reported successful installation and launch of 0.3.0 on Windows. New 0.4.0 Windows hardware and signed-update tests remain outstanding.
- Kept automatic GitHub builds disabled; no tag-triggered workflows were reintroduced.

## 0.3.0 — Earth identity and first impression

- Replaced the generic icon with illuminated Earth artwork, including seven native Windows icon sizes (16–256 px) for the application, installer, and uninstaller.
- Removed the Godot boot graphic. A 2.8-second real-time Earth reveal now brightens the globe and approaches the starting view before showing controls. Input skips the intro.
- Added gentle drag inertia, double-click zoom, a visible Reset Earth action, and Home to restore the full globe.
- Preserved wheel zoom, orbit controls, offline destinations, favorites, and opt-in discovery. Tests now use an isolated preferences file.
- Kept the single self-contained Windows installer, desktop/Start menu shortcuts, and per-user uninstall behavior.
- Changed the Windows build script to wait explicitly for Godot processes and validate exit codes and runtime logs. Branding is applied to the clean export template before its embedded data pack is built.
- Disabled the failing GitHub installer workflow and removed automatic tag triggers after failure emails were reported. It remains disabled; no remote runs are needed for local development.
- Added a prioritized living roadmap and explicit release evidence. Windows hardware/installation testing and release signing remain outstanding.

## 0.2.0 — Installer and textured Explorer preview

- Added an NSIS Windows installer, bundled screensaver executable, shortcuts, and uninstall entry.
- Added offline 2K Earth maps, night lights, atmosphere, smooth wheel zoom, and monitor-aware sizing.
- Added six offline discovery destinations, camera journeys, favorite persistence, and optional timed discovery.
- Implemented optional GitHub release checks and an updater that refuses unsigned or differently signed installers.
- Published a checksum-verified installer download from a dedicated repository branch after direct release uploading was unavailable.
