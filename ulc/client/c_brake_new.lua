--print("[ULC] Brake Extras Loaded")
local realBrakeThreshold = 3
local shouldUseRealBrakes = if Config.brakeConfig.speedThreshold or 3 <= realBrakeThreshold then return true else return false end
local braking = false

RblActive = false
RblState = GetResourceState("real-brake-lights")
if RblState == "started" or RblState == "starting" then RblActive = true end
if RblACtive then print("[ULC] Found real-brake-lights resource! Activating integrations!") end

-------------------
-- MAIN FUNCTIONS --
-------------------

local disabledExtras= {}

local function setBrakeExtras(newState)
    for _, v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local currentState
        if IsVehicleExtraTurnedOn(MyVehicle, v) then currentState = 0 else currentState = 1 end
        --print("[ULC] setBrakeExtras() newState: " .. newState .. " currentState: " .. currentState)
        if currentState == newState then break end
        ULC:SetStage(v, newState, false, true)
    end
    if newState == 0 then
        -- disable the disable extras and save the ones that we change
        for _, v in pairs(MyVehicleConfig.brakeConfig.disableExtras) do
            if IsVehicleExtraTurnedOn(MyVehicle, v) then
                ULC:SetStage(v, 1, false, true)
                table.insert(disabledExtras, v)
            end
        end
    else if newState == 1 then
        -- re-enable any extras that were disabled
        for _, v in pairs(disabledExtras) do
            ULC:SetStage(v, 0, false, true)
        end
    end
end


----------------------------
-- REALISTIC BRAKE LIGHTS --
----------------------------

local mode = "STANDARD" -- RBL or STANDARD

-- if RBL resource exists set mode to RBL
if not RblActive then
    print("real-brake-lights resource not found. Using brakes in standard mode.")
    mode = "STANDARD"
    -- start checking if stopped manually with a loop
    CreateThread(function()
        local sleep = 1000
        while true do Wait(sleep)
            if not MyVehicle then sleep = 1000 goto continue end
            if not shouldUseRealBrakeMode then sleep = 1000 goto continue end
            if braking then goto continue end
            sleep = 250
            local speed = GetVehicleSpeedConverted(MyVehicle)
            if speed < realBrakeThreshold and shouldUseRealBrakeMode() and not IsControlPressed(0, 72) then
                --print("Enabling brakes")
                setBrakeExtras(0)
            else
                --print("Disabling brakes")
                setBrakeExtras(1)
            end
            ::continue::
        end
    end)
    -- add change handler for ulc
    AddStateBagChangeHandler('ulc_blackout', null, function(bagName, key, value)
        Wait(0)
        local vehicle = GetEntityFromStateBagName(bagName)
        if vehicle == 0 or vehicle != MyVehicle then print("Vehicle is 0 or not mine") return end
        local blackout = value
        if blackout then
            -- set blackout stuff
        else
            -- undo blackout stuff
        end
    end)
    -- registerCommand blackout
    RegisterCommand('blackout', function()
        -- trigger server event to set blackout on my vehicle
        TriggerServerEvent('ulc:setVehicleBlackout', VehToNet(MyVehicle), not Entity(MyVehicle).state.ulc_blackout)
    end)
        


else
    print("real-brake-lights resource found! Linking brake functionality!")
    mode = "RBL"
    -- setup statebag event handler
    -- whenever rbl_brakelights value changes on an entity
    AddStateBagChangeHandler('rbl_brakelights', null, function(bagName, key, value)
        Wait(0) -- Nedded as GetEntityFromStateBagName sometimes returns 0 on first frame
        local vehicle = GetEntityFromStateBagName(bagName)
        -- print("state changed for vehicle")
        if vehicle == 0 or vehicle != MyVehicle then print("Vehicle is 0 or not mine") return end
        local newState
        if value then newState = 0 else newState = 1 end
        print("ULC: Setting brakes to state" .. newState)
        setBrakeExtras(newState)
    end)

    
end

-----------------
-- KEYBINDINGS --
-----------------

-- pressed brakes
RegisterCommand('+ulc:brakePattern', function()
    braking = true
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        if GetVehicleCurrentGear(MyVehicle) == 0 then return end -- disable while reversing
        --print("Enabling brakes")
        local speed = GetVehicleSpeedConverted(MyVehicle)
        -- if using real brakes always enable
        if shouldUseRealBrakeMode() or speed > (MyVehicleConfig.brakeConfig.speedThreshold or 3) then
            setBrakeExtras(0)
        end
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = true
    })
end)

RegisterCommand('-ulc:brakePattern', function()
    braking = false
    if MyVehicle and MyVehicleConfig.brakeConfig.useBrakes then
        local speed = GetVehicleSpeedConverted(MyVehicle)
        if shouldUseRealBrakeMode() and speed < realBrakeThreshold then return end
        --print("Disabling brakes")
        setBrakeExtras(1)
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = false
    })
end)

RegisterKeyMapping('+ulc:brakePattern', 'Enable Brake Pattern (Hold)', 'keyboard', 's')