# Button Management (c_buttons.lua)

Manages stage buttons, UI state, and extra toggling logic.

## Purpose

Provides the core button system for controlling vehicle extras via numpad keys and UI display.

## Configuration

```lua
buttons = {
    {
        key = 1,
        label = "TKD",
        extra = 1,
        color = "amber",
        repair = true
    }
}
```

## Core Functions

### `ULC:SetStage(extra, state, ...)`

The primary function for controlling vehicle extras.

**Parameters:**
- `extra` - Extra number to control
- `state` - 0 (on) or 1 (off)
- `overrideRestrict` - Ignore restrictions
- `parkPattern` - Called by park pattern
- `repair` - Allow on damaged vehicles
- `onDisable` - Turning extra off
- `onEnable` - Turning extra on
- `smart` - Use smart stage logic

**Logic:**
1. Check if in configured vehicle
2. Validate extra exists
3. Check restrictions (lights on, doors closed, vehicle health)
4. Toggle extra state
5. Update UI button state
6. Play audio feedback
7. Handle smart stage interactions

### `ULC:PopulateButtons(buttons)`

Populates UI with button configuration on vehicle entry.

### Button State

Each button can be:
- **On** - Extra enabled (amber/colored)
- **Off** - Extra disabled (gray)
- **Disabled** - Not available (restrictions)

## Smart Stages

When enabled, pressing a stage button:
1. Disables all previous stage buttons
2. Enables the pressed button
3. Updates `currentStage`

## Restrictions

Extras can be restricted by:
- Lights must be on
- Doors must be closed (if configured)
- Vehicle must be healthy (if repair flag not set)

## Keybindings

Registers commands for numpad 1-9:
```lua
RegisterCommand('ulc:button_1', ...)
RegisterKeyMapping('ulc:button_1', 'ULC: Button 1', 'keyboard', 'NUMPAD1')
```

## UI Communication

Sends NUI messages:
- `populateButtons` - Initial button setup
- `setButtonActive` - Update button state

## Helper Functions

- `GetButtonByExtra(extra)` - Find button config by extra number
- `GetExtraByKey(key)` - Find extra number by key
- `DisableButtonsUpToStage(stage)` - Smart stage helper

## Integration

Other features call `ULC:SetStage()` to control extras:
- Park patterns
- Brake patterns
- Reverse patterns
- Horn patterns
- Default stages
