print("[ULC]: Reverse Extras Loaded")

local reversing = false

AddEventHandler('ulc:StartCheckingReverseState', function()

    if not MyVehicleConfig.reverseConfig then return end
    CreateThread(function()
        while MyVehicle do 
            local gear = GetVehicleCurrentGear(MyVehicle)
            if gear == 0 then
                if not reversing then
                    reversing = true
                    for k, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        if AreVehicleDoorsClosed(MyVehicle) and IsVehicleHealthy(MyVehicle) then
                            SetStageByExtra(v, 0, true)
                        end
                    end
                end
            else
                if reversing then
                    reversing = false
                    for k, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        if AreVehicleDoorsClosed(MyVehicle) and IsVehicleHealthy(MyVehicle) then
                            SetStageByExtra(v, 1, true)
                        end
                    end
                end
            end
            Wait(250)
        end
    end)
end)
