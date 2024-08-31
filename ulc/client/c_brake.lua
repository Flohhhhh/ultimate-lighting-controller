--print("[ULC] Brake Extras Loaded")
local realBrakeThreshold = 3
local shouldUseRealBrakes = function()
    return (MyVehicleConfig.brakeConfig.speedThreshold or 3) <= realBrakeThreshold
end
local braking = false

-------------------
-- MAIN FUNCTIONS --
-------------------

local disabledExtras = {}

local function setBrakeExtras(newState)
    for _, v in pairs(MyVehicleConfig.brakeConfig.brakeExtras) do
        local currentState
        if IsVehicleExtraTurnedOn(MyVehicle, v) then currentState = 0 else currentState = 1 end
        --print("[ULC] setBrakeExtras() newState: " .. newState .. " currentState: " .. currentState)
        if currentState == newState then break end
        ULC:SetStage(v, newState, false, true, false, false, true, false)
    end
    if newState == 0 then
        -- disable the disable extras and save the ones that we change
        if not MyVehicleConfig.brakeConfig.disableExtras then return end
        for _, v in pairs(MyVehicleConfig.brakeConfig.disableExtras) do
            if IsVehicleExtraTurnedOn(MyVehicle, v) then
                ULC:SetStage(v, 1, false, true, false, false, true, false)
                table.insert(disabledExtras, v)
            end
        end
    elseif newState == 1 then
        -- re-enable any extras that were disabled
        for _, v in pairs(disabledExtras) do
            ULC:SetStage(v, 0, false, true, false, false, true, false)
        end
        disabledExtras = {}
    end
end


----------------------------
-- REALISTIC BRAKE LIGHTS --
----------------------------
if shouldUseRealBrakes then
    print("Realistic brake light functionality intialized.")
    local mode = "STANDARD"

    -- start checking if stopped manually with a loop
    CreateThread(function()
        local sleep = 1000
        while true do
            Wait(sleep)
            -- if rbl_brakelights change handler gets triggered that means rbl exists and we want to use that functionality instead, return from this loop
            if mode == "RBL" then
                print("real-brake-lights resource detected, integrating brakelight functionality.")
                return
            end
            if not MyVehicle then
                sleep = 1000
                goto continue
            end
            if not shouldUseRealBrakes() then
                sleep = 1000
                goto continue
            end
            if not MyVehicleConfig.brakeConfig.useBrakes then
                sleep = 1000
                goto continue
            end
            if braking then goto continue end
            sleep = 250
            local speed = GetVehicleSpeedConverted(MyVehicle)
            if speed < realBrakeThreshold and shouldUseRealBrakes() and not IsControlPressed(0, 72) then
                --print("[manual checks] Enabling brakes")
                setBrakeExtras(0)
            else
                --print("[manual checks] Disabling brakes")
                setBrakeExtras(1)
            end
            ::continue::
        end
    end)

    -- add a statebag change handler for rbl_brakelights
    -- once this is triggered, disable manual checking
    AddStateBagChangeHandler('rbl_brakelights', null, function(bagName, key, value)
        Wait(0)      -- Nedded as GetEntityFromStateBagName sometimes returns 0 on first frame
        mode = "RBL" -- set mode to RBL to disable manual checking
        if not MyVehicle then return end
        if not MyVehicleConfig.brakeConfig.useBrakes then return end
        local vehicle = GetEntityFromStateBagName(bagName)
        --print("state changed for vehicle")
        if vehicle == 0 or vehicle ~= MyVehicle then return end
        local newState
        if value then newState = 0 else newState = 1 end
        --print("ULC: Setting brakes to state" .. newState)
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
        if shouldUseRealBrakes() or speed > (MyVehicleConfig.brakeConfig.speedThreshold or 3) then
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
        if shouldUseRealBrakes() and speed < realBrakeThreshold then return end
        --print("Disabling brakes")
        setBrakeExtras(1)
    end
    SendNUIMessage({
        type = 'toggleBrakeIndicator',
        state = false
    })
end)

RegisterKeyMapping('+ulc:brakePattern', 'ULC: Activate Brake Pattern (Hold)', 'keyboard', 's')
