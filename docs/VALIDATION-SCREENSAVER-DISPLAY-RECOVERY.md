# Native Windows screensaver display-topology recovery

Status: candidate implementation; validation pending.

## Intended behavior

A fullscreen saver no longer exits immediately when Windows broadcasts `WM_DISPLAYCHANGE`. It waits for a 350 ms quiet interval so a burst of resolution/topology notifications is coalesced, then:

- gracefully closes the existing owned renderer processes;
- retains the job-object kill-on-close safeguard for any renderer that does not exit;
- destroys and recreates the native host windows from the current monitor enumeration;
- starts the bounded renderer set again and restores the saver foreground/cursor grace state.

The embedded `/p` preview does not rebuild its supplied parent window; its existing resize tracking remains responsible for the new client dimensions. Suspend, session lock, committed logoff/shutdown and user-input exit behavior are unchanged.

## Validation plan

The cross-platform native policy test checks the debounce boundary and rejects a backwards timestamp. The installed Windows lifecycle test sends a burst of simulated display-change messages, verifies that the saver stays alive, checks that the old renderer exits and a replacement renderer covers every currently enumerated monitor, and confirms the burst produces only one rebuild.

The CI desktop has a software-rendered virtual display. This test does not physically attach/detach a monitor or establish Dell U4919DW mixed-DPI, GPU, sleep/wake or overnight behavior.

No installer, updater manifest/feed, trust key, signing material, preference or saved scene is changed.
