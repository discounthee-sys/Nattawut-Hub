--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local LockedPlayer = nil
local LockEnabled = false
local Connection = nil

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PlayerLockUI"
ScreenGui.ResetOnSpawn = false

--// Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromOffset(260, 180)
Frame.Position = UDim2.fromScale(0.05, 0.3)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

--// Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -35, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Player Lock"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.fromOffset(10,0)

--// Dropdown
local Dropdown = Instance.new("TextButton", Frame)
Dropdown.Position = UDim2.fromOffset(20,50)
Dropdown.Size = UDim2.fromOffset(220,30)
Dropdown.Text = "Select Player"
Dropdown.Font = Enum.Font.Gotham
Dropdown.TextSize = 12
Dropdown.TextColor3 = Color3.new(1,1,1)
Dropdown.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0,8)

--// Player List
local ListFrame = Instance.new("Frame", Frame)
ListFrame.Position = UDim2.fromOffset(20,85)
ListFrame.Size = UDim2.fromOffset(220,0)
ListFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
ListFrame.BorderSizePixel = 0
ListFrame.Visible = false
ListFrame.ClipsDescendants = true
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,8)

local UIListLayout = Instance.new("UIListLayout", ListFrame)
UIListLayout.Padding = UDim.new(0,5)

--// Toggle Lock
local Toggle = Instance.new("TextButton", Frame)
Toggle.Position = UDim2.fromOffset(20,95)
Toggle.Size = UDim2.fromOffset(220,30)
Toggle.Text = "Lock : OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

--// Hide Button
local Close = Instance.new("TextButton", Frame)
Close.Position = UDim2.fromOffset(20,140)
Close.Size = UDim2.fromOffset(220,25)
Close.Text = "Hide UI"
Close.Font = Enum.Font.Gotham
Close.TextSize = 12
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

