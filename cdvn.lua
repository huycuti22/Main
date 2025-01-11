local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sigma Hub - Cong Dong Viet Nam",
    SubTitle = "By ghuy4800",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
local Keybind = Tabs.Main:AddKeybind("Keybind", {
    Title = "KeyBind",
    Mode = "Toggle", -- Always, Toggle, Hold
    Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

    -- Occurs when the keybind is clicked, Value is true/false
    Callback = function(Value)
        print("Keybind clicked!", Value)
    end,

    -- Occurs when the keybind itself is changed, New is a KeyCode Enum OR a UserInputType Enum
    ChangedCallback = function(New)
        print("Keybind changed!", New)
    end
})
getgenv().AutoGrab = false
getgenv().AutoLog = false
local gotbox = false
local gotTree = false


local Options = Fluent.Options

local Toggle = Tabs.Main:AddToggle("Auto Grab", {Title = "Grab", Default = false })
Toggle:OnChanged(function(t)
    print(t)
    getgenv().AutoGrab = t
end)



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
local function interactWithPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0

        -- Check for mobile or PC
        local UserInputService = game:GetService("UserInputService")
        if UserInputService.TouchEnabled then
            -- Mobile touch interaction
            prompt:InputHoldBegin()
            wait(0.1)
            prompt:InputHoldEnd()
        else
            -- PC key press simulation
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)
        end
    end
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
        TP(npc.HumanoidRootPart.CFrame, 40) -- Adjust NPC position here if necessary.
        wait(1)
        interactWithPrompt(proximityPrompt)
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

        TP(defaultLocation.CFrame * CFrame.new(0,3,0), 40)
        wait(1)
        interactWithPrompt(proximityPrompt)
        gotbox = true
        wait(1.5)

        
    end
    return true
end

spawn(function()
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local job = game.Workspace:FindFirstChild("Jobs")
    local delivery = job and job:FindFirstChild("Delivery")
    local defaultLocation = delivery and delivery.Box:FindFirstChild("Part")

    while true do
        if getgenv().AutoGrab then
            -- Check if player is on the correct team
            if not checkTeam(player, "Giao hàng") then
                joinTeam("Giao hàng")
                repeat
                    wait(0.5)
                until checkTeam(player, "Giao hàng") -- Wait until the team is switched
            end

            -- Grab box logic
            if not gotbox and defaultLocation then
                gotbox = grabBox(defaultLocation, player)
                wait(1)
            end

            -- Delivery logic
            local box = game.Players.LocalPlayer.Backpack:FindFirstChild("Box")
            if box and box:FindFirstChild("Address") and gotbox then
                print("Box and Address found, and gotbox is true")
            
                local addressValue = box.Address.Value
                print("Address value:", addressValue)
            
                local realPlace = game.Workspace.Jobs.Delivery:FindFirstChild(addressValue)
                if realPlace and realPlace:IsA("BasePart") then
                    print("Found delivery location:", realPlace.Name)
            
                    -- Teleport to the shipping place
                    TP(CFrame.new(798.446533, 22.1844006, -522.543762), 40)
                    print("Teleported to shipping place")
                    wait(1.5)
            
                    -- Equip box and teleport to delivery location
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        print("Humanoid found, equipping tool")
                        player.Character.Humanoid:EquipTool(box)
                    else
                        warn("Humanoid not found")
                    end
            
                    TP(realPlace.CFrame, 50)
                    print("Teleported to delivery location")
                    wait(1)
            
                    -- Interact with the delivery prompt
                    local proximityPrompt = realPlace:FindFirstChildOfClass("ProximityPrompt")
                    if proximityPrompt then
                        interactWithPrompt(proximityPrompt)
                        print("Delivery completed!")
                        gotbox = false
                        wait(1)
                    else
                        warn("Delivery prompt not found.")
                    end
                else
                    warn("Error: Destination not found.")
                end
            else
                print("Conditions not met: box:", box, "gotbox:", gotbox)
            end
            
        elseif getgenv().AutoLog then
            -- Logging logic remains unchanged
        end

        wait(0.1)
    end
end)

