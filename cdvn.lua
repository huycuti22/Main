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
getgenv().AutoLog = false
local gotbox = false
local gotTree = false

local Toggle = Section1:Toggle({
	Name = "Auto Grab",
	Default = false,
	Callback = function(Bool) 
		print("Auto Grab toggled:", Bool)
        getgenv().AutoGrab = Bool
	end
})
local Toggle2 = Section1:Toggle({
	Name = "Auto Log - Not Work",
	Default = false,
	Callback = function(Bool) 
		print("Auto Log toggled:", Bool)
        getgenv().AutoLog = Bool
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

local function checkTeam(player, team)
    return player.Team and player.Team.Name == team
end

local function joinTeam(team)
    print(team)
    local npcname 
    if team == "Giao hàng" then
        npcname = "npc grab"
    else
        npcname = "ToiLaThanhTuan"
    end
    local npc = game.Workspace.NPCs:FindFirstChild(team):FindFirstChild(npcname)
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
        TP(defaultLocation.CFrame * CFrame.new(0,3,0), 40)
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
            if checkTeam(player, "Giao hàng") then
                if not gotbox and defaultLocation then
                    grabBox(defaultLocation, player)
                    print(gotbox)
                end

                local box = backpack:FindFirstChild("Box")
                if box and box:FindFirstChild("Address") and gotbox == true then
                    local addressValue = box.Address.Value
                    local realPlace = game.Workspace.Jobs.Delivery:FindFirstChild(addressValue)

                    if realPlace and realPlace:IsA("BasePart") then
                        TP(CFrame.new(798.446533, 22.1844006, -522.543762 )* CFrame.new(0,3,0), 40)
                        wait(3.5)
                        player.Character.Humanoid:EquipTool(box)
                        TP(realPlace.CFrame * CFrame.new(0,3,0), 50)
                        
                        print("Delivering to:", addressValue)
                        wait(4)

                        

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
                    wait(1)
                end
            else
                joinTeam("Giao hàng") 
                wait(2)
            end
        elseif getgenv().AutoLog then
                -- Teleport to initial position
                TP(CFrame.new(1612.82666, 22.8966408, -310.416016), 40)
                wait(2)
            
                -- Check if the player is on the correct team
                if checkTeam(player, "Khai thác gỗ") then
                    local args = {[1] = "eue",[2] = "R\195\172u"}
                    game:GetService("ReplicatedStorage"):WaitForChild("KnitPackages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("InventoryService"):WaitForChild("RE"):WaitForChild("updateInventory"):FireServer(unpack(args)) 
            
                    -- Ensure the required tool is in the inventory
                    local tool = backpack:FindFirstChild("Rìu")
                    if tool then
                        -- Equip the tool
                        player.Character.Humanoid:EquipTool(tool)
            
                        -- Loop through trees to find eligible ones for logging
                        local TreeFD = game.Workspace.Jobs.Trees
                        for _, tree in ipairs(TreeFD:GetChildren()) do
                            if tree.Name == "Tree" and not tree.Cooldown.Value and not tree.isCutting.Value then
                                -- Teleport to the tree
                                TP(tree.Prompt.CFrame, 40)
                                wait(1)
            
                                local proximityPrompt = tree.Prompt:FindFirstChildOfClass("ProximityPrompt")
                                if proximityPrompt then
                                    proximityPrompt.HoldDuration = 0
            
                                    -- Simulate key press to interact
                                    local VirtualInputManager = game:GetService("VirtualInputManager")
                                    VirtualInputManager:SendKeyEvent(true, "E", false, game)
                                    wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, "E", false, game)
            
                                    print("Logged tree successfully:", tree.Name)
            
                                    -- Process log clones
                                    for _, log in pairs(tree.LogClones:GetChildren()) do
                                        if log:IsA("Model") then
                                            local logPrompt = log.Trunk:FindFirstChildOfClass("ProximityPrompt")
                                            if logPrompt then
                                                logPrompt.HoldDuration = 0
                                                TP(log.Trunk.CFrame, 40)
            
                                                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                                                wait(0.1)
                                                VirtualInputManager:SendKeyEvent(false, "E", false, game)
                                                wait(1)
                                            end
                                        end
                                    end
            
                                    wait(2) -- Allow cooldown before processing the next tree
                                end
                            end
                        end
                    else
                        warn("Tool 'Rìu' not found in backpack.")
                    end
                else
                    -- If not on the correct team, attempt to join
                    joinTeam("Khai thác gỗ")
                    wait(2)
                end
            end
            
        
        wait(0.1)
    end
end)
