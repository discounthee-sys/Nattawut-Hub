-- [[ NATTAWUT HUB : THE ULTIMATE LOADER ]]
print("🚀 Nattawut Hub: Initializing Components...")

-- 1. สร้างตารางกลาง (Global Table) เชื่อมทุกไฟล์เข้าด้วยกัน
_G.NattawutHub = {
    Version = "2.1.0",
    Config = {
        AutoSkill = false,
        IsRecording = false,
        IsPlaying = false,
        Folder = "NattawutHub_Macros"
    },
    Data = {
        MacroData = {}
    }
}

-- 2. ฟังก์ชันโหลดไฟล์จาก GitHub
local function LoadComponent(fileName)
    local url = "https://raw.githubusercontent.com/discounthee-sys/Nattawut-Hub/main/" .. fileName .. ".lua"
    local success, content = pcall(game.HttpGet, game, url)
    if success and content then
        local func, err = loadstring(content)
        if func then
            return func()
        else
            warn("❌ Script Error in " .. fileName .. ": " .. tostring(err))
        end
    else
        warn("⚠️ Connection Error: Could not fetch " .. fileName)
    end
end

-- 3. เริ่มการประกอบ (ลำดับ: โหลด UI ก่อน แล้วตามด้วย Logic)
LoadComponent("ui")    -- เรียกหน้ากากมาแสดง
LoadComponent("logic") -- เรียกสมองมาสั่งงาน

print("🔥 Nattawut Hub: Engine Started SucceNattawut-Hubb
