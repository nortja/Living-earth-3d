# 0.5.5 camera action layout correction

Visual review of the 0.5.4 native 1080p camera screenshot revealed that Close, Refresh and Official source buttons collapsed to blank pills: the common button helper enabled clip_text outside the application header. Camera viewer actions now explicitly preserve their text minimum width.

The camera suite checks each action is non-clipping and measures actual button width against rendered font text at 800x600, 1080p, ultrawide and 5K. The isolated release workflow repeats all source/security checks, captures native Linux screenshots and gates publication on Windows installation/rollback and shortcut-icon checks. Physical Windows GPU/DPI and visible restart remain field checks.
