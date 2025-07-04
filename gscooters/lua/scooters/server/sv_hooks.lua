-- gscooters/lua/scooters/server/sv_hooks.lua
-- Basitleştirilmiş server tarafı kodları

local tCooldowns = {}
local iTimeout = .25

-- Job sistemi değişkenleri
local jobCooldowns = {}

-- UI kilitleme sistemi
local activeScooterUIs = {} -- {[scooter] = player} UI açık olan scooterları takip eder

-- Debug print fonksiyonu
local function DebugPrint(...)
    if gScooters.Config.DebugMode then
        print("[gScooters DEBUG]", ...)
    end
end

-- Oyuncu jail durumu kontrolü
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
    if team == 1000 or team == TEAM_JAIL then
        return true
    end
    
    return false
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

-- RentScooter network receiver
net.Receive("gScooters.Net.RentScooter", function(len, pPlayer)
    if not GC_SpamCheck("gScooters.Net.RentScooter", pPlayer) then return end
    local eScooter = net.ReadEntity()
    
    -- UI kilidini kaldır
    if activeScooterUIs[eScooter] == pPlayer then
        activeScooterUIs[eScooter] = nil
    end

    -- Temel kontroller
    if not IsValid(pPlayer) or not IsValid(eScooter) then return end
    if not eScooter.gScooter then return end
    if IsValid(eScooter:GetPassenger(0)) then return end
    if pPlayer:Team() == TEAM_MARTI then return end

    -- Para kontrolü
    if not gScooters:CanAfford(pPlayer, gScooters.Config.RentalRate) then 
        gScooters:ChatMessage(gScooters:GetPhrase("cannot_afford"), pPlayer)
        return
    end

    -- Jail kontrolü
    if IsPlayerJailed(pPlayer) then
        DebugPrint("Player", pPlayer:Nick(), "is jailed, cannot rent scooter")
        gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!", pPlayer)
        return
    end

    -- Blacklist kontrolü
    local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]
    if iBlacklist and CurTime() < iBlacklist + (60*5) then 
        gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)
        return 
    end

    -- Oyuncunun başka bir araçta olup olmadığını kontrol et
    if IsValid(pPlayer:GetVehicle()) then
        DebugPrint("Player already in a vehicle")
        gScooters:ChatMessage("Zaten bir araçtasınız!", pPlayer)
        return
    end
    
    -- Zaten işlem yapılıyor mu kontrolü
    if pPlayer.GC_RentalProcessing then
        DebugPrint("Rental already processing for player")
        return
    end

    -- Geçici bir flag koy
    pPlayer.GC_RentalProcessing = true
    
    -- Scooter'ı kiralanabilir yap
    eScooter.GC_Enterable = true
    
    -- Ses efekti
    eScooter:EmitSound("gscooters/scooter_unlock.wav", 45)
    
    -- Fizik ayarları
    if IsValid(eScooter:GetPhysicsObject()) then
        eScooter:GetPhysicsObject():EnableMotion(true)
    end
    eScooter:Fire("TurnOff")

    -- Önce kemik ayarlarını yap (binmeden önce)
    if not VC or SVMOD then
        for sBone, aAngle in pairs(gScooters.Bones) do
            local boneId = pPlayer:LookupBone(sBone)
            if boneId then
                pPlayer:ManipulateBoneAngles(boneId, aAngle) 
            end
        end
    end
    
    -- Oyuncuyu bindir
    pPlayer:EnterVehicle(eScooter)
    
    -- 0.3 saniye sonra kontrol et
    local checkTimerID = "GC_RentCheck_" .. pPlayer:SteamID64() .. "_" .. eScooter:EntIndex()
    timer.Create(checkTimerID, 0.3, 1, function()
        -- Flag'i kaldır
        if IsValid(pPlayer) then
            pPlayer.GC_RentalProcessing = nil
        end
        
        if not IsValid(pPlayer) or not IsValid(eScooter) then
            if IsValid(eScooter) then
                eScooter.GC_Enterable = false
            end
            return
        end
        
        -- Oyuncu scooter'a binebildi mi?
        if pPlayer:GetVehicle() ~= eScooter then
            -- Binemedi, temizlik yap
            DebugPrint("Player couldn't enter scooter")
            eScooter.GC_Enterable = false
            
            -- Kemikleri sıfırla
            ResetPlayerBones(pPlayer)
            
            gScooters:ChatMessage("Scooter'a binilemedi! Lütfen yakınlaşıp tekrar deneyin.", pPlayer)
            return
        end
        
        -- Başarıyla bindi
        DebugPrint("Player successfully entered scooter, starting rental")
        eScooter.GC_Enterable = false
        
        -- VCMod yakıt ayarı
        if VC and not SVMOD then
            eScooter:VC_fuelSet(eScooter:VC_fuelGetMax())
        end
        
        -- Kira başlangıcını kaydet
        pPlayer.GC_ScooterRentStartTime = CurTime()
        pPlayer.GC_ActiveScooter = eScooter
        pPlayer.GC_PendingRental = true
        
        -- Scooter bilgisini kaydet
        pPlayer.GC_PendingScooterEntIndex = eScooter:EntIndex()
        
        -- 5 saniye sonra scooter'ı aktifleştir
        local activateTimerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. eScooter:EntIndex()
        timer.Create(activateTimerID, 5, 1, function()
            if not IsValid(pPlayer) or not IsValid(eScooter) then
                DebugPrint("Entity became invalid during pending rental")
                return
            end
            
            -- Son kontrol - oyuncu hala scooter'da mı?
            if pPlayer:GetVehicle() == eScooter and pPlayer.GC_PendingRental then
                -- Evet, kirayı aktifleştir
                eScooter:Fire("TurnOn")
                pPlayer.GC_PendingRental = nil
                pPlayer.GC_PendingScooterEntIndex = nil
                DebugPrint("Rental ACTIVATED for", pPlayer:Nick())
            else
                -- Hayır, temizlik yap
                DebugPrint("Player left scooter during pending rental")
                
                pPlayer.GC_ScooterRentStartTime = nil
                pPlayer.GC_ActiveScooter = nil
                pPlayer.GC_PendingRental = nil
                pPlayer.GC_PendingScooterEntIndex = nil
                
                -- Kemikleri sıfırla
                ResetPlayerBones(pPlayer)
            end
        end)
    end)
