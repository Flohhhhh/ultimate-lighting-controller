--print("[ULC]: Main Thread Loaded")

ULC = {}

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

if Config.controlLights then
  RegisterCommand('ulc:toggleLights', function()
    if Lights then
      SetVehicleSiren(MyVehicle, false)
    else
      SetVehicleSiren(MyVehicle, true)
    end
  end)

  RegisterKeyMapping('ulc:toggleLights', 'Toggle Emergency Lights', 'keyboard', 'q')
end

AddEventHandler('ulc:lightsOn', function()
  --print("Lights On")
  -- set Lights on
  Lights = true
  setDefaultStages()
  -- check if parked or driving for park patterns
  TriggerEvent('ulc:checkParkState', GetVehiclePedIsIn(PlayerPedId()), false)
  SendNUIMessage({
    type = 'toggleIndicator',
    state = Lights
  })
  if Config.controlLights then
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
  if Config.controlLights then
    PlayBeep(false)
  end
end)

-- check if lights are on 10 times a second;
-- used to trigger above events
CreateThread(function()
  local sleep = 1000
  while true do
    Wait(sleep)
    if not MyVehicle then
      sleep = 1000
      goto continue
    end
    sleep = 100

    if not IsPedInAnyVehicle(PlayerPedId()) then goto continue end
    if IsVehicleSirenOn(GetVehiclePedIsIn(PlayerPedId())) then
      if not Lights then
        TriggerEvent('ulc:lightsOn')
      end
    else
      if Lights then
        TriggerEvent('ulc:lightsOff')
      end
    end

    ::continue::
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
    while not GlobalState.ulcloaded do
      print("ULC: Waiting for load.")
      Wait(250)
    end
    print("[ULC:checkVehicle] Checking for vehicle configuration")
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local passed, vehicleConfig = GetVehicleFromConfig(vehicle)

    --print(passed, vehicleConfig)

    if passed then
      MyVehicle = vehicle
      MyVehicleConfig = vehicleConfig
      table.sort(MyVehicleConfig.buttons, function(a, b) return a["key"] < b["key"] end)


      print("[ULC:checkVehicle] Found vehicle, ready to go.")

      -- if i am driver
      if ped == GetPedInVehicleSeat(vehicle, -1) then
        ULC:PopulateButtons(MyVehicleConfig.buttons)
        --ShowHelp()
        if not Config.hideHud and ClientPrefs.hideUi == 0 then
          ULC:SetDisplay(true)
        else
          print(
            "HUD is hidden. Type /ulc to see if you disabled it. Otherwise, the server owner may have disabled the HUD.")
        end

        TriggerEvent('ulc:CheckCruise')
        TriggerEvent('ulc:checkParkState', true)
        TriggerEvent('ulc:StartCheckingReverseState')
        currentStage = 0
      end
    else
      MyVehicle = nil
      TriggerEvent('ulc:cleanup')
      TriggerEvent('ulc:StopCheckingReverseState')
    end
  end)
end)

-- used to hide the hud
RegisterNetEvent('ulc:cleanup')
AddEventHandler('ulc:cleanup', function()
  -- MyVehicle = nil
  -- MyVehicleConfig = nil
  ULC:SetDisplay(false)
  -- hide hud
  -- SendNUIMessage({
  --   type = 'hideLightsHUD',
  -- })
end)

-----------------
-- CONFIG SYNC --
-----------------

RegisterNetEvent('UpdateVehicleConfigs', function(newData)
  print("[ULC] Updating vehicle table. Done loading.")
  Config.Vehicles = newData
end)

-- trigger checks when spawning from one vehicle into another directly, or from another seat to driver seat
CreateThread(function()
  local lastVehicle
  local wasDriving
  while true do
    Wait(500)
    if IsPedInAnyVehicle(PlayerPedId()) then
      local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
      local driving = GetPedInVehicleSeat(MyVehicle, -1) == PlayerPedId()
      if currentVehicle ~= lastVehicle then
        TriggerEvent('ulc:checkVehicle')
      end
      if MyVehicle and not wasDriving and driving then
        TriggerEvent('ulc:checkVehicle')
      end
      lastVehicle = currentVehicle
      wasDriving = driving
    end
  end
end)


-------------------------
-------------------------
-- AUTO REPAIR HANDLER --
-------------------------
-------------------------

-- every second set no repair on all vehicles except my own
CreateThread(function()
  while true do
    Wait(1000)
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
