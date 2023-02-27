--[[ 
Ultimate Lighting Controller Config
the ULC resource is required to use this configuration
get the resource here: https://github.com/Flohhhhh/ultimate-lighting-controller/releases/latest

To learn how to setup and use ULC visit here: https://docs.dwnstr.com/ulc/overview
]]

return { names = {"yourvehiclename"},
    steadyBurnConfig = {
        forceOn = false,
        useTime = false,
        disableWithLights = false,
        sbExtras = {}
    },
    parkConfig = {
        usePark = false,
        useSync = false,
        syncWith = { "" },
        pExtras = {},
        dExtras = {}
    },
    hornConfig = {
        useHorn = false,
        hornExtras = {}
    },
    brakeConfig = {
        useBrakes = false,
        speedThreshold = 3,
        brakeExtras = {}
    },
    reverseConfig = {
        useReverse = false,
        reverseExtras = {}
    },

    --[[ example button
        {label = 'STAGE 2', key = 5, extra = 8, linkedExtras = {}, offExtras = {1, 2}},
    ]]

    buttons = { --paste your buttons below


    }
}