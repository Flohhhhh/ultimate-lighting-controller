--print("[ULC]: Horn Extras Loaded")

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

function SetHornExtras(newState)
    -- print('SetHornExtras: ' .. newState)
    if newState == 0 then
        for _, extra in pairs(MyVehicleConfig.hornConfig.hornExtras) do
            local extraState = {
                extra = extra,
                state = IsVehicleExtraTurnedOn(MyVehicle, extra)
            }
            table.insert(extraStates, extraState)
            ULC:SetStage(extra, 0, false, true, false, false, true, false)
        end
        if not MyVehicleConfig.hornConfig.disableExtras then return end
        for _, extra in pairs(MyVehicleConfig.hornConfig.disableExtras) do
            local extraState = {
                extra = extra,
                state = IsVehicleExtraTurnedOn(MyVehicle, extra)
            }
            table.insert(extraStates, extraState)
            ULC:SetStage(extra, 1, false, true, false, false, true, false)
        end
    elseif newState == 1 then
        for _, extra in pairs(MyVehicleConfig.hornConfig.hornExtras) do
            local prevState = GetPreviousStateByExtra(extra)
            if not prevState then
                ULC:SetStage(extra, 1, false, true, false, false, true, false)
            end
        end
        if not MyVehicleConfig.hornConfig.disableExtras then return end
        for _, extra in pairs(MyVehicleConfig.hornConfig.disableExtras) do
            local prevState = GetPreviousStateByExtra(extra)
            if prevState then
                ULC:SetStage(extra, 0, false, true, false, false, true, false)
            end
        end
    end
end

RegisterCommand('+ulc:horn', function()
    --print('horn')
    extraStates = {}

    if MyVehicle and MyVehicleConfig.hornConfig.useHorn then
        SetHornExtras(0)
    end
end)

RegisterCommand('-ulc:horn', function()
    if MyVehicle and MyVehicleConfig.hornConfig.useHorn then
        SetHornExtras(1)
    end
end)

RegisterKeyMapping('+ulc:horn', 'ULC: Activate Horn Extras', 'keyboard', 'e')
