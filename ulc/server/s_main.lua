local myVersion = 'v1.1.0'
local latestVersion = ''
GlobalState.ulcloaded = false

AddEventHandler('ulc:error', function(error)
  print("^1[ULC ERROR] " .. error)
end)

AddEventHandler('ulc:warn', function(error)
  print("^3[ULC WARNING] " .. error)
end)


PerformHttpRequest("https://api.github.com/repos/Flohhhhh/ultimate-lighting-controller/releases/latest", function (errorCode, resultData, resultHeaders)

  print("My Version: [" .. myVersion .. "]")

  local errorString = tostring(errorCode)
  if errorString == "403" or errorString == "404" then
    print("Got code " .. errorString .. " when trying to get version.")
    return
  end

  latestVersion = json.decode(resultData).name
  print("^0Latest Version: [" .. latestVersion .. "]")

  print([[
    ___  ___   ___        ________     
   |\  \|\  \ |\  \      |\   ____\    
   \ \  \\\  \\ \  \     \ \  \___|    
    \ \  \\\  \\ \  \     \ \  \       
     \ \  \\\  \\ \  \____ \ \  \____  
      \ \_______\\ \_______\\ \_______\
       \|_______| \|_______| \|_______|
  
    ULTIMATE LIGHTING CONTROLLER
    by Dawnstar
    ^2Loaded
 ]])
  if myVersion == latestVersion then
    print('Up to date!')
  else
    print("^1ULC IS OUTDATED. A NEW VERSION (" .. latestVersion .. ") IS AVAILABLE.^0")
    print("^1YOUR VERSION: " .. myVersion .. "^0")
  end
end)


local function IsIntInTable(table, int)
  for k, v in ipairs(table) do
      if v == int then
          return true
      end
  end
  return false
end

if Config.ParkSettings.delay < 0.5 then
    TriggerEvent("ulc:warn", 'Park Pattern delay is too short! This will hurt performance! Recommended values are above 0.5s.')
end

if Config.SteadyBurnSettings.delay <= 2 then
    TriggerEvent("ulc:error", 'Steady burn delay is too short! Steady burns will be unstable or not work!')
end

if Config.SteadyBurnSettings.nightStartHour < Config.SteadyBurnSettings.nightEndHour then
    TriggerEvent("ulc:error", 'Steady burn night start hour should be later/higher than night end hour.')
end

if Config.SteadyBurnSettings.delay < 2 then
    TriggerEvent("ulc:error", "Steady burn check delay can never be lower than 2 seconds. Will cause stability issues.")
end

local function CheckData(data, resourceName)

  if not data.name then
      TriggerEvent("ulc:error", "^1Vehicle config in resource \"" .. resourceName .. "\" does not include a name!^0")
      return false
  end

  if not data.parkConfig or not data.brakeConfig or not data.buttons or not data.hornConfig then
    TriggerEvent("ulc:error", "^1Vehicle config in resource \"" .. resourceName .. "\" is missing data or not formatted properly.^0")
    return false
  end

  -- check if steady burns are enabled but no extras specified
  if (data.steadyBurnConfig.forceOn or data.steadyBurnConfig.useTime) and #data.steadyBurnConfig.sbExtras == 0 then
      TriggerEvent("ulc:warn", '"' .. data.name .. '"uses Steady Burns, but no extras were specified (sbExtras = {})')
  end

  -- check if park pattern enabled but no extras specified
  if data.parkConfig.usePark then
      if #data.parkConfig.pExtras == 0 and #data.parkConfig.dExtras == 0 then
          TriggerEvent("ulc:warn", '"' .. data.name .. '" uses Park Pattern is enabled, but no park or drive extras were specified (pExtras = {}, dExtras = {})')
      end
  end

  -- check if brakes enabled but no extras specified
  if data.brakeConfig.useBrakes and #data.brakeConfig.brakeExtras == 0 then
      TriggerEvent("ulc:warn", '"' .. data.name .. '" uses Brake Pattern, but no brake extras were specified.')
  end

  -- check if horn enabled but no extras specified
  if data.hornConfig.useHorn and #data.hornConfig.hornExtras == 0 then
    TriggerEvent("ulc:warn", '"' .. data.name .. '" uses Horn Extras, but no horn extras were specified.')
  end

  local usedButtons = {}
  local usedExtras = {}
  for i, b in ipairs(data.buttons) do
      -- check if key is valid
      if b.key > 9 or b.key < 1 then
          Trigger('ulc:error', '"' .. data.name .. '" button ".. i .. " key is invalid. Key must be 1-9 representing number keys.')
          return false
      end
      -- check if label is empty
      if b.label == '' then
          TriggerEvent("ulc:error", '"' .. data.name .. '" has an unlabeled button using extra: ' .. b.extra)
          return false
      end
      -- check if any keys are used twice
      if IsIntInTable(usedButtons, b.key) then
          TriggerEvent("ulc:error", '"' .. data.name .. '" uses key: " .. b.key .. " more than once in button config.')
          return false
      end
      -- check if any extras are used twice
      if IsIntInTable(usedExtras, b.extra) then
          TriggerEvent("ulc:error", '"' .. data.name .. '" uses extra: " .. b.extra .. " more than once in button config.')
          return false
      end
  end
  return true
