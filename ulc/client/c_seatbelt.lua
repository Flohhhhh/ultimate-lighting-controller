local function GetPedSeatbeltSafe(ped)
    if type(GetPedSeatbelt) ~= 'function' then
        return false
    end

    local ok, result = pcall(GetPedSeatbelt, ped)
    return ok and (result == true)
end

local function GetVehicleSeatbeltSafe(vehicle)
    if type(GetVehicleSeatbeltOnVehicle) ~= 'function' then
        return false
    end

    local ok, result = pcall(GetVehicleSeatbeltOnVehicle, vehicle)
    return ok and (result == true)
end

local function GetSeatbeltParkConfig()
    local config = MyVehicleConfig
    if type(config) ~= 'table' then
        return false, 0
    end

    local enabled = false
    local stage = 0

    local park = config.park
    if type(park) == 'table' then
        stage = park.parkStage or park.stage or 0

        if park.useSeatbelt == true or park.seatbelt == true then
            enabled = true
        elseif type(park.seatbelt) == 'table' and (park.seatbelt.use == true or park.seatbelt.park == true) then
            enabled = true
        end
    end

    local seatbelt = config.seatbelt
    if type(seatbelt) == 'table' then
        if seatbelt.usePark == true or seatbelt.park == true or seatbelt.use == true then
            enabled = true
        end

        if stage == 0 and (seatbelt.parkStage or seatbelt.stage) then
            stage = seatbelt.parkStage or seatbelt.stage
        end
    end

    if type(stage) ~= 'number' then
        stage = 0
    end

    return enabled, stage
end

local function GetLightsState()
    if Lights == true or Lights == 1 then
        return 1
    end

    return 0
end

local function ActivateSeatbeltPark(stage)
    if not MyVehicle or MyVehicle == 0 then
        return
    end

    parked = true

    if type(ULC) == 'table' and type(ULC.SetStage) == 'function' then
        ULC.SetStage(stage, GetLightsState(), false, true, false, false, true, false)
    elseif type(stage) == 'number' and type(SetVehicleExtra) == 'function' then
        SetVehicleExtra(MyVehicle, stage, 0)
    end

    TriggerEvent('ulc:vehPark', true)
end

local lastVehicle = 0
local lastSeatbelt = nil

CreateThread(function()
    local sleep = 1000
    while true do
        Wait(sleep)

        if MyVehicle and MyVehicle ~= 0 then
            sleep = 100
            local enabled, stage = GetSeatbeltParkConfig()

            if not enabled then
                lastVehicle = 0
                lastSeatbelt = nil
            else
                local playerPed = GetPlayerPed(-1)
                if playerPed == 0 or GetVehiclePedIsIn(playerPed, false) ~= MyVehicle then
                    lastVehicle = 0
                    lastSeatbelt = nil
                else
                    local beltOn = GetPedSeatbeltSafe(playerPed) or GetVehicleSeatbeltSafe(MyVehicle)

                    if lastVehicle ~= MyVehicle then
                        lastVehicle = MyVehicle
                        lastSeatbelt = beltOn
                    else
                        if lastSeatbelt == true and beltOn == false then
                            ActivateSeatbeltPark(stage)
                        end

                        lastSeatbelt = beltOn
                    end
                end
            end
        else
            sleep = 1000
            lastVehicle = 0
            lastSeatbelt = nil
        end
    end
end)
