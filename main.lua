local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [[ 🛠️ DATA CORE ]]
local MacroSystem = {
    IsRecording = false,
    Data = {},
    StartTime = 0,
    Folder = "ImmortalLogic_Macros",
    ConfigFile = "ImmortalLogic_Config.json"
}

if not isfolder(MacroSystem.Folder) then makefolder(MacroSystem.Folder) end

local function UpdateDropdown()
    local files = listfiles(MacroSystem.Folder)
    local names = {}
    for _, file in ipairs(files) do
        table.insert(names, file:gsub(MacroSystem.Folder .. "/", ""):gsub(MacroSystem.Folder .. "\\", ""):gsub(".json", ""))
    end
    if _G.MacroDropdown then _G.MacroDropdown:SetValues(names) end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Immortal Logic Hub",
    SubTitle = "The Path to Immortality",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460),
    Acrylic = false, Theme = "Darker", MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Menu = Window:AddTab({ Title = "Menu" }),
    AutoJoin = Window:AddTab({ Title = "Auto Join" }),
    Gameplay = Window:AddTab({ Title = "Gameplay" }),
    Macro = Window:AddTab({ Title = "Macro Engine" }),
    Webhook = Window:AddTab({ Title = "Webhook" }),
    Settings = Window:AddTab({ Title = "Settings" })
}

-- 🏠 [MENU] - คงเดิม 100%
Tabs.Menu:AddSection("Project Origin")
Tabs.Menu:AddParagraph({ Title = "The Eternal Vision", Content = "Built for precision, stability, and absolute performance." })
Tabs.Menu:AddButton({ Title = "Join Discord Community", Callback = function() setclipboard("https://discord.gg/gdPGTjtn") end })

-- 🎮 [GAMEPLAY] - ดึงกลับมาครบทุกปุ่ม
Tabs.Gameplay:AddSection("Match Management")
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start Match", Default = false })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay Stage", Default = false })
Tabs.Gameplay:AddToggle("AutoNext", { Title = "Auto Next Stage", Default = false })
Tabs.Gameplay:AddToggle("AutoLeave", { Title = "Auto Return to Lobby", Default = false })

Tabs.Gameplay:AddSection("Combat System")
Tabs.Gameplay:AddDropdown("SkillMode", { Title = "Ability Activation Mode", Values = {"Continuous Execution", "Boss Phase Only"}, Default = "Continuous Execution" })
Tabs.Gameplay:AddToggle("AutoSkill", { Title = "Auto Skill System", Default = false })

-- ⏺️ [MACRO ENGINE] - เชื่อมระบบไฟล์ครบ
Tabs.Macro:AddSection("Live Monitoring")
local ActionLabel = Tabs.Macro:AddParagraph({ Title = "Action Counter", Content = "0 Actions Logged" })
local TimeLabel = Tabs.Macro:AddParagraph({ Title = "Session Timer", Content = "00:00 Seconds" })

Tabs.Macro:AddSection("Data Management")
Tabs.Macro:AddInput("MacroNameInput", { Title = "Configuration Name", Placeholder = "Enter filename..." })
_G.MacroDropdown = Tabs.Macro:AddDropdown("MacroSelect", { Title = "Select Configuration", Values = {} })
Tabs.Macro:AddButton({ Title = "Initialize New File", Callback = function() 
    local name = Fluent.Options.MacroNameInput.Value
    if name ~= "" then writefile(MacroSystem.Folder.."/"..name..".json", "[]") UpdateDropdown() end
end })

Tabs.Macro:AddSection("Execution Control")
-- ระบบ Record/Play (ดึง Logic มาโครที่ทำยากๆ ใส่ให้ครบ)
Tabs.Macro:AddToggle("RecordToggle", { Title = "Capture Mode", Callback = function(v)
    MacroSystem.IsRecording = v
    if v then table.clear(MacroSystem.Data) MacroSystem.StartTime = tick()
    else writefile(MacroSystem.Folder.."/"..Fluent.Options.MacroNameInput.Value..".json", HttpService:JSONEncode(MacroSystem.Data)) UpdateDropdown() end
end })

Tabs.Macro:AddToggle("PlayToggle", { Title = "Playback System", Callback = function(v)
    if v then
        local name = Fluent.Options.MacroSelect.Value
        if not name or not isfile(MacroSystem.Folder.."/"..name..".json") then return end
        local data = HttpService:JSONDecode(readfile(MacroSystem.Folder.."/"..name..".json"))
        for _, act in ipairs(data) do
            if not Fluent.Options.PlayToggle.Value then break end
            task.wait(act.Delay)
            pcall(function() ReplicatedStorage.sync[act.Remote]:FireServer(buffer.fromstring(act.BufferStr), act.Extra) end)
        end
        Fluent.Options.PlayToggle:SetValue(false)
    end
end })

Tabs.Macro:AddSection("Cleanup")
Tabs.Macro:AddButton({ Title = "Purge Selected File", Callback = function() 
    local name = Fluent.Options.MacroSelect.Value
    if name then delfile(MacroSystem.Folder.."/"..name..".json") UpdateDropdown() end
end })

-- ⚙️ [SETTINGS]
Tabs.Settings:AddSection("Performance Optimization")
Tabs.Settings:AddToggle("BlackScreen", { Title = "Black Screen Mode", Callback = function(v) RunService:Set3dRenderingEnabled(not v) end })
Tabs.Settings:AddToggle("AutoRun", { Title = "Force Auto Run", Default = false })
Tabs.Settings:AddButton({ Title = "Unload Script", Callback = function() Window:Destroy() end })

-- [[ HOOK ]]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and MacroSystem.IsRecording and (self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE") then
        table.insert(MacroSystem.Data, { Remote = self.Name, BufferStr = tostring(args[1]), Extra = args[2] or {}, Delay = (tick() - MacroSystem.StartTime) })
        MacroSystem.StartTime = tick()
        pcall(function() ActionLabel:SetTitle(#MacroSystem.Data .. " Actions Logged") end)
    end
    return OldNamecall(self, ...)
end)

UpdateDropdown()
Window:SelectTab(1)
