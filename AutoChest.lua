local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()

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

local Main = Window:Tab({
    Name = "Main",
    Icon = "rbxassetid://11396131982",
    Color = Color3.new(1, 0, 0)
})

local AutoChestSec = Main:Section({
    Name = "Auto"
})

local Speed = 100


-- Teleport function
function TP(P1, place, callback)
    if not P1 then return end -- Ensure P1 exists
    local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end -- Ensure the character's HumanoidRootPart exists

    local Distance = (P1.Position - humanoidRootPart.Position).Magnitude

    -- Handle special case for "SkyArea2"
    Speed = Distance < 250 and 600 or Distance < 500 and 400 or Distance < 1000 and 250 or 300

    -- Create and play the Tween for the final teleport
    local Tween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = P1}
    )
    Tween:Play()
    Tween.Completed:Wait() -- Wait for the teleport tween to finish

    -- Execute the callback if provided
    if callback then
        callback()
    end
end

-- Auto Chest toggle
getgenv().AutoChest = false
local AutoChestTG = AutoChestSec:Toggle({
    Name = "Auto Chest (Not sure for work on sea 2 and 3)",
    Default = false,
    Callback = function(Bool)
        getgenv().AutoChest = Bool
        if Bool then
            spawn(function()
                while getgenv().AutoChest do
                    local foundChest = false
                    for _, island in pairs(game.Workspace.Map:GetChildren()) do
                        if island:FindFirstChild("Chests") then
                            print("Island with chests found:", island.Name)
                            
                            for _, chest in pairs(island.Chests:GetChildren()) do
                                if chest:IsA("BasePart") and chest.CanTouch and getgenv().AutoChest then
                                    foundChest = true
                                    Library:Notify({
                                        Name = "Chest Found",
                                        Text = "Chest found in "..island.Name.." (Is teleporting)",
                                        Icon = "rbxassetid://11401835376",
                                        Duration = 3
                                    })
                                    TP(chest.CFrame, island.Name, function()
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
        end
    end
})
