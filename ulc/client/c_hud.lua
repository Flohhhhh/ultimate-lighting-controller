function PopulateButtons(buttons)
    print("Populating buttons")

    local buttonsToSend = {}
    for _, v in pairs(buttons) do
        local thisButton = {}
        thisButton.extra = v.extra
        thisButton.state = IsVehicleExtraTurnedOn(MyVehicle, v.extra)
        thisButton.color = 'blue'
        thisButton.label = v.label

        table.insert(buttonsToSend, thisButton)
    end

    SendNUIMessage({
        type = 'populateButtons',
        buttons = buttonsToSend
    })
end

function SetButton(extra, enabled)
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
