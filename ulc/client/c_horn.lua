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

    if MyVehicle and MyVehicleConfig.hornConfig.useHorn then
        for _, extra in ipairs(MyVehicleConfig.hornConfig.hornExtras) do

            local extraState = {
                extra = extra,
                state = IsVehicleExtraTurnedOn(MyVehicle, extra)
            }
            table.insert(extraStates, extraState)
            --print("Extra: " .. extraState.extra .. " start state = " .. tostring(extraState.state))
            ULC:SetStage(extra, 0, false, true)
        end
    end
end)

RegisterCommand('-ulc:horn', function()

        if MyVehicle and MyVehicleConfig.hornConfig.useHorn then
            for k, extra in ipairs(MyVehicleConfig.hornConfig.hornExtras) do
                local prevState = GetPreviousStateByExtra(extra)
                --print("Extra " .. extra .. " previous state = " ..  tostring(prevState))
                if not prevState then
                    ULC:SetStage(extra, 1, false, true)
                end
            end
        end
end)

RegisterKeyMapping('+ulc:horn', 'Toggle Horn Extras', 'keyboard', 'e')