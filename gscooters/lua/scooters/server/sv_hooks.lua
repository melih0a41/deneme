-- gscooters/lua/scooters/server/sv_hooks.lua
-- Server tarafında scooter çakışması ve jail bugları düzeltildi

local tCooldowns = {}
local iTimeout = .25

-- Job sistemi değişkenleri
local jobCooldowns = {} -- Her oyuncu için cooldown takibi

-- FİX: Scooter rezervasyon sistemi (SERVER SIDE)
local scooterReservations = {} -- {[scooter] = {player = ply, expireTime = time}}
local playerActiveRentals = {} -- {[player] = {scooter = ent, startTime = time, isPending = bool}}

-- Debug print fonksiyonu
local function DebugPrint(...)
    if gScooters.Config.DebugMode then
        print("[gScooters DEBUG]", ...)
    end
end

local function GC_SpamCheck(sNetMessage, pPlayer)
    tCooldowns[pPlayer] = tCooldowns[pPlayer] or {}
    tCooldowns[pPlayer][sNetMessage] = tCooldowns[pPlayer][sNetMessage] or nil

    if not tCooldowns[pPlayer][sNetMessage] then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    end
    if CurTime() - tCooldowns[pPlayer][sNetMessage] >= iTimeout then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    else
        return false
    end
end

-- FİX: Scooter rezervasyon fonksiyonları
local function ReserveScooter(scooter, player)
    scooterReservations[scooter] = {
        player = player,
        expireTime = CurTime() + 10 -- 10 saniye rezervasyon
    }
    DebugPrint("Scooter", scooter:EntIndex(), "reserved for", player:Nick())
end

local function IsScooterReserved(scooter, player)
    local reservation = scooterReservations[scooter]
    if not reservation then return false end
    
    -- Rezervasyon süresi dolmuş mu?
    if CurTime() > reservation.expireTime then
        scooterReservations[scooter] = nil
        return false
    end
    
    -- Bu oyuncu için mi rezerve edilmiş?
    return reservation.player ~= player
end

local function ClearScooterReservation(scooter)
    scooterReservations[scooter] = nil
    DebugPrint("Scooter reservation cleared for", scooter:EntIndex())
end

-- FİX: Oyuncu jail durumu kontrolü (SERVER SIDE)
local function IsPlayerJailed(player)
    if not IsValid(player) then return true end
    
    -- DarkRP jail kontrolü
    if player.DarkRPJailed or player:getDarkRPVar("jailed") then
        return true
    end
    
    -- ULX jail kontrolü
    if player:GetNWBool("ulx_jailed", false) then
        return true
    end
    
    -- SAM jail kontrolü  
    if player:GetNWBool("sam_jailed", false) then
        return true
    end
    
    -- Ekstra jail kontrolü - team bazlı
    local team = player:Team()
    if team == 1000 or team == TEAM_JAIL then -- Çoğu sunucuda jail team'i
        return true
    end
    
    return false
end

-- FİX: Güçlendirilmiş rental temizlik sistemi
local function ForceCleanupPlayerRental(player, reason)
    if not IsValid(player) then return end
    
    DebugPrint("Force cleaning rental for", player:Nick(), "- Reason:", reason)
    
    local rental = playerActiveRentals[player]
    if rental then
        local scooter = rental.scooter
        local startTime = rental.startTime
        local isPending = rental.isPending
        
        -- Eğer pending değilse ücret al
        if not isPending and startTime then
            local duration = CurTime() - startTime
            gScooters:BillPlayer(player, duration)
            DebugPrint("Billed player", player:Nick(), "for", duration, "seconds")
        end
        
        -- Scooter temizliği
        if IsValid(scooter) then
            scooter.StartRentTime = nil
            scooter.GC_RenterSteamID = nil
            scooter.GC_IsRentalPending = nil
            ClearScooterReservation(scooter)
        end
        
        -- Player temizliği
        player.GC_ActiveScooter = nil
        player.GC_ScooterRentStartTime = nil
        player.GC_RentalPending = nil
        playerActiveRentals[player] = nil
    end
    
    -- Rezervasyonları da temizle
    for scooter, reservation in pairs(scooterReservations) do
        if reservation.player == player then
            scooterReservations[scooter] = nil
        end
    end
    
    -- UI'ı kapat
    net.Start("gScooters.Net.ResetScooterUI")
    net.WriteEntity(NULL)
    net.Send(player)
    
    DebugPrint("Force cleanup completed for", player:Nick())
end

