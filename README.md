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
    SubTitle = "by lovegojo",
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
    SelectedWeapon       = "None",
    AutoEquip            = false,
    FarmAngle            = "Behind",
    DistanceBehind       = 7.5,
    TargetMonster        = "None",
    FarmEnabled          = false,
    
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
local LastSafePosition = nil

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
    Title = "Zenith Soul Engine v2.9",
    Content = "High-efficiency auto farming system with secure execution.\nOptimized for RDP and Mobile."
})

-- ==========================================
-- TAB: FARM (CLEANED UP & ONLY 2 MAIN ITEMS FOR MONSTER FARM)
-- ==========================================
local WeaponSection = HubTabs.Farm:AddSection("Weapon Settings")
local WeaponDropdown = HubTabs.Farm:AddDropdown("WeaponDropdown", { Title = "Select Melee / Weapon", Description = "เลือกอาวุธ", Values = getWeaponList(), CurrentValue = Config.SelectedWeapon, Callback = function(Value) Config.SelectedWeapon = Value end })
HubTabs.Farm:AddToggle("AutoEquipToggle", { Title = "Auto Equip", Description = "o", Default = Config.AutoEquip, Callback = function(Value) Config.AutoEquip = Value end })
HubTabs.Farm:AddButton({ Title = "Refresh Weapons List", Description = "กดอัปเดตรายชื่ออาวุธใหม่ในตัว", Callback = function() WeaponDropdown:SetValues(getWeaponList()) end })

local PositionSection = HubTabs.Farm:AddSection("Position Settings")
local AngleDropdown = HubTabs.Farm:AddDropdown("AngleDropdown", { Title = "Attack Position / Angle", Description = "", Values = { "Behind หลัง", "Above บน", "Below ล่าง" }, CurrentValue = Config.FarmAngle, Callback = function(Value) Config.FarmAngle = Value end })
HubTabs.Farm:AddInput("DistanceInput", { Title = "Distance Offset Range", Description = "ระยะห่างระหว่างตัวละครกับมอนสเตอร์", Default = tostring(Config.DistanceBehind), Numeric = true, Finished = true, Callback = function(Value) Config.DistanceBehind = tonumber(Value) or 7.5 end })

local FarmSection = HubTabs.Farm:AddSection("Farm Monster")
local MonsterDropdown = HubTabs.Farm:AddDropdown("MonsterDropdown", { Title = "Select Monster", Description = "เลือกมอนส", Values = StaticMonsterList, CurrentValue = Config.TargetMonster, Callback = function(Value) Config.TargetMonster = Value end })
HubTabs.Farm:AddToggle("FarmToggle", { Title = "Auto Farm", Description = ".", Default = Config.FarmEnabled, Callback = function(Value) Config.FarmEnabled = Value end })

-- ==========================================
-- TAB: BOSS
-- ==========================================
local SummonSection = HubTabs.Boss:AddSection("Boss Summon")
local SummonDropdown = HubTabs.Boss:AddDropdown("SummonDropdown", { Title = "Select Summon Boss", Description = ".", Values = { "Sukuna", "Gojo" }, CurrentValue = Config.SelectedSummonBoss, Callback = function(Value) Config.SelectedSummonBoss = Value end })
HubTabs.Boss:AddToggle("AutoSummonToggle", { Title = "Auto Summon Boss", Description = "เรียกเสกบอสอัตโนมัติเมื่อแต้มเสกบอสพร้อม", Default = Config.SummonBossEnabled, Callback = function(Value) Config.SummonBossEnabled = Value end })

local BattleSection = HubTabs.Boss:AddSection("Boss Summon")
local BattleBossDropdown = HubTabs.Boss:AddDropdown("BattleBossDropdown", { Title = "Select Battle Boss", Description = "เสกบอส", Values = { "Verdant Hero", "Saber" }, CurrentValue = Config.SelectedBattleBoss, Callback = function(Value) Config.SelectedBattleBoss = Value end })
HubTabs.Boss:AddToggle("AutoBattleBossToggle", { Title = "Auto Boss", Description = "", Default = Config.BattleBossEnabled, Callback = function(Value) Config.BattleBossEnabled = Value end })

