print("[ULC]: Brake Patterns Loaded")
local extraStates = {}
local braking = false
local realBrakeThreshold = 3 -- below this speed vehicle is always considered to be braking

local function GetPreviousStateByExtra(extra)
    for _, v in pairs(extraStates) do
        if extra == v.extra then
            return v.state
        end
    end
end

local function enableBrakeExtras()
    for _, v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local extraState = {
            extra = v,
            state = IsVehicleExtraTurnedOn(MyVehicle, v)
        }
        table.insert(extraStates, extraState)
        ULC:SetStage(v, 0, false, true)
    end
end

local function disableBrakeExtras()
    for _, v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local prevState = GetPreviousStateByExtra(v)
        if not prevState then
            ULC:SetStage(v, 1, false, true)
        end
    end
end

local function shouldUseRealBrakeMode()
    return (MyVehicleConfig.brakeConfig.speedThreshold or 3) <= realBrakeThreshold
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

        --if speed < realBrakeThreshold and shouldUseRealBrakeMode() and not (IsControlPressed(0, 71) or IsControlPressed(0, 72)) then
        if speed < realBrakeThreshold and shouldUseRealBrakeMode() and not IsControlPressed(0, 72) then
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
 
    extraStates = {}

    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        if GetVehicleCurrentGear(MyVehicle) == 0 then return end -- disable while reversing
        braking = true

        local speed = GetVehicleSpeedConverted(MyVehicle)

        -- if using real brakes always enable
        if shouldUseRealBrakeMode() or speed > (MyVehicleConfig.brakeConfig.speedThreshold or 3) then
            enableBrakeExtras()
        end
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = true
    })
end)

RegisterCommand('-ulc:brakePattern', function()
    braking = false
    --local passed, vehConfig = GetVehicleFromConfig(vehicle)
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        local speed = GetEntitySpeed(vehicle)
        if shouldUseRealBrakeMode() and speed < realBrakeThreshold then return end

        disableBrakeExtras()
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = false
    })
end)

RegisterKeyMapping('+ulc:brakePattern', 'Enable Brake Pattern (Hold)', 'keyboard', 's')