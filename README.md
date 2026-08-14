# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with an orange/red HUD and weapon telemetry.

## Latest fixes

- Hard-locks native first person every frame and blocks camera switching without disabling mouse look.
- Uses a more FPS-like FOV of 88 rather than an extreme wide-angle value that can make weapons look small.
- Keeps the native GTA first-person weapon camera instead of attaching a custom camera inside the body.
- Adds visible RGB-split glitch bursts to HUD text and telemetry lines, not only the background.
- Polls weapon state every 50 ms so ox_inventory hotbar changes update immediately.
- Uses `exports.ox_inventory:getCurrentWeapon()` when available and falls back to GTA weapon/ammo natives.
- Adds `dependency 'ox_inventory'` so resource startup order is explicit.
- No speed indicator and no center crosshair.

## Installation

```cfg
ensure ox_inventory
ensure fivem-bodycam-pov
```

Restart after updating:

```text
restart fivem-bodycam-pov
```

If weapon data still remains `UNARMED`, verify the weapon is actually equipped rather than only present in the hotbar, and check the client F8 console for ox_inventory export errors. The resource intentionally uses the current equipped weapon, because a hotbar slot is not necessarily the active GTA weapon.

The camera approach follows common FiveM first-person resources that force view mode 4 and tune FOV, while weapon presentation remains native to GTA for proper hands/weapon alignment. [web:2][web:70]
