# Changelog

## 0.5.4 — Visible cameras and a clearer Earth identity

- Replaced desktop/app/installer/uninstaller artwork with a new Earth tile and seven native Windows icon sizes. Shortcuts and installed-apps entries reference a versioned ICO; setup requests a shell icon refresh.
- Camera clicks now open an in-app periodic-image viewer for three NPS Yellowstone cameras. Added loading, failure/retained-image states, source credit, timestamps, refresh controls, late-response protection and unchanged-frame warnings. Images are not labeled as continuous live video.
- External video/seasonal cameras now open their official pages directly when selected; added Sequoia's official camera page.
- Preserved the pinned automatic-update trust key and update protocol so 0.5.3 can acquire this release without another manual installation.
- Reconciled the roadmap with completed sound, interface scaling and Windows-tested signed updates, while keeping continuous video, multi-camera viewing and physical hardware checks open.


## 0.5.3 — Install once, update from the app

- Added automatic update checks at startup and every 30 minutes while Explorer is open. Verified updates download in the background and install silently after all app/screensaver windows close.
- Added Update and restart now, persistent pause/resume, progress/error status and cancellation. Offline use continues when updates are unavailable.
- Added a pinned 3072-bit RSA release-signing key and detached SHA-256 signatures. The helper verifies raw metadata, exact project URLs, version, bounded download size, installer checksum and installed app/helper hashes. A checksum alone never authorizes execution. Private signing material is excluded from git and CI.
- Both small and large releases use the full installer internally. Existing preferences/favorites remain outside the installation directory; normal updates require no installer wizard or manual download.
- Added a previous-file backup and restoration on installer/post-install verification failure. This is not a guarantee of recovery from power loss during replacement. Windows publisher signing remains separate from release authentication.
- Passed 310 local application/security checks; the release workflow additionally gates publication on real Windows installation and rollback tests.
- Older versions need this bootstrap installer once. No scheduled service, administrator access or global execution-policy change is required.


## 0.5.2 — Readable controls on large displays

- Added saved interface sizes: Automatic, 100%, 125%, 150%, 175% and 200%. Changes apply immediately without reducing Earth rendering resolution.
- Smaller windows safely limit the effective size and explain the adjustment; the chosen size returns when the window grows again.
- Invalid saved sizes fall back to Automatic. Existing audio, favorites and graphics preferences remain intact.
- Passed 288 Linux headless behavior/layout checks; installer publication repeats these and checks native icon resources.
- User confirmed 0.5.1 installed and works on Windows. This does not establish 0.5.2 Windows DPI or hardware performance.


## 0.5.1 — Optional ambient sound

- Added an original offline synthesized ambient pad, disabled by default, with saved volume and smooth fades.
- Screensaver launch and preview stay silent; returning to Explorer restores opted-in sound.
- User confirmed that the 0.5.0 installer installs nicely. Display, upgrade and performance checks remain separate.
- Existing 95 regression checks and six ambient behavior checks pass on Linux; Windows playback and installation of this version remain unverified.


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
