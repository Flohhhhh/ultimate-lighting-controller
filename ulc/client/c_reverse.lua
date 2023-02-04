print("[ULC]: Reverse Extras Loaded")

local reversing = false

AddEventHandler('ulc:StartCheckingReverseState', function()

    if not MyVehicleConfig.reverseConfig then return end
    CreateThread(function()
        while MyVehicle do Wait(250)
            local gear = GetVehicleCurrentGear(MyVehicle)
            if gear == 0 then

                if not reversing then
                    print("Started reversing")
                    reversing = true
                    for k, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        SetStageByExtra(v, 0, true)
                    end
                end
            else
                if reversing then
                    print("Stopped reversing")
                    reversing = false
                    for k, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        SetStageByExtra(v, 1, true)
                    end
                end
            end
        end
    end)
end)