local PrioritySection = HubTabs.Boss:AddSection("Priority Targets")
local PriorityDropdown = HubTabs.Boss:AddDropdown("PriorityDropdown", { Title = "Select Target Boss", Description = "ล็อคเป้าหมายบอสพิเศษลำดับสูงสุด", Values = { "Sung Jinwoo" }, CurrentValue = Config.SelectedPriorityBoss, Callback = function(Value) Config.SelectedPriorityBoss = Value end })
HubTabs.Boss:AddToggle("PriorityToggle", { Title = "Auto Farm Boss", Description = "ตีบอสตัวนี้ก่อนเสมอทุกอัน", Default = Config.PriorityBossEnabled, Callback = function(Value) Config.PriorityBossEnabled = Value end })

-- ==========================================
-- TAB: DUNGEON
-- ==========================================
HubTabs.Dungeon:AddParagraph({ Title = "Coming soon", Content = "กำลังพัฒนาครับ" })

-- ==========================================
-- TAB: STATS
-- ==========================================
local StatsSection = HubTabs.Stats:AddSection("Auto Allocate Points")
local StatSelectionDropdown = HubTabs.Stats:AddDropdown("StatSelectionDropdown", { Title = "Select Stat Type", Description = "เลือกค่าพลังที่ต้องการใช้อัปเลเวล", Values = { "Strength", "Defense", "Weapon", "Power" }, CurrentValue = Config.SelectedStat, Callback = function(Value) Config.SelectedStat = Value end })
HubTabs.Stats:AddInput("StatAmountInput", { Title = "Stat Points Amount", Description = "ใส่จำนวนพ้อยท์ที่จะอัปต่อรอบการส่งข้อมูล", Default = tostring(Config.StatsAmount), Numeric = true, Finished = true, Callback = function(Value) Config.StatsAmount = tonumber(Value) or 1 end })
HubTabs.Stats:AddToggle("AutoStatsToggle", { Title = "Enable Auto Stats", Description = "เปิดระบบกดแต้มอัปสเตตัสแบบต่อเนื่อง", Default = Config.AutoStatsEnabled, Callback = function(Value) Config.AutoStatsEnabled = Value end })

