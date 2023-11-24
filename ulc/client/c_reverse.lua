--print("[ULC]: Reverse Extras Loaded")

local reversing = false

AddEventHandler('ulc:StartCheckingReverseState', function()
    CreateThread(function()
        while true do Wait(250)
            --print("Checking reverse state")
            if not IsPedInAnyVehicle(PlayerPedId()) then return end
            -- this feels unncessary, but I think some people may not have .reverseConfig
            if not MyVehicle then return end
            if not MyVehicleConfig.reverseConfig then return end
            if not MyVehicleConfig.reverseConfig.useReverse then return end
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
        end
    end)
end)