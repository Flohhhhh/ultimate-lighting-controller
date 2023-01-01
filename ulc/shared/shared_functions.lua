
-- Returns: bool (whether vehicle was found), table (vehicle config info)
function GetVehicleFromConfig(vehicle)
    for k,v in pairs(Config.Vehicles) do
        -- find which vehicle matches
        --print(GetEntityModel(vehicle), GetHashKey(v.name))
        if GetEntityModel(vehicle) == GetHashKey(v.name) then
            --print("Vehicle [" .. v.name .. "] was found in Config.")
            return true, v
        else
            --print("Vehicle [" .. v.name .. "] does not match.")
        end
    end
end

-- Returns whether a vehicle is in a table of vehicle spawn names given a vehicle handle
function IsVehicleInTable(vehicle, table)
    --print(table)
    for _, v in pairs(table) do
        --print(v)
        --print(GetHashKey(v))
        --print(vehicle)
        --print(GetEntityModel(vehicle))
        if GetEntityModel(vehicle) == GetHashKey(v) then
            return true, v
        else
            --print("Vehicle [" .. v .. "] not found in table.")
        end
    end
end

-- Returns the vehicle speed converted to MPH or KPH based on config value
function GetVehicleSpeedConverted(vehicle)
    if Config.useKPH then
        return GetEntitySpeed(Entity(vehicle)) * 3.6
    else
        return GetEntitySpeed(Entity(vehicle)) * 2.236936
    end
end

-- returns true when all vehicle doors are fully closed
function AreVehicleDoorsClosed(vehicle)
    local result = true
    local numberOfDoors = GetNumberOfVehicleDoors(vehicle)
    for i = 0, numberOfDoors, 1 do
        if GetVehicleDoorAngleRatio(vehicle, i) > 0.0 then
            --print("[AreVehicleDoorsClosed()] Door " .. i .. " is open.")
            result = false
        end
    end
    return result
end

-- returns true when vehicle health is above config threshold
function IsVehicleHealthy(vehicle)
    local vehHealth = GetVehicleBodyHealth(vehicle)

    if vehHealth > Config.healthThreshold then
        return true
    else
        --print("[IsVehicleHealth())] Vehicle is damaged.")
        return false
    end
end