-- [[ NATTAWUT HUB : THE BRAIN ENGINE ]]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = _G.NattawutHub.Config
local Data = _G.NattawutHub.Data

-- สร้างโฟลเดอร์เก็บมาโครถ้ายังไม่มี
if not isfolder(Config.Folder) then makefolder(Config.Folder) end

-- [[ 🎮 1. AUTO SKILL SYSTEM ]]
task.spawn(function()
    while true do
        if Config.AutoSkill then
            pcall(function()
                local towers = workspace:FindFirstChild("placedTowers")
                if towers then
                    for _, t in ipairs(towers:GetChildren()) do
                        -- ส่งคำสั่งสกิล (Buffer Mode กันแดง)
                        ReplicatedStorage.sync.sync_RELIABLE:FireServer(buffer.fromstring("\000+\000" .. t.Name .. "\001\000"), {})
                    end
                end
            end)
        end
        task.wait(0.5) -- ปรับดีเลย์ตามความเหมาะสม
    end
end)

-- [[ 🛡️ 2. MACRO ENGINE (HOOK SYSTEM) ]]
local StartTime = tick()
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and Config.IsRecording then
        -- ดักจับเฉพาะ Remote ที่เกี่ยวกับการวางและสกิล
        if self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE" then
            local now = tick()
            table.insert(Data.MacroData, {
                Remote = self.Name,
                BufferStr = typeof(args[1]) == "buffer" and buffer.tostring(args[1]) or tostring(args[1]),
                Delay = (#Data.MacroData == 0) and 0 or (now - StartTime)
            })
            StartTime = now
            
            -- อัปเดตตัวเลขใน UI
            if _G.NattawutHub.ActionLabel then
                pcall(function() _G.NattawutHub.ActionLabel:SetTitle(#Data.MacroData .. " Actions Logged") end)
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- [[ ▶️ 3. MACRO PLAYBACK SYSTEM ]]
task.spawn(function()
    while true do
        if Config.IsPlaying then
            -- สมมติว่าเลือกไฟล์จาก Dropdown แล้ว (พี่ต้องเพิ่มระบบเซฟ/โหลดไฟล์ใน ui.lua)
            if #Data.MacroData > 0 then
                for _, act in ipairs(Data.MacroData) do
                    if not Config.IsPlaying then break end
                    task.wait(act.Delay)
                    pcall(function()
                        ReplicatedStorage.sync[act.Remote]:FireServer(buffer.fromstring(act.BufferStr), {})
                    end)
                end
            end
            Config.IsPlaying = false -- เล่นจบแล้วปิด Toggle
        end
        task.wait(0.1)
    end
end)

print("🧠 Logic Engine: Connected and Listening to UI!")
return true
