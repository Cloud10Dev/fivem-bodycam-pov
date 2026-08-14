# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with an orange/red HUD and ox_inventory weapon telemetry.

## Camera tuning

The uploaded screenshot showed the native first-person view too far forward, causing the rifle to be cropped and leaving the full weapon out of frame. This update tunes the native gameplay camera backward/downward through relative camera values while preserving normal mouse look and weapon handling.

- On-foot FOV: `82.0`.
- Vehicle FOV: `78.0`.
- On-foot relative pitch: `-1.5`.
- On-foot relative heading: `-0.35`.
- Vehicle relative pitch: `-0.5`.
- Vehicle relative heading: `-0.15`.

Adjust these values in `config.lua` if a custom weapon pack has a different camera profile. GTA/FiveM first-person FOV and weapon framing are also affected by the native camera and weapon metadata, so camera tuning should remain moderate rather than using extreme FOV values. [web:116][web:117]

## Stability

Mouse look, aiming, movement, sprinting, jumping, and shooting remain enabled. Only camera-switch and pause/cinematic controls are blocked. The HUD remains hidden until the player is active and spawned.

## ox_inventory

```cfg
ensure ox_inventory
ensure fivem-bodycam-pov
```

The active hotbar item must actually equip the GTA weapon for weapon telemetry to update. [web:46][web:105]
