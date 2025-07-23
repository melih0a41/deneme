-- /lua/autorun/server/sam_vip_job_bypass_aggressive.lua
-- Diamond VIP'ler için meslek sınırı atlama sistemi - AGRESİF VERSİYON

-- DarkRP'nin meslek değiştirme fonksiyonunu tamamen override et
hook.Add("DarkRPFinishedLoading", "SAM_DiamondVIP_AggressiveOverride", function()
    print("[SAM VIP] Diamond VIP bypass sistemi yükleniyor...")
    
    -- Meta table üzerinden changeTeam fonksiyonunu değiştir
    timer.Simple(1, function()
        local meta = FindMetaTable("Player")
        if not meta then return end
        
        -- Orijinal changeTeam fonksiyonunu sakla
        local oldChangeTeam = meta.changeTeam
        if not oldChangeTeam then 
            print("[SAM VIP] HATA: changeTeam fonksiyonu bulunamadı!")
            return 
        end
        
        -- Yeni changeTeam fonksiyonu
        meta.changeTeam = function(ply, team, force, ...)
            -- Diamond VIP kontrolü
            if IsValid(ply) and ply:GetUserGroup() == "diamondvip" and not force then
                print("[SAM VIP] " .. ply:Nick() .. " (Diamond VIP) meslek değiştiriyor: " .. (RPExtraTeams[team] and RPExtraTeams[team].name or "Unknown"))
                
                local jobTable = RPExtraTeams[team]
                if not jobTable then 
                    DarkRP.notify(ply, 1, 4, "Geçersiz meslek!")
                    return false 
                end
                
                -- Sadece customCheck kontrolü
                if jobTable.customCheck and not jobTable.customCheck(ply) then
                    local msg = jobTable.CustomCheckFailMsg or "Bu mesleğe geçemezsiniz!"
                    DarkRP.notify(ply, 1, 4, msg)
                    return false
                end
                
                -- Diamond VIP için force = true ile çağır (tüm limitleri atlar)
                return oldChangeTeam(ply, team, true, ...)
            end
            
            -- Normal oyuncular için standart işlem
            return oldChangeTeam(ply, team, force, ...)
        end
        
        print("[SAM VIP] changeTeam fonksiyonu başarıyla override edildi!")
    end)
    
    -- F4 menüsü için özel kontrol
    hook.Add("playerCanChangeTeam", "SAM_DiamondVIP_F4Override", function(ply, team, force)
        if IsValid(ply) and ply:GetUserGroup() == "diamondvip" and not force then
            local jobTable = RPExtraTeams[team]
            if jobTable and jobTable.max and jobTable.max > 0 then
                -- Mevcut sayıyı kontrol et
                local current = team.NumPlayers(team)
                if current and current >= jobTable.max then
                    -- Diamond VIP için limit mesajını override et
                    timer.Simple(0, function()
                        if IsValid(ply) then
                            ply:changeTeam(team, true) -- Force ile tekrar dene
                        end
                    end)
                    return false, "Limit kontrol ediliyor..." -- Geçici mesaj
                end
            end
        end
    end, -999) -- En düşük öncelik
    
    -- DarkRP'nin kendi limit kontrol fonksiyonunu da override et
    if DarkRP.hooks and DarkRP.hooks.playerCanChangeTeam then
        local oldHook = DarkRP.hooks.playerCanChangeTeam
        DarkRP.hooks.playerCanChangeTeam = function(ply, team, force)
            if IsValid(ply) and ply:GetUserGroup() == "diamondvip" and not force then
                return true
            end
            return oldHook(ply, team, force)
        end
    end
end)

-- Komut ile meslek değiştirme
hook.Add("PlayerSay", "SAM_DiamondVIP_JobCommand", function(ply, text)
    if not IsValid(ply) or ply:GetUserGroup() ~= "diamondvip" then return end
    
    -- / ile başlayan komutları kontrol et
    if string.sub(text, 1, 1) == "/" then
        local cmd = string.sub(text, 2)
        
        -- Meslek komutlarını kontrol et
        for k, v in pairs(RPExtraTeams) do
            if v.command and v.command == cmd then
                print("[SAM VIP] " .. ply:Nick() .. " komut ile meslek değiştiriyor: " .. v.name)
                
                -- customCheck kontrolü
                if v.customCheck and not v.customCheck(ply) then
                    DarkRP.notify(ply, 1, 4, v.CustomCheckFailMsg or "Bu mesleğe geçemezsiniz!")
                    return ""
                end
                
                -- Force ile mesleğe geç
                ply:changeTeam(k, true)
                return ""
            end
        end
    end
end)

-- Debug komutları
concommand.Add("sam_vip_bypass_status", function(ply)
    local output = IsValid(ply) and ply.ChatPrint or print
    
    output("=== Diamond VIP Bypass Status ===")
    
    if IsValid(ply) then
        output("Rankın: " .. ply:GetUserGroup())
        output("Diamond VIP: " .. (ply:GetUserGroup() == "diamondvip" and "EVET" or "HAYIR"))
        
        local job = ply:Team()
        local jobTable = RPExtraTeams[job]
        if jobTable then
            output("Meslek: " .. jobTable.name)
            output("Meslek Limiti: " .. (jobTable.max or "Sınırsız"))
            output("Mevcut Sayı: " .. team.NumPlayers(job))
        end
    end
    
    local meta = FindMetaTable("Player")
    output("changeTeam override: " .. (meta and meta.changeTeam and "AKTIF" or "KAPALI"))
end)

-- Diamond VIP test komutu
concommand.Add("sam_vip_give_diamond", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local target = args[1]
    if not target then
        ply:SetUserGroup("diamondvip")
        ply:ChatPrint("Diamond VIP verildi!")
    else
        local targetPly = nil
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), string.lower(target)) then
                targetPly = p
                break
            end
        end
        
        if targetPly then
            targetPly:SetUserGroup("diamondvip")
            ply:ChatPrint(targetPly:Nick() .. " oyuncusuna Diamond VIP verildi!")
            targetPly:ChatPrint("Size Diamond VIP verildi! Artık meslek limitlerini atlayabilirsiniz.")
        else
            ply:ChatPrint("Oyuncu bulunamadı: " .. target)
        end
    end
end)

print("[SAM VIP] Diamond VIP agresif bypass sistemi yüklendi!")