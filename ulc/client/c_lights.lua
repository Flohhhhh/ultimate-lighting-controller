--[[
  Fake Environmental Lights
  --------------------------
  Toggles a light-head extra's mesh only (no real environmental lighting
  running behind it) and draws a real point light near the vehicle in that
  light's direction, sized and positioned to read as a proper pool of
  light rather than a dim blob - meant for things like TKDs/alleys where
  you don't want the cost of a real environmental extra running full time.

  Synced to nearby players via an entity state bag on the vehicle, so
  passengers/bystanders see the same fake light the driver does, not just
  the driver.
]]

print("[ULC] Lights (Fake Env) Loaded")

local STATEBAG_KEY = 'ulc:fakeLights'

-- vehicle handle -> { [extra] = direction, ... }
-- covers both our own vehicle and any nearby synced vehicles
local vehicleLightStates = {}

-------------------
-- Helpers
-------------------

local function getFakeEnvChecksPass()
  if not Config.FakeEnvSettings.enabled then return false end
  if not MyVehicle then return false end
  if not MyVehicleConfig.fakeEnvConfig then return false end
  if not MyVehicleConfig.fakeEnvConfig.useFakeEnv then return false end
  if not MyVehicleConfig.fakeEnvConfig.lights then return false end
  return true
end

local function getLightConfigByDirection(direction)
  for _, v in pairs(MyVehicleConfig.fakeEnvConfig.lights) do
    if v.direction == direction then return v end
  end
  return nil
end

-- computes the world position the light sits at for a given direction -
-- left/right offset out to the side of the vehicle, tk (take-down) offsets
-- forward, all raised up above the vehicle so it reads as a light source
-- sitting above/beside it rather than something glued to the bodywork
local function getLightOrigin(vehicle, direction)
  local s = Config.FakeEnvSettings
  local sideOffset, frontOffset = 0.0, 0.0

  if direction == 'left' then
    sideOffset = -s.sideDistance
  elseif direction == 'right' then
    sideOffset = s.sideDistance
  elseif direction == 'tk' then
    frontOffset = s.frontDistance
  end

  return GetOffsetFromEntityInWorldCoords(vehicle, sideOffset, frontOffset, s.heightOffset)
end

local function pushOwnStatebag()
  if not MyVehicle then return end
  Entity(MyVehicle).state:set(STATEBAG_KEY, vehicleLightStates[MyVehicle] or {}, true)
end

-------------------
-- Toggle logic (local vehicle only - other players just receive our state bag)
-------------------

function ULC:ToggleFakeEnvLight(direction)
  if not getFakeEnvChecksPass() then return end

  local lightCfg = getLightConfigByDirection(direction)
  if not lightCfg then
    print("[ULC:ToggleFakeEnvLight] No fake env light configured for direction: " .. tostring(direction))
    return
  end

  -- extraOnly = true, forceUi = true: toggle only this extra's mesh, don't
  -- chain into linked/opposite/off extras or stage logic. Purely visual.
  -- hornOverride = true: fake env/scene lights are meant to stay usable
  -- even while horn extras (Intersection Mode) are active.
  ULC:SetStage(lightCfg.extra, 2, true, true, false, false, true, false, true)

  vehicleLightStates[MyVehicle] = vehicleLightStates[MyVehicle] or {}

  if IsVehicleExtraTurnedOn(MyVehicle, lightCfg.extra) then
    vehicleLightStates[MyVehicle][lightCfg.extra] = direction
  else
    vehicleLightStates[MyVehicle][lightCfg.extra] = nil
  end

  pushOwnStatebag()
end

-- called whenever the vehicle changes/despawns so we don't try to draw
-- lights against a stale/invalid vehicle handle, and so the old vehicle's
-- state bag is cleared for other players
local lastVehicle = nil
AddEventHandler('ulc:checkVehicle', function()
  if lastVehicle and DoesEntityExist(lastVehicle) then
    vehicleLightStates[lastVehicle] = nil
    Entity(lastVehicle).state:set(STATEBAG_KEY, {}, true)
  end
  lastVehicle = MyVehicle

  -- ask the server to sanity-check this vehicle's fakeEnvConfig, results show
  -- up in the server console (see server/s_lights.lua)
  if MyVehicleConfig and MyVehicleConfig.fakeEnvConfig and MyVehicleConfig.fakeEnvConfig.useFakeEnv then
    TriggerServerEvent('ulc:lights:reportConfig', GetCurrentResourceName(), MyVehicleConfig.fakeEnvConfig)
  end
end)

-------------------
-- Remote sync (other players' vehicles)
-------------------

AddStateBagChangeHandler(STATEBAG_KEY, nil, function(bagName, _, value)
  local vehicle = GetEntityFromStateBagName(bagName)
  if not vehicle or vehicle == 0 then return end
  -- our own vehicle is driven locally by the toggle function above, ignore echoes
  if vehicle == MyVehicle then return end

  if value and next(value) then
    vehicleLightStates[vehicle] = value
  else
    vehicleLightStates[vehicle] = nil
  end
end)

-------------------
-- Draw loop
-------------------

CreateThread(function()
  while true do
    local sleep = 250

    if next(vehicleLightStates) then
      sleep = 0

      local playerCoords = GetEntityCoords(PlayerPedId())
      local s = Config.FakeEnvSettings

      for vehicle, lights in pairs(vehicleLightStates) do
        if DoesEntityExist(vehicle) then
          local vehCoords = GetEntityCoords(vehicle)

          if #(playerCoords - vehCoords) <= s.drawRange then
            for extra, direction in pairs(lights) do
              if IsVehicleExtraTurnedOn(vehicle, extra) then
                local origin = getLightOrigin(vehicle, direction)
                DrawLightWithRange(
                  origin.x, origin.y, origin.z,
                  s.color.r, s.color.g, s.color.b,
                  s.lightRange, s.lightIntensity
                )
              elseif vehicle == MyVehicle then
                -- our own extra was turned off some other way (blackout, respray) - clean up and re-sync
                lights[extra] = nil
                pushOwnStatebag()
              end
            end
          end
        else
          -- vehicle despawned/out of range, drop it
          vehicleLightStates[vehicle] = nil
        end
      end
    end

    Wait(sleep)
  end
end)

-------------------
-- Keybinds
-------------------
-- keys are read from Config.FakeEnvSettings.defaultKeys so server owners can
-- change the default bind without editing this file. Players can still
-- rebind in FiveM's keybind settings (Ultimate Lighting Controls category)
-- same as every other ULC keybind.

RegisterKeyMapping('ulc:fakeenv_left', 'ULC: Toggle Fake Left Alley Light', 'keyboard', Config.FakeEnvSettings.defaultKeys.left)
RegisterCommand('ulc:fakeenv_left', function()
  ULC:ToggleFakeEnvLight('left')
end)

RegisterKeyMapping('ulc:fakeenv_tk', 'ULC: Toggle Fake Take-Down Light', 'keyboard', Config.FakeEnvSettings.defaultKeys.tk)
RegisterCommand('ulc:fakeenv_tk', function()
  ULC:ToggleFakeEnvLight('tk')
end)

RegisterKeyMapping('ulc:fakeenv_right', 'ULC: Toggle Fake Right Alley Light', 'keyboard', Config.FakeEnvSettings.defaultKeys.right)
RegisterCommand('ulc:fakeenv_right', function()
  ULC:ToggleFakeEnvLight('right')
end)