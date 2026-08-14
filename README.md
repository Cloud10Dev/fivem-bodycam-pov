# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with an orange/red HUD and adjustable head-mounted camera.

## Why the native values did not help

The previous `SetGameplayCamRelativePitch` and `SetGameplayCamRelativeHeading` values changed camera orientation, not the physical camera-to-weapon distance. That is why changing numbers appeared to make little or no difference. GTA V also does not provide a general native viewmodel-offset control for every first-person weapon; weapon positioning can be affected by weapon metadata. [web:115][web:144]

## New explicit camera positioning

The resource now uses a custom camera attached near the head bone with direct X/Y/Z offsets:

```lua
Config.CameraOffsetX = 0.0
Config.CameraOffsetY = -0.12
Config.CameraOffsetZ = 0.08
```

- X: left/right.
- Y: forward/backward relative to the head. Negative moves the camera backward.
- Z: up/down.

The default is deliberately behind and slightly above the head so more of the weapon should remain visible. The FOV is `78.0`, which is less distorted and gives the weapon more screen presence.

## Live tuning

Use the F8 console while in gameplay:

```text
bodycam_offset 0.00 -0.20 0.10
bodycam_offset 0.00 -0.30 0.12
bodycam_reset
```

Changes apply immediately without editing or restarting the resource.

## Controls

The custom camera reads normal mouse look while leaving movement, sprint, jump, aim, and fire controls available. Only camera switching and pause/cinematic controls are blocked.

The HUD remains hidden until the player is fully active and spawned.
