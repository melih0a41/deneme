-- gscooters/lua/scooters/server/sv_hooks.lua
-- Server tarafında scooter UI kilitleme sistemi

local tCooldowns = {}
local iTimeout = .25

-- Job sistemi değişkenleri
local jobCooldowns = {} -- Her oyuncu için cooldown takibi

-- UI kilitleme sistemi
local activeScooterUIs = {} -- {[scooter] = player} UI açık olan scooterları takip eder

-- Debug print fonksiyonu
local function DebugPrint(...)
    if gScooters.Config.DebugMode then
        print("[gScooters DEBUG]", ...)
    end
end

-- ============= RENTAL KONTROL SİSTEMİ BAŞLANGIÇ =============
-- Aktif kiralamaları takip için global tablo
gScooters.ActiveRentals = gScooters.ActiveRentals or {}

-- Kontrol sistemi için yerel değişkenler
local RENTAL_CHECK_INTERVAL = 10 -- 10 saniyede bir kontrol
local MAX_DISTANCE_FROM_SCOOTER = 10 -- metre
local RENTAL_TIMEOUT = 300 -- 5 dakika - maksimum kira süresi kontrolü

-- Kiralama başladığında çağrılacak fonksiyon
local function RegisterActiveRental(player, scooter)
    if not IsValid(player) or not IsValid(scooter) then return end
    
    local steamId = player:SteamID64()
    gScooters.ActiveRentals[steamId] = {
        player = player,
        scooter = scooter,
        startTime = CurTime(),
        lastCheckTime = CurTime(),
        isActive = true
    }
    
    DebugPrint("Rental registered for", player:Nick())
end

-- Kiralama sonlandırma fonksiyonu
local function EndRentalForPlayer(steamId, reason)
    local rentalData = gScooters.ActiveRentals[steamId]
    if not rentalData then return end
    
    local player = rentalData.player
    local scooter = rentalData.scooter
    
    -- Oyuncu geçerliyse işlemleri yap
    if IsValid(player) then
        -- Kemikleri sıfırla
        ResetPlayerBones(player)
        
        -- Kira ücretini hesapla ve al
        if player.GC_ScooterRentStartTime then
            local rentDuration = CurTime() - player.GC_ScooterRentStartTime
            if rentDuration > 5 then -- 5 saniyeden uzun kiralamalar ücretlendirilir
                gScooters:BillPlayer(player, rentDuration)
            end
        end
        
        -- UI'ı kapat
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(player)
        
        -- Oyuncu değişkenlerini temizle
        player.GC_ScooterRentStartTime = nil
        player.GC_ActiveScooter = nil
        player.GC_PendingRental = nil
        
        -- Debug mesajı
        if reason then
            gScooters:ChatMessage("Kiralama sonlandırıldı: " .. reason, player)
        end
        DebugPrint("Rental ended for", player:Nick(), "- Reason:", reason)
    end
    
    -- Scooter geçerliyse motoru kapat
    if IsValid(scooter) then
        scooter:Fire("TurnOff")
        scooter.GC_Enterable = false
    end
    
    -- Tablodan kaldır
    gScooters.ActiveRentals[steamId] = nil
end

