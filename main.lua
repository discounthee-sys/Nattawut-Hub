local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [[ 🛠️ BACKEND LOGIC - ห้ามลบส่วนนี้เพื่อให้ระบบทำงานได้ ]] --
local MacroSystem = {
    IsRecording = false,
    IsPlaying = false,
    Data = {},
    StartTime = 0,
    Folder = "ImmortalLogic_Macros",
    ConfigFile = "ImmortalLogic_Config.json"
}

if not isfolder(MacroSystem.Folder) then makefolder(MacroSystem.Folder) end

-- ฟังก์ชันดึงรายชื่อไฟล์เข้า Dropdown
local function UpdateDropdown()
    local files = listfiles(MacroSystem.Folder)
    local names = {}
    for _, file in ipairs(files) do
        table.insert(names, file:gsub(MacroSystem.Folder .. "/", ""):gsub(MacroSystem.Folder .. "\\", ""):gsub(".json", ""))
    end
    if _G.MacroDropdown then _G.MacroDropdown:SetValues(names) end
end

-- ฟังก์ชัน Save ค่าใน UI ทั้งหมด
local function SaveAllConfigs()
    local data = {}
    for i, v in pairs(_G.FluentOptions) do
        if v.Type == "Toggle" or v.Type == "Slider" or v.Type == "Dropdown" or v.Type == "Input" then
            data[i] = v.Value
        end
    end
    writefile(MacroSystem.ConfigFile, HttpService:JSONEncode(data))
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
_G.FluentOptions = Fluent.Options -- เก็บไว้ใช้ Auto Save

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
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start Match", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay Stage", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoNext", { Title = "Auto Next Stage", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoLeave", { Title = "Auto Return to Lobby", Default = false, Callback = function() SaveAllConfigs() end })

Tabs.Gameplay:AddSection("Combat System")
Tabs.Gameplay:AddDropdown("SkillMode", {
    Title = "Ability Activation Mode",
    Values = {"Continuous Execution", "Boss Phase Only"},
    Default = "Continuous Execution",
    Callback = function() SaveAllConfigs() end
})
Tabs.Gameplay:AddToggle("AutoSkill", { Title = "Auto Skill System", Default = false, Callback = function() SaveAllConfigs() end })

