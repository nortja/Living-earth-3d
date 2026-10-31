# 0.15.0 candidate validation

Prepared 2026-10-31. Adds a previous-seven-UTC-days selector to the optional NASA GIBS satellite view, defaulting to yesterday. Selection is local until Load; the displayed observation date/texture does not change before successful retrieval. Selection is disabled during a request. Only one mosaic is retained in memory. No startup/timer/native-saver requests are added. Offline Earth is beside Load and immediately visible.

All sixteen source suites passed 1046 checks before the final offline-action placement; the relevant satellite regression then passed 38 checks (three added viewport assertions), bringing covered total to 1049. Actual request through the app for the oldest offered day, 2026-10-24, returned a valid 2048×1024 mosaic. The actual image rendered at 800×600, 1920×1080, 3840×1080 and 5120×2880 after the final control placement; date picker, Load and offline return fit without scrolling. Screenshots reviewed.

The installed Windows validator requires seven choices, correct selected offset, unchanged displayed date/no request when choosing another day, visible date/offline controls and all prior satellite/weather/photograph/performance behavior. A fresh frozen-source build and full Windows/native gates remain required. Production is 0.13.1 until independently verified signed promotion; 0.14.0 is a separate running candidate.

Model weather remains an explicit 32-place point sample. Satellite mosaics are daily composites with real gaps, not simultaneous photographs or a current cloud field. Software-rendered validation does not establish physical Dell GPU/DPI, mixed-monitor or sleep/resume behavior. See SATELLITE_SNAPSHOT.md for primary-source acknowledgement and protocol limits.
