--// Services
local UIS = game:GetService("UserInputService")

--// UI เล็ก (Toggle)
local smallIcon = "rbxassetid://100401819662162"
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Toggle = Instance.new("ImageButton", ScreenGui)
Toggle.Image = smallIcon
Toggle.Size = UDim2.new(0, 70, 0, 70)
Toggle.Position = UDim2.new(0, 20, 0, 200)
Toggle.BackgroundTransparency = 0.2
Toggle.BackgroundColor3 = Color3.fromRGB(25,25,25)
local ToggleCorner = Instance.new("UICorner", Toggle)
ToggleCorner.CornerRadius = UDim.new(0,16)

-- ให้ UI เล็กลากได้
local draggingBtn = false
local dragStartBtn, startPosBtn
Toggle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingBtn = true
		dragStartBtn = input.Position
		startPosBtn = Toggle.Position
	end
end)
Toggle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingBtn = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingBtn and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartBtn
		Toggle.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X,
			startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
	end
end)

--------------------------------------------------------------------
-- UI ใหญ่ (แนวนอน + รูปพื้นหลัง)
--------------------------------------------------------------------
local MainUI = Instance.new("Frame", ScreenGui)
MainUI.Size = UDim2.new(0, 600, 0, 280)
MainUI.Position = UDim2.new(0.5, -300, 0.5, -140)
MainUI.BackgroundTransparency = 0
MainUI.Visible = false
MainUI.ClipsDescendants = true

local BG = Instance.new("ImageLabel", MainUI)
BG.Image = "rbxassetid://82760345395309"
BG.Size = UDim2.new(1,0,1,0)
BG.BackgroundTransparency = 0
BG.ScaleType = Enum.ScaleType.Stretch
local BGCorner = Instance.new("UICorner", BG)
BGCorner.CornerRadius = UDim.new(0,14)

-- กรอบ Menu ด้านซ้าย
local MenuFrame = Instance.new("Frame", MainUI)
MenuFrame.Size = UDim2.new(0,120,1,0)
MenuFrame.Position = UDim2.new(0,0,0,0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(50,120,220)
MenuFrame.BackgroundTransparency = 0.4
local MenuCorner = Instance.new("UICorner", MenuFrame)
MenuCorner.CornerRadius = UDim.new(0,8)

-- พื้นที่ฟังก์ชันด้านขวา + ListLayout
local FuncFrame = Instance.new("Frame", MainUI)
FuncFrame.Size = UDim2.new(1,-120,1,0)
FuncFrame.Position = UDim2.new(0,120,0,0)
FuncFrame.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", FuncFrame)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0,5)

-- UI ใหญ่ลากได้
local Drag = Instance.new("Frame", MainUI)
Drag.Size = UDim2.new(1,0,0,35)
Drag.BackgroundTransparency = 1
local draggingUI = false
local dragStartUI, startPosUI
Drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingUI = true
		dragStartUI = input.Position
		startPosUI = MainUI.Position
	end
end)
Drag.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingUI = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartUI
		MainUI.Position = UDim2.new(startPosUI.X.Scale, startPosUI.X.Offset + delta.X,
			startPosUI.Y.Scale, startPosUI.Y.Offset + delta.Y)
	end
end)

--------------------------------------------------------------------
-- Toggle เล็กเปิด–ปิด UI ใหญ่
--------------------------------------------------------------------
local canClick = true
Toggle.MouseButton1Click:Connect(function()
	if not canClick then return end
	canClick = false
	MainUI.Visible = not MainUI.Visible
	task.delay(0.25, function() canClick = true end)
end)