-- [[ 🤖 AUTO SKILL BRAIN ]]
task.spawn(function()
    while true do
        if Fluent.Options.AutoSkill and Fluent.Options.AutoSkill.Value then
            pcall(function()
                local towerFolder = workspace:FindFirstChild("placedTowers")
                if towerFolder then
                    for _, tower in ipairs(towerFolder:GetChildren()) do
                        ReplicatedStorage.sync.sync_RELIABLE:FireServer(buffer.fromstring("\000+\000" .. tower.Name .. "\001\000"), {})
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

Tabs.Gameplay:AddSection("Coming Soon")
Tabs.Gameplay:AddParagraph({
    Title = "Planned Features",
    Content = "Additional automation modules and advanced combat logic are currently under development."
})

---------------------------------------------------------
-- ⏺️ [MACRO ENGINE]
---------------------------------------------------------
Tabs.Macro:AddSection("Live Monitoring")
local ActionLabel = Tabs.Macro:AddParagraph({ Title = "Action Counter", Content = "0 Actions Logged" })
local TimeLabel = Tabs.Macro:AddParagraph({ Title = "Session Timer", Content = "00:00 Seconds" })

-- [[ ⏺️ MACRO HOOK ]]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and MacroSystem.IsRecording and (self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE") then
        local now = tick()
        local bufStr = typeof(args[1]) == "buffer" and buffer.tostring(args[1]) or tostring(args[1])
        table.insert(MacroSystem.Data, {
            Remote = self.Name, BufferStr = bufStr,
            HasID = string.find(bufStr, "tower%-") ~= nil,
            Extra = args[2] or {}, Delay = (#MacroSystem.Data == 0) and 0 or (now - MacroSystem.StartTime)
        })
        MacroSystem.StartTime = now
        ActionLabel:SetTitle(#MacroSystem.Data .. " Actions Logged")
    end
    return OldNamecall(self, ...)
end)

Tabs.Macro:AddSection("Data Management")
Tabs.Macro:AddInput("MacroNameInput", { Title = "Configuration Name", Placeholder = "Enter filename...", Callback = function() SaveAllConfigs() end })
_G.MacroDropdown = Tabs.Macro:AddDropdown("MacroSelect", { Title = "Select Configuration", Values = {}, Callback = function() SaveAllConfigs() end })

Tabs.Macro:AddButton({ 
    Title = "Initialize New File", 
    Callback = function() 
        local name = Fluent.Options.MacroNameInput.Value
        if name ~= "" then
            writefile(MacroSystem.Folder .. "/" .. name .. ".json", HttpService:JSONEncode({}))
            UpdateDropdown()
            Fluent:Notify({Title = "Macro", Content = "สร้างไฟล์ใหม่สำเร็จ: " .. name})
        end
    end 
})

Tabs.Macro:AddSection("Execution Control")
Tabs.Macro:AddToggle("RecordToggle", { 
    Title = "Capture Mode", 
    Description = "Record Macro Actions", 
    Default = false, 
    Callback = function(v) 
        MacroSystem.IsRecording = v
        if v then
            table.clear(MacroSystem.Data)
            MacroSystem.StartTime = tick()
            task.spawn(function()
                while MacroSystem.IsRecording do
                    TimeLabel:SetTitle(string.format("%.2f Seconds", tick() - MacroSystem.StartTime))
                    task.wait(0.1)
                end
            end)
        else
            local name = Fluent.Options.MacroNameInput.Value
            if name ~= "" then
                writefile(MacroSystem.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(MacroSystem.Data))
                UpdateDropdown()
            end
        end
        SaveAllConfigs()
    end 
})

Tabs.Macro:AddToggle("PlayToggle", { 
    Title = "Playback System", 
    Description = "Play Recorded Macro", 
    Default = false, 
    Callback = function(v) 
        if v then
            local name = Fluent.Options.MacroSelect.Value
            if not name or not isfile(MacroSystem.Folder .. "/" .. name .. ".json") then 
                Fluent.Options.PlayToggle:SetValue(false) return 
            end
            local data = HttpService:JSONDecode(readfile(MacroSystem.Folder .. "/" .. name .. ".json"))
            MacroSystem.IsPlaying = true
            for _, act in ipairs(data) do
                if not Fluent.Options.PlayToggle.Value then break end
                task.wait(act.Delay)
                pcall(function()
                    local finalStr = act.BufferStr
                    local towers = workspace.placedTowers:GetChildren()
                    local realID = #towers > 0 and towers[#towers].Name or nil
                    if act.HasID and realID then finalStr = string.gsub(act.BufferStr, "tower%-[%w%-]+", realID) end
                    ReplicatedStorage.sync[act.Remote]:FireServer(buffer.fromstring(finalStr), act.Extra)
                end)
            end
            Fluent.Options.PlayToggle:SetValue(false)
        end
        SaveAllConfigs()
    end 
})

Tabs.Macro:AddSection("Cleanup")
Tabs.Macro:AddButton({ 
    Title = "Purge Selected File", 
    Callback = function() 
        local name = Fluent.Options.MacroSelect.Value
        if name then delfile(MacroSystem.Folder .. "/" .. name .. ".json") UpdateDropdown() end
    end 
})

---------------------------------------------------------
-- 🔔 [WEBHOOK]
---------------------------------------------------------
Tabs.Webhook:AddSection("Notifications")
Tabs.Webhook:AddInput("WebhookURL", { Title = "Discord Webhook URL", Placeholder = "Enter URL here...", Callback = function() SaveAllConfigs() end })

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
        SaveAllConfigs()
    end
})
Tabs.Settings:AddToggle("AutoRun", { Title = "Force Auto Run", Default = false, Callback = function() SaveAllConfigs() end })

Tabs.Settings:AddSection("Configuration")
Tabs.Settings:AddButton({ 
    Title = "Save Current Config", 
    Callback = function() 
        SaveAllConfigs()
        Fluent:Notify({Title = "Settings", Content = "Saved Successfully!"})
    end 
})
Tabs.Settings:AddButton({ Title = "Unload Script", Callback = function() Window:Destroy() end })

-- [[ 🚀 FINAL INITIALIZE ]]
UpdateDropdown()
if isfile(MacroSystem.ConfigFile) then
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(MacroSystem.ConfigFile)) end)
    if success then
        for i, v in pairs(data) do if Fluent.Options[i] then Fluent.Options[i]:SetValue(v) end end
    end
