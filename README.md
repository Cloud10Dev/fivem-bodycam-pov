# FiveM Bodycam POV

A standalone FiveM resource that provides a forced first-person bodycam camera and a visible Bodycam-inspired overlay.

## Fixes in 1.1.0

- Mouse look is preserved. Look controls are no longer disabled.
- Only camera switching and cinematic camera controls are blocked.
- A scripted camera provides a configurable head-mounted perspective.
- Added subtle breathing sway, movement shake, vignette, animated noise, scan framing, status panels, compass heading, and live system indicators.
- The NUI overlay is intentionally high-contrast and visible over gameplay.

## Installation

1. Put this folder in your server's `resources` directory.
2. Add `ensure fivem-bodycam-pov` to `server.cfg`.
3. Edit `config.lua` to tune camera sway, offsets, FOV, noise, and HUD fields.
4. Restart the resource or server.

## Controls

Normal mouse look remains available. The camera-switch and cinematic camera controls are suppressed while the resource is enabled. Set `Config.AllowToggleCommand = true` to enable the `/bodycam` toggle command.

## Notes

The custom scripted camera is designed to feel like a body-mounted camera rather than a static GTA first-person view. It does not lock the cursor or consume look controls. Test alongside other camera resources because competing scripts may also call `RenderScriptCams`.
