print("Ok")
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Dead Rails | Aurora Hub ",
    SubTitle = "by ghuy4800",
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


local ESPConfig = {
    FadeStartMultiplier = 0.7, -- Fade starts at 70% of MaxDistance
    HealthBarDistance = 100,   -- Health bars visible under 100 studs
    SpatialFilterThreshold = 0.9, -- Skip updates beyond 90% MaxDistance
    SpatialMoveThreshold = 5,  -- Movement threshold for spatial filtering (studs)
    UpdateInterval = 0.2,      -- Update every 0.2 seconds
    RarityColors = {           -- Colors triggering rarity glow
        "Gold", "Silver", "Rare"
    }
}
local Config = {
    Enabled = true,
    MaxDistance = 1000,
    Colors = {
        -- Humanoid Colors
        Player = Color3.fromRGB(0, 0, 255),    -- Blue for players
        NPC = Color3.fromRGB(255, 0, 0),       -- Red for NPCs
        
        -- Item Colors
        Default = Color3.fromRGB(200, 200, 200), -- Gray for unidentified/junk items
        Corpse = Color3.fromRGB(139, 69, 19),   -- Brown for corpses
        Fuel = Color3.fromRGB(255, 165, 0),     -- Orange for fuel
        Ammo = Color3.fromRGB(0, 255, 255),     -- Cyan for ammo
        Weapon = Color3.fromRGB(255, 0, 255),   -- Magenta for guns, weapons, melee
        Junk = Color3.fromRGB(100, 100, 100),   -- Dark gray for junk
        Healing = Color3.fromRGB(0, 255, 0),    -- Green for bandages and snake oil
        Gold = Color3.fromRGB(255, 215, 0),     -- Yellow for gold (high value)
        Silver = Color3.fromRGB(192, 192, 192), -- Silver for silver (high value)
        Rare = Color3.fromRGB(160, 32, 240)     -- Purple for rare items (Holy Water, Crucifix, Bond)
    }
}
local Aimbot = {
    Enabled = false, -- Controlled by UI
    Aiming = false, -- Tracks right-click state
    Target = nil,   -- Current NPC target
    RenderConnection = nil, -- Store RenderStepped connection
    Settings = {
        AimKey = Enum.UserInputType.MouseButton2, -- RightClick
    }
}
local ESPManager = {
    Items = {},
    Humanoids = {},
    Connection = nil,
    VanillaUIVisible = true
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Utilities = {}
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera


--getgenv
getgenv().Aimbot = false
getgenv().Esp = false
--ESP OBJ
local TweenService = game:GetService("TweenService")
    
local ESPObject = {}
    
function ESPObject.Create(object, espType)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.1
    highlight.Adornee = object
    highlight.Parent = game.CoreGui
        
    local glow = Instance.new("Highlight")
    glow.FillTransparency = 0.95
    glow.OutlineTransparency = 0.6
    glow.Adornee = object
    glow.Parent = game.CoreGui
        
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 130, 0, espType == "Item" and 25 or 35)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")) or object
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui
        
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, espType == "Item" and 1 or 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
        
    local shadow = Instance.new("TextLabel")
    shadow.Size = UDim2.new(1, 2, espType == "Item" and 1 or 0.6, 2)
    shadow.Position = UDim2.new(0, -1, 0, -1)
    shadow.BackgroundTransparency = 1
    shadow.TextSize = 14
    shadow.Font = Enum.Font.GothamBold
    shadow.TextStrokeTransparency = 1
    shadow.TextTransparency = 0.5
    shadow.Parent = billboard
        
    local healthBar, healthFill, healthBorder
    if espType ~= "Item" then
        healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(0.9, 0, 0.15, 0)
        healthBar.Position = UDim2.new(0.05, 0, 0.75, 0)
        healthBar.BackgroundTransparency = 1
        healthBar.Parent = billboard
            
        healthBorder = Instance.new("Frame")
        healthBorder.Size = UDim2.new(1, 4, 1, 4)
        healthBorder.Position = UDim2.new(0, -2, 0, -2)
        healthBorder.BackgroundColor3 = espType == "Player" and Config.Colors.Player or Config.Colors.NPC
        healthBorder.BackgroundTransparency = 0.5
        healthBorder.BorderSizePixel = 0
        healthBorder.ZIndex = 0
        healthBorder.Parent = healthBar
            
        healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.Position = UDim2.new(0, 0, 0, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.BorderSizePixel = 0
        healthFill.ZIndex = 1
        healthFill.Parent = healthBar
            
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
        })
        gradient.Rotation = 0
        gradient.Parent = healthFill
            
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = healthBorder
        corner:Clone().Parent = healthFill
    end
        
    local esp = {
        Highlight = highlight,
        Glow = glow,
        Billboard = billboard,
        Label = label,
        Shadow = shadow,
        HealthBar = healthBar,
        HealthFill = healthFill,
        HealthBorder = healthBorder,
        Object = object,
        Type = espType,
        LastPosition = nil,
        LastDistance = nil,
        PulseTween = nil,
            
        Update = function(self)
            if not Config.Enabled or not self.Object.Parent then
                self.Highlight.Enabled = false
                self.Glow.Enabled = false
                self.Billboard.Enabled = false
                if self.HealthBar then self.HealthBar.Visible = false end
                if self.PulseTween then self.PulseTween:Pause() end
                return
            end
                
            local position = Utilities.getPosition(self.Object)
            local distance = Utilities.getDistance(position)
                
            if self.LastDistance and distance > Config.MaxDistance * ESPConfig.SpatialFilterThreshold and 
                (self.LastPosition and (position - self.LastPosition).Magnitude < ESPConfig.SpatialMoveThreshold) then
                return
            end
                
            self.LastPosition = position
            self.LastDistance = distance
                
            if distance > Config.MaxDistance then
                self.Highlight.Enabled = false
                self.Glow.Enabled = false
                self.Billboard.Enabled = false
                if self.HealthBar then self.HealthBar.Visible = false end
                if self.PulseTween then self.PulseTween:Pause() end
                return
            end
                
            self.Highlight.Enabled = true
            self.Glow.Enabled = true
            self.Billboard.Enabled = true
                
            local fadeStart = Config.MaxDistance * ESPConfig.FadeStartMultiplier
            local fade = distance > fadeStart and math.clamp((distance - fadeStart) / (Config.MaxDistance - fadeStart), 0, 1) or 0
            if fade ~= lastFadeValue then
                highlight.FillTransparency = 0.8 + fade * 0.2
                lastFadeValue = fade
            end
            
            self.Highlight.FillTransparency = 0.8 + fade * 0.2
            self.Highlight.OutlineTransparency = 0.1 + fade * 0.9
            self.Glow.FillTransparency = 0.95 + fade * 0.05
            self.Glow.OutlineTransparency = 0.6 + fade * 0.4
            self.Label.TextTransparency = fade
            self.Label.TextStrokeTransparency = 0.2 + fade * 0.8
            self.Shadow.TextTransparency = 0.5 + fade * 0.5
                
            local color
            if self.Type == "Item" then
                color = getItemColor(self.Object, Config)
                if not self.PulseTween and table.find(ESPConfig.RarityColors, table.find(Config.Colors, color) and table.find(Config.Colors, color):match("^%u%l+$") or "") then
                    self.PulseTween = TweenService:Create(self.Glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        FillTransparency = 0.9
                    })
                    self.PulseTween:Play()
                end
                if self.PulseTween then
                    self.PulseTween:Play()
                end
            else
                color = Config.Colors[self.Type]
                if self.PulseTween then self.PulseTween:Pause() end
            end
                
            self.Highlight.FillColor = color
            self.Highlight.OutlineColor = color:Lerp(Color3.fromRGB(255, 255, 255), 0.4)
            self.Glow.FillColor = color:Lerp(Color3.fromRGB(255, 255, 255), 0.6)
            self.Glow.OutlineColor = color
                
            local name = self.Object.Name
            if #name > 12 then name = name:sub(1, 10) .. "..." end
            local text = string.format("%s [%dm]", name, math.floor(distance))
            self.Label.TextColor3 = color
            self.Label.Text = text
            self.Shadow.TextColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.7)
            self.Shadow.Text = text
                
            if self.Type ~= "Item" then
                if distance <= ESPConfig.HealthBarDistance then
                    self.HealthBar.Visible = true
                    local health = Utilities.getHealth(self.Object)
                    local healthPercent = math.clamp(health.Current / health.Max, 0, 1)
                    TweenService:Create(self.HealthFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(healthPercent, 0, 1, 0)
                    }):Play()
                    self.HealthBorder.BackgroundTransparency = 0.5 + fade * 0.5
                    self.HealthFill.BackgroundTransparency = fade
                else
                    self.HealthBar.Visible = false
                end
            end
        end,
            
        Destroy = function(self)
            if self.PulseTween then self.PulseTween:Cancel() end
            safeDestroy(self.Highlight)
            safeDestroy(self.Glow)
            safeDestroy(self.Billboard)
        end
    }
        
    end
