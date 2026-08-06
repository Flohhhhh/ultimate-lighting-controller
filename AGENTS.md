# Repository Instructions

- Keep `example.ulc.lua` up to date whenever features are added, removed, renamed, or behavior changes in a way that affects vehicle configuration.
- Treat `example.ulc.lua` as the canonical example config for contributors and users. New config fields should be reflected there with sensible defaults.
- Keep the `buttons` section in `example.ulc.lua` empty so it remains a clean copy/paste starter config. Per-button fields do not need placeholder entries there.
- All config-related changes must remain backwards compatible with older config files, consistent with the README guidance that features are opt-in.
- Do not require existing configs to define newly added sections or keys. Guard optional config access and preserve behavior for older configs that do not include newer settings.
- Never add annotations to `example.ulc.lua`
