local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()

Window = Library:Create({
	Name = "Sigma Hub - Cong Dong Viet Nam",
	Footer = "By ghuy4800",
	ToggleKey = Enum.KeyCode.RightShift,
	LoadedCallback = function()
		Window:TaskBarOnly(true)
	end,
	ToggledRelativeYOffset = 0
})

local Tab1 = Window:Tab({
	Name = "Main",
	Icon = "rbxassetid://11396131982",
	Color = Color3.new(1, 0, 0)
})
local Tab2 = Window:Tab({
	Name = "Info",
	Icon = "rbxassetid://11396131982",
	Color = Color3.new(1, 0, 0)
})

local Section1 = Tab1:Section({
	Name = "Main Farm"
})

getgenv().AutoGrab = false
local gotbox = false

local Toggle = Section1:Toggle({
	Name = "Auto Grab",
	Default = false,
	Callback = function(Bool) 
		print("Auto Grab toggled:", Bool)
        getgenv().AutoGrab = Bool
	end
})

-- Function to teleport to a given CFrame
local isTeleporting = false

local function randomDelay(min, max)
    wait(math.random(min * 1000, max * 1000) / 1000)
end

function TP(targetCFrame)
    if isTeleporting then return end
    isTeleporting = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and typeof(targetCFrame) == "CFrame" then
        -- Add random intermediate positions
        local intermediate = targetCFrame.Position + Vector3.new(
            math.random(-5, 5),
            math.random(0, 5),
            math.random(-5, 5)
        )

        local intermediateCFrame = CFrame.new(intermediate)

        -- Tween to intermediate
        local tween1 = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new(1, Enum.EasingStyle.Linear),
            {CFrame = intermediateCFrame}
        )
        tween1:Play()
        tween1.Completed:Wait()

        -- Tween to final destination
        local tween2 = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new(1, Enum.EasingStyle.Linear),
            {CFrame = targetCFrame}
        )
        tween2:Play()
        tween2.Completed:Wait()
    else
        warn("HumanoidRootPart not found or invalid targetCFrame provided.")
    end
    randomDelay(0.5, 1.5) -- Random delay after teleport
    isTeleporting = false
end


local function checkTeam(player)
    return player.Team and player.Team.Name == "Giao hàng"
end

local function joinTeam()
    local npc = game.Workspace.NPCs["Giao hàng"]
    if npc then
        local proximityPrompt = npc:FindFirstChildOfClass("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt.HoldDuration = 0
        end
        TP(CFrame.new(831.900146, 19.9371243, -487.379547))

        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)

        local player = game.Players.LocalPlayer
        player.CharacterAdded:Wait()
    else
        warn("NPC for joining team not found.")
    end
end

local function grabBox(defaultLocation, player)
    if not gotbox and defaultLocation then
        local proximityPrompt = defaultLocation:FindFirstChildOfClass("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt.HoldDuration = 0
        end
        TP(defaultLocation.CFrame)
        wait(1)

        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)
        gotbox = true
    end
    return gotbox
end

spawn(function()
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local job = game.Workspace:FindFirstChild("Jobs")
    local delivery = job and job:FindFirstChild("Delivery")
    local defaultLocation = delivery and delivery.Box:FindFirstChild("Part")

    while true do
        if getgenv().AutoGrab then
            if checkTeam(player) then
                if not gotbox and defaultLocation then
                    grabBox(defaultLocation, player)
                end

                local box = backpack:FindFirstChild("Box")
                if box and box:FindFirstChild("Address") then
                    local addressValue = box.Address.Value
                    local realPlace = game.Workspace.Jobs.Delivery:FindFirstChild(addressValue)

                    if realPlace and realPlace:IsA("BasePart") and gotbox then
                        TP(CFrame.new(798.446533, 22.1844006, -522.543762))
                        wait(0.5)

                        TP(realPlace.CFrame)
                        print("Delivering to:", addressValue)

                        player.Character.Humanoid:EquipTool(box)

                        local proximityPrompt = realPlace:FindFirstChildOfClass("ProximityPrompt")
                        if proximityPrompt then
                            proximityPrompt.HoldDuration = 0
                        end

                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendKeyEvent(true, "E", false, game)
                        wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, "E", false, game)

                        gotbox = false
                        wait(3)

                        
                    else
                        warn("Error: Destination not found.")
                    end
                else
                    warn("Error: Box or Address not found.")
                end
            else
                joinTeam()
            end
        end
        wait(0.1)
    end
end)