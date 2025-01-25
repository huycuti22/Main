if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local HttpService = game:GetService('HttpService')
local player = game.Players.LocalPlayer

LRM_INIT_SCRIPT(function()
    local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
-- Ensure the API loaded successfully


-- Print the globally set key
    print("Global Key:", getgenv().Key)

-- Set your script ID here. Replace with your actual script ID.
    api.script_id = "b291479d7a831c39412c10e09cc92835"

-- Get the user's key from the global environment
    script_key = getgenv().Key
    local status = api.check_key(script_key); -- pass 32-char user key here
    print(status) --> table {code:<string>, message:<string>, data?:<table>}

-- custom logic below:
    if (status.code == "KEY_VALID") then

    -- fetch basic info about the key (only if KEY_VALID)
        print("Welcome. Seconds left: " .. (status.data.auth_expire - os.time()))
   
        print("Is key from ad system? " .. status.data.note == "Ad Reward" and "YES" or "NO")
    
        script_key = script_key; -- SET THE KEY BEFORE LOADSTRINGING.
    
        api.load_script(); -- Executes the script, based on the script_id you put above.
    -- Alternatively, you can just put the loadstring you got from luarmor website.
    -- You must specify the script_key global either way.
        return
    
    elseif (status.code == "KEY_HWID_LOCKED") then
        return
    
    elseif (status.code == "KEY_INCORRECT") then
        return    
    else
    -- fallback to anything else e.g blacklisted, key empty/too short:
        player:Kick("Key check failed:" .. status.message .. " Code: " .. status.code)
    end
end)




local Window = Fluent:CreateWindow({
    Title = "Sigma Hub - Cong Dong Viet Nam",
    SubTitle = "By ghuy4800",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Add new settings for WebhookLink and AutoWeb
local Settings = {
    AutoGrab = false,
    TweenSpeed = 70,
    AntiAfk = false,
    WebhookLink = "",
    AutoWeb = false,
    AutoLv = false,
    EnableHitbox = false,
    HitboxSize = 50,
    LoadedAccounts = {game.Players.LocalPlayer.UserId}
}

-- Function to update the configuration file
local function UpdateFile()
    if isfile and writefile and isfile("SigmaHubConfigCDVN.txt") then
        writefile("SigmaHubConfigCDVN.txt", HttpService:JSONEncode(Settings))
    end
end

-- Ensure settings are set in the global environment
getgenv().AutoGrab = Settings.AutoGrab
getgenv().TweenSpeed = Settings.TweenSpeed
getgenv().AntiAfk = Settings.AntiAfk
getgenv().WebhookLink = Settings.WebhookLink
getgenv().AutoWeb = Settings.AutoWeb
getgenv().AutoLv = Settings.AutoLv
getgenv().EnableHitbox = Settings.EnableHitbox
getgenv().HitboxSize = Settings.HitboxSize
local gotbox = false
local status = "Idle"
if isfile and not isfile("SigmaHubConfigCDVN.txt") and writefile then
    writefile("SigmaHubConfigCDVN.txt", HttpService:JSONEncode(Settings))
elseif isfile and isfile("SigmaHubConfigCDVN.txt") then
    Settings = HttpService:JSONDecode(readfile("SigmaHubConfigCDVN.txt"))
    print("SigmaHubConfigCDVN loaded")
    getgenv().AutoGrab = Settings.AutoGrab
    getgenv().TweenSpeed = Settings.TweenSpeed
    getgenv().AntiAfk = Settings.AntiAfk
    getgenv().WebhookLink = Settings.WebhookLink
    getgenv().AutoWeb = Settings.AutoWeb
    getgenv().AutoLv = Settings.AutoLv
    getgenv().HitboxSize = Settings.HitboxSize
    getgenv().EnableHitbox = Settings.EnableHitbox
end

-- Tabs and Options
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Webhook = Window:AddTab({ Title = "🔴 Webhook", Icon = "" }),
    Status = Window:AddTab({ Title = "Status", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "" }),
}
local Options = Fluent.Options

Tabs.Status:AddParagraph({
    Title = "Lv",
    Content = "Lv. "..game.Players.LocalPlayer.stats.Level.Value
})
Tabs.Status:AddParagraph({
    Title = "Farm Status"..status,
    Content = "Farm Status: "..status
})

Tabs.Main:AddButton({
    Title = "Anti Afk",
    Description = "Very important button",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        getgenv().AntiAfk = true
                        print("Anti-AFK has been enabled.")
                        Settings.AntiAfk = true  -- Update the setting in the config
                        UpdateFile()  -- Save the changes
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        })
    end
})

-- Ensure a clean loop by using task.spawn
task.spawn(function()
    while true do
        if getgenv().AntiAfk then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            print("Anti-AFK action performed.")
        end
        wait(10) -- Ensure a delay to avoid overloading
    end
end)

