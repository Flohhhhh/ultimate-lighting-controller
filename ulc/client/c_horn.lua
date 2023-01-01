print("[ULC]: Horn Extras Loaded")

local extraStates = {}

local function GetPreviousStateByExtra(extra)
    for k, v in pairs(extraStates) do
        --print(v.extra, v.state)
        if extra == v.extra then
            --print('Found state of : ' .. tostring(v.state) .. ' for extra ' .. extra)
            return v.state
        end
    end
end

RegisterCommand('+ulc:horn', function()
    --print('horn')
    extraStates = {}
    local vehicle = GetVehiclePedIsIn(PlayerPedId())

    if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
        local passed, vehConfig = GetVehicleFromConfig(vehicle)
        if passed and vehConfig.hornConfig.useHorn then
            for k, extra in ipairs(vehConfig.hornConfig.hornExtras) do

                local extraState = {
                    extra = extra,
                    state = IsVehicleExtraTurnedOn(vehicle, extra)
                }
                table.insert(extraStates, extraState)
                --print("Extra: " .. extraState.extra .. " start state = " .. tostring(extraState.state))
                SetStageByExtra(extra, 0, false)
            end
        end
    end
end)

RegisterCommand('-ulc:horn', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then

        local passed, vehConfig = GetVehicleFromConfig(vehicle)

        if passed and vehConfig.hornConfig.useHorn then
            for k, extra in ipairs(vehConfig.hornConfig.hornExtras) do
                
                local prevState = GetPreviousStateByExtra(extra)
                --print("Extra " .. extra .. " previous state = " ..  tostring(prevState))
                if not prevState then
                    SetStageByExtra(extra, 1, false)
                end
            end
        end
    end
end)

RegisterKeyMapping('+ulc:horn', 'Toggle Horn Extras', 'keyboard', 'e')