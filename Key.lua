-- Key Validation
local success, key = pcall(function()
    return game:HttpGet('https://pastebin.com/raw/fMtF0rta')
end)

if success then
    print("안녕하세요 - Xin Chao - Hello")
    if getgenv().Key == key then
        print("OK")
    else
        print("Wrong Key")
        local player = game.Players.LocalPlayer
        local reason = "Wrong Key"
        local message = string.format("You were kicked from this experience: %s", reason)
        player:Kick(message)
    end
else
    warn("Failed to load key")
end

-- Library + Variables
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local HttpService = game:GetService('HttpService')

local Settings = {
    AutoLoad = false,
    LoadedAccounts = {game.Players.LocalPlayer.UserId}
}

-- Read and Apply Settings
local function LoadSettings()
    if isfile and readfile and isfile("SigmaHubConfig.txt") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("SigmaHubConfig.txt"))
        end)
        if success and type(result) == "table" then
            Settings = result
        else
            warn("Failed to load settings from SigmaHubConfig.txt")
        end
    else
        if isfile and writefile then
            writefile("SigmaHubConfig.txt", HttpService:JSONEncode(Settings))
        end
    end
end

LoadSettings()

-- Debug: Check AutoLoad
print("Settings.AutoLoad:", Settings.AutoLoad)

-- Utility Functions
local function SendNotification(Name, Content, Image, Time)
    Library:Notify({
        Name = Name,
        Text = Content,
        Icon = Image,
        Duration = Time or 3
    })
end

local function UpdateFile()
    if isfile and writefile then
        local success, err = pcall(function()
            writefile("SigmaHubConfig.txt", HttpService:JSONEncode(Settings))
        end)
        if not success then
            warn("Failed to update SigmaHubConfig.txt:", err)
        end
    end
end

local function LoadScript()
    if Settings.AutoLoad then
        print("Auto Load True")
        SendNotification("Auto-Load Enabled", "Please wait...", "rbxassetid://13328029686", 5)
    else
        SendNotification("Checking Game", "Please wait...", "rbxassetid://13328029686", 5)
    end

    local GetScript
    local success, err = pcall(function()
        if game.PlaceId == 2753915549 then
            GetScript = Request({Url = "https://raw.githubusercontent.com/huycuti22/autochestBF/refs/heads/main/AutoChest.lua", Method = "GET"})
        end
    end)

    if not success then
        warn("Failed to fetch script:", err)
        SendNotification("Sigma Hub - Error", "Failed to fetch script.", "rbxassetid://161551681", 5)
        return
    end

    if GetScript and GetScript.Body and GetScript.Body ~= "404: Not Found" then
        task.wait(math.random(1, 4))
        Library:Destroy()
        loadstring(GetScript.Body)()
    else
        SendNotification("Sigma Hub - Error", "Game not supported.", "rbxassetid://161551681", 5)
    end
end

-- Notifications
SendNotification("Sigma Hub", "Loading... Please wait.", "rbxassetid://13328029686", 5)

-- UI Library Setup
local Window = Library:Create({
    Name = "Sigma Hub - Loader",
    Footer = "By Ghuy",
    ToggleKey = Enum.KeyCode.RightShift,
    KeySystem = false,
    MaxAttempts = 5
})

local Tab = Window:Tab({
    Name = "Main",
    Icon = "rbxassetid://11396131982",
    Color = Color3.new(1, 0, 0)
})

local Section1 = Tab:Section({
    Name = "Main"
})

Section1:Button({
    Name = "Load Script - " .. GameName,
    Callback = function()
        LoadScript()
    end
})

if writefile and readfile and isfile then
    Section1:Toggle({
        Name = "Auto Load",
        Default = Settings.AutoLoad,
        Callback = function(Bool)
            Settings.AutoLoad = Bool
            UpdateFile()
        end
    })
end

-- Auto Load Check
if Settings.AutoLoad then
    SendNotification("Sigma Hub", "Auto Load True, waiting for user settings", "rbxassetid://13328029686", 5)
    wait(15)
    print("AutoLoad is enabled. Loading script...")
    SendNotification("Sigma Hub", "Auto Load True, loading script", "rbxassetid://13328029686", 5)
    LoadScript()
else
    print("AutoLoad is disabled.")
end
