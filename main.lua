local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- [[ 1. CLEANUP PREVIOUS GUI ]]
pcall(function()
    if CoreGui:FindFirstChild("ImmortalToggle") then
        CoreGui:FindFirstChild("ImmortalToggle"):Destroy()
    end
end)

-- [[ 2. FLOATING TOGGLE BUTTON ]]
local ToggleGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ToggleGui.Name = "ImmortalToggle"
ToggleGui.Parent = CoreGui
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Image = "rbxassetid://116966281442429"
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

-- [[ 3. SYSTEM DATA (CENTRAL CORE) ]]
local Sys = {
    Recording = false,
    Playing = false,
    MacroData = {},
    StartTime = 0,
    MatchTime = 0,
    AutoStart = false,
    AutoReplay = false,
    AutoSkill = false,
    SkillAfterTime = false,
    TargetTime = 60,
    WaitForMoney = false,
    LastSkillTick = 0
}

-- [[ 4. HELPER FUNCTIONS ]]
local function GetCurrentMoney()
    local money = 0
    pcall(function() money = game.Players.LocalPlayer.leaderstats.Gold.Value end)
    return money
end

local function SafeFire(folderName, remoteName, dataStr)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    local remote = folder and folder:FindFirstChild(remoteName)
    if remote then
        pcall(function()
            remote:FireServer(buffer.fromstring(dataStr), {})
        end)
    end
end

-- [[ 5. PROTECTED HOOK ENGINE ]]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and Sys.Recording then
        if self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE" then
            -- Protection: Check if args[1] is valid for buffer conversion
            local finalData = ""
            if typeof(args[1]) == "buffer" then
                finalData = buffer.tostring(args[1])
            elseif typeof(args[1]) == "string" then
                finalData = args[1]
            end

            table.insert(Sys.MacroData, {
                Remote = self.Name,
                Data = finalData,
                Timestamp = tick() - Sys.StartTime,
                MoneyRequired = GetCurrentMoney()
            })
        end
    end
    return OldNamecall(self, ...)
end)

-- [[ 6. UI INITIALIZATION ]]
local Window = Fluent:CreateWindow({
    Title = "IMMORTAL LOGIC HUB",
    SubTitle = "PREMIUM EDITION | v10",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local Tabs = {
    Menu = Window:AddTab({ Title = "Menu" }),
    AutoJoin = Window:AddTab({ Title = "Auto Join" }),
    Gameplay = Window:AddTab({ Title = "Gameplay" }),
    Macro = Window:AddTab({ Title = "Macro" }),
    Settings = Window:AddTab({ Title = "Settings" })
}

-- [[ TABS CONTENT ]]
Tabs.Menu:AddParagraph({
    Title = "Developer Note",
    Content = "We created this for fun. If there is high demand, we will continue long-term development."
})

Tabs.Menu:AddButton({
    Title = "Support / Discord",
    Callback = function() setclipboard("https://discord.gg/hYQZs58Vg") end
})

Tabs.Gameplay:AddSection("Match Management")
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start", Default = false, Callback = function(v) Sys.AutoStart = v end })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay", Default = false, Callback = function(v) Sys.AutoReplay = v end })

Tabs.Gameplay:AddSection("Skill System")
Tabs.Gameplay:AddToggle("AutoSkill", { Title = "Continuous Spam", Default = false, Callback = function(v) Sys.AutoSkill = v end })
Tabs.Gameplay:AddToggle("TimedSkill", { Title = "Spam After Time", Default = false, Callback = function(v) Sys.SkillAfterTime = v end })
Tabs.Gameplay:AddInput("SkillDelay", {
    Title = "Set Delay (Seconds)",
    Default = "60",
    Callback = function(v) Sys.TargetTime = tonumber(v) or 60 end
})

Tabs.Macro:AddSection("Recording")
Tabs.Macro:AddToggle("RecToggle", { 
    Title = "Record Actions", 
    Default = false, 
    Callback = function(v) 
        Sys.Recording = v 
        if v then 
            table.clear(Sys.MacroData)
            Sys.StartTime = tick() 
            Fluent:Notify({ Title = "Macro", Content = "Recording Started", Duration = 2 })
        end
    end 
})

Tabs.Macro:AddSection("Playback (High Precision)")
Tabs.Macro:AddToggle("PlayToggle", { 
    Title = "Play Macro", 
    Default = false, 
    Callback = function(v) 
        Sys.Playing = v 
        if v and #Sys.MacroData > 0 then
            task.spawn(function()
                local playbackStart = tick()
                for _, act in ipairs(Sys.MacroData) do
                    if not Sys.Playing then break end
                    
                    -- Money Based Logic
                    if Sys.WaitForMoney then
                        while GetCurrentMoney() < act.MoneyRequired and Sys.Playing do
                            task.wait(0.2)
                        end
                    end

                    -- High Precision Timing
                    repeat task.wait() until (tick() - playbackStart) >= act.Timestamp or not Sys.Playing
                    
                    if not Sys.Playing then break end
                    SafeFire("sync", act.Remote, act.Data)
                end
                Sys.Playing = false
                Fluent:Notify({ Title = "Macro", Content = "Playback Finished", Duration = 3 })
            end)
        end
    end 
})

Tabs.Macro:AddDropdown("PlayMode", {
    Title = "Priority Mode",
    Values = {"Time Delay", "Money Based"},
    Default = "Time Delay",
    Callback = function(v) Sys.WaitForMoney = (v == "Money Based") end
})

Tabs.Macro:AddButton({ Title = "Clear Macro Data", Callback = function() table.clear(Sys.MacroData) end })

-- [[ 7. MASTER LOOP (THROTTLED) ]]
task.spawn(function()
    while task.wait(1) do
        local inMatch = workspace:FindFirstChild("placedTowers")
        
        if inMatch then
            Sys.MatchTime = Sys.MatchTime + 1
        else
            Sys.MatchTime = 0
        end

        -- Auto Start / Replay
        if Sys.AutoStart then SafeFire("voting", "voting_RELIABLE", "\000") end
        if Sys.AutoReplay then SafeFire("gamemodes", "gamemodes_RELIABLE", "\002\002") end

        -- Throttled Auto Skill
        if (Sys.AutoSkill or (Sys.SkillAfterTime and Sys.MatchTime >= Sys.TargetTime)) and inMatch then
            if tick() - Sys.LastSkillTick > 0.5 then -- Limit to 0.5s intervals
                Sys.LastSkillTick = tick()
                for _, t in ipairs(inMatch:GetChildren()) do
                    SafeFire("sync", "sync_RELIABLE", "\000+\000" .. t.Name .. "\001\000")
                    task.wait(0.05) -- Tiny gap between towers to prevent lag
                end
            end
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({ Title = "IMMORTAL LOGIC", Content = "v10 Professional Loaded", Duration = 5 })
