-- SAM VIP Yönetim Sistemi - Server Tarafı (GÜNCEL)
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

-- İşlem geçmişi için tablo oluştur
local function InitializeDatabase()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS sam_vip_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            admin_steamid TEXT,
            target_steamid TEXT,
            action TEXT,
            old_data TEXT,
            new_data TEXT,
            timestamp INTEGER
        )
    ]])
end
InitializeDatabase()

-- İşlem kaydetme
local function LogVIPAction(admin, target_steamid, action, old_data, new_data)
    local admin_steamid = IsValid(admin) and admin:SteamID() or "CONSOLE"
    sql.Query(string.format([[
        INSERT INTO sam_vip_history (admin_steamid, target_steamid, action, old_data, new_data, timestamp)
        VALUES (%s, %s, %s, %s, %s, %d)
    ]], 
        sql.SQLStr(admin_steamid),
        sql.SQLStr(target_steamid),
        sql.SQLStr(action),
        sql.SQLStr(old_data or ""),
        sql.SQLStr(new_data or ""),
        os.time()
    ))
end

-- Son işlemi geri alma
local function UndoLastAction(admin)
    local last_action = sql.QueryRow([[
        SELECT * FROM sam_vip_history 
        WHERE admin_steamid = ]] .. sql.SQLStr(admin:SteamID()) .. [[
        ORDER BY id DESC LIMIT 1
    ]])
    
    if not last_action then
        return false, "Geri alınacak işlem bulunamadı!"
    end
    
    -- İşlemi geri al
    if last_action.action == "add" then
        sql.Query("UPDATE sam_players SET rank = 'user' WHERE steamid = " .. sql.SQLStr(last_action.target_steamid))
        local target = player.GetBySteamID(last_action.target_steamid)
        if IsValid(target) then
            target:sam_set_rank("user")
        end
    elseif last_action.action == "extend" or last_action.action == "settime" then
        local old_expiry = tonumber(last_action.old_data) or 0
        sql.Query("UPDATE sam_players SET expiry_date = " .. old_expiry .. " WHERE steamid = " .. sql.SQLStr(last_action.target_steamid))
        local target = player.GetBySteamID(last_action.target_steamid)
        if IsValid(target) then
            local rank = target:GetUserGroup()
            target:sam_set_rank(rank, old_expiry)
        end
    elseif last_action.action == "upgrade" then
        sql.Query("UPDATE sam_players SET rank = " .. sql.SQLStr(last_action.old_data) .. " WHERE steamid = " .. sql.SQLStr(last_action.target_steamid))
        local target = player.GetBySteamID(last_action.target_steamid)
        if IsValid(target) then
            target:sam_set_rank(last_action.old_data)
        end
    end
    
    -- Kaydı sil
    sql.Query("DELETE FROM sam_vip_history WHERE id = " .. last_action.id)
    
    return true, "İşlem başarıyla geri alındı!"
end

-- VIP ranklarını kontrol etme
local function IsVIPRank(rank)
    for _, vipRank in ipairs(VIP_RANKS) do
        if rank == vipRank.id then
            return true
        end
    end
    return rank == "vip"
end

-- VIP rank bilgisi alma
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

-- Güvenli süre ekleme
local function SafeAddTime(current_expiry, days_to_add)
    local seconds_to_add = days_to_add * 86400
    local now = os.time()
    
    if not current_expiry or current_expiry == 0 then
        return 0 -- Kalıcı olarak kalsın
    end
    
    local base_time = current_expiry
    if current_expiry < now then
        base_time = now
    end
    
    local new_expiry = base_time + seconds_to_add
    
    -- Maksimum 10 yıl sınırı
    local max_time = now + (10 * 365 * 86400)
    if new_expiry > max_time then
        new_expiry = max_time
    end
    
    return new_expiry
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
util.AddNetworkString("SAM_VIP_GetHistory")
util.AddNetworkString("SAM_VIP_SendHistory")
util.AddNetworkString("SAM_VIP_UndoLast")
util.AddNetworkString("SAM_VIP_UndoResult")

-- Komutlar
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

