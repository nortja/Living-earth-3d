# 0.13.0 superseded candidate

This candidate was superseded before authenticated production-feed promotion. Do not sign or promote it; 0.13.1 includes its satellite feature and the narrow-window correction.

Corrected frozen source `c9138f055bf153debfff39802487be4e1e4048b3`, tree `01b2819fd9f05e5b2670463edc43c724e9b82234`, passed [pipeline 41219416770](https://github.com/nortja/Living-earth-3d/actions/runs/41219416770), including build/native, Windows installation/rollback/screensaver, installed desktop and public candidate-installer publication. The earlier run 41219104755 stopped on an obsolete future-version test fixture; that fixture was corrected to derive future versions dynamically.

Installed screenshot review then showed the initial satellite Load action partly below the small-window scroll viewport. A regression reproduced the issue at 800×600. The corrected 0.13.1 candidate increased the sheet height and required initial Load visibility in source/native/installed Windows tests, then passed its complete final pipeline and authenticated production updater. See VALIDATION-0.13.1.md for exact sources, failed readiness attempts, corrected final gates and released hashes.

Actual 2026-10-30 NASA imagery and source/native satellite rendering were exercised during this candidate's development. These were dated observations, not continuous video/current clouds or physical Dell GPU/DPI evidence. The production updater skipped directly from 0.12.4 to authenticated 0.13.1.
