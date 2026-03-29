local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ WINDOW SETUP ]]
local Window = Fluent:CreateWindow({
    Title = "Immortal Logic Hub",
    SubTitle = "The Path to Immortality",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Darker", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ TABS DECLARATION ]]
local Tabs = {
    Menu = Window:AddTab({ Title = "Menu" }),
    AutoJoin = Window:AddTab({ Title = "Auto Join" }),
    Gameplay = Window:AddTab({ Title = "Gameplay" }),
    Macro = Window:AddTab({ Title = "Macro Engine" }),
    Webhook = Window:AddTab({ Title = "Webhook" }),
    Settings = Window:AddTab({ Title = "Settings" })
}

---------------------------------------------------------
-- 🏠 [MENU]
---------------------------------------------------------
Tabs.Menu:AddSection("Project Origin")
Tabs.Menu:AddParagraph({
    Title = "The Eternal Vision",
    Content = "I noticed a lack of high-quality tools in the community. This led to the creation of Immortal Logic—built for precision, stability, and absolute performance."
})

Tabs.Menu:AddSection("Community Support")
Tabs.Menu:AddButton({
    Title = "Join Discord Community",
    Description = "Access updates and exclusive features",
    Callback = function()
        setclipboard("https://discord.gg/gdPGTjtn")
        Fluent:Notify({ Title = "Success", Content = "Discord link copied to clipboard!", Duration = 3 })
    end
})

---------------------------------------------------------
-- 🚪 [AUTO JOIN]
---------------------------------------------------------
Tabs.AutoJoin:AddSection("Coming Soon")
Tabs.AutoJoin:AddParagraph({
    Title = "Under Development",
    Content = "The Advanced Server Joiner and Auto-Reconnection modules are currently being optimized for the next update."
})

---------------------------------------------------------
-- 🎮 [GAMEPLAY]
---------------------------------------------------------
Tabs.Gameplay:AddSection("Match Management")
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start Match", Default = false, Callback = function() end })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay Stage", Default = false, Callback = function() end })
Tabs.Gameplay:AddToggle("AutoNext", { Title = "Auto Next Stage", Default = false, Callback = function() end })
Tabs.Gameplay:AddToggle("AutoLeave", { Title = "Auto Return to Lobby", Default = false, Callback = function() end })

Tabs.Gameplay:AddSection("Combat System")
Tabs.Gameplay:AddDropdown("SkillMode", {
    Title = "Ability Activation Mode",
    Values = {"Continuous Execution", "Boss Phase Only"},
    Default = "Continuous Execution",
    Callback = function() end
})
Tabs.Gameplay:AddToggle("AutoSkill", { Title = "Auto Skill System", Default = false, Callback = function() end })

Tabs.Gameplay:AddSection("Coming Soon")
Tabs.Gameplay:AddParagraph({
    Title = "Planned Features",
    Content = "Additional automation modules and advanced combat logic are currently under development."
})

---------------------------------------------------------
-- ⏺️ [MACRO ENGINE]
---------------------------------------------------------
Tabs.Macro:AddSection("Live Monitoring")
Tabs.Macro:AddParagraph({ Title = "Action Counter", Content = "0 Actions Logged" })
Tabs.Macro:AddParagraph({ Title = "Session Timer", Content = "00:00 Seconds" })

Tabs.Macro:AddSection("Data Management")
Tabs.Macro:AddInput("MacroNameInput", { Title = "Configuration Name", Placeholder = "Enter filename...", Callback = function() end })
Tabs.Macro:AddDropdown("MacroSelect", { Title = "Select Configuration", Values = {}, Callback = function() end })
Tabs.Macro:AddButton({ Title = "Initialize New File", Callback = function() end })

Tabs.Macro:AddSection("Execution Control")
Tabs.Macro:AddToggle("RecordToggle", { Title = "Capture Mode", Description = "Record Macro Actions", Default = false, Callback = function() end })
Tabs.Macro:AddToggle("PlayToggle", { Title = "Playback System", Description = "Play Recorded Macro", Default = false, Callback = function() end })

Tabs.Macro:AddSection("Cleanup")
Tabs.Macro:AddButton({ Title = "Purge Selected File", Callback = function() end })

---------------------------------------------------------
-- 🔔 [WEBHOOK]
---------------------------------------------------------
Tabs.Webhook:AddSection("Notifications")
Tabs.Webhook:AddInput("WebhookURL", { Title = "Discord Webhook URL", Placeholder = "Enter URL here...", Callback = function() end })

---------------------------------------------------------
-- ⚙️ [SETTINGS]
---------------------------------------------------------
Tabs.Settings:AddSection("Performance Optimization")
Tabs.Settings:AddToggle("BlackScreen", {
    Title = "Black Screen Mode",
    Description = "Reduce CPU and GPU usage",
    Default = false,
    Callback = function(v)
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end
})
Tabs.Settings:AddToggle("AutoRun", { Title = "Force Auto Run", Default = false, Callback = function() end })

Tabs.Settings:AddSection("Configuration")
Tabs.Settings:AddButton({ Title = "Save Current Config", Callback = function() end })
Tabs.Settings:AddButton({ Title = "Unload Script", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
