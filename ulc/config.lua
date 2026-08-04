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

    -- AUDIO SETTINGS
    -- whether to enable beep sounds when toggling lights and extras
    enableBeeps = true,

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

    -- Reverse Extras/Patterns Config;
    -- introduced in v1.8.0
    ReverseSettings = {
        -- these options control the expiration of the reverse extras
        -- if enabled, reverse extras will turn off after a random time between min and max
        -- this is to simulate more realistic behavior where the vehicle would shifted out of reverse
        -- after being stopped for some time
        useRandomExpiration = true,
        -- minimum time in seconds extras will stay on after stopping
        minExpiration = 3,
        -- maximum time in seconds extras will stay on after stopping
        maxExpiration = 8,
    },

    -- Fake Environmental Light Config;
    -- Lets a light-head extra (e.g. a TKD or alley light) be toggled as a
    -- pure visual mesh, without the vehicle's real environmental lighting
    -- actually running. A soft "spill" bulb of light is drawn near the
    -- vehicle opposite the light head to sell the effect, saving on
    -- running full environmental extras/sirens.
    FakeEnvSettings = {
        -- global master switch. false = feature is fully disabled for every
        -- vehicle regardless of what any individual vehicle's fakeEnvConfig
        -- says. Each vehicle still needs its own fakeEnvConfig.useFakeEnv = true
        -- on top of this - this is just the server-wide kill switch.
        enabled = true,
        defaultKeys = {
            left = 'NUMPAD7',
            tk = 'NUMPAD8',
            right = 'NUMPAD9',
        },
        -- color of the fake light (r, g, b, 0-255)
        color = { r = 255, g = 244, b = 214 },
        -- how far out to the side the left/right lights sit (meters)
        sideDistance = 5.0,
        -- how far out in front the tk (take-down) light sits (meters)
        frontDistance = 8.0,
        -- how high above the vehicle's position the light sits (meters)
        heightOffset = 1.2,
        -- size of the light's sphere of influence (meters) - this is the
        -- "range" the native actually expects, bigger = a larger, further-
        -- reaching pool of light
        lightRange = 15.0,
        -- brightness multiplier for the light
        lightIntensity = 4.0,

        -- stop drawing (not toggling, just rendering) past this distance from the player, for performance
        drawRange = 30.0,
    },

    -- Horn Hold Timing Config;
    -- global defaults for the horn-hold extras feature (c_horn.lua).
    -- both can be overridden per-vehicle via MyVehicleConfig.hornConfig.holdDelay
    -- and MyVehicleConfig.hornConfig.extraHoldTime
    HornSettings = {
        -- delay after pressing the horn key before horn extras turn on, in milliseconds
        -- 0 = instant, same as legacy behavior
        defaultHoldDelay = 500,
        -- how long horn extras stay on after releasing the horn key, in seconds
        -- 0 = instant restore, same as legacy behavior
        defaultExtraHoldTime = 5,
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
