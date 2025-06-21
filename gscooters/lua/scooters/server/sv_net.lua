-- gscooters/lua/scooters/server/sv_net.lua
-- Tam güncellenmiş dosya

local sMap = string.lower(game.GetMap())

util.AddNetworkString("gScooters.Net.ChatMessage")
util.AddNetworkString("gScooters.Net.OpenScooterUI")
util.AddNetworkString("gScooters.Net.ResetScooterUI")
util.AddNetworkString("gScooters.Net.RentScooter")
util.AddNetworkString("gScooters.Net.OpenRetrieverUI")
util.AddNetworkString("gScooters.Net.RetrieveEmployerCar")
util.AddNetworkString("gScooters.Net.PickupScooter")
util.AddNetworkString("gScooters.Net.SendJob")
util.AddNetworkString("gScooters.Net.ResetJobs")
util.AddNetworkString("gScooters.Net.OpenAdminUI")
util.AddNetworkString("gScooters.Net.AdminRequestData")
util.AddNetworkString("gScooters.Net.AdminSendData")
util.AddNetworkString("gScooters.Net.AdminCreateEntity")
util.AddNetworkString("gScooters.Net.AdminDeleteEntity")
util.AddNetworkString("gScooters.Net.SendWaypoint")
util.AddNetworkString("gScooters.Net.JobCooldownStart")
util.AddNetworkString("gScooters.Net.JobCooldownUpdate") 
util.AddNetworkString("gScooters.Net.JobCooldownEnd")

local tCooldowns = {}
local iTimeout = 0.5

-- Debug print fonksiyonu - sadece config'te aktifse çalışır
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

local bSpawning = false
gScooters.Entities = gScooters.Entities or {}
gScooters.RackEntities = gScooters.RackEntities or {}

function gScooters:SpawnEntities()
    if bSpawning then return end

    for _, eEntity in ipairs(gScooters.Entities) do
        if IsValid(eEntity) then eEntity:Remove() end
    end

    local tDataExisting
    if file.Exists("gscooters/maps/"..sMap..".json", "DATA") then 
        tDataExisting = util.JSONToTable(file.Read("gscooters/maps/"..sMap..".json", "DATA"))
    else
        tDataExisting = {}
    end

    tDataExisting[GC_RACK] = tDataExisting[GC_RACK] or {}
    tDataExisting[GC_NPC] = tDataExisting[GC_NPC] or {}

    gScooters.Data = tDataExisting

    local iCount = 0 -- For timer seperation
    local iStringIndex = 0 -- For telling when last rack is done

    for iRackIndex, tRack in pairs(tDataExisting[GC_RACK]) do
        iStringIndex = iStringIndex + 1

        gScooters.RackEntities[iRackIndex] = {}

        for iScooterIndex, vPos in ipairs(tRack.Scooters) do
            iCount = iCount + 0.1

            timer.Simple(iCount, function()
                local eScooter = gScooters:CreateScooter(vPos, tRack.Angle)
                table.insert(gScooters.Entities, eScooter)

                table.insert(gScooters.RackEntities[iRackIndex], eScooter)
                eScooter.GC_OriginalRack = iRackIndex
            end)

            if iStringIndex == table.Count(tDataExisting) and iScooterIndex == #tRack.Scooters then -- Prevention from modification while spawning
                bSpawning = false
            end
        end
    end

    for sName, tNPC in pairs(tDataExisting[GC_NPC]) do
        local eNPC = ents.Create("gc_npc")

        if IsValid(eNPC) then
            eNPC:SetPos(tNPC.Position)
            eNPC:SetAngles(Angle(0, tNPC.Angle.y, 0))
            eNPC:SetModel(gScooters.Config.RetrieverModel)
            eNPC:Spawn()

            eNPC.VehiclePosition = tNPC.VehiclePosition
            eNPC.VehicleAngle = tNPC.VehicleAngle
            eNPC.VehicleMins = tNPC.VehicleMins
            eNPC.VehicleMaxs = tNPC.VehicleMaxs

            table.insert(gScooters.Entities, eNPC)
        end
    end