end
Window:SelectTab(1)
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if not autoCollect then break end
                
                if v.Name:find("Dio") or v.Name:find("Present") or v.Name:find("Gift") then
                    collectItem(v)
                    -- สแกนลูกข้างในตามที่พี่ต้องการ
                    for _, child in pairs(v:GetDescendants()) do
                        collectItem(child)
                    end
                end
            end
        end
        task.wait(1) -- พัก 1 วินาทีกันค้าง
    end
end)

-- [[ MACRO & OTHER FUNCTIONS ]]
local function setNoclip(state)
    task.spawn(function()
        while state and playing do
            if char then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function saveMacro()
    local success, encoded = pcall(function()
        local dataToSave = {}
        for _, cframe in ipairs(pathData) do table.insert(dataToSave, {cframe:GetComponents()}) end
        return HttpService:JSONEncode(dataToSave)
    end)
    if success then writefile(fileName, encoded) Rayfield:Notify({Title = "Success", Content = "เซฟแล้ว!", Duration = 3}) end
end

local function loadMacro()
    if isfile(fileName) then
        local success, decoded = pcall(function()
            local data = HttpService:JSONDecode(readfile(fileName))
            pathData = {}
            for _, components in ipairs(data) do table.insert(pathData, CFrame.new(unpack(components))) end
        end)
        if success then Rayfield:Notify({Title = "Loaded", Content = "โหลดแล้ว!", Duration = 3}) end
    end
end

-- [[ UI TABS ]]
local MainTab = Window:CreateTab("Main Features", 4483345998)

MainTab:CreateSection("Auto Farming")

MainTab:CreateToggle({
   Name = "💰 เปิดระบบเก็บของ (Logic เดิมของพี่)",
   CurrentValue = false,
   Flag = "AutoCollectFlag",
   Callback = function(Value)
      autoCollect = Value
   end,
})

MainTab:CreateSection("Macro Recorder")

MainTab:CreateButton({
   Name = "🔴 Start Record (อัดใหม่)",
   Callback = function()
      recording = true
      pathData = {}
      Rayfield:Notify({Title = "Recording", Content = "เริ่มอัด...", Duration = 3})
      task.spawn(function()
          while recording do
              table.insert(pathData, hrp.CFrame)
              task.wait(0.1)
          end
      end)
   end,
})

MainTab:CreateButton({ Name = "⏹️ Stop Record", Callback = function() recording = false end })
MainTab:CreateButton({ Name = "💾 Save Macro", Callback = saveMacro })
MainTab:CreateButton({ Name = "📂 Load Macro", Callback = loadMacro })
MainTab:CreateButton({ 
    Name = "🗑️ Delete All", 
    Callback = function() 
        pathData = {} 
        if isfile(fileName) then delfile(fileName) end 
    end 
})

MainTab:CreateSection("Play")

MainTab:CreateButton({
   Name = "▶️ Start Macro (เดินวน + ทะลุบล็อก)",
   Callback = function()
      if #pathData == 0 then return end
      playing = true
      setNoclip(true)
      task.spawn(function()
          while playing do
              for _, frame in ipairs(pathData) do
                  if not playing then break end
                  hrp.CFrame = frame
                  task.wait(0.1)
              end
          end
      end)
   end,
})

MainTab:CreateButton({ Name = "🚫 Stop Play", Callback = function() playing = false setNoclip(false) end })    Txt.Text = "SYSTEM > " .. msg:upper()
    Txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    Txt.Font = Enum.Font.GothamBold
    Txt.TextSize = 10

    Notif:TweenPosition(UDim2.new(1, -240, 0, 20), "Out", "Quad", 0.15, true)
    task.wait(1.2)
    local tweenOut = TweenService:Create(Notif, TweenInfo.new(0.15), {Position = UDim2.new(1, 20, 0, 20)})
    tweenOut:Play()
    tweenOut.Completed:Connect(function() Notif:Destroy() isNotifying = false end)
end

-- [[ 2. ฟังก์ชันการลาก (Draggable) ]] --
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- [[ 3. Main Frame (Ray Style) ]] --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 560, 0, 390)
Main.Position = UDim2.new(0.5, -280, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 0.2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
makeDraggable(Main)

-- [[ 4. Tabs & Container ]] --
local BrandTitle = Instance.new("TextLabel", Main)
BrandTitle.Text = "Nattawut-Ch"
BrandTitle.Size = UDim2.new(0, 130, 0, 60)
BrandTitle.Position = UDim2.new(0, 20, 0, 0)
BrandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextSize = 18
BrandTitle.BackgroundTransparency = 1
BrandTitle.TextXAlignment = "Left"

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -160, 0, 45)
TabBar.Position = UDim2.new(0, 150, 0, 7)
TabBar.BackgroundTransparency = 1
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -85)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 0.8
Container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", Container)

