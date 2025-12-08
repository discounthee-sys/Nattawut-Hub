--// Services
local UIS = game:GetService("UserInputService")

--// Assets
local smallIcon = "rbxassetid://100401819662162"
local bigBG = "rbxassetid://82760345395309"

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

--------------------------------------------------------------------
-- UI เล็ก (Toggle)
--------------------------------------------------------------------
local Toggle = Instance.new("ImageButton", ScreenGui)
Toggle.Image = smallIcon
Toggle.Size = UDim2.new(0, 70, 0, 70)
Toggle.Position = UDim2.new(0, 20, 0, 200)
Toggle.BackgroundTransparency = 0.2
Toggle.BackgroundColor3 = Color3.fromRGB(25,25,25)
local ToggleCorner = Instance.new("UICorner", Toggle)
ToggleCorner.CornerRadius = UDim.new(0,16)

-- Drag UI เล็ก
local draggingBtn, dragStartBtn, startPosBtn = false, nil, nil
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
-- UI ใหญ่หลัก (MainUI)
--------------------------------------------------------------------
local MainUI = Instance.new("Frame", ScreenGui)
MainUI.Size = UDim2.new(0, 600, 0, 350)
MainUI.Position = UDim2.new(0.5, -300, 0.5, -175)
MainUI.BackgroundTransparency = 0
MainUI.Visible = false
MainUI.ClipsDescendants = true

local BG = Instance.new("ImageLabel", MainUI)
BG.Image = bigBG
BG.Size = UDim2.new(1,0,1,0)
BG.BackgroundTransparency = 0
BG.ScaleType = Enum.ScaleType.Stretch
local BGCorner = Instance.new("UICorner", BG)
BGCorner.CornerRadius = UDim.new(0,14)

-- Drag UI ใหญ่
local Drag = Instance.new("Frame", MainUI)
Drag.Size = UDim2.new(1,0,0,35)
Drag.BackgroundTransparency = 1
local draggingUI, dragStartUI, startPosUI = false, nil, nil
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
-- Toggle UI เล็กเปิด/ปิด MainUI
--------------------------------------------------------------------
local canClick = true
Toggle.MouseButton1Click:Connect(function()
	if not canClick then return end
	canClick = false

	MainUI.Visible = not MainUI.Visible

	task.delay(0.25, function()
		canClick = true
	end)
end)

--------------------------------------------------------------------
-- ตัวเลือกปุ่มใน MainUI
--------------------------------------------------------------------
local OptionsFrame = Instance.new("Frame", MainUI)
OptionsFrame.Size = UDim2.new(1, -20, 1, -50)
OptionsFrame.Position = UDim2.new(0,10,0,40)
OptionsFrame.BackgroundTransparency = 1

local OptionBtn = Instance.new("TextButton", OptionsFrame)
OptionBtn.Size = UDim2.new(0, 120, 0, 40)
OptionBtn.Position = UDim2.new(0, 10, 0, 10)
OptionBtn.Text = "ไปหน้า SubUI"
OptionBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
local OptionCorner = Instance.new("UICorner", OptionBtn)
OptionCorner.CornerRadius = UDim.new(0,8)

--------------------------------------------------------------------
-- SubUI (เท่ากับ MainUI แต่สีขาว)
--------------------------------------------------------------------
local SubUI = Instance.new("Frame", ScreenGui)
SubUI.Size = MainUI.Size
SubUI.Position = MainUI.Position
SubUI.BackgroundColor3 = Color3.fromRGB(255,255,255)
SubUI.Visible = false
SubUI.ClipsDescendants = true

-- Drag SubUI
local SubDrag = Instance.new("Frame", SubUI)
SubDrag.Size = UDim2.new(1,0,0,35)
SubDrag.BackgroundTransparency = 1
local draggingSub, dragStartSub, startPosSub = false, nil, nil
SubDrag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSub = true
		dragStartSub = input.Position
		startPosSub = SubUI.Position
	end
end)
SubDrag.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSub = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingSub and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartSub
		SubUI.Position = UDim2.new(startPosSub.X.Scale, startPosSub.X.Offset + delta.X,
			startPosSub.Y.Scale, startPosSub.Y.Offset + delta.Y)
	end
end)

-- ปุ่มย้อนกลับ SubUI -> MainUI
local BackBtn = Instance.new("TextButton", SubUI)
BackBtn.Size = UDim2.new(0, 100, 0, 30)
BackBtn.Position = UDim2.new(0, 10, 0, 10)
BackBtn.Text = "กลับ"
BackBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
local BackCorner = Instance.new("UICorner", BackBtn)
BackCorner.CornerRadius = UDim.new(0,6)

BackBtn.MouseButton1Click:Connect(function()
	SubUI.Visible = false
	MainUI.Visible = true
end)

-- กด OptionBtn -> เปิด SubUI ทับ MainUI
OptionBtn.MouseButton1Click:Connect(function()
	MainUI.Visible = false
	SubUI.Visible = true
end)      task.wait(0.02)
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
