print("[ULC] Stages Loaded")

-- Definitions
-- # TODO maybe currentStage should not be 0 when entering a vehicle?
--[[ # TODO this file does not handle setting the currentStage, instead ULC:SetStage does,
may want to change this if possible, leads to hacky stuff like in CycleStage function ]]
-- this is set to 0 whenever ulc:checkVehicle is triggered
currentStage = 0


-- helpers
local function checks()
  if not MyVehicle then return end
  if not MyVehicleConfig.stages then return end
  if not MyVehicleConfig.stages.useStages then return end
  if not MyVehicleConfig.stages.stageKeys
  then
    return false
  end
  return true
end

function getMaxStage()
  if not MyVehicle then return end
  if not MyVehicleConfig.stages then return end
  if not MyVehicleConfig.stages.stageKeys then return end
  return #MyVehicleConfig.stages.stageKeys
end

-- main functions
function stageUp()
  print("[ULC:stageUp] Increasing stage from " .. currentStage)
  if currentStage == getMaxStage() then
    print("Already at max stage")
    return
  end

  -- this is handled in ULC:SetStage?
  -- currentStage = currentStage + 1
  -- instead we just want to keep track locally
  local nextStage = currentStage + 1

  -- # TODO might want to check if the key is actually a button that exists (maybe do this in the initial checks when script starts?)
  local key = MyVehicleConfig.stages.stageKeys[nextStage]

  local extra = GetExtraByKey(key)
  local button = GetButtonByExtra(extra)
  if not button then
    print("[stageUp()] Could not find button for extra " .. extra)
    return
  end
  print("Setting stage to: " .. nextStage .. " using key " .. key .. " with extra " .. extra)
  ULC:SetStage(extra, 0, true, false, button.repair or false, false, true, false)
end

function stageDown()
  print("[ULC:stageDown] Decreasing stage from " .. currentStage)
  if currentStage == 0 then
    print("Already stage 0")
    return
  end

  -- this is handled in ULC:SetStage?
  -- currentStage = currentStage - 1
  -- instead we just want to keep track locally
  local nextStage = currentStage - 1

  -- # TODO might want to check if the key is actually a button that exists (maybe do this in the initial checks when script starts?)
  local key = MyVehicleConfig.stages.stageKeys[nextStage]
  local extra = GetExtraByKey(key)
  local button = GetButtonByExtra(extra)
  if not button then
    print("[stageDown()] Could not find button for extra " .. extra)
    return
  end
  print("Setting stage to: " .. nextStage .. " using key " .. key .. " with extra " .. extra)
  ULC:SetStage(extra, 0, true, false, button.repair or false, false, true, false)
end

function cycleStages()
  if not checks() then return end
  if currentStage == getMaxStage() then
    print("Tried to cycle stages at max stage, resetting to 0")
    -- we need to turn off the current stage
    local key = MyVehicleConfig.stages.stageKeys[currentStage]
    local extra = GetExtraByKey(key)
    local button = GetButtonByExtra(extra)
    if not button then
      print("[cycleStages()] Could not find button for extra " .. extra)
      return
    end
    print("Setting stage to: 0 using key " .. key .. " with extra " .. extra)
    ULC:SetStage(extra, 1, true, false, button.repair or false, true, true, false)
    return
  end
  stageUp()
end

-- Keybinds
RegisterKeyMapping("ulc:stage_down", "ULC: Stage Down", "keyboard", "SUBTRACT")
RegisterCommand("ulc:stage_down", function()
  if not checks() then return end
  stageDown()
end)

RegisterKeyMapping("ulc:stage_up", "ULC: Stage Up", "keyboard", "ADD")
RegisterCommand("ulc:stage_up", function()
  if not checks() then return end
  stageUp()
end)

RegisterKeyMapping("ulc:stage_cycle", "ULC: Cycle Stages", "keyboard", "NUMPAD0")
RegisterCommand("ulc:stage_cycle", function()
  if not checks() then return end
  cycleStages()
end)

--------------------
--------------------
-- DEFAULT STAGES --
--------------------
--------------------

-- checks if the button.key is contained in the stageKeys array and returns the index
function getStageFromButton(button)
  if not button then return false end
  if not MyVehicle then return false end
  -- if MyVehicleConfig.stages.stageKeys is nil or doesn't contain the button.key return false
  if not MyVehicleConfig.stages.stageKeys then return false end
  for i, key in pairs(MyVehicleConfig.stages.stageKeys) do
    if key == button.key then
      return i
    end
  end
  return false
end

function setDefaultStages()
  -- default stages
  if not MyVehicleConfig.defaultStages or false then return end
  if not MyVehicleConfig.defaultStages.useDefaults then return end
  for _, e in pairs(MyVehicleConfig.defaultStages.enableKeys) do
    local button = GetButtonByExtra(GetExtraByKey(e))
    if not button then break end
    -- if the button is a stage
    local stage = getStageFromButton(button)
    -- if the index of this stage = the current stage do nothing
    if stage and stage == currentStage then return end
    -- if this button is not a stage or the stage is not the current stage proceed normally
    ULC:SetStage(GetExtraByKey(e), 0, false, false, button.repair, true, true, false)
  end
  for _, d in pairs(MyVehicleConfig.defaultStages.disableKeys) do
    local button = GetButtonByExtra(GetExtraByKey(d))
    if not button then break end
    ULC:SetStage(GetExtraByKey(d), 1, false, false, button.repair, true, true, false)
  end
end
