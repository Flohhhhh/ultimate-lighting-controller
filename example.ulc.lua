--[[
  Ultimate Lighting Controller Config
  the ULC resource is required to use this configuration
  get the resource here: https://github.com/Flohhhhh/ultimate-lighting-controller/releases/latest
  To learn how to setup and use ULC visit here: https://docs.dwnstr.com/ulc/overview
]]

return {
  names = { "" },
  steadyBurnConfig = {
    forceOn = false,
    useTime = false,
    disableWithLights = false,
    sbExtras = {}
  },
  parkConfig = {
    usePark = false,
    useSync = false,
    syncWith = {},
    pExtras = {},
    dExtras = {}
  },
  hornConfig = {
    useHorn = false,
    hornExtras = {},
    disableExtras = {},
    hornPressDelay = nil,
    hornReleaseDelay = nil
  },
  brakeConfig = {
    useBrakes = false,
    speedThreshold = 3,
    brakeExtras = {},
    disableExtras = {}
  },
  reverseConfig = {
    useReverse = false,
    reverseExtras = {},
    disableExtras = {}
  },
  signalConfig = {
    useSignals = false,
    left = { enable = {}, disable = {} },
    right = { enable = {}, disable = {} },
    hazard = { enable = {}, disable = {} }
  },
  doorConfig = {
    useDoors = false,
    driverSide = { enable = {}, disable = {} },
    passSide = { enable = {}, disable = {} },
    trunk = { enable = {}, disable = {} }
  },
  buttons = {
  },
  stages = {
    useStages = false,
    stageKeys = {},
  },
  defaultStages = {
    useDefaults = false,
    enableKeys = {},
    disableKeys = {}
  }
}