end

net.Receive("gScooters.Net.RentScooter", function(len, pPlayer)
    if not GC_SpamCheck("gScooters.Net.RentScooter", pPlayer) then return end
    local eScooter = net.ReadEntity()

    if not IsValid(pPlayer) then
        DebugPrint("RentScooter: pPlayer is invalid at start of RentScooter net message.")
        return
    end
    if not IsValid(eScooter) then 
        DebugPrint("RentScooter: eScooter is invalid for pPlayer:", pPlayer:Nick())
        return
    end
    if not eScooter.gScooter then return end
    if IsValid(eScooter:GetPassenger(0)) then return end
    if not (pPlayer:GetPos():DistToSqr(eScooter:GetPos()) < 610000) then return end
    if not gScooters:CanAfford(pPlayer, gScooters.Config.RentalRate) then return end
    if pPlayer:Team() == TEAM_MARTI then return end

    -- ÖNEMLİ: Eğer oyuncunun zaten aktif bir kiraması varsa, onu sonlandır
    if pPlayer.GC_ActiveScooter or pPlayer.GC_ScooterRentStartTime then
        DebugPrint("Player", pPlayer:Nick(), "already has active rental, ending it first.")
        gScooters:HandleEnd(pPlayer.GC_ActiveScooter, pPlayer)
    end

    local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]
    if iBlacklist and CurTime() < iBlacklist + (60*5) then return end

    -- DÜZELTME: Kira bilgilerini hemen burada set et, 5 saniye sonra değil!
    local startTime = CurTime()
    eScooter.StartRentTime = startTime
    eScooter.GC_RenterSteamID = pPlayer:SteamID64()
    eScooter.GC_IsRentalPending = true -- Yeni flag: Kira bekleniyor
    
    pPlayer.GC_ActiveScooter = eScooter          
    pPlayer.GC_ScooterRentStartTime = startTime
    pPlayer.GC_RentalPending = true -- Oyuncuda da pending flag

    DebugPrint("Rental INITIATED (PENDING) for", pPlayer:Nick(), ". Scooter EntIndex:", eScooter:EntIndex())

    eScooter.GC_Enterable = true
    pPlayer:EnterVehicle(eScooter)
    eScooter.GC_Enterable = false

    if VC and not SVMOD then
        eScooter:VC_fuelSet(eScooter:VC_fuelGetMax())
    else
        for sBone, aAngle in pairs(gScooters.Bones) do
            pPlayer:ManipulateBoneAngles(pPlayer:LookupBone(sBone), aAngle) 
        end
    end

    eScooter:GetPhysicsObject():EnableMotion(true)
    eScooter:Fire("TurnOff")
    eScooter:EmitSound("gscooters/scooter_unlock.wav", 45)

    -- 5 saniye sonra kira aktivasyonu
    timer.Simple(5, function() 
        if IsValid(pPlayer) and IsValid(eScooter) then
            -- Eğer oyuncu hala scooter'da ise kira aktifleştir
            if pPlayer:GetVehicle() == eScooter and pPlayer.GC_RentalPending then
                eScooter:Fire("TurnOn")
                eScooter.GC_IsRentalPending = false -- Artık aktif kira
                pPlayer.GC_RentalPending = false
                
                DebugPrint("Rental ACTIVATED for", pPlayer:Nick(), ". Scooter EntIndex:", eScooter:EntIndex())
            else
                -- Oyuncu scooter'da değil veya zaten başka bir kira var, bu kira iptal
                DebugPrint("Rental CANCELLED for", pPlayer:Nick(), "- player not in scooter or has other rental")
                
                -- ÖNEMLİ: UI'ı temizle
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
                
                -- Sadece bu scooter'ın bilgilerini temizle, HandleEnd çağırma
                if eScooter.GC_RenterSteamID == pPlayer:SteamID64() then
                    eScooter.StartRentTime = nil
                    eScooter.GC_RenterSteamID = nil
                    eScooter.GC_IsRentalPending = nil
                end
                
                -- Eğer oyuncunun aktif scooter'ı bu scooter ise temizle
                if pPlayer.GC_ActiveScooter == eScooter then
                    pPlayer.GC_ActiveScooter = nil
                    pPlayer.GC_ScooterRentStartTime = nil
                    pPlayer.GC_RentalPending = nil
                end
            end
        else
            DebugPrint("Rental timer failed - player or scooter invalid")
            
            -- Timer başarısız olursa da UI'ı temizle
            if IsValid(pPlayer) then
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
            end
        end
    end)
