local enabled = Config.EnabledByDefault
local nuiVisible = Config.HudEnabled

local function setFirstPerson()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    SetFollowPedCamViewMode(4)
    SetFollowVehicleCamViewMode(4)
    SetCamViewModeForContext(GetCamActiveViewModeContext(), 4)
    SetGameplayCamRelativePitch(0.0, 1.0)
    SetGameplayCamRelativeHeading(0.0)
    SetFirstPersonAimCamRelativeHeadingLimitsThisUpdate(-20.0, 20.0)
    SetFirstPersonAimCamRelativePitchLimitsThisUpdate(-30.0, 30.0)
end

local function disableThirdPersonControls()
    for _, control in ipairs({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 68, 69, 70, 91, 92, 99, 100, 114, 115, 116, 117, 118, 121, 122, 123, 199, 200}) do
        DisableControlAction(0, control, true)
    end
end

local function streetName(ped)
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash)
end

local function updateHud()
    if not nuiVisible then return end
    local ped = PlayerPedId()
    local speed = 0
    if IsPedInAnyVehicle(ped, false) then
        speed = math.floor(GetEntitySpeed(ped) * 3.6 + 0.5)
    end
    SendNUIMessage({
        action = 'update',
        visible = enabled and Config.HudEnabled,
        title = Config.HudTitle,
        color = Config.HudColor,
        unit = Config.UnitIdPrefix .. '-' .. GetPlayerServerId(PlayerId()),
        street = Config.ShowStreet and streetName(ped) or '',
        speed = Config.ShowVehicleSpeed and speed or nil,
        timestamp = os.date('!%Y-%m-%d %H:%M:%S UTC')
    })
end

CreateThread(function()
    while true do
        if enabled then
            setFirstPerson()
            SetCinematicModeActive(false)
            if Config.HideReticle then HideHudComponentThisFrame(14) end
            Wait(Config.EnforceInterval)
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        if enabled then
            disableThirdPersonControls()
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
    end, false)
end

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SendNUIMessage({ action = 'visibility', visible = enabled and Config.HudEnabled })
end)