--// Build Player List
local function buildPlayerList()
	for _,v in pairs(ListFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.fromOffset(220,25)
			btn.Text = plr.Name
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextColor3 = Color3.new(1,1,1)
			btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
			btn.Parent = ListFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

			btn.MouseButton1Click:Connect(function()
				LockedPlayer = plr
				Dropdown.Text = "Target: "..plr.Name
				ListFrame.Visible = false
				ListFrame.Size = UDim2.fromOffset(220,0)
			end)
		end
	end

	task.wait()
	ListFrame.Size = UDim2.fromOffset(220, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- realtime update (เพิ่มอย่างเดียว)
Players.PlayerAdded:Connect(buildPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if LockedPlayer == plr then
		LockedPlayer = nil
		LockEnabled = false
		Dropdown.Text = "Select Player"
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
	end
	buildPlayerList()
end)

Dropdown.MouseButton1Click:Connect(function()
	buildPlayerList()
	ListFrame.Visible = not ListFrame.Visible
end)

--// Lock Logic
local function startLock()
	if Connection then Connection:Disconnect() end
	Connection = RunService.RenderStepped:Connect(function()
		if not LockEnabled or not LockedPlayer then return end

		local char = LocalPlayer.Character
		local targetChar = LockedPlayer.Character
		if char and targetChar then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local thrp = targetChar:FindFirstChild("HumanoidRootPart")
			if hrp and thrp then
				hrp.CFrame = CFrame.new(
					hrp.Position,
					Vector3.new(thrp.Position.X, hrp.Position.Y, thrp.Position.Z)
				)
			end
		end
	end)
end

Toggle.MouseButton1Click:Connect(function()
	LockEnabled = not LockEnabled
	if LockEnabled then
		Toggle.Text = "Lock : ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(40,80,40)
		startLock()
	else
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
		if Connection then Connection:Disconnect() end
	end
end)

--// Hide UI
Close.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

--// Toggle UI Keybind (RightAlt)
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightAlt then
		Frame.Visible = not Frame.Visible
	end
end)FullSize = Frame.Size

--// Title
local Title = Instance.new("TextLabel",Frame)
Title.Size = UDim2.new(1,-35,0,30)
Title.Position = UDim2.fromOffset(10,0)
Title.BackgroundTransparency = 1
Title.Text = "Player Lock"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

--// Minimize Button
local Minimize = Instance.new("TextButton",Frame)
Minimize.Size = UDim2.fromOffset(30,30)
Minimize.Position = UDim2.new(1,-35,0,0)
Minimize.Text = "-"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BackgroundTransparency = 1

--// Dropdown
local Dropdown = Instance.new("TextButton",Frame)
Dropdown.Position = UDim2.fromOffset(20,50)
Dropdown.Size = UDim2.fromOffset(220,30)
Dropdown.Text = "Select Player"
Dropdown.Font = Enum.Font.Gotham
Dropdown.TextSize = 12
Dropdown.TextColor3 = Color3.new(1,1,1)
Dropdown.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner",Dropdown).CornerRadius = UDim.new(0,8)

--// Player List
local ListFrame = Instance.new("Frame",Frame)
ListFrame.Position = UDim2.fromOffset(20,85)
ListFrame.Size = UDim2.fromOffset(220,0)
ListFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
ListFrame.BorderSizePixel = 0
ListFrame.Visible = false
ListFrame.ClipsDescendants = true
Instance.new("UICorner",ListFrame).CornerRadius = UDim.new(0,8)

local UIListLayout = Instance.new("UIListLayout",ListFrame)
UIListLayout.Padding = UDim.new(0,5)

--// Toggle
local Toggle = Instance.new("TextButton",Frame)
Toggle.Position = UDim2.fromOffset(20,95)
Toggle.Size = UDim2.fromOffset(220,30)
Toggle.Text = "Lock : OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
Instance.new("UICorner",Toggle).CornerRadius = UDim.new(0,8)

--// Hide Button
local Close = Instance.new("TextButton",Frame)
Close.Position = UDim2.fromOffset(20,140)
Close.Size = UDim2.fromOffset(220,25)
Close.Text = "Hide UI"
Close.Font = Enum.Font.Gotham
Close.TextSize = 12
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner",Close).CornerRadius = UDim.new(0,8)

--// Build Player List (Realtime)
local function buildPlayerList()
	for _,v in pairs(ListFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.fromOffset(220,25)
			btn.Text = plr.Name
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextColor3 = Color3.new(1,1,1)
			btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
			btn.Parent = ListFrame
			Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

			btn.MouseButton1Click:Connect(function()
				LockedPlayer = plr
				Dropdown.Text = "Target: "..plr.Name
				ListFrame.Visible = false
				ListFrame.Size = UDim2.fromOffset(220,0)
			end)
		end
	end

	task.wait()
	ListFrame.Size = UDim2.fromOffset(220,UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(buildPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if LockedPlayer == plr then
		LockedPlayer = nil
		LockEnabled = false
		Dropdown.Text = "Select Player"
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
	end
	buildPlayerList()
end)

Dropdown.MouseButton1Click:Connect(function()
	buildPlayerList()
	ListFrame.Visible = not ListFrame.Visible
end)

--// Lock Logic
local function startLock()
	if Connection then Connection:Disconnect() end
	Connection = RunService.RenderStepped:Connect(function()
		if not LockEnabled or not LockedPlayer then return end

		local char = LocalPlayer.Character
		local tchar = LockedPlayer.Character
		if char and tchar then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local thrp = tchar:FindFirstChild("HumanoidRootPart")
			if hrp and thrp then
				hrp.CFrame = CFrame.new(
					hrp.Position,
					Vector3.new(thrp.Position.X,hrp.Position.Y,thrp.Position.Z)
				)
			end
		end
	end)
end

Toggle.MouseButton1Click:Connect(function()
	LockEnabled = not LockEnabled
	if LockEnabled then
		Toggle.Text = "Lock : ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(40,80,40)
		startLock()
	else
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
		if Connection then Connection:Disconnect() end
	end
end)

--// Minimize (FIX FUNCTION LOST)
Minimize.MouseButton1Click:Connect(function()
	Minimized = not Minimized

	if Minimized then
		Frame.Size = UDim2.fromOffset(260,30)
		for _,v in pairs(Frame:GetChildren()) do
			if v ~= Title and v ~= Minimize and not v:IsA("UICorner") then
				v.Visible = false
			end
		end
		Minimize.Text = "+"
	else
		Frame.Size = FullSize
		Dropdown.Visible = true
		Toggle.Visible = true
		Close.Visible = true
		ListFrame.Visible = false
		ListFrame.Size = UDim2.fromOffset(220,0)
		Minimize.Text = "-"
	end
end)

--// Hide
Close.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

--// RightAlt Toggle UI
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightAlt then
		Frame.Visible = not Frame.Visible
	end
end)Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

--// Minimize
local Minimize = Instance.new("TextButton", Frame)
Minimize.Size = UDim2.fromOffset(30,30)
Minimize.Position = UDim2.new(1,-35,0,0)
Minimize.Text = "-"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BackgroundTransparency = 1

--// Dropdown
local Dropdown = Instance.new("TextButton", Frame)
Dropdown.Position = UDim2.fromOffset(20,50)
Dropdown.Size = UDim2.fromOffset(220,30)
Dropdown.Text = "Select Player"
Dropdown.Font = Enum.Font.Gotham
Dropdown.TextSize = 12
Dropdown.TextColor3 = Color3.new(1,1,1)
Dropdown.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0,8)

--// Player List
local ListFrame = Instance.new("Frame", Frame)
ListFrame.Position = UDim2.fromOffset(20,85)
ListFrame.Size = UDim2.fromOffset(220,0)
ListFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
ListFrame.BorderSizePixel = 0
ListFrame.Visible = false
ListFrame.ClipsDescendants = true
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,8)

