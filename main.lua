--[[
    UI NAME: Nattawut-Ch (Anti-Spam Edition)
    VERSION: 5.1 (Final Logic | Draggable Home | No Spam Notify)
]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ล้าง UI เก่า
if CoreGui:FindFirstChild("Nattawut_UI_v4") then 
    CoreGui.Nattawut_UI_v4:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nattawut_UI_v4"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- [[ 1. Anti-Spam Notification System (Logic: Wait for finish) ]] --
local isNotifying = false -- ตัวแปรเช็คสถานะว่ามีแจ้งเตือนค้างอยู่ไหม

local function playNotify(tabName)
    if isNotifying then return end -- ถ้ากำลังแจ้งเตือนอยู่ ให้กั้นไว้ห้ามขึ้นซ้ำ (ห้ามสแปม)
    
    isNotifying = true -- ล็อคสถานะ
    
    local messages = {
        ["Gameplay"] = "⚔️ COMBAT READY",
        ["Macro"] = "⚙️ MACRO ACTIVE",
        ["Summon"] = "🔮 SUMMONING",
        ["Settings"] = "🔧 CONFIGURATION"
    }

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 200, 0, 40)
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