-- Ana kontrol timer'ı
timer.Create("gScooters.RentalChecker", RENTAL_CHECK_INTERVAL, 0, function()
    local currentTime = CurTime()
    local checkedCount = 0
    
    -- Tüm aktif kiralamaları kontrol et
    for steamId, rentalData in pairs(gScooters.ActiveRentals) do
        checkedCount = checkedCount + 1
        
        local player = rentalData.player
        local scooter = rentalData.scooter
        
        -- Oyuncu geçerli değilse
        if not IsValid(player) then
            DebugPrint("Player invalid, ending rental for SteamID:", steamId)
            EndRentalForPlayer(steamId, "Oyuncu bağlantıyı kesti")
        -- Scooter geçerli değilse
        elseif not IsValid(scooter) then
            DebugPrint("Scooter invalid, ending rental for", player:Nick())
            EndRentalForPlayer(steamId, "Scooter silindi")
        else
            -- Oyuncu scooter'da mı kontrol et
            local currentVehicle = player:GetVehicle()
            local isInScooter = IsValid(currentVehicle) and currentVehicle == scooter
            
            -- Oyuncu scooter'da değilse mesafe kontrolü yap
            if not isInScooter and rentalData.isActive then
                local playerPos = player:GetPos()
                local scooterPos = scooter:GetPos()
                local distance = playerPos:Distance(scooterPos)
                
                DebugPrint("Player", player:Nick(), "not in scooter. Distance:", math.Round(distance))
                
                -- Mesafe kontrolü
                if distance > MAX_DISTANCE_FROM_SCOOTER * 52.49 then -- Garry's Mod birim dönüşümü
                    DebugPrint("Player too far from scooter, ending rental")
                    EndRentalForPlayer(steamId, "Scooter'dan çok uzaklaştınız")
                else
                    -- Süre aşımı kontrolü (opsiyonel)
                    if RENTAL_TIMEOUT > 0 then
                        local rentalDuration = currentTime - rentalData.startTime
                        if rentalDuration > RENTAL_TIMEOUT then
                            DebugPrint("Rental timeout for", player:Nick())
                            EndRentalForPlayer(steamId, "Maksimum kira süresi aşıldı")
                        else
                            -- Jail kontrolü
                            if IsPlayerJailed(player) then
                                DebugPrint("Player jailed, ending rental")
                                EndRentalForPlayer(steamId, "Hapse girdiniz")
                            else
                                -- Son kontrol zamanını güncelle
                                rentalData.lastCheckTime = currentTime
                            end
                        end
                    else
                        -- Jail kontrolü
                        if IsPlayerJailed(player) then
                            DebugPrint("Player jailed, ending rental")
                            EndRentalForPlayer(steamId, "Hapse girdiniz")
                        else
                            -- Son kontrol zamanını güncelle
                            rentalData.lastCheckTime = currentTime
                        end
                    end
                end
            else
                -- Oyuncu scooter'da, normal kontroller
                if RENTAL_TIMEOUT > 0 then
                    local rentalDuration = currentTime - rentalData.startTime
                    if rentalDuration > RENTAL_TIMEOUT then
                        DebugPrint("Rental timeout for", player:Nick())
                        EndRentalForPlayer(steamId, "Maksimum kira süresi aşıldı")
                    else
                        -- Jail kontrolü
                        if IsPlayerJailed(player) then
                            DebugPrint("Player jailed, ending rental")
                            EndRentalForPlayer(steamId, "Hapse girdiniz")
                        else
                            -- Son kontrol zamanını güncelle
                            rentalData.lastCheckTime = currentTime
                        end
                    end
                else
                    -- Jail kontrolü
                    if IsPlayerJailed(player) then
                        DebugPrint("Player jailed, ending rental")
                        EndRentalForPlayer(steamId, "Hapse girdiniz")
                    else
                        -- Son kontrol zamanını güncelle
                        rentalData.lastCheckTime = currentTime
                    end
                end
            end
        end
    end
    
    -- Debug: Kontrol edilen kiralama sayısı
    if checkedCount > 0 and gScooters.Config.DebugMode then
        DebugPrint("Checked", checkedCount, "active rentals")
    end
end)

-- Hook for rental start
hook.Add("gScooters.RentalStarted", "gScooters.RegisterRental", function(player, scooter)
    RegisterActiveRental(player, scooter)
end)

-- Admin komutları
concommand.Add("gscooter_rental_list", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    print("=== Active G-Scooter Rentals ===")
    local count = 0
    for steamId, rental in pairs(gScooters.ActiveRentals) do
        count = count + 1
        local duration = math.Round(CurTime() - rental.startTime)
        print(string.format("%d. %s - Duration: %ds", 
            count, 
            IsValid(rental.player) and rental.player:Nick() or "Invalid Player",
            duration
        ))
    end
    print("Total active rentals:", count)
end)

