# Global Configuration

The main `config.lua` file contains global settings affecting all vehicles and clients.

## Light Controls

```lua
Config = {
    controlLights = false
}
```

**Purpose:** Enable ULC to control emergency lights with Q key

**Default:** `false` - Allows other scripts (LVC) to control lights

**When enabled:**
- Q key toggles lights
- Audio beeps play
- Must disable light controls in other scripts

## HUD Settings

```lua
hideHud = false
useKPH = false
```

**hideHud:** Global toggle for UI visibility (affects all clients)

**useKPH:** Display speed in KPH instead of MPH

## Park Pattern Settings

```lua
ParkSettings = {
    speedThreshold = 1,
    delay = 0.5,
    syncDistance = 32,
    syncCooldown = 4
}
```

**speedThreshold:** Speed below which park patterns activate (MPH or KPH based on `useKPH`)

**delay:** Seconds between park state checks (min 0.5s recommended)

**syncDistance:** Radius to check for vehicles to sync patterns with

**syncCooldown:** Seconds before client can trigger sync again

**Performance note:** `delay < 0.5` will generate warning about performance impact

## Steady Burn Settings

```lua
SteadyBurnSettings = {
    nightStartHour = 18,
    nightEndHour = 6
}
```

**nightStartHour:** Hour when time-based steady burns enable (24h format)

**nightEndHour:** Hour when time-based steady burns disable

**Validation:** `nightStartHour` must be > `nightEndHour`

## Brake Settings

```lua
BrakeSettings = {}
```

Currently unused - reserved for future brake-related global settings.

## Reverse Settings

```lua
ReverseSettings = {
    useRandomExpiration = true,
    minExpiration = 3,
    maxExpiration = 8
}
```

**useRandomExpiration:** Auto-disable reverse extras after random delay when stopped

**minExpiration:** Minimum seconds extras stay on after stopping

**maxExpiration:** Maximum seconds extras stay on after stopping

**Purpose:** Simulate realistic behavior where driver shifts out of reverse

## External Vehicle Resources

```lua
ExternalVehResources = {
    -- "my-vehicle-resource",
}
```

List of resource names containing `ulc.lua` config files.

**Notes:**
- Must be resource names, not model names
- Resources must be started before/with ULC
- Server loads configs from these resources on startup

## Vehicles Table

```lua
Vehicles = {
    -- Not required
}
```

Optional direct vehicle configurations.

**Recommended:** Use external resources instead for cleaner organization.

## Configuration Validation

Server validates:
1. Park delay >= 0.5s (warning if lower)
2. Night start hour > night end hour
3. All vehicle configs load successfully
4. External resources exist and are started

## Config File Location

`/ulc/config.lua` - Main configuration file

Loaded as `shared_script` in fxmanifest.lua - available on both client and server.

## Best Practices

1. **Keep defaults:** Most settings work well at defaults
2. **Test park delay:** Lower values hurt performance
3. **Use external resources:** Easier to manage vehicle configs
4. **Document changes:** Comment why you changed from defaults
5. **Consider client hardware:** Lower-end systems need higher delays
