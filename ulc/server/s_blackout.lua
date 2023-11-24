
RegisterNetEvent('ulc:setVehicleBlackout', function(netId, state)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    Entity(vehicle).state.ulc_blackout = state
end)

