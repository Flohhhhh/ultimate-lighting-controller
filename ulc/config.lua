-- Ultimate Lighting Controller by Dawnstar FiveM
-- Written by Floh and Imperfection from Dawnstar
-- For support: https://discord.com/invite/zH3k624aSv

Config = {
    -- whether to mute beep when sirens/lights are turned on and off;
    -- should be off if using another resource that adds a beep (ex. Luxart V3)
    muteBeepForLights = true,
    -- whether to use KPH instead of MPH in config
    useKPH = false,
    -- health threshold disables these effects while vehicle is damaged to prevent unrealistic repairs upon crashing
    healthThreshold = 990, -- 999 would disable effect with ANY damage to vehicle, between 900-999 are good values

    -- Park Pattern Settings;
    -- changes settings for extras enabled when vehicle is slow or parked, and park pattern sync
    ParkSettings = {
        -- extras will toggle below this speed
        speedThreshold = 1,
        -- check if any doors are fully open before executing effect (prevents doors from always snapping shut)
        checkDoors = true,
        -- time between checks in seconds
        -- should not need to be any lower than .5 seconds
        -- higher values may look more realistic
        delay = 0.5,
        -- distance at which to check for other vehicles to sync patterns with
        syncDistance = 32,
        -- seconds before a single client triggers sync again 
        -- I'm not aware of anything specific that this fixes, but it seems like a safe move and shouldn't affect the outcome.
        syncCooldown = 10,
    },

    -- Steady Burn Config;
    -- changes settings for extras that are enabled at night, or enabled all the time.
    SteadyBurnSettings = {
        -- hour effect starts (extras are enabled)
        nightStartHour = 18,
        -- hour effect ends (extras are disabled)
        nightEndHour = 6,
        -- time between checks in seconds
        -- should be high (checks also occur when entering vehicle)
        -- should NEVER be lower than 2 seconds (bad things will happen)
        delay = 10,
    },

    -- Brake Extras/Patterns Config;
    -- changes settings for extras that are enabled when braking
    BrakeSettings = {
        -- brake pattern will not activate below this speed
        -- if it's already active while you brake from 50 - 30 it will stay active until you release brakes
        speedThreshold = 30
    },

    -- the resource names of vehicle resources that include a ulc.lua config file
    ExternalVehResources = {
        -- ex. "my-police-vehicle",
    },

    Vehicles = {
        -- EXAMPLE -- COPY AND PASTE AND REMOVE --[[ ]]
        --[[{name = 'example', -- Vehicle Spawn Name
        
            -- Steady Burn/Alaways On Settings
            steadyBurnConfig = {
                forceOn = false,
                useTime = true,
                sbExtras = {1}
            },

            -- Park Pattern Settings
            parkConfig = {
                usePark = true,
                useSync = true,
                syncWith = {'example', 'sp18chrg'},
                pExtras = {10, 11},
                dExtras = {}
            },

            -- Extras on Airhorn (E key)
            -- Could be scene lighting or another pattern
            hornConfig = {
                useHorn = true,
                hornExtras = {12}
            },

            -- Brake Lights/Patterns Settings;
            -- Could be another pattern or extra brake lights
            brakeConfig = {
                useBrakes = false,
                brakeExtras = {12}
            },

            -- Stage Control Button Mappings
            -- label = text that appears on the button 
            -- key = key that the button uses (num pad numbers)
            -- there are 9 keys, and you don't have to use 1 first, then 2
            -- only order matters, a button using key 1 will always show before (left of) key 5 on the UI
            -- only keys you define appear as buttons, the rest are hidden
            -- extra = extra that is toggled by the button
            buttons = {
                {label = 'STAGE 2', key = 5, extra = 8},
                {label = 'TA', key = 6, extra = 9},
                {label = 'AUX1', key = 7, extra = 10},
                {label = 'AUX 2',key = 8,extra = 11},
                {label = 'SCENE',key = 9,extra = 12},
            }
        },]]
    }
}