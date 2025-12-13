# Architecture Overview

## Design Philosophy

ULC uses a client-server architecture with:
- **Opt-in features** - No vehicles are affected without explicit configuration
- **Per-vehicle configuration** - Each vehicle can have unique settings
- **Backwards compatibility** - Old configs must always work

## Component Flow

```
┌─────────────────┐
│   Server Start  │
└────────┬────────┘
         │
         ├─► Load config.lua
         ├─► Load external vehicle resources
         ├─► Validate all configurations (s_main.lua)
         └─► Set GlobalState.ulcloaded = true
                  │
                  ▼
         ┌────────────────┐
         │  Client Ready  │
         └────────┬───────┘
                  │
                  ├─► Receive validated configs
                  ├─► Wait for vehicle entry
                  └─► Check vehicle config (c_main.lua)
                           │
                           ▼
                  ┌──────────────────┐
                  │  Vehicle Match?  │
                  └────┬─────────┬───┘
                       YES       NO
                       │         └─► Continue waiting
                       ▼
              ┌────────────────┐
              │ Enable Features│
              └────────────────┘
                       │
                       ├─► Initialize UI
                       ├─► Load feature modules
                       └─► Monitor vehicle state
```

## State Management

### Global State
- `GlobalState.ulcloaded` - Server loading status

### Vehicle State
- `MyVehicle` - Current vehicle handle
- `MyVehicleConfig` - Active vehicle configuration
- `Lights` - Emergency lights on/off state
- `parked` - Park pattern state
- `currentStage` - Active stage level

## Thread Model

### Client Threads
- **Light state checker** (c_main.lua) - Polls siren state 10x/second
- **Vehicle change detector** (c_main.lua) - Checks vehicle/seat changes every 500ms
- **Auto-repair handler** (c_main.lua) - Manages repair state every 1s
- **Park pattern checker** (c_park.lua) - Monitors speed for park patterns
- **Feature-specific threads** - Each feature has its own monitoring threads

### Server Threads
- **Config loader** (s_main.lua) - Loads external configurations on startup

## Event System

### Client Events
- `ulc:checkVehicle` - Triggered on vehicle entry
- `ulc:lightsOn/Off` - Light state changes
- `ulc:vehPark/Drive` - Park pattern state changes
- `ulc:cleanup` - Vehicle exit cleanup

### Server Events
- `baseevents:enteredVehicle` - Vehicle entry from baseevents
- `baseevents:leftVehicle` - Vehicle exit from baseevents
- `UpdateVehicleConfigs` - Sends configs to clients

## Data Flow

1. **Server validates** vehicle configs
2. **Client receives** validated configs
3. **Client checks** if entered vehicle matches config
4. **Client enables** features for matched vehicle
5. **Client monitors** vehicle state and triggers feature logic
