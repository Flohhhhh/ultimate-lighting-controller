local rblIntegration = false

function ULC:SetBlackout(newState)
  --print("Setting blackout to " .. newState)
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  if newState == 0 then
    -- do blackout stuff
      -- turn off headlights
    SetVehicleLights(vehicle, 1)
    -- turn off emergency lights
    SetVehicleSiren(vehicle, false)
    -- turn off specified blackout extras?
    -- might need to just make a blackout file and config section, i think this can work when brake patterns aren't being used?
    -- turn off cruise lights (do in c_cruise.lua)
    -- if lights are turned on with q, or h, or a button is pressed, cancel effect, not sure how to do this.
        -- when these actions are done check [if Entity(GetVehiclePedIsIn(PlayerPedId())).state.rbl_blackout or ulc_blackout] <- depending on if these can be accessed when not defined, may have to just use a static global variable in here.
    
    -- if rbl is not loaded, start checking if vehicle is moving to disable blackout, rbl handles this itself if loaded
    if not rblIntegration then
      CreateThread(function()
        while true do Wait(500)
          if Entity(vehicle).state.ulc_blackout == 1 then ULC:SetBlackout(1) return end
          local speed = GetEntitySpeed(vehicle) * 2.236936
          --print("Speed is " .. speed)
          if speed > 5 then ULC:SetBlackout(1) return end
        end
      end)
    end
  elseif newState == 1 then
    -- do undo blackout stuff
    SetVehicleLights(vehicle, 0)
  end
end

-- add statebag change handler for ulc_blackout
AddStateBagChangeHandler('ulc_blackout', null, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  --print("ulc_blackout listener: Vehicle is " .. vehicle .. " and GetVehiclePedIsIn(PlayerPedId()) is " .. GetVehiclePedIsIn(PlayerPedId()))
  if vehicle == 0 or vehicle ~= GetVehiclePedIsIn(PlayerPedId()) then
      print("ulc_blackout listener: Vehicle is 0 or not mine.")
      return
  end
  local blackout = value
  --print("ulc_blackout listener: new state value is " .. tostring(blackout))
  if blackout == 0 then
      ULC:SetBlackout(0)
  elseif blackout == 1 then
      ULC:SetBlackout(1)
  end
end)

-- add statebag change handler for rbl blackout
AddStateBagChangeHandler('rbl_blackout', null, function(bagName, key, value)
  Wait(0)
  rblIntegration = true
  local vehicle = GetEntityFromStateBagName(bagName)
  --print("rbl_blackout listener: Vehicle is " .. vehicle .. " and GetVehiclePedIsIn(PlayerPedId()) is " .. GetVehiclePedIsIn(PlayerPedId()))
  if vehicle == 0 or vehicle ~= GetVehiclePedIsIn(PlayerPedId()) then
      --print("rbl_blackout listener: Vehicle is 0 or not mine")
      return
  end
  local blackout = value
  --print("rbl_blackout listener: new state value is " .. tostring(blackout))
  if blackout == true then
    --print("rbl_blackout listener: setting blackout to 0")
    ULC:SetBlackout(0)
  elseif blackout == false then
    --print("rbl_blackout listener: setting blackout to 1")
    ULC:SetBlackout(1)
  end
end)

-- register command for blackout

-- if rbl loads first then ULC
  -- ulc will overwrite command
  -- ULC needs to trigger rbl:setBlackout state change on server
  -- ULC only manages the extras

-- if ulc loads first then rbl
  -- rbl will overwrite command
  -- rbl needs to trigger ulc:setBlackout state change on server
  -- rbl only manages the brake lights

RegisterCommand('blackout', function()
    local newState
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle then return end
    local currentState = Entity(vehicle).state.ulc_blackout
    --print("/blackout: Current state: " .. tostring(currentState))
    if currentState == nil or currentState == 1 then
        print("Setting blackout to true/0")
        newState = 0
    elseif currentState == 0 then
        print("Setting blackout to false/1")
        newState = 1
    end
    -- trigger server event to set blackout on my vehicle
    -- might need to extract this to an event/function to control the effect programmatically, like disbling when q pressed
    TriggerServerEvent('ulc:setBlackout', VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
    TriggerServerEvent('rbl:setBlackout', VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
end)
  -- toggle blackout state on vehicle
  

-------------------------------
-- DISABLE BLACKOUT TRIGGERS --
-------------------------------

--TODO when H is pressed to control headlights disable blackout
--TODO when Q is pressed to control emergency lights disable blackout


