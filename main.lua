local function SafeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        return result
    else
        warn("Failed to load: " .. url .. " | Error: " .. result)
        return nil
    end
end

local Config = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Config.lua")
local Utilities = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Utilities.lua")

if not Config or not Utilities then
    warn("Config or Utilities failed to load. Exiting script.")
    return
end

local ESP = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/ESP.lua")
local MiddleClick = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/MiddleClick.lua")
local Aimbot = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Aimbot.lua")
local UI = SafeLoad("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/UI.lua")

if ESP then ESP = ESP(Config, Utilities) end
if UI then UI = UI(Config, ESP, MiddleClick, Aimbot) end

if ESP and ESP.Initialize then ESP.Initialize() end
if MiddleClick and MiddleClick.Initialize then MiddleClick.Initialize() end
if Aimbot and Aimbot.Initialize then Aimbot.Initialize() end

print("DeadRails ESP Loaded Successfully!")
