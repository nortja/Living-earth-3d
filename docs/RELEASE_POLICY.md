# Development and stable delivery

There is no production stable release yet. Existing 0.5.0 downloads are unsigned previews.

- `main` currently preserves the existing preview application plus delivery maintenance. It is not a declaration of production readiness.
- `development` contains the next application cycle. Development installers and their update metadata stay on that branch; the existing `main/updates/preview.json` feed is not advanced by development publication.
- Development update metadata uses `channel: development`. The application and Windows helper both reject a different channel, unexpected installer URL, missing checksum or unsigned automatic replacement. Unsigned previews can only be downloaded and installed manually.
- The Windows workflow is manual-only, remains disabled until one controlled validation is possible, and has read-only repository permissions. It builds/test-installs the native EXE and uploads development artifacts. It cannot publish GitHub releases or alter update feeds. No automatic push/tag runs or account-wide notification changes.
- A production stable promotion requires successful native Windows install/upgrade/uninstall and display evidence, reviewed screenshots, physical GPU/DPI/refresh and sleep/resume testing, trusted signatures on app and installer, and an end-to-end same-publisher update test. A future stable feed must be separate and signed; it is not created by this development cycle.

Do not label a Linux render, cross-built PE, fixture parser test, provider HTTP 200, or simulated long-duration check as Windows hardware validation, live camera playback, or an actual hours-long soak.

Provider-network configuration is saved in the environment draft. Only the product's user-facing publication flow can activate a prepared environment snapshot/configuration; the agent has no publication tool. Git read/push access does not imply GitHub API access. No provider secrets are required for the current public services.
