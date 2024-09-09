--print("[ULC]: Stage Controls Loaded")

-------------------
-------------------
----- HELPERS -----
-------------------
-------------------

function GetExtraByKey(key)
    local result = nil
    for _, v in pairs(MyVehicleConfig.buttons) do
        if v.key == key then
            result = v.extra
        end
    end
    return result
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

function ULC:ChangeExtra(extra, newState, repair)
    --print("[ULC:ChangeExtra()] Changing extra: " .. extra .. " to: " .. newState)
    -- disable repair
    if not repair then
        SetVehicleAutoRepairDisabled(MyVehicle, true)
    end
    -- change extra
    SetVehicleExtra(MyVehicle, extra, newState)
    -- fix deformation if repair is true
    if repair then
        SetVehicleDeformationFixed(MyVehicle)
    end
    -- enable repair
    SetVehicleAutoRepairDisabled(MyVehicle, false)
end

---------------
---------------
-- MAIN CODE --
---------------
---------------

-- new event
AddEventHandler('ulc:SetStage', function(extra, action, playSound, extraOnly, repair, forceChange, forceUi)
    ULC:SetStage(extra, action, playSound, extraOnly, repair, forceChange, forceUi)
end)

-- change specified extra, and if not extraOnly, and extra is in a button, act on the linked and off extras as well, acts recursively;
-- action 0 enables, 1 disables, 2 toggles;
-- updates ui whenever extra is used in a button
function ULC:SetStage(extra, action, playSound, extraOnly, repair, forceChange, forceUi, allowOutside)
    ----------
    -- checks
    if not MyVehicle then
        print("[ULC:SetStage()] MyVehicle is not defined right now :/")
        return false
    end
    if not allowOutside and not IsPedInAnyVehicle(PlayerPedId(), false) then
        print("[ULC:SetStage()] Player must be in a vehicle, or allowOutside must be true.")
        return false
    end

    --print("[ulc:SetStage]", extra, action, playSound, extraOnly)

    --------------
    -- definitions
    local button = GetButtonByExtra(extra)
    local buttonStates = {} -- track button states for UI

    --------------------------
    -- determine the new state
    local newState
    if IsVehicleExtraTurnedOn(MyVehicle, extra) then
        if action == 1 or action == 2 then
            newState = 1
        end
    else
        if action == 0 or action == 2 then
            newState = 0
        end
    end

    ---------------------------------------------------------
    -- built in don't try to change if it's the same already!
    --[[ forceChange is used to forceChange the change even if it's the same
    this is used to trigger the additional actions like linked and off extras
    even if the extra is already in the state we want it to be
    (used in cycling stages and one other place i cant remember)]]
    if not forceChange and not newState then return end

    local canChange = true
    if repair then
        if not AreVehicleDoorsClosed(MyVehicle) then
            canChange = false
            print("[ULC:SetStage] Can't change stage with repair while a door is open.")
        end
        if not IsVehicleHealthy(MyVehicle) then
            canChange = false
            print("[ULC:SetStage] Can't change stage with repair while vehicle is damaged.")
        end
    end

    if not canChange then return end

    ---------------------------------------
    -- if the extra corresponds to a button
    if button then
        --------------------
        -- sound
        if playSound then
            if newState == 0 then
                PlayBeep(true)
            else
                PlayBeep(false)
            end
        end

        ----------------------
        -- smart stages stuff
        local key = button.key
        if MyVehicleConfig.stages then
            local keyStage = contains(MyVehicleConfig.stages.stageKeys, key) -- find whether MyVehicleConfig.stages.stageKeys contain the key

            -- # TODO we're not getting here for some reason when cycling stages at max stage
            -- if the key pressed is not a stage, just change the extra
            if not keyStage then
                ULC:ChangeExtra(extra, newState, repair)
            end

            -- if the key pressed is a stage and extraOnly is false
            if keyStage and not extraOnly then
                print("key: " .. key .. " keyStage: " .. tostring(keyStage) .. " currentStage: " .. currentStage)
                -- if it's the same as the current stage, change the extra and proceed normally
                if keyStage == currentStage then
                    print("Key is the same as current stage")
                    ULC:ChangeExtra(extra, newState, repair)
                    -- set the stage to 0
                    print("Setting stage to: 0")
                    currentStage = 0
                else
                    -- if it's a different stage then we want to change to a state where that stage is enabled
                    print("Key is not the same as current stage")
                    newState = 0 -- change to newState to 0 since we want the new stage to be enabled

                    local currentPrimaryExtraState = IsVehicleExtraTurnedOn(MyVehicle, extra)
                    print("New state: " ..
                        newState .. "Extra " .. extra .. " current state: " .. tostring(currentPrimaryExtraState))

                    if not IsVehicleExtraTurnedOn(MyVehicle, extra) and newState == 0 then
                        print("Extra needs to be turned on")
                        ULC:ChangeExtra(extra, newState, repair)
                    elseif IsVehicleExtraTurnedOn(MyVehicle, extra) and newState == 1 then
                        print("Extra needs to be turned off")
                        ULC:ChangeExtra(extra, newState, repair)
                    else
                        -- if it's in the correct state
                        print("Extra is already in the correct state")
                    end
                    -- set the new stage
                    print("Setting stage to: " .. keyStage)
                    currentStage = keyStage
                end
            else -- if extraOnly is true
                ULC:ChangeExtra(extra, newState, repair)
            end
        else
            -- if there are no stages, just change the extra
            ULC:ChangeExtra(extra, newState, repair)
        end


        ----------------------
        -- initialize UI changes
        -- add that button to the new button states for UI with it's extra and new state
        table.insert(buttonStates, { extra = extra, newState = newState })

        -----------------------------
        -- additional actions/extras
        if not extraOnly then
            -- set linked extras
            if button.linkedExtras then
                for _, v in ipairs(button.linkedExtras) do
                    ULC:SetStage(v, newState, false, true, repair, forceChange)
                    -- add linked buttons to the new button states for UI with their extras and new state
                    table.insert(buttonStates, { extra = v, newState = newState })
                end
            end

            -- set opposite extras
            if button.oppositeExtras or false then -- in case they have old config without the feature
                local oppState
                if newState == 1 then oppState = 0 elseif newState == 0 then oppState = 1 end
                for _, v in pairs(button.oppositeExtras) do
                    ULC:SetStage(v, oppState, false, true, repair, forceChange)
                    -- add opposite buttons to the new button states for UI with their extras and new state
                    table.insert(buttonStates, { extra = v, newState = oppState })
                end
            end

            -- set off extras
            if button.offExtras then
                for _, v in ipairs(button.offExtras) do
                    ULC:SetStage(v, 1, false, true, repair, forceChange)
                    -- add off buttons to the new button states for UI with their extras and new state
                    table.insert(buttonStates, { extra = v, newState = 1 })
                end
            end
        end

        if not extraOnly or forceUi then
            -- update UI
            ULC:SetButtons(buttonStates)
        end
    else -- if it's not a button, we just change the extra because we don't care about stages or linked extras etc.
        ULC:ChangeExtra(extra, newState, repair)
    end
end

-----------------------
-----------------------
------ KEYBINDS -------
-----------------------
-----------------------

for i = 1, 9, 1 do
    RegisterKeyMapping('ulc:num' .. i, 'ULC: Toggle Button ' .. i, 'keyboard', 'NUMPAD' .. i)
    RegisterCommand('ulc:num' .. i, function()
        local extra = GetExtraByKey(i)
        local button = GetButtonByExtra(extra)
        if not button then return end
        ULC:SetStage(extra, 2, true, false, button.repair or false)
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
