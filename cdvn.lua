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

function TP(targetCFrame, speed)
    if isTeleporting then return end

    isTeleporting = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and typeof(targetCFrame) == "CFrame" then
        local distance = (targetCFrame.Position - humanoidRootPart.Position).Magnitude

        local tween = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new(distance / speed, Enum.EasingStyle.Linear),
            {CFrame = targetCFrame}
        )

        tween:Play()
        tween.Completed:Wait(1)
    else
        warn("HumanoidRootPart not found or invalid targetCFrame provided.")
    end

    isTeleporting = false
end

local function checkTeam(player)
    return player.Team and player.Team.Name == "Giao hàng"
end

local function joinTeam()
    local npc = game.Workspace.NPCs:FindFirstChild("Giao hàng"):FindFirstChild("npc grab")
    if npc then
        local proximityPrompt = npc.Parent:FindFirstChildOfClass("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt.HoldDuration = 0
        end
        TP(npc.HumanoidRootPart.CFrame, 40) -- Adjust NPC position here if necessary.

        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)

        local player = game.Players.LocalPlayer

        -- Wait until the team changes to "Giao hàng".
        local success = false
        for i = 1, 10 do
            if checkTeam(player) then
                success = true
                break
            end
            wait(0.5)
        end

        if not success then
            warn("Failed to join the team 'Giao hàng'. Retrying...")
        end
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
        TP(defaultLocation.CFrame, 40)
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
                if box and box:FindFirstChild("Address") and gotbox then
                    local addressValue = box.Address.Value
                    local realPlace = game.Workspace.Jobs.Delivery:FindFirstChild(addressValue)

                    if realPlace and realPlace:IsA("BasePart") then
                        TP(CFrame.new(798.446533, 22.1844006, -522.543762), 40)
                        wait(4)
                        player.Character.Humanoid:EquipTool(box)
                        TP(realPlace.CFrame, 50)
                        
                        print("Delivering to:", addressValue)
                        wait(2)

                        

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
                wait(2)
            end
        end
        wait(0.1)
    end
end)
