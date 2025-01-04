local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()

Window = Library:Create({
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

local Main = Window:Tab({
    Name = "Main",
    Icon = "rbxassetid://11396131982",
    Color = Color3.new(1, 0, 0)
})

local AutoChestSec = Main:Section({
    Name = "Auto"
})

local Speed = 100

function TP(P1, callback)
    local Distance = (P1.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if Distance < 250 then
        Speed = 800
    elseif Distance < 500 then
        Speed = 600
    elseif Distance < 1000 then
        Speed = 500
    elseif Distance >= 1000 then
        Speed = 400
    end
    local Tween = game:GetService("TweenService"):Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = P1}
    )
    Tween:Play()
    Tween.Completed:Wait() -- Wait for the teleport tween to finish
    if callback then
        callback()
    end
end

getgenv().AutoChest = false
local AutoChestTG = AutoChestSec:Toggle({
    Name = "Auto Chest",
    Default = false,
    Callback = function(Bool)
        getgenv().AutoChest = Bool
    end
})

spawn(function()
    while getgenv().AutoChest do
        local foundChest = false
        for _, island in pairs(game.Workspace.Map:GetChildren()) do
            if island:FindFirstChild("Chests") then
                print("Island with chests found:", island.Name)
                for _, chest in pairs(island.Chests:GetChildren()) do
                    if chest:IsA("BasePart") and getgenv().AutoChest and chest.CanTouch == true then
                        foundChest = true
                        TP(chest.CFrame, function()
                            wait(0.5) -- Delay after reaching the chest
                        end)
                    end
                    if not getgenv().AutoChest then break end
                end
            end
            if not getgenv().AutoChest or foundChest then break end
        end
        if not foundChest then
            print("No chests found on any islands. Retrying...")
            wait(1) -- Wait before checking all islands again
        end
    end
end)