--print("[ULC]: Park Patterns Loaded")

local veh = GetVehiclePedIsIn(PlayerPedId())
parked = false
local lastSync = 0
local effectDelay = 1000

CreateThread(function()
    while true do
        if IsPedInAnyVehicle(PlayerPedId()) then
            TriggerEvent('ulc:checkParkState', veh, false)

            Wait(Config.ParkSettings.delay * 1000)
        else
            Wait(2000)
        end
    end
end)

RegisterNetEvent("ulc:checkParkState", function(delay)
    CreateThread(function()
        --print('Checking park state')

        if delay then
            --print('Delay...')
            Wait(5000)
        end
        local speed = GetVehicleSpeedConverted(MyVehicle)


        if speed > Config.ParkSettings.speedThreshold and parked then
            TriggerEvent("ulc:vehDrive")
        end
        if speed < Config.ParkSettings.speedThreshold and not parked then
            Wait(effectDelay)
            if not parked then -- double checks
                TriggerEvent('ulc:vehPark')
            end
        end
    end)
end)

AddEventHandler('ulc:vehPark', function()
    if Lights then
        --print('[ulc:vehPark] My vehicle is parked.')
        parked = true

        if MyVehicle and MyVehicleConfig.parkConfig.usePark then
            -- enable pExtras
            for _, v in pairs(MyVehicleConfig.parkConfig.pExtras) do
                ULC:SetStage(v, 0, false, true, false, false, true, false)
            end
            -- disable dExtras
            for _, v in pairs(MyVehicleConfig.parkConfig.dExtras) do
                ULC:SetStage(v, 1, false, true, false, false, true, false)
            end

            -- park pattern sync stuff
            if MyVehicleConfig.parkConfig.useSync then
                -- cooldown
                local gameSeconds = GetGameTimer() / 1000
                if gameSeconds >= lastSync + Config.ParkSettings.syncCooldown then
                    lastSync = gameSeconds

                    local loadedVehicles = GetGamePool("CVehicle")
                    --print(#loadedVehicles .. " vehicles in pool")
                    local vehsToSync = {}

                    for k, v in pairs(loadedVehicles) do
                        -- don't include my vehicle
                        if v ~= veh then
                            local vehCoords = GetEntityCoords(v)
                            local pedCoords = GetEntityCoords(PlayerPedId())
                            local distance = GetDistanceBetweenCoords(vehCoords, pedCoords)


                            if distance < Config.ParkSettings.syncDistance then
                                if GetVehicleClass(v) == 18 then
                                    -- check if my vehicle is set to sync with this vehicle or if the vehicle is the same model as my vehicle
                                    if IsVehicleInTable(v, MyVehicleConfig.parkConfig.syncWith) or GetEntityModel(v) == GetEntityModel(MyVehicle) then
                                        --print('Vehicle' .. v .. ' should sync with me.')

                                        local speed = GetVehicleSpeedConverted(veh)

                                        if speed < Config.ParkSettings.speedThreshold then
                                            --print("Found an eligible sync vehicle.")
                                            table.insert(vehsToSync, v)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if #vehsToSync > 0 then
                        -- sync my vehicle
                        SetVehicleSiren(veh, false)
                        SetVehicleSiren(veh, true)

                        -- sync other vehicles on my screen
                        for k, v in pairs(vehsToSync) do
                            if IsVehicleSirenOn(v) then
                                SetVehicleSiren(v, false)
                                SetVehicleSiren(v, true)
                            end
                        end

                        -- send sync to other clients nearby
                        --print("Preparing to send sync to server")
                        local vehsToSyncNet = {}
                        for k, v in pairs(vehsToSync) do
                            --print("Candidate: " .. VehToNet(v))
                            table.insert(vehsToSyncNet, VehToNet(v))
                        end
                        TriggerServerEvent("sync:send", vehsToSyncNet)
                    else --print('Found no vehicles to sync.')
                    end
                else
                    print("Sync on cooldown, time left: " ..
                        Config.ParkSettings.syncCooldown - (gameSeconds - lastSync) .. " seconds.")
                end
            end
        end
    end
end)

RegisterNetEvent('ulc:sync:receive', function(vehicles)
    --print("[sync:receive] Trying to sync " .. #vehicles .. " vehicles.")
    for _, v in pairs(vehicles) do
        --print("Attempting to sync: " .. NetToVeh(v))
        SetVehicleSiren(NetToVeh(v), false)
        SetVehicleSiren(NetToVeh(v), true)
    end
end)

AddEventHandler('ulc:vehDrive', function()
    if Lights then
        --print('[ulc:vehDrive] My vehicle is driving.')
        parked = false
        if MyVehicle and MyVehicleConfig.parkConfig.usePark then
            -- disable pExtras
            for _, v in pairs(MyVehicleConfig.parkConfig.pExtras) do
                ULC:SetStage(v, 1, false, true, false, false, true, false)
            end
            -- enable dExtras
            for _, v in pairs(MyVehicleConfig.parkConfig.dExtras) do
                ULC:SetStage(v, 0, false, true, false, false, true, false)
            end
        end
    end
end)
