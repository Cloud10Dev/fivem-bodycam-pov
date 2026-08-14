local enabled = Config.EnabledByDefault
local nuiVisible = Config.HudEnabled
local camera = nil

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function ensureCamera()
    if camera and DoesCamExist(camera) then return camera end
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    return camera
end

local function destroyCamera()
    if camera and DoesCamExist(camera) then
        RenderScriptCams(false, true, 250, true, true)
        DestroyCam(camera, false)
    end
    camera = nil
end

local function updateBodycamCamera()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local cam = ensureCamera()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local offset = vehicle ~= 0 and Config.VehicleCameraOffset or Config.CameraOffset
    local time = GetGameTimer() / 1000.0
    local movement = clamp(GetEntitySpeed(ped) / 8.0, 0.0, 1.0)
    local sway = Config.CameraSway and math.sin(time * 2.1) * Config.BreathingAmount or 0.0
    local shake = 0.0

    if vehicle ~= 0 then
        shake = math.sin(time * 18.0) * Config.VehicleShakeAmount * clamp(GetEntitySpeed(vehicle) / 25.0, 0.0, 1.0)
    elseif IsPedSprinting(ped) then
        shake = math.sin(time * 13.0) * Config.RunShakeAmount
    elseif movement > 0.05 then
        shake = math.sin(time * 9.0) * Config.WalkShakeAmount
    end

    local position = GetOffsetFromEntityInWorldCoords(ped, offset.x + shake, offset.y, offset.z + sway)
    local heading = GetEntityHeading(ped)
    SetCamCoord(cam, position.x, position.y, position.z)
    SetCamRot(cam, sway * 10.0, shake * 8.0, heading, 2)
    SetCamFov(cam, Config.FirstPersonFov)
    AttachCamToEntity(cam, ped, offset.x + shake, offset.y, offset.z + sway, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

local function disableOnlyCameraSwitching()
    for _, control in ipairs({0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 68, 69, 70, 91, 92, 99, 100, 114, 115, 116, 117, 118, 121, 122, 123, 199, 200}) do
        DisableControlAction(0, control, true)
    end
end

local function streetName(ped)
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash)
end

local function compassDirection(heading)
    local directions = {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}
    return directions[(math.floor((heading + 22.5) / 45.0) % 8) + 1]
end

local function updateHud()
    if not nuiVisible then return end
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local speed = vehicle ~= 0 and math.floor(GetEntitySpeed(vehicle) * 3.6 + 0.5) or 0
    local movement = clamp(GetEntitySpeed(ped) / 8.0, 0.0, 1.0)
    SendNUIMessage({
        action = 'update',
        visible = enabled and Config.HudEnabled,
        title = Config.HudTitle,
        color = Config.HudColor,
        unit = Config.ShowUnitId and (Config.UnitIdPrefix .. '-' .. GetPlayerServerId(PlayerId())) or '',
        street = Config.ShowStreet and streetName(ped) or '',
        speed = Config.ShowVehicleSpeed and speed or nil,
        direction = compassDirection(GetEntityHeading(ped)),
        timestamp = os.date('!%Y-%m-%d %H:%M:%S UTC'),
        noise = Config.HudNoise,
        movement = movement,
        vehicle = vehicle ~= 0
    })
end

CreateThread(function()
    while true do
        if enabled then
            updateBodycamCamera()
            SetCinematicModeActive(false)
            if Config.HideReticle then HideHudComponentThisFrame(14) end
            Wait(0)
        else
            destroyCamera()
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        if enabled then
            disableOnlyCameraSwitching()
            Wait(0)
        else
            Wait(500)
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
        SendNUIMessage({ action = 'visibility', visible = enabled and Config.HudEnabled })
        if not enabled then destroyCamera() end
    end, false)
end

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SendNUIMessage({ action = 'visibility', visible = enabled and Config.HudEnabled })
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then destroyCamera() end
end)
