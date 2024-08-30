print("[ULC] LVC Integrations Loaded")

-- going to store the LVC siren state just for fun
LVC_SirenState = 0

-- received from s_lvc.lua when player changes main siren state in LVC
-- sirenId is an int representing the index of a siren in lvc/SIRENS.lua:SIRENS
RegisterNetEvent("ulc:LVC_MainSirenStateChange")
AddEventHandler("ulc:LVC_MainSirenStateChange", function(sirenId)
  print("[ulc:LVC_MainSirenStateChange] " .. sirenId)
  -- # TODO check how much of this is actually needed
  if not MyVehicle then return end
  if not MyVehicleConfig.luxartVehicleControlConfig then return end
  if not MyVehicleConfig.luxartVehicleControlConfig.useLVC then return end

  local config = MyVehicleConfig.luxartVehicleControlConfig

  -- if sirenId is not in the config, return
  if not MyVehicleConfig.luxartVehicleControlConfig[sirenId] then
    print("[ULC: LVC_MainSirenStateChange()] siren [" ..
      sirenId .. "] is not defined in MyVehicleConfig.luxartVehicleControlConfig")
    return false
  end

  for _, v in pairs(config[sirenId].enable) do
    ULC:SetStage(v, 0, false, false, false, false, false, false)
  end

  for _, v in pairs(config[sirenId].disable) do
    ULC:SetStage(v, 1, false, false, false, false, false, false)
  end
end)