end)

net.Receive("gScooters.Net.AdminCreateEntity", function(len, pPlayer)
    if not (gScooters.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end
    
    local iNum = net.ReadUInt(22)
    local tJsonTableToRecieve = util.Decompress(net.ReadData(iNum)) or {}
    local tData = util.JSONToTable(tJsonTableToRecieve)
    local iType = net.ReadUInt(2)

    local tDataExisting
    if file.Exists("gscooters/maps/"..sMap..".json", "DATA") then 
        tDataExisting = util.JSONToTable(file.Read("gscooters/maps/"..sMap..".json", "DATA"))
    else
        tDataExisting = {}
    end
    
    tDataExisting[iType] = tDataExisting[iType] or {}

    local sName
    if iType == GC_RACK then
        sName = net.ReadString()
    else
        local tDataExistingNPC = tDataExisting[iType] 
        local iLen = 1
        for _, _ in pairs(tDataExistingNPC) do iLen = iLen + 1 end

        sName = string.format("%s #%i", gScooters:GetPhrase("retriever"), iLen)
    end

    tDataExisting[iType][sName] = tData

    file.Write("gscooters/maps/"..sMap..".json", util.TableToJSON(tDataExisting))

    gScooters:SpawnEntities()
end)

net.Receive("gScooters.Net.AdminDeleteEntity", function(len, pPlayer)
    if not (gScooters.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    if bSpawning then gScooters:ChatMessage(gScooters:GetPhrase("error"), pPlayer) return end

    local sName = net.ReadString()
    local iType = net.ReadUInt(2)
    
    local tDataExisting
    if file.Exists("gscooters/maps/"..sMap..".json", "DATA") then 
        tDataExisting = util.JSONToTable(file.Read("gscooters/maps/"..sMap..".json", "DATA"))
    else
        tDataExisting = {}
    end

    if tonumber(sName) then sName = tonumber(sName) end
    tDataExisting[iType][sName] = nil

    file.Write("gscooters/maps/"..sMap..".json", util.TableToJSON(tDataExisting))

    gScooters:SpawnEntities()
end)

net.Receive("gScooters.Net.AdminRequestData", function(len, pPlayer)
    if not (gScooters.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local jDataExisting
    if file.Exists("gscooters/maps/"..sMap..".json", "DATA") then 
        jDataExisting = file.Read("gscooters/maps/"..sMap..".json", "DATA")
    else
        jDataExisting = ""
    end
    
    local tTableToSend = util.Compress(jDataExisting)

    net.Start("gScooters.Net.AdminSendData")
    net.WriteUInt(#tTableToSend, 22)
    net.WriteData(tTableToSend, #tTableToSend)
    net.Send(pPlayer)
end)

local function GC_CheckSpawnPointBlockage(vMins, vMaxs, pPlayer)
    local bIndividualCheckPassed = true
    local eEnts = ents.FindInBox(vMins, vMaxs)
    for _, eEnt in ipairs(eEnts) do
        if (eEnt:GetClass() == "player" or eEnt:GetClass() == "prop_vehicle_jeep" or eEnt:GetClass() == "gmod_sent_vehicle_fphysics_base" or eEnt:GetClass() == "prop_vehicle_airboat" or eEnt:GetClass() == "") and not (eEnt == pPlayer.GC_Van) then
            bIndividualCheckPassed = false
        end
    end

    return bIndividualCheckPassed
end

net.Receive("gScooters.Net.RetrieveEmployerCar", function(len, pPlayer)
    if not GC_SpamCheck("gScooters.Net.RetrieveEmployerCar", pPlayer) then return end

    if not (pPlayer:Team() == TEAM_MARTI) then return end
    if not pPlayer.GC_LastUse then return end

    local eNPC = pPlayer.GC_LastUse[2]
    if not IsValid(eNPC) then return end 

    if pPlayer.GC_LastUse[1] > (CurTime() - 30) and GC_CheckSpawnPointBlockage(eNPC.VehicleMins, eNPC.VehicleMaxs + Vector(0, 0, 45), pPlayer) then
        if IsValid(pPlayer.GC_Van) then
            pPlayer.GC_Van:Remove()
        end
        
        local eVan = ents.Create("prop_vehicle_jeep")
        if not IsValid(eVan) then return end
    
        eVan:SetModel(gScooters.Config.Van.Model)
    
        eVan:SetVehicleClass("merc_sprinter_swb_lw")
        eVan:SetKeyValue("vehiclescript", "scripts/vehicles/LWCars/merc_sprinter_swb.txt")
        
        eVan:SetPos(eNPC.VehiclePosition + Vector(0, 0, 10))
        eVan:SetAngles(eNPC.VehicleAngle - Angle(0, 90, 0))
        eVan:Spawn()
        eVan:Activate()

        eVan:SetColor(gScooters.Config.Van.Color)
        eVan:SetSkin(gScooters.Config.Van.Skin)

        for iKey, iValue in pairs(gScooters.Config.Van.Bodygroups) do
            eVan:SetBodygroup(iKey, iValue)
        end

        gScooters:LockVehicle(eVan)
        gScooters:SetVehicleOwner(eVan, pPlayer)

        local tParams = eVan:GetVehicleParams()
        tParams.engine.horsepower = tParams.engine.horsepower + gScooters.Config.Van.AddedPower
        eVan:SetVehicleParams(tParams)

        pPlayer.GC_Van = eVan
        eVan.GC_Owner = pPlayer
        eVan.GC_NPC = eNPC

        net.Start("gScooters.Net.ResetJobs")
        net.Send(pPlayer)

        pPlayer.CanAcceptJob = true
        pPlayer.ActiveJob = false
    else
        gScooters:ChatMessage(gScooters:GetPhrase("spawn_positions_full"), pPlayer)
    end
end)

net.Receive("gScooters.Net.PickupScooter", function(len, pPlayer)
    if not GC_SpamCheck("gScooters.Net.PickupScooter", pPlayer) then 
        print("[gScooters] Spam check failed for", pPlayer:Nick())
        return 
    end

    local eEnt = pPlayer:GetEyeTrace().Entity
    local eVan = pPlayer.GC_Van

    -- Debug bilgileri
    print("[gScooters Pickup Debug]")
    print("Player:", pPlayer:Nick())
    print("Looking at entity:", IsValid(eEnt) and eEnt:GetClass() or "INVALID")
    print("Has van:", IsValid(eVan))
    
    if not IsValid(eEnt) then
        gScooters:ChatMessage("Geçerli bir scooter'a bakmıyorsunuz!", pPlayer)
        return
    end
    
    if not IsValid(eVan) then
        gScooters:ChatMessage("Van'ınız bulunamadı!", pPlayer)
        return
    end
    
    if not eEnt.gScooter then
        gScooters:ChatMessage("Bu bir scooter değil!", pPlayer)
        return
    end
    
    if not IsValid(eVan.GC_Owner) then
        gScooters:ChatMessage("Van sahibi bulunamadı!", pPlayer)
        return
    end
    
    if not eVan.GC_Owner.ActiveJob then
        gScooters:ChatMessage("Aktif bir işiniz yok!", pPlayer)
        return
    end
    
    -- Mesafe kontrolü
    local distance = eEnt:GetPos():DistToSqr(eVan:GetPos())
    print("Distance to van:", math.sqrt(distance))
    
    if distance > 700000 then
        gScooters:ChatMessage(gScooters:GetPhrase("too_far"), pPlayer)
        return
    end

    -- Van'daki scooter listesini başlat
    if not eVan.GC_ScooterEnts then
        eVan.GC_ScooterEnts = {}
        print("[gScooters] Initialized GC_ScooterEnts table for van")
    end
    
    -- Mevcut scooter sayısı
    local currentCount = #eVan.GC_ScooterEnts
    print("Current scooter count in van:", currentCount)
    print("Max capacity:", gScooters.Config.ScooterPickupRequirement)
    
    -- Kapasite kontrolü
    if currentCount >= gScooters.Config.ScooterPickupRequirement then
        gScooters:ChatMessage(gScooters:GetPhrase("max_scooters"), pPlayer)
        
        if IsValid(eVan.GC_NPC) then
            net.Start("gScooters.Net.SendWaypoint")
            net.WriteEntity(eVan.GC_NPC)
            net.Send(pPlayer)
        end
        return
    end
    
    -- Oyuncu başka bir araçta mı kontrolü
    local playerVehicle = pPlayer:GetVehicle()
    if IsValid(playerVehicle) and playerVehicle.GC_Owner then
        gScooters:ChatMessage("Başka bir araçtayken scooter toplayamazsınız!", pPlayer)
        return
    end
    
    -- ÖNEMLİ: Scooter'ın gerçekten toplanabilir olup olmadığını kontrol et
    local bCanBeCollected = false
    
    -- 1. Hareket kontrolü
    if eEnt.GC_OriginalSpawnPos then
        local movedDistance = (eEnt:GetPos() - eEnt.GC_OriginalSpawnPos):Length()
        print("Scooter moved distance from spawn:", movedDistance)
        
        if movedDistance >= gScooters.Config.MinMovedDistance then
            bCanBeCollected = true
        end
    elseif eEnt.GC_FirstTimeUsed then
        -- İlk kez kullanılmış olarak işaretlenmiş
        bCanBeCollected = true
    else
        print("[gScooters] Scooter has not been moved from spawn position")
        gScooters:ChatMessage("Bu scooter henüz hareket ettirilmemiş, park yerinden toplanamaz!", pPlayer)
        return
    end
    
    if not bCanBeCollected then
        gScooters:ChatMessage("Bu scooter toplanamaz! (Henüz kullanılmamış)", pPlayer)
        return
    end
    
    -- 2. Kullanım kontrolü
    if IsValid(eEnt:GetDriver()) then
        gScooters:ChatMessage("Kullanımdaki scooter toplanamaz!", pPlayer)
        return
    end
    
    -- 3. Kiralık scooter kontrolü
    if eEnt.GC_RenterSteamID or eEnt.StartRentTime then
        gScooters:ChatMessage("Kiralanmış scooter toplanamaz!", pPlayer)
        return
    end

    -- SCOOTER'I TOPLA
    print("[gScooters] All checks passed, picking up collectable scooter...")
    
    local eScooterProp = ents.Create("prop_physics")
    if not IsValid(eScooterProp) then
        print("[gScooters] Failed to create prop_physics!")
        return
    end

    eScooterProp:SetModel("models/dannio/gscooters.mdl")
    
    -- Van'a göre pozisyon hesaplama
    local offset = Vector(0, currentCount * -20, 24)
    eScooterProp:SetPos(eVan:LocalToWorld(offset))
    eScooterProp:SetAngles(eVan:GetAngles() + Angle(0, 90, 0))
    eScooterProp:SetParent(eVan)
    eScooterProp:Spawn()
    
    -- Ses efekti
    eVan:EmitSound("items/ammocrate_open.wav")

    -- Orijinal bilgileri kopyala
    eScooterProp.GC_OriginalSpawnPos = eEnt.GC_OriginalSpawnPos 
    eScooterProp.GC_OriginalSpawnAng = eEnt.GC_OriginalSpawnAng 
    eScooterProp.GC_OriginalRack = eEnt.GC_OriginalRack
    
    -- Eski scooter'ı kaldır
    eEnt:Remove()

    -- Van'ın listesine ekle
    table.insert(eVan.GC_ScooterEnts, eScooterProp)
    
    -- Network değerini güncelle
    local newCount = #eVan.GC_ScooterEnts
    eVan:SetNWInt("GC_ScooterAmount", newCount)
    
    print("[gScooters] Scooter picked up successfully! New count:", newCount)
    gScooters:ChatMessage(string.format("Scooter toplandı! (%d/%d)", newCount, gScooters.Config.ScooterPickupRequirement), pPlayer)

    -- Maksimum kapasiteye ulaşıldı mı?
    if newCount >= gScooters.Config.ScooterPickupRequirement then
        if IsValid(eVan.GC_Owner) then
            gScooters:ChatMessage(gScooters:GetPhrase("max_scooters"), eVan.GC_Owner)

            if IsValid(eVan.GC_NPC) then
                net.Start("gScooters.Net.SendWaypoint")
                net.WriteEntity(eVan.GC_NPC)
                net.Send(eVan.GC_Owner)
            end
        end
    end
end)

-- Van spawn edildiğinde scooter listesini sıfırla
hook.Add("OnEntityCreated", "gScooters.VanSpawnFix", function(ent)
    timer.Simple(0.1, function()
        if IsValid(ent) and ent:IsVehicle() and ent:GetVehicleClass() == "merc_sprinter_swb_lw" then
            if ent.GC_Owner then
                ent.GC_ScooterEnts = {}
                ent:SetNWInt("GC_ScooterAmount", 0)
                print("[gScooters] Van spawned, initialized scooter storage")
            end
        end
    end)
end)

-- Debug komutları
if SERVER then
    concommand.Add("gc_debug_van", function(ply)
        if not ply:IsAdmin() then return end
        
        local van = ply.GC_Van
        if not IsValid(van) then
            ply:ChatPrint("[gScooters] Van bulunamadı!")
            return
        end
        
        ply:ChatPrint("[gScooters] Van Debug Info:")
        ply:ChatPrint("- GC_ScooterEnts exists: " .. tostring(van.GC_ScooterEnts ~= nil))
        ply:ChatPrint("- Scooter count: " .. (van.GC_ScooterEnts and #van.GC_ScooterEnts or "NIL"))
        ply:ChatPrint("- Network count: " .. van:GetNWInt("GC_ScooterAmount", -1))
        ply:ChatPrint("- Active job: " .. tostring(ply.ActiveJob))
        
        if van.GC_ScooterEnts then
            for i, ent in ipairs(van.GC_ScooterEnts) do
                ply:ChatPrint(string.format("  [%d] Valid: %s", i, tostring(IsValid(ent))))
            end
        end
    end)
    
    concommand.Add("gc_reset_van_storage", function(ply)
        if not ply:IsAdmin() then return end
        
        local van = ply.GC_Van
        if not IsValid(van) then
            ply:ChatPrint("[gScooters] Van bulunamadı!")
            return
        end
        
        -- Eski scooterları temizle
        if van.GC_ScooterEnts then
            for _, ent in ipairs(van.GC_ScooterEnts) do
                if IsValid(ent) then
                    ent:Remove()
                end
            end
        end
        
        van.GC_ScooterEnts = {}
        van:SetNWInt("GC_ScooterAmount", 0)
        ply:ChatPrint("[gScooters] Van storage reset!")
    end)
end