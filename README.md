# FiveM Bodycam POV

Standalone forced first-person bodycam resource for FiveM with an orange/red HUD and ox_inventory weapon telemetry.

## Stability fixes

- Restores full mouse look, vertical camera movement, aiming, shooting, sprinting, jumping, and movement controls.
- Only the camera-switch and pause/cinematic controls are blocked.
- First-person enforcement runs only after the player is active and spawned.
- HUD is hidden during loading, pause, character selection, screen fades, and before the player is fully active.
- Reads ox_inventory equipped weapon state from the active item/state and falls back to GTA natives for weapon and ammo values.

## ox_inventory hotkeys

Hotkeys `1`, `2`, `3`, `4`, and `5` are handled by ox_inventory. This resource reads the weapon after ox_inventory equips it; merely having an item in a hotbar slot is not enough. The slot must equip the item and create an active weapon state.

```cfg
ensure ox_inventory
ensure fivem-bodycam-pov
```

## Restart

```text
restart fivem-bodycam-pov
```

If vertical look remains unavailable, check the FiveM mouse input setting. Some FiveM mouse bugs are caused by the client `profile_mousetype` setting; changing it to `0` has been reported as a workaround. [web:102]

If weapons remain undetected, inspect the client F8 console and confirm that ox_inventory is running before this resource and that the hotkey actually equips the weapon. ox_inventory manages weapons as inventory items and maintains current-weapon state separately from ordinary hotbar contents. [web:46][web:95]