local UIListLayout = Instance.new("UIListLayout", ListFrame)
UIListLayout.Padding = UDim.new(0,5)

--// Toggle Lock
local Toggle = Instance.new("TextButton", Frame)
Toggle.Position = UDim2.fromOffset(20,95)
Toggle.Size = UDim2.fromOffset(220,30)
Toggle.Text = "Lock : OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

--// Hide
local Close = Instance.new("TextButton", Frame)
Close.Position = UDim2.fromOffset(20,140)
Close.Size = UDim2.fromOffset(220,25)
Close.Text = "Hide UI"
Close.Font = Enum.Font.Gotham
Close.TextSize = 12
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

--// Build Player List (Realtime)
local function buildPlayerList()
	for _,v in pairs(ListFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.fromOffset(220,25)
			btn.Text = plr.Name
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextColor3 = Color3.new(1,1,1)
			btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
			btn.Parent = ListFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

			btn.MouseButton1Click:Connect(function()
				LockedPlayer = plr
				Dropdown.Text = "Target: "..plr.Name
				ListFrame.Visible = false
				ListFrame.Size = UDim2.fromOffset(220,0)
			end)
		end
	end

	task.wait()
	ListFrame.Size = UDim2.fromOffset(220, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(buildPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if LockedPlayer == plr then
		LockedPlayer = nil
		LockEnabled = false
		Dropdown.Text = "Select Player"
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
	end
	buildPlayerList()
end)

Dropdown.MouseButton1Click:Connect(function()
	buildPlayerList()
	ListFrame.Visible = not ListFrame.Visible
end)

--// Lock Logic
local function startLock()
	if Connection then Connection:Disconnect() end
	Connection = RunService.RenderStepped:Connect(function()
		if not LockEnabled or not LockedPlayer then return end

		local char = LocalPlayer.Character
		local tchar = LockedPlayer.Character
		if char and tchar then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local thrp = tchar:FindFirstChild("HumanoidRootPart")
			if hrp and thrp then
				hrp.CFrame = CFrame.new(
					hrp.Position,
					Vector3.new(thrp.Position.X, hrp.Position.Y, thrp.Position.Z)
				)
			end
		end
	end)
end

Toggle.MouseButton1Click:Connect(function()
	LockEnabled = not LockEnabled
	if LockEnabled then
		Toggle.Text = "Lock : ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(40,80,40)
		startLock()
	else
		Toggle.Text = "Lock : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(80,40,40)
		if Connection then Connection:Disconnect() end
	end
end)

--// Minimize (Fix Function Loss)
Minimize.MouseButton1Click:Connect(function()
	Minimized = not Minimized

	if Minimized then
		Frame.Size = UDim2.fromOffset(260,30)
		for _,v in pairs(Frame:GetChildren()) do
			if v ~= Title and v ~= Minimize and not v:IsA("UICorner") then
				v.Visible = false
			end
		end
		Minimize.Text = "+"
	else
		Frame.Size = FullSize
		Dropdown.Visible = true
		Toggle.Visible = true
		Close.Visible = true
		ListFrame.Visible = false
		ListFrame.Size = UDim2.fromOffset(220,0)
		Minimize.Text = "-"
	end
end)

--// Hide
Close.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

--// RightAlt Toggle UI
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightAlt then
		Frame.Visible = not Frame.Visible
	end
end)e
	end
end)
