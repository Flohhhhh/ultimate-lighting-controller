print("[ULC] Brake Patterns Loaded")
local realBrakeThreshold = 3 -- below this speed vehicle is always considered to be braking
local braking = false

local function setBrakes(newState)

    for _, v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        ULC:SetStage(v, newState, false, true)
    end

end


-- real brakes
local function shouldUseRealBrakeMode()
    return (MyVehicleConfig.brakeConfig.speedThreshold or 3) <= realBrakeThreshold
end

CreateThread(function()
    local sleep = 1000
    while true do Wait(sleep)
        if not MyVehicle then sleep = 1000 goto continue end
        if not shouldUseRealBrakeMode then sleep = 1000 goto continue end
        if braking then goto continue end
            
        sleep = 250
        local speed = GetVehicleSpeedConverted(MyVehicle)

        if speed < realBrakeThreshold and shouldUseRealBrakeMode() and not IsControlPressed(0, 72) then
            --print("Enabling brakes")
            setBrakes(0)
            SendNUIMessage({
                type = 'toggleBrakeIndicator',
                state = true
            })
        else
            --print("Disabling brakes")
            setBrakes(1)
            SendNUIMessage({
                type = 'toggleBrakeIndicator',
                state = false
            })
        end

        ::continue::
    end
end)


-- pressed brakes
RegisterCommand('+ulc:brakePattern', function()
    braking = true
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        if GetVehicleCurrentGear(MyVehicle) == 0 then return end -- disable while reversing
        
        --print("Enabling brakes")


        local speed = GetVehicleSpeedConverted(MyVehicle)

        -- if using real brakes always enable
        if shouldUseRealBrakeMode() or speed > (MyVehicleConfig.brakeConfig.speedThreshold or 3) then
            setBrakes(0)
        end
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = true
    })
end)

RegisterCommand('-ulc:brakePattern', function()
    braking = false
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        local speed = GetVehicleSpeedConverted(MyVehicle)
        if shouldUseRealBrakeMode() and speed < realBrakeThreshold then return end

        --print("Disabling brakes")
       
        setBrakes(1)
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = false
    })
end)

RegisterKeyMapping('+ulc:brakePattern', 'Enable Brake Pattern (Hold)', 'keyboard', 's')
