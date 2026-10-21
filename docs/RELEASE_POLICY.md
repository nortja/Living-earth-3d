# Preview and stable delivery

There is no production stable release. Current installers remain Windows publisher-unsigned previews.

Version 0.5.3 introduces authenticated automatic preview updates, explicitly requested by the owner. A dedicated 3072-bit RSA public key is pinned in the installed update core. The corresponding private release key stays outside git and CI. A detached RSA PKCS#1 v1.5 SHA-256 signature over the exact application manifest bytes is required before any installer can execute. This replaces the earlier preview limitation to manual installation; it does not permit checksum-only updates or claim Windows Authenticode trust.

`updates/preview.json` remains backward compatible so 0.5.2 and older can download the bootstrap installer manually. New installations use `updates/application.json` and `updates/application.sig`. Publish the installer first; publish the signed manifest, signature and preview discovery metadata atomically only after validation. Future small/large releases use the same authenticated full-installer path. Increasing the update protocol requires a deliberate compatibility plan.

The previous failing Windows workflow remains disabled and unchanged. Release-specific workflows on dedicated branches repeat source tests, cross-build, verify resources and execute Windows update/rollback checks before installer publication. They do not automatically promote an unsigned manifest or receive the private key.

Stable promotion still needs physical Windows GPU/DPI/refresh and sleep/resume evidence, reviewed screenshots, long-duration reliability, Windows publisher signatures and broader field testing. Headless Windows installation checks establish installer behavior, not native display quality or audible playback.
