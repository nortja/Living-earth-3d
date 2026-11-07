# Unreleased camera elapsed-age reliability

November 7, 2026. Unchanged-image warnings now measure elapsed age using monotonic engine milliseconds, rather than subtracting wall-clock UTC values. A computer clock correction cannot change the elapsed-age calculation. UTC retrieval/check values and provider Last-Modified remain separately labeled; capture time is still unverified. No request, refresh cadence, memory limit, preference or updater behavior changes.

Targeted regression tests cover identical HTTP 200 bytes, HTTP 304, failed refresh retention, changed-image reset, future UTC display metadata, and existing provider-specific five-/thirty-minute thresholds. Local Godot 4.6.3 import and all 356 camera assertions passed: viewer 41, revalidation 230, expansion 26 and wall 59. The 12 release-verifier tests also passed.

Application change source: `7e050bbf83b09ce55047348786709e32941a3d31`. Validation correction source: `ea64fd9c0cbc4b6d9bd863ac0929efbeba2dc4fc`, with the same application change. [Targeted Linux and Windows validation](https://github.com/nortja/Living-earth-3d/actions/runs/42390478383). The earlier [run](https://github.com/nortja/Living-earth-3d/actions/runs/42390178635) passed Linux but stopped during Windows tool setup before any application tests; its tool checksum lookup was replaced with the exact official SHA-512 pin, without changing application source.

Native validation uses an explicitly named generated JPEG fixture and makes no camera-provider request. Linux exercises 870×612, 2496×1664 and 3840×1080 layouts; Windows exercises 870×612 with checksum-pinned test-only software OpenGL. This is source/native Godot validation, not an installed-package, full release matrix, physical Dell/DPI/sleep or actual-provider freshness test.

Both final CI jobs passed: all 356 camera assertions on each platform and zero native-render failures. Linux job 128456805596 and Windows job 128456805458 retain the logs and fixture screenshots. The new rendered check confirms the age warning remains alongside distinct UTC retrieval metadata and a retained image.

This change is not distributed. The published 0.25.1 installer, authenticated metadata, pinned key, updater helper bytes and old disabled workflow remain unchanged. A separately versioned candidate must pass full installer, Windows lifecycle, public download/provenance and signature gates before update-feed promotion.

The Windows 870×612 fixture screenshot was visually reviewed: retrieval/check identity, capture-time limitation, elapsed-age warning and primary actions are readable within the viewer.
