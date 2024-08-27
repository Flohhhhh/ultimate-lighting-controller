local doors = {
    [0] = false, -- d front
    [1] = false, -- p front
    [2] = false, -- d rear
    [3] = false, -- p rear
    [4] = false, -- hood
    [5] = false  -- trunk
}

local function intNot(value)
    result = 0
    if value == 0 then
        result = 1
    end
    return result
end

-- state 1 = closed, state 0 = open
local function onDoorStateChange(door, newDoorState)
    --print("Handling door change", door, newDoorState)
    if door == 0 or door == 2 then -- if driver side
        for _, v in pairs(MyVehicleConfig.doorConfig.driverSide.enable) do
            --print("Enable extra:", v)
            ULC:SetStage(v, newDoorState, true, true, false, false, true, true)
        end
        for _, v in pairs(MyVehicleConfig.doorConfig.driverSide.disable) do
            --print("Disable extra:", v, intNot(newDoorState))
            ULC:SetStage(v, intNot(newDoorState), true, true, false, false, true, true)
        end
    elseif door == 1 or door == 3 then -- if pass side
        for _, v in pairs(MyVehicleConfig.doorConfig.passSide.enable) do
            --print("Enable extra:", v)
            ULC:SetStage(v, newDoorState, true, true, false, false, true, true)
        end
        for _, v in pairs(MyVehicleConfig.doorConfig.passSide.disable) do
            --print("Disable extra:", v, intNot(newDoorState))
            ULC:SetStage(v, intNot(newDoorState), true, true, false, false, true, true)
        end
    elseif door == 5 then -- if trunk
        for _, v in pairs(MyVehicleConfig.doorConfig.trunk.enable) do
            ULC:SetStage(v, newDoorState, true, true, false, false, true, true)
        end
        for _, v in pairs(MyVehicleConfig.doorConfig.trunk.disable) do
            ULC:SetStage(v, intNot(newDoorState), true, true, false, false, true, true)
        end
    end
end

CreateThread(function()
    local sleep = 1000
    while true do
        Wait(sleep)
        if not MyVehicle then
            sleep = 1000
            goto continue
        end
        if not MyVehicleConfig.doorConfig or false then
            sleep = 1000
            goto continue
        end
        if not MyVehicleConfig.doorConfig.useDoors then
            sleep = 1000
            goto continue
        end
        sleep = 250

        for k, v in pairs(doors) do
            if GetVehicleDoorAngleRatio(MyVehicle, k) > 0.0 then
                if v == false then
                    -- print("Setting door", k, "open.")
                    doors[k] = true         -- set door open
                    onDoorStateChange(k, 0) -- handle what to do
                end
            else
                if v == true then
                    -- print("Setting door", k, "closed.")
                    doors[k] = false        -- set door closed
                    onDoorStateChange(k, 1) -- handle what to do
                end
            end
        end

        ::continue::
    end
end)
