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

-- nil/missing at every level = 0 = legacy instant behavior
local function GetHornPressDelay()
    local cfg = MyVehicleConfig.hornConfig
    if cfg.hornPressDelay ~= nil then return cfg.hornPressDelay end
    local hornSettings = Config.HornSettings or {}
    return hornSettings.hornPressDelay or 0
end

local function GetHornReleaseDelay()
    local cfg = MyVehicleConfig.hornConfig
    if cfg.hornReleaseDelay ~= nil then return cfg.hornReleaseDelay end
    local hornSettings = Config.HornSettings or {}
    return hornSettings.hornReleaseDelay or 0
end

local function ApplyHornExtrasOn()
    if hornActive then return end -- don't re-capture state over an active hold

    extraStates = {}

    for _, extra in pairs(MyVehicleConfig.hornConfig.hornExtras) do
        local extraState = {
            extra = extra,
            state = IsVehicleExtraTurnedOn(MyVehicle, extra)
        }
        table.insert(extraStates, extraState)
        ULC:SetStage(extra, 0, false, true, false, false, true, false)
    end

    if MyVehicleConfig.hornConfig.disableExtras then
        for _, extra in pairs(MyVehicleConfig.hornConfig.disableExtras) do
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

local function RestoreHornExtrasOff()
    if not hornActive then return end

    for _, extra in pairs(MyVehicleConfig.hornConfig.hornExtras) do
        local prevState = GetPreviousStateByExtra(extra)
        if not prevState then
            ULC:SetStage(extra, 1, false, true, false, false, true, false)
        end
    end

    if MyVehicleConfig.hornConfig.disableExtras then
        for _, extra in pairs(MyVehicleConfig.hornConfig.disableExtras) do
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
    if not (MyVehicle and MyVehicleConfig.hornConfig.useHorn) then return end

    hornGeneration = hornGeneration + 1
    local myGeneration = hornGeneration

    if hornActive then return end -- already on, this press just cancelled any pending restore

    local pressDelay = GetHornPressDelay()

    if pressDelay <= 0 then
        ApplyHornExtrasOn()
        return
    end

    CreateThread(function()
        Wait(pressDelay)
        if myGeneration ~= hornGeneration then return end -- released/pressed again mid-delay
        if not (MyVehicle and MyVehicleConfig.hornConfig.useHorn) then return end

        ApplyHornExtrasOn()
    end)
end)

RegisterCommand('-ulc:horn', function()
    if not (MyVehicle and MyVehicleConfig.hornConfig.useHorn) then return end

    hornGeneration = hornGeneration + 1
    local myGeneration = hornGeneration

    if not hornActive then return end -- never triggered, nothing to restore

    local releaseDelay = GetHornReleaseDelay()

    if releaseDelay <= 0 then
        RestoreHornExtrasOff()
        return
    end

    CreateThread(function()
        Wait(releaseDelay)
        if myGeneration ~= hornGeneration then return end -- pressed again, that press owns the restore now

        RestoreHornExtrasOff()
    end)
end)

RegisterKeyMapping('+ulc:horn', 'ULC: Activate Horn Extras', 'keyboard', 'e')
