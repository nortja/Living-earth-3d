# Automatic-update release process

Consumer behavior: one 0.5.3 bootstrap installation, automatic authenticated downloads, apply after normal exit, or Update and restart now. Pause/resume is saved. Offline/network failures leave the existing app usable. No background Windows service is installed; checks happen while the app is open, and a helper waits for normal exit after a download is ready. Close active screensavers and the Windows Screen Saver Settings preview before applying an update; their native renderer keeps installed files in use.

Authentication: installed public RSA-3072 key -> detached signature over exact UTF-8 manifest -> fixed project installer URL, version, size and SHA-256 -> expected installed files. This remains mandatory even though preview installers have no Windows publisher certificate. Do not bypass either signature or hash verification. Production Authenticode signing can be added independently.

Maintainer sequence:

1. Update all product versions and regression expectations. Keep the signing key outside git and exported build directories.
2. Run Godot regressions, PowerShell parsing and update-security tests. Cross-build the application, the separate native .scr launcher and installer. Write payload-hashes.json from those actual binaries and the update helpers.
3. On Windows, run update_security_test.ps1 using Windows PowerShell 5.1, and windows_update_install_test.ps1 against the built installer and payload metadata. This tests silent installation at a path with spaces, rollback on a bad installed-file hash, running-app protection, preservation of user data and uninstall. Native GPU/DPI and visible-app restart behavior remain separate.
4. Publish installer, its SHA-256 and payload-hashes.json under downloads/windows-VERSION only after checks pass. Download it again and verify its digest.
5. Retrieve the owner's private release-signing key from its private backup. Invoke sign_release.py with --key, --installer, --payload-metadata, --version and --output-directory. The signer rejects a key that differs from the pinned public key. Never print or commit the private key.
6. Verify the produced signature with the installed PowerShell core; atomically publish updates/application.json, updates/application.sig and backward-compatible updates/preview.json. A new release is not auto-update-ready until all three are published.

The current updater uses full installers for both minor and major releases; differential downloads are not implemented. It keeps one previous-file backup. New installers must preserve the install location, app/helper filenames and preference storage until a planned protocol migration. Cancelling during download is supported; an installer already committing files is allowed to finish. Network error status is non-modal. No updater-forced termination, checksum-only execution, production-ready claim or guarantee against power-loss interruption.
