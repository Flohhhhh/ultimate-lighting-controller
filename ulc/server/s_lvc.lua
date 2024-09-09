print("[ULC] LVC Integrations Loaded")

-- triggers when player changes main siren state in LVC
-- newState is an int representing the index of a siren in lvc/SIRENS.lua:SIRENS
RegisterNetEvent("lvc:SetLxSirenState_s")
AddEventHandler("lvc:SetLxSirenState_s", function(newState)
  local src = source
  print("[lvc:SetLxSirenState_s] " .. src .. " " .. newState)
  TriggerClientEvent("ulc:LVC_MainSirenStateChange", src, newState)
end)

-- TODO: this isn't use anywhere yet
