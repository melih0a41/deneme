-- SAM VIP Yönetim Sistemi - Ana Yükleyici
-- lua/autorun/sam_vip_init.lua

-- VIP_RANKS global değişkeni olarak tanımla
VIP_RANKS = {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

if SERVER then
    -- Server dosyalarını yükle
    include("sam_vip_system/sv_sam_vip.lua")
    
    -- Client dosyalarını client'a gönder
    AddCSLuaFile("sam_vip_system/cl_sam_vip.lua")
    AddCSLuaFile("sam_vip_system/cl_sam_vip_menu.lua")
    AddCSLuaFile("sam_vip_system/cl_sam_vip_packages.lua")
    
    -- Global değişkeni client'a gönder
    AddCSLuaFile("autorun/sam_vip_init.lua")
else
    -- Client dosyalarını sırayla yükle
    timer.Simple(0.1, function()
        include("sam_vip_system/cl_sam_vip.lua")
        include("sam_vip_system/cl_sam_vip_menu.lua")
        include("sam_vip_system/cl_sam_vip_packages.lua")
    end)
end

print("[SAM VIP Sistemi] Başarıyla yüklendi!")
print("[SAM VIP Sistemi] Komutlar: !vipmenu, !vipver, !vipuzat, !vipkaldir, !vipyukselt")