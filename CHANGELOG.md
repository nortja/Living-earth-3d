# Changelog

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
