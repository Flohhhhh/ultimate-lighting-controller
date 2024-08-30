-- Returns: bool (whether vehicle was found), table (vehicle config info)
function GetVehicleFromConfig(vehicle)
    for _, v in pairs(Config.Vehicles) do
        -- if old method with just a string
        if v.name then
            -- find which vehicle matches
            if GetEntityModel(vehicle) == GetHashKey(v.name) then
                --print("Vehicle [" .. v.name .. "] was found in Config.")
                return true, v
            end
        elseif v.names then -- if new method with a table
            -- for each name check if it matches the vehicle
            for _, n in ipairs(v.names) do
                if GetEntityModel(vehicle) == GetHashKey(n) then
                    --print("Vehicle [" .. v.name .. "] was found in Config.")
                    return true, v
                end
            end
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

    if vehHealth > 980 then
        return true
    else
        --print("[IsVehicleHealth())] Vehicle is damaged.")
        return false
    end
end

function SortButtonsByKey(arr)
    table.sort(arr, function(a, b)
        return a["key"] < b["key"]
    end)
end

function formatInt(num)
    local formatted = tostring(num)
    local length = formatted:len()

    for i = length - 3, 1, -3 do
        formatted = formatted:sub(1, i) .. ',' .. formatted:sub(i + 1)
    end

    return formatted
end

function validateButtonText(text)
    local count = 0
    for word in text:gmatch("%w+") do
        count = count + 1
        if count > 3 or #word > 5 then
            return false
        end
    end
    return true
end

-- Function to check if a value exists in a table
-- Returns: bool (whether value is contained), int (index of value if contained)
function contains(table, val)
    for i, v in ipairs(table) do
        if v == val then
            return i
        end
    end
    return false
end
