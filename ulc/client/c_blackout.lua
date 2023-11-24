Blackout = false --  not currently used

function ULC:SetBlackout(newState)
    print("Setting blackout to " .. newState)
    if newState == 0 then
        -- do blackout stuff
        -- turn off headlights
        -- turn off emergency lights
        -- turn off specified blackout extras?
        -- might need to just make a blackout file and config section, i think this can work when brake patterns aren't being used?
        -- turn off cruise lights (do in c_cruise.lua)
        -- if lights are turned on with q, or h, or a button is pressed, cancel effect, not sure how to do this.
            -- when these actions are done check [if Entity(MyVehicle).state.rbl_blackout or ulc_blackout] <- depending on if these can be accessed when not defined, may have to just use a static global variable in here.
    else if newState == 1 then
        -- do undo blackout stuff
    end
end

if RblActive then
    -- add change handler for ulc
    AddStateBagChangeHandler('ulc_blackout', null, function(bagName, key, value)
        Wait(0)
        local vehicle = GetEntityFromStateBagName(bagName)
        if vehicle == 0 or vehicle != MyVehicle then print("Vehicle is 0 or not mine") return end
        local blackout = value
        if blackout then
            ULC:SetBlackout(0)
        else
            ULC:SetBlackout(1)
        end
    end)
    -- registerCommand blackout
    RegisterCommand('blackout', function()
        -- trigger server event to set blackout on my vehicle
        TriggerServerEvent('ulc:setVehicleBlackout', VehToNet(MyVehicle), not Entity(MyVehicle).state.ulc_blackout)
    end)
else 
    AddStateBagChangeHandler('rbl_blackout', null, function(bagName, key, value)
        Wait(0)
        local vehicle = GetEntityFromStateBagName(bagName)
        if vehicle == 0 or vehicle != MyVehicle then print("Vehicle is 0 or not mine") return end
        local blackout = value
        if blackout then
            ULC:SetBlackout(0)
        else
            ULC:SetBlackout(1)
        end
    end)
end