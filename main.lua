local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")

local Window = Rayfield:CreateWindow({
   Name = "Nattawut Final Hub",
   LoadingTitle = "Nattawut System Loading...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {Enabled = true, FolderName = "NattawutData", FileName = "Config"}
})

-- [[ VARIABLES ]]
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local recording = false
local playing = false
local autoCollect = false 
local pathData = {}
local fileName = "Nattawut_Macro.json"

-- [[ THE COLLECTOR FUNCTION (ของพี่เป๊ะๆ) ]]
local function collectItem(obj)
    if obj:IsA("ProximityPrompt") then
        fireproximityprompt(obj)
    elseif obj:IsA("TouchTransmitter") then
        firetouchinterest(hrp, obj.Parent, 0)
        task.wait()
        firetouchinterest(hrp, obj.Parent, 1)
    end
end

-- ระบบลูปเก็บของ (ใช้ Logic ที่พี่ให้มา)
task.spawn(function()
    while true do
        if autoCollect then
            -- สแกนหาไอเทมตามที่พี่กำหนด
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
            if b:IsA("TextButton") then
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