end)

-- Scooter giriş kontrolü - UI açma
hook.Add("CanPlayerEnterVehicle", "gScooters.Hook.OnScooterUse", function(pPlayer, eScooter)
    if eScooter.gScooter and not eScooter.GC_Enterable then
        -- Jail kontrolü
        if IsPlayerJailed(pPlayer) then
            DebugPrint("Player", pPlayer:Nick(), "is jailed, cannot enter scooter")
            return false
        end
        
        local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]

        if iBlacklist and CurTime() < iBlacklist + (60*5) then
            gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)
        elseif not (pPlayer:Team() == TEAM_MARTI) then
            -- UI kilidi kontrolü
            if activeScooterUIs[eScooter] and IsValid(activeScooterUIs[eScooter]) and activeScooterUIs[eScooter] ~= pPlayer then
                gScooters:ChatMessage("Bu scooter için zaten bir kiralama işlemi devam ediyor!", pPlayer)
                return false
            end
            
            -- UI'ı kilitle
            activeScooterUIs[eScooter] = pPlayer
            
            net.Start("gScooters.Net.OpenScooterUI")
            net.WriteEntity(eScooter)
            net.Send(pPlayer)

            pPlayer.GC_ActiveScooter = eScooter
            
            -- 30 saniye sonra UI kilidini kaldır (oyuncu menüyü kapatmadıysa)
            timer.Simple(30, function()
                if activeScooterUIs[eScooter] == pPlayer then
                    activeScooterUIs[eScooter] = nil
                end
            end)
        end
        
        return false
    end
end)

