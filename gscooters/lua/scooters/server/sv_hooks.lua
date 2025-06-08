-- MAX HEALTH

local tCooldowns = {}
local iTimeout = .25

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

-- [[ ROBUST HandleEnd FUNCTION ]] --
function gScooters:HandleEnd(eScooter_param, pPlayer)
    if not IsValid(pPlayer) then
        print("[gScooters DEBUG HandleEnd] Called but pPlayer is INVALID.")
        return false
    end
    print("[gScooters DEBUG HandleEnd] CALLED for player: " .. pPlayer:Nick() .. ". Passed eScooter_param EntIndex: " .. (IsValid(eScooter_param) and eScooter_param:EntIndex() or "NIL_OR_INVALID"))
    print("[gScooters DEBUG HandleEnd]   Player state BEFORE HandleEnd: pPlayer.GC_ActiveScooter EntIndex: " .. (IsValid(pPlayer.GC_ActiveScooter) and pPlayer.GC_ActiveScooter:EntIndex() or "NIL_OR_INVALID") .. ", pPlayer.GC_ScooterRentStartTime: " .. tostring(pPlayer.GC_ScooterRentStartTime))

    local activeScooterEntity_playerRef = pPlayer.GC_ActiveScooter 
    local rentStartTime_playerRef = pPlayer.GC_ScooterRentStartTime 

    -- Oyuncunun bir kira kaydı var mı diye kontrol et (oyuncu üzerindeki veriye göre)
    if activeScooterEntity_playerRef and rentStartTime_playerRef then 
        -- Hangi scooter referansını (eScooter_param mı yoksa oyuncudaki mi) kullanacağımıza karar verelim.
        -- activeScooterEntity_playerRef, oyuncunun kiraladığını düşündüğü (belki de artık geçersiz olan) scooter'dır.
        local scooterToLogForUI = activeScooterEntity_playerRef 
        if IsValid(eScooter_param) and eScooter_param == activeScooterEntity_playerRef then
            -- Eğer HandleEnd geçerli ve oyuncunun aktif scooter'ıyla eşleşen bir scooter ile çağrıldıysa, onu kullanalım.
            scooterToLogForUI = eScooter_param
        end
        print("[gScooters DEBUG HandleEnd]   Processing with scooterToLogForUI (for UI reset) EntIndex: " .. (IsValid(scooterToLogForUI) and scooterToLogForUI:EntIndex() or "NIL_OR_INVALID"))

        -- Oyuncuyu, SADECE oyuncu üzerinde saklanan başlangıç zamanına göre faturalandır
        gScooters:BillPlayer(pPlayer, CurTime() - rentStartTime_playerRef)
        print("[gScooters DEBUG HandleEnd]   Player " .. pPlayer:Nick() .. " BILLED. Amount for duration: " .. tostring(CurTime() - rentStartTime_playerRef))

        -- UI sıfırlama mesajını gönder
        net.Start("gScooters.Net.ResetScooterUI")
        if IsValid(scooterToLogForUI) then 
            net.WriteEntity(scooterToLogForUI)
        else
            net.WriteEntity(NULL) -- Scooter geçersizse NULL gönder
        end
        net.Send(pPlayer)
        print("[gScooters DEBUG HandleEnd]   ResetScooterUI sent to " .. pPlayer:Nick())
        
        -- Eğer scooter (oyuncunun referansındaki veya parametre olarak gelen) hala geçerliyse, onun durumunu temizle
        if IsValid(scooterToLogForUI) then
            scooterToLogForUI.StartRentTime = nil
            scooterToLogForUI.GC_RenterSteamID = nil
            print("[gScooters DEBUG HandleEnd]   Cleared StartRentTime and GC_RenterSteamID from scooterToLogForUI (if it was valid).")
        end

        -- En önemlisi: Oyuncunun kira durumunu temizle
        pPlayer.GC_ActiveScooter = nil
        pPlayer.GC_ScooterRentStartTime = nil
        print("[gScooters DEBUG HandleEnd]   Cleared pPlayer.GC_ActiveScooter and pPlayer.GC_ScooterRentStartTime for " .. pPlayer:Nick())

        -- Oyuncu kemik manipülasyonunu sıfırla (oyuncu hala geçerliyse)
        if IsValid(pPlayer) then
            if not VC then
                for sBone, aAngle in pairs(gScooters.Bones) do
                    pPlayer:ManipulateBoneAngles(pPlayer:LookupBone(sBone), aReset)
                end
            elseif IsValid(scooterToLogForUI) and not SVMOD then 
                scooterToLogForUI:VC_repairFull_Admin()
            end
        end

        -- Scooter su içindeyse yeniden spawn et (sadece scooterToLogForUI geçerliyse ve gerçekten o scooter ise)
        if IsValid(scooterToLogForUI) and scooterToLogForUI:IsVehicleBodyInWater() then
            print("[gScooters DEBUG HandleEnd]   Scooter was in water, attempting to respawn.")
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
        print("[gScooters DEBUG HandleEnd]   Finished successfully for " .. pPlayer:Nick())
        return true
    else
        print("[gScooters DEBUG HandleEnd]   No active rental on player (GC_ActiveScooter is " .. (activeScooterEntity_playerRef and (IsValid(activeScooterEntity_playerRef) and activeScooterEntity_playerRef:EntIndex() or "INVALID_REF") or "NIL") .. ") OR rentStartTime missing (GC_ScooterRentStartTime is " .. tostring(rentStartTime_playerRef) .. ") for player " .. pPlayer:Nick() .. ". Cannot finalize rental normally via player state.")
    end
    return false 
