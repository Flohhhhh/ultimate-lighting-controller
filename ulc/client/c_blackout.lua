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
          -- when these actions are done check [if Entity(GetVehiclePedIsIn(PlayerPedId())).state.rbl_blackout or ulc_blackout] <- depending on if these can be accessed when not defined, may have to just use a static global variable in here.
  elseif newState == 1 then
      -- do undo blackout stuff
  end
end

-- add statebag change handler for ulc_blackout
AddStateBagChangeHandler('ulc_blackout', null, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  print("ulc_blackout listener: Vehicle is " .. vehicle .. " and GetVehiclePedIsIn(PlayerPedId()) is " .. GetVehiclePedIsIn(PlayerPedId()))
  if vehicle == 0 or vehicle ~= GetVehiclePedIsIn(PlayerPedId()) then
      print("ulc_blackout listener: Vehicle is 0 or not mine.")
      return
  end
  local blackout = value
  if blackout then
      ULC:SetBlackout(0)
  else
      ULC:SetBlackout(1)
  end
end)

-- add statebag change handler for rbl blackout
AddStateBagChangeHandler('rbl_blackout', null, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  print("rbl_blackout listener: Vehicle is " .. vehicle .. " and GetVehiclePedIsIn(PlayerPedId()) is " .. GetVehiclePedIsIn(PlayerPedId()))
  if vehicle == 0 or vehicle ~= GetVehiclePedIsIn(PlayerPedId()) then
      print("rbl_blackout listener: Vehicle is 0 or not mine")
      return
  end
  local blackout = value
  if blackout then
      ULC:SetBlackout(0)
  else
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
    if not Entity(vehicle).state.ulc_blackout then
        print("Setting blackout to true")
        newState = 0
    else
        print("Setting blackout to false")
        newState = 1
    end
    -- trigger server event to set blackout on my vehicle
    -- might need to extract this to an event/function to control the effect programmatically, like disbling when q pressed
    TriggerServerEvent('ulc:setBlackout', VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
    TriggerServerEvent('rbl:setBlackout', VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
end)
  -- toggle blackout state on vehicle
  



