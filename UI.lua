return function(Config, ESP, MiddleClick, Aimbot)
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
    local Toggle1 = Tabs.Main:AddToggle("MyToggle", {Title = "Aim bot", Default = false })
    local aimbotEnabled = (Aimbot and Aimbot.Enabled ~= nil) and Aimbot.Enabled or false
    Toggle1:OnChanged(function(value)
        getgenv().Aimbot = value
         if Aimbot and Aimbot.Enabled ~= nil then
            Aimbot.Enabled = value
        else
            warn("Aimbot module not loaded or Enabled property missing")
        end
    end)


       
    end)

    local Toggle2 = Tabs.Main:AddToggle("MyToggle", {Title = "ESP", Default = false })

    Toggle2:OnChanged(function(value)
        getgenv().Esp = value
        if value then
            ESP.Initialize()
            ESP.Update()
        else
            ESP.Cleanup()
        end

    end)
    -- Toggle ESP Enable
    
    
    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Max Distance",
        Description = "This is a slider",
        Default = 2,
        Min = 100,
        Max = 2000,
        Rounding = 1,
        Callback = function(Value)
           Config.MaxDistance = value
        end
    })

    Slider:OnChanged(function(Value)
       Config.MaxDistance = value
    end)

    local Toggle3 = Tabs.Main:AddToggle("MyToggle", {Title = "Middle Click Utility", Default = false })

    Toggle3:OnChanged(function(value)
        MiddleClick.Enabled = value

    end)

    
    -- Aimbot Toggle (with safe access and debug)
    
    
    return UI
end
