local Fluent = nil
local Success, Error = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success then
    return
end

Fluent = Error

-- ==========================================
-- WINDOW CREATION
-- ==========================================
local Window = Fluent:CreateWindow({
    Title = "Zenith Soul HUB",
    SubTitle = "by Yifeng",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local HubTabs = {
    Main     = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm     = Window:AddTab({ Title = "Farm", Icon = "swords" }),
    Boss     = Window:AddTab({ Title = "Boss", Icon = "skull" }),
    Dungeon  = Window:AddTab({ Title = "Dungeon", Icon = "shield" }),
    Stats    = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ==========================================
-- CONFIGURATION STATES
-- ==========================================
local Config = {
    FarmEnabled          = false,
    TargetMonster        = "None",
    SelectedWeapon       = "None",
    FarmAngle            = "Behind",
    DistanceBehind       = 7.5,
    TeleportDelay        = 0.15,
    
    SummonBossEnabled    = false,
    SelectedSummonBoss   = "Sukuna",

    BattleBossEnabled    = false,
    SelectedBattleBoss   = "Verdant Hero",

    PriorityBossEnabled  = false,
    SelectedPriorityBoss = "Sung Jinwoo",

    AutoStatsEnabled     = false,
    SelectedStat         = "Strength",
    StatsAmount          = 1,

    SelectedTeleportTarget = "None",
    SearchTeleportName     = "",

    SelectedTheme        = "Deep Dark",
    AntiAFKEnabled       = false
}

local LastTargetQuest = "None"
local CurrentFarmTarget = nil
local IsFarmingActive = false
local IsSwitchingTarget = false

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SaveFolder = "ZenithSoulHub"
local SaveFile = SaveFolder .. "/Config.json"

local function SaveConfig()
    pcall(function()
        if not isfolder(SaveFolder) then makefolder(SaveFolder) end
        writefile(SaveFile, HttpService:JSONEncode(Config))
    end)
    Fluent:Notify({ Title = "Zenith Soul", Content = "Config saved!", Duration = 2 })
end

local function LoadConfig()
    if isfolder(SaveFolder) and isfile(SaveFile) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(SaveFile)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then Config[k] = v end
            end
        end
    end
end

LoadConfig()

-- ==========================================
-- DATABASE & MAPS
-- ==========================================
local StaticMonsterList = {
    "Bandit [Lv.1]", "Bandit Leader [Lv.50]", "Monkey [Lv.250]", "Shank [Lv.400]",
    "Snow Bandit [Lv.600]", "Mihawk [Lv.800]", "National Level Hunter [Lv.1000]",
    "Sorcerer Student [Lv.1300]", "Miwa [Lv.1600]", "Hollow [Lv.2000]",
    "Arrancar [Lv.2500]", "Sung Jinwoo [Lv.3000]"
}

local QuestIDs = {
    ["Bandit"] = 1, ["Bandit Leader"] = 2, ["Monkey"] = 3, ["Shank"] = 4,
    ["Snow Bandit"] = 8, ["Mihawk"] = 7, ["National Level Hunter"] = 9,
    ["Sorcerer Student"] = 5, ["Miwa"] = 6, ["Hollow"] = 10,
    ["Arrancar"] = 11, ["Sung Jinwoo"] = 12
}

local CustomThemes = {
    ["Deep Dark"] = { Accent = Color3.fromRGB(85, 170, 255), Background = Color3.fromRGB(5, 5, 5), LightContrast = Color3.fromRGB(10, 10, 10), DarkContrast = Color3.fromRGB(2, 2, 2), TextColor = Color3.fromRGB(255, 255, 255) },
    ["Midnight"] = { Accent = Color3.fromRGB(0, 120, 215), Background = Color3.fromRGB(10, 12, 18), LightContrast = Color3.fromRGB(15, 18, 25), DarkContrast = Color3.fromRGB(5, 6, 10), TextColor = Color3.fromRGB(240, 240, 250) },
    ["Charcoal"] = { Accent = Color3.fromRGB(200, 200, 200), Background = Color3.fromRGB(15, 15, 15), LightContrast = Color3.fromRGB(22, 22, 22), DarkContrast = Color3.fromRGB(8, 8, 8), TextColor = Color3.fromRGB(230, 230, 230) }
}

local function applyCustomTheme(themeName)
    local themeData = CustomThemes[themeName]
    if themeData and Window then
        for Key, Value in pairs(themeData) do
            pcall(function() Fluent.ThemeManager:SetColor(Key, Value) end)
        end
    end
end

local function isAlive(entity)
    if not entity or not entity:IsDescendantOf(workspace) then return false end
    local humanoid = entity:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function getCleanName(fullName)
    return fullName:gsub("%s*%[Lv%.%s*%d+%]", ""):gsub("%s*%[Lv%.%s*Unknown%]", "")
end

local function switchQuest(newMonsterName)
    local questId = QuestIDs[newMonsterName]
    if not questId then return end
    local rs = game:GetService("ReplicatedStorage")
    local qEvent = rs:FindFirstChild("QuestEvent", true) or rs:FindFirstChild("RE/QuestEvent", true)
    if qEvent then
        qEvent:FireServer("Cancel")
        task.wait(0.2)
        qEvent:FireServer("Request", { Id = questId })
    end
end

local function summonBoss(bossName)
    local rs = game:GetService("ReplicatedStorage")
    local sEvent = rs:FindFirstChild("SummonEvent", true) or rs:FindFirstChild("RE/SummonEvent", true)
    if sEvent then sEvent:FireServer("Summon", { Boss = bossName }) end
end

local function allocateStat(statName, amount)
    local rs = game:GetService("ReplicatedStorage")
    local aEvent = rs:FindFirstChild("StatsAllocateEvent", true) or rs:FindFirstChild("RE/StatsAllocateEvent", true)
    if aEvent then aEvent:FireServer(statName, amount) end
end

local function checkSpecificBossExists(bossName)
    local cleanName = getCleanName(bossName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == cleanName and isAlive(v) then return v end
    end
    return nil
end

local function getWeaponList()
    local list = {}
    if LocalPlayer then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(list, tool.Name) end
        end
        if LocalPlayer.Character then
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then table.insert(list, tool.Name) end
            end
        end
    end
    return list
end

local function findTarget()
    if Config.PriorityBossEnabled and Config.SelectedPriorityBoss ~= "None" then
        local boss = checkSpecificBossExists(Config.SelectedPriorityBoss)
        if boss then return boss, false end
    end
    if Config.BattleBossEnabled and Config.SelectedBattleBoss ~= "None" then
        local boss = checkSpecificBossExists(Config.SelectedBattleBoss)
        if boss then return boss, false end
    end
    if Config.SummonBossEnabled and Config.SelectedSummonBoss ~= "None" then
        local boss = checkSpecificBossExists(Config.SelectedSummonBoss)
        if boss then return boss, false end
    end
    if Config.FarmEnabled and Config.TargetMonster ~= "None" then
        local cleanName = getCleanName(Config.TargetMonster)
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == cleanName and isAlive(v) then return v, true end
        end
    end
    return nil, false
end

-- ==========================================
-- TAB: MAIN
-- ==========================================
local MainSection = HubTabs.Main:AddSection("Welcome back, Master")
HubTabs.Main:AddParagraph({
    Title = "Zenith Soul Engine v2.8",
    Content = "High-efficiency auto farming system with secure execution. Optimized for RDP and Mobile."
})

-- ==========================================
-- TAB: FARM
-- ==========================================
local FarmSection = HubTabs.Farm:AddSection("Farm Settings")
HubTabs.Farm:AddInput("DistanceInput", { Title = "Distance Offset", Default = tostring(Config.DistanceBehind), Numeric = true, Finished = true, Callback = function(Value) Config.DistanceBehind = tonumber(Value) or 7.5 end })
HubTabs.Farm:AddDropdown("MonsterDropdown", { Title = "Select Target", Values = StaticMonsterList, CurrentValue = Config.TargetMonster, Callback = function(Value) Config.TargetMonster = Value end })
HubTabs.Farm:AddDropdown("AngleDropdown", { Title = "Attack Angle", Values = { "Behind", "Above", "Below" }, CurrentValue = Config.FarmAngle, Callback = function(Value) Config.FarmAngle = Value end })
local WeaponDropdown = HubTabs.Farm:AddDropdown("WeaponDropdown", { Title = "Select Weapon", Values = getWeaponList(), CurrentValue = Config.SelectedWeapon, Callback = function(Value) Config.SelectedWeapon = Value end })
HubTabs.Farm:AddButton({ Title = "Refresh Weapons", Callback = function() WeaponDropdown:SetValues(getWeaponList()) Fluent:Notify({ Title = "Zenith Soul", Content = "Weapons updated!", Duration = 2 }) end })
HubTabs.Farm:AddToggle("FarmToggle", { Title = "Auto Farm", Default = Config.FarmEnabled, Callback = function(Value) Config.FarmEnabled = Value end })

HubTabs.Farm:AddParagraph({ 
    Title = "ออโต้ฟาร์ม", 
    Content = "ระบบเปิด-ปิดฟาร์มมอนสเตอร์ทั่วไปและรับเควสแบบอัตโนมัติ" 
})

-- ==========================================
-- TAB: BOSS
-- ==========================================
local SummonSection = HubTabs.Boss:AddSection("Boss Summon")
HubTabs.Boss:AddDropdown("SummonDropdown", { Title = "Select Summon", Values = { "Sukuna", "Gojo" }, CurrentValue = Config.SelectedSummonBoss, Callback = function(Value) Config.SelectedSummonBoss = Value end })
HubTabs.Boss:AddToggle("AutoSummonToggle", { Title = "Auto Summon", Default = Config.SummonBossEnabled, Callback = function(Value) Config.SummonBossEnabled = Value end })

local BattleSection = HubTabs.Boss:AddSection("Battle Summon")
HubTabs.Boss:AddDropdown("BattleBossDropdown", { Title = "Select Battle", Values = { "Verdant Hero", "Saber" }, CurrentValue = Config.SelectedBattleBoss, Callback = function(Value) Config.SelectedBattleBoss = Value end })
HubTabs.Boss:AddToggle("AutoBattleBossToggle", { Title = "Auto Battle", Default = Config.BattleBossEnabled, Callback = function(Value) Config.BattleBossEnabled = Value end })

local PrioritySection = HubTabs.Boss:AddSection("Priority Target")
HubTabs.Boss:AddDropdown("PriorityDropdown", { Title = "Select Boss", Values = { "Sung Jinwoo" }, CurrentValue = Config.SelectedPriorityBoss, Callback = function(Value) Config.SelectedPriorityBoss = Value end })
HubTabs.Boss:AddToggle("PriorityToggle", { Title = "Auto Farm Boss", Default = Config.PriorityBossEnabled, Callback = function(Value) Config.PriorityBossEnabled = Value end })

HubTabs.Boss:AddParagraph({ 
    Title = "ระบบฟาร์มบอส", 
    Content = "ระบบฟาร์มบอสระดับพรีเมียมและบอสเสกที่จะพาวาร์ปไปล่าทันทีเมื่อบอสเกิด" 
})

-- ==========================================
-- TAB: DUNGEON
-- ==========================================
HubTabs.Dungeon:AddParagraph({ Title = "Dungeon Mode", Content = "Dungeon progression engine is currently in development." })
HubTabs.Dungeon:AddParagraph({ 
    Title = "โหมดดันเจี้ยน", 
    Content = "ระบบผ่านดันเจี้ยนอัตโนมัติ (กำลังอยู่ในระหว่างการพัฒนาและทดสอบ)" 
})

-- ==========================================
-- TAB: STATS
-- ==========================================
local StatsSection = HubTabs.Stats:AddSection("Auto Stats")
HubTabs.Stats:AddDropdown("StatSelectionDropdown", { Title = "Select Stat", Values = { "Strength", "Defense", "Weapon", "Power" }, CurrentValue = Config.SelectedStat, Callback = function(Value) Config.SelectedStat = Value end })
HubTabs.Stats:AddInput("StatAmountInput", { Title = "Points", Default = tostring(Config.StatsAmount), Numeric = true, Finished = true, Callback = function(Value) Config.StatsAmount = tonumber(Value) or 1 end })
HubTabs.Stats:AddToggle("AutoStatsToggle", { Title = "Enable Stats", Default = Config.AutoStatsEnabled, Callback = function(Value) Config.AutoStatsEnabled = Value end })

HubTabs.Stats:AddParagraph({ 
    Title = "อัพสเตตัสอัตโนมัติ", 
    Content = "อัพค่าพลังสถานะของตัวละครทันทีที่ได้รับแต้มสเตตัสเพิ่มขึ้น" 
})

-- ==========================================
-- TAB: TELEPORT
-- ==========================================
local TeleportSection = HubTabs.Teleport:AddSection("Teleport System")
HubTabs.Teleport:AddInput("SearchBarInput", { Title = "Search Target", Default = "", Callback = function(Value) Config.SearchTeleportName = Value:lower() end })
HubTabs.Teleport:AddDropdown("TeleportDropdown", { Title = "Select Target", Values = StaticMonsterList, CurrentValue = Config.SelectedTeleportTarget, Callback = function(Value) Config.SelectedTeleportTarget = Value end })
HubTabs.Teleport:AddButton({ Title = "Teleport", Callback = function()
    local targetName = Config.SelectedTeleportTarget
    if Config.SearchTeleportName ~= "" then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find(Config.SearchTeleportName) and v:FindFirstChild("HumanoidRootPart") then
                targetName = v.Name
                break
            end
        end
    end
    local targetInstance = workspace:FindFirstChild(targetName, true)
    if targetInstance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetInstance.HumanoidRootPart.CFrame
        Fluent:Notify({ Title = "Zenith Soul", Content = "Teleported!", Duration = 2 })
    end
end })

HubTabs.Teleport:AddParagraph({ 
    Title = "ระบบวาร์ป", 
    Content = "เลือกเป้าหมายหรือพิมพ์ชื่อวัตถุในแมพเพื่อเคลื่อนย้ายตำแหน่งตัวละครทันที" 
})

-- ==========================================
-- TAB: SETTINGS
-- ==========================================
local SaveSection = HubTabs.Settings:AddSection("Configuration")
HubTabs.Settings:AddButton({ Title = "Save Config", Callback = function() SaveConfig() end })
HubTabs.Settings:AddDropdown("ThemeSelectorDropdown", { Title = "Select Theme", Values = { "Deep Dark", "Midnight", "Charcoal" }, CurrentValue = Config.SelectedTheme, Callback = function(Value) Config.SelectedTheme = Value applyCustomTheme(Value) end })
HubTabs.Settings:AddToggle("AntiAFKToggle", { Title = "Anti-AFK", Default = Config.AntiAFKEnabled, Callback = function(Value) Config.AntiAFKEnabled = Value end })

HubTabs.Settings:AddParagraph({ 
    Title = "ตั้งค่าระบบ", 
    Content = "บันทึกการตั้งค่าของตัวสคริปต์, ปรับแต่งธีมหน้าต่าง และเปิดระบบป้องกันการโดนเตะออกจากเกม" 
})

-- ==========================================
-- UTILITY LOOPS & PHYSICS CONTROLLERS
-- ==========================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFKEnabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoStatsEnabled then pcall(function() allocateStat(Config.SelectedStat, Config.StatsAmount) end) end
    end
end)

task.spawn(function()
    while task.wait(2.0) do
        if Config.SummonBossEnabled and not checkSpecificBossExists(Config.SelectedSummonBoss) then summonBoss(Config.SelectedSummonBoss) end
        if Config.BattleBossEnabled and not checkSpecificBossExists(Config.SelectedBattleBoss) then summonBoss(Config.SelectedBattleBoss) end
    end
end)

-- PASSIVE TARGET MONITOR (ปรับปรุงดีเลย์สลับตัวเป็น 0.4 วินาที)
task.spawn(function()
    while task.wait(0.4) do 
        IsFarmingActive = (Config.FarmEnabled or Config.SummonBossEnabled or Config.BattleBossEnabled or Config.PriorityBossEnabled)
        
        if IsFarmingActive and not IsSwitchingTarget then
            if CurrentFarmTarget and isAlive(CurrentFarmTarget) then
                -- ยังไม่ตาย ทำงานต่อ
            else
                -- หากเป้าหมายเดิมสลายไปแล้ว ดีเลย์พัก 0.4 วินาทีเพื่อหาเป้าหมายถัดไปอย่างปลอดภัย
                IsSwitchingTarget = true
                task.wait(0.7)
                
                local target, isQuest = findTarget()
                CurrentFarmTarget = target
                IsSwitchingTarget = false
                
                if target and isQuest then
                    local cleanName = getCleanName(target.Name)
                    if cleanName ~= LastTargetQuest then
                        LastTargetQuest = cleanName
                        task.spawn(function() switchQuest(cleanName) end)
                    end
                end
            end
        elseif not IsFarmingActive then
            CurrentFarmTarget = nil
        end
    end
end)

-- NO-SPIN MOVEMENT CONTROLLER
RunService.Heartbeat:Connect(function()
    if IsFarmingActive and CurrentFarmTarget and isAlive(CurrentFarmTarget) and not IsSwitchingTarget then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local tHrp = CurrentFarmTarget:FindFirstChild("HumanoidRootPart")

        if hrp and tHrp then
            local offset = CFrame.new(0, 0, Config.DistanceBehind)
            if Config.FarmAngle == "Above" then 
                offset = CFrame.new(0, Config.DistanceBehind, 0)
            elseif Config.FarmAngle == "Below" then 
                offset = CFrame.new(0, -Config.DistanceBehind, 0) 
            end
            
            local targetRotation = tHrp.CFrame - tHrp.CFrame.Position
            hrp.CFrame = CFrame.new(tHrp.Position) * targetRotation * offset
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- SAFE EXCLUSIVE NOCLIP
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if IsFarmingActive and CurrentFarmTarget and isAlive(CurrentFarmTarget) then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- AUTO ATTACK
task.spawn(function()
    while task.wait(0.1) do
        if IsFarmingActive and CurrentFarmTarget and isAlive(CurrentFarmTarget) and Config.SelectedWeapon ~= "None" then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(Config.SelectedWeapon) or LocalPlayer.Backpack:FindFirstChild(Config.SelectedWeapon)
                if tool then
                    if tool.Parent ~= char then tool.Parent = char end
                    tool:Activate()
                end
            end
        end
    end
end)

-- UI RE-RENDER & DROP DOWN FIX
task.spawn(function()
    task.wait(1.5)
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") and gui.Name == "DropdownItems" then
                gui.Size = UDim2.new(1, 0, 0, 220)
                if gui:FindFirstChild("UIListLayout") then gui.UIListLayout.Padding = UDim.new(0, 4) end
                for _, btn in pairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") then
                        btn.Size = UDim2.new(1, -10, 0, 36)
                        if btn:FindFirstChild("UIStroke") then btn.UIStroke.Thickness = 1.5 end
                    end
                end
            end
        end
    end
end)

applyCustomTheme(Config.SelectedTheme)
Fluent:Notify({ Title = "Zenith Soul", Content = "Anti-Lag Engine Ready!", Duration = 3 })
