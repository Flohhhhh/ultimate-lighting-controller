--print("[ULC]: Reverse Extras Loaded")

local reversing = false
local disabledExtras = {}
local timerExpired = false

function setReverseExtras(newState)
    -- set enable extras to match the new state
    for _, v in ipairs(MyVehicleConfig.reverseConfig.reverseExtras) do
        ULC:SetStage(v, newState, false, true, false, false, true, false)
    end
    if not MyVehicleConfig.reverseConfig.disableExtras then return end
    if newState == 0 then
        -- set disable extras off and save the ones we changed
        for _, v in ipairs(MyVehicleConfig.reverseConfig.disableExtras) do
            --print("Checking extra " .. v .. " for reverse state")
            if IsVehicleExtraTurnedOn(MyVehicle, v) then
                ULC:SetStage(v, 1, false, true, false, false, true, false)
                table.insert(disabledExtras, v)
            end
        end
    else -- newState == 1
        -- set the disabled extras back on
        for _, v in ipairs(disabledExtras) do
            ULC:SetStage(v, 0, false, true, false, false, true, false)
        end
        disabledExtras = {}
    end
end

AddEventHandler('ulc:StartCheckingReverseState', function()
    CreateThread(function()
        while true do
            Wait(250)
            --print("Checking reverse state")
            if not IsPedInAnyVehicle(PlayerPedId()) then return end
            -- this feels unncessary, but I think some people may not have .reverseConfig
            if not MyVehicle then return end
            if not MyVehicleConfig.reverseConfig then return end
            if not MyVehicleConfig.reverseConfig.useReverse then return end
            local gear = GetVehicleCurrentGear(MyVehicle)
            if gear == 0 then
                if not reversing then
                    startTimer()
                    reversing = true
                    setReverseExtras(0)
                end
            else
                if reversing then
                    reversing = false
                    setReverseExtras(1)
                end
            end
        end
    end)
end)

-- handle disabling lights after some time
function startTimer()
    -- if disabled in config, don't start timer , if enabled or missing config, start timer
    if Config and Config.ReverseSettings and not Config.ReverseSettings.useRandomExpiration then return end
    -- timer thread
    CreateThread(function()
        local speed
        local duration = math.random(3, 8) * 1000
        local expirationTime

        while true do
            --print("Reverse timer tick")
            if not MyVehicle then return end
            if not MyVehicleConfig.reverseConfig then return end
            if not MyVehicleConfig.reverseConfig.useReverse then return end
            if not reversing then
                timerExpired = false
                --print("Not reversing")
                return
            end

            speed = GetVehicleSpeedConverted(MyVehicle)

            if speed < 0.5 then -- if we are in reverse and stopped
                if timerExpired then
                    goto continue
                end
                if Config and Config.ReverseSettings then
                    duration = math.random(
                        (Config.ReverseSettings.minExpiration or 3) * 1000,
                        (Config.ReverseSettings.maxExpiration or 8) * 1000
                    )
                end
                expirationTime = GetGameTimer() + duration
                while GetGameTimer() < expirationTime do
                    Wait(500)
                    --print("Reverse timer active")

                    if GetVehicleSpeedConverted(MyVehicle) > 1 then
                        -- print("[ULC] Reverse: Moving, breaking timer")
                        break
                    end
                    if not reversing then
                        -- print("[ULC] Reverse: Not reversing, breaking timer")
                        break
                    end
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        -- print("[ULC] Reverse: Not in vehicle, breaking timer")
                        break
                    end
                    if GetGameTimer() > expirationTime then
                        print("[ULC] Reverse: Timer expired, disabling extras")
                        timerExpired = true
                        setReverseExtras(1)
                        break
                    end
                end
            else -- if we are in reverse and moving
                -- print("[ULC] Reverse: Resetting timer")
                setReverseExtras(0)
                timerExpired = false
            end

            ::continue::
            Wait(500)
        end
    end)
end