-- Network mesajları
net.Receive("SAM_VIP_GetList", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local vip_list = {}
    local result = sql.Query("SELECT steamid, name, rank, expiry_date FROM sam_players WHERE rank IN ('vip', 'bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip')")
    
    if result then
        for _, row in ipairs(result) do
            local expiry = tonumber(row.expiry_date) or 0
            if expiry == 0 or expiry > os.time() then
                local rankInfo = GetVIPRankInfo(row.rank)
                local target_ply = player.GetBySteamID(row.steamid)
                
                table.insert(vip_list, {
                    steamid = row.steamid,
                    nick = IsValid(target_ply) and target_ply:Nick() or (row.name or row.steamid),
                    expiry = expiry,
                    online = IsValid(target_ply),
                    rank = row.rank,
                    rankName = rankInfo and rankInfo.name or "VIP",
                    rankColor = rankInfo and rankInfo.color or Color(255, 215, 0)
                })
            end
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

net.Receive("SAM_VIP_GetHistory", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local history = sql.Query([[
        SELECT * FROM sam_vip_history 
        ORDER BY id DESC 
        LIMIT 50
    ]])
    
    net.Start("SAM_VIP_SendHistory")
    net.WriteTable(history or {})
    net.Send(ply)
end)

net.Receive("SAM_VIP_UndoLast", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local success, message = UndoLastAction(ply)
    
    net.Start("SAM_VIP_UndoResult")
    net.WriteBool(success)
    net.WriteString(message)
    net.Send(ply)
end)

net.Receive("SAM_VIP_Action", function(len, ply)
    if not ply:HasPermission("vip_menu") then return end
    
    local action = net.ReadString()
    
    if action == "extendall" then
        local days = net.ReadUInt(16)
        local affected_count = 0
        
        local result = sql.Query([[
            SELECT steamid, expiry_date, rank, name 
            FROM sam_players 
            WHERE rank IN ('bronzvip', 'silvervip', 'goldvip', 'platinumvip', 'diamondvip') 
            AND expiry_date > 0
        ]])
        
        if result then
            for _, row in ipairs(result) do
                local current_expiry = tonumber(row.expiry_date) or 0
                local new_expiry = SafeAddTime(current_expiry, days)
                
                sql.Query(string.format(
                    "UPDATE sam_players SET expiry_date = %d WHERE steamid = %s",
                    new_expiry,
                    sql.SQLStr(row.steamid)
                ))
                
                local target = player.GetBySteamID(row.steamid)
                if IsValid(target) then
                    target:sam_set_rank(row.rank, new_expiry)
                end
                
                affected_count = affected_count + 1
                LogVIPAction(ply, row.steamid, "extendall", tostring(current_expiry), tostring(new_expiry))
            end
        end
        
        sam.player.send_message(nil, "{A} toplam {V} VIP'ye {T} ekledi.", {
            A = ply, V = affected_count, T = days .. " gün"
        })
        
        return
    end
    
    local steamid = net.ReadString()
    if not steamid then return end
    
    if action == "add" then
        local vipType = net.ReadString()
        local minutes = net.ReadUInt(16)
        
        local vipRank = vipType:lower() .. "vip"
        local rankInfo = GetVIPRankInfo(vipRank)
        
        if not rankInfo then
            ply:sam_send_message("Geçersiz VIP türü!")
            return
        end
        
        local expiry = 0
        if minutes > 0 then
            expiry = os.time() + (minutes * 60)
        end
        
        local old_data = sql.QueryRow("SELECT rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
        
        RunConsoleCommand("sam", "setrankid", steamid, vipRank, minutes > 0 and tostring(minutes) or nil)
        
        LogVIPAction(ply, steamid, "add", old_data and old_data.rank or "user", vipRank)
        
    elseif action == "extend" then
        local days = net.ReadUInt(16)
        
        local current = sql.QueryRow("SELECT expiry_date, rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
        if not current then
            ply:sam_send_message("Oyuncu bulunamadı!")
            return
        end
        
        local current_expiry = tonumber(current.expiry_date) or 0
        if current_expiry == 0 then
            ply:sam_send_message("Kalıcı VIP'lere süre eklenemez!")
            return
        end
        
        local new_expiry = SafeAddTime(current_expiry, days)
        
        sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
        
        local target = player.GetBySteamID(steamid)
        if IsValid(target) then
            target:sam_set_rank(current.rank, new_expiry)
        end
        
        LogVIPAction(ply, steamid, "extend", tostring(current_expiry), tostring(new_expiry))
        
        ply:sam_send_message("VIP süresine " .. days .. " gün eklendi!")
        
    elseif action == "remove" then
        local old_data = sql.QueryRow("SELECT rank FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
        
        RunConsoleCommand("sam", "setrankid", steamid, "user")
        
        LogVIPAction(ply, steamid, "remove", old_data and old_data.rank or "", "user")
    end
end)

-- Debug komutları
concommand.Add("vip_debug_time", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    print("=== VIP ZAMAN DEBUG ===")
    print("Sunucu Zamanı: " .. os.date("%Y-%m-%d %H:%M:%S", os.time()))
    print("Unix Timestamp: " .. os.time())
    
    local result = sql.Query("SELECT steamid, name, rank, expiry_date FROM sam_players WHERE rank LIKE '%vip%'")
    if result then
        for _, row in ipairs(result) do
            local expiry = tonumber(row.expiry_date) or 0
            if expiry > 0 then
                local remaining = expiry - os.time()
                local days = math.floor(remaining / 86400)
                print(string.format("%s (%s): %d gün kaldı", row.name or "Unknown", row.rank, days))
            else
                print(string.format("%s (%s): Kalıcı VIP", row.name or "Unknown", row.rank))
            end
        end
    end
    print("======================")
end)

concommand.Add("vip_fix_times", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local fixed = 0
    local now = os.time()
    local max_time = now + (10 * 365 * 86400)
    
    local result = sql.Query("SELECT steamid, expiry_date FROM sam_players WHERE rank LIKE '%vip%' AND expiry_date > 0")
    if result then
        for _, row in ipairs(result) do
            local expiry = tonumber(row.expiry_date)
            if expiry and expiry > max_time then
                local new_expiry = now + (30 * 86400)
                sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(row.steamid))
                fixed = fixed + 1
            end
        end
    end
    
    if IsValid(ply) then
        ply:ChatPrint("Düzeltilen VIP sayısı: " .. fixed)
    else
        print("Düzeltilen VIP sayısı: " .. fixed)
    end
end)