# Client Main (c_main.lua)

The main client file coordinates vehicle detection, light state management, and feature initialization.

## Core Responsibilities

1. Monitor emergency light state
2. Detect vehicle entry/exit
3. Check for vehicle configuration
4. Initialize features when in configured vehicle
5. Clean up on vehicle exit
6. Manage auto-repair state

## Global State

```lua
ULC = {}           -- Main namespace
Lights = false     -- Emergency lights state
MyVehicle = nil    -- Current vehicle handle
MyVehicleConfig = nil  -- Active vehicle configuration
```

## Light State Management

### Detection Thread

Runs 10x per second when in a vehicle:

```lua
CreateThread(function()
    while true do
        -- Check if siren is on
        if IsVehicleSirenOn(vehicle) then
            TriggerEvent('ulc:lightsOn')
        else
            TriggerEvent('ulc:lightsOff')
        end
        Wait(100)
    end
end)
```

### Light State Events

**`ulc:lightsOn`**
- Sets `Lights = true`
- Applies default stages
- Checks park state
- Updates UI indicator
- Plays beep (if controlling lights)

**`ulc:lightsOff`**
- Sets `Lights = false`
- Updates UI indicator
- Plays beep (if controlling lights)

## Vehicle Detection

### Entry Detection

**`ulc:checkVehicle`** event:
1. Wait for `GlobalState.ulcloaded`
2. Get current vehicle
3. Call `GetVehicleFromConfig(vehicle)`
4. If match found:
   - Store `MyVehicle` and `MyVehicleConfig`
   - Sort buttons by key
   - If driver seat:
     - Populate UI buttons
     - Show HUD (if not hidden)
     - Initialize features (cruise, park, reverse, signals)
5. If no match:
   - Clear vehicle state
   - Trigger cleanup

### Continuous Monitoring

Thread runs every 500ms:
- Detects vehicle changes
- Detects driver seat changes
- Re-triggers `ulc:checkVehicle` when needed

## Feature Initialization

When driver enters configured vehicle:

```lua
-- UI
ULC:PopulateButtons(MyVehicleConfig.buttons)
ULC:SetDisplay(true)

-- Features
TriggerEvent('ulc:CheckCruise')
TriggerEvent('ulc:checkParkState', true)
TriggerEvent('ulc:StartCheckingReverseState')
TriggerEvent('ulc:SetupSignalExtrasTable')

-- Set initial stage
currentStage = 0
```

## Config Synchronization

### Receiving Updates

**`UpdateVehicleConfigs`** event:
- Receives validated vehicle table from server
- Updates `Config.Vehicles`
- Triggered on:
  - Server load complete
  - Player connects
  - Vehicle entry

## Cleanup

**`ulc:cleanup`** event:
- Hides HUD
- Stops feature threads
- Triggered on vehicle exit

## Auto-Repair Handler

Thread runs every second:

```lua
CreateThread(function()
    while true do
        local vehicles = GetGamePool("CVehicle")
        for _, v in pairs(vehicles) do
            if v ~= GetVehiclePedIsIn(PlayerPedId()) then
                SetVehicleAutoRepairDisabled(v, true)
            else
                SetVehicleAutoRepairDisabled(v, false)
            end
        end
        Wait(1000)
    end
end)
```

**Purpose**: Prevents auto-repair of extras on other vehicles while allowing it for player's vehicle.

## Light Control (Optional)

If `Config.controlLights = true`:

```lua
RegisterCommand('ulc:toggleLights', function()
    SetVehicleSiren(MyVehicle, not Lights)
end)

RegisterKeyMapping('ulc:toggleLights', 'Toggle Emergency Lights', 'keyboard', 'q')
```

Disabled by default to allow other scripts (like LVC) to control lights.

## Integration Points

Features hook into the main client via:
- Checking `MyVehicle` and `MyVehicleConfig` globals
- Responding to light state events
- Using shared utility functions
- Operating independently in their own threads
