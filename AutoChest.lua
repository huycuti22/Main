local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()

-- Create the main window
local Window = Library:Create({
    Name = "Sigma Hub",
    Footer = "By Ghuy",
    ToggleKey = Enum.KeyCode.RightShift,
    LoadedCallback = function()
        Window:TaskBarOnly(true)
    end,
    KeySystem = false,
    Key = "123456",
    MaxAttempts = 5,
    DiscordLink = nil,
    ToggledRelativeYOffset = 0
})

-- Create the main tab
local Main = Window:Tab({
    Name = "Main",
    Icon = "rbxassetid://11396131982",
    Color = Color3.new(1, 0, 0)
})

-- Create the Auto section
local AutoChestSec = Main:Section({
    Name = "Auto"
})

-- Default speed for teleportation
local Speed = 100

-- Teleport function
local function TP(P1, callback)
    if not P1 then return end
    local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local Distance = (P1.Position - humanoidRootPart.Position).Magnitude
    Speed = Distance < 250 and 600 or Distance < 500 and 400 or Distance < 1000 and 250 or 300

    local Tween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = P1}
    )
    Tween:Play()
    Tween.Completed:Wait()

    if callback then
        callback()
    end
end

-- Function to find the nearest chest
local function FindNearestChest()
    local closestChest = nil
    local shortestDistance = math.huge

    for _, island in pairs(game.Workspace:FindFirstChild("Map") and game.Workspace.Map:GetChildren() or {}) do
        if island:FindFirstChild("Chests") then
            for _, chest in pairs(island.Chests:GetChildren()) do
                if chest:IsA("BasePart") and chest.CanTouch then
                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - chest.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestChest = chest
                    end
                end
            end
        end
    end

    return closestChest
end

-- Globals and Toggles
getgenv().AutoChest = false
getgenv().AutoHop = false
getgenv().WaitNew = 0.5
getgenv().MaxChest = 40

local chestCollected = 0

-- Auto Chest Toggle
local AutoChestTG = AutoChestSec:Toggle({
    Name = "Auto Chest (Not sure for work on sea 2 and 3)",
    Default = false,
    Callback = function(Bool)
        getgenv().AutoChest = Bool
        if Bool then
            spawn(function()
                while getgenv().AutoChest do
                    local chest = FindNearestChest()
                    if chest then
                        Library:Notify({
                            Name = "Chest Found",
                            Text = "Chest found! (Teleporting), Total Chest = "..chestCollected,
                            Icon = "rbxassetid://11401835376",
                            Duration = 3
                        })
                        TP(chest.CFrame, function()
                            task.wait(0.5)
                            chestCollected = chestCollected + 1
                        end)
                    else
                        Library:Notify({
                            Name = "No Chests",
                            Text = "No chests found. Retrying...",
                            Duration = 2
                        })
                    end
                    task.wait(getgenv().WaitNew)
                end
            end)
        end
    end
})

-- Wait per Chest Slider
local Slider = AutoChestSec:Slider({
    Name = "Wait per chest",
    Max = 2,
    Min = 0.1,
    Default = 0.5,
    Callback = function(Number)
        getgenv().WaitNew = Number
    end
})

-- Max Chest to Collect Slider
local Slider2 = AutoChestSec:Slider({
    Name = "Max chest to collect",
    Max = 100,
    Min = 5,
    Default = 5,
    Callback = function(Number)
        getgenv().MaxChest = Number
    end
})

-- Auto Hop Toggle
local Toggle = AutoChestSec:Toggle({
    Name = "Auto hop if enough chest",
    Default = false,
    Callback = function(Bool)
        getgenv().AutoHop = Bool
    end
})

-- Server Hop Button

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = 2753915549 -- Blox Fruits Place ID

-- Hàm lấy danh sách server
local function getServerList(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local response = HttpService:JSONDecode(game:HttpGet(url))
    return response
end

-- Hàm chuyển server
local function serverHop()
    local cursor = nil
    while true do
        local servers = getServerList(cursor)
        if servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    Library:Notify({
                        Name = "Sigma Hub",
                        Text = "Dang hop server nha mmb",
                        Icon = "rbxassetid://11401835376",
                        Duration = 3
                    })
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, game.Players.LocalPlayer)
                    return
                end
            end
        end
        cursor = servers.nextPageCursor
        if not cursor then
            break
        end
    end
    warn("Không tìm thấy server phù hợp.")
end

local Button = AutoChestSec:Button({
    Name = "Hop Server",
    Callback = function()
        serverHop()
    end
})

-- Auto Hop Execution
spawn(function()
    while true do
        if getgenv().AutoHop and chestCollected >= getgenv().MaxChest then
            getgenv().AutoChest = false
            serverHop()
        end
        task.wait(1)
    end
end)
