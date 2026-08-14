local enabled = Config.EnabledByDefault
local nuiReady = false
local playerActive = false
local camera = nil
local cameraYaw = 0.0
local cameraPitch = 0.0
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

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function destroyCamera()
    if camera and DoesCamExist(camera) then
        RenderScriptCams(false, true, 250, true, true)
        DestroyCam(camera, false)
    end
    camera = nil
end

local function ensureCamera()
    if camera and DoesCamExist(camera) then return camera end
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    return camera
end

local function updateHeadCamera()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local cam = ensureCamera()
    local offsetX = vehicle ~= 0 and Config.VehicleCameraOffsetX or Config.CameraOffsetX
    local offsetY = vehicle ~= 0 and Config.VehicleCameraOffsetY or Config.CameraOffsetY
    local offsetZ = vehicle ~= 0 and Config.VehicleCameraOffsetZ or Config.CameraOffsetZ
    local head = GetPedBoneCoords(ped, 31086, offsetX, offsetY, offsetZ)
    local lookX = GetDisabledControlNormal(0, 1)
    local lookY = GetDisabledControlNormal(0, 2)
    cameraYaw = cameraYaw - lookX * Config.MouseSensitivity
    cameraPitch = clamp(cameraPitch - lookY * Config.MouseSensitivity, -Config.VerticalLookLimit, Config.VerticalLookLimit)
    SetEntityHeading(ped, cameraYaw)
    SetCamCoord(cam, head.x, head.y, head.z)
    SetCamRot(cam, cameraPitch, 0.0, cameraYaw, 2)
    SetCamFov(cam, vehicle ~= 0 and Config.VehicleFirstPersonFov or Config.FirstPersonFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    AttachCamToPedBone(cam, ped, GetPedBoneIndex(ped, 31086), offsetX, offsetY, offsetZ, true)
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
    local label = weaponLabels[hash] or 'UNARMED'
    local name = hash == `WEAPON_UNARMED` and 'unarmed' or string.lower(label:gsub('[^%w]+', '_'))
    local magazine, reserve = 0, 0
    if hash ~= `WEAPON_UNARMED` then
        local ok, clip = GetAmmoInClip(ped, hash)
        magazine = ok and clip or 0
        reserve = GetAmmoInPedWeapon(ped, hash)
    end
    if GetResourceState('ox_inventory') == 'started' then
        local ok, current = pcall(function() return exports.ox_inventory:getCurrentWeapon() end)
        if ok and type(current) == 'table' then
            name = current.name or name
            label = current.label or label
            magazine = type(current.ammo) == 'number' and current.ammo or magazine
        end
    end
    return { label = label, name = name, magazine = magazine, reserve = reserve, armed = hash ~= `WEAPON_UNARMED` }
end

local function updateHud()
    if not playerActive then return end
    local ped = PlayerPedId()
    weaponState = readWeaponData(ped)
    SendNUIMessage({ action = 'update', visible = enabled and Config.HudEnabled and playerActive, title = Config.HudTitle, color = Config.HudColor, accent = Config.HudAccent, unit = Config.UnitIdPrefix .. '-' .. GetPlayerServerId(PlayerId()), street = getStreet(ped), direction = compass(GetEntityHeading(ped)), timestamp = os.date('!%Y-%m-%d %H:%M:%S UTC'), noise = Config.HudNoise, glitch = Config.HudGlitch, weapon = weaponState })
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
            if not playerActive then destroyCamera() end
        end
        Wait(250)
    end
end)

CreateThread(function()
    while true do
        if enabled and playerActive then
            updateHeadCamera()
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

RegisterCommand('bodycam_offset', function(_, args)
    local x = tonumber(args[1]) or Config.CameraOffsetX
    local y = tonumber(args[2]) or Config.CameraOffsetY
    local z = tonumber(args[3]) or Config.CameraOffsetZ
    Config.CameraOffsetX, Config.CameraOffsetY, Config.CameraOffsetZ = x, y, z
    print(('[bodycam] Offset set to X %.3f, Y %.3f, Z %.3f'):format(x, y, z))
end, false)

RegisterCommand('bodycam_reset', function()
    Config.CameraOffsetX, Config.CameraOffsetY, Config.CameraOffsetZ = 0.0, 0.18, 0.12
    cameraYaw = GetEntityHeading(PlayerPedId())
    cameraPitch = 0.0
    print('[bodycam] Camera offset reset')
end, false)

if Config.AllowToggleCommand then
    RegisterCommand(Config.ToggleCommand, function()
        enabled = not enabled
        SetNuiFocus(false, false)
        setHudVisible(enabled and playerActive)
        if not enabled then destroyCamera() end
    end, false)
end

AddEventHandler('playerSpawned', function()
    CreateThread(function()
        Wait(750)
        cameraYaw = GetEntityHeading(PlayerPedId())
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
        destroyCamera()
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'visibility', visible = false, active = false })
    end
end)
