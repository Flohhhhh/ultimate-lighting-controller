if LoadResourceFile(GetCurrentResourceName(), "config.local.lua") then
    local context = IsDuplicityVersion() and "server" or "client"
    print("[ULC] Local configuration loaded (" .. context .. "): config.local.lua")
end
