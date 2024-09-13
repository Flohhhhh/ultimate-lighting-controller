-- Ultimate Lighting Controller by Dawnstar FiveM
-- Written by Dawnstar
-- Documentation: https://docs.dwnstr.com/ulc/overview
-- For support: https://discord.gg/dwnstr-fivem

-- Most of these can be left at their default values.
-- View documentation for details on each value
Config = {
    -- whether to enable control of lights on/off state using Q key
    -- disabled by default to allow other scripts to control lights such as Luxart
    -- make sure to disable light controls in other scripts if you enable this
    controlLights = false,

    -- HUD SETTINGS
    -- global toggle for UI (affects all clients)
    hideHud = false,
    -- whether to use KPH instead of MPH
    useKPH = false,

    -- Park Pattern Settings;
    ParkSettings = {
        -- extras will toggle below this speed
        speedThreshold = 1,
        -- time between checks in seconds
        -- should not be any lower than .5 seconds
        delay = 0.5,
        -- distance at which to check for other vehicles to sync patterns with
        syncDistance = 32,
        -- seconds before a single client triggers sync again
        syncCooldown = 4,
    },

    -- Steady Burn Config;
    -- changes settings for extras that are enabled at night, or enabled all the time.
    SteadyBurnSettings = {
        -- hour effect starts (extras are enabled)
        nightStartHour = 18,
        -- hour effect ends (extras are disabled)
        nightEndHour = 6,
    },

    -- Brake Extras/Patterns Config;
    -- temporarily empty as of v1.3.0
    BrakeSettings = {},

    -- Import confiurations here
    -- Add the resource names of vehicle resources that include a ulc.lua config file
    ExternalVehResources = {
        -- ex. "my-police-vehicle",
    },

    Vehicles = {
        -- this is not required!
        -- see documentation for instructions!
        -- https://docs.dwnstr.com/ulc/configuration
    }
}