--------------------------------------------------------------------
-- ฟังก์ชันเพิ่มเมนู
--------------------------------------------------------------------
local menuCount = 0
local function addMenu(name, funcs)
	menuCount = menuCount + 1
	local Btn = Instance.new("TextButton", MenuFrame)
	Btn.Size = UDim2.new(1,0,0,35)
	Btn.Position = UDim2.new(0,0,(menuCount-1)*35,0)
	Btn.Text = name
	Btn.BackgroundTransparency = 1
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 18

	Btn.MouseButton1Click:Connect(function()
		-- เคลียร์ฟังก์ชันเก่า
		for i,v in ipairs(FuncFrame:GetChildren()) do
			if v:IsA("TextButton") then v:Destroy() end
		end
		-- เพิ่มฟังก์ชันใหม่
		for i,f in ipairs(funcs) do
			local FBtn = Instance.new("TextButton", FuncFrame)
			FBtn.Size = UDim2.new(1,0,0,35)
			FBtn.BackgroundColor3 = Color3.fromRGB(80,180,255)
			FBtn.BackgroundTransparency = 0.3
			FBtn.TextColor3 = Color3.fromRGB(255,255,255)
			FBtn.Font = Enum.Font.Gotham
			FBtn.TextSize = 16
			FBtn.Text = f
		end
	end)
end

-- ตัวอย่างเมนู
addMenu("Mumu", {"ออโต้ฟาร์ม","ปุ่มปิดปิด","อื่นๆ"})
addMenu("Test", {"ฟังก์ชันทดสอบ1","ฟังก์ชันทดสอบ2"})    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40,0,30)
    btn.Position = UDim2.new(0,20,0,yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    btn.Parent = MainFrame

    btn.MouseButton1Click:Connect(function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(vec) end
    end)
    yOffset = yOffset + 40
end

-- Speed Button
local speedOn = false
local defaultSpeed = 16
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40,0,30)
speedBtn.Position = UDim2.new(0,20,0,yOffset)
speedBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.TextSize = 18
speedBtn.Text = "Speed"
speedBtn.Parent = MainFrame

speedBtn.MouseButton1Click:Connect(function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or getHumanoid()
    if humanoid then
        if speedOn then
            humanoid.WalkSpeed = defaultSpeed
        else
            humanoid.WalkSpeed = 30
        end
        speedOn = not speedOn
    end
end)

yOffset = yOffset + 40

-- Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40,0,30)
flyBtn.Position = UDim2.new(0,20,0,yOffset)
flyBtn.BackgroundColor3 = Color3.fromRGB(255,85,0)
flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 18
flyBtn.Text = "Fly"
flyBtn.Parent = MainFrame

flyBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)FloatGui.Name = "PLam_MainUI"
FloatGui.ResetOnSpawn = false
FloatGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,400,0,480)
MainFrame.Position = UDim2.new(0.5,-200,0.5,-240)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = FloatGui

local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0,18)

-- =====================
-- Float Button
-- =====================
local FloatBtn = Instance.new("ImageButton")
FloatBtn.Size = UDim2.new(0,64,0,64)
FloatBtn.Position = UDim2.new(0.05,0,0.5,-32)
FloatBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
FloatBtn.BackgroundTransparency = 0
FloatBtn.Image = UI_BTN_ID
FloatBtn.ScaleType = Enum.ScaleType.Fit
FloatBtn.AutoButtonColor = true
FloatBtn.Parent = FloatGui

local btnCorner = Instance.new("UICorner", FloatBtn)
btnCorner.CornerRadius = UDim.new(0,10)

local dragging, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
    end
end)
FloatBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragging then dragging = false end
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- =====================
-- Warp Buttons เรียง
-- =====================
local yOffset = 20
for i = 1, #TP_ORDER do
    local name, vec = TP_ORDER[i][1], TP_ORDER[i][2]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40, 0,30)
    btn.Position = UDim2.new(0,20,0,yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 18
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,10)

    btn.MouseButton1Click:Connect(function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(vec)
        end
    end)

    yOffset = yOffset + 40
end

-- =====================
-- Speed & Fly Buttons
-- =====================
local speedOn = false
local defaultSpeed = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40, 0,30)
speedBtn.Position = UDim2.new(0,20,0,yOffset)
speedBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.TextSize = 18
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.Text = "Speed"
speedBtn.Parent = MainFrame
local corner = Instance.new("UICorner", speedBtn)
corner.CornerRadius = UDim.new(0,10)

speedBtn.MouseButton1Click:Connect(function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if not speedOn then
            humanoid.WalkSpeed = 30
            speedOn = true
        else
            humanoid.WalkSpeed = defaultSpeed
            speedOn = false
        end
    end
end)

yOffset = yOffset + 40

-- Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, MainFrame.Size.X.Offset-40, 0,30)
flyBtn.Position = UDim2.new(0,20,0,yOffset)
flyBtn.BackgroundColor3 = Color3.fromRGB(255,85,0)
flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
flyBtn.TextSize = 18
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.Text = "Fly"
flyBtn.Parent = MainFrame
local corner2 = Instance.new("UICorner", flyBtn)
corner2.CornerRadius = UDim.new(0,10)

flyBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)
-- =========================
-- Intro Splash (fullscreen, hold, fade)
-- =========================
do
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "PLam_Intro"
    IntroGui.ResetOnSpawn = false
    IntroGui.Parent = CoreGui

    local Img = Instance.new("ImageLabel", IntroGui)
    Img.Size = UDim2.new(1,0,1,0)
    Img.Position = UDim2.new(0,0,0,0)
    Img.BackgroundTransparency = 1
    Img.Image = SPLASH_ID
    Img.ScaleType = Enum.ScaleType.Fit
    Img.ImageTransparency = 0

    task.wait(3)

    local steps = 40
    for i = 1, steps do
        Img.ImageTransparency = i/steps
        task.wait(0.02)
    end

    IntroGui:Destroy()
end

-- =========================
-- ปุ่ม Open/Close UI
-- =========================
local OpenGui = Instance.new("ScreenGui")
OpenGui.Name = "PLam_OpenBtnGui"
OpenGui.ResetOnSpawn = false
OpenGui.Parent = CoreGui

local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "PLam_OpenBtn"
OpenBtn.Parent = OpenGui
OpenBtn.Size = UDim2.new(0,64,0,64)
OpenBtn.Position = UDim2.new(0.04,0,0.5,-32)
OpenBtn.BackgroundTransparency = 0
OpenBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
OpenBtn.Image = "" -- ว่างเพราะ Cat ไปไว้ใน UI
OpenBtn.AutoButtonColor = true

local corner = Instance.new("UICorner", OpenBtn)
corner.CornerRadius = UDim.new(0,14)

-- Dragging logic
local dragging, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
    end
end)

-- =========================
-- Load Library (Lates)
-- =========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()
local Window = Library:CreateWindow({
    Title = "P' Lam Hub",
    Theme = "Dark",
    Size = UDim2.fromOffset(570,370),
    Transparency = 0.15,
    Blurring = false,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

-- =========================
-- Toggle UI
-- =========================
local uiVisible = true
OpenBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    local foundGui = nil
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name:find("Lates") then
            foundGui = g
            break
        end
    end
    if foundGui then
        foundGui.Enabled = uiVisible
    end
end)

-- =========================
-- ใส่รูป Cat ใน Library UI
-- =========================
task.spawn(function()
    task.wait(0.7)
    local foundGui = nil
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name:find("Lates") then
            foundGui = g
            break
        end
    end
    if not foundGui then return end

    local mainFrame = foundGui:FindFirstChildWhichIsA("Frame", true) or foundGui:FindFirstChild("Window")
    if not mainFrame then return end

    local img = Instance.new("ImageLabel")
    img.Name = "PLam_CatHeader"
    img.Parent = mainFrame
    img.Size = UDim2.new(0,110,0,110)
    img.Position = UDim2.new(0.5,-55,0,-80)
    img.BackgroundTransparency = 1
    img.Image = CAT_ICON_ID
    img.ScaleType = Enum.ScaleType.Fit
    local u = Instance.new("UICorner", img)
    u.CornerRadius = UDim.new(0,18)
end)

-- =========================
-- TAB: Main + ปุ่มวาร์ป 6 จุด
-- =========================
local Main = Window:AddTab({
    Title = "Main",
    Section = "Main",
    Icon = "rbxassetid://11963373994"
})

local function doTeleportTo(vec)
    local hrp = getHRP()
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(vec)
        end)
    else
        pcall(function()
            LocalPlayer:Kick("Teleport failed: character not ready.")
        end)
    end
end

for name, vec in pairs(TP_POINTS) do
    Window:AddButton({
        Title = name,
        Description = "Warp to location",
        Tab = Main,
        Callback = function()
            doTeleportTo(vec)
        end
    })
