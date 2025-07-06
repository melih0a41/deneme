-- DarkRP AFK Demote System
-- Bu dosyayı: garrysmod/addons/afk_demote_system/lua/autorun/afk_demote_init.lua olarak kaydedin

if SERVER then
    AddCSLuaFile("afk_demote/cl_afk_demote.lua")
    
    -- DarkRP yüklendikten sonra sistemi başlat
    hook.Add("DarkRPFinishedLoading", "AFKDemote.Init", function()
        include("afk_demote/sv_afk_demote.lua")
    end)
    
    -- Eğer DarkRP zaten yüklüyse direkt yükle
    if DarkRP and GAMEMODE and GAMEMODE.DarkRP then
        include("afk_demote/sv_afk_demote.lua")
    end
else
    include("afk_demote/cl_afk_demote.lua")
end