# Ultimate Lighting Controller
![ulc_banner](https://user-images.githubusercontent.com/48927090/209438952-b931af04-f7b5-45bb-b2df-514d6c28d751.png)


ULC is an all-in-one lighting controller for Non-ELS vehicles in FiveM! It uses the extra-based lighting stages on your vehicles and adds extra automation and improvements to create amazing, realistic, and fully-configurable lighting controls.

[Join Discord](https://discord.gg/dwnstr-fivem)<br>
[Full ULC documentation](https://github.com/dwnstr/vehicle-docs/wiki/ULC)<br>

# Key Features
- Stage Controls
- Park Patterns
- Brake Patterns & Extras
- Smart Steady Burns
- Horn/Honk Patterns & Extras
- Granular Configuration per Vehicle
- Re-mappable Keybindings
- Great performance

# Installation
place ``ulc`` in your ``resources`` folder<br>
add ``ensure ulc`` to your ``server.cfg``

# Configuration
ULC offers a wide range of configuration settings, as well as a table of vehicle configurations.

By default, no vehicles are affected by ULC's functionality. In order to enable ULC for a vehicle, you must add it to the ``Vehicles`` table in the config file.

For details about each config value, view your own ``config.lua`` file which has comments, or view the [full ULC documentation.](https://github.com/dwnstr/vehicle-docs/wiki/ULC)

## Example Settings Config

The top of the config file has a series of global settings which affect the way the effects of ULC work. 

```lua
    muteBeepForLights = true,
    useKPH = false,
    healthThreshold = 990,

    ParkSettings = {
        speedThreshold = 1,
        checkDoors = true,
        delay = 0.5,
        syncDistance = 32,
        syncCooldown = 10,
    },
    
    SteadyBurnSettings = {
        nightStartHour = 18,
        nightEndHour = 6,
        delay = 10,
    },

    BrakeSettings = {
        speedThreshold = 30
    },
```

## Example Vehicle Config

Below the settings is the ``Vehicles`` table. This table is populated with vehicle configuration that enable specific features that that vehicle uses, and configures the links to extras.

```lua
{name = 'sp20',
  steadyBurnConfig = {
      forceOn = false,
      useTime = true,
      sbExtras = {1}
  },
  parkConfig = {
      usePark = true,
      useSync = true,
      syncWith = {'sp20', 'sp18chrg'},
      pExtras = {10, 11},
      dExtras = {}
  },
  hornConfig = {
      useHorn = true,
      hornExtras = {12}
  },
  brakeConfig = {
      useBrakes = true,
      brakeExtras = {12}
  },
  buttons = {
    {label = 'STAGE 2', key = 5, extra = 8},
    {label = 'SCENE', key = 6, extra = 12},
    {label = 'TA', key = 7, extra = 9},
  }
},
```
