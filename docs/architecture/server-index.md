# Server Index (s_main.lua)

The server index file is the most critical component for DX as it handles configuration loading and validation.

## Responsibilities

1. Load vehicle configurations from external resources
2. Validate configuration format and data
3. Check for configuration errors and warnings
4. Coordinate client config distribution
5. Monitor version updates

## Configuration Loading

### External Vehicle Resources

```lua
Config.ExternalVehResources = {
    "my-police-vehicle",
    "my-ems-vehicle"
}
```

The server:
1. Waits for resources to be ready
2. Loads `ulc.lua` or `data/ulc.lua` from each resource
3. Validates each configuration
4. Adds to `Config.Vehicles` table
5. Sets `GlobalState.ulcloaded = true`
6. Broadcasts configs to all clients

### Loading Process

```lua
LoadExternalVehicleConfig(resourceName)
├─► Check resource state (missing/stopped/running)
├─► Load ulc.lua file from resource
├─► Execute and parse configuration
├─► Validate with CheckData()
└─► Add to Config.Vehicles table
```

## Configuration Validation

The `CheckData()` function validates:

### Required Fields
- `name` (deprecated) or `names` - Vehicle model name(s)
- `parkConfig` - Park pattern settings
- `brakeConfig` - Brake extra settings
- `buttons` - Button configuration array
- `hornConfig` - Horn extra settings

### Button Validation
- Keys must be 1-9 (numpad keys)
- Labels must be non-empty
- Labels should be concise (≤3 words, ≤5 chars each)
- Colors must be: blue, green, amber, or red
- No duplicate keys
- No duplicate extras

### Stage Validation
- Stage keys must be 1-9
- Each stage key must have corresponding button
- Enable/disable keys validated if using default stages

### Feature-Specific Checks
- Steady burns: extras specified if enabled
- Park patterns: park or drive extras specified if enabled
- Brakes: brake extras specified if enabled
- Horn: horn extras specified if enabled

## Error Handling

### Error Levels

**Errors** (`ulc:error`) - Critical issues that prevent loading:
- Missing required fields
- Invalid data types
- Duplicate keys/extras
- Invalid key values (not 1-9)
- Resource not found/stopped

**Warnings** (`ulc:warn`) - Non-critical issues:
- Using deprecated `name` field instead of `names`
- Features enabled but no extras specified
- Performance concerns (park delay < 0.5s)
- UI disabled but buttons configured

### Example Error Messages

```
[ULC ERROR] Vehicle config in resource "my-vehicle" does not include model names!
[ULC WARNING] A config in "my-vehicle" uses deprecated 'name' field. Change to > names = {'yourvehicle'}
[ULC ERROR] Button 1 in a config found in resource "my-vehicle" has an invalid key. Key must be 1-9
```

## Version Checking

On startup, the server:
1. Fetches latest release from GitHub API
2. Compares with current version
3. Displays ASCII art banner
4. Warns if outdated

## Client Coordination

### On Vehicle Entry (`baseevents:enteredVehicle`)
```lua
TriggerClientEvent("UpdateVehicleConfigs", source, Config.Vehicles)
TriggerClientEvent("ulc:checkVehicle", source)
```

### On Vehicle Exit (`baseevents:leftVehicle`)
```lua
TriggerClientEvent("ulc:cleanup", source)
```

## Best Practices for Contributors

1. **Always validate new config fields** - Add checks in `CheckData()`
2. **Provide clear error messages** - Include resource name and specific issue
3. **Support backwards compatibility** - Old configs must still work
4. **Default to disabled** - New features should be opt-in
5. **Check resource state** - Handle missing/stopped resources gracefully