-- Kemik sıfırlama fonksiyonu
local function ResetPlayerBones(ply)
    if not IsValid(ply) then return end
    
    -- Tüm kemikleri sıfırla
    for i = 0, ply:GetBoneCount() - 1 do
        ply:ManipulateBoneScale(i, Vector(1, 1, 1))
        ply:ManipulateBoneAngles(i, Angle(0, 0, 0))
        ply:ManipulateBonePosition(i, Vector(0, 0, 0))
    end
    
    -- Model yenileme
    timer.Simple(0.1, function()
        if IsValid(ply) then
            local model = ply:GetModel()
            ply:SetModel(model)
            ply:ResetSequence(ply:LookupSequence("idle_all_01"))
        end
    end)
end

-- Toplanabilir scooter sayısını kontrol et
local function CountCollectableScooters()
    local count = 0
    
    if gScooters.RackEntities and table.Count(gScooters.RackEntities) > 0 then 
        for rackKey, tScooters in pairs(gScooters.RackEntities) do
            for _, eScooter in pairs(tScooters) do
                if IsValid(eScooter) then
                    local bCanBeCollected = false
                    
                    if eScooter.GC_OriginalSpawnPos then
                        local movedDistance = (eScooter:GetPos() - eScooter.GC_OriginalSpawnPos):Length()
                        if movedDistance > gScooters.Config.MinMovedDistance then
                            bCanBeCollected = true
                        end
                    elseif eScooter.GC_FirstTimeUsed then
                        bCanBeCollected = true
                    end
                    
                    if bCanBeCollected then
                        if not IsValid(eScooter:GetDriver()) then
                            if not eScooter.GC_RenterSteamID and not eScooter.StartRentTime then
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end
    end
    
    return count
end

-- FİX: Güçlendirilmiş scooter giriş kontrolü
hook.Add("CanPlayerEnterVehicle", "gScooters.Hook.OnScooterUse", function(pPlayer, eScooter)
    if eScooter.gScooter and not eScooter.GC_Enterable then
        -- FİX: Jail kontrolü
        if IsPlayerJailed(pPlayer) then
            DebugPrint("Player", pPlayer:Nick(), "is jailed, cannot enter scooter")
            return false
        end
        
        local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]

        if iBlacklist and CurTime() < iBlacklist + (60*5) then
            gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)
        elseif not (pPlayer:Team() == TEAM_MARTI) then
            -- FİX: Scooter rezervasyon kontrolü
            if IsScooterReserved(eScooter, pPlayer) then
                gScooters:ChatMessage("Bu scooter başka birisi tarafından kiralanıyor!", pPlayer)
                return false
            end
            
            -- FİX: Zaten aktif kira kontrolü
            if playerActiveRentals[pPlayer] then
                gScooters:ChatMessage("Zaten aktif bir kiranız var!", pPlayer)
                return false
            end
            
            net.Start("gScooters.Net.OpenScooterUI")
            net.WriteEntity(eScooter)
            net.Send(pPlayer)

            pPlayer.GC_ActiveScooter = eScooter
        end
        
        return false
    end
end)

local aReset = Angle(0, 0, 0)

