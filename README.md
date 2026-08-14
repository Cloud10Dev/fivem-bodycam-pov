# FiveM Bodycam POV

A standalone FiveM resource that forces players into first-person view and displays a lightweight bodycam-style HUD. It has no framework or dependency requirements.

## Features

- Forces first-person pedestrian and vehicle camera modes.
- Blocks camera-switch and cinematic camera controls while enabled.
- Configurable FOV and camera offsets.
- NUI overlay with REC indicator, unit ID, street, speed, and UTC timestamp.
- Optional reticle hiding.
- Optional toggle command, disabled by default so the server can enforce the mode.

## Installation

1. Put this folder in your server's `resources` directory.
2. Add `ensure fivem-bodycam-pov` to `server.cfg`.
3. Edit `config.lua` to tune the experience.
4. Restart the resource or server.

FiveM/GTA camera natives can vary slightly by game build and by other camera resources. Test alongside police, cinematic, or custom-camera scripts. This project includes no third-party assets.