--ESP
local function hideVanillaUI()
    if not ESPManager.VanillaUIVisible then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in pairs({game.CoreGui, playerGui}) do
                    for _, child in pairs(gui:GetChildren()) do
                        if child:IsA("BillboardGui") and (child.Name:match("NameGui") or child.Name:match("HealthGui")) then
                            child.Enabled = false
                        end
                    end
                end
            end
        end
    end
    ESPManager.VanillaUIVisible = false

end

-- Function to restore vanilla name/health bars
local function restoreVanillaUI()
    if ESPManager.VanillaUIVisible then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in pairs({game.CoreGui, playerGui}) do
                    for _, child in pairs(gui:GetChildren()) do
                        if child:IsA("BillboardGui") and (child.Name:match("NameGui") or child.Name:match("HealthGui")) then
                            child.Enabled = true
                        end
                    end
                end
            end
        end
    end
    ESPManager.VanillaUIVisible = true

end

function Update()
    if not Config.Enabled then return end
    
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in pairs(runtimeItems:GetChildren()) do
            if not ESPManager.Items[item] then
                ESPManager.Items[item] = ESPObject.Create(item, "Item")
                wait(0.1)
            end
        end
    end
    
    for item, esp in pairs(ESPManager.Items) do
        if item.Parent then
            esp:Update()
            wait(0.1)
        else
            esp:Destroy()
            ESPManager.Items[item] = nil
        end
    end
    
    for _, humanoid in pairs(workspace:GetDescendants()) do
        if humanoid:IsA("Model") and humanoid:FindFirstChildOfClass("Humanoid") and humanoid ~= Player.Character then
            local hum = humanoid:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not ESPManager.Humanoids[humanoid] then
                local isPlayer = Utilities.isPlayerCharacter(humanoid)
                ESPManager.Humanoids[humanoid] = ESPObject.Create(humanoid, isPlayer and "Player" or "NPC")
            end
        end
    end
    
    for humanoid, esp in pairs(ESPManager.Humanoids) do
        if humanoid.Parent then
            local hum = humanoid:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                esp:Update()
            else
                esp:Destroy()
                ESPManager.Humanoids[humanoid] = nil
            end
        else
            esp:Destroy()
            ESPManager.Humanoids[humanoid] = nil
        end
    end