function gScooters:HandleEnd(eScooter, pPlayer)
    -- Eğer oyuncu henüz kira başlatmamışsa işlem yapma
    if not pPlayer.GC_ScooterRentStartTime then
        return
    end
    
    -- Kira süresi 5 saniyeden kısaysa (henüz aktif değilse) ücret alma
    local rentDuration = CurTime() - pPlayer.GC_ScooterRentStartTime
    if rentDuration > 5 then
        gScooters:BillPlayer(pPlayer, rentDuration)
    end

    net.Start("gScooters.Net.ResetScooterUI")
    net.WriteEntity(eScooter)
    net.Send(pPlayer)

    pPlayer.GC_ScooterRentStartTime = nil
    pPlayer.GC_ActiveScooter = nil
    pPlayer.GC_PendingRental = nil

    if not IsValid(pPlayer) then return end

    if VC and IsValid(eScooter) and not SVMOD then 
        eScooter:VC_repairFull_Admin()
    else
        ResetPlayerBones(pPlayer)
    end

    if IsValid(eScooter) and eScooter:IsVehicleBodyInWater() then
        local eNewScooter = gScooters:CreateScooter(eScooter.OriginalPos, eScooter.OriginalAngle)
        table.insert(gScooters.Entities, eNewScooter)
        
        if eScooter.GC_OriginalRack and gScooters.RackEntities and gScooters.RackEntities[eScooter.GC_OriginalRack] then
            table.insert(gScooters.RackEntities[eScooter.GC_OriginalRack], eNewScooter)
            eNewScooter.GC_OriginalRack = eScooter.GC_OriginalRack
        end
        
        eScooter:Remove()
    end
end

-- PlayerLeaveVehicle hook'u
hook.Add("PlayerLeaveVehicle", "gScooters.Hook.OnScooterExit", function(pPlayer, eScooter)
    if IsValid(eScooter) and eScooter.gScooter then
        -- Önce pending rental kontrolü yap
        if pPlayer.GC_PendingRental then
            DebugPrint("Player left scooter during pending rental period")
            
            -- Doğru timer'ı iptal et
            local timerID
            if pPlayer.GC_PendingScooterEntIndex then
                timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_PendingScooterEntIndex
            else
                timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. eScooter:EntIndex()
            end
            
            if timer.Exists(timerID) then
                timer.Remove(timerID)
                DebugPrint("Removed pending rental timer:", timerID)
            end
            
            -- Check timer'ı da iptal et
            local checkTimerID = "GC_RentCheck_" .. pPlayer:SteamID64() .. "_" .. eScooter:EntIndex()
            if timer.Exists(checkTimerID) then
                timer.Remove(checkTimerID)
            end
            
            -- Pending rental'ı iptal et
            pPlayer.GC_ScooterRentStartTime = nil
            pPlayer.GC_ActiveScooter = nil
            pPlayer.GC_PendingRental = nil
            pPlayer.GC_PendingScooterEntIndex = nil
            
            -- Kemikleri sıfırla
            ResetPlayerBones(pPlayer)
            
            -- UI'ı kapat
            net.Start("gScooters.Net.ResetScooterUI")
            net.WriteEntity(eScooter)
            net.Send(pPlayer)
            
            -- Scooter'ı kapat
            if IsValid(eScooter) then
                eScooter:Fire("TurnOff")
                eScooter.GC_Enterable = false
            end
            
            gScooters:ChatMessage("Scooter kiralama iptal edildi.", pPlayer)
            return -- HandleEnd'i çağırma
        end
        
        -- Normal kira bitişi
        gScooters:HandleEnd(eScooter, pPlayer)
    end
end)

hook.Add("PostPlayerDeath", "gScooters.Hook.Death", function(pPlayer)
    if not IsValid(pPlayer) then return end
    
    -- Önce kemikleri sıfırla
    ResetPlayerBones(pPlayer)
    
    -- Pending rental timer'larını iptal et
    if pPlayer.GC_PendingScooterEntIndex then
        local timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_PendingScooterEntIndex
        if timer.Exists(timerID) then
            timer.Remove(timerID)
        end
        
        local checkTimerID = "GC_RentCheck_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_PendingScooterEntIndex
        if timer.Exists(checkTimerID) then
            timer.Remove(checkTimerID)
        end
    elseif pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
        local timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_ActiveScooter:EntIndex()
        if timer.Exists(timerID) then
            timer.Remove(timerID)
        end
        
        local checkTimerID = "GC_RentCheck_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_ActiveScooter:EntIndex()
        if timer.Exists(checkTimerID) then
            timer.Remove(checkTimerID)
        end
    end
    
    -- Pending rental durumunu temizle
    if pPlayer.GC_PendingRental then
        pPlayer.GC_PendingRental = nil
        pPlayer.GC_ScooterRentStartTime = nil
        pPlayer.GC_ActiveScooter = nil
        pPlayer.GC_PendingScooterEntIndex = nil
    end
    
    -- Kira kontrolü ve temizlik
    if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
        gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
    end
    
    -- UI kilidini temizle
    for scooter, player in pairs(activeScooterUIs) do
        if player == pPlayer then
            activeScooterUIs[scooter] = nil
        end
    end
end)

