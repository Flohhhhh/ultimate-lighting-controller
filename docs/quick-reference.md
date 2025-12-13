# Quick Reference Guide

## File Structure

```
ulc/
├── client/
│   ├── c_main.lua          ⭐ Main client thread & vehicle detection
│   ├── c_buttons.lua       Core button/extra management
│   ├── c_stages.lua        Stage controls
│   ├── c_park.lua          Park patterns & sync
│   ├── c_brake.lua         Brake extras
│   ├── c_reverse.lua       Reverse extras
│   ├── c_horn.lua          Horn extras
│   ├── c_blackout.lua      Blackout mode
│   ├── c_cruise.lua        Cruise control display
│   ├── c_signals.lua       Turn signal extras
│   ├── c_doors.lua         Door monitoring
│   ├── c_beeps.lua         Audio feedback
│   └── c_hud.lua           UI management
├── server/
│   ├── s_main.lua          ⭐ Config loading & validation
│   ├── s_blackout.lua      Blackout coordination
│   └── s_lvc.lua           LVC compatibility
├── shared/
│   └── shared_functions.lua  Utility functions
├── config.lua              ⭐ Global settings
├── fxmanifest.lua          Resource manifest
├── html/                    Built React UI
└── src/                     React source code

⭐ = Most important for understanding DX
```

## Key Concepts

### 1. Opt-In Architecture
- No vehicle affected without explicit configuration
- Features enabled per-vehicle via config
- Backwards compatibility required

### 2. Configuration Flow
```
Resource Start → Load External Configs → Validate → Broadcast to Clients
                                    ↓
                            Client Receives Configs
                                    ↓
                            Player Enters Vehicle
                                    ↓
                            Check for Match
                                    ↓
                            Enable Features
```

### 3. Feature Independence
- Each feature in separate file
- Features check `MyVehicle` and `MyVehicleConfig`
- Features run own threads
- Features call `ULC:SetStage()` to control extras

## Common Tasks

### Adding a New Feature

1. Create `c_newfeature.lua`
2. Add to fxmanifest.lua `client_scripts`
3. Check `MyVehicle` and `MyVehicleConfig` before running
4. Add config validation to `s_main.lua` `CheckData()`
5. Document in config structure

### Modifying Validation

Edit `s_main.lua` function `CheckData()`:
- Add checks for new fields
- Use `TriggerEvent('ulc:error', msg)` for critical issues
- Use `TriggerEvent('ulc:warn', msg)` for non-critical issues
- Return `false` to prevent config loading

### Changing Config Structure

⚠️ **Backwards compatibility required!**

1. Support old format alongside new format
2. Add deprecation warning for old format
3. Document migration path
4. Never break existing configs

Example:
```lua
if data.oldField then
    TriggerEvent('ulc:warn', 'oldField is deprecated, use newField')
    -- Convert old to new internally
end
```

## Common Patterns

### Checking Vehicle Config

```lua
if not MyVehicle then return end
if not MyVehicleConfig then return end
if not MyVehicleConfig.feature then return end
if not MyVehicleConfig.feature.useFeature then return end
```

### Monitoring Thread

```lua
CreateThread(function()
    local sleep = 1000
    while true do
        Wait(sleep)
        
        if not MyVehicle then
            sleep = 1000
            goto continue
        end
        
        sleep = 100
        -- Feature logic here
        
        ::continue::
    end
end)
```

### Feature Event

```lua
AddEventHandler('ulc:myFeature', function()
    if not MyVehicle then return end
    if not Lights then return end
    
    -- Feature logic
    ULC:SetStage(extra, state, ...)
end)
```

## Debugging

### Server-Side
```lua
print("[ULC] Message")                    -- Normal
TriggerEvent('ulc:error', 'message')     -- Red error
TriggerEvent('ulc:warn', 'message')      -- Yellow warning
```

### Client-Side
```lua
print("[ULC:feature] Message")
```

### Check Loading
```
Server console: Watch for validation errors
Client console: Check "Found vehicle, ready to go"
```

## Performance Considerations

1. **Thread sleep times:** Higher = better performance
2. **Park pattern delay:** Min 0.5s, higher for lower-end hardware
3. **Vehicle pool checks:** Minimize frequency
4. **Extra state changes:** Batch when possible

## Testing Checklist

- [ ] Config validation catches errors
- [ ] Feature works with lights on/off
- [ ] Feature respects vehicle config
- [ ] UI updates correctly
- [ ] No console errors
- [ ] Works with existing configs
- [ ] Performance acceptable

## Common Gotchas

1. **Client needs validated config from server** - Wait for `GlobalState.ulcloaded`
2. **Features only work in driver seat** - Check seat in feature logic if needed
3. **Extras are vehicle-specific** - Not all vehicles have all extras
4. **Config changes need server restart** - Configs loaded at startup
5. **Resource name ≠ model name** - `ExternalVehResources` uses resource names
