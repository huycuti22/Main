-- DeadRails ESP Cheat by LxckStxp
-- Injected via Executor



local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Config.lua"))()
local Utilities = loadstring(game:HttpGet("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Utilities.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/ESP.lua"))()(Config, Utilities)
local MiddleClick = loadstring("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/MiddleClick.lua")()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/Aimbot.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/huycuti22/Main/refs/heads/main/UI.lua"))()(Config, ESP, MiddleClick, Aimbot)

ESP.Initialize()
MiddleClick.Initialize()
Aimbot.Initialize()

print("DeadRails ESP Loaded Successfully!")
