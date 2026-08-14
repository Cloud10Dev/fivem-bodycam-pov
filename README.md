# FiveM Bodycam POV

A standalone forced first-person bodycam resource for FiveM. The camera uses GTA's native first-person head/eye placement rather than a scripted camera attached to the player's waist. This keeps mouse look and normal first-person weapon handling intact.

## Current implementation

- Native first-person camera is reasserted every frame.
- Mouse look is preserved.
- Camera-switch and cinematic controls are blocked.
- NUI is explicitly initialized after load and forced to visible when enabled.
- Bodycam overlay includes REC state, scanlines, vignette, noise, framing corners, unit, location, speed, direction, timestamp, and status.
- `/bodycam` toggles the view because the command is enabled by default.

## Installation

1. Place the resource in your server's `resources` directory.
2. Add `ensure fivem-bodycam-pov` to `server.cfg`.
3. Restart the resource.
4. Use `/bodycam` to toggle it if needed.

If the overlay does not appear, use `restart fivem-bodycam-pov` after connecting rather than only restarting the server resource before the player has loaded. Also confirm that `Config.HudEnabled = true` and that the resource's `html` files are present.

The visual treatment is an original bodycam-inspired effect, not a copy of proprietary game assets or code. Similar FiveM bodycam resources commonly combine a custom camera perspective with a visible Axon-style overlay. [web:27][web:16]
