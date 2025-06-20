-- gscooters/lua/scooters/server/sv_hooks_fixed.lua
-- Bu dosyayı sv_hooks.lua ile değiştirin

local tCooldowns = {}
local iTimeout = .25

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

hook.Add("CanPlayerEnterVehicle", "gScooters.Hook.OnScooterUse", function(pPlayer, eScooter)
    if eScooter.gScooter and not eScooter.GC_Enterable then
        local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]

        if iBlacklist and CurTime() < iBlacklist + (60*5) then
            gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)
        elseif not (pPlayer:Team() == TEAM_MARTI) then
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

    local activeScooterEntity_playerRef = pPlayer.GC_ActiveScooter 
    local rentStartTime_playerRef = pPlayer.GC_ScooterRentStartTime 
    local isRentalPending = pPlayer.GC_RentalPending

    -- Oyuncunun bir kira kaydı var mı diye kontrol et
    if activeScooterEntity_playerRef and rentStartTime_playerRef then 
        
        -- ÖZEL DURUM: Eğer kira henüz pending durumda ise (5 saniye bitmemiş)
        if isRentalPending then
            DebugPrint("Cancelling PENDING rental for", pPlayer:Nick())
            
            -- Pending kira iptal - ücret alınmaz
            if IsValid(activeScooterEntity_playerRef) then
                activeScooterEntity_playerRef.StartRentTime = nil
                activeScooterEntity_playerRef.GC_RenterSteamID = nil
                activeScooterEntity_playerRef.GC_IsRentalPending = nil
            end
            
            -- Oyuncu bilgilerini temizle
            pPlayer.GC_ActiveScooter = nil
            pPlayer.GC_ScooterRentStartTime = nil
            pPlayer.GC_RentalPending = nil
            
            -- ÖNEMLİ: UI sıfırlama mesajını gönder
            net.Start("gScooters.Net.ResetScooterUI")
            net.WriteEntity(NULL)
            net.Send(pPlayer)
            
            -- Kemikleri sıfırla
            ResetPlayerBones(pPlayer)
            
            DebugPrint("Pending rental cancelled, no charge applied for", pPlayer:Nick())
            return true
        end

        -- Normal aktif kira bitirme
        local scooterToLogForUI = activeScooterEntity_playerRef 
        if IsValid(eScooter_param) and eScooter_param == activeScooterEntity_playerRef then
            scooterToLogForUI = eScooter_param
        end
        
        DebugPrint("Processing active rental with scooterToLogForUI EntIndex:", (IsValid(scooterToLogForUI) and scooterToLogForUI:EntIndex() or "NIL_OR_INVALID"))

        -- Oyuncuyu faturalandır
        gScooters:BillPlayer(pPlayer, CurTime() - rentStartTime_playerRef)
        DebugPrint("Player", pPlayer:Nick(), "BILLED. Duration:", tostring(CurTime() - rentStartTime_playerRef))

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
        end

        -- Oyuncunun kira durumunu temizle
        pPlayer.GC_ActiveScooter = nil
        pPlayer.GC_ScooterRentStartTime = nil
        pPlayer.GC_RentalPending = nil
        DebugPrint("Cleared player rental state for", pPlayer:Nick())

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
    local eScooter = pPlayer.GC_ActiveScooter
    gScooters:HandleEnd(eScooter, pPlayer)
end)

