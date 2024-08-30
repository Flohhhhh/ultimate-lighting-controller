-- MAIN FUNCTIONS --

function ULC:PopulateButtons(_buttons, placeholders)
    --print("Populating buttons")

    local buttons = _buttons

    if placeholders then
        buttons = {
            { label = 'TEST STAGE', extra = 1, color = 'green', enabled = true },
            { label = 'TEST STAGE', extra = 2, color = 'blue',  enabled = false },
            { label = 'TEST STAGE', extra = 3, color = 'blue',  enabled = false },
            { label = 'TEST STAGE', extra = 4, color = 'blue',  enabled = true },
            { label = 'test stage', extra = 5, color = 'red',   enabled = true }
        }
    end

    local buttonsToSend = {}
    for _, v in pairs(buttons) do
        local thisButton = {}
        local thisState = false
        if IsVehicleExtraTurnedOn(MyVehicle, v.extra) then thisState = true end
        thisButton.extra = v.extra
        thisButton.enabled = thisState
        thisButton.color = v.color or 'green'
        thisButton.label = string.upper(v.label)
        thisButton.numKey = v.key

        --print("Sending button: " .. json.encode(thisButton))
        table.insert(buttonsToSend, thisButton)
    end

    SendNUIMessage({
        type = 'populateButtons',
        buttons = buttonsToSend
    })
end

-- deprecated in exchange for "SetButtons"
function ULC:SetButton(extra, enabled)
    local newState
    if enabled == 0 then
        newState = true
    elseif enabled == 1 then
        newState = false
    end

    SendNUIMessage({
        type = 'setButton',
        extra = extra,
        newState = newState
    })
end

function ULC:SetButtons(buttonStates)
    -- print("Setting buttons", json.encode(buttonStates))
    -- go through the buttons and replace newState with a boolean
    -- newState = 1 means false, 0 means true

    for k, v in pairs(buttonStates) do
        if v.newState == 1 then
            v.newState = false
        elseif v.newState == 0 then
            v.newState = true
        end
    end

    SendNUIMessage({
        type = 'setButtons',
        buttonStates = buttonStates
    })
end

-----------------
-- UI SETTINGS --
-----------------

function ULC:SetDisplay(bool)
    if bool then
        SendNUIMessage({
            type = 'showHUD',
        })
    else
        SendNUIMessage({
            type = 'hideHUD',
        })
    end
end

function ULC:SetPosition(x, y)
    SendNUIMessage({
        type = 'setPosition',
        x = x,
        y = y
    })
end

function ULC:SetScale(float)
    SendNUIMessage({
        type = 'setScale',
        scale = float
    })
end

-- TODO this is unused in game, should be in menu
function ULC:SetUseLeftAnchor(bool)
    SendNUIMessage({
        type = 'setAnchor',
        bool = bool
    })
end

function ULC:SetHudDisabled(bool)
    SendNUIMessage({
        type = 'setHudDisabled',
        bool = bool
    })
end

function ULC:SetHelpDisplay(bool)
    if bool then
        SendNUIMessage({ type = 'showHelp' })
    else
        SendNUIMessage({ type = 'hideHelp' })
    end
end

----------
-- MENU --
----------

-- TODO set this up in js
function ULC:SetMenuDisplay(bool)
    --print("Client setting display", bool)
    if bool then
        SendNUIMessage({
            type = 'showMenu',
        })
    else
        SendNUIMessage({
            type = 'hideHideMenu',
        })
    end
end

----------------------
-- USER PREFERENCES --
----------------------
print("[ULC] Client Storage Loaded")
ClientPrefs = {}

local function loadUserPrefs()
    -- if prefs already exist
    local prefsExist = GetResourceKvpString('ulc')
    if prefsExist == "exists" then
        print("[ULC] Loading prefs")
        -- load
        ClientPrefs.hideUi = GetResourceKvpInt("ulc:hideUi")
        ClientPrefs.x = GetResourceKvpInt("ulc:x")
        ClientPrefs.y = GetResourceKvpInt("ulc:y")
        ClientPrefs.scale = GetResourceKvpFloat("ulc:scale")
        ClientPrefs.useLeftAnchor = GetResourceKvpString("ulc:useLeftAnchor")
    else
        print("[ULC] Creating prefs")
        -- set defaults
        SetResourceKvp('ulc', "exists")
        SetResourceKvpInt('ulc:x', 0)
        SetResourceKvpInt('ulc:y', 0)
        SetResourceKvpFloat('ulc:scale', 1.0)
        SetResourceKvpInt('ulc:hideUi', 0)
        SetResourceKvp('ulc:useLeftAnchor', 'false')


        loadUserPrefs()

        Wait(5000)
        TriggerEvent('chat:addMessage', {
            color = { 0, 153, 204 },
            multiline = false,
            args = { "ULC", "^4This server uses ULC! Type /ulc to view settings and adjust the HUD!" }
        })
    end
