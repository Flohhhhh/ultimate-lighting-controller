# Other Features

## Brake Patterns (c_brake.lua)

Automatically enables extras when vehicle is braking.

**Config:**
```lua
brakeConfig = {
    useBrakes = true,
    brakeExtras = {5, 6}
}
```

**Logic:**
- Monitors brake pedal state
- Enables `brakeExtras` when braking
- Disables when brake released
- Only active when lights are on

---

## Reverse Patterns (c_reverse.lua)

Enables extras when vehicle is in reverse gear.

**Config:**
```lua
reverseConfig = {
    useReverse = true,
    reverseExtras = {7, 8}
}

ReverseSettings = {
    useRandomExpiration = true,
    minExpiration = 3,
    maxExpiration = 8
}
```

**Logic:**
- Monitors vehicle gear
- Enables `reverseExtras` in reverse
- Expires after random delay when stopped
- Only active when lights are on

---

## Horn Patterns (c_horn.lua)

Enables extras briefly when horn is pressed.

**Config:**
```lua
hornConfig = {
    useHorn = true,
    hornExtras = {9},
    duration = 150  -- Milliseconds
}
```

**Logic:**
- Detects horn key press
- Enables `hornExtras` for duration
- Auto-disables after duration

---

## Blackout Mode (c_blackout.lua)

Temporarily disables all lighting for tactical operations.

**Features:**
- Command: `/blackout [radius] [duration]`
- Affects all vehicles within radius
- Server-coordinated via s_blackout.lua
- Temporarily disables sirens

**Logic:**
- Server broadcasts blackout to clients
- Affected clients disable vehicle sirens
- Re-enables after duration

---

## Cruise Control (c_cruise.lua)

Shows cruise control state in UI.

**Logic:**
- Monitors cruise control state
- Updates UI indicator
- Pure display feature

---

## Turn Signals (c_signals.lua)

Manages extras tied to turn signals.

**Config:**
```lua
signalConfig = {
    useSignals = true,
    leftExtra = 10,
    rightExtra = 11,
    bothExtra = 12
}
```

**Logic:**
- Monitors turn signal state
- Enables appropriate extra for active signal
- Handles hazard lights (both signals)

---

## Door Monitoring (c_doors.lua)

Monitors vehicle door state for restriction checks.

**Logic:**
- Tracks door open/closed state
- Used by button restrictions
- Some vehicles restrict extra usage with doors open

---

## Beeps (c_beeps.lua)

Provides audio feedback for light toggle.

**Function:** `PlayBeep(on)`
- Plays different sounds for lights on/off
- Only if `Config.controlLights = true`

---

## HUD/UI (c_hud.lua)

Manages the React-based UI display.

**Functions:**
- `ULC:SetDisplay(bool)` - Show/hide UI
- `ULC:PopulateButtons()` - Send button config to UI
- Command: `/ulc` - Toggle UI visibility

**Preferences:**
- Stored in `ClientPrefs.hideUi`
- Persists across sessions

**UI Messages:**
- `setDisplay` - Show/hide
- `populateButtons` - Initial setup
- `setButtonActive` - Button state
- `toggleIndicator` - Light state
- Speed/cruise updates
