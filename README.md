# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with a red-orange telemetry HUD and optional ox_inventory weapon display.

## Features

- Native first-person head/eye placement with a stronger FOV of 100 for a pronounced wide-angle/fisheye feel.
- Mouse look preserved; camera switching remains blocked.
- Red/orange bodycam HUD with scanlines, vignette, noise, framing corners, and subtle global glitch lines.
- No center crosshair and no speed display.
- Bottom-right weapon panel with weapon name, icon-style identifier, magazine ammo, and reserve ammo.

## ox_inventory

The client reads the currently equipped weapon through the ox_inventory export when ox_inventory is running, then falls back to GTA weapon natives if it is unavailable. Ensure ox_inventory starts before this resource:

```cfg
ensure ox_inventory
ensure fivem-bodycam-pov
```

The ox_inventory project provides weapon and item inventory functionality and exposes the current weapon data used by this resource. [web:47][web:46]

## Installation

1. Put the resource in your server's `resources` directory.
2. Add the `ensure` lines above to `server.cfg`.
3. Restart the resource.
4. Use `/bodycam` to toggle the view.

Tune `Config.FirstPersonFov` between 90 and 110 to adjust the fisheye strength. Very high values can cause distortion and motion discomfort.
