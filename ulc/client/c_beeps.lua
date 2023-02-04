
-------------------------
--------- SOUND ---------
-------------------------

function PlayBeep(highPitched)
    if highPitched then
        PlaySoundFrontend(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 1)
    else
        PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
    end
end

--[[
coming soon, once client options arrive it will be opt in per client

---------------
-- REMINDERS --
---------------
local mute = false

if Config.reminderBeeps then
    CreateThread(function()
        while true do Wait(Config.reminderBeepTime * 1000)
            if Lights and not mute then PlayBeep(false) end
        end
    end)
end

RegisterCommand('mutelights', function()
    mute = not mute
    if mute then
        print("Lighting reminders muted.")
    else
        print("Lighting reminders unmuted.")
    end
end)
]]