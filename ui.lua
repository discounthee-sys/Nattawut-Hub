local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ WINDOW SETUP ]]
local Window = Fluent:CreateWindow({
    Title = "Immortal Logic Hub",
    SubTitle = "The Path to Immortality | By Phi Lam",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Darker", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ TABS ]]
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
    Content = "Built for precision, stability, and absolute performance. System v" .. _G.NattawutHub.Version
})

Tabs.Menu:AddButton({
    Title = "Join Discord Community",
    Callback = function()
        setclipboard("https://discord.gg/gdPGTjtn")
        Fluent:Notify({ Title = "Success", Content = "Discord link copied!", Duration = 3 })
    end
})

---------------------------------------------------------
-- 🎮 [GAMEPLAY]
---------------------------------------------------------
Tabs.Gameplay:AddSection("Match Management")
-- เชื่อมต่อระบบ Auto ต่างๆ เข้ากับ Config กลาง
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start Match", Default = false, Callback = function(v) _G.NattawutHub.Config.AutoStart = v end })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay Stage", Default = false, Callback = function(v) _G.NattawutHub.Config.AutoReplay = v end })

Tabs.Gameplay:AddSection("Combat System")
Tabs.Gameplay:AddToggle("AutoSkill", { 
    Title = "Auto Skill System", 
    Default = false, 
    Callback = function(v) _G.NattawutHub.Config.AutoSkill = v end 
})

---------------------------------------------------------
-- ⏺️ [MACRO ENGINE]
---------------------------------------------------------
Tabs.Macro:AddSection("Live Monitoring")
-- เก็บ Label ไว้ในตารางกลางเพื่อให้ logic.lua มาแก้ข้อความได้
_G.NattawutHub.ActionLabel = Tabs.Macro:AddParagraph({ Title = "Action Counter", Content = "0 Actions Logged" })
_G.NattawutHub.TimeLabel = Tabs.Macro:AddParagraph({ Title = "Session Timer", Content = "00:00 Seconds" })

Tabs.Macro:AddSection("Data Management")
_G.NattawutHub.MacroInput = Tabs.Macro:AddInput("MacroNameInput", { Title = "Configuration Name", Placeholder = "Enter filename..." })
_G.NattawutHub.MacroSelector = Tabs.Macro:AddDropdown("MacroSelect", { Title = "Select Configuration", Values = {} })

Tabs.Macro:AddSection("Execution Control")
Tabs.Macro:AddToggle("RecordToggle", { 
    Title = "Capture Mode", 
    Default = false, 
    Callback = function(v) _G.NattawutHub.Config.IsRecording = v end 
})
Tabs.Macro:AddToggle("PlayToggle", { 
    Title = "Playback System", 
    Default = false, 
    Callback = function(v) _G.NattawutHub.Config.IsPlaying = v end 
})

---------------------------------------------------------
-- ⚙️ [SETTINGS]
---------------------------------------------------------
Tabs.Settings:AddToggle("BlackScreen", {
    Title = "Black Screen Mode",
    Default = false,
    Callback = function(v)
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end
})

Tabs.Settings:AddButton({ Title = "Unload Script", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
return true
