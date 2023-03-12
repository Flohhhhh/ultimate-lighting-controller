--print("[ULC]: Reverse Extras Loaded")

local reversing = false

AddEventHandler('ulc:StartCheckingReverseState', function()

    if not MyVehicleConfig.reverseConfig then return end
    CreateThread(function()
        while MyVehicle do 
            local gear = GetVehicleCurrentGear(MyVehicle)
            if gear == 0 then
                if not reversing then
                    reversing = true
                    for _, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        ULC:SetStage(v, 0, false, true)
                    end
                end
            else
                if reversing then
                    reversing = false
                    for _, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
                        ULC:SetStage(v, 1, false, true)
                    end
                end
            end
            Wait(250)
        end
    end)
end)
