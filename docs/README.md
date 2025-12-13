# ULC Developer Documentation

This documentation provides technical details for contributors and developers working on the Ultimate Lighting Controller (ULC).

## Structure

- **[Architecture](./architecture/)** - System design and component interaction
- **[Features](./features/)** - Individual feature implementations
- **[Configuration](./configuration/)** - Vehicle configuration and validation

## Quick Reference

### Key Files

- **`c_main.lua`** - Main client thread, vehicle detection, and light state management
- **`s_main.lua`** - Server index file, loads and validates vehicle configurations
- **Feature files** - `c_[feature].lua` for client-side features
- **`config.lua`** - Global configuration settings
- **`shared_functions.lua`** - Shared utility functions

### Client Features (c_*.lua)

Each feature has its own file:
- `c_stages.lua` - Stage controls and cycling
- `c_park.lua` - Park patterns and vehicle sync
- `c_buttons.lua` - UI button management
- `c_brake.lua` - Brake light extras
- `c_reverse.lua` - Reverse light extras
- `c_horn.lua` - Horn patterns and extras
- `c_blackout.lua` - Blackout mode
- `c_cruise.lua` - Cruise control integration
- `c_signals.lua` - Turn signal handling
- `c_doors.lua` - Door state monitoring
- `c_beeps.lua` - Audio feedback
- `c_hud.lua` - UI/HUD management

### Server Components (s_*.lua)

- `s_main.lua` - Configuration loading and validation
- `s_blackout.lua` - Server-side blackout coordination
- `s_lvc.lua` - LVC compatibility

## Development Workflow

1. Features are opt-in via vehicle configuration
2. All config changes must be backwards compatible
3. Server validates configurations on startup
4. Client receives validated configs and enables features per vehicle
