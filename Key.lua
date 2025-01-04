
-- Instances:
local KeySystem = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Getkey = Instance.new("TextButton")
local Submit = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")

-- Properties:
KeySystem.Name = "KeySystem"
KeySystem.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
KeySystem.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = KeySystem
Frame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
Frame.BackgroundTransparency = 0.200
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.365288228, 0, 0.315436244, 0)
Frame.Size = UDim2.new(0, 430, 0, 220)

Getkey.Name = "Getkey"
Getkey.Parent = Frame
Getkey.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
Getkey.BackgroundTransparency = 0.300
Getkey.BorderColor3 = Color3.fromRGB(0, 0, 0)
Getkey.BorderSizePixel = 0
Getkey.Position = UDim2.new(0, 0, 1.06818187, 0)
Getkey.Size = UDim2.new(0, 179, 0, 48)
Getkey.Font = Enum.Font.Unknown
Getkey.Text = "Get Key"
Getkey.TextColor3 = Color3.fromRGB(255, 255, 255)
Getkey.TextScaled = true
Getkey.TextSize = 14.000
Getkey.TextWrapped = true

Submit.Name = "Submit"
Submit.Parent = Frame
Submit.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
Submit.BackgroundTransparency = 0.300
Submit.BorderColor3 = Color3.fromRGB(0, 0, 0)
Submit.BorderSizePixel = 0
Submit.Position = UDim2.new(0.583720922, 0, 1.06818187, 0)
Submit.Size = UDim2.new(0, 179, 0, 48)
Submit.Font = Enum.Font.Unknown
Submit.Text = "Submit Key"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextScaled = true
Submit.TextSize = 14.000
Submit.TextWrapped = true

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.146511629, 0, -0.277272731, 0)
TextLabel.Size = UDim2.new(0, 304, 0, 61)
TextLabel.Font = Enum.Font.Unknown
TextLabel.Text = "Sigma Hub - Key System"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.134883717, 0, 0.295454532, 0)
TextBox.Size = UDim2.new(0, 313, 0, 89)
TextBox.Font = Enum.Font.SourceSansBold
TextBox.Text = "dda"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
TextBox.TextSize = 14.000
TextBox.TextWrapped = true

-- Retrieve key from the URL
local success, key = pcall(function()
    return game:HttpGet('https://pastebin.com/raw/fMtF0rta')
end)

if success then
    print("OK")
else
    warn("Failed to load key")
end

-- Handle Getkey button click
Getkey.MouseButton1Click:Connect(function()
	-- The "SetClipboard" function is not a default Roblox function. We'll create a custom function to mimic it.
	local function SetClipboard(text)
		-- Copy to clipboard logic (not native to Roblox, but can mimic with external solutions)
		print("Clipboard Set:", text)
	end
	
	-- Set the clipboard to the key link
	SetClipboard("https://link-target.net/1274722/key")
end)

-- Handle Submit button click
Submit.MouseButton1Click:Connect(function()
    if TextBox.Text == key then
        print("Whitelisted")  
        loadstring(game:HttpGet('https://raw.githubusercontent.com/huycuti22/autochestBF/refs/heads/main/AutoChest.lua'))()
        print("Loading")
        game.Debris:AddItem(KeySystem, 0.2)
    else
        print("Not whitelisted")
    end
	-- Validate the key input
end)





