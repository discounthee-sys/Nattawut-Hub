-- [[ NATTAWUT HUB - LOGIC ENGINE ]]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not isfolder(_G.NattawutConfig.Folder) then makefolder(_G.NattawutConfig.Folder) end

-- [[ ⏺️ MACRO HOOK SYSTEM ]]
local StartTime = 0
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and _G.NattawutConfig.IsRecording then
        if self.Name == "sync_RELIABLE" or self.Name == "towers_RELIABLE" then
            local now = tick()
            table.insert(_G.NattawutConfig.MacroData, {
                Remote = self.Name,
                BufferStr = tostring(args[1]),
                Delay = (#_G.NattawutConfig.MacroData == 0) and 0 or (now - StartTime)
            })
            StartTime = now
            if _G.ActionLabel then _G.ActionLabel:SetTitle(#_G.NattawutConfig.MacroData .. " Actions Logged") end
        end
    end
    return OldNamecall(self, ...)
end)

-- [[ 🎮 AUTO SKILL LOGIC ]]
task.spawn(function()
    while true do
        if _G.NattawutConfig.AutoSkill then
            pcall(function()
                local folder = workspace:FindFirstChild("placedTowers")
                if folder then
                    for _, tower in ipairs(folder:GetChildren()) do
                        ReplicatedStorage.sync.sync_RELIABLE:FireServer(buffer.fromstring("\000+\000" .. tower.Name .. "\001\000"), {})
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

print("✅ Nattawut Logic Loaded Successfully!")
