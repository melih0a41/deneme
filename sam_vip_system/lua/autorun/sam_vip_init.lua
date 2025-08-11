-- SAM VIP Yönetim Sistemi - Ana Yükleyici
-- lua/autorun/sam_vip_init.lua

local VERSION = "2.0.1"
local BUILD_DATE = "2024"

print("=====================================")
print(" SAM VIP Yönetim Sistemi v" .. VERSION)
print(" Build: " .. BUILD_DATE)
print("=====================================")

-- VIP_RANKS global değişkeni olarak tanımla
VIP_RANKS = {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

if SERVER then
    print("[SAM VIP] Server dosyaları yükleniyor...")
    
    -- Server dosyalarını yükle
    include("sam_vip_system/sv_sam_vip.lua")
    
    -- Client dosyalarını client'a gönder
    AddCSLuaFile("sam_vip_system/cl_sam_vip.lua")
    AddCSLuaFile("sam_vip_system/cl_sam_vip_menu.lua")
    AddCSLuaFile("sam_vip_system/cl_sam_vip_packages.lua")
    
    -- Global değişkeni client'a gönder
    AddCSLuaFile("autorun/sam_vip_init.lua")
    
    -- Duyuru sistemini client'a gönder
    AddCSLuaFile("autorun/client/vip_announcement_cl.lua")
    
    print("[SAM VIP] Server dosyaları yüklendi.")
    
    -- Veritabanı temizliği
    hook.Add("Initialize", "SAM_VIP_Cleanup", function()
        timer.Simple(5, function()
            -- Süresi dolmuş VIP'leri temizle
            local expired = sql.Query([[
                SELECT steamid FROM sam_players 
                WHERE rank LIKE '%vip%' 
                AND expiry_date > 0 
                AND expiry_date < ]] .. os.time()
            )
            
            if expired then
                for _, row in ipairs(expired) do
                    sql.Query("UPDATE sam_players SET rank = 'user' WHERE steamid = " .. sql.SQLStr(row.steamid))
                end
                print("[SAM VIP] " .. #expired .. " adet süresi dolmuş VIP temizlendi.")
            end
        end)
    end)
    
else -- CLIENT
    print("[SAM VIP] Client dosyaları yükleniyor...")
    
    -- Client dosyalarını yükle
    timer.Simple(0.5, function()
        include("sam_vip_system/cl_sam_vip.lua")
        include("sam_vip_system/cl_sam_vip_menu.lua")
        include("sam_vip_system/cl_sam_vip_packages.lua")
        
        print("[SAM VIP] Client dosyaları yüklendi.")
    end)
end

-- Paylaşılan komutlar
if CLIENT then
    -- Hızlı erişim tuşu (F7)
    hook.Add("Think", "SAM_VIP_Hotkey", function()
        if input.IsKeyDown(KEY_F7) and not SAM_VIP_F7_PRESSED then
            SAM_VIP_F7_PRESSED = true
            
            if LocalPlayer():IsSuperAdmin() then
                RunConsoleCommand("say", "!vipmenu")
            else
                RunConsoleCommand("say", "!vip")
            end
        elseif not input.IsKeyDown(KEY_F7) then
            SAM_VIP_F7_PRESSED = false
        end
    end)
end

-- Başarılı yükleme mesajı
print("[SAM VIP] Sistem başarıyla yüklendi!")
print("[SAM VIP] Komutlar:")
print("  !vip - VIP paketlerini görüntüle")
print("  !vipmenu - VIP yönetim paneli (admin)")
print("  F7 - Hızlı erişim tuşu")
print("=====================================")

-- Server tarafında hoş geldin mesajı
if SERVER then
    hook.Add("PlayerInitialSpawn", "SAM_VIP_Welcome", function(ply)
        timer.Simple(5, function()
            if IsValid(ply) then
                local userGroup = ply:GetUserGroup()
                for _, rank in ipairs(VIP_RANKS) do
                    if userGroup == rank.id then
                        ply:ChatPrint("════════════════════════════")
                        ply:ChatPrint("Hoş geldiniz " .. rank.name .. "!")
                        
                        local expiry = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(ply:SteamID()))
                        if expiry and tonumber(expiry) > 0 then
                            local remaining = tonumber(expiry) - os.time()
                            if remaining > 0 then
                                local days = math.floor(remaining / 86400)
                                ply:ChatPrint("VIP süreniz: " .. days .. " gün kaldı")
                            end
                        else
                            ply:ChatPrint("VIP süreniz: Kalıcı")
                        end
                        
                        ply:ChatPrint("F7 tuşu ile VIP menüsüne erişebilirsiniz")
                        ply:ChatPrint("════════════════════════════")
                        break
                    end
                end
            end
        end)
    end)
end