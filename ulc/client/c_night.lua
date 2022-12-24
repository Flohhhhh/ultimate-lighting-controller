print("[ULC]: Night Extras Loaded")

RegisterNetEvent('ulc:checkLightTime', function()
    CreateThread(function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        local passed, vehConfig = GetVehicleFromConfig(vehicle)

        if passed then
            Wait(2000)
            if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then
                if vehConfig.steadyBurnConfig.useTime then
                    if GetClockHours() > Config.SteadyBurnSettings.nightStartHour or GetClockHours() < Config.SteadyBurnSettings.nightEndHour or vehConfig.steadyBurnConfig.forceOn then
                        for k, v in pairs(vehConfig.steadyBurnConfig.sbExtras) do
                            -- there seems to be no conflict with setting a stage that isn't actually a stage
                            SetStageByExtra(v, 0, false)
                            --TriggerEvent('ulc:setStage', v, 0, true)
                            --SetVehicleExtra(vehicle, v, 0)
                        end
                    else
                        for k, v in pairs(vehConfig.steadyBurnConfig.sbExtras) do
                            SetStageByExtra(v, 1, false)
                            --TriggerEvent('ulc:setStage', v, 1, true)
                            --SetVehicleExtra(vehicle, v, 1)
                        end
                    end
                end
            else --print("[c_night.lua] A door is open or vehicle is damaged.")
            end
        end
    end)
end)

CreateThread(function()
    while true do
        TriggerEvent('ulc:checkLightTime')
        Wait(Config.SteadyBurnSettings.delay * 1000)
    end
end)