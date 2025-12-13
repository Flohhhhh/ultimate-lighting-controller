# Park Patterns (c_park.lua)

Automatically switches between park and drive lighting patterns based on vehicle speed.

## Purpose

When vehicle is parked, enables different extras than when driving. Supports pattern synchronization between nearby vehicles.

## Configuration

```lua
parkConfig = {
    usePark = true,
    pExtras = {1, 2},      -- Park pattern extras
    dExtras = {3, 4},      -- Drive pattern extras
    useSync = true,
    syncWith = {"police", "police2"}  -- Models to sync with
}
```

## State

- `parked` - Boolean tracking park state

## How It Works

1. **Speed monitoring** - Checks speed every `Config.ParkSettings.delay` seconds
2. **State transition** - When speed drops below threshold:
   - Wait `effectDelay` (1s)
   - Trigger `ulc:vehPark`
3. **Pattern application**:
   - Park: Enable `pExtras`, disable `dExtras`
   - Drive: Enable `dExtras`, disable `pExtras`

## Park Pattern Sync

When parking with sync enabled:

1. Find nearby vehicles (within `Config.ParkSettings.syncDistance`)
2. Filter for emergency vehicles matching `syncWith` or same model
3. Filter for vehicles below speed threshold
4. Reset siren state to sync all patterns
5. Send sync to server for other clients
6. Respect `Config.ParkSettings.syncCooldown` to avoid spam

### Sync Process

```lua
SetVehicleSiren(vehicle, false)
SetVehicleSiren(vehicle, true)
```

This resets the pattern timing, causing all vehicles to flash in sync.

## Events

**`ulc:checkParkState`**
- Triggered by main thread
- Checks current speed
- Transitions park/drive state

**`ulc:vehPark`**
- Activates park pattern
- Initiates sync if configured

**`ulc:vehDrive`**
- Activates drive pattern

**`ulc:sync:receive`**
- Receives sync from other clients
- Applies siren reset to vehicles

## Config Settings

```lua
ParkSettings = {
    speedThreshold = 1,     -- MPH/KPH threshold
    delay = 0.5,            -- Check interval (min 0.5s)
    syncDistance = 32,      -- Sync radius
    syncCooldown = 4        -- Seconds between syncs
}
```
