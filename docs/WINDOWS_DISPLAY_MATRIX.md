# Actual Windows framebuffer matrix

Frozen application 0.16.0 from source `d06e2f49dc531ed5bbf6ede400db38da7c2e57dd` was installed from its independently checksum-verified public installer and exercised by [run41230261117](https://github.com/nortja/Living-earth-3d/actions/runs/41230261117), job124622808879.

| Requested and actual viewport | Quality | UI scale | Result |
| --- | --- | --- | --- |
| 1920×1080 | detailed | 1.0 | Passed |
| 3440×1440 | detailed | 1.3333 | Passed |
| 3840×2160 | detailed | 1.75 | Passed |
| 5120×1440 | detailed | 1.3333 | Passed |
| 5120×2880 | detailed | 1.75 | Passed |

Each native Windows application process required a fresh report, Windows/non-headless display, exact viewport dimensions, real framebuffer/globe pixels, visible control bounds and unobstructed center. Earth/Command Center PNGs were saved; the archive digest was checked and 5K/ultrawide images reviewed. Driver identity: D3D12 (Microsoft Basic Render Driver), software rendering. Source imagery remains genuine 4K in detailed mode, not new 5K source detail.

The runner's virtual desktop is 1024×768. Original run41229789626 correctly rejected the 1920×1080 request because initial window creation yielded only1028×749, despite passing layout at that actual size. The test did not accept the smaller dimensions. Optional `-ResizeAfterStartup` now requests the exact native client area after the window exists and writes matrix-context.json explicitly recording the small desktop and oversize-window limitation. Strict framebuffer checks remain unchanged. The actual render can extend beyond the visible virtual desktop; this does not establish physical 4K/5K monitor/DPI, mixed-monitor, refresh, GPU performance or sleep behavior.

The maintainer harness supports Windows PowerShell5.1/Core via the OS environment check; the successful matrix ran under pwsh. It receives no signing key and cannot promote a feed. Ordinary app/saver behavior is unchanged. For physical monitors, omit the optional forced resize and use the unmodified requested-size checks on an appropriately sized desktop.

## Current 0.18.1 package gate

Full release run 41231442929, installed desktop job 124628418801, repeated all five exact sizes with the current 0.18.1 installer under Windows PowerShell 5.1. All reports passed using llvmpipe (LLVM 23.1.2, 256 bits), detailed textures and the same explicit small-virtual-desktop context. Archive digest verified and 5K/search images reviewed. The matrix is now required by the release-specific installed desktop gate, alongside its real five-minute recording and resource/backup checks.