local function sendwebhook(content)
    if getgenv().WebhookLink == "" then
        warn("No webhook link provided.")
        return
    end

    local HttpService = game:GetService("HttpService")
    local webhookUrl = getgenv().WebhookLink

    local data = {
        event = "playerJoined",
        player = game.Players.LocalPlayer.Name,
        time = os.time(),
    }

    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("Custom webhook sent successfully!")
    else
        warn("Failed to send webhook: " .. response)
    end
end

-- UI Input to set the webhook URL
local Input = Tabs.Webhook:AddInput("Input", {
    Title = "Webhook Link",
    Default = Settings.WebhookLink,
    Numeric = false,
    Finished = false,
    Placeholder = "Enter your webhook link here...",
    Callback = function(Value)
        getgenv().WebhookLink = Value
        Settings.WebhookLink = Value  -- Update the setting in the config
        UpdateFile()  -- Save the changes
    end
})

-- Toggle for enabling/disabling auto webhook
local ToggleAutoWebhook = Tabs.Webhook:AddToggle("Auto Webhook", {
    Title = "Enable Auto Webhook",
    Default = Settings.AutoWeb
})
ToggleAutoWebhook:OnChanged(function(isEnabled)
    getgenv().AutoWeb = isEnabled
    Settings.AutoWeb = isEnabled  -- Update the setting in the config
    UpdateFile()  -- Save the changes

    if isEnabled then
        print("Auto webhook enabled.")
        -- Start the auto webhook loop in a coroutine
        spawn(function()
            while getgenv().AutoWeb do
                local player = game.Players.LocalPlayer
                local level = player:FindFirstChild("stats") and player.stats:FindFirstChild("Level") and player.stats.Level.Value or "N/A"
                local vnd = player:FindFirstChild("VND") and player.VND:FindFirstChild("Level") and player.VND.Level.Value or "N/A"

                sendwebhook("Your levels now are: " .. level .. " | VND is: " .. vnd)
                wait(15) -- Wait 15 seconds between each webhook
            end
        end)
    else
        print("Auto webhook disabled.")
    end
end)

-- Button to test the webhook
Tabs.Webhook:AddButton({
    Title = "Test Webhook",
    Description = "Send a test webhook.",
    Callback = function()
        Window:Dialog({
            Title = "Send test webhook",
            Content = "Do you want to send a test webhook?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        sendwebhook("This is a test webhook.")
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Test webhook cancelled.")
                    end
                }
            }
        })
    end
})


local ToggleAutoGrab = Tabs.Main:AddToggle("Auto Grab", {
    Title = "Enable Auto Grab",
    Default = Settings.AutoGrab,
    Callback = function(t)
        print("Auto Grab:", t)
        getgenv().AutoGrab = t
        Settings.AutoGrab = t
        UpdateFile()
        if not t then
            print("Auto Grab disabled.")
        end
    end,
})

local ToggleAutoLv = Tabs.Main:AddToggle("Auto Lv", {
    Title = "Enable Auto Level",
    Default = Settings.AutoLv,
    Callback = function(t)
        print("Auto Lv toggled:", t)
        getgenv().AutoLv = t
        Settings.AutoLv = t
        UpdateFile()
        if not t then
            print("Auto Lv disabled.")
        end
    end,
})

local ToggleHitbox = Tabs.Player:AddToggle("Enable Hitbox", {
    Title = "Enable Hitbox",
    Default = Settings.Hitbox,
    Callback = function(t)
        print("Hitbox toggled:", t)
        getgenv().EnableHitbox = t
        Settings.EnableHitbox = t
        UpdateFile()
        if not t then
            print("Hitbox disabled.")
        end
    end,
})
--[[while wait(0.1) do
    
end]]--



-- Tween Speed Slider
local Slider = Tabs.Main:AddSlider("Slider", {
    Title = "Tween Speed",
    Description = "Change your tween speed, recommended from 40 to 150",
    Default = Settings.TweenSpeed,
    Min = 40,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        getgenv().TweenSpeed = Value
        Settings.TweenSpeed = Value  -- Update the setting in the config
        UpdateFile()  -- Save the changes
    end
})

-- GUI Setup
local screenGui

if not game.CoreGui:FindFirstChild("Sigma Hub") then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Sigma Hub"
    screenGui.Parent = game.CoreGui

    local imageButtonC = Instance.new("ImageButton")
    imageButtonC.Image = "rbxassetid://133753729929737"
    imageButtonC.Position = UDim2.new(0.157, 0, 0.367, 0)
    imageButtonC.Size = UDim2.new(0, 75, 0, 75)
    imageButtonC.Parent = screenGui
end

