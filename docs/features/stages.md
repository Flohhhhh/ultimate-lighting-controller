# Stage Controls (c_stages.lua)

Manages lighting stage progression and cycling.

## Purpose

Allows drivers to control lighting intensity by stepping through configured stages using numpad controls.

## Configuration

```lua
stages = {
    useStages = true,
    stageKeys = {1, 2, 3}  -- Numpad keys for stages
}
```

## State

- `currentStage` - Current stage index (0 = all off)

## Functions

### `stageUp()`
- Increases stage by 1
- Activates next stage button
- Updates `currentStage`

### `stageDown()`
- Decreases stage by 1
- Activates previous stage button
- Updates `currentStage`

### `cycleStages()`
- Increments through stages
- Resets to 0 after max stage

### `getMaxStage()`
- Returns highest stage index

## Keybinds

- **NUM+** - Stage Up
- **NUM-** - Stage Down
- **NUM0** - Cycle Stages

## Default Stages

Optional feature to auto-enable/disable certain extras when lights turn on:

```lua
defaultStages = {
    useDefaults = true,
    enableKeys = {1, 2},   -- Auto-enable on lights on
    disableKeys = {8, 9}   -- Auto-disable on lights on
}
```

Called by `setDefaultStages()` when lights turn on.

## Integration

- Uses `ULC:SetStage()` from c_buttons.lua to toggle extras
- Reads button config to find extras for each stage
- Stage state tracked globally via `currentStage`