-- GELİŞTİRİLMİŞ HandleEnd FUNCTION
function gScooters:HandleEnd(eScooter_param, pPlayer)
    if not IsValid(pPlayer) then
        DebugPrint("HandleEnd called but pPlayer is INVALID.")
        return false
    end
    
    DebugPrint("HandleEnd CALLED for player:", pPlayer:Nick())

    local rental = playerActiveRentals[pPlayer]
    if rental then
        local scooter = rental.scooter
        local startTime = rental.startTime
        local isPending = rental.isPending
        
        -- ÖZEL DURUM: Eğer kira henüz pending durumda ise (5 saniye bitmemiş)
        if isPending then
            DebugPrint("Cancelling PENDING rental for", pPlayer:Nick())
            
            -- Pending kira iptal - ücret alınmaz
            if IsValid(scooter) then
                scooter.StartRentTime = nil
                scooter.GC_RenterSteamID = nil
                scooter.GC_IsRentalPending = nil
                ClearScooterReservation(scooter)
            end
            
            -- Oyuncu bilgilerini temizle
            pPlayer.GC_ActiveScooter = nil
            pPlayer.GC_ScooterRentStartTime = nil
            pPlayer.GC_RentalPending = nil
            playerActiveRentals[pPlayer] = nil
            
            -- UI sıfırlama mesajını gönder
            net.Start("gScooters.Net.ResetScooterUI")
            net.WriteEntity(NULL)
            net.Send(pPlayer)
            
            ResetPlayerBones(pPlayer)
            
            DebugPrint("Pending rental cancelled, no charge applied for", pPlayer:Nick())
            return true
        end

        -- Normal aktif kira bitirme
        local scooterToLogForUI = scooter
        if IsValid(eScooter_param) and eScooter_param == scooter then
            scooterToLogForUI = eScooter_param
        end
        
        DebugPrint("Processing active rental with scooter EntIndex:", (IsValid(scooterToLogForUI) and scooterToLogForUI:EntIndex() or "NIL_OR_INVALID"))

        -- Oyuncuyu faturalandır
        if startTime then
            gScooters:BillPlayer(pPlayer, CurTime() - startTime)
            DebugPrint("Player", pPlayer:Nick(), "BILLED. Duration:", tostring(CurTime() - startTime))
        end

        -- UI sıfırlama mesajını gönder
        net.Start("gScooters.Net.ResetScooterUI")
        if IsValid(scooterToLogForUI) then 
            net.WriteEntity(scooterToLogForUI)
        else
            net.WriteEntity(NULL)
        end
        net.Send(pPlayer)
        DebugPrint("ResetScooterUI sent to", pPlayer:Nick())
        
        -- Scooter durumunu temizle
        if IsValid(scooterToLogForUI) then
            scooterToLogForUI.StartRentTime = nil
            scooterToLogForUI.GC_RenterSteamID = nil
            scooterToLogForUI.GC_IsRentalPending = nil
            ClearScooterReservation(scooterToLogForUI)
        end

        -- Oyuncunun kira durumunu temizle
        pPlayer.GC_ActiveScooter = nil
        pPlayer.GC_ScooterRentStartTime = nil
        pPlayer.GC_RentalPending = nil
        playerActiveRentals[pPlayer] = nil

        -- Oyuncu kemik manipülasyonunu sıfırla
        if IsValid(pPlayer) then
            ResetPlayerBones(pPlayer)
            
            -- VCMod düzeltmesi
            if VC and IsValid(scooterToLogForUI) and not SVMOD then 
                scooterToLogForUI:VC_repairFull_Admin()
            end
        end

        -- Scooter su içindeyse yeniden spawn et
        if IsValid(scooterToLogForUI) and scooterToLogForUI:IsVehicleBodyInWater() then
            DebugPrint("Scooter was in water, respawning.")
            local eNewScooter = gScooters:CreateScooter(scooterToLogForUI.OriginalPos, scooterToLogForUI.OriginalAngle)
            if IsValid(eNewScooter) then
                table.insert(gScooters.Entities, eNewScooter)
                if scooterToLogForUI.GC_OriginalRack and gScooters.RackEntities and gScooters.RackEntities[scooterToLogForUI.GC_OriginalRack] then
                    table.insert(gScooters.RackEntities[scooterToLogForUI.GC_OriginalRack], eNewScooter)
                    eNewScooter.GC_OriginalRack = scooterToLogForUI.GC_OriginalRack
                end
            end
            scooterToLogForUI:Remove() 
        end
        
        DebugPrint("HandleEnd finished successfully for", pPlayer:Nick())
        return true
    else
        DebugPrint("No active rental state found for player", pPlayer:Nick())
    end
    return false 
end

hook.Add("PlayerLeaveVehicle", "gScooters.Hook.OnScooterExit", function(pPlayer, eScooter)
    if IsValid(eScooter) and eScooter.gScooter then
        gScooters:HandleEnd(eScooter, pPlayer)
    end
end)

hook.Add("PostPlayerDeath", "gScooters.Hook.Death", function(pPlayer)
    if not IsValid(pPlayer) then return end
    
    -- Önce kemikleri sıfırla
    ResetPlayerBones(pPlayer)
    
    -- Sonra kira işlemlerini bitir
    ForceCleanupPlayerRental(pPlayer, "player death")
end)

-- FİX: Jail hook'ları - server tarafında
hook.Add("OnPlayerChangedTeam", "gScooters.Hook.JailTeamChange", function(pPlayer, oldTeam, newTeam)
    if not IsValid(pPlayer) then return end
    
    -- Jail team kontrolü
    if newTeam == 1000 or newTeam == TEAM_JAIL then
        ForceCleanupPlayerRental(pPlayer, "jailed via team change")
        return
    end
    
    -- Normal team değişimi için eski sistem
    ForceCleanupPlayerRental(pPlayer, "team change")
end)

