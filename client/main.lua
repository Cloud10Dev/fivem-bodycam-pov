local enabled = Config.EnabledByDefault
local nuiReady = false

local function setHudVisible(visible)
    if not Config.HudEnabled then visible = false end
    SendNUIMessage({ action = 'visibility', visible = visible })
end

local function forceFirstPerson()
    SetFollowPedCamViewMode(4)
    SetFollowVehicleCamViewMode(4)
    SetCamViewModeForContext(GetCamActiveViewModeContext(), 4)
    SetCinematicModeActive(false)
end

local function disableCameraSwitchOnly()
    for _, control in ipairs({0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 68, 69, 70, 91, 92, 99, 100, 114, 115, 116, 117, 118, 121, 122, 123, 199, 200}) do
        DisableControlAction(0, control, true)
    end
end

local function getStreet(ped)
    local coords = GetEntityCoords(ped)
    local hash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(hash)
end

local function direction(heading)
    local names = {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}
    return names[(math.floor((heading + 22.5) / 45.0) % 8) + 1]
end

local function updateHud()
    if not nuiReady then return end
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local speed = vehicle ~= 0 and math.floor(GetEntitySpeed(vehicle) * 3.6 + 0.5) or 0
    SendNUIMessage({
        action = 'update', visible = enabled and Config.HudEnabled,
        title = Config.HudTitle, color = Config.HudColor,
        unit = Config.ShowUnitId and (Config.UnitIdPrefix .. '-' .. GetPlayerServerId(PlayerId())) or '',
        street = Config.ShowStreet and getStreet(ped) or '',
        speed = Config.ShowVehicleSpeed and speed or 0,
        direction = direction(GetEntityHeading(ped)),
        timestamp = os.date('!%Y-%m-%d %H:%M:%S UTC'),
        noise = Config.HudNoise, moving = GetEntitySpeed(ped) > 0.5,
        vehicle = vehicle ~= 0
    })
end

CreateThread(function()
    Wait(1000)
    nuiReady = true
    SetNuiFocus(false, false)
    setHudVisible(enabled)
end)

CreateThread(function()
    while true do
        if enabled then
            forceFirstPerson()
            if Config.HideReticle then HideHudComponentThisFrame(14) end
            disableCameraSwitchOnly()
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
        setHudVisible(enabled)
    end, false)
end

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    CreateThread(function()
        Wait(1000)
        nuiReady = true
        setHudVisible(enabled)
    end)
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'visibility', visible = false })
    end
end)