-- ==========================================
-- TAB: TELEPORT
-- ==========================================
local TeleportSection = HubTabs.Teleport:AddSection("Instant Teleportation")
HubTabs.Teleport:AddInput("SearchBarInput", { Title = "Search World Target", Description = "พิมพ์ชื่อสถานที่หรือวัตถุเพื่อค้นหาในแมพ", Default = "", Callback = function(Value) Config.SearchTeleportName = Value:lower() end })
local TeleportDropdown = HubTabs.Teleport:AddDropdown("TeleportDropdown", { Title = "Select Map Target", Description = "เลือกมอนสเตอร์เพื่อใช้วาร์ปไปพิกัดนั้นทันที", Values = StaticMonsterList, CurrentValue = Config.SelectedTeleportTarget, Callback = function(Value) Config.SelectedTeleportTarget = Value end })
HubTabs.Teleport:AddButton({ Title = "Activate Teleport", Description = "กดย้ายตัวละครไปจุดพิกัดเป้าหมายที่เลือกไว้", Callback = function()
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

-- ==========================================
-- TAB: SETTINGS
-- ==========================================
local SaveSection = HubTabs.Settings:AddSection("Main Configuration")
HubTabs.Settings:AddButton({ Title = "Save Config Now", Description = "กดบันทึกพิกัดและการตั้งค่าทั้งหมดลงเครื่องสำรองไว้", Callback = function() SaveConfig() end })
local ThemeDropdown = HubTabs.Settings:AddDropdown("ThemeSelectorDropdown", { Title = "Select GUI Theme", Description = "เลือกโทนสีการตกแต่งหน้าต่างโปรแกรมโกง", Values = { "Deep Dark", "Midnight", "Charcoal" }, CurrentValue = Config.SelectedTheme, Callback = function(Value) Config.SelectedTheme = Value applyCustomTheme(Value) end })
HubTabs.Settings:AddToggle("AntiAFKToggle", { Title = "Anti-AFK Security", Description = "", Default = Config.AntiAFKEnabled, Callback = function(Value) Config.AntiAFKEnabled = Value end })

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

-- CORE MONITOR: TARGET SWITCHING WITH 0.8s SAFE COOLDOWN (ลอยค้างเมื่อไม่มีเป้าหมาย)
task.spawn(function()
    while task.wait(0.1) do 
        IsFarmingActive = (Config.FarmEnabled or Config.SummonBossEnabled or Config.BattleBossEnabled or Config.PriorityBossEnabled)
        
        if IsFarmingActive and not IsSwitchingTarget then
            if CurrentFarmTarget and isAlive(CurrentFarmTarget) then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LastSafePosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            else
                IsSwitchingTarget = true
                
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                    if LastSafePosition then
                        hrp.CFrame = LastSafePosition
                    end
                end
                
                task.wait(0.8)
                
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

-- KINEMATICS & CFrame CONTROLLER (KEEP HOVERING IN AIR SECURELY)
RunService.Heartbeat:Connect(function()
    if IsFarmingActive and not IsSwitchingTarget then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            if CurrentFarmTarget and isAlive(CurrentFarmTarget) then
                local tHrp = CurrentFarmTarget:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local targetPos = tHrp.Position
                    if Config.FarmAngle == "Above" then 
                        local myPos = targetPos + Vector3.new(0, Config.DistanceBehind, 0)
                        hrp.CFrame = CFrame.lookAt(myPos, targetPos)
                    elseif Config.FarmAngle == "Below" then 
                        local myPos = targetPos - Vector3.new(0, Config.DistanceBehind, 0)
                        hrp.CFrame = CFrame.lookAt(myPos, targetPos)
                    else
                        local offset = CFrame.new(0, 0, Config.DistanceBehind)
                        local targetRotation = tHrp.CFrame - tHrp.CFrame.Position
                        hrp.CFrame = CFrame.new(targetPos) * targetRotation * offset
                    end
                    LastSafePosition = hrp.CFrame
                end
            else
                if LastSafePosition then
                    hrp.CFrame = LastSafePosition
                end
            end
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- SAFE NOCLIP
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if IsFarmingActive then
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

-- AUTO ATTACK & AUTO EQUIP (0.15s SECURE DELAY)
task.spawn(function()
    while task.wait(0.15) do
        if IsFarmingActive and CurrentFarmTarget and isAlive(CurrentFarmTarget) and Config.SelectedWeapon ~= "None" and not IsSwitchingTarget then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(Config.SelectedWeapon) or LocalPlayer.Backpack:FindFirstChild(Config.SelectedWeapon)
                if tool then
                    if Config.AutoEquip and tool.Parent ~= char then 
                        tool.Parent = char 
                    end
                    if tool.Parent == char then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- UI RE-RENDER & STATE RESTORER (FORCE CORRECT STATE & FIX DROP-DOWN "...")
task.spawn(function()
    task.wait(2)
    
    if Config.SelectedWeapon ~= "None" then WeaponDropdown:SetValue(Config.SelectedWeapon) end
    if Config.TargetMonster ~= "None" then MonsterDropdown:SetValue(Config.TargetMonster) end
    if Config.SelectedSummonBoss ~= "None" then SummonDropdown:SetValue(Config.SelectedSummonBoss) end
    if Config.SelectedBattleBoss ~= "None" then BattleBossDropdown:SetValue(Config.SelectedBattleBoss) end
    if Config.SelectedPriorityBoss ~= "None" then PriorityDropdown:SetValue(Config.SelectedPriorityBoss) end
    if Config.SelectedTeleportTarget ~= "None" then TeleportDropdown:SetValue(Config.SelectedTeleportTarget) end
    if Config.SelectedStat ~= "Strength" then StatSelectionDropdown:SetValue(Config.SelectedStat) end
    if Config.FarmAngle ~= "Behind" then AngleDropdown:SetValue(Config.FarmAngle) end
    if Config.SelectedTheme ~= "Deep Dark" then ThemeDropdown:SetValue(Config.SelectedTheme) end

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
    Fluent:Notify({ Title = "Zenith Soul", Content = "Anti-Lag Engine & UI Ready!", Duration = 3 })
end)

applyCustomTheme(Config.SelectedTheme)
