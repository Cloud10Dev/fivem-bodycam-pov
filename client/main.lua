local enabled = Config.EnabledByDefault
local nuiReady = false
local playerActive = false
local weaponState = nil

local weaponLabels = {
    [`WEAPON_PISTOL`] = 'PISTOL', [`WEAPON_COMBATPISTOL`] = 'COMBAT PISTOL', [`WEAPON_APPISTOL`] = 'AP PISTOL', [`WEAPON_PISTOL_MK2`] = 'PISTOL MK II',
    [`WEAPON_SMG`] = 'SMG', [`WEAPON_MICROSMG`] = 'MICRO SMG', [`WEAPON_ASSAULTRIFLE`] = 'ASSAULT RIFLE', [`WEAPON_CARBINERIFLE`] = 'CARBINE RIFLE',
    [`WEAPON_SPECIALCARBINE`] = 'SPECIAL CARBINE', [`WEAPON_PUMPSHOTGUN`] = 'PUMP SHOTGUN', [`WEAPON_SAWNOFF_SHOTGUN`] = 'SAWED-OFF',
    [`WEAPON_SNIPERRIFLE`] = 'SNIPER RIFLE', [`WEAPON_HEAVYSNIPER`] = 'HEAVY SNIPER', [`WEAPON_KNIFE`] = 'KNIFE', [`WEAPON_BAT`] = 'BAT', [`WEAPON_UNARMED`] = 'UNARMED'
}

local function isGameplayActive()
    local ped = PlayerPedId()
    return nuiReady and DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPauseMenuActive() and not IsScreenFadedOut() and not IsPlayerSwitchInProgress() and NetworkIsPlayerActive(PlayerId())
end

local function setHudVisible(visible)
    SendNUIMessage({ action = 'visibility', visible = visible and Config.HudEnabled, active = visible })
end

local function forceFirstPerson()
    local inVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
    SetFollowPedCamViewMode(4)
    SetFollowVehicleCamViewMode(4)
    SetCamViewModeForContext(GetCamActiveViewModeContext(), 4)
    SetCinematicModeActive(false)
    SetGameplayCamRelativePitch(inVehicle and Config.VehicleRelativePitch or Config.CameraRelativePitch, 1.0)
    SetGameplayCamRelativeHeading(inVehicle and Config.VehicleRelativeHeading or Config.CameraRelativeHeading)
    SetGameplayCamFov(inVehicle and Config.VehicleFirstPersonFov or Config.FirstPersonFov)
end

local function blockCameraSwitchOnly()
    DisableControlAction(0, 0, true)
    DisableControlAction(0, 199, true)
    DisableControlAction(0, 200, true)
end

local function getStreet(ped)
    local coords = GetEntityCoords(ped)
    local hash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(hash)
end

local function compass(heading)
    local names = {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}
    return names[(math.floor((heading + 22.5) / 45.0) % 8) + 1]
end

local function readWeaponData(ped)
    local hash = GetSelectedPedWeapon(ped)
    local stateWeapon = LocalPlayer and LocalPlayer.state and LocalPlayer.state.currentWeapon or nil
    local label = weaponLabels[hash] or 'UNARMED'
    local name = hash == `WEAPON_UNARMED` and 'unarmed' or string.lower(label:gsub('[^%w]+', '_'))
    local magazine, reserve = 0, 0
    if hash ~= `WEAPON_UNARMED` then
        local ok, clip = GetAmmoInClip(ped, hash)
        magazine = ok and clip or 0
        reserve = GetAmmoInPedWeapon(ped, hash)
    end
    if type(stateWeapon) == 'table' then
        name = stateWeapon.name or stateWeapon.weapon or name
        label = stateWeapon.label or label
        if type(stateWeapon.ammo) == 'number' then magazine = stateWeapon.ammo end
        if stateWeapon.metadata then reserve = stateWeapon.metadata.ammo or stateWeapon.metadata.clip or reserve end
    elseif type(stateWeapon) == 'string' then
        name = stateWeapon
    end
    if GetResourceState('ox_inventory') == 'started' then
        local ok, current = pcall(function() return exports.ox_inventory:getCurrentWeapon() end)
        if ok and type(current) == 'table' then
            name = current.name or name
            label = current.label or label
            if type(current.ammo) == 'number' then magazine = current.ammo end
            if type(current.metadata) == 'table' then reserve = current.metadata.ammo or current.metadata.clip or reserve end
        end
    end
    local armed = hash ~= `WEAPON_UNARMED` or (type(stateWeapon) == 'table' and stateWeapon.name ~= nil) or (type(stateWeapon) == 'string' and stateWeapon ~= 'unarmed')
    return { label = label, name = name, magazine = magazine, reserve = reserve, armed = armed }
end

local function updateHud()
    if not playerActive then return end
    local ped = PlayerPedId()
    weaponState = readWeaponData(ped)
    SendNUIMessage({ action = 'update', visible = enabled and Config.HudEnabled and playerActive, title = Config.HudTitle, color = Config.HudColor, accent = Config.HudAccent, unit = Config.ShowUnitId and (Config.UnitIdPrefix .. '-' .. GetPlayerServerId(PlayerId())) or '', street = Config.ShowStreet and getStreet(ped) or '', direction = compass(GetEntityHeading(ped)), timestamp = os.date('!%Y-%m-%d %H:%M:%S UTC'), noise = Config.HudNoise, glitch = Config.HudGlitch, weapon = Config.ShowWeapon and weaponState or nil })
end

CreateThread(function()
    Wait(1000)
    nuiReady = true
    SetNuiFocus(false, false)
    setHudVisible(false)
    while true do
        local active = isGameplayActive()
        if active ~= playerActive then
            playerActive = active
            setHudVisible(enabled and playerActive)
        end
        Wait(250)
    end
end)

CreateThread(function()
    while true do
        if enabled and playerActive then
            forceFirstPerson()
            blockCameraSwitchOnly()
            if Config.HideReticle then HideHudComponentThisFrame(14) end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while true do
        updateHud()
        Wait(Config.HudUpdateInterval)
    end
end)

if Config.AllowToggleCommand then
    RegisterCommand(Config.ToggleCommand, function()
        enabled = not enabled
        SetNuiFocus(false, false)
        setHudVisible(enabled and playerActive)
    end, false)
end

AddEventHandler('playerSpawned', function()
    CreateThread(function()
        Wait(750)
        playerActive = isGameplayActive()
        setHudVisible(enabled and playerActive)
    end)
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    setHudVisible(false)
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'visibility', visible = false, active = false })
    end
end)
