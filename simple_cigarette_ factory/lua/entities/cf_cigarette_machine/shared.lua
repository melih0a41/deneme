ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "AUTO-CIG 2000"
ENT.Category = "Cigarette Factory"
ENT.Spawnable = true
ENT.DisableDuplicator = false

-- Paket yönetimi fonksiyonları (SERVER SIDE)
if SERVER then
    -- Global tablo: Her oyuncunun sahip olduğu paket sayısını tutar
    CF_PlayerPacks = CF_PlayerPacks or {}

    -- Oyuncunun sahip olduğu paket sayısını döndür
    function CF_GetPlayerPackCount(ply)
        if not IsValid(ply) then return 0 end
        
        local steamID = ply:SteamID()
        local count = 0
        
        -- Oyuncunun kayıtlı paketlerini kontrol et
        if CF_PlayerPacks[steamID] then
            for k, pack in pairs(CF_PlayerPacks[steamID]) do
                if IsValid(pack) then
                    count = count + 1
                else
                    -- Geçersiz paketleri temizle
                    CF_PlayerPacks[steamID][k] = nil
                end
            end
        end
        
        return count
    end

    -- Oyuncuya paket ekle
    function CF_AddPackToPlayer(ply, pack)
        if not IsValid(ply) or not IsValid(pack) then return end
        
        local steamID = ply:SteamID()
        CF_PlayerPacks[steamID] = CF_PlayerPacks[steamID] or {}
        table.insert(CF_PlayerPacks[steamID], pack)
    end

    -- Oyuncudan paket çıkar
    function CF_RemovePackFromPlayer(ply, pack)
        if not IsValid(ply) then return end
        
        local steamID = ply:SteamID()
        if CF_PlayerPacks[steamID] then
            for k, p in pairs(CF_PlayerPacks[steamID]) do
                if p == pack then
                    table.remove(CF_PlayerPacks[steamID], k)
                    break
                end
            end
        end
    end

    -- Oyuncu disconnect olduğunda paketlerini temizle
    hook.Add("PlayerDisconnected", "CF_CleanupPlayerPacks", function(ply)
        local steamID = ply:SteamID()
        CF_PlayerPacks[steamID] = nil
    end)
end