-- Function to find frame with the most children
local function findFrameWithMostChildren()
    local frames = {}
    for _, child in ipairs(game.CoreGui:FindFirstChild("ScreenGui"):GetChildren()) do
        if child:IsA("Frame") and child.Name == "Frame" then
            table.insert(frames, child)
        end
    end

    local frameWithMoreChildren = nil
    local maxChildren = -1

    for _, frame in ipairs(frames) do
        local childrenCount = #frame:GetChildren()
        if childrenCount > maxChildren then
            maxChildren = childrenCount
            frameWithMoreChildren = frame
        end
    end
    return frameWithMoreChildren
end

local frameWithMoreChildren = findFrameWithMostChildren()
if frameWithMoreChildren then
    local imageButton = game.CoreGui:FindFirstChild("Sigma Hub"):FindFirstChild("ImageButton")

    -- Toggle frame visibility on button click
    imageButton.MouseButton1Click:Connect(function()
        frameWithMoreChildren.Visible = not frameWithMoreChildren.Visible
    end)
end

-- Teleportation function with sky tween
local isTeleporting = false
function TP(targetCFrame)
    if isTeleporting then return end
    isTeleporting = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and typeof(targetCFrame) == "CFrame" then
        local skyHeight = 40
        local startCFrame = humanoidRootPart.CFrame
        local skyCFrame = CFrame.new(startCFrame.Position.X, startCFrame.Position.Y + skyHeight, startCFrame.Position.Z)
        local destinationCFrame = CFrame.new(targetCFrame.Position.X, targetCFrame.Position.Y + skyHeight, targetCFrame.Position.Z)

        -- Tween up to the sky
        local tweenToSky = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new((skyCFrame.Position - startCFrame.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear),
            {CFrame = skyCFrame}
        )
        tweenToSky:Play()
        tweenToSky.Completed:Wait()

        -- Tween to the target position in the sky
        local tweenToTargetSky = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new((destinationCFrame.Position - skyCFrame.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear),
            {CFrame = destinationCFrame}
        )
        tweenToTargetSky:Play()
        tweenToTargetSky.Completed:Wait()

        -- Tween down to the final position
        local tweenToTargetGround = game:GetService("TweenService"):Create(
            humanoidRootPart,
            TweenInfo.new((targetCFrame.Position - destinationCFrame.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear),
            {CFrame = targetCFrame}
        )
        tweenToTargetGround:Play()
        tweenToTargetGround.Completed:Wait(1)
    else
        warn("HumanoidRootPart not found or invalid targetCFrame provided.")
    end

    isTeleporting = false
end

function TP1(P1)
    Distance = (P1.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if Distance < 250 then
        Speed = 600
    elseif Distance < 500 then
        Speed = 400
    elseif Distance < 1000 then
        Speed = 350
    elseif Distance >= 1000 then
        Speed = 200
    end
    game:GetService("TweenService"):Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear),
        {CFrame = P1}
    ):Play()
end

local function checkTeam(player, team)
    return player.Team and player.Team.Name == team
end

-- Function to interact with a proximity prompt
local function interactWithPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        local UserInputService = game:GetService("UserInputService")
        if UserInputService.TouchEnabled then
            prompt:InputHoldBegin()
            wait(0.1)
            prompt:InputHoldEnd()
        else
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)
        end
    end
end


-- Function to grab the box from its location
local function grabBox(defaultLocation, player)
    if not gotbox and defaultLocation then
        local proximityPrompt = defaultLocation:FindFirstChildOfClass("ProximityPrompt")
        TP(defaultLocation.CFrame)
        wait(1)
        interactWithPrompt(proximityPrompt)
        gotbox = true
        wait(1.5)
    end
    return gotbox
end

-- Function to join a team
local function joinTeam(team)
    local npcname = team == "Giao hàng" and "npc grab" or "ToiLaThanhTuan"
    local npc = game.Workspace.NPCs:FindFirstChild(team):FindFirstChild(npcname)
    if npc then
        local proximityPrompt = npc.Parent:FindFirstChildOfClass("ProximityPrompt")
        TP(npc.HumanoidRootPart.CFrame)
        wait(1)
        interactWithPrompt(proximityPrompt)

        local player = game.Players.LocalPlayer
        repeat
            wait(0.5)
        until checkTeam(player, team)
        getgenv().AutoGrab = false
        task.wait(2)
        getgenv().AutoGrab = true

        -- Continue auto grab after joining the tea
    else
        warn("NPC for joining team not found.")
    end
end
local function EquipWeapon(weaponName)
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local weapon = backpack:FindFirstChild(weaponName)
        if weapon then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(weapon)
                print("Equipped weapon:", weaponName)
            end
        else
            warn("Weapon not found in backpack:", weaponName)
        end
    end
end