local function addPage(name)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = "Center"
    
    local Btn = Instance.new("TextButton", TabBar)
    Btn.Size = UDim2.new(0, 90, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(130, 130, 130)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        Page.Visible = true
        for _, b in pairs(TabBar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(130, 130, 130) end end
        Btn.TextColor3 = Color3.fromRGB(0, 170, 255)
    end)
    return Page
end

-- [[ 5. Ray UI Components ]] --

-- สวิตช์เปิด/ปิด (Blue Toggle)
local function createToggle(parent, text, callback)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(0.95, 0, 0, 50)
    F.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    F.BackgroundTransparency = 0.95
    Instance.new("UICorner", F)

    local L = Instance.new("TextLabel", F)
    L.Text = text
    L.Size = UDim2.new(0.6, 0, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.BackgroundTransparency = 1
    L.TextXAlignment = "Left"
    L.Font = Enum.Font.GothamBold
    L.TextSize = 13

    local Tbg = Instance.new("TextButton", F)
    Tbg.Size = UDim2.new(0, 40, 0, 20)
    Tbg.Position = UDim2.new(1, -55, 0.5, -10)
    Tbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Tbg.Text = ""
    Instance.new("UICorner", Tbg).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", Tbg)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 3, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local enabled = false
    Tbg.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetPos = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 40)
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(Tbg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(enabled)
        playNotify(text .. (enabled and " On" or " Off"))
    end)
end

-- ปุ่มเลือกแบบ Ray Option (Dropdown Style)
local function createRayOption(parent, title, options, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 0.96
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = title:upper()
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = "Left"
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11

    local Cont = Instance.new("Frame", Frame)
    Cont.Size = UDim2.new(0.55, 0, 1, 0)
    Cont.Position = UDim2.new(0.45, -10, 0, 0)
    Cont.BackgroundTransparency = 1
    Instance.new("UIListLayout", Cont).FillDirection = "Horizontal"
    Cont.UIListLayout.HorizontalAlignment = "Right"
    Cont.UIListLayout.VerticalAlignment = "Center"
    Cont.UIListLayout.Padding = UDim.new(0, 6)

    for _, opt in pairs(options) do
        local B = Instance.new("TextButton", Cont)
        B.Size = UDim2.new(0, 65, 0, 28)
        B.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        B.BackgroundTransparency = 0.9
        B.Text = opt
        B.TextColor3 = Color3.fromRGB(255, 255, 255)
        B.Font = Enum.Font.GothamBold
        B.TextSize = 10
        Instance.new("UIStroke", B).Color = Color3.fromRGB(0, 170, 255)
        Instance.new("UICorner", B)
        B.MouseButton1Click:Connect(function() 
            for _, btn in pairs(Cont:GetChildren()) do if btn:IsA("TextButton") then btn.BackgroundTransparency = 0.9 end end
            B.BackgroundTransparency = 0.6
            callback(opt) 
        end)
    end
end

-- ช่องใส่ชื่อไฟล์ (Input)
local function createFileNameInput(parent, title, callback)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(0.95, 0, 0, 60)
    F.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    F.BackgroundTransparency = 0.96
    Instance.new("UICorner", F)
    local L = Instance.new("TextLabel", F)
    L.Text = title:upper()
    L.Size = UDim2.new(1, 0, 0, 25)
    L.Position = UDim2.new(0, 15, 0, 5)
    L.TextColor3 = Color3.fromRGB(180, 180, 180)
    L.BackgroundTransparency = 1
    L.TextXAlignment = "Left"
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    local Input = Instance.new("TextBox", F)
    Input.Size = UDim2.new(0.7, 0, 0, 25)
    Input.Position = UDim2.new(0, 15, 0, 30)
    Input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Input.BackgroundTransparency = 0.8
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderText = "Enter Name..."
    Input.Font = Enum.Font.GothamMedium
    Input.TextSize = 12
    Instance.new("UICorner", Input)
    local Btn = Instance.new("TextButton", F)
    Btn.Size = UDim2.new(0, 55, 0, 25)
    Btn.Position = UDim2.new(0.75, 5, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Text = "CREATE"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 9
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function() if Input.Text ~= "" then callback(Input.Text) Input.Text = "" end end)
end

-- --- [ APPLY PAGES ] --- --
local GameplayTab = addPage("Gameplay")
local MacroTab    = addPage("Macro")
addPage("Summon")
addPage("Settings")
GameplayTab.Visible = true

-- [[ 6. GAMEPLAY FUNCTIONS ]]
createToggle(GameplayTab, "Auto Start", function(state) _G.AutoStart = state end)
createToggle(GameplayTab, "Auto Replay", function(state) _G.AutoReplay = state end)
createToggle(GameplayTab, "Auto Select Card", function(state) _G.AutoCard = state end)

createRayOption(GameplayTab, "Wave Speed", {"Fast", "Super"}, function(choice)
    local val = (choice == "Fast") and "Fast Wave" or "Super Faster Wave"
    ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge"):FireServer(val)
end)

createRayOption(GameplayTab, "Card Select", {"2", "3"}, function(choice)
    _G.SelectedCard = choice
end)

-- [[ 7. MACRO FUNCTIONS ]]
createFileNameInput(MacroTab, "Create Macro File", function(name)
    playNotify("File Created: " .. name)
end)

createRayOption(MacroTab, "Select Macro", {"Macro 1", "Macro 2"}, function(choice)
    playNotify("Loaded: " .. choice)
end)

createToggle(MacroTab, "Record Macro", function(state) _G.IsRecording = state end)
createToggle(MacroTab, "Auto Play Macro", function(state) _G.AutoPlay = state end)

-- [[ 8. Toggle Button (N) ]] --
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 1, -70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.BackgroundTransparency = 0.5
ToggleBtn.Text = "N"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
makeDraggable(ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
    Notif.Position = UDim2.new(1, 20, 0, 20)
    Notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Notif.BackgroundTransparency = 0.2
    Notif.Parent = ScreenGui
    
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = Color3.fromRGB(255, 255, 255)

    local Txt = Instance.new("TextLabel", Notif)
    Txt.Size = UDim2.new(1, 0, 1, 0)
    Txt.BackgroundTransparency = 1
    Txt.Text = messages[tabName] or "SELECTED"
    Txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    Txt.Font = Enum.Font.GothamBold
    Txt.TextSize = 11

    -- Animation: เด้งเข้า
    local tweenIn = TweenService:Create(Notif, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -220, 0, 20)})
    tweenIn:Play()
    
    task.wait(1.2) -- โชว์ข้อความค้างไว้
    
    -- Animation: เด้งออก
    local tweenOut = TweenService:Create(Notif, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 20)})
    tweenOut:Play()
    
    tweenOut.Completed:Connect(function()
        Notif:Destroy()
        isNotifying = false -- ปลดล็อคสถานะเพื่อให้ข้อความถัดไปขึ้นได้ (รอจนหายถึงขึ้นอันใหม่)
    end)
