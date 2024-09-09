# Ultimate Lighting Controller

![ulc_banner](https://user-images.githubusercontent.com/48927090/224608424-52e9505c-adc2-47dd-b5ab-30a5f933427f.png)<br><br>
<img alt="Discord" src="https://img.shields.io/discord/603591936372244501?label=Discord&logo=Discord&logoColor=white">
<img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/flohhhhh/ultimate-lighting-controller?label=Version">
<img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/flohhhhh/ultimate-lighting-controller">

ULC is an all-in-one lighting controller for non-ELS vehicles in FiveM! It uses the extra-based lighting stages on your vehicles and adds extra automation and improvements to create amazing, realistic, and fully-configurable lighting controls.

If you are a vehicle developer, [view the full documentation](https://docs.dwnstr.com/ulc/overview).

# Links

[Join Discord](https://discord.gg/zH3k624aSv)<br>
[Full ULC documentation](https://docs.dwnstr.com/ulc/overview)<br>
[Config Generator](https://ulc.dwnstr.com/generator)

[CFX Forum Post](https://forum.cfx.re/t/free-ultimate-lighting-controller/4985223)

[Video Preview](https://www.youtube.com/watch?v=f1H6sohjTao)<br>
[Video Tutorial](https://youtu.be/FIF3qqRY0Ts)

# Key Features

- Stage Controls
- Park Patterns
- Park Pattern Sync
- Intuitive & Minimal UI
- Brake Extras
- Reverse Extras
- Smart Steady Burns
- Blackout Command
- Horn/Honk Patterns & Extras
- Smart Stage Controls
- Granular Configuration per Vehicle
- Re-mappable Keybindings
- Great performance
- more!

# Installation

1. place `ulc` in your `resources` folder<br>
2. add `ensure ulc` to your `server.cfg`
3. add the names of your ULC ready resources in the `config.lua`

For more installation help view the [video tutorial!](https://youtu.be/FIF3qqRY0Ts)

# Dependencies

- `onesync` (as of v1.7.0)
- `baseevents`

<hr>

# Goes well with:

- [Real Brake Lights](https://github.com/Flohhhhh/real-brake-lights)
- [Luxart Vehicle Control](https://github.com/TrevorBarns/luxart-vehicle-control)

# Credits

- [theebu](https://github.com/theebu) - for help with auto repair limitation
- Everyone who helped test!

<hr>

# Vehicle Configuration

[Get started by viewing the full documentation here!](https://docs.dwnstr.com/ulc/overview)

Each vehicle that is configured to use ULC can have it's own dedicated configuration. This configuration can even be included in the vehicle's resource as a `ulc.lua` file, this way vehicle developers can deliver their vehicles pre-configured for ULC.

ULC offers a wide range of configuration settings and all features are opt-in.

**By default, no vehicles are affected by ULC's functionality.** In order to enable ULC for a vehicle, you must configure it. There are two methods for doing so.

# Information for Contributors

## How to work on the interface

The UI is built using React, Vite, Typescript, and Tailwind CSS. The React project in `/ulc/src` builds out to `/ulc/html` which is where FiveM runs it from.

Follow these steps to run and test locally.

1. `cd ulc/src/src`
2. `npm i`
3. Uncomment the debugging buttons in `App.tsx`.
4. `npm run dev`
5. View the app in your browser and use the debug buttons to show the UI.

To build the UI to the `html` folder:

1. Simply `npm run build`

## Contribution guide

<!-- TODO: need to formalize this in a contributing.md -->

1. All changes that effect the `ulc.lua` config in any way must be 100% backwards compatible. That is, a `ulc.lua` file that was created on the first day ULC was released must still work today.
   1. Any new features should never throw errors if that config section is not present and by default the new behavior should be entirely disabled.
   2. Changes to the configuration format of an existing feature must also still support the old format.
   3. For this reason, it's imperative that new features be well though-out in terms of the format of their configuration in the `ulc.lua` files.
