function IsIntInTable(table, int)
    for k, v in ipairs(table) do
        if v == int then
            return true
        end
    end
    return false
end

if Config.ParkSettings.delay < 0.5 then
    TriggerServerEvent("ulc:error", 'Park Pattern delay is too short! This will hurt performance! Recommended values are above 0.5s.')
end

if Config.SteadyBurnSettings.delay <= 2 then
    TriggerServerEvent("ulc:error", 'Steady burn delay is too short! Steady burns will be unstable or not work!')
end

if Config.SteadyBurnSettings.nightStartHour < Config.SteadyBurnSettings.nightEndHour then
    TriggerServerEvent("ulc:error", 'Steady burn night start hour should be later/higher than night end hour.')
end

for k, v in pairs(Config.Vehicles) do
    -- check if steady burns are enabled but no extras specified
    if (v.steadyBurnConfig.forceOn or v.steadyBurnConfig.useTime) and #v.steadyBurnConfig.sbExtras == 0 then
        TriggerServerEvent("ulc:error", v.name .. 'uses Steady Burns, but no extras were specified (sbExtras = {})')
    end

    -- check if park pattern enabled but no extras specified
    if v.parkConfig.usePark then
        if #v.parkConfig.pExtras == 0 and #v.parkConfig.dExtras == 0 then
            TriggerServerEvent("ulc:error", v.name .. 'uses Park Pattern is enabled, but no park or drive extras were specified (pExtras = {}, dExtras = {})')
        end
    end

    -- check if brakes enabled but no extras specified
    if v.brakeConfig.useBrakes and #v.brakeConfig.brakeExtras == 0 then
        TriggerServerEvent("ulc:error", v.name .. 'uses Brake Pattern, but no brake extras were specified.')
    end
    
    local usedButtons = {}
    local usedExtras = {}
    for i, b in ipairs(v.buttons) do
        -- check if key is valid
        if b.key > 9 or b.key < 1 then
            Trigger('ulc:error', v.name .. " button ".. i .. " key is invalid. Key must be 1-9 representing number keys.")
        end
        -- check if label is empty
        if b.label == '' then
            TriggerServerEvent("ulc:error", v.name .. ' has an unlabeled button using extra: ' .. b.extra)
        end
        -- check if any keys are used twice
        if IsIntInTable(usedButtons, b.key) then
            TriggerServerEvent("ulc:error", v.name .. " uses key: " .. b.key .. " more than once in button config.")
        end
        -- check if any extras are used twice
        if IsIntInTable(usedExtras, b.extra) then
            TriggerServerEvent("ulc:error", v.name .. " uses extra: " .. b.extra .. " more than once in button config.")
        end
    end
end