-- Ultimate Lighting Controller by Dawnstar FiveM
-- Written by Dawnstar
-- Documentation: https://docs.dwnstr.com/ulc/overview
-- For support: https://discord.gg/dwnstr-fivem

-- Most of these can be left at their default values.
-- View documentation for details on each value
Config = {
    -- whether to mute beep when sirens/lights are turned on and off;
    -- should be true if using another resource that adds a beep (ex. Luxart V3)
    muteBeepForLights = true,
    -- whether to use KPH instead of MPH
    useKPH = false,
    -- health threshold disables these effects while vehicle is damaged to prevent unrealistic repairs upon crashing
    healthThreshold = 990, -- 999 would disable effect with ANY damage to vehicle, between 900-999 are good values

    -- Park Pattern Settings;
    ParkSettings = {
        -- extras will toggle below this speed
        speedThreshold = 1,
        -- check if any doors are fully open before executing effect (prevents doors from always snapping shut)
        checkDoors = true,
        -- time between checks in seconds
        -- should not be any lower than .5 seconds
        delay = 0.5,
        -- distance at which to check for other vehicles to sync patterns with
        syncDistance = 32,
        -- seconds before a single client triggers sync again 
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
    BrakeSettings = {

        speedThreshold = 30
    },

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