concommand.Add("gscooter_rental_cleanup", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local cleaned = 0
    for steamId, rental in pairs(gScooters.ActiveRentals) do
        if not IsValid(rental.player) or not IsValid(rental.scooter) then
            gScooters.ActiveRentals[steamId] = nil
            cleaned = cleaned + 1
        end
    end
    print("Cleaned up", cleaned, "invalid rentals")
end)
-- ============= RENTAL KONTROL SİSTEMİ BİTİŞ =============

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

-- FİX: Oyuncu jail durumu kontrolü
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

-- FİX: Güçlendirilmiş scooter giriş kontrolü - UI kilitleme eklendi
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
            -- YENİ: UI kilidi kontrolü
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

local aReset = Angle(0, 0, 0)

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

-- PlayerLeaveVehicle hook'u düzeltildi
hook.Add("PlayerLeaveVehicle", "gScooters.Hook.OnScooterExit", function(pPlayer, eScooter)
    if IsValid(eScooter) and eScooter.gScooter then
        -- RENTAL SİSTEMİ İÇİN YENİ KOD - BAŞLANGIÇ
        local steamId = pPlayer:SteamID64()
        local rentalData = gScooters.ActiveRentals[steamId]
        
        if rentalData and rentalData.scooter == eScooter then
            -- 5 saniye bekle, eğer hala uzaktaysa sonlandır
            timer.Simple(5, function()
                if not IsValid(pPlayer) then return end
                
                local rental = gScooters.ActiveRentals[steamId]
                if not rental then return end
                
                local currentVehicle = pPlayer:GetVehicle()
                if not IsValid(currentVehicle) or currentVehicle ~= eScooter then
                    local distance = pPlayer:GetPos():Distance(eScooter:GetPos())
                    if distance > MAX_DISTANCE_FROM_SCOOTER * 52.49 then
                        EndRentalForPlayer(steamId, "Scooter'dan ayrıldınız")
                        return -- HandleEnd'i çağırmayı engelle
                    end
                end
            end)
        end
        -- RENTAL SİSTEMİ İÇİN YENİ KOD - BİTİŞ
        
        -- Mevcut HandleEnd kodu
        gScooters:HandleEnd(eScooter, pPlayer)
    end
end)

hook.Add("PostPlayerDeath", "gScooters.Hook.Death", function(pPlayer)
    if not IsValid(pPlayer) then return end
    
    -- Önce kemikleri sıfırla
    ResetPlayerBones(pPlayer)
    
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

-- FİX: Jail hook'ları - server tarafında
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

-- FİX: DarkRP jail hook'u
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
        
        -- KEMİK AYARLARI BURADA YAPILMAYACAK, RentScooter'da yapılıyor
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
    
    -- UI kilidini temizle
    for scooter, player in pairs(activeScooterUIs) do
        if player == pPlayer then
            activeScooterUIs[scooter] = nil
        end
    end
    
    -- Kira kontrolü ve temizlik
    if pPlayer.GC_ActiveScooter and IsValid(pPlayer.GC_ActiveScooter) then
        gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
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

-- Periyodik pending rental temizleyici
timer.Create("gScooters.Timer.PendingRentalCleanup", 2, 0, function()
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer.GC_PendingRental then
            -- Pending rental var ama oyuncu scooter'da değil
            if not IsValid(pPlayer:GetVehicle()) or not pPlayer:GetVehicle().gScooter then
                DebugPrint("Cleaning up orphaned pending rental for", pPlayer:Nick())
                
                pPlayer.GC_ScooterRentStartTime = nil
                pPlayer.GC_ActiveScooter = nil
                pPlayer.GC_PendingRental = nil
                
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
            end
        end
    end
end)