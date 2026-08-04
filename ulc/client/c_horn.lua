--print("[ULC]: Horn Extras Loaded")

local extraStates = {}

-- generation counter used to invalidate stale delayed threads when the
-- player presses/releases the horn key rapidly, so an old timer can't
-- turn extras on/off after a newer press has already changed state
local hornGeneration = 0
local hornActive = false

local function GetPreviousStateByExtra(extra)
    for k, v in pairs(extraStates) do
        --print(v.extra, v.state)
        if extra == v.extra then
            --print('Found state of : ' .. tostring(v.state) .. ' for extra ' .. extra)
            return v.state
        end
    end
end

-- resolves per-vehicle overrides, falling back to the global defaults
local function GetHoldDelay()
    local cfg = MyVehicleConfig.hornConfig
    if cfg.holdDelay ~= nil then return cfg.holdDelay end
    return Config.HornSettings.defaultHoldDelay
end

local function GetExtraHoldTime()
    local cfg = MyVehicleConfig.hornConfig
    if cfg.extraHoldTime ~= nil then return cfg.extraHoldTime end
    return Config.HornSettings.defaultExtraHoldTime
end

-- Turns horn extras on and captures the pre-horn state so it can be
-- restored later. Guarded by hornActive so that re-pressing the horn key
-- while extras are already active (e.g. mashing it, or pressing again
-- before the previous release's restore timer fired) can never overwrite
-- the originally captured states with the "horn on" states.
local function ApplyHornExtrasOn()
    if hornActive then return end

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

-- Restores extras to the state captured in ApplyHornExtrasOn. Guarded by
-- hornActive so it's only ever meaningful once, matching ApplyHornExtrasOn.
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

    -- extras are already active - this press just cancelled any pending
    -- restore timer (via the generation bump above). Don't re-capture
    -- state and don't start another on-delay, or the real "before horn"
    -- state would get lost.
    if hornActive then return end

    local holdDelay = GetHoldDelay()

    if holdDelay <= 0 then
        ApplyHornExtrasOn()
        return
    end

    CreateThread(function()
        Wait(holdDelay)
        -- bail if the key was released (or pressed again) before the delay finished
        if myGeneration ~= hornGeneration then return end
        if not (MyVehicle and MyVehicleConfig.hornConfig.useHorn) then return end

        ApplyHornExtrasOn()
    end)
end)

RegisterCommand('-ulc:horn', function()
    if not (MyVehicle and MyVehicleConfig.hornConfig.useHorn) then return end

    hornGeneration = hornGeneration + 1
    local myGeneration = hornGeneration

    -- the horn never actually triggered (released before holdDelay elapsed)
    -- nothing to restore
    if not hornActive then return end

    local extraHoldTime = GetExtraHoldTime()

    if extraHoldTime <= 0 then
        RestoreHornExtrasOff()
        return
    end

    -- every release starts exactly one fresh countdown. If the horn gets
    -- pressed and released again before this fires, the generation bump
    -- from that later release invalidates this thread and starts its own
    -- - the hold time never adds up, it just restarts from full each time.
    CreateThread(function()
        Wait(extraHoldTime * 1000)
        -- bail if the horn was pressed again before the hold time finished,
        -- that press's own logic now owns restoring state
        if myGeneration ~= hornGeneration then return end

        RestoreHornExtrasOff()
    end)
end)

RegisterKeyMapping('+ulc:horn', 'ULC: Activate Horn Extras', 'keyboard', 'e')
