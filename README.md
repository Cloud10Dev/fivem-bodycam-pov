# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with an orange/red HUD and adjustable head-mounted camera.

## Camera placement fix

The previous version used an entity-relative offset that could place the camera inside the torso. This version attaches the camera to the actual head bone index using `AttachCamToPedBone`, with a positive depth offset that places the camera just outside the face/head area. FiveM distinguishes between a bone ID and a bone index, so the resource resolves the head index with `GetPedBoneIndex` before attaching. [web:146][web:161]

Default values:

```lua
Config.CameraOffsetX = 0.0
Config.CameraOffsetY = 0.18
Config.CameraOffsetZ = 0.12
```

If the view is still too far inside or outside, use the live command:

```text
bodycam_offset 0.00 0.12 0.10
bodycam_offset 0.00 0.25 0.15
bodycam_reset
```

The camera retains normal mouse look, aiming, running, jumping, shooting, and movement. Only camera switching and pause/cinematic controls are blocked.