end
-- [[ END OF ROBUST HandleEnd FUNCTION ]] --

hook.Add("CanExitVehicle", "gScooters.Hook.OnScooterUse", function(eScooter, pPlayer)
    gScooters:HandleEnd(eScooter, pPlayer)
end)

hook.Add("PostPlayerDeath", "gScooters.Hook.Death", function(pPlayer)
    if not IsValid(pPlayer) then return end -- Oyuncu zaten ölmüş/geçersiz olabilir.
    local eScooter = pPlayer.GC_ActiveScooter
    -- if not IsValid(eScooter) then return end -- eScooter zaten geçersiz olabilir, HandleEnd bunu yönetecek.
    -- if not eScooter.gScooter then return end -- Bu kontrol HandleEnd içinde yapılabilir veya oyuncu durumu öncelikli

    gScooters:HandleEnd(eScooter, pPlayer) -- eScooter burada nil veya geçersiz olabilir, HandleEnd bunu yönetmeli
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
--[[]  
elseif iKey == KEY_LALT then
        if not GC_SpamCheck("gScooters.Hook.Wheelie", pPlayer) then return end

            local vScooterPos = eScooter:GetPos()
            local aScooterAngles = eScooter:GetAngles()
            local vRopePos = vScooterPos + aScooterAngles:Up()*20 + aScooterAngles:Right()*-100

            local eBalloon = ents.Create("gmod_balloon")
            eBalloon:SetModel("models/hunter/blocks/cube025x025x025.mdl")
            eBalloon:SetPos(vRopePos)
            eBalloon:Spawn()
            eBalloon:SetForce(1460)
            eBalloon:SetColor(color_transparent)
            eBalloon:SetRenderMode(RENDERMODE_TRANSCOLOR)
            eBalloon:SetModelScale(0)

            local eConstraint, eRope = constraint.Rope(eBalloon, eScooter, 0, 0, eBalloon:WorldToLocal(vRopePos), Vector(0, 100, 20), 10, 0, 0, 0, "cable/rope", nil)

            eScooter.Wheelie = {eBalloon, eRope, eConstraint}
]]--
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

-- timer.Create("gScooters.Timer.1", ...)
-- (Bu timer bloğu yorum satırı olarak kalabilir)

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

hook.Add("OnPlayerLeaveVehicle", "gScooters.PanelReset", function(ply, vehicle)
    if IsValid(vehicle) and vehicle.gScooter then 
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(vehicle)
        net.Send(ply)
    end
end)



-- [[ PERIYODIK KIRA GEÇERLILIK KONTROLU ]] --
if not timer.Exists("gScooters_RentalValidityGlobalCheck") then
    timer.Create("gScooters_RentalValidityGlobalCheck", 15, 0, function() -- Her 15 saniyede bir kontrol et
        -- print("[gScooters DEBUG PeriodicCheck] Running rental validity check...") -- İsteğe bağlı: Zamanlayıcının çalıştığını görmek için bu satırın başındaki yorumu kaldırabilirsiniz.
        for _, pPlayer in ipairs(player.GetAll()) do
            if IsValid(pPlayer) and pPlayer:IsPlayer() then -- Oyuncunun bağlı ve geçerli olduğundan emin ol
                -- Oyuncunun Lua durumuna göre aktif bir kira kaydı var mı?
                if pPlayer.GC_ActiveScooter and pPlayer.GC_ScooterRentStartTime then
                    
                    local rentedScooterEntity = pPlayer.GC_ActiveScooter
                    
                    -- Oyuncunun kiraladığını düşündüğü scooter varlığı artık geçerli değil mi?
                    if not IsValid(rentedScooterEntity) then
                        print("[gScooters DEBUG PeriodicCheck] Player " .. pPlayer:Nick() .. " has a rental record, but their pPlayer.GC_ActiveScooter (Original EntIndex: " .. (rentedScooterEntity and rentedScooterEntity:EntIndex() or "UNKNOWN_WAS_REMOVED") .. ") is NO LONGER VALID.")
                        print("[gScooters DEBUG PeriodicCheck]   Calling HandleEnd for player " .. pPlayer:Nick() .. " to finalize rental due to invalid scooter.")
                        
                        -- HandleEnd fonksiyonunu çağır. rentedScooterEntity burada geçersiz bir referans olacaktır.
                        -- HandleEnd fonksiyonunun bu durumu yönetebilmesi (oyuncu üzerindeki kira bilgilerini kullanması) önemlidir.
                        gScooters:HandleEnd(rentedScooterEntity, pPlayer) 
                    -- else
                        -- Aktif ve geçerli bir kirası var, bir şey yapma.
                        -- print("[gScooters DEBUG PeriodicCheck] Player " .. pPlayer:Nick() .. " has a valid ongoing rental with scooter: " .. rentedScooterEntity:EntIndex()) -- İsteğe bağlı: Detaylı loglama için
                    end
                end
            end
        end
    end)
    print("[gScooters] Periodic rental validity check timer created and started.")
else
    print("[gScooters] Periodic rental validity check timer already exists.")
end
-- [[ END OF PERIYODIK KIRA GEÇERLILIK KONTROLU ]] --