end    IntroGui.Name = "PLam_Intro"
    IntroGui.ResetOnSpawn = false
    IntroGui.Parent = CoreGui

    local Img = Instance.new("ImageLabel", IntroGui)
    Img.Size = UDim2.new(1,0,1,0)
    Img.Position = UDim2.new(0,0,0,0)
    Img.BackgroundTransparency = 1
    Img.Image = SPLASH_ID
    Img.ScaleType = Enum.ScaleType.Fit
    Img.ImageTransparency = 0

    -- เวลาค้างบนจอ (ปรับได้)
    task.wait(3) -- อยู่ 3 วินาที

    -- fade out
    local steps = 40
    for i = 1, steps do
        Img.ImageTransparency = i/steps
        task.wait(0.02)
    end

    IntroGui:Destroy()
end

-- =========================
-- Draggable Open Button (รูป Cat) — ลากได้ และเปิด/ปิด UI
-- =========================
local OpenGui = Instance.new("ScreenGui")
OpenGui.Name = "PLam_OpenBtnGui"
OpenGui.ResetOnSpawn = false
OpenGui.Parent = CoreGui

local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "PLam_OpenBtn"
OpenBtn.Parent = OpenGui
OpenBtn.Size = UDim2.new(0, 64, 0, 64)
OpenBtn.Position = UDim2.new(0.04, 0, 0.5, -32)
OpenBtn.AnchorPoint = Vector2.new(0,0)
OpenBtn.BackgroundTransparency = 0
OpenBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
OpenBtn.Image = CAT_ICON_ID
OpenBtn.ScaleType = Enum.ScaleType.Fit
OpenBtn.AutoButtonColor = true

local corner = Instance.new("UICorner", OpenBtn)
corner.CornerRadius = UDim.new(0, 14)

-- Dragging logic
local dragging, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
    end
end)

-- =========================
-- Load Lates Library Window (ไม่เปลี่ยน UI หลักของพี่)
-- =========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"))()
local Window = Library:CreateWindow({
    Title = "P' Lam Hub",
    Theme = "Dark",
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.15,
    Blurring = false,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

Window:SetTheme({
    Primary = Color3.fromRGB(30,30,30),
    Secondary = Color3.fromRGB(35,35,35),
    Component = Color3.fromRGB(40,40,40),
    Interactables = Color3.fromRGB(45,45,45),
    Tab = Color3.fromRGB(200,200,200),
    Title = Color3.fromRGB(240,240,240),
    Description = Color3.fromRGB(200,200,200),
    Shadow = Color3.fromRGB(0,0,0),
    Outline = Color3.fromRGB(40,40,40),
    Icon = Color3.fromRGB(220,220,220),
})

-- Toggle UI: เมื่อกดปุ่ม Cat จะเปิด/ปิดหน้าต่างที่สร้างโดย Library
local uiVisible = end
OpenBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    -- ลูปหา ScreenGui ของ Library แล้วสั่ง Enabled (หลายชื่อ fallback)
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:lower():find("lates") or v.Name:lower():find("window") or v.Name:lower():find("lib")) then
            v.Enabled = uiVisible
        end
    end
end)

-- TAB: Main + ปุ่มวาร์ป 6 จุด
-- =========================
local Main = Window:AddTab({
    Title = "Main",
    Section = "Main",
    Icon = "rbxassetid://11963373994"
})

local function doTeleportTo(vec)
    local hrp = getHRP()
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(vec)
        end)
    else
        -- ถ้ายังไม่มีตัว ให้บอกผู้เล่น
        pcall(function()
            LocalPlayer:Kick("Teleport failed: character not ready.")
        end)
    end
end

for name, vec in pairs(TP_POINTS) do
    Window:AddButton({
        Title = name,
        Description = "Warp to location",
        Tab = Main,
        Callback = function()
            doTeleportTo(vec)
        end
    })
end

-- =========================
-- Note:
-- - โค้ดนี้ไม่มีระบบ Auto-Return (ที่พี่ขอเอาออก)
-- - ถ้าต้องการให้ผมเพิ่ม "บันทึกตำแหน่งขณะใช้งาน" หรือ "ปุ่มแก้ชื่อ" บอกได้เลย
-- =========================