-- Jail hook'ları
hook.Add("OnPlayerChangedTeam", "gScooters.Hook.JailTeamChange", function(pPlayer, oldTeam, newTeam)
    if not IsValid(pPlayer) then return end
    
    -- Jail team kontrolü
    if newTeam == 1000 or newTeam == TEAM_JAIL then
        -- Kira kontrolü ve temizlik
        if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
            gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
        end
        
        -- UI'ı kapat
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
    end
end)

-- DarkRP jail hook'u
if DarkRP then
    hook.Add("playerArrested", "gScooters.Hook.DarkRPJail", function(pPlayer, time, cop)
        if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
            gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
        end
        
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
    end)
end

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
    else
        -- Başka bir araca binirse kemikleri sıfırla
        timer.Simple(0.1, function()
            if IsValid(pPlayer) then
                ResetPlayerBones(pPlayer)
            end
        end)
    end
end)

-- Job timer'ı
timer.Create("gScooters.Timer.Job", 15, 0, function()
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer:Team() == TEAM_MARTI and IsValid(pPlayer.GC_Van) and pPlayer:GetVehicle() == pPlayer.GC_Van then 
            
            local playerSteamID = pPlayer:SteamID64()
            local currentTime = CurTime()
            
            -- Cooldown bitmişse ve aktif job yoksa
            if jobCooldowns[playerSteamID] and currentTime >= jobCooldowns[playerSteamID] and not pPlayer.ActiveJob then
                
                -- Toplanabilir scooter sayısını kontrol et
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

            -- Toplanan scooter sayısını hesapla
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
            
            -- Scooter başına ödeme hesapla
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

-- Entity silindiğinde temizlik
hook.Add("EntityRemoved", "gScooters.Hook.CleanupScooterMarkers", function(ent)
    if IsValid(ent) and ent.gScooter then
        -- Scooter silindiğinde temizlik işlemleri
        ent.GC_FirstTimeUsed = nil
        
        -- UI kilidini temizle
        activeScooterUIs[ent] = nil
    end
end)

-- Oyuncu disconnect olduğunda temizlik
hook.Add("PlayerDisconnected", "gScooters.Hook.PlayerDisconnectCleanup", function(pPlayer)
    local playerSteamID = pPlayer:SteamID64()
    if jobCooldowns[playerSteamID] then
        jobCooldowns[playerSteamID] = nil
        print("[gScooters] Cleaned up job cooldown for disconnected player")
    end
    
    -- Pending rental timer'ını iptal et
    if pPlayer.GC_PendingScooterEntIndex then
        local timerID = "GC_ActivateRental_" .. playerSteamID .. "_" .. pPlayer.GC_PendingScooterEntIndex
        if timer.Exists(timerID) then
            timer.Remove(timerID)
        end
        
        local checkTimerID = "GC_RentCheck_" .. playerSteamID .. "_" .. pPlayer.GC_PendingScooterEntIndex
        if timer.Exists(checkTimerID) then
            timer.Remove(checkTimerID)
        end
    elseif pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
        local timerID = "GC_ActivateRental_" .. playerSteamID .. "_" .. pPlayer.GC_ActiveScooter:EntIndex()
        if timer.Exists(timerID) then
            timer.Remove(timerID)
        end
        
        local checkTimerID = "GC_RentCheck_" .. playerSteamID .. "_" .. pPlayer.GC_ActiveScooter:EntIndex()
        if timer.Exists(checkTimerID) then
            timer.Remove(checkTimerID)
        end
    end
    
    -- UI kilidini temizle
    for scooter, player in pairs(activeScooterUIs) do
        if player == pPlayer then
            activeScooterUIs[scooter] = nil
        end
    end
    
    -- Kira kontrolü ve temizlik
    if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
        -- Pending rental durumunu da temizle
        pPlayer.GC_PendingRental = nil
        pPlayer.GC_PendingScooterEntIndex = nil
        gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
    end
end)

-- Oyuncu spawn olduğunda kemik düzeltmesi
hook.Add("PlayerSpawn", "gScooters.Hook.SpawnBoneFix", function(pPlayer)
    timer.Simple(0.5, function()
        if IsValid(pPlayer) then
            ResetPlayerBones(pPlayer)
        end
    end)
end)

-- Periyodik pending rental temizleyici
timer.Create("gScooters.Timer.PendingRentalCleanup", 2, 0, function()
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer.GC_PendingRental then
            -- Pending rental var ama oyuncu scooter'da değil
            if not IsValid(pPlayer:GetVehicle()) or not pPlayer:GetVehicle().gScooter then
                DebugPrint("Cleaning up orphaned pending rental for", pPlayer:Nick())
                
                -- Timer'ı temizle
                if pPlayer.GC_PendingScooterEntIndex then
                    local timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_PendingScooterEntIndex
                    if timer.Exists(timerID) then
                        timer.Remove(timerID)
                    end
                elseif pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
                    local timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_ActiveScooter:EntIndex()
                    if timer.Exists(timerID) then
                        timer.Remove(timerID)
                    end
                end
                
                pPlayer.GC_ScooterRentStartTime = nil
                pPlayer.GC_ActiveScooter = nil
                pPlayer.GC_PendingRental = nil
                pPlayer.GC_PendingScooterEntIndex = nil
                
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
            end
        end
    end
end)

-- Aktif kiralama güvenlik kontrolü (3-4 dakikada bir)
timer.Create("gScooters.Timer.ActiveRentalSafetyCheck", 210, 0, function() -- 3.5 dakika
    local fixedCount = 0
    
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer.GC_ScooterRentStartTime and not pPlayer.GC_PendingRental then
            -- Oyuncunun aktif kirası var ve pending değil (yani 5 saniye geçmiş)
            local currentVehicle = pPlayer:GetVehicle()
            local isInScooter = false
            
            -- Oyuncu bir scooter'da mı kontrol et
            if IsValid(currentVehicle) and currentVehicle.gScooter then
                isInScooter = true
                
                -- Ayrıca doğru scooter'da mı kontrol et
                if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
                    if currentVehicle ~= pPlayer.GC_ActiveScooter then
                        isInScooter = false
                        DebugPrint("Player", pPlayer:Nick(), "is in wrong scooter!")
                    end
                end
            end
            
            -- Oyuncu scooter'da değilse kirayı sonlandır
            if not isInScooter then
                fixedCount = fixedCount + 1
                
                DebugPrint("Safety check: Ending orphaned rental for", pPlayer:Nick())
                
                -- Özür mesajı gönder
                gScooters:ChatMessage(" Özür dileriz, sistemsel bir hata sebebiyle kiralamanız düzgün sonlandırılamamıştı.", pPlayer)
                gScooters:ChatMessage(" Sizden ücret alınmayacak, kiralama iptal edildi.", pPlayer)
                
                -- Timer'ları temizle
                if pPlayer.GC_PendingScooterEntIndex then
                    local timerID = "GC_ActivateRental_" .. pPlayer:SteamID64() .. "_" .. pPlayer.GC_PendingScooterEntIndex
                    if timer.Exists(timerID) then
                        timer.Remove(timerID)
                    end
                end
                
                -- Kirayı ücretsiz sonlandır
                pPlayer.GC_ScooterRentStartTime = nil
                pPlayer.GC_ActiveScooter = nil
                pPlayer.GC_PendingRental = nil
                pPlayer.GC_PendingScooterEntIndex = nil
                
                -- Kemikleri sıfırla
                ResetPlayerBones(pPlayer)
                
                -- UI'ı kapat
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
            end
        end
    end
    
    if fixedCount > 0 then
        print("[gScooters] Safety check fixed", fixedCount, "orphaned rentals")
    end
end)