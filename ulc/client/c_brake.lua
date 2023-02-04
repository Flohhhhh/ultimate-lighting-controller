print("[ULC]: Brake Patterns Loaded")
local extraStates = {}
local braking = false
local realBrakeThreshold = 3 -- below this speed vehicle is always considered to be braking
local realBrakeMode = false

local function GetPreviousStateByExtra(extra)
    for k, v in pairs(extraStates) do
        if extra == v.extra then
            return v.state
        end
    end
end

local function enableBrakeExtras()
    for k,v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local extraState = {
            extra = v,
            state = IsVehicleExtraTurnedOn(vehicle, v)
        }
        table.insert(extraStates, extraState)
        SetStageByExtra(v, 0, false)
    end
end

local function disableBrakeExtras()
    for k,v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local prevState = GetPreviousStateByExtra(v)
        if not prevState then
            SetStageByExtra(v, 1, false)
        end
    end
end

-- if MyVehicleConfig.brakeConfig.speedThreshold <= realBrakeThreshold then
--     realBrakeMode = true
-- end

local function shouldUseRealBrakeMode()

    return MyVehicleConfig.brakeConfig.speedThreshold <= realBrakeThreshold
end

CreateThread(function()
    local sleep = 250
    while true do Wait(sleep)
        if not Loaded then goto continue end
        if not MyVehicle then goto continue end
        if braking then goto continue end

        local speed = GetEntitySpeed(MyVehicle)
        if not shouldUseRealBrakeMode() then sleep = 1000 goto continue end
        sleep = 250

        if speed < realBrakeThreshold and shouldUseRealBrakeMode() and not (IsControlPressed(0, 71) or IsControlPressed(0, 72)) then
            enableBrakeExtras()
            SendNUIMessage({
                type = 'toggleBrakeIndicator',
                state = true
            })
        else
            disableBrakeExtras()
            SendNUIMessage({
                type = 'toggleBrakeIndicator',
                state = false
            })
        end

        ::continue::
    end
end)

RegisterCommand('+ulc:brakePattern', function()
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    extraStates = {}

    --local passed, vehConfig = GetVehicleFromConfig(vehicle)
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        if GetVehicleCurrentGear(vehicle) == 0 then return end -- disable while reversing
        braking = true
        if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
            local speed = GetVehicleSpeedConverted(vehicle)

            -- if using real brakes always enable

            if shouldUseRealBrakeMode() or speed > MyVehicleConfig.brakeConfig.speedThreshold then
                enableBrakeExtras()
                --[[ for k,v in pairs(vehConfig.brakeConfig.brakeExtras) do
                    local extraState = {
                        extra = v,
                        state = IsVehicleExtraTurnedOn(vehicle, v)
                    }
                    table.insert(extraStates, extraState)
                    SetStageByExtra(v, 0, false)
                end
                ]]
            end

        end
        SendNUIMessage({
            type = 'toggleBrakeIndicator',
            state = true
        })
    end
end)

RegisterCommand('-ulc:brakePattern', function()
    braking = false
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    --local passed, vehConfig = GetVehicleFromConfig(vehicle)
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
            local speed = GetEntitySpeed(vehicle)
            if shouldUseRealBrakeMode() and speed < realBrakeThreshold then return end
            disableBrakeExtras()
            --local speed = GetVehicleSpeedConverted(vehicle)
            --[[for k,v in pairs(vehConfig.brakeConfig.brakeExtras) do
                local prevState = GetPreviousStateByExtra(v)
                if not prevState then
                    SetStageByExtra(v, 1, false)
                end
            end]]
        end
        SendNUIMessage({
            type = 'toggleBrakeIndicator',
            state = false
        })
    end
end)

RegisterKeyMapping('+ulc:brakePattern', 'Enable Brake Pattern (Hold)', 'keyboard', 's')