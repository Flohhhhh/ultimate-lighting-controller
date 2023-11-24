
RegisterNetEvent('ulc:setBlackout', function(netId, state)
    print("[ULC] Setting blackout to " .. tostring(state) .. " on vehicle " .. tostring(netId))
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    Entity(vehicle).state.ulc_blackout = state
end)