end

function Initialize()
    local lastUpdate = 0
    ESPManager.Connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate >= ESPConfig.UpdateInterval then
            Update()
            lastUpdate = currentTime
        end
    end)
    Update()
    
    -- Hide vanilla UI initially if ESP is enabled
    if Config.Enabled then
        hideVanillaUI()
    end

end

function Cleanup()
    for _, esp in pairs(ESPManager.Items) do
        esp:Destroy()
    end
    for _, esp in pairs(ESPManager.Humanoids) do
        esp:Destroy()
    end
    ESPManager.Items = {}
    ESPManager.Humanoids = {}
    if ESPManager.Connection then
        ESPManager.Connection:Disconnect()
        ESPManager.Connection = nil
    end
    
    -- Restore vanilla UI when cleaning up
    restoreVanillaUI()

end

-- Expose current enabled state for external checks
function IsEnabled()
    return Config.Enabled
end



local Toggle1 = Tabs.Main:AddToggle("MyToggle", {Title = "Aim bot", Default = false })

Toggle1:OnChanged(function(value)
    getgenv().Aimbot = value
end)

local Toggle2 = Tabs.Main:AddToggle("MyToggle", {Title = "ESP", Default = false })

Toggle2:OnChanged(function(value)
    getgenv().Esp = value
    if value then
        hideVanillaUI()
    else
        restoreVanillaUI()
        Cleanup()
    end

end)

