local activeButtons = {}
local showingHelp = false

------------------
------ HELP ------
------------------

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

-- Get the extra associated with a key in vehicle configuration
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
  local veh = GetVehiclePedIsIn(PlayerPedId())
  local passed, vehicleConfig = GetVehicleFromConfig(veh)
  if passed then
    for k, v in pairs(vehicleConfig.buttons) do
      if v.extra == extra then
        return true
      end
    end
  end
end

-- Change stage by extra;
-- This is the main "do the thing" function
function SetStageByExtra(extra, newState, playSound)
  local veh = GetVehiclePedIsIn(PlayerPedId())
  -- print("Setting button for extra " .. extra .. " to " .. newState)
  -- toggle extra
  SetVehicleExtra(veh, extra, newState)

  if IsExtraUsedByAnyVehicleKey(extra) then

    if playSound then
      if newState == 0 then
        PlayBeep(true)
      else
        PlayBeep(false)
      end
    end
    -- send message to JS to update HUD
    SendNUIMessage({
      type = 'setButton',
      extra = extra,
      state = newState
    })
  end
end

-- Sets the stage of the vehicle, 0 enables, 1 disables, 2 toggles; 
-- This is just a pass through, does some checks and then calls SetStageByExtra() function;
-- Note this is called by key, while other function is called by Extra
AddEventHandler('ulc:setStage', function(key, action, playSound)

  local vehicle = GetVehiclePedIsIn(PlayerPedId())
  local extra, linkedExtras, offExtras = GetExtraForVehicleKey(vehicle, key)


  if AreVehicleDoorsClosed(vehicle) and IsVehicleHealthy(vehicle) then

    local state = IsVehicleExtraTurnedOn(vehicle, extra) -- returns true if enabled
    -- new stage state as extra disable (1 is disable, 0 is enable)
    local newState = null

    -- stage is on
    if state then
	  --print("[ulc:setStage] Stage is on")
      if action == 1 or action == 2 then
        newState = 1
        SetStageByExtra(extra, newState, playSound)
      end
    -- stage is off
    else
	  --print("[ulc:setStage] Stage is off")
      if action == 0 or action == 2 then
        newState = 0
        SetStageByExtra(extra, newState, playSound)
      end
    end

    if linkedExtras then
      for _, v in ipairs(linkedExtras) do
        SetStageByExtra(v, newState, false)
      end
    end

    if offExtras then
      for _, v in ipairs(offExtras) do
        SetStageByExtra(v, 1, false)
      end
    end
  end
end)


-----------------------
-----------------------
------ KEYBINDS -------
-----------------------
-----------------------

for i = 1, 9, 1 do
  RegisterKeyMapping('ulc:num' .. i, 'Toggle ULC Slot ' .. i , 'keyboard', 'NUMPAD' .. i)
  RegisterCommand('ulc:num' .. i, function()
    TriggerEvent('ulc:setStage', i, 2, true)
  end)
end