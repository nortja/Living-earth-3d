# Next stage: authorized continuous-video pilot

Planning note, 2026-11-01. Continuous in-app video is not delivered by the current camera-image service or the sunlight candidate.

## Technical boundary

Godot 4.6's core VideoStreamPlayer supports Ogg Theora and does not stream URLs. Feeding an HLS/YouTube URL to that node is not a working implementation. [Official Godot playback documentation](https://docs.godotengine.org/en/4.6/tutorials/animation/playing_videos.html).

Evaluate a small native Windows WebView2 integration for one provider-approved embedded player. Its runtime must be detected explicitly; installed Edge alone is not a substitute. Missing-runtime behavior must keep Earth and existing image cameras usable. [Microsoft runtime distribution](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution).

This is a design candidate, not a dependency decision or completed permission review. Do not scrape signed media URLs, bypass a provider player, remove attribution or label an external website as in-app playback.

## Bounded first implementation

1. Select one feed with a documented embedding route and retained source/terms link. Verify actual playback and unavailable/seasonal states before adding it to the in-app list.
2. Prototype one selected video in the focused camera view. Start only on explicit selection, muted; expose sound and official-source fallback. Keep image Camera Wall behavior intact.
3. Restrict navigation/permissions to the required provider origins, deny device permissions, block downloads/popups and do not offer account sign-in in the embedded view.
4. Prove stop/destroy on selection change, close, minimization and screensaver entry. Tie native child lifetime to the app and test unexpected app/renderer exits.
5. Verify Windows resizing, keyboard focus/escape, fullscreen, mixed-scale handoff and recovery from network/renderer failure. Record CPU/private memory and perform a sustained test; repeat current release gates.
6. Resolve packaging/trust before rollout. The current updater verifies exactly four installed files. New executable/DLL/runtime payloads require an explicit integrity and backward-compatibility plan; never silently omit them from verification or weaken the existing schema.

## Acceptance

One real authorized stream plays continuously within the installed app, with visible source and honest status. Offline Earth and image cameras work without a video runtime or connection. All exits release media/children, screensavers stay silent, no download occurs before selection, and authenticated upgrading/rollback continue to validate the complete executable payload. Physical Dell observation supplements software-rendered CI.
