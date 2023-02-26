-- when I try to change state
-- Sets the stage of the vehicle, action 0 enables, 1 disables, 2 toggles; 
AddEventHandler('ulc:SetStage', function(key, action, playSound)
    local data = {key = key, action = action, playSound = playSound}
    -- tell server
    TriggerServerEvent('ulc:ClientSetStage', VehToNet(MyVehicle), data)
end)


-- when server tells me someone else changed their stage
RegisterNetEvent('ulc:SetVehicleExtra', function(src, _vehicle, data)

    local vehicle = NetToVeh(_vehicle)
    print("ulc:SetVehicleExtra: " .. vehicle)

    -- disable auto repair on the vehicle
    SetVehicleAutoRepairDisabled(vehicle, true)

    -- if i was the source
    local wasMe = GetPlayerServerId(PlayerId()) == src
    if wasMe then
        print("It was me!")
        -- start a cooldown for stage changes
        -- do client stuff
        SetStageByKey(data.key, data.action, data.playSound)
    end

    Wait(100)

    -- if i was source
    if wasMe then
        -- disable cooldown
    end

    --SetVehicleDeformationFixed(vehicle) -- ? need to test this
    -- enable auto repair on vehicle
    SetVehicleAutoRepairDisabled(vehicle, false)

end)


---------------------
---------------------
----- FUNCTIONS -----
---------------------
---------------------

-- get the extra associated with a key in vehicle configuration
function GetExtraForVehicleKey(vehicle, key)
    local passed, vehicleConfig = GetVehicleFromConfig(vehicle)
    if passed then
        for k, v in pairs(vehicleConfig.buttons) do
            if v.key == key then
                return v.extra, v.linkedExtras, v.offExtras
            end
        end
    end
end

-- get whether the specified extra is bound to any key in vehicle configuration
function IsExtraUsedByAnyVehicleKey(extra)
    local passed, vehicleConfig = GetVehicleFromConfig(MyVehicle)
    if passed then
        for k, v in pairs(vehicleConfig.buttons) do
            if v.extra == extra then
                return true
            end
        end
    end
end

function SetStageByKey(key, action, playSound)

    print("Setting stage for key: ".. key)
    if not MyVehicle then print("[SetStageByKey()] MyVehicle is not defined right now :/") return false end

    local extra, linkedExtras, offExtras = GetExtraForVehicleKey(MyVehicle, key)

    
    local state = IsVehicleExtraTurnedOn(MyVehicle, extra)
    local newState

    -- change extra
    if state then
        if action == 1 or action == 2 then
            newState = 1
            SetStageByExtra(extra, newState, playSound, false)
        end
    else
        if action == 0 or action == 2 then
            newState = 0
            SetStageByExtra(extra, newState, playSound, false)
        end
    end

    -- set linked extras
    if linkedExtras then
        for _, v in ipairs(linkedExtras) do
            SetStageByExtra(v, newState, false, false)
        end
    end

    -- set off extras
    if offExtras then
        for _, v in ipairs(offExtras) do
            SetStageByExtra(v, 1, false, false)
        end
    end

end

function SetStageByExtra(extra, newState, playSound, doChecks)
    if not MyVehicle then print("[SetStageByExtra()] MyVehicle is not defined right now :/") return false end
    if doChecks and (not IsVehicleHealthy(MyVehicle) or not AreVehicleDoorsClosed(MyVehicle)) then print("[SetStageByExtra()] Vehicle is not healthy or door is open :/") return false end

    SetVehicleExtra(MyVehicle, extra, newState)

    if not IsExtraUsedByAnyVehicleKey(extra) then return end

    if playSound then
        if newState == 0 then
            PlayBeep(true)
        else
            PlayBeep(false)
        end
    end

    SendNUIMessage({
        type = 'setButton',
        extra = extra,
        state = newState
    })
end

-----------------------
-----------------------
------ KEYBINDS -------
-----------------------
-----------------------

for i = 1, 9, 1 do
    RegisterKeyMapping('ulc:num' .. i, 'Toggle ULC Slot ' .. i , 'keyboard', 'NUMPAD' .. i)
    RegisterCommand('ulc:num' .. i, function()
        TriggerEvent('ulc:SetStage', i, 2, true)
    end)
end

------------------
------ HELP ------
------------------
local activeButtons = {}
local showingHelp = false

function ShowHelp()
    CreateThread(function()
      if not showingHelp then
        -- show help
        showingHelp = true
        for k, v in ipairs(activeButtons) do
          --print('Showing help for button: ' .. k .. ' : ' .. v.key)
          SendNUIMessage({
            type = 'showHelp',
            button = k,
            key = v.key,
          })
        end
        Wait(3000)
        -- hide help
        showingHelp = false
        for k, v in ipairs(activeButtons) do
          SendNUIMessage({
            type = 'hideHelp',
            button = k,
            label = string.upper(v.label),
          })
        end
      end
    end)
  end