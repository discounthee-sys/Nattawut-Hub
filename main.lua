-- FINAL (ไม่มี Auto-Return) สำหรับ P' Lam — วางแล้วรันได้ทันที
-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Teleport positions (จากพี่)
local TP_POINTS = {
    ["สถานที่ 1"] = Vector3.new(683.61, 3040.14, -1753.22),
    ["สถานที่ 2"] = Vector3.new(751.34, 3033.49, -1576.00),
    ["สถานที่ 3"] = Vector3.new(710.85, 3033.63, -1393.17),
    ["สถานที่ 4"] = Vector3.new(766.19, 4134.76, -17420.10),
    ["สถานที่ 5"] = Vector3.new(768.69, 2819.81, 9828.04),
    ["สถานที่ 6"] = Vector3.new(381.30, 2983.88, 15830.59),
}

-- Asset IDs
local SPLASH_ID = "rbxassetid://98294806019489"
local CAT_ICON_ID = "rbxassetid://129032539718649"

-- Helper: get HumanoidRootPart safely
local function getHRP()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5) 
    end
    return nil
end

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
local uiVisible = true
OpenBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    -- ลูปหา ScreenGui ของ Library แล้วสั่ง Enabled (หลายชื่อ fallback)
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:lower():find("lates") or v.Name:lower():find("window") or v.Name:lower():find("lib")) then
            v.Enabled = uiVisible
        end
    end
end)

-- =========================
-- ใส่รูป (Cat) บนหน้าต่าง Library — ไม่แก้โครงหลัก แค่เพิ่ม ImageLabel ไว้ใน Window object (หาโดยเผื่อชื่อ)
-- =========================
task.spawn(function()
    task.wait(0.7) -- รอให้ Library สร้าง UI เสร็จ
    local foundGui = nil
    -- หา ScreenGui ที่น่าจะเป็น library (fallback หลายแบบ)
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g:IsA("ScreenGui") then
            local name = g.Name:lower()
            if name:find("lates") or name:find("lytes") or name:find("window") or name:find("library") or name:find("ui") then
                foundGui = g
                break
            end
        end
    end

    if not foundGui then
        -- ถ้าไม่เจอ ให้สร้าง Image ใน CoreGui (จะลอยอยู่) เพื่อให้พี่เห็นก่อน
        local floatImg = Instance.new("ImageLabel")
        floatImg.Name = "PLam_CatFloat"
        floatImg.Parent = CoreGui
        floatImg.Size = UDim2.new(0, 120, 0, 120)
        floatImg.Position = UDim2.new(0.5, -60, 0.06, 0)
        floatImg.BackgroundTransparency = 1
        floatImg.Image = CAT_ICON_ID
        local c = Instance.new("UICorner", floatImg); c.CornerRadius = UDim.new(0,18)
        return
    end

    -- หา Frame หลักของ Window (ค้นหา descendant ที่น่าจะเป็น container)
    local mainFrame = foundGui:FindFirstChildWhichIsA("Frame", true) or foundGui:FindFirstChild("Window") or foundGui:FindFirstChildWhichIsA("Frame")
    if not mainFrame then
        return
    end

    local img = Instance.new("ImageLabel")
    img.Name = "PLam_CatHeader"
    img.Parent = mainFrame
    img.Size = UDim2.new(0, 110, 0, 110)
    img.Position = UDim2.new(0.5, -55, 0, -80) -- อยู่บนเหนือหน้าต่าง
    img.BackgroundTransparency = 1
    img.Image = CAT_ICON_ID
    img.ScaleType = Enum.ScaleType.Fit
    local u = Instance.new("UICorner", img); u.CornerRadius = UDim.new(0,18)
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
