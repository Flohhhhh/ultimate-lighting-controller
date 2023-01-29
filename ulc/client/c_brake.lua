print("[ULC]: Brake Patterns Loaded")
local extraStates = {}

local function GetPreviousStateByExtra(extra)
    for k, v in pairs(extraStates) do
        if extra == v.extra then
            return v.state
        end
    end
end

RegisterCommand('+ulc:brakePattern', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    extraStates = {}

    local passed, vehConfig = GetVehicleFromConfig(vehicle)
    if passed and vehConfig.brakeConfig.useBrakes then
        if GetVehicleCurrentGear(vehicle) == 0 then return end
        if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
            local speed = GetVehicleSpeedConverted(vehicle)
            if speed > Config.BrakeSettings.speedThreshold then
                for k,v in pairs(vehConfig.brakeConfig.brakeExtras) do
                    local extraState = {
                        extra = v,
                        state = IsVehicleExtraTurnedOn(vehicle, v)
                    }
                    table.insert(extraStates, extraState)
                    SetStageByExtra(v, 0, false)
                end
            end
        end
        SendNUIMessage({
            type = 'toggleBrakeIndicator',
            state = true
        })
    end
end)

RegisterCommand('-ulc:brakePattern', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local passed, vehConfig = GetVehicleFromConfig(vehicle)
    if passed and vehConfig.brakeConfig.useBrakes then
        if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
            -- local speed = GetVehicleSpeedConverted(vehicle)
            for k,v in pairs(vehConfig.brakeConfig.brakeExtras) do
                local prevState = GetPreviousStateByExtra(v)
                if not prevState then
                    SetStageByExtra(v, 1, false)
                end
            end
        end
        SendNUIMessage({
            type = 'toggleBrakeIndicator',
            state = false
        })
    end
end)

RegisterKeyMapping('+ulc:brakePattern', 'Enable Brake Pattern (Hold)', 'keyboard', 's')