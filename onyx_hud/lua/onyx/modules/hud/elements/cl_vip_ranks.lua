--[[
Author: Modified for VIP ranks
VIP Rank Display System for SAM Admin Mod
Bu dosyayı şu konuma koy: lua/onyx/modules/hud/elements/cl_vip_ranks.lua
--]]

-- VIP rank tanımlamaları (SAM VIP sistemiyle aynı)
onyx.hud.vipRanks = {
    ["bronzvip"] = {
        short = "BVIP",
        color = Color(205, 127, 50), -- Bronz rengi
        priority = 1
    },
    ["silvervip"] = {
        short = "SVIP", 
        color = Color(192, 192, 192), -- Gümüş rengi
        priority = 2
    },
    ["goldvip"] = {
        short = "GVIP",
        color = Color(255, 215, 0), -- Altın rengi
        priority = 3
    },
    ["platinumvip"] = {
        short = "PVIP",
        color = Color(229, 228, 226), -- Platin rengi
        priority = 4
    },
    ["diamondvip"] = {
        short = "DVIP",
        color = Color(185, 242, 255), -- Elmas rengi (açık mavi)
        priority = 5
    }
}

-- Oyuncunun VIP rankını kontrol et
function onyx.hud.GetPlayerVIPRank(ply)
    if not IsValid(ply) then return nil end
    
    -- Standart GetUserGroup ile kontrol et (SAM bunu kullanıyor)
    local userGroup = ply:GetUserGroup()
    
    -- Debug için
    -- print("Player:", ply:Nick(), "UserGroup:", userGroup)
    
    if onyx.hud.vipRanks[userGroup] then
        return userGroup, onyx.hud.vipRanks[userGroup]
    end
    
    return nil
end

-- VIP badge'i çiz
function onyx.hud.DrawVIPBadge(x, y, vipData, font, alignment)
    if not vipData then return 0 end
    
    local text = vipData.short
    local color = vipData.color
    
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)
    
    -- Badge arka planı
    local padding = onyx.hud.ScaleTall(3)
    local badgeW = tw + padding * 2
    local badgeH = th + padding * 1.2
    local badgeX = x
    local badgeY = y - badgeH / 2
    
    -- Alignment ayarla
    if alignment == TEXT_ALIGN_CENTER then
        badgeX = badgeX - badgeW / 2
    elseif alignment == TEXT_ALIGN_RIGHT then
        badgeX = badgeX - badgeW
    end
    
    -- Arka plan kutusu
    draw.RoundedBox(4, badgeX, badgeY, badgeW, badgeH, ColorAlpha(color, 30))
    
    -- Kenarlık
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(badgeX, badgeY, badgeW, badgeH)
    
    -- VIP metni
    draw.SimpleText(text, font, badgeX + badgeW / 2, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    return badgeW + padding
end

-- Debug komutu
concommand.Add("onyx_hud_check_vip", function()
    local ply = LocalPlayer()
    
    print("=== VIP Rank Debug ===")
    print("Oyuncu:", ply:Nick())
    print("SteamID:", ply:SteamID())
    print("UserGroup:", ply:GetUserGroup())
    
    local vipRank, vipData = onyx.hud.GetPlayerVIPRank(ply)
    if vipRank then
        print("VIP Rank:", vipRank)
        print("VIP Short:", vipData.short)
        print("VIP Color:", tostring(vipData.color))
    else
        print("VIP Rank: Yok")
    end
    print("===================")
end)