-- FİX: DarkRP jail hook'u
if DarkRP then
    hook.Add("playerArrested", "gScooters.Hook.DarkRPJail", function(pPlayer, time, cop)
        ForceCleanupPlayerRental(pPlayer, "DarkRP arrested")
    end)
    
    hook.Add("playerUnArrested", "gScooters.Hook.DarkRPUnjail", function(pPlayer)
        DebugPrint("Player", pPlayer:Nick(), "unjailed")
    end)
end

-- FİX: ULX jail hook'u
hook.Add("ULXJail", "gScooters.Hook.ULXJail", function(pPlayer)
    ForceCleanupPlayerRental(pPlayer, "ULX jailed")
end)

hook.Add("ULXUnjail", "gScooters.Hook.ULXUnjail", function(pPlayer)
    DebugPrint("Player", pPlayer:Nick(), "ULX unjailed")
end)

-- FİX: Pozisyon kontrolü - jail teleport algılama
local playerLastPositions = {}
hook.Add("PlayerTick", "gScooters.Hook.JailTeleportDetection", function(pPlayer)
    if not IsValid(pPlayer) then return end
    if not playerActiveRentals[pPlayer] then return end
    
    local currentPos = pPlayer:GetPos()
    local lastPos = playerLastPositions[pPlayer]
    
    if lastPos then
        local distance = currentPos:Distance(lastPos)
        
        -- Büyük mesafe = teleport (jail olabilir)
        if distance > 2000 then
            timer.Simple(0.5, function() -- Kısa gecikme ile kontrol et
                if IsValid(pPlayer) and IsPlayerJailed(pPlayer) then
                    ForceCleanupPlayerRental(pPlayer, "detected jail teleport")
                end
            end)
        end
    end
    
    playerLastPositions[pPlayer] = currentPos
end)

hook.Add("PlayerButtonDown", "gScooters.Hook.ScooterKeyDown", function(pPlayer, iKey)
    if IsValid(pPlayer) and IsValid(pPlayer:GetVehicle()) and pPlayer:GetVehicle().gScooter then
        local eScooter = pPlayer:GetVehicle()

        if iKey == KEY_R then
            eScooter:EmitSound("vcmod/horn/ding.wav")
        end
    end
end)

hook.Add("PlayerButtonUp", "gScooters.Hook.ScooterKeyUp", function(pPlayer, iKey)
    if IsValid(pPlayer) and IsValid(pPlayer:GetVehicle()) and pPlayer:GetVehicle().gScooter then
        local eScooter = pPlayer:GetVehicle()

        if iKey == KEY_LALT then
            if eScooter.Wheelie then
                for _, eEnt in ipairs(eScooter.Wheelie) do
                    if IsValid(eEnt) then eEnt:Remove() end
                end
            end
        end
    end
end)

hook.Add("PlayerGiveSWEP", "gScooters.Hook.DeployTool", function(pPlayer, sClass)
    if sClass == "scooter_admintool" and gScooters.Config.AdminGroups[pPlayer:GetUserGroup()] then
        net.Start("gScooters.Net.OpenAdminUI")
        net.Send(pPlayer)
    end
end)

hook.Add("InitPostEntity", "gScooters.Hook.SpawnEntities", function()
    timer.Simple(10, function() gScooters:SpawnEntities() end)
end)

hook.Add("PostCleanupMap", "gScooters.Hook.PostCleanupMap", function()
    gScooters:SpawnEntities()
end)

