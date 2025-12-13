# Development Patterns

Common patterns and approaches used throughout the ULC codebase.

## Feature Module Pattern

Each feature follows a standard structure:

### Configuration Check Pattern
```lua
-- Features check their config before running
if not MyVehicle then return end
if not MyVehicleConfig then return end
if not MyVehicleConfig.featureConfig.useFeature then return end
```

### Thread Pattern
```lua
CreateThread(function()
    local sleep = 1000
    while true do
        Wait(sleep)
        
        if not MyVehicle then
            sleep = 1000  -- Slow down when not in vehicle
            goto continue
        end
        
        sleep = 100  -- Active monitoring
        -- Feature logic here
        
        ::continue::
    end
end)
```

### State Management
Features share global state:
- `MyVehicle` - Current vehicle entity
- `MyVehicleConfig` - Active vehicle's configuration
- `Lights` - Emergency lights on/off
- Feature-specific state is kept local to the feature file

## Configuration Validation Pattern

Server-side validation in `s_main.lua`:

### Validation Philosophy
- Catch errors before they reach clients
- Provide clear, actionable error messages
- Warn for non-critical issues
- Return false to prevent loading bad configs

### Error vs Warning
```lua
-- Errors: Critical issues that prevent functionality
TriggerEvent('ulc:error', 'Missing required field: buttons')

-- Warnings: Non-critical but should be addressed
TriggerEvent('ulc:warn', 'Using deprecated field name')
```

## Backwards Compatibility Pattern

When changing configuration structure:

### Support Both Old and New
```lua
-- Support both old single name and new names table
if data.name then
    TriggerEvent('ulc:warn', 'name field is deprecated, use names = {...}')
    -- Process old format
elseif data.names then
    -- Process new format
end
```

### Never Break Existing Configs
- Old configs from any ULC version must still work
- New features default to disabled
- Changes to existing features must support old config format

## Vehicle Extra Control Pattern

Central control through `ULC:SetStage()`:

### Why Centralized?
- Consistent restriction checking (lights on, doors closed, etc.)
- UI updates handled in one place
- Smart stage logic applied uniformly
- Audio feedback coordinated

### When Features Control Extras
Features don't directly toggle extras - they call `ULC:SetStage()`:
```lua
-- Park pattern enables extras
ULC:SetStage(extra, 0, false, true, false, false, true, false)

-- Brake pattern enables extras
ULC:SetStage(extra, 0, false, false, false, false, true, false)
```

## Event-Driven Communication

### Client Events
- `ulc:lightsOn/Off` - Light state changed
- `ulc:checkVehicle` - Vehicle entry, check for config
- `ulc:cleanup` - Vehicle exit
- Feature-specific events for coordination

### Server-Client Sync
- Server validates on startup
- `GlobalState.ulcloaded` signals ready
- Clients receive validated configs
- Config updates on vehicle entry

## Performance Considerations

### Thread Sleep Strategy
```lua
-- Adapt sleep time based on context
if not MyVehicle then
    sleep = 1000  -- Longer sleep when idle
else
    sleep = 100   -- Active monitoring
end
```

### Minimize Expensive Calls
- Pool operations (`GetGamePool`) sparingly
- Cache values when possible
- Batch extra changes when feasible

## Adding New Features

When adding a new feature:

1. **Create feature file** - `c_newfeature.lua`
2. **Follow patterns** - Use standard configuration checks and thread structure
3. **Add validation** - Update `CheckData()` in `s_main.lua`
4. **Default disabled** - Feature must be opted-in via config
5. **Document config** - Specify config structure and validation rules

## Testing Approach

### Configuration Testing
- Test with missing fields
- Test with invalid values
- Test with old config formats
- Verify error messages are clear

### Runtime Testing
- Test in various vehicles (configured and unconfigured)
- Test with lights on/off
- Test seat changes
- Monitor console for errors
