# Real-time native screensaver long runs

These are supplementary Linux software-rendered checks of exact frozen application sources. They do not establish physical Windows/Dell GPU, mixed-DPI/monitor, sleep/power or overnight behavior.

| Version | Frozen source | Actual duration | Result |
| --- | --- | ---: | --- |
| 0.16.0 | d06e2f49dc531ed5bbf6ede400db38da7c2e57dd | 3606.961 seconds | 0 failures |
| 0.18.0 | d0f881d0273a591c4c174b3f9ceb5c0cb749850f | 3606.937 seconds | 0 failures |
| 0.18.2 | da9f06f4267cf896dfb576d18402946e74f7eb15 | 1803.705 seconds | 0 failures |

The 0.16.0 run used actual native graphics at 640×360 with `--saver-hosted --saver-preview --soak-seconds=3600`, the 15 FPS preview budget, Godot 4.6.3 and Mesa llvmpipe. It cycled all six styles at five-minute intervals, checked quiet/hidden controls, disconnected requests, bounded engine memory/node counts and retained renderer operation. There were 120 real-time samples; sampled FPS ranged 14–15 within the cap. Engine-tracked memory after warmup was 49,675,522 bytes, peak 49,809,876, growth 134,354 bytes (about 131 KiB). Node count peaked at 451. Engine-tracked memory excludes driver/GPU/process allocations.

[Raw 0.16.0 report](evidence/native-saver-hour-0.16.0.json) preserves the actual sample timings and limits. The test ran against a separate frozen checkout while later source work continued. A later full-package Windows ten-minute preview/lifecycle gate remains required for each candidate; these long runs do not replace it.

The exact 0.18.0 run completed 120 real-time samples, 14–15 sampled FPS, baseline engine-tracked memory 50,872,924 bytes and peak 51,007,258 (growth 134,334 bytes), with node count at most 459. All six styles were exercised. [Raw 0.18.0 report](evidence/native-saver-hour-0.18.0.json). Same software/viewport/preview limits apply. The later 0.18.2 run completed 1803.705 seconds: 60 real-time samples, all six styles, sampled FPS 14–15, baseline engine-tracked memory 50,853,528 bytes and peak 50,938,682 (growth 85,154 bytes, about 83 KiB), with node count at most 459. [Raw current-source report](evidence/native-saver-half-hour-0.18.2.json). Same software/viewport/preview limits apply.