-- Van'a binince hemen cooldown başlat
hook.Add("PlayerEnteredVehicle", "gScooters.Hook.VanEntered", function(pPlayer, vehicle, role)
    if IsValid(vehicle) and vehicle:GetVehicleClass() == "merc_sprinter_swb_lw" and pPlayer:Team() == TEAM_MARTI then
        local playerSteamID = pPlayer:SteamID64()
        
        -- Eğer cooldown yoksa hemen başlat
        if not jobCooldowns[playerSteamID] and not pPlayer.ActiveJob then
            jobCooldowns[playerSteamID] = CurTime() + gScooters.Config.JobCooldown
            print("[gScooters] Job cooldown started immediately for", pPlayer:Nick())
            
            -- Hemen bilgilendirme mesajı gönder
            gScooters:ChatMessage("Van'a bindiniz! Merkez size görev hazırlıyor...", pPlayer)
            
            -- Oyuncuya cooldown bilgisi gönder
            timer.Simple(0.5, function() -- Küçük gecikme ile UI'ın yüklenmesini bekle
                if IsValid(pPlayer) then
                    net.Start("gScooters.Net.JobCooldownStart")
                    net.WriteFloat(gScooters.Config.JobCooldown)
                    net.Send(pPlayer)
                end
            end)
        end
    end
    
    -- Scooter'a binme kontrolü
    if IsValid(vehicle) and vehicle.gScooter then
        -- İlk kez binildiğinde işaretle
        if not vehicle.GC_FirstTimeUsed then
            vehicle.GC_FirstTimeUsed = true
            print("[gScooters] Scooter marked as moved for first time by", pPlayer:Nick())
        end
        
        -- Scooter'a binerken kemikleri ayarla
        if not VC then
            for sBone, aAngle in pairs(gScooters.Bones) do
                local boneID = pPlayer:LookupBone(sBone)
                if boneID then
                    pPlayer:ManipulateBoneAngles(boneID, aAngle)
                end
            end
        end
    else
        -- Başka bir araca binerse kemikleri sıfırla
        timer.Simple(0.1, function()
            if IsValid(pPlayer) then
                ResetPlayerBones(pPlayer)
            end
        end)
    end
end)

-- DÜZELTME: Job timer'ını kaldır ve yeniden oluştur - toplanabilir scooter kontrolü düzeltildi
if timer.Exists("gScooters.Timer.Job") then
    timer.Remove("gScooters.Timer.Job")
end

