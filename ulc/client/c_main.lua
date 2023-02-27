print("[ULC]: Stage Controls Loaded")

-- this is all just so resource can be restarted and not break for clients in server
Loaded = false
-- this is for when someone joins
AddEventHandler('onClientMapStart', function()
    --print("I joined.")
    Loaded = true
end)

RegisterNetEvent('ulc:Loaded', function()
    Loaded = true
end)

-----------------
-- DEFINITIONS --
-----------------

Lights = false
MyVehicle = nil
MyVehicleConfig = nil

------------------------------------
------------------------------------
------- LIGHTS STATE HANDLER -------
------------------------------------
------------------------------------

-- These 2 events need to be received from Luxart, the ones currently below are from luxart v1, need to update
-- From what I can see so far, there is no longer an event for this in luxart v3
-- we can just check every 250 frames or something, and leave this in for anyone using old version i guess?

-- Going with loop method for now.
AddEventHandler('ulc:lightsOn', function()
  --print("Lights On")
  -- set Lights on
  Lights = true
  -- check if parked or driving for park patterns
  TriggerEvent('ulc:checkParkState', GetVehiclePedIsIn(PlayerPedId()), false)
  SendNUIMessage({
    type = 'toggleIndicator',
    state = Lights
  })

  if not Config.muteBeepForLights then
    PlayBeep(true)
  end

end)

AddEventHandler('ulc:lightsOff', function()
  --print("Lights Off")
  Lights = false
  SendNUIMessage({
    type = 'toggleIndicator',
    state = Lights
  })

  if not Config.muteBeepForLights then
    PlayBeep(false)
  end

end)

-- check if lights are on 10 times a second;
-- used to trigger above events
CreateThread(function()
  while true do
    Wait(100)
    if IsVehicleSirenOn(GetVehiclePedIsIn(PlayerPedId())) then
      if not Lights then
        TriggerEvent('ulc:lightsOn')
      end
    else
      if Lights then
        TriggerEvent('ulc:lightsOff')
      end
    end
  end
end)

---------------------------
---------------------------
-------- MAIN CODE --------
---------------------------
---------------------------

-- this event is called whenever player enters vehicle
RegisterNetEvent('ulc:checkVehicle')
AddEventHandler('ulc:checkVehicle', function()
  CreateThread(function()
    --while not GlobalState.ulcloaded do
    while not Loaded do
      print("ULC: Waiting for load.")
      Wait(250)
    end
    --print("Checking for vehicle configuration")
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local passed, vehicleConfig = GetVehicleFromConfig(vehicle)

    --print(passed, vehicleConfig)

    if passed then
      MyVehicle = vehicle
      MyVehicleConfig = vehicleConfig
      --print("Found vehicle.")
      -- clear any existing buttons from hud
      SendNUIMessage({
        type = 'clearButtons',
      })

      activeButtons = {}

      -- if i am driver
      if ped == GetPedInVehicleSeat(vehicle, -1) then
        -- for each configured button on this vehicle
        for k, v in pairs(vehicleConfig.buttons) do
          -- determine state of button's extra
          local extraState = 1
          if IsVehicleExtraTurnedOn(vehicle, v.extra) then
            extraState = 0
          end 
          -- add/show and configure the button
          --print("Adding button: " .. v.label)
          table.insert(activeButtons, v)
          SendNUIMessage({
            type = 'addButton',
            label = string.upper(v.label),
            extra = v.extra,
            state = extraState
          })
        end

        if vehicleConfig.parkConfig.usePark then
          SendNUIMessage({
            type = 'showParkIndicator',
          })
        end

        if vehicleConfig.brakeConfig.useBrakes then
          SendNUIMessage({
            type = 'showBrakeIndicator',
          })
        end

        ShowHelp()

        -- when done
        -- show hud
        if not Config.hideHud then
          SendNUIMessage({
            type = 'showLightsHUD',
          })
        end

        TriggerEvent('ulc:CheckCruise')
        TriggerEvent('ulc:checkParkState', true)
        TriggerEvent('ulc:StartCheckingReverseState')
      end
    else
      Vehicle = nil
      TriggerEvent('ulc:StopCheckingReverseState')
    end
  end)
end)

-- used to hide the hud
RegisterNetEvent('ulc:cleanup')
AddEventHandler('ulc:cleanup', function()
  MyVehicle = nil
  MyVehicleConfig = nil
  -- hide hud
  SendNUIMessage({
    type = 'hideLightsHUD',
  })
end)

-----------------
-- CONFIG SYNC --
-----------------

RegisterNetEvent('UpdateVehicleConfigs', function(newData)
  print("[ULC] Updating vehicle table. Done loading.")
  Config.Vehicles = newData
end)

---------
-- IDK --
---------

-- i guess this is for when you are in a vehicle and immediately spawn a new one with a menu?
-- not sure, this was a while ago and i didn't comment it : )
CreateThread(function()
  local lastVehicle = nil
  while true do Wait(500)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
      local vehicle = GetVehiclePedIsIn(ped)
      if vehicle ~= lastVehicle then
        TriggerServerEvent('baseevents:enteredVehicle')
      end
      lastVehicle = GetVehiclePedIsIn(ped)
    end
  end
end)