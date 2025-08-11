-- SAM VIP Yönetim Sistemi - Server Tarafı (STEAM ID SORUNU DÜZELTİLDİ)
-- lua/sam_vip_system/sv_sam_vip.lua

local sam = sam
local command = sam.command

-- VIP paket resimlerini client'a gönder
resource.AddFile("materials/vip_packages/bronze.png")
resource.AddFile("materials/vip_packages/silver.png")
resource.AddFile("materials/vip_packages/gold.png")
resource.AddFile("materials/vip_packages/platinum.png")
resource.AddFile("materials/vip_packages/diamond.png")

-- VIP rank tanımlamaları
local VIP_RANKS = {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

-- VIP ranklarını kontrol etme fonksiyonu
local function IsVIPRank(rank)
    for _, vipRank in ipairs(VIP_RANKS) do
        if rank == vipRank.id then
            return true
        end
    end
    return rank == "vip"
end

-- VIP rank bilgisi alma fonksiyonu
local function GetVIPRankInfo(rank)
    for _, vipRank in ipairs(VIP_RANKS) do
        if rank == vipRank.id then
            return vipRank
        end
    end
    if rank == "vip" then
        return {id = "vip", name = "VIP", color = Color(255, 215, 0)}
    end
    return nil
end

-- Network stringleri
util.AddNetworkString("SAM.VIPAnnouncement")
util.AddNetworkString("SAM_VIP_GetRanks")
util.AddNetworkString("SAM_VIP_SendRanks")
util.AddNetworkString("SAM_VIP_OpenMenu")
util.AddNetworkString("SAM_VIP_GetList")
util.AddNetworkString("SAM_VIP_SendList")
util.AddNetworkString("SAM_VIP_Action")
util.AddNetworkString("SAM_VIP_ShowPackages")

command.set_category("VIP Yönetimi")

command.new("vip")
    :SetCategory("User Management")
    :Help("VIP paketlerini gösterir")
    :OnExecute(function(ply)
        net.Start("SAM_VIP_ShowPackages")
        net.Send(ply)
    end)
:End()

command.new("vipmenu")
    :SetPermission("vip_menu", "superadmin")
    :SetCategory("User Management")
    :Help("VIP yönetim menüsünü açar")
    :OnExecute(function(ply)
        net.Start("SAM_VIP_OpenMenu")
        net.Send(ply)
    end)
:End()

command.new("vipver")
    :SetPermission("vip_ver", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :AddArg("text", {hint = "vip türü (bronz/silver/gold/platinum/diamond)", optional = true, default = "silver"})
    :AddArg("length", {hint = "süre (dakika)", optional = true, default = 1440})
    :Help("Oyuncuya VIP verir")
    :OnExecute(function(ply, targets, vipType, length)
        local target = targets[1]
        if not IsValid(target) then 
            -- Debug için
            print("[SAM VIP] vipver komutu - hedef oyuncu bulunamadı!")
            return ply:sam_send_message("Hedef oyuncu bulunamadı!") 
        end
        
        local vipRank = vipType:lower() .. "vip"
        local rankInfo = GetVIPRankInfo(vipRank)
        if not rankInfo then return ply:sam_send_message("Geçersiz VIP türü! Kullanılabilir: bronz, silver, gold, platinum, diamond") end
        
        local length_num = tonumber(length) or 1440
        local expiry_date = 0
        if length_num > 0 then
            expiry_date = os.time() + (length_num * 60)
        end
        
        target:sam_set_rank(vipRank, expiry_date)
        
        net.Start("SAM.VIPAnnouncement")
        net.WriteString(target:Nick())
        net.WriteString(rankInfo.name)
        net.WriteColor(rankInfo.color)
        net.Broadcast()
        
        sam.player.send_message(nil, "{A} {T} oyuncusuna {V} süreliğine " .. rankInfo.name .. " verdi", {
            A = ply, T = targets, V = sam.format_length(length_num)
        })
    end)
:End()

command.new("vipuzat")
    :SetPermission("vip_uzat", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :AddArg("length", {hint = "eklenecek süre (dakika)"})
    :Help("VIP süresini uzatır")
    :OnExecute(function(ply, targets, length)
        local target = targets[1]
        if not IsVIPRank(target:GetUserGroup()) then return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets}) end
        
        local query_expiry = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        local current_expiry = tonumber(query_expiry) or 0
        if current_expiry == 0 then return ply:sam_send_message("{T} oyuncusu zaten kalıcı VIP!", {T = targets}) end
        
        local length_num = tonumber(length) or 0
        local time_to_add = length_num * 60
        
        -- Süresi dolmuşsa, şu anki zamana ekle. Dolmamışsa, mevcut sürenin üstüne ekle.
        local base_time = math.max(current_expiry, os.time())
        local new_expiry = base_time + time_to_add
        
        -- Sürenin çok ileri bir tarihe gitmesini engelle (Örn: max 10 yıl)
        local cap = os.time() + (10 * 365 * 86400)
        if new_expiry > cap then new_expiry = cap end

        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        target:sam_set_rank(target:GetUserGroup(), new_expiry)
        
        local rankInfo = GetVIPRankInfo(target:GetUserGroup())
        sam.player.send_message(nil, "{A} {T} oyuncusunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresine {V} ekledi", {
            A = ply, T = targets, V = sam.format_length(length_num)
        })
    end)
:End()

command.new("vipkaldir")
    :SetPermission("vip_kaldir", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :Help("VIP rankını kaldırır")
    :OnExecute(function(ply, targets)
        local target = targets[1]
        if not IsVIPRank(target:GetUserGroup()) then return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets}) end
        
        local rankInfo = GetVIPRankInfo(target:GetUserGroup())
        target:sam_set_rank("user")
        
        sam.player.send_message(nil, "{A} {T} oyuncusundan " .. (rankInfo and rankInfo.name or "VIP") .. " rankını kaldırdı", {
            A = ply, T = targets
        })
    end)
:End()

command.new("vipyukselt")
    :SetPermission("vip_yukselt", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :Help("VIP rankını bir üst seviyeye yükseltir")
    :OnExecute(function(ply, targets)
        local target = targets[1]
        if not IsVIPRank(target:GetUserGroup()) then return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets}) end
        
        local currentRank = target:GetUserGroup()
        local newRankId
        if currentRank == "vip" or currentRank == "bronzvip" then newRankId = "silvervip"
        elseif currentRank == "silvervip" then newRankId = "goldvip"
        elseif currentRank == "goldvip" then newRankId = "platinumvip"
        elseif currentRank == "platinumvip" then newRankId = "diamondvip"
        else return ply:sam_send_message("{T} zaten en yüksek VIP rankına sahip!", {T = targets}) end
        
        local query_expiry = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        local expiry = tonumber(query_expiry) or 0
        
        target:sam_set_rank(newRankId, expiry)
        
        local oldInfo = GetVIPRankInfo(currentRank)
        local newInfo = GetVIPRankInfo(newRankId)
        sam.player.send_message(nil, "{A} {T} oyuncusunu " .. (oldInfo and oldInfo.name or "VIP") .. " rankından " .. newInfo.name .. " rankına yükseltti", {
            A = ply, T = targets
        })
    end)
:End()

net.Receive("SAM_VIP_GetList", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    local vip_list = {}
    local result = sql.Query("SELECT steamid, name, rank, expiry_date FROM sam_players WHERE rank IN ('vip', 'bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip')")
    if not result then return end

    for _, row in ipairs(result) do
        local expiry = tonumber(row.expiry_date) or 0
        if expiry == 0 or expiry > os.time() then
            local rankInfo = GetVIPRankInfo(row.rank)
            table.insert(vip_list, {
                steamid = row.steamid,
                nick = row.name or row.steamid,
                expiry = expiry,
                online = player.GetBySteamID(row.steamid) and true or false,
                rank = row.rank,
                rankName = rankInfo and rankInfo.name or "VIP",
                rankColor = rankInfo and rankInfo.color or Color(255, 215, 0)
            })
        end
    end
    net.Start("SAM_VIP_SendList")
    net.WriteTable(vip_list)
    net.Send(ply)
end)

net.Receive("SAM_VIP_GetRanks", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    net.Start("SAM_VIP_SendRanks")
    net.WriteTable(VIP_RANKS)
    net.Send(ply)
end)

net.Receive("SAM_VIP_Action", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local action = net.ReadString()
    
    -- Debug log
    print("[SAM VIP Debug] Action: " .. action)
    
    if action == "extendall" then
        -- Tüm VIP'lere süre ekle
        local days = net.ReadUInt(16)
        local minutes = days * 1440
        local seconds_to_add = minutes * 60
        local affected_count = 0
        
        -- Sadece süresi olan VIP'leri veritabanından çek (kalıcı olanları elleme)
        local query_result = sql.Query("SELECT steamid, expiry_date, rank FROM sam_players WHERE rank IN ('bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip') AND expiry_date > 0")
        if not query_result then return end
        
        local cap = os.time() + (10 * 365 * 86400) -- Süre sınırı (max 10 yıl)

        for _, row in ipairs(query_result) do
            local current_expiry = tonumber(row.expiry_date) or 0
            
            -- Süresi dolmuşsa şu anki zamandan, dolmamışsa mevcut süreden ekle
            local base_time = math.max(current_expiry, os.time())
            local new_expiry = base_time + seconds_to_add
            
            -- Süre sınırını uygula
            if new_expiry > cap then new_expiry = cap end

            sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(row.steamid))
            
            -- Oyuncu online ise anında güncelle
            local target_ply = player.GetBySteamID(row.steamid)
            if IsValid(target_ply) then
                target_ply:sam_set_rank(row.rank, new_expiry)
            end
            affected_count = affected_count + 1
        end

        sam.player.send_message(nil, "{A} toplam {V} adet süreli VIP'nin süresine {T} ekledi.", {
            A = ply, V = affected_count, T = sam.format_length(minutes)
        })
        return
    end

    -- Diğer aksiyonlar için steamid'yi oku
    local steamid = net.ReadString()
    if not steamid then return end
    
    if action == "add" or action == "give" then
        -- Yeni VIP ekleme
        local vipType = net.ReadString()
        local minutes = net.ReadUInt(16) -- CLIENT'TAN DAKIKA OLARAK GELİYOR
        
        local vipRank = vipType:lower() .. "vip"
        local rankInfo = GetVIPRankInfo(vipRank)
        if not rankInfo then 
            ply:sam_send_message("Geçersiz VIP türü! Kullanılabilir: bronz, silver, gold, platinum, diamond")
            return
        end
        
        -- SAM'ın setrankid komutunu kullan (# işareti OLMADAN, hem online hem offline için çalışır)
        if minutes > 0 then
            RunConsoleCommand("sam", "setrankid", steamid, vipRank, tostring(minutes))
        else
            RunConsoleCommand("sam", "setrankid", steamid, vipRank)
        end
        
    elseif action == "remove" then
        -- setrankid kullanarak user rankına düşür (# işareti OLMADAN)
        RunConsoleCommand("sam", "setrankid", steamid, "user")
        
    elseif action == "upgrade" then
        -- Oyuncunun VIP seviyesini yükselt
        local target = player.GetBySteamID(steamid)
        if not target then
            -- Offline oyuncu için veritabanından bilgi al
            local result = sql.QueryRow("SELECT rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if not result or not IsVIPRank(result.rank) then
                ply:sam_send_message("Oyuncunun VIP rankı yok!")
                return
            end
            
            local currentRank = result.rank
            local newRankId
            if currentRank == "vip" or currentRank == "bronzvip" then newRankId = "silvervip"
            elseif currentRank == "silvervip" then newRankId = "goldvip"
            elseif currentRank == "goldvip" then newRankId = "platinumvip"
            elseif currentRank == "platinumvip" then newRankId = "diamondvip"
            else 
                ply:sam_send_message("Oyuncu zaten en yüksek VIP rankına sahip!")
                return
            end
            
            -- Mevcut süreyi koru
            RunConsoleCommand("sam", "setrankid", steamid, newRankId)
        else
            -- Online oyuncu için entity index kullan
            RunConsoleCommand("sam", "vipyukselt", tostring(target:EntIndex()))
        end
        
    elseif action == "extend" then
        local days = net.ReadUInt(16)
        local target = player.GetBySteamID(steamid)
        if IsValid(target) then
            -- Online oyuncu için entity index kullan
            RunConsoleCommand("sam", "vipuzat", tostring(target:EntIndex()), tostring(days * 1440))
        else
            -- Offline oyuncu için veritabanı işlemi
            local result = sql.QueryRow("SELECT rank, expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if not result or not IsVIPRank(result.rank) then
                ply:sam_send_message("Oyuncunun VIP rankı yok!")
                return
            end
            
            local current_expiry = tonumber(result.expiry_date) or 0
            if current_expiry == 0 then
                ply:sam_send_message("Oyuncu zaten kalıcı VIP!")
                return
            end
            
            local seconds_to_add = days * 1440 * 60
            local base_time = math.max(current_expiry, os.time())
            local new_expiry = base_time + seconds_to_add
            
            local cap = os.time() + (10 * 365 * 86400)
            if new_expiry > cap then new_expiry = cap end
            
            sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
            
            local rankInfo = GetVIPRankInfo(result.rank)
            ply:sam_send_message("Offline oyuncunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresine " .. sam.format_length(days * 1440) .. " eklendi.")
        end
        
    elseif action == "settime" then
        local days = net.ReadUInt(16)
        local minutes = days * 1440
        local new_expiry = os.time() + (minutes * 60)
        
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
        
        local target = player.GetBySteamID(steamid)
        if IsValid(target) then
            target:sam_set_rank(target:GetUserGroup(), new_expiry)
            ply:sam_send_message("VIP süresi " .. sam.format_length(minutes) .. " olarak ayarlandı.")
        else
            ply:sam_send_message("Offline oyuncunun VIP süresi güncellendi.")
        end
    end
end)

hook.Add("SAM.Player.OnRankExpire", "VIPExpired", function(ply, old_rank)
    if IsVIPRank(old_rank) then
        local rankInfo = GetVIPRankInfo(old_rank)
        ply:sam_send_message((rankInfo and rankInfo.name or "VIP") .. " süreniz doldu!")
    end
end)

hook.Add("SAM.ChangedPlayerRank", "AnnounceVIPRank", function(ply, rank, oldRank)
    if IsVIPRank(rank) and not IsVIPRank(oldRank) then
        local rankInfo = GetVIPRankInfo(rank)
        if rankInfo then
            net.Start("SAM.VIPAnnouncement")
            net.WriteString(ply:Nick())
            net.WriteString(rankInfo.name)
            net.WriteColor(rankInfo.color)
            net.Broadcast()
        end
    end
end)