timer.Create("gScooters.Timer.Job", 15, 0, function() -- 15 saniyede bir kontrol et
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer:Team() == TEAM_MARTI and IsValid(pPlayer.GC_Van) and pPlayer:GetVehicle() == pPlayer.GC_Van then 
            
            local playerSteamID = pPlayer:SteamID64()
            local currentTime = CurTime()
            
            -- Cooldown bitmişse ve aktif job yoksa
            if jobCooldowns[playerSteamID] and currentTime >= jobCooldowns[playerSteamID] and not pPlayer.ActiveJob then
                
                -- ÖNEMLİ FİX: Önce toplanabilir scooter sayısını kontrol et
                local collectableCount = CountCollectableScooters()
                print("[gScooters] Checking collectable scooters for", pPlayer:Nick(), "- Found:", collectableCount)
                
                if collectableCount >= gScooters.Config.MinCollectableScooters then
                    -- Yeterli scooter var, görev hazır
                    pPlayer.CanAcceptJob = true
                    
                    -- Cooldown'ı sıfırla
                    jobCooldowns[playerSteamID] = nil
                    
                    -- UI'ı kapat ve görev hazır bildir
                    net.Start("gScooters.Net.JobCooldownEnd")
                    net.Send(pPlayer)
 
                    if gScooters.RackEntities and table.Count(gScooters.RackEntities) > 0 then 
                        -- Tüm rack'lerden toplanabilir scooterları topla
                        local tCollectableScooters = {}
                        
                        for rackKey, tScooters in pairs(gScooters.RackEntities) do
                            for _, eScooter in pairs(tScooters) do
                                if IsValid(eScooter) then
                                    -- Scooter hareket ettirilmiş mi kontrol et
                                    local bCanBeCollected = false
                                    
                                    if eScooter.GC_OriginalSpawnPos then
                                        local movedDistance = (eScooter:GetPos() - eScooter.GC_OriginalSpawnPos):Length()
                                        if movedDistance > gScooters.Config.MinMovedDistance then
                                            bCanBeCollected = true
                                        end
                                    elseif eScooter.GC_FirstTimeUsed then
                                        bCanBeCollected = true
                                    end
                                    
                                    if bCanBeCollected then
                                        if not IsValid(eScooter:GetDriver()) then
                                            if not eScooter.GC_RenterSteamID and not eScooter.StartRentTime then
                                                table.insert(tCollectableScooters, eScooter)
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- Görev için scooter seç (maksimum 5)
                        local tScootersToSend = {}
                        local maxScooters = math.min(#tCollectableScooters, gScooters.Config.ScooterPickupRequirement)
                        
                        for i = 1, maxScooters do
                            local randomIndex = math.random(1, #tCollectableScooters)
                            table.insert(tScootersToSend, tCollectableScooters[randomIndex])
                            table.remove(tCollectableScooters, randomIndex)
                        end

                        -- Görev gönder
                        net.Start("gScooters.Net.SendJob")
                        net.WriteUInt(#tScootersToSend, 22)
                        for _, eScooter in pairs(tScootersToSend) do
                            if IsValid(eScooter) then 
                                net.WriteEntity(eScooter) 
                            end
                        end
                        net.Send(pPlayer)
                        
                        print("[gScooters] Job sent to", pPlayer:Nick(), "with", #tScootersToSend, "collectable scooters")
                    end
                    
                else
                    -- Yeterli scooter yok, kısa cooldown devam et
                    print("[gScooters] Not enough collectable scooters for", pPlayer:Nick(), ". Found:", collectableCount, "Required:", gScooters.Config.MinCollectableScooters)
                    
                    -- 30 saniye sonra tekrar dene
                    jobCooldowns[playerSteamID] = currentTime + 30
                    
                    gScooters:ChatMessage("Şu anda toplanabilir scooter yok, 30 saniye sonra tekrar kontrol edilecek.", pPlayer)
                    
                    net.Start("gScooters.Net.JobCooldownStart")
                    net.WriteFloat(30)
                    net.Send(pPlayer)
                end
                
            elseif jobCooldowns[playerSteamID] and not pPlayer.ActiveJob then
                -- Hala cooldown'daysa oyuncuya kalan süreyi gönder (15 saniyede bir)
                local remainingTime = jobCooldowns[playerSteamID] - currentTime
                if remainingTime > 0 then
                    net.Start("gScooters.Net.JobCooldownUpdate")
                    net.WriteFloat(remainingTime)
                    net.Send(pPlayer)
                end
            end
        else
            -- Oyuncu artık van'da değilse cooldown'ı sıfırla
            local playerSteamID = pPlayer:SteamID64()
            if jobCooldowns[playerSteamID] then
                jobCooldowns[playerSteamID] = nil
                
                -- Cooldown UI'ını kapat
                net.Start("gScooters.Net.JobCooldownEnd")
                net.Send(pPlayer)
                print("[gScooters] Cooldown cleared for", pPlayer:Nick(), "- not in van")
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "gScooters.Hook.JobAcceptKey", function(pPlayer, iKey)
    if IsFirstTimePredicted() and IsValid(pPlayer.GC_Van) then
        if iKey == gScooters.Config.JobAcceptKey then
            -- Önce cooldown kontrolü
            local playerSteamID = pPlayer:SteamID64()
            if jobCooldowns[playerSteamID] then
                local remainingTime = jobCooldowns[playerSteamID] - CurTime()
                if remainingTime > 0 then
                    local minutes = math.floor(remainingTime / 60)
                    local seconds = math.floor(remainingTime % 60)
                    gScooters:ChatMessage(string.format("Merkez hala hazırlık yapıyor! Kalan süre: %02d:%02d", minutes, seconds), pPlayer)
                    return
                end
            end
            
            -- Normal job accept kontrolü
            if pPlayer.CanAcceptJob and pPlayer:GetVehicle() == pPlayer.GC_Van then
                pPlayer.CanAcceptJob = false
                pPlayer.ActiveJob = true
                gScooters:ChatMessage(string.format(gScooters:GetPhrase("job_start"), gScooters:GetPhrase("numbers")[gScooters.Config.ScooterPickupRequirement] or tostring(gScooters.Config.ScooterPickupRequirement)), pPlayer)
                
                -- Cooldown UI'ını kapat
                net.Start("gScooters.Net.JobCooldownEnd")
                net.Send(pPlayer)
            elseif not pPlayer.CanAcceptJob then
                gScooters:ChatMessage("Şu anda kabul edebileceğiniz bir görev yok!", pPlayer)
            end
            
        elseif iKey == gScooters.Config.JobSellKey and pPlayer.ActiveJob and pPlayer.GC_Van.GC_ScooterEnts and #pPlayer.GC_Van.GC_ScooterEnts > 0 and pPlayer.GC_Van:GetPos():DistToSqr(pPlayer.GC_Van.GC_NPC:GetPos()) < 490000 then
            pPlayer.ActiveJob = false

            -- FİX: Toplanan scooter sayısını hesapla
            local scooterCount = #pPlayer.GC_Van.GC_ScooterEnts
            print("[gScooters] Player", pPlayer:Nick(), "selling", scooterCount, "scooters")

            for iIndex, eEnt in ipairs(pPlayer.GC_Van.GC_ScooterEnts) do
                if IsValid(eEnt) then
                    if IsValid(eEnt:GetParent()) then
                        eEnt:SetParent(nil)
                    end
                
                    local initialPos = eEnt.GC_OriginalSpawnPos 
                    local initialAng = eEnt.GC_OriginalSpawnAng
                    local originalRackID = eEnt.GC_OriginalRack

                    eEnt:Remove() 

                    if initialPos and initialAng then
                        local eNewScooter = gScooters:CreateScooter(initialPos, initialAng) 
                        if IsValid(eNewScooter) then
                            table.insert(gScooters.Entities, eNewScooter)
                            if originalRackID and gScooters.RackEntities and gScooters.RackEntities[originalRackID] then
                                table.insert(gScooters.RackEntities[originalRackID], eNewScooter)
                                eNewScooter.GC_OriginalRack = originalRackID 
                            end
                        end
                    else
                        print("[gScooters Error] Scooter satışı sonrası ilk spawn pozisyonu bulunamadı! Prop Index: " .. tostring(iIndex))
                    end
                end
            end
            
            pPlayer.GC_Van.GC_ScooterEnts = {} 

            net.Start("gScooters.Net.ResetJobs")
            net.Send(pPlayer)
            
            -- FİX: Scooter başına ödeme hesapla
            local totalPayment = scooterCount * gScooters.Config.JobPaymentPerScooter
            print("[gScooters] Calculating payment:", scooterCount, "scooters x", gScooters.Config.JobPaymentPerScooter, "=", totalPayment)
            
            gScooters:ChatMessage(string.format(gScooters:GetPhrase("job_end"), gScooters:FormatMoney(totalPayment)), pPlayer)
            gScooters:ModifyMoney(pPlayer, totalPayment)
            pPlayer.GC_Van:SetNWInt("GC_ScooterAmount", 0)
            
            -- İş bitince cooldown'ı tekrar başlat
            local playerSteamID = pPlayer:SteamID64()
            jobCooldowns[playerSteamID] = CurTime() + gScooters.Config.JobCooldown
            
            net.Start("gScooters.Net.JobCooldownStart")
            net.WriteFloat(gScooters.Config.JobCooldown)
            net.Send(pPlayer)
        end
    end
end)

-- Oyuncu meslek değiştirdiğinde cooldown'ı sıfırla
hook.Add("PlayerChangedTeam", "gScooters.Hook.SwitchJob", function(pPlayer)
    if IsValid(pPlayer.GC_Van) then
        pPlayer.GC_Van:Remove()
        net.Start("gScooters.Net.ResetJobs")
        net.Send(pPlayer)
    end
    
    -- Cooldown'ı sıfırla
    local playerSteamID = pPlayer:SteamID64()
    if jobCooldowns[playerSteamID] then
        jobCooldowns[playerSteamID] = nil
        
        -- Cooldown UI'ını kapat
        net.Start("gScooters.Net.JobCooldownEnd")
        net.Send(pPlayer)
    end
    
    pPlayer.CanAcceptJob = false 
    pPlayer.ActiveJob = false    
end) 

-- Alternatif hareket kontrolü - fizik objesi hareket ettiğinde
hook.Add("EntityRemoved", "gScooters.Hook.CleanupScooterMarkers", function(ent)
    if IsValid(ent) and ent.gScooter then
        -- Scooter silindiğinde temizlik işlemleri
        ent.GC_FirstTimeUsed = nil
        
        -- Rezervasyonları temizle
        scooterReservations[ent] = nil
        
        -- Aktif kiralardan temizle
        for player, rental in pairs(playerActiveRentals) do
            if rental.scooter == ent then
                playerActiveRentals[player] = nil
            end
        end
    end
end)

-- Oyuncu disconnect olduğunda temizlik
hook.Add("PlayerDisconnected", "gScooters.Hook.PlayerDisconnectCleanup", function(pPlayer)
    local playerSteamID = pPlayer:SteamID64()
    if jobCooldowns[playerSteamID] then
        jobCooldowns[playerSteamID] = nil
        print("[gScooters] Cleaned up job cooldown for disconnected player")
    end
    
    -- Pozisyon geçmişini temizle
    playerLastPositions[pPlayer] = nil
    
    -- Rezervasyonları temizle
    for scooter, reservation in pairs(scooterReservations) do
        if reservation.player == pPlayer then
            scooterReservations[scooter] = nil
        end
    end
    
    -- Aktif kirayı temizle
    ForceCleanupPlayerRental(pPlayer, "player disconnect")
end)

-- FİX: Periyodik temizlik timer'ı
timer.Create("gScooters.Timer.ReservationCleanup", 5, 0, function()
    local currentTime = CurTime()
    local cleanedCount = 0
    
    -- Süresi dolmuş rezervasyonları temizle
    for scooter, reservation in pairs(scooterReservations) do
        if currentTime > reservation.expireTime then
            scooterReservations[scooter] = nil
            cleanedCount = cleanedCount + 1
        end
    end
    
    if cleanedCount > 0 then
        DebugPrint("Cleaned", cleanedCount, "expired reservations")
    end
    
    -- Jail durumundaki oyuncuları kontrol et
    for player, rental in pairs(playerActiveRentals) do
        if IsValid(player) and IsPlayerJailed(player) then
            ForceCleanupPlayerRental(player, "periodic jail check")
        end
    end
end)

-- PERİYODİK KONTROL SİSTEMİ - KİRA VE KEMİK KONTROLÜ
if timer.Exists("gScooters_RentalValidityGlobalCheck") then
    timer.Remove("gScooters_RentalValidityGlobalCheck")
end

timer.Create("gScooters_RentalValidityGlobalCheck", 5, 0, function() -- 5 saniyede bir kontrol
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer:IsPlayer() then
            -- KEMİK KONTROLÜ
            local needsBoneFix = false
            local inScooter = IsValid(pPlayer:GetVehicle()) and pPlayer:GetVehicle().gScooter
            
            -- Eğer oyuncu scooter'da değilse ve kemik manipülasyonu varsa düzelt
            if not inScooter then
                for i = 0, pPlayer:GetBoneCount() - 1 do
                    local scale = pPlayer:GetManipulateBoneScale(i)
                    local angles = pPlayer:GetManipulateBoneAngles(i)
                    local pos = pPlayer:GetManipulateBonePosition(i)
                    
                    if scale ~= Vector(1, 1, 1) or angles ~= Angle(0, 0, 0) or pos ~= Vector(0, 0, 0) then
                        needsBoneFix = true
                        break
                    end
                end
                
                if needsBoneFix then
                    DebugPrint("Bone fix needed for", pPlayer:Nick())
                    ResetPlayerBones(pPlayer)
                end
            end
            
            -- KİRA KONTROLÜ - YENİ SİSTEM
            local rental = playerActiveRentals[pPlayer]
            if rental then
                local scooter = rental.scooter
                local isPending = rental.isPending
                
                -- Scooter artık geçerli değil mi?
                if not IsValid(scooter) then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "has rental record but scooter is invalid")
                    playerActiveRentals[pPlayer] = nil
                    
                -- Pending kira çok uzun süredir bekliyor mu? (15 saniyeden fazla)
                elseif isPending and (CurTime() - rental.startTime) > 15 then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "has pending rental too long - cancelling")
                    ForceCleanupPlayerRental(pPlayer, "pending too long")
                    
                -- Oyuncu scooter'da değil ama aktif kira var ve pending değil
                elseif not isPending and pPlayer:GetVehicle() ~= scooter then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "not in rented scooter")
                    ForceCleanupPlayerRental(pPlayer, "not in scooter")
                    
                -- Scooter başka birisi tarafından kullanılıyor
                elseif IsValid(scooter:GetDriver()) and scooter:GetDriver() ~= pPlayer then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "'s rented scooter is being used by someone else")
                    ForceCleanupPlayerRental(pPlayer, "scooter used by other")
                end
            end
            
            -- Ters kontrol: Oyuncu scooter'da ama kira kaydı yok
            local currentVehicle = pPlayer:GetVehicle()
            if IsValid(currentVehicle) and currentVehicle.gScooter then
                if not playerActiveRentals[pPlayer] or playerActiveRentals[pPlayer].scooter ~= currentVehicle then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "in scooter but no rental record - forcing exit")
                    pPlayer:ExitVehicle()
                    ResetPlayerBones(pPlayer)
                end
            end
        end
    end
end)
print("[gScooters] Enhanced server-side rental system initialized.")

-- DISCONNECT HOOK
hook.Add("PlayerDisconnected", "gScooters.Hook.PlayerDisconnect", function(pPlayer)
    if IsValid(pPlayer) then
        -- Kemikleri sıfırla
        ResetPlayerBones(pPlayer)
        
        -- Kira temizliği
        ForceCleanupPlayerRental(pPlayer, "player disconnect")
    end
end)

-- KEMİK BOZULMA ÖNLEYİCİ
hook.Add("PlayerSpawn", "gScooters.Hook.SpawnBoneFix", function(pPlayer)
    timer.Simple(0.5, function()
        if IsValid(pPlayer) then
            ResetPlayerBones(pPlayer)
        end
    end)
end)