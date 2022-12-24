local myVersion = 'v.1.0.0 Release - Door Fix'
local latestVersion = ''

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function()

  TriggerClientEvent('ulc:checkLightTime', source)
  TriggerClientEvent('ulc:checkVehicle', source)
  TriggerClientEvent('ulc:checkparkState', source, true)

end)

RegisterNetEvent('baseevents:leftVehicle')
AddEventHandler('baseevents:leftVehicle', function()

  TriggerClientEvent('ulc:cleanupHUD', source)

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

RegisterNetEvent('ulc:error', function(error)
  print("^1[ULC ERROR] " .. error)
end)

PerformHttpRequest("https://api.github.com/repos/Flohhhhh/simple-park-patterns/releases/latest", function (errorCode, resultData, resultHeaders)
  print("Returned code" .. tostring(errorCode))
  latestVersion = json.decode(resultData).name

  print("Latest Version: [" .. latestVersion .. "]")
  print("My Version: [" .. myVersion .. "]")
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