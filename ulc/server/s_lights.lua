--[[
  Fake Environmental Lights - Server
  -----------------------------------
  No gameplay logic runs here - the actual light toggle/sync happens
  client-side via entity state bags (see client/c_lights.lua), which
  replicate automatically without needing a manual relay.

  This file just validates config.lua's FakeEnvSettings on startup, and
  validates each vehicle's fakeEnvConfig as it's reported in by clients,
  reusing the same ulc:error / ulc:warn events s_main.lua uses so problems
  show up consistently in the server console.
]]

local VALID_DIRECTIONS = { left = true, tk = true, right = true }

local function isColorComponentValid(n)
  return type(n) == 'number' and n >= 0 and n <= 255
end

-------------------
-- Global config validation (runs once on resource start)
-------------------

CreateThread(function()
  local s = Config.FakeEnvSettings
  if not s then
    TriggerEvent('ulc:error', 'Config.FakeEnvSettings is missing - fake environmental lights will not work.')
    return
  end

  if type(s.enabled) ~= 'boolean' then
    TriggerEvent('ulc:error', 'Config.FakeEnvSettings.enabled must be true or false.')
  end

  if not (isColorComponentValid(s.color.r) and isColorComponentValid(s.color.g) and isColorComponentValid(s.color.b)) then
    TriggerEvent('ulc:error', 'Config.FakeEnvSettings.color values must each be between 0 and 255.')
  end

  if s.sideDistance < 0 or s.frontDistance < 0 or s.lightRange < 0 or s.lightIntensity < 0
    or s.drawRange < 0 then
    TriggerEvent('ulc:error',
      'Config.FakeEnvSettings sideDistance/frontDistance/lightRange/lightIntensity/drawRange cannot be negative.')
  end

  for direction, key in pairs(s.defaultKeys) do
    if not VALID_DIRECTIONS[direction] then
      TriggerEvent('ulc:error',
        'Config.FakeEnvSettings.defaultKeys has an invalid direction "' .. tostring(direction) .. '". Must be left, tk, or right.')
    end
  end

  if not Config.HornSettings then
    TriggerEvent('ulc:error', 'Config.HornSettings is missing - horn hold timing will fall back to instant on/off.')
  elseif Config.HornSettings.defaultHoldDelay < 0 or Config.HornSettings.defaultExtraHoldTime < 0 then
    TriggerEvent('ulc:error', 'Config.HornSettings hold/extra times cannot be negative.')
  end
end)

-------------------
-- Per-vehicle config validation
-------------------
-- clients call this once after loading MyVehicleConfig for a vehicle that
-- has fakeEnvConfig.useFakeEnv = true, so misconfigured vehicle resources
-- get flagged in the server console the same way other ULC config issues do

RegisterNetEvent('ulc:lights:reportConfig')
AddEventHandler('ulc:lights:reportConfig', function(resourceName, fakeEnvConfig)
  if not fakeEnvConfig or not fakeEnvConfig.useFakeEnv then return end

  if not fakeEnvConfig.lights or #fakeEnvConfig.lights == 0 then
    TriggerEvent('ulc:warn',
      'A config in "' .. tostring(resourceName) .. '" uses Fake Env Lights, but no lights were specified (lights = {}).')
    return
  end

  local seenDirections = {}

  for _, light in pairs(fakeEnvConfig.lights) do
    if type(light.extra) ~= 'number' then
      TriggerEvent('ulc:error',
        'A config in "' .. tostring(resourceName) .. '" has a fakeEnvConfig light with a missing/invalid extra number.')
    end

    if not VALID_DIRECTIONS[light.direction] then
      TriggerEvent('ulc:error',
        'A config in "' .. tostring(resourceName) .. '" has a fakeEnvConfig light with an invalid direction "' ..
        tostring(light.direction) .. '". Must be left, tk, or right.')
    elseif seenDirections[light.direction] then
      TriggerEvent('ulc:warn',
        'A config in "' .. tostring(resourceName) .. '" has more than one fakeEnvConfig light using direction "' ..
        light.direction .. '" - only the last one registered will be reachable by its keybind.')
    else
      seenDirections[light.direction] = true
    end
  end
end)