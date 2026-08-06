--print("[ULC]: Horn Extras Loaded")

local extraStates = {}
local hornGeneration = 0 -- bumped on every press/release, invalidates stale delayed threads
local hornActive = false -- true once extras are actually on, guards against re-capturing state

local function GetPreviousStateByExtra(extra)
    for k, v in pairs(extraStates) do
        if extra == v.extra then
            return v.state
        end
    end
end

local function GetActiveHornConfig()
    if not MyVehicle or not MyVehicleConfig then return nil end

    local hornConfig = MyVehicleConfig.hornConfig
    if not hornConfig or not hornConfig.useHorn then return nil end

    return hornConfig
end

-- nil/missing at every level = 0 = legacy instant behavior
local function GetHornPressDelay(hornConfig)
    if hornConfig.hornPressDelay ~= nil then return hornConfig.hornPressDelay end
    local hornSettings = Config.HornSettings or {}
    return hornSettings.hornPressDelay or 0
end

local function GetHornReleaseDelay(hornConfig)
    if hornConfig.hornReleaseDelay ~= nil then return hornConfig.hornReleaseDelay end
    local hornSettings = Config.HornSettings or {}
    return hornSettings.hornReleaseDelay or 0
end

local function ApplyHornExtrasOn(hornConfig)
    if hornActive then return end -- don't re-capture state over an active hold

    extraStates = {}

    for _, extra in pairs(hornConfig.hornExtras) do
        local extraState = {
            extra = extra,
            state = IsVehicleExtraTurnedOn(MyVehicle, extra)
        }
        table.insert(extraStates, extraState)
        ULC:SetStage(extra, 0, false, true, false, false, true, false)
    end

    if hornConfig.disableExtras then
        for _, extra in pairs(hornConfig.disableExtras) do
            local extraState = {
                extra = extra,
                state = IsVehicleExtraTurnedOn(MyVehicle, extra)
            }
            table.insert(extraStates, extraState)
            ULC:SetStage(extra, 1, false, true, false, false, true, false)
        end
    end

    hornActive = true
end

local function RestoreHornExtrasOff(hornConfig)
    if not hornActive then return end

    for _, extra in pairs(hornConfig.hornExtras) do
        local prevState = GetPreviousStateByExtra(extra)
        if not prevState then
            ULC:SetStage(extra, 1, false, true, false, false, true, false)
        end
    end

    if hornConfig.disableExtras then
        for _, extra in pairs(hornConfig.disableExtras) do
            local prevState = GetPreviousStateByExtra(extra)
            if prevState then
                ULC:SetStage(extra, 0, false, true, false, false, true, false)
            end
        end
    end

    extraStates = {}
    hornActive = false
end

RegisterCommand('+ulc:horn', function()
    local hornConfig = GetActiveHornConfig()
    if not hornConfig then return end

    hornGeneration = hornGeneration + 1
    local myGeneration = hornGeneration

    if hornActive then return end -- already on, this press just cancelled any pending restore

    local pressDelay = GetHornPressDelay(hornConfig)

    if pressDelay <= 0 then
        ApplyHornExtrasOn(hornConfig)
        return
    end

    CreateThread(function()
        Wait(pressDelay)
        if myGeneration ~= hornGeneration then return end -- released/pressed again mid-delay
        hornConfig = GetActiveHornConfig()
        if not hornConfig then return end

        ApplyHornExtrasOn(hornConfig)
    end)
end)

RegisterCommand('-ulc:horn', function()
    local hornConfig = GetActiveHornConfig()
    if not hornConfig then return end

    hornGeneration = hornGeneration + 1
    local myGeneration = hornGeneration

    if not hornActive then return end -- never triggered, nothing to restore

    local releaseDelay = GetHornReleaseDelay(hornConfig)

    if releaseDelay <= 0 then
        RestoreHornExtrasOff(hornConfig)
        return
    end

    CreateThread(function()
        Wait(releaseDelay)
        if myGeneration ~= hornGeneration then return end -- pressed again, that press owns the restore now

        hornConfig = GetActiveHornConfig()
        if not hornConfig then return end

        RestoreHornExtrasOff(hornConfig)
    end)
end)

RegisterKeyMapping('+ulc:horn', 'ULC: Activate Horn Extras', 'keyboard', 'e')
