-- when a client wants to change their stage
RegisterNetEvent('ulc:ClientSetStage', function(vehicle, data)
    local src = source
    --print("ulc:ClientSetStage: ", src, data.key, data.extra)

    -- tell all clients to disable auto repair for the vehicle
    -- source client will change the extra
    TriggerClientEvent('ulc:SetVehicleExtra', src, src, vehicle, data)
end)


RegisterNetEvent('ulc:PrepVehicleForChange', function(vehicle)
    TriggerClientEvent('ulc:DisableRepairOnVehicle', -1, vehicle)
end)

RegisterNetEvent('ulc:ResetVehicleAfterChange', function(vehicle)
    TriggerClientEvent('ulc:EnableRepairOnVehicle', -1, vehicle)
end)