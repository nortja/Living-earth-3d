# Changelog

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
