print("[ULC]: Stage Controls Loaded")

-------------------
-------------------
----- HELPERS -----
-------------------
-------------------

function GetExtraByKey(key)
    for _, v in pairs(MyVehicleConfig.buttons) do
        if v.key == key then return v.extra end
    end
end

function GetButtonByExtra(extra)
    local result = nil
    for _, v in pairs(MyVehicleConfig.buttons) do
        if v.extra == extra then
            result = v
        end
    end
    return result
end

---------------
---------------
-- MAIN CODE --
---------------
---------------

-- new event
AddEventHandler('ulc:SetStage', function(extra, action, playSound, extraOnly)
    ULC:SetStage(extra, action, playSound, extraOnly)
end)

-- change specified extra, and if not extraOnly, and extra is in a button, act on the linked and off extras as well, acts recursively;
-- action 0 enables, 1 disables, 2 toggles;
-- updates ui whenever extra is used in a button
function ULC:SetStage(extra, action, playSound, extraOnly)
    if not MyVehicle then print("[ULC:SetStage()] MyVehicle is not defined right now :/") return false end

    local newState
    --print("[ulc:SetStage]", extra, action, playSound, extraOnly)
    
    if IsVehicleExtraTurnedOn(MyVehicle, extra) then
        if action == 1 or action == 2 then
            newState = 1
        end
    else
        if action == 0 or action == 2 then
            newState = 0
        end
    end

    -- built in don't try to change if it's the same already!
    if not newState then return end



    -- disable repair
    SetVehicleAutoRepairDisabled(MyVehicle, true)
    -- change extra
    SetVehicleExtra(MyVehicle, extra, newState)
    -- enable repair
    SetVehicleAutoRepairDisabled(MyVehicle, false)

    -- if the extra corresponds to a button
    local button = GetButtonByExtra(extra)
    if button then
        
        if playSound then
            if newState == 0 then
                PlayBeep(true)
            else
                PlayBeep(false)
            end
        end

        if not extraOnly then
            -- set linked extras
            for _, v in ipairs(button.linkedExtras) do
                ULC:SetStage(v, newState, false, true)
            end

            -- set off extras
            for _, v in ipairs(button.offExtras) do
                ULC:SetStage(v, 1, false, true)
            end
        end

        -- update ui
        SendNUIMessage({
            type = 'setButton',
            extra = extra,
            state = newState
        })
    end
end
-----------------------
-----------------------
------ KEYBINDS -------
-----------------------
-----------------------

for i = 1, 9, 1 do
    RegisterKeyMapping('ulc:num' .. i, 'Toggle ULC Slot ' .. i , 'keyboard', 'NUMPAD' .. i)
    RegisterCommand('ulc:num' .. i, function()
        TriggerEvent('ulc:SetStage', GetExtraByKey(i), 2, true, false)
    end)
end

------------------
------ HELP ------
------------------

local activeButtons = {}
local showingHelp = false

function ShowHelp()
    CreateThread(function()
      if not showingHelp then
        -- show help
        showingHelp = true
        for k, v in ipairs(activeButtons) do
          --print('Showing help for button: ' .. k .. ' : ' .. v.key)
          SendNUIMessage({
            type = 'showHelp',
            button = k,
            key = v.key,
          })
        end
        Wait(3000)
        -- hide help
        showingHelp = false
        for k, v in ipairs(activeButtons) do
          SendNUIMessage({
            type = 'hideHelp',
            button = k,
            label = string.upper(v.label),
          })
        end
      end
    end)
end


