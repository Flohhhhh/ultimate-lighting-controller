-- when a client wants to change their stage
RegisterNetEvent('ulc:ClientSetStage', function(vehicle, data)
    local src = source
    print("ulc:ClientSetStage: ", src)

    -- tell all clients to disable auto repair for the vehicle
    -- source client will change the extra
    TriggerClientEvent('ulc:SetVehicleExtra', -1, src, vehicle, data)
end)
