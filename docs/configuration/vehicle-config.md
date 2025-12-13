# Vehicle Configuration

Vehicle configurations define which features are enabled and how they behave for specific vehicles.

## Configuration Methods

### 1. External Resource (Recommended)

Place `ulc.lua` in vehicle resource:

```
my-vehicle-resource/
  ├── ulc.lua          (or)
  └── data/ulc.lua
```

Add to ULC config:
```lua
Config.ExternalVehResources = {
    "my-vehicle-resource"
}
```

### 2. Direct Config

Add to `config.lua`:
```lua
Config.Vehicles = {
    { -- config here }
}
```

## Configuration Structure

### Required Fields

```lua
return {
    -- Vehicle identification
    names = {"police", "police2"},  -- Model names
    
    -- Button configuration
    buttons = {
        {
            key = 1,              -- Numpad key (1-9)
            label = "TKD",        -- Button label
            extra = 1,            -- Extra number
            color = "amber",      -- Optional: blue, green, amber, red
            repair = true         -- Optional: allow when damaged
        }
    },
    
    -- Park pattern config
    parkConfig = {
        usePark = false,
        pExtras = {},
        dExtras = {},
        useSync = false,
        syncWith = {}
    },
    
    -- Brake config
    brakeConfig = {
        useBrakes = false,
        brakeExtras = {}
    },
    
    -- Horn config
    hornConfig = {
        useHorn = false,
        hornExtras = {},
        duration = 150
    }
}
```

## Optional Features

### Stages

```lua
stages = {
    useStages = true,
    stageKeys = {1, 2, 3}  -- Which buttons are stages
}
```

### Default Stages

```lua
defaultStages = {
    useDefaults = true,
    enableKeys = {1, 2},   -- Auto-on when lights on
    disableKeys = {8, 9}   -- Auto-off when lights on
}
```

### Steady Burns

```lua
steadyBurnConfig = {
    forceOn = false,           -- Always on
    useTime = false,           -- Use time of day
    sbExtras = {}              -- Extras to control
}
```

### Reverse

```lua
reverseConfig = {
    useReverse = true,
    reverseExtras = {7, 8}
}
```

### Signals

```lua
signalConfig = {
    useSignals = true,
    leftExtra = 10,
    rightExtra = 11,
    bothExtra = 12
}
```

### Smart Stages

```lua
smartStages = {
    useSmartStages = true,
    noOverride = {8, 9}  -- Keys not affected by smart stages
}
```

## Validation Rules

### Button Rules
1. Keys must be 1-9
2. No duplicate keys
3. No duplicate extras
4. Labels required (non-empty)
5. Labels should be ≤3 words, ≤5 chars each
6. Colors: blue, green, amber, red only

### Stage Rules
1. Stage keys must be 1-9
2. Each stage key must have matching button
3. Stage keys should be in order

### Feature Rules
1. If feature enabled, specify at least one extra
2. Extras should not conflict with buttons

## Multiple Vehicles

Single config file can define multiple vehicles:

```lua
return {
    names = {"police", "police2"},
    -- config
},
{
    names = {"sheriff"},
    -- different config
}
```

## Backwards Compatibility

**Deprecated `name` field:**
```lua
name = "police"  -- Old way (still works)
names = {"police"}  -- New way (preferred)
```

Old configs will still work but generate warnings.

## Example Complete Config

```lua
return {
    names = {"police", "police2"},
    
    buttons = {
        {key = 1, label = "TKD", extra = 1, color = "amber"},
        {key = 2, label = "ALLEY", extra = 2, color = "amber"},
        {key = 3, label = "REAR", extra = 3, color = "red"}
    },
    
    stages = {
        useStages = true,
        stageKeys = {1, 2, 3}
    },
    
    parkConfig = {
        usePark = true,
        pExtras = {4},
        dExtras = {1, 2, 3},
        useSync = true,
        syncWith = {"police"}
    },
    
    brakeConfig = {
        useBrakes = true,
        brakeExtras = {5}
    },
    
    hornConfig = {
        useHorn = true,
        hornExtras = {6},
        duration = 150
    },
    
    reverseConfig = {
        useReverse = true,
        reverseExtras = {7}
    },
    
    steadyBurnConfig = {
        useTime = true,
        sbExtras = {8}
    }
}
```