end

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function()
  local src = source
  TriggerClientEvent('ulc:checkVehicle', src)
end)

RegisterNetEvent('baseevents:leftVehicle')
AddEventHandler('baseevents:leftVehicle', function()
  local src = source
  TriggerClientEvent('ulc:cleanupHUD', src)
end)

RegisterNetEvent('ulc:sync:send')
AddEventHandler('ulc:sync:send', function(vehicles)
    print("Player ".. source .. " sent a sync request.")
    local players = GetPlayers()
    for i,v in ipairs(players) do
        if not v == source then 
            --print("Sending veh sync array to player: " .. v)
            TriggerClientEvent('ulc:sync:receive', v)
        end
    end
end)


local function LoadExternalVehicleConfig(resourceName)
  local resourceState = GetResourceState(resourceName)

  if resourceState == "missing" then
    TriggerEvent("ulc:error", "^1Couldn't load external ulc.lua file from resource: \"" .. resourceName .. "\". Resource is missing.^0")
    return
  end

  if resourceState == "stopped" then
    TriggerEvent("ulc:error", "^1Couldn't load external ulc.lua file from resource: \"" .. resourceName .. "\". Resource is stopped.^0")
    return
  end

  if resourceState == "uninitialized" or resourceState == "unknown" then
    TriggerEvent("ulc:error", "^1Couldn't load external ulc.lua file from resource: \"" .. resourceName .. "\". Resource could not be loaded. Unknown issue.^0" )
    return
  end

  local data = LoadResourceFile(resourceName, "data/ulc.lua")
  if not data then
    data = LoadResourceFile(resourceName, "ulc.lua")
    if not data then
      print("Error loading 'ulc.lua' file. Make sure it is at the root of your resource or in the 'data' folder.")
      TriggerEvent("ulc:error", '^1Could not load external ulc.lua file for "' .. f().name .. '"^0')
      return
    end
  end

  local f, err = load(data)
  if err then
    print(err)
    return
  end
  if not f then
    return
  end
  if CheckData(f(), resourceName) then
    print('^2Loaded external configuration for "' .. f().name .. '"^0')
    table.insert(Config.Vehicles, f())
  else
    TriggerEvent("ulc:error", '^1Could not load external configuration for "' .. f().name .. '"^0')
  end
end

CreateThread(function ()
  Wait(2000)
  print("[ULC] Checking for external vehicle resources.")
  for k, v in ipairs(Config.ExternalVehResources) do
    local resourceState = GetResourceState(v)
    while resourceState == "starting" do
      print("^3Waiting for resource: " .. resourceName .. " to load.")
      Wait(100)
    end
    LoadExternalVehicleConfig(v)
  end
  GlobalState.ulcloaded = true
  TriggerClientEvent("UpdateVehicleConfigs", -1 , Config.Vehicles)
  print("Done loading external vehicle resources.")
  for k, v in ipairs(Config.Vehicles) do
    print("Loaded : " .. v.name)
  end
end)