end

-- [[ 2. Draggable Function ]] --
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ 3. Main UI Frame ]] --
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 390)
Main.Position = UDim2.new(0.5, -280, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0.4
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(60, 60, 60)
makeDraggable(Main)

-- [[ 4. Header (Brand & Tabs) ]] --
local BrandTitle = Instance.new("TextLabel", Main)
BrandTitle.Text = "Nattawut-Ch"
BrandTitle.Size = UDim2.new(0, 130, 0, 60)
BrandTitle.Position = UDim2.new(0, 20, 0, 0)
BrandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextSize = 18
BrandTitle.BackgroundTransparency = 1
BrandTitle.TextXAlignment = "Left"

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -160, 0, 45)
TabBar.Position = UDim2.new(0, 150, 0, 7)
TabBar.BackgroundTransparency = 1
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"
TabBar.UIListLayout.Padding = UDim.new(0, 2)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -75)
Container.Position = UDim2.new(0, 10, 0, 65)
Container.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Container.BackgroundTransparency = 0.5
Container.Parent = Main
Instance.new("UICorner", Container)

local function addPage(name)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    
    local Btn = Instance.new("TextButton", TabBar)
    Btn.Size = UDim2.new(0, 90, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(130, 130, 130)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11

    local Line = Instance.new("Frame", Btn)
    Line.Size = UDim2.new(0.5, 0, 0, 2)
    Line.Position = UDim2.new(0.25, 0, 1, -8)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 1

    Btn.MouseButton1Click:Connect(function()
        task.spawn(function() playNotify(name) end) -- เรียกแจ้งเตือน (แต่จะโดนระบบดักถ้ามีของเก่าอยู่)
        
        for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        Page.Visible = true
        
        for _, b in pairs(TabBar:GetChildren()) do
            if b:Islocal HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [[ 🛠️ BACKEND LOGIC - ห้ามลบส่วนนี้เพื่อให้ระบบทำงานได้ ]] --
local MacroSystem = {
    IsRecording = false,
    IsPlaying = false,
    Data = {},
    StartTime = 0,
    Folder = "ImmortalLogic_Macros",
    ConfigFile = "ImmortalLogic_Config.json"
}

if not isfolder(MacroSystem.Folder) then makefolder(MacroSystem.Folder) end

-- ฟังก์ชันดึงรายชื่อไฟล์เข้า Dropdown
local function UpdateDropdown()
    local files = listfiles(MacroSystem.Folder)
    local names = {}
    for _, file in ipairs(files) do
        table.insert(names, file:gsub(MacroSystem.Folder .. "/", ""):gsub(MacroSystem.Folder .. "\\", ""):gsub(".json", ""))
    end
    if _G.MacroDropdown then _G.MacroDropdown:SetValues(names) end
end

-- ฟังก์ชัน Save ค่าใน UI ทั้งหมด
local function SaveAllConfigs()
    local data = {}
    for i, v in pairs(_G.FluentOptions) do
        if v.Type == "Toggle" or v.Type == "Slider" or v.Type == "Dropdown" or v.Type == "Input" then
            data[i] = v.Value
        end
    end
    writefile(MacroSystem.ConfigFile, HttpService:JSONEncode(data))
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
_G.FluentOptions = Fluent.Options -- เก็บไว้ใช้ Auto Save

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
Tabs.Gameplay:AddToggle("AutoStart", { Title = "Auto Start Match", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoReplay", { Title = "Auto Replay Stage", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoNext", { Title = "Auto Next Stage", Default = false, Callback = function() SaveAllConfigs() end })
Tabs.Gameplay:AddToggle("AutoLeave", { Title = "Auto Return to Lobby", Default = false, Callback = function() SaveAllConfigs() end })

Tabs.Gameplay:AddSection("Combat System")
Tabs.Gameplay:AddDropdown("SkillMode", {
    Title = "Ability Activation Mode",
    Values = {"Continuous Execution", "Boss Phase Only"},
    Default = "Continuous Execution",
    Callback = function() SaveAllConfigs() end
})
Tabs.Gameplay:AddToggle("AutoSkill", { Title = "Auto Skill System", Default = false, Callback = function() SaveAllConfigs() end })

-- [[ 🤖 AUTO SKILL BRAIN ]]
task.spawn(function()
    while true do
        if Fluent.Options.AutoSkill and Fluent.Options.AutoSkill.Value then
            pcall(function()
                local towerFolder = workspace:FindFirstChild("placedTowers")
                if towerFolder then
                    for _, tower in ipairs(towerFolder:GetChildren()) do
                        ReplicatedStorage.sync.sync_RELIABLE:FireServer(buffer.fromstring("\000+\000" .. tower.Name .. "\001\000"), {})
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

Tabs.Gameplay:AddSection("Coming Soon")
Tabs.Gameplay:AddParagraph({
    Title = "Planned Features",
    Content = "Additional automation modules and advanced combat logic are currently under development."
})

---------------------------------------------------------
-- ⏺️ [MACRO ENGINE]
---------------------------------------------------------
Tabs.Macro:AddSection("Live Monitoring")
local ActionLabel = Tabs.Macro:AddParagraph({ Title = "Action Counter", Content = "0 Actions Logged" })
local TimeLabel = Tabs.Macro:AddParagraph({ Title = "Session Timer", Content = "00:00 Seconds" })

-- [[ ⏺️ MACRO HOOK ]]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and MacroSystem.IsRecording and (self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE") then
        local now = tick()
        local bufStr = typeof(args[1]) == "buffer" and buffer.tostring(args[1]) or tostring(args[1])
        table.insert(MacroSystem.Data, {
            Remote = self.Name, BufferStr = bufStr,
            HasID = string.find(bufStr, "tower%-") ~= nil,
            Extra = args[2] or {}, Delay = (#MacroSystem.Data == 0) and 0 or (now - MacroSystem.StartTime)
        })
        MacroSystem.StartTime = now
        ActionLabel:SetTitle(#MacroSystem.Data .. " Actions Logged")
    end
    return OldNamecall(self, ...)
end)

Tabs.Macro:AddSection("Data Management")
Tabs.Macro:AddInput("MacroNameInput", { Title = "Configuration Name", Placeholder = "Enter filename...", Callback = function() SaveAllConfigs() end })
_G.MacroDropdown = Tabs.Macro:AddDropdown("MacroSelect", { Title = "Select Configuration", Values = {}, Callback = function() SaveAllConfigs() end })

Tabs.Macro:AddButton({ 
    Title = "Initialize New File", 
    Callback = function() 
        local name = Fluent.Options.MacroNameInput.Value
        if name ~= "" then
            writefile(MacroSystem.Folder .. "/" .. name .. ".json", HttpService:JSONEncode({}))
            UpdateDropdown()
            Fluent:Notify({Title = "Macro", Content = "สร้างไฟล์ใหม่สำเร็จ: " .. name})
        end
    end 
})

Tabs.Macro:AddSection("Execution Control")
Tabs.Macro:AddToggle("RecordToggle", { 
    Title = "Capture Mode", 
    Description = "Record Macro Actions", 
    Default = false, 
    Callback = function(v) 
        MacroSystem.IsRecording = v
        if v then
            table.clear(MacroSystem.Data)
            MacroSystem.StartTime = tick()
            task.spawn(function()
                while MacroSystem.IsRecording do
                    TimeLabel:SetTitle(string.format("%.2f Seconds", tick() - MacroSystem.StartTime))
                    task.wait(0.1)
                end
            end)
        else
            local name = Fluent.Options.MacroNameInput.Value
            if name ~= "" then
                writefile(MacroSystem.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(MacroSystem.Data))
                UpdateDropdown()
            end
        end
        SaveAllConfigs()
    end 
})

Tabs.Macro:AddToggle("PlayToggle", { 
    Title = "Playback System", 
    Description = "Play Recorded Macro", 
    Default = false, 
    Callback = function(v) 
        if v then
            local name = Fluent.Options.MacroSelect.Value
            if not name or not isfile(MacroSystem.Folder .. "/" .. name .. ".json") then 
                Fluent.Options.PlayToggle:SetValue(false) return 
            end
            local data = HttpService:JSONDecode(readfile(MacroSystem.Folder .. "/" .. name .. ".json"))
            MacroSystem.IsPlaying = true
            for _, act in ipairs(data) do
                if not Fluent.Options.PlayToggle.Value then break end
                task.wait(act.Delay)
                pcall(function()
                    local finalStr = act.BufferStr
                    local towers = workspace.placedTowers:GetChildren()
                    local realID = #towers > 0 and towers[#towers].Name or nil
                    if act.HasID and realID then finalStr = string.gsub(act.BufferStr, "tower%-[%w%-]+", realID) end
                    ReplicatedStorage.sync[act.Remote]:FireServer(buffer.fromstring(finalStr), act.Extra)
                end)
            end
            Fluent.Options.PlayToggle:SetValue(false)
        end
        SaveAllConfigs()
    end 
})

Tabs.Macro:AddSection("Cleanup")
Tabs.Macro:AddButton({ 
    Title = "Purge Selected File", 
    Callback = function() 
        local name = Fluent.Options.MacroSelect.Value
        if name then delfile(MacroSystem.Folder .. "/" .. name .. ".json") UpdateDropdown() end
    end 
})

---------------------------------------------------------
-- 🔔 [WEBHOOK]
---------------------------------------------------------
Tabs.Webhook:AddSection("Notifications")
Tabs.Webhook:AddInput("WebhookURL", { Title = "Discord Webhook URL", Placeholder = "Enter URL here...", Callback = function() SaveAllConfigs() end })

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
        SaveAllConfigs()
    end
})
Tabs.Settings:AddToggle("AutoRun", { Title = "Force Auto Run", Default = false, Callback = function() SaveAllConfigs() end })

Tabs.Settings:AddSection("Configuration")
Tabs.Settings:AddButton({ 
    Title = "Save Current Config", 
    Callback = function() 
        SaveAllConfigs()
        Fluent:Notify({Title = "Settings", Content = "Saved Successfully!"})
    end 
})
Tabs.Settings:AddButton({ Title = "Unload Script", Callback = function() Window:Destroy() end })

-- [[ 🚀 FINAL INITIALIZE ]]
UpdateDropdown()
if isfile(MacroSystem.ConfigFile) then
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(MacroSystem.ConfigFile)) end)
    if success then
        for i, v in pairs(data) do if Fluent.Options[i] then Fluent.Options[i]:SetValue(v) end end
    end
end
Window:SelectTab(1)
A("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(130, 130, 130)}):Play()
                TweenService:Create(b:FindFirstChild("Frame"), TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            end
        end
        TweenService:Create(Btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Line, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    end)
    return Page
end

local GameplayTab = addPage("Gameplay")
local MacroTab    = addPage("Macro")
local SummonTab   = addPage("Summon")
local SettingsTab = addPage("Settings")
GameplayTab.Visible = true

-- [[ 5. ปุ่มเปิด/ปิด (N) - ลากได้ & เริ่มต้นซ้ายล่าง ]] --
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 1, -70) -- ซ้ายล่างสุด
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.BackgroundTransparency = 0.3
ToggleBtn.Text = "N"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(255, 255, 255)

makeDraggable(ToggleBtn) -- ปุ่มเปิดปิดลากไปไหนก็ได้

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