end

loadUserPrefs()

-- use the values
CreateThread(function()
    --print("CLIENT PREF DISABLED =", ClientPrefs.hideUi)
    Wait(1000)
    -- positioning
    if ClientPrefs.x then
        --print("Loaded position from kvp: ", ClientPrefs.x, ClientPrefs.y)
        ULC:SetPosition(ClientPrefs.x, ClientPrefs.y)
    end
    if ClientPrefs.scale then
        -- print("Loaded saved scale from kvp: " .. ClientPrefs.scale)
        ULC:SetScale(ClientPrefs.scale + 0.0)
    end
    if ClientPrefs.hideUi then
        -- print("Loaded disabled HUD kvp: " .. ClientPrefs.hideUi)
        ULC:SetHudDisabled(ClientPrefs.hideUi)
    end
    if ClientPrefs.useLeftAnchor then
        -- print("Loaded useLeftAnchor from kvp", ClientPrefs.useLeftAnchor)
        ULC:SetUseLeftAnchor(ClientPrefs.useLeftAnchor)
    end
end)


--------------
-- COMMANDS --
--------------

RegisterCommand('ulc', function()
    if not MyVehicle then
        ULC:PopulateButtons({}, true)
        ULC:SetDisplay(true)
    end
    ULC:SetMenuDisplay(true)
    if MyVehicle then
        ULC:SetHelpDisplay(true)
    end
    SetNuiFocus(true, true)
end)

TriggerEvent('chat:addSuggestion', '/ulc', 'Enables dragging ULC HUD and shows settings menu and controls.', {
})

RegisterCommand("ulcReset", function()
    DeleteResourceKvp("ulc")
    loadUserPrefs()
end)

TriggerEvent('chat:addSuggestion', '/ulcReset', 'Resets all saved ULC settings to defaults.', {
})

-- NUI CALLBACKS --

RegisterNUICallback("savePosition", function(data, cb)
    --print("NUI Setting position", data.newX, data.newY, "type = ", type(data.newX))
    SetResourceKvpInt('ulc:x', data.newX)
    SetResourceKvpInt('ulc:y', data.newY)

    cb({ success = true })
end)

RegisterNUICallback("saveScale", function(data, cb)
    --print("NUI Setting Scale " .. data.scale + 0.0)
    SetResourceKvpFloat('ulc:scale', data.scale + 0.0)

    cb({ success = true })
end)

RegisterNUICallback("saveAnchor", function(data, cb)
    --print("NUI Setting Anchor ", data.useLeftAnchor)
    SetResourceKvp('ulc:useLeftAnchor', data.useLeftAnchor)

    cb({ success = true })
end)

RegisterNUICallback("focusGame", function(data, cb)
    ULC:SetMenuDisplay(false)
    SetNuiFocus(false, false)
    ULC:SetHelpDisplay(false)

    if not MyVehicle then
        ULC:SetDisplay(false)
    end

    cb({ success = true })
end)

RegisterNUICallback("setHudDisabled", function(data, cb)
    --print("NUI Setting HUD Disabled ", data.hudDisabled)

    if not data.hudDisabled then
        --print("Set HUD enabled")
        if MyVehicle then
            ULC:SetDisplay(true)
        end
        if #ClientPrefs > 0 then
            ClientPrefs.hideUi = 0
            --print("Are we here?")
        end
        SetResourceKvpInt('ulc:hideUi', 0)
    else
        --print("Set HUD disabled")
        ULC:SetDisplay(false)
        if #ClientPrefs > 0 then
            ClientPrefs.hideUi = 1
            --print("Are we here?")
        end
        SetResourceKvpInt('ulc:hideUi', 1)
    end

    cb({ success = true })
end)
