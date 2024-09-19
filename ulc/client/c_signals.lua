local combinedExtrasTable = {}

-- combine all extras from signalConfig into a single array
AddEventHandler("ulc:SetupSignalExtrasTable", function()
  print('[ulc:SetupSignalExtrasTable] Setting up signal extras table')

  local extras = {}


  for side, data in pairs(MyVehicleConfig.signalConfig) do
    print('[ulc:SetupSignalExtrasTable] Hello? ' .. side)
    if side ~= "useSignals" then
      for _, extra in ipairs(data.enable) do
        table.insert(extras, { extra = extra, side = side, state = "enable" })
      end
      for _, extra in ipairs(data.disable) do
        table.insert(extras, { extra = extra, side = side, state = "disable" })
      end
    end
  end

  -- for side, data in pairs(MyVehicleConfig.signalConfig) do
  --   print('[ulc:SetupSignalExtrasTable] Hello? ' .. side)
  --   if side ~= "useSignals" then
  --     for _, extra in ipairs(data.enable) do
  --       table.insert(extras, { extra = extra, side = side, state = "enable" })
  --     end
  --     for _, extra in ipairs(data.disable) do
  --       table.insert(extras, { extra = extra, side = side, state = "disable" })
  --     end
  --   end
  -- end

  combinedExtrasTable = extras

  print('[ulc:SetupSignalExtrasTable] Combined extras table:', json.encode(combinedExtrasTable))
end)

-- IndicatorState and savedExtraStates remain unchanged
IndicatorState = 0
local savedExtraStates = {}

local function saveExtraStates()
  -- get states of all extras listed in signalConfig
  local extras = {}
  for _, side in pairs({ "left", "right", "hazard" }) do
    for _, extra in pairs(MyVehicleConfig.signalConfig[side].enable) do
      extras[extra] = true
    end
    for _, extra in pairs(MyVehicleConfig.signalConfig[side].disable) do
      extras[extra] = false
    end
  end

  -- save the current state of all extras listed in signalConfig
  for extra, _ in pairs(extras) do
    savedExtraStates[extra] = IsVehicleExtraTurnedOn(MyVehicle, extra)
  end
end

local function checks()
  if not IsPedInAnyVehicle(PlayerPedId()) then return false end
  if not MyVehicle then return false end
  if not MyVehicleConfig then return false end
  if not MyVehicleConfig.signalConfig then return false end
  if not MyVehicleConfig.signalConfig.useSignals then return false end
  return true
end

-- loop to get state of indicator lights
CreateThread(function()
  local sleep = 500
  local oldState
  local newState
  while true do
    if not checks() then
      sleep = 500
      goto continue
    end

    sleep = 20
    oldState = IndicatorState
    newState = GetVehicleIndicatorLights(GetVehiclePedIsIn(PlayerPedId(), false))
    if newState ~= IndicatorState then
      print('[ulc:indicatorStateChanged] Indicator state changed from', oldState, 'to', newState)
      TriggerEvent('ulc:indicatorStateChanged', newState, oldState)
      IndicatorState = newState
    end

    ::continue::
    Wait(sleep)
  end
end)

AddEventHandler("ulc:indicatorStateChanged", function(newIndicatorState, oldIndicatorState)
  if not checks() then return end
  local config = MyVehicleConfig.signalConfig

  -- action = 1 to disable, 0 to enable
  local function setIndicatorExtras(action, indicatorStateName)
    -- loop through the combined extras table
    for _, data in ipairs(combinedExtrasTable) do
      if data.side ~= indicatorStateName then return end
      if data.state == "enable" then
        if action == 0 then
          print('[ulc:indicatorStateChanged] Enabling extra', data.extra)
          ULC:SetStage(data.extra, 0, true, false, false, false, false, false)
        elseif action == 1 then
          print('[ulc:indicatorStateChanged] Disabling extra', data.extra)
          ULC:SetStage(data.extra, 1, true, false, false, false, false, false)
        end
      elseif data.state == "disable" then
        if action == 0 then
          print('[ulc:indicatorStateChanged] Disabling extra', data.extra)
          ULC:SetStage(data.extra, 1, true, false, false, false, false, false)
        elseif action == 1 then
          print('[ulc:indicatorStateChanged] Enabling extra', data.extra)
          ULC:SetStage(data.extra, 0, true, false, false, false, false, false)
        end
      end
    end
  end

  if newIndicatorState == 0 then
    setIndicatorExtras(1, "left")
    setIndicatorExtras(1, "right")
    setIndicatorExtras(1, "hazard")
  elseif newIndicatorState == 1 then
    setIndicatorExtras(0, "left")
    setIndicatorExtras(1, "right")
    setIndicatorExtras(1, "hazard")
  elseif newIndicatorState == 2 then
    setIndicatorExtras(1, "left")
    setIndicatorExtras(0, "right")
    setIndicatorExtras(1, "hazard")
  elseif newIndicatorState == 3 then
    setIndicatorExtras(0, "left")
    setIndicatorExtras(0, "right")
    setIndicatorExtras(1, "hazard")
  end
end)
