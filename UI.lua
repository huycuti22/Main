return function(Config, ESP, MiddleClick, Aimbot)
    print("Ok")

    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "Dead Rails | Aurora Hub",
        SubTitle = "by ghuy4800",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl -- Used when there's no MinimizeKeybind
    })

    -- Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Aimbot Toggle
    local Toggle1 = Tabs.Main:AddToggle("AimbotToggle", { Title = "Aim bot", Default = false })
    Toggle1:OnChanged(function(value)
        if Aimbot and Aimbot.Enabled ~= nil then
            Aimbot.Enabled = value
        else
            warn("Aimbot module not loaded or Enabled property missing")
        end
    end)

    -- ESP Toggle
    local Toggle2 = Tabs.Main:AddToggle("ESPToggle", { Title = "ESP", Default = false })
    Toggle2:OnChanged(function(value)
        if value then
            ESP.Initialize()
            ESP.Update()
        else
            ESP.Cleanup()
        end
    end)

    -- Max Distance Slider
    local Slider = Tabs.Main:AddSlider("MaxDistanceSlider", {
        Title = "Max Distance",
        Description = "This is a slider",
        Default = 500,
        Min = 100,
        Max = 2000,
        Rounding = 1
    })

    Slider:OnChanged(function(Value)
        Config.MaxDistance = Value
    end)

    -- Middle Click Utility Toggle
    local Toggle3 = Tabs.Main:AddToggle("MiddleClickToggle", { Title = "Middle Click Utility", Default = false })
    Toggle3:OnChanged(function(value)
        if MiddleClick then
            MiddleClick.Enabled = value
        else
            warn("MiddleClick module not loaded")
        end
    end)

    return Window
end