local npcs
-- Main loop to automate actions
spawn(function()
    while true do
        
        -- Check if AutoGrab is enabled
        if getgenv().AutoGrab then
            local player = game.Players.LocalPlayer
            local job = game.Workspace:FindFirstChild("Jobs")
            local delivery = job and job:FindFirstChild("Delivery")
            local defaultLocation = delivery and delivery.Box:FindFirstChild("Part")

            -- If not in the "Giao hàng" team, join it
            if not checkTeam(player, "Giao hàng") then
                joinTeam("Giao hàng")
            end

            if not gotbox then
                gotbox = grabBox(defaultLocation, player)
                wait(2)
            end

            -- Process box if grabbed
            local box = player.Backpack:FindFirstChild("Box")
            if box and box:FindFirstChild("Address") and gotbox then
                local addressValue = box.Address.Value
                local realPlace = delivery:FindFirstChild(addressValue)

                -- If a valid destination is found, deliver the box
                if realPlace and realPlace:IsA("BasePart") then
                    -- Teleport to the delivery location
                    TP(CFrame.new(798.446533, 22.1844006, -522.543762))
                    wait(2)

                    -- Equip the box to the player character
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:EquipTool(box)
                    end
                    repeat
                        TP(realPlace.CFrame)
                        wait(3)
    
                        -- Interact with the delivery prompt
                        local proximityPrompt = realPlace:FindFirstChildOfClass("ProximityPrompt")
                        if proximityPrompt then
                            interactWithPrompt(proximityPrompt)
                            gotbox = false -- Reset box status after delivery
                            wait(2)
                        else
                            warn("Delivery prompt not found.")
                        end
                    until not gotbox or not getgenv().AutoGrab
                            

                    -- Teleport to the final destination
                    
                else
                    warn("Error: Destination not found.")
                end
            end
        elseif getgenv().AutoLv then
                local player = game.Players.LocalPlayer
                local giangHo = game.Workspace:FindFirstChild("GiangHo")
                local center = giangHo and giangHo:FindFirstChild("Center")
    
                if not center then
                    TP(CFrame.new(858.978394, 18.5102119, -1200.22485))
                else
                    TP(CFrame.new(858.978394, 18.5102119, -1200.22485))
                    local npcs = giangHo:FindFirstChild("NPCs")
                    if npcs then
                        for _, npc in pairs(npcs:GetChildren()) do
                            if npc.Name == "NPC" and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and player.Character.Humanoid.Health > 50 then
                                EquipWeapon(getgenv().Weapon) -- Equip weapon before attacking
                                repeat
                                    if npc:FindFirstChild("HumanoidRootPart") then
                                        local size = npc.HumanoidRootPart.Size
                                        if size ~= Vector3.new(60, 150, 60) then
                                            npc.HumanoidRootPart.Size = Vector3.new(60, 200, 60) -- Adjust size
                                        end
                                    end
                                    game:GetService("RunService").Heartbeat:wait()
                                    if npc.Parent and npc.Humanoid.Health > 0 then
                                        TP1(npc.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0))
                                        npc.HumanoidRootPart.CanCollide = false
                                        npc.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        
                                        

                                        local virtualUser = game:GetService("VirtualUser")
                                        virtualUser:CaptureController()
                                        virtualUser:Button1Down(Vector2.new(1280, 670), workspace.CurrentCamera.CFrame)
                                    end
                                until not npc.Parent or npc.Humanoid.Health <= 0 or not getgenv().AutoLv or player.Character.Humanoid.Health <= 30
                            else
                                TP(CFrame.new(858.978394, 18.5102119, -1200.22485))
                            end
                        end
                    else
                        warn("No NPCs found in GiangHo.")
                    end
                end
            elseif getgenv().EnableHitbox then
                for i, v in next, game:GetService('Players'):GetPlayers() do
                    if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                        pcall(function()
                            for _, Hitbox in ipairs(v.Character:GetChildren()) do
                                if Hitbox:IsA("BasePart") and Hitbox:FindFirstChild("WeldConstraint") then
                                    if Hitbox.Size ~= Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize) or
                                       Hitbox.Transparency ~= 0.9 or
                                       Hitbox.BrickColor ~= BrickColor.new("Really red") or
                                       Hitbox.Material ~= Enum.Material.Neon or
                                       Hitbox.CanCollide ~= false then
                                        -- Update hitbox properties only if they are not already set
                                        Hitbox.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                                        Hitbox.Transparency = 0.9
                                        Hitbox.BrickColor = BrickColor.new("Really red")
                                        Hitbox.Material = Enum.Material.Neon
                                        Hitbox.CanCollide = false
                                    end
                                end
                            end
                        end)
                    end
                end
            end                
        wait(0.1) -- Small delay to prevent overloading the loop        
    end
end)

