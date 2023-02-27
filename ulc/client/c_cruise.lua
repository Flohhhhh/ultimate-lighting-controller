print("[ULC]: Cruise lights Loaded")

-- 1 disabled, 0 enabled
local sbState = 1

-- 0 on, 1 off
local function setCruiseLights(newState)
    sbState = newState

    for _, v in pairs(MyVehicleConfig.steadyBurnConfig.sbExtras) do
            SetStageByExtra(v, newState, false, true) -- i want to remove checks from this, will need to check if steady burns are already in correct state.
        local key = GetKeyForVehicleExtra(vehicle, v)
        TriggerEvent('ulc:SetStage', key, newState, false)
    end
end

CreateThread(function()
    while true do
        if MyVehicle then
            TriggerEvent('ulc:CheckCruise', false)
        end
        Wait(Config.SteadyBurnSettings.delay * 1000)
    end
end)

--TODO: disable when lights are on, enable when lights are off

AddEventHandler('ulc:lightsOn', function()
    --print("Lights on")
    if MyVehicle and (MyVehicleConfig.steadyBurnConfig.disableWithLights or false) then
        setCruiseLights(1)
    end
end)

AddEventHandler('ulc:lightsOff', function()
    --print("Lights off")
    if MyVehicle and (MyVehicleConfig.steadyBurnConfig.disableWithLights or false) then
        TriggerEvent('ulc:CheckCruise', false)
    end
end)

AddEventHandler('ulc:CheckCruise', function()
    if not MyVehicle then return end

    if MyVehicleConfig.steadyBurnConfig.forceOn then

        if sbState == 0 then return end
        if Lights and MyVehicleConfig.steadyBurnConfig.disableWithLights then return end
        setCruiseLights(0)

    elseif MyVehicleConfig.steadyBurnConfig.useTime then

        local isTime = GetClockHours() > Config.SteadyBurnSettings.nightStartHour or GetClockHours() < Config.SteadyBurnSettings.nightEndHour
        if isTime then
            -- if lights are already on do nothing
            if sbState == 0 then return end
            if Lights and MyVehicleConfig.steadyBurnConfig.disableWithLights then return end
            setCruiseLights(0)
        else
            -- if already off do nothing
            if sbState == 1 then return end
            setCruiseLights(1)
        end

    end
end)