hook.Add("OnPlayerChangedTeam", "gScooters.Hook.SwitchJobWithMenu", function(pPlayer)
    if not IsValid(pPlayer) then return end
    local eScooter = pPlayer.GC_ActiveScooter
    gScooters:HandleEnd(eScooter, pPlayer)
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

hook.Add("PlayerChangedTeam", "gScooters.Hook.SwitchJob", function(pPlayer)
    if IsValid(pPlayer.GC_Van) then
        pPlayer.GC_Van:Remove()
        net.Start("gScooters.Net.ResetJobs")
        net.Send(pPlayer)
    end
    pPlayer.CanAcceptJob = false 
    pPlayer.ActiveJob = false    
end) 

timer.Create("gScooters.Timer.Job", 300, 0, function()
    for _, pPlayer in ipairs(player.GetAll()) do
        if IsValid(pPlayer) and pPlayer:Team() == TEAM_MARTI and IsValid(pPlayer.GC_Van) and pPlayer:GetVehicle() == pPlayer.GC_Van then 
            if not pPlayer.ActiveJob then
                pPlayer.CanAcceptJob = true
 
                if gScooters.RackEntities and table.Count(gScooters.RackEntities) > 0 then 
                    local randomRackKey = table.Random(table.GetKeys(gScooters.RackEntities)) 
                    local tTableToSend = gScooters.RackEntities[randomRackKey]

                    if tTableToSend and #tTableToSend > 0 then 
                        net.Start("gScooters.Net.SendJob")
                        net.WriteUInt(#tTableToSend, 22)
                        for _, eScooter in pairs(tTableToSend) do
                            if IsValid(eScooter) then net.WriteEntity(eScooter) end
                        end
                        net.Send(pPlayer)
                    end
                end
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "gScooters.Hook.JobAcceptKey", function(pPlayer, iKey)
    if IsFirstTimePredicted() and IsValid(pPlayer.GC_Van) then
        if iKey == gScooters.Config.JobAcceptKey and pPlayer.CanAcceptJob and pPlayer:GetVehicle() == pPlayer.GC_Van then
            pPlayer.CanAcceptJob = false
            pPlayer.ActiveJob = true
            gScooters:ChatMessage(string.format(gScooters:GetPhrase("job_start"), gScooters:GetPhrase("numbers")[gScooters.Config.ScooterPickupRequirement] or tostring(gScooters.Config.ScooterPickupRequirement)), pPlayer)
        elseif iKey == gScooters.Config.JobSellKey and pPlayer.ActiveJob and pPlayer.GC_Van.GC_ScooterEnts and #pPlayer.GC_Van.GC_ScooterEnts > 0 and pPlayer.GC_Van:GetPos():DistToSqr(pPlayer.GC_Van.GC_NPC:GetPos()) < 490000 then
            pPlayer.ActiveJob = false

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
            gScooters:ChatMessage(string.format(gScooters:GetPhrase("job_end"), gScooters:FormatMoney(gScooters.Config.JobPayment)), pPlayer)
            gScooters:ModifyMoney(pPlayer, gScooters.Config.JobPayment)
            pPlayer.GC_Van:SetNWInt("GC_ScooterAmount", 0)
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
            
            -- KİRA KONTROLÜ
            if pPlayer.GC_ActiveScooter and pPlayer.GC_ScooterRentStartTime then
                local rentedScooterEntity = pPlayer.GC_ActiveScooter
                local isRentalPending = pPlayer.GC_RentalPending
                
                -- Scooter artık geçerli değil mi?
                if not IsValid(rentedScooterEntity) then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "has rental record but scooter is invalid - calling HandleEnd")
                    gScooters:HandleEnd(rentedScooterEntity, pPlayer) 
                    
                -- Pending kira çok uzun süredir bekliyor mu? (15 saniyeden fazla)
                elseif isRentalPending and (CurTime() - pPlayer.GC_ScooterRentStartTime) > 15 then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "has pending rental too long - cancelling")
                    gScooters:HandleEnd(rentedScooterEntity, pPlayer)
                    
                -- Oyuncu scooter'da değil ama aktif kira var ve pending değil
                elseif not isRentalPending and pPlayer:GetVehicle() ~= rentedScooterEntity then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "not in rented scooter - calling HandleEnd")
                    gScooters:HandleEnd(rentedScooterEntity, pPlayer)
                    
                -- Scooter başka birisi tarafından kullanılıyor
                elseif IsValid(rentedScooterEntity:GetDriver()) and rentedScooterEntity:GetDriver() ~= pPlayer then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "'s rented scooter is being used by someone else - calling HandleEnd")
                    gScooters:HandleEnd(rentedScooterEntity, pPlayer)
                end
            end
            
            -- Ters kontrol: Oyuncu scooter'da ama kira kaydı yok
            local currentVehicle = pPlayer:GetVehicle()
            if IsValid(currentVehicle) and currentVehicle.gScooter then
                if not pPlayer.GC_ActiveScooter or pPlayer.GC_ActiveScooter ~= currentVehicle then
                    DebugPrint("PeriodicCheck: Player", pPlayer:Nick(), "in scooter but no rental record - forcing exit")
                    pPlayer:ExitVehicle()
                    ResetPlayerBones(pPlayer)
                end
            end
        end
    end
end)
print("[gScooters] Enhanced periodic rental validity check timer created.")

-- DISCONNECT HOOK
hook.Add("PlayerDisconnected", "gScooters.Hook.PlayerDisconnect", function(pPlayer)
    if IsValid(pPlayer) then
        -- Kemikleri sıfırla
        ResetPlayerBones(pPlayer)
        
        -- Kira temizliği
        if pPlayer.GC_ActiveScooter or pPlayer.GC_ScooterRentStartTime then
            DebugPrint("Player", pPlayer:Nick(), "disconnected with active rental - cleaning up")
            gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
        end
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

-- VEHICLE ENTRY KEMİK KONTROLÜ
hook.Add("PlayerEnteredVehicle", "gScooters.Hook.VehicleEntryBoneCheck", function(pPlayer, veh, role)
    if IsValid(veh) and veh.gScooter then
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