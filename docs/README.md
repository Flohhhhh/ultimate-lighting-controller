# ULC Developer Documentation

Documentation for contributors and agents to understand ULC's architecture and development approach.

## Purpose

ULC is built around a modular, opt-in architecture where:
- No vehicle is affected without explicit configuration
- Each feature operates independently
- Backwards compatibility is non-negotiable
- Configuration validation happens server-side before distribution

## Documentation Structure

- **[Architecture Overview](./architecture/overview.md)** - Core design principles, component flow, and state management
- **[Development Patterns](./development-patterns.md)** - Common patterns and approaches used throughout the codebase

## Key Architectural Concepts

### Modular Feature Design
Each feature is self-contained in its own `c_[feature].lua` file. Features:
- Check for their own configuration before running
- Operate independently in their own threads
- Share state through global variables (`MyVehicle`, `MyVehicleConfig`)
- Control vehicle extras through a central function (`ULC:SetStage`)

### Configuration-First Approach
Vehicle configurations define what features are enabled:
- Server loads and validates all configs on startup
- Validation catches errors before they reach clients
- Clients receive only validated configurations
- Configuration changes require server restart

### Opt-In Everything
Features must be explicitly enabled in vehicle config. Default behavior is always "off" for new features.

## File Organization

```
ulc/
├── client/          # Feature modules (c_[feature].lua)
│   └── c_main.lua   # Entry point: vehicle detection & state
├── server/
│   └── s_main.lua   # Configuration loader & validator
├── shared/          # Utility functions
└── config.lua       # Global settings
```

## Contributing

When making changes:
1. **Maintain backwards compatibility** - Old configs must continue to work
2. **Validate new config fields** - Add checks in `s_main.lua` `CheckData()`
3. **Default to disabled** - New features should be opt-in
4. **Keep features independent** - Avoid tight coupling between feature modules