function getDistance(position)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return 9999 end
    return (Player.Character.HumanoidRootPart.Position - position).Magnitude
end

function getPosition(object)
    if object:IsA("Model") then
        local primaryPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
        return primaryPart and primaryPart.Position or Vector3.new(0, 0, 0)
    end
    return object:IsA("BasePart") and object.Position or Vector3.new(0, 0, 0)
end

function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return true end
    end
    return false
end

function safeDestroy(instance)
    pcall(function()
        if instance and instance.Parent then
            instance:Destroy()
        end
    end)
end

-- Assign colors to items based on name or TextLabel content
function getItemColor(object, Config)
    local name = object.Name:lower()
    
    -- Check high-value items first (Gold, Silver, Rare take priority)
    if name:find("gold") then return Config.Colors.Gold end
    if name:find("silver") then return Config.Colors.Silver end
    if name:find("holy water") or name:find("crucifix") or name:find("bond") then return Config.Colors.Rare end
    
    -- Check TextLabels and name for other categories
    for _, child in pairs(object:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text ~= "" then
            local labelText = child.Text:lower()
            if labelText == "corpse" or name:find("corpse") then return Config.Colors.Corpse end
            if labelText == "fuel" or name:find("fuel") or name:find("gas") then return Config.Colors.Fuel end
            if labelText == "ammo" or name:find("ammo") or name:find("bullet") then return Config.Colors.Ammo end
            if labelText == "gun" or labelText == "weapon" or labelText == "melee" or 
               name:find("gun") or name:find("weapon") or name:find("melee") then return Config.Colors.Weapon end
            if labelText == "junk" or name:find("junk") then return Config.Colors.Junk end
            if name:find("bandage") or name:find("snake oil") then return Config.Colors.Healing end
        end
    end
    
    -- Check name if no TextLabel matches
    if name:find("corpse") then return Config.Colors.Corpse end
    if name:find("fuel") or name:find("gas") then return Config.Colors.Fuel end
    if name:find("ammo") or name:find("bullet") then return Config.Colors.Ammo end
    if name:find("gun") or name:find("weapon") or name:find("melee") then return Config.Colors.Weapon end
    if name:find("junk") then return Config.Colors.Junk end
    if name:find("bandage") or name:find("snake oil") then return Config.Colors.Healing end
    
    return Config.Colors.Default -- Fallback for uncategorized items
end

-- Get health information for a humanoid
function getHealth(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return {
            Current = humanoid.Health,
            Max = humanoid.MaxHealth
        }
    end
    return { Current = 0, Max = 100 } -- Fallback if no humanoid found
end




local MiddleClick = {
    Enabled = false, -- Controlled by UI
    RecordedTargets = {} -- Store targets and their original properties
}

-- Check if a target is a humanoid
local function isHumanoid(target)
    local model = target:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

-- Record and modify a part’s properties
local function modifyPart(part)
    if not part:IsA("BasePart") or MiddleClick.RecordedTargets[part] then return end
    
    -- Record original properties
    local original = {
        Transparency = part.Transparency,
        Color = part.Color,
        CanCollide = part.CanCollide
    }
    MiddleClick.RecordedTargets[part] = original
    
    -- Apply changes
    part.Transparency = 0.9 -- 90% transparent
    part.Color = Color3.fromRGB(255, 0, 0) -- Red
    part.CanCollide = false -- Disable collisions
    
    -- Revert after 10 seconds
    task.delay(10, function()
        if part and part.Parent then
            part.Transparency = original.Transparency
            part.Color = original.Color
            part.CanCollide = original.CanCollide
        end
        MiddleClick.RecordedTargets[part] = nil
    end)
end

-- Initialize middle-click detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not MiddleClick.Enabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then -- Middle click
        local mouse = Player:GetMouse()
        local target = mouse.Target
        if not target then return end
        
        -- Do nothing for humanoids
        if isHumanoid(target) then return end
        
        -- Modify part if it’s not a humanoid
        modifyPart(target)
    end
end)


-- Utility function to get NPC models (non-player humanoids)
local function getNPCs()
    local npcs = {}
    for _, humanoid in pairs(workspace:GetDescendants()) do
        if humanoid:IsA("Model") and humanoid:FindFirstChildOfClass("Humanoid") and humanoid ~= Player.Character then
            local isPlayer = Players:GetPlayerFromCharacter(humanoid)
            if not isPlayer and humanoid:FindFirstChildOfClass("Humanoid").Health > 0 then
                table.insert(npcs, humanoid)
            end
        end
    end
    return npcs
end

-- Find closest NPC to crosshair (excluding players)
local function findClosestNPC()
    local mouse = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local closestNPC, closestDistance = nil, math.huge
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    
    if raycastResult and raycastResult.Instance then
        local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") and model ~= Player.Character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local isPlayer = Players:GetPlayerFromCharacter(model)
            if hum and hum.Health > 0 and not isPlayer then
                closestNPC = model
                closestDistance = (Camera.CFrame.Position - raycastResult.Position).Magnitude
            end
        end
    end

    -- Fallback: Check all NPCs for closest to crosshair
    for _, npc in pairs(getNPCs()) do
        local head = npc:FindFirstChild("Head") or npc.PrimaryPart
        if head then
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                if distance < closestDistance then
                    closestNPC = npc
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestNPC
end

-- Aim at target’s head instantly
local function aimAtTarget()
    if not Aimbot.Target or not Aimbot.Target.PrimaryPart then return end
    
    local head = Aimbot.Target:FindFirstChild("Head") or Aimbot.Target.PrimaryPart
    if not head then return end
    
    local targetPos = head.Position -- Direct head targeting, no offset
    local lookVector = (targetPos - Camera.CFrame.Position).Unit
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    
    -- Instant aim (no smoothing)
    Camera.CFrame = newCFrame
end

-- Handle input for aimbot
while true do
    if getgenv().Aimbot then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not Aimbot.Enabled then return end
            if input.UserInputType == Aimbot.Settings.AimKey then
                Aimbot.Aiming = true
                Aimbot.Target = findClosestNPC()
                if Aimbot.Target then
                    Aimbot.RenderConnection = RunService.RenderStepped:Connect(aimAtTarget)
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed or not Aimbot.Enabled then return end
            if input.UserInputType == Aimbot.Settings.AimKey then
                Aimbot.Aiming = false
                Aimbot.Target = nil
                if Aimbot.RenderConnection then
                    Aimbot.RenderConnection:Disconnect()
                    Aimbot.RenderConnection = nil
                end
            end
        end)
    elseif getgenv().Esp then
        Initialize()
    end
    wait(0.1)
end