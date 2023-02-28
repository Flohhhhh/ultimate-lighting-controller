print("[ULC]: Stage Controls Loaded")

-- -- when I try to change state
-- -- Sets the stage of the vehicle, action 0 enables, 1 disables, 2 toggles; 
AddEventHandler('ulc:SetStage', function(key, action, playSound)
    local data = {key = key, action = action, playSound = playSound}
    TriggerEvent('ulc:SetVehicleStage', data)
--     -- tell server
--     TriggerServerEvent('ulc:ClientSetStage', VehToNet(MyVehicle), data)
end)

AddEventHandler('ulc:SetStageByExtra', function(extra, action, playSound, doChecks)
     local data = {extra = extra, action = action, playSound = playSound}
     TriggerEvent('ulc:SetVehicleStage', data, doChecks)
--     TriggerServerEvent('ulc:ClientSetStage', VehToNet(MyVehicle), data)
end)

-- -- when server tells me someone else changed their stage
-- RegisterNetEvent('ulc:SetVehicleExtra', function(src, _vehicle, data)
-- 	print("Got event")
--     local vehicle = NetToVeh(_vehicle)
--     print("ulc:SetVehicleExtra: " .. vehicle, data.key)

--     print("Disabling auto repair for vehicle: " .. vehicle)
--     -- disable auto repair on the vehicle
--     SetVehicleAutoRepairDisabled(vehicle, true)
--     -- if i was the source
--     local wasMe = GetPlayerServerId(PlayerId()) == src
--     if not wasMe then
--         Wait(100)
--     else
--         print("It was me!")
--         -- start a cooldown for stage changes
--         -- do client stuff
--         if data.key then
--             SetStageByKey(data.key, data.action, data.playSound)
--         elseif data.extra then
--             SetStageByExtra(data.extra, data.action, data.playSound)
--         end
--     end

--     Wait(200)

--     -- if i was source
--     if wasMe then
--         -- disable cooldown
--     end

--     --SetVehicleDeformationFixed(vehicle) -- ? need to test this
--     -- enable auto repair on vehicle
--     print("Enabling auto repair for vehicle: " .. vehicle)
--     SetVehicleAutoRepairDisabled(vehicle, false)

-- end)

AddEventHandler('ulc:SetVehicleStage', function(data, doChecks)
    SetVehicleAutoRepairDisabled(MyVehicle, true)
    if data.key then
        SetStageByKey(data.key, data.action, data.playSound)
    elseif data.extra then
        SetStageByExtra(data.extra, data.action, data.playSound, doChecks)
    end
    --do I need a wait?
    SetVehicleAutoRepairDisabled(MyVehicle, false)
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

function GetKeyForVehicleExtra(vehicle, extra)
    local passed, vehicleConfig = GetVehicleFromConfig(vehicle)
	print("Finding key for extra: " .. extra .. " on vehicle: " .. vehicle)
    if passed then
        for _, v in pairs(vehicleConfig.buttons) do
            if v.extra == extra then
			print("Found: " .. v.key)
                return v.key, v.linkedExtras, v.offExtras
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


CreateThread(function()
    while true do Wait(1000)
        local vehicles = GetGamePool("CVehicle")
        for _, v in pairs(vehicles) do
            if v ~= GetVehiclePedIsIn(PlayerPedId(), false) then
                SetVehicleAutoRepairDisabled(v, true)
            else
				--print("Enabling repair for" .. v)
				SetVehicleAutoRepairDisabled(v, false)
			end
        end
    end
end)