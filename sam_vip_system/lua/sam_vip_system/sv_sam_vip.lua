-- SAM VIP Yönetim Sistemi - Server Tarafı
-- lua/sam_vip_system/sv_sam_vip.lua

local sam = sam
local command = sam.command

-- VIP paket resimlerini client'a gönder
resource.AddFile("materials/vip_packages/bronze.png")
resource.AddFile("materials/vip_packages/silver.png")
resource.AddFile("materials/vip_packages/gold.png")
resource.AddFile("materials/vip_packages/platinum.png")
resource.AddFile("materials/vip_packages/diamond.png")

-- VIP rank tanımlamaları (SAM'deki mevcut ranklara göre)
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
    -- Eski VIP rankı için de kontrol
    return rank == "vip"
end

-- VIP rank bilgisi alma fonksiyonu
local function GetVIPRankInfo(rank)
    for _, vipRank in ipairs(VIP_RANKS) do
        if rank == vipRank.id then
            return vipRank
        end
    end
    -- Eski VIP için default
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

-- Komut kategorisini ayarla
command.set_category("VIP Yönetimi")

-- !vip komutunu oluştur - VIP paketlerini göster
command.new("vip")
    :SetCategory("User Management")
    :Help("VIP paketlerini gösterir")
    :OnExecute(function(ply)
        net.Start("SAM_VIP_ShowPackages")
        net.Send(ply)
    end)
:End()

-- !vipmenu komutunu oluştur
command.new("vipmenu")
    :SetPermission("vip_menu", "superadmin")
    :SetCategory("User Management")
    :Help("VIP yönetim menüsünü açar")
    :OnExecute(function(ply)
        net.Start("SAM_VIP_OpenMenu")
        net.Send(ply)
    end)
:End()

-- !vipver komutunu güncelle - artık VIP türü seçilebilir
command.new("vipver")
    :SetPermission("vip_ver", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :AddArg("text", {hint = "vip türü (bronz/silver/gold/platinum/diamond)", optional = true, default = "silver"})
    :AddArg("length", {hint = "süre (dakika)", optional = true, default = 1440})
    :Help("Oyuncuya VIP verir")
    :OnExecute(function(ply, targets, vipType, length)
        local target = targets[1]
        local duration = length * 60
        
        -- VIP türünü doğrula
        local vipRank = vipType:lower() .. "vip"
        local rankInfo = GetVIPRankInfo(vipRank)
        
        if not rankInfo then
            return ply:sam_send_message("Geçersiz VIP türü! Kullanılabilir: bronz, silver, gold, platinum, diamond")
        end
        
        target:sam_set_rank(vipRank, duration)
        
        -- VIP duyurusu yap
        net.Start("SAM.VIPAnnouncement")
        net.WriteString(target:Nick())
        net.WriteString(rankInfo.name)
        net.WriteColor(rankInfo.color)
        net.Broadcast()
        
        sam.player.send_message(nil, "{A} {T} oyuncusuna {V} süreliğine " .. rankInfo.name .. " verdi", {
            A = ply, 
            T = targets, 
            V = sam.format_length(length)
        })
    end)
:End()

-- !vipuzat komutunu güncelle
command.new("vipuzat")
    :SetPermission("vip_uzat", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :AddArg("length", {hint = "eklenecek süre (dakika)"})
    :Help("VIP süresini uzatır")
    :OnExecute(function(ply, targets, length)
        local target = targets[1]
        
        if not IsVIPRank(target:GetUserGroup()) then
            return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets})
        end
        
        -- SQL'den mevcut bitiş zamanını al
        local current_expiry = 0
        local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        if query then
            current_expiry = tonumber(query) or 0
        end
        
        local new_expiry = math.max(current_expiry, os.time()) + (length * 60)
        
        -- SQL'de güncelle
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        
        -- SAM'a bildir
        if sam.player and sam.player.set_rank then
            sam.player.set_rank(target:SteamID(), target:GetUserGroup(), new_expiry)
        end
        
        local rankInfo = GetVIPRankInfo(target:GetUserGroup())
        sam.player.send_message(nil, "{A} {T} oyuncusunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresine {V} ekledi", {
            A = ply,
            T = targets,
            V = sam.format_length(length)
        })
    end)
:End()

-- !vipkaldir komutunu güncelle
command.new("vipkaldir")
    :SetPermission("vip_kaldir", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :Help("VIP rankını kaldırır")
    :OnExecute(function(ply, targets)
        local target = targets[1]
        
        if not IsVIPRank(target:GetUserGroup()) then
            return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets})
        end
        
        local rankInfo = GetVIPRankInfo(target:GetUserGroup())
        
        -- Rank'ı user yap
        target:sam_set_rank("user")
        
        -- SQL'de de güncelle
        sql.Query("UPDATE sam_players SET rank = 'user', expiry_date = 0 WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        
        sam.player.send_message(nil, "{A} {T} oyuncusundan " .. (rankInfo and rankInfo.name or "VIP") .. " rankını kaldırdı", {
            A = ply,
            T = targets
        })
    end)
:End()

-- !vipyukselt komutunu ekle
command.new("vipyukselt")
    :SetPermission("vip_yukselt", "superadmin")
    :SetCategory("User Management")
    :AddArg("player", {single_target = true})
    :Help("VIP rankını bir üst seviyeye yükseltir")
    :OnExecute(function(ply, targets)
        local target = targets[1]
        
        if not IsVIPRank(target:GetUserGroup()) then
            return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets})
        end
        
        local currentRank = target:GetUserGroup()
        local newRank = nil
        
        -- Yükseltme sırası
        if currentRank == "vip" or currentRank == "bronzvip" then
            newRank = "silvervip"
        elseif currentRank == "silvervip" then
            newRank = "goldvip"
        elseif currentRank == "goldvip" then
            newRank = "platinumvip"
        elseif currentRank == "platinumvip" then
            newRank = "diamondvip"
        else
            return ply:sam_send_message("{T} zaten en yüksek VIP rankına sahip!", {T = targets})
        end
        
        -- Mevcut süreyi koru
        local expiry = 0
        local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(target:SteamID()))
        if query then
            expiry = tonumber(query) or 0
        end
        
        target:sam_set_rank(newRank, expiry > 0 and expiry or nil)
        
        local oldInfo = GetVIPRankInfo(currentRank)
        local newInfo = GetVIPRankInfo(newRank)
        
        sam.player.send_message(nil, "{A} {T} oyuncusunu " .. (oldInfo and oldInfo.name or "VIP") .. " rankından " .. newInfo.name .. " rankına yükseltti", {
            A = ply,
            T = targets
        })
    end)
:End()

-- VIP listesini gönder
net.Receive("SAM_VIP_GetList", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local vip_list = {}
    local added_steamids = {}
    
    -- Online oyuncuları kontrol et
    for _, p in ipairs(player.GetAll()) do
        if IsVIPRank(p:GetUserGroup()) then
            local expiry = 0
            
            -- SQL'den expiry bilgisini al
            local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(p:SteamID()))
            if query then
                expiry = tonumber(query) or 0
            end
            
            local time_left = expiry > 0 and (expiry - os.time()) or -1
            local rankInfo = GetVIPRankInfo(p:GetUserGroup())
            
            table.insert(vip_list, {
                steamid = p:SteamID(),
                nick = p:Nick(),
                time_left = time_left,
                expiry = expiry,
                online = true,
                rank = p:GetUserGroup(),
                rankName = rankInfo and rankInfo.name or "VIP",
                rankColor = rankInfo and rankInfo.color or Color(255, 215, 0)
            })
            
            added_steamids[p:SteamID()] = true
        end
    end
    
    -- SQL'den tüm VIP'leri al (offline olanlar dahil)
    local query = [[
        SELECT steamid, name, rank, expiry_date 
        FROM sam_players 
        WHERE rank IN ('vip', 'bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip')
    ]]
    
    local result = sql.Query(query)
    if result then
        for _, row in ipairs(result) do
            if not added_steamids[row.steamid] and IsVIPRank(row.rank) then
                local expiry = tonumber(row.expiry_date) or 0
                local time_left = expiry > 0 and (expiry - os.time()) or -1
                
                -- Süresi dolmuş VIP'leri gösterme (0 kalıcı demek)
                if expiry == 0 or time_left > 0 then
                    local rankInfo = GetVIPRankInfo(row.rank)
                    
                    table.insert(vip_list, {
                        steamid = row.steamid,
                        nick = row.name or row.steamid,
                        time_left = time_left,
                        expiry = expiry,
                        online = false,
                        rank = row.rank,
                        rankName = rankInfo and rankInfo.name or "VIP",
                        rankColor = rankInfo and rankInfo.color or Color(255, 215, 0)
                    })
                end
            end
        end
    end
    
    -- Listeyi gönder
    net.Start("SAM_VIP_SendList")
    net.WriteTable(vip_list)
    net.Send(ply)
end)

-- VIP rankları listesini gönder
net.Receive("SAM_VIP_GetRanks", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    net.Start("SAM_VIP_SendRanks")
    net.WriteTable(VIP_RANKS)
    net.Send(ply)
end)

-- VIP aksiyonları
net.Receive("SAM_VIP_Action", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local action = net.ReadString()
    local steamid = net.ReadString()
    
    if action == "remove" then
        -- Önce oyuncuyu bul
        local target = player.GetBySteamID(steamid)
        local target_name = "Bilinmeyen"
        local rankInfo = nil
        
        if IsValid(target) then
            -- Online oyuncu - direkt SAM komutu
            target_name = target:Nick()
            rankInfo = GetVIPRankInfo(target:GetUserGroup())
            target:sam_set_rank("user")
        else
            -- Offline oyuncu - SQL'den ismi al ve rankı güncelle
            local query = sql.QueryRow("SELECT name, rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                target_name = query.name or "Bilinmeyen"
                rankInfo = GetVIPRankInfo(query.rank)
            end
            
            sql.Query("UPDATE sam_players SET rank = 'user', expiry_date = 0 WHERE steamid = " .. sql.SQLStr(steamid))
        end
        
        -- Log mesajı - isim bilgisiyle
        sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusundan " .. (rankInfo and rankInfo.name or "VIP") .. " rankını kaldırdı", {
            A = ply
        })
        
    elseif action == "extend" then
        local days = net.ReadUInt(16)
        local minutes = days * 1440
        
        -- Oyuncu bilgilerini al
        local target = player.GetBySteamID(steamid)
        local target_name = "Bilinmeyen"
        local rankInfo = nil
        
        if IsValid(target) then
            target_name = target:Nick()
            rankInfo = GetVIPRankInfo(target:GetUserGroup())
        else
            -- Offline oyuncu - SQL'den ismi al
            local query = sql.QueryRow("SELECT name, rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                target_name = query.name or "Bilinmeyen"
                rankInfo = GetVIPRankInfo(query.rank)
            end
        end
        
        -- Mevcut süreyi al
        local current_expiry = 0
        local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
        if query then
            current_expiry = tonumber(query) or 0
        end
        
        local new_expiry = math.max(current_expiry, os.time()) + (minutes * 60)
        
        -- SQL'de güncelle
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
        
        -- Online oyuncuyu güncelle
        if IsValid(target) then
            target:sam_set_rank(target:GetUserGroup(), new_expiry)
        end
        
        -- Log mesajı - isim bilgisiyle
        sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresine {V} ekledi", {
            A = ply,
            V = sam.format_length(minutes)
        })
        
    elseif action == "reduce" then
        -- YENİ: Süre azaltma işlemi
        local option = net.ReadString() -- "1day", "1week", "1month"
        
        -- Oyuncu bilgilerini al
        local target = player.GetBySteamID(steamid)
        local target_name = "Bilinmeyen"
        local rankInfo = nil
        
        if IsValid(target) then
            target_name = target:Nick()
            rankInfo = GetVIPRankInfo(target:GetUserGroup())
        else
            -- Offline oyuncu
            local query = sql.QueryRow("SELECT name, rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                target_name = query.name or "Bilinmeyen"
                rankInfo = GetVIPRankInfo(query.rank)
            end
        end
        
        -- Yeni süreyi hesapla
        local new_expiry = os.time()
        if option == "1day" then
            new_expiry = new_expiry + 86400
        elseif option == "1week" then
            new_expiry = new_expiry + 604800
        elseif option == "1month" then
            new_expiry = new_expiry + 2592000
        end
        
        -- SQL'de güncelle
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
        
        -- Online oyuncuyu güncelle
        if IsValid(target) then
            target:sam_set_rank(target:GetUserGroup(), new_expiry)
        end
        
        -- Log mesajı
        local time_text = "1 gün"
        if option == "1week" then time_text = "1 hafta"
        elseif option == "1month" then time_text = "1 ay" end
        
        sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresini " .. time_text .. " olarak değiştirdi", {
            A = ply
        })
        
    elseif action == "settime" then
        -- YENİ: Direkt süre belirleme
        local days = net.ReadUInt(16)
        
        -- Oyuncu bilgilerini al
        local target = player.GetBySteamID(steamid)
        local target_name = "Bilinmeyen"
        local rankInfo = nil
        
        if IsValid(target) then
            target_name = target:Nick()
            rankInfo = GetVIPRankInfo(target:GetUserGroup())
        else
            -- Offline oyuncu
            local query = sql.QueryRow("SELECT name, rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                target_name = query.name or "Bilinmeyen"
                rankInfo = GetVIPRankInfo(query.rank)
            end
        end
        
        -- Yeni süreyi hesapla
        local new_expiry = os.time() + (days * 86400)
        
        -- SQL'de güncelle
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
        
        -- Online oyuncuyu güncelle
        if IsValid(target) then
            target:sam_set_rank(target:GetUserGroup(), new_expiry)
        end
        
        -- Log mesajı
        sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusunun " .. (rankInfo and rankInfo.name or "VIP") .. " süresini " .. days .. " gün olarak belirledi", {
            A = ply
        })
        
    elseif action == "upgrade" then
        -- VIP yükseltme
        local newRankId = net.ReadString()
        
        -- Önce oyuncuyu bul
        local target = player.GetBySteamID(steamid)
        local target_name = "Bilinmeyen"
        local oldRankInfo = nil
        local newRankInfo = GetVIPRankInfo(newRankId)
        
        if IsValid(target) then
            target_name = target:Nick()
            oldRankInfo = GetVIPRankInfo(target:GetUserGroup())
            
            -- Mevcut süreyi koru
            local expiry = 0
            local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                expiry = tonumber(query) or 0
            end
            
            target:sam_set_rank(newRankId, expiry > 0 and expiry or nil)
        else
            -- Offline oyuncu
            local query = sql.QueryRow("SELECT name, rank, expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                target_name = query.name or "Bilinmeyen"
                oldRankInfo = GetVIPRankInfo(query.rank)
                
                -- SQL'de güncelle
                sql.Query("UPDATE sam_players SET rank = " .. sql.SQLStr(newRankId) .. " WHERE steamid = " .. sql.SQLStr(steamid))
            end
        end
        
        -- Log mesajı
        sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusunu " .. (oldRankInfo and oldRankInfo.name or "VIP") .. " rankından " .. newRankInfo.name .. " rankına yükseltti", {
            A = ply
        })
    end
end)

-- Hook'ları kaldırmıyoruz, sadece güncelliyoruz
-- VIP süresi dolduğunda
hook.Add("SAM.Player.OnRankExpire", "VIPExpired", function(ply, old_rank)
    if IsVIPRank(old_rank) then
        local rankInfo = GetVIPRankInfo(old_rank)
        ply:sam_send_message((rankInfo and rankInfo.name or "VIP") .. " süreniz doldu!")
    end
end)

-- Rank değiştiğinde duyuru yap
hook.Add("SAM.ChangedPlayerRank", "AnnounceVIPRank", function(ply, rank, oldRank)
    if IsVIPRank(rank) and not IsVIPRank(oldRank) then
        local rankInfo = GetVIPRankInfo(rank)
        net.Start("SAM.VIPAnnouncement")
        net.WriteString(ply:Nick())
        net.WriteString(rankInfo and rankInfo.name or "VIP")
        net.WriteColor(rankInfo and rankInfo.color or Color(255, 215, 0))
        net.Broadcast()
    end
end)

-- Konsol komutları aynı kalıyor
concommand.Add("sam_vip_menu", function(ply)
    if IsValid(ply) and ply:HasPermission("vip_menu") then
        net.Start("SAM_VIP_OpenMenu")
        net.Send(ply)
    end
end)

-- Debug komutu güncellendi
concommand.Add("sam_vip_debug", function(ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    print("=== SAM VIP Debug ===")
    
    -- VIP rankları
    print("VIP Rankları:")
    for _, vipRank in ipairs(VIP_RANKS) do
        print("  - " .. vipRank.name .. " (" .. vipRank.id .. ")")
    end
    
    -- Online VIP'ler
    print("\nOnline VIP'ler:")
    for _, p in ipairs(player.GetAll()) do
        if IsVIPRank(p:GetUserGroup()) then
            local rankInfo = GetVIPRankInfo(p:GetUserGroup())
            print("  - " .. p:Nick() .. " (" .. p:SteamID() .. ") - " .. (rankInfo and rankInfo.name or p:GetUserGroup()))
        end
    end
    
    -- SQL tablo yapısını kontrol et
    print("\nSQL Tablo Yapısı:")
    if sql.TableExists("sam_players") then
        print("  sam_players tablosu mevcut")
        
        -- VIP kayıtlarını detaylı göster
        local result = sql.Query("SELECT * FROM sam_players WHERE rank IN ('vip', 'bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip') LIMIT 10")
        if result then
            print("\n  VIP Kayıtları (detaylı):")
            for i, row in ipairs(result) do
                print("    Kayıt " .. i .. ":")
                print("      name = " .. (row.name or "N/A"))
                print("      rank = " .. (row.rank or "N/A"))
                print("      expiry_date = " .. (row.expiry_date or "N/A"))
            end
        end
    else
        print("  sam_players tablosu bulunamadı")
    end
    
    print("=== Debug Sonu ===")
end)

-- Eski VIP'leri otomatik dönüştür
hook.Add("Initialize", "ConvertOldVIPsToSilver", function()
    timer.Simple(5, function()
        local oldVIPs = sql.Query("SELECT steamid FROM sam_players WHERE rank = 'vip'")
        if oldVIPs and #oldVIPs > 0 then
            print("[SAM VIP] Eski VIP'ler Silver VIP'e dönüştürülüyor...")
            sql.Query("UPDATE sam_players SET rank = 'silvervip' WHERE rank = 'vip'")
            print("[SAM VIP] " .. #oldVIPs .. " adet VIP, Silver VIP'e dönüştürüldü.")
        end
    end)
end)