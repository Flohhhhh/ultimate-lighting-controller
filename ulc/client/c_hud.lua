print("ULC: HUD Functions Loaded")
function ULC:PopulateButtons(buttons)
    --print("Populating buttons")

    local buttonsToSend = {}
    for _, v in pairs(buttons) do
        local thisButton = {}
        local thisState = false
        if IsVehicleExtraTurnedOn(MyVehicle, v.extra) then thisState = true end
        thisButton.extra = v.extra
        thisButton.enabled = thisState
        thisButton.color = v.color
        thisButton.label = v.label

        --print("Sending button: " .. json.encode(thisButton))
        table.insert(buttonsToSend, thisButton)
    end

    SendNUIMessage({
        type = 'populateButtons',
        buttons = buttonsToSend
    })
end

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

----------
-- MENU --
----------

-- TODO set this up in js
function ULC:SetMenuDisplay(bool)
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
print("[ULC]: Client Storage Loaded")
ClientPrefs = {}

local function loadUserPrefs()
    -- if prefs already exist
    local prefsExist = GetResourceKvpString('ulc')
    if prefsExist == "exists" then
        -- load
        ClientPrefs.hideUi = GetResourceKvpInt("ulc:hideUi")
        ClientPrefs.x = GetResourceKvpInt("ulc:x")
        ClientPrefs.y = GetResourceKvpInt("ulc:y")
        print("Loading prefs")
        
    else
        -- set defaults
        SetResourceKvp('ulc', "exists")
        SetResourceKvpInt('ulc:hideUi', 0)
        print("Creating prefs")
    end
end

loadUserPrefs()
-- use the values
CreateThread(function()
    Wait(1000)
    -- positioning
    if ClientPrefs.x then
        print("Setting saved position: ", ClientPrefs.x, ClientPrefs.y)
        ULC:SetPosition(ClientPrefs.x, ClientPrefs.y)
    end
    if ClientPrefs.scale then
        print("Setting saved scale: " .. ClientPrefs.scale)
        ULC:SetScale(ClientPrefs.scale)
    end
end)


--------------
-- COMMANDS --
--------------

local focus = false
RegisterCommand('ulc', function()
    if focus then
        ULC:SetMenuDisplay(false)
        SetNuiFocus(false, false)
    else
        ULC:SetMenuDisplay(true)
        SetNuiFocus(true, true)
    end
end)

RegisterCommand("ulcReset", function()
    DeleteResourceKvp("ulc")
    loadUserPrefs()
end)

RegisterCommand("ulcHide", function()
    if GetResourceKvpInt('ulc:hideUi') == 1 then
        SetResourceKvpInt('ulc:hideUi', 0)
        print("Showing ULC UI")
        ULC:SetDisplay(true)
    else
        SetResourceKvpInt('ulc:hideUi', 1)
        print("Hiding ULC UI")
        ULC:SetDisplay(false)
    end
end)

-- NUI CALLBACKS --

RegisterNUICallback("savePosition", function(data)

    print(data.newX, data.newY)
    SetResourceKvpInt('ulc:x', data.newX)
    SetResourceKvpInt('ulc:y', data.newY)

    --cb({valid = valid})
end)

RegisterNUICallback("focusGame", function()

    ULC:SetMenuDisplay(false)
    SetNuiFocus(false, false)

end)