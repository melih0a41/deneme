-- gscooters/lua/scooters/server/sv_net.lua
-- Server tarafında scooter rezervasyon sistemi ve jail kontrolü

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

-- FİX: Global değişkenler - server tarafında
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

-- FİX: Rezervasyon fonksiyonları
local function ReserveScooter(scooter, player)
    scooterReservations[scooter] = {
        player = player,
        expireTime = CurTime() + 10
    }
    DebugPrint("Scooter", scooter:EntIndex(), "reserved for", player:Nick())
end

local function IsScooterReserved(scooter, player)
    local reservation = scooterReservations[scooter]
    if not reservation then return false end
    
    if CurTime() > reservation.expireTime then
        scooterReservations[scooter] = nil
        return false
    end
    
    return reservation.player ~= player
end

local function ClearScooterReservation(scooter)
    scooterReservations[scooter] = nil
end

-- FİX: Jail kontrolü
local function IsPlayerJailed(player)
    if not IsValid(player) then return true end
    
    if player.DarkRPJailed or player:getDarkRPVar("jailed") then
        return true
    end
    
    if player:GetNWBool("ulx_jailed", false) then
        return true
    end
    
    if player:GetNWBool("sam_jailed", false) then
        return true
    end
    
    local team = player:Team()
    if team == 1000 or team == TEAM_JAIL then
        return true
    end
    
    return false
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

    local iCount = 0
    local iStringIndex = 0

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

            if iStringIndex == table.Count(tDataExisting) and iScooterIndex == #tRack.Scooters then
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

-- FİX: Güçlendirilmiş RentScooter network
net.Receive("gScooters.Net.RentScooter", function(len, pPlayer)
    if not GC_SpamCheck("gScooters.Net.RentScooter", pPlayer) then return end
    local eScooter = net.ReadEntity()

    -- Temel kontroller
    if not IsValid(pPlayer) then
        DebugPrint("RentScooter: pPlayer is invalid")
        return
    end
    if not IsValid(eScooter) then 
        DebugPrint("RentScooter: eScooter is invalid")
        return
    end
    if not eScooter.gScooter then return end
    if IsValid(eScooter:GetPassenger(0)) then return end
    if not (pPlayer:GetPos():DistToSqr(eScooter:GetPos()) < 610000) then return end
    if not gScooters:CanAfford(pPlayer, gScooters.Config.RentalRate) then return end
    if pPlayer:Team() == TEAM_MARTI then return end

    -- FİX: Jail kontrolü
    if IsPlayerJailed(pPlayer) then
        DebugPrint("Player", pPlayer:Nick(), "is jailed, cannot rent scooter")
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
        gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!", pPlayer)
        return
    end

    -- FİX: Scooter rezervasyon kontrolü
    if IsScooterReserved(eScooter, pPlayer) then
        DebugPrint("Scooter is reserved for another player")
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
        gScooters:ChatMessage("Bu scooter başka birisi tarafından kiralanıyor!", pPlayer)
        return
    end

    -- FİX: Zaten aktif kira kontrolü
    if playerActiveRentals[pPlayer] then
        DebugPrint("Player", pPlayer:Nick(), "already has active rental")
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
        gScooters:ChatMessage("Zaten aktif bir kiranız var!", pPlayer)
        return
    end

    -- FİX: Scooter zaten kiralık mı kontrolü
    if eScooter.GC_RenterSteamID or eScooter.StartRentTime then
        DebugPrint("Scooter already rented")
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(pPlayer)
        gScooters:ChatMessage("Bu scooter zaten kiralandı!", pPlayer)
        return
    end

    -- FİX: Blacklist kontrolü
    local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]
    if iBlacklist and CurTime() < iBlacklist + (60*5) then 
        gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)
        return 
    end

    -- FİX: Scooter'ı rezerve et
    ReserveScooter(eScooter, pPlayer)

    -- FİX: Yeni rental sistemi - global tabloya kaydet
    local startTime = CurTime()
    playerActiveRentals[pPlayer] = {
        scooter = eScooter,
        startTime = startTime,
        isPending = true
    }
    
    -- Eski sistem uyumluluğu için
    eScooter.StartRentTime = startTime
    eScooter.GC_RenterSteamID = pPlayer:SteamID64()
    eScooter.GC_IsRentalPending = true
    
    pPlayer.GC_ActiveScooter = eScooter          
    pPlayer.GC_ScooterRentStartTime = startTime
    pPlayer.GC_RentalPending = true

    DebugPrint("Rental INITIATED (PENDING) for", pPlayer:Nick(), ". Scooter EntIndex:", eScooter:EntIndex())

    eScooter.GC_Enterable = true
    
    -- FİX: Binme işlemi
    local success = pPlayer:EnterVehicle(eScooter)
    
    -- Kısa gecikme ile jail kontrolü
    timer.Simple(0.1, function()
        if IsValid(pPlayer) and IsPlayerJailed(pPlayer) then
            DebugPrint("Player was jailed after entering vehicle, cancelling rental")
            
            -- Force cleanup
            if playerActiveRentals[pPlayer] then
                playerActiveRentals[pPlayer] = nil
            end
            
            if IsValid(eScooter) then
                eScooter.StartRentTime = nil
                eScooter.GC_RenterSteamID = nil
                eScooter.GC_IsRentalPending = nil
                ClearScooterReservation(eScooter)
            end
            
            pPlayer.GC_ActiveScooter = nil
            pPlayer.GC_ScooterRentStartTime = nil
            pPlayer.GC_RentalPending = nil
            
            net.Start("gScooters.Net.ResetScooterUI")
            net.WriteEntity(NULL)
            net.Send(pPlayer)
            
            return
        end
    end)
    
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
            -- FİX: Jail kontrolü eklendi
            if IsPlayerJailed(pPlayer) then
                DebugPrint("Player jailed during rental activation, cancelling")
                
                if playerActiveRentals[pPlayer] then
                    playerActiveRentals[pPlayer] = nil
                end
                
                eScooter.StartRentTime = nil
                eScooter.GC_RenterSteamID = nil
                eScooter.GC_IsRentalPending = nil
                ClearScooterReservation(eScooter)
                
                pPlayer.GC_ActiveScooter = nil
                pPlayer.GC_ScooterRentStartTime = nil
                pPlayer.GC_RentalPending = nil
                
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
                
                return
            end
            
            -- Rental durumu kontrolü
            local rental = playerActiveRentals[pPlayer]
            if rental and rental.scooter == eScooter and rental.isPending then
                -- Eğer oyuncu hala scooter'da ise kira aktifleştir
                if pPlayer:GetVehicle() == eScooter then
                    eScooter:Fire("TurnOn")
                    eScooter.GC_IsRentalPending = false
                    pPlayer.GC_RentalPending = false
                    rental.isPending = false -- Global tabloda da güncelle
                    ClearScooterReservation(eScooter)
                    
                    DebugPrint("Rental ACTIVATED for", pPlayer:Nick(), ". Scooter EntIndex:", eScooter:EntIndex())
                else
                    -- Oyuncu scooter'da değil, kira iptal
                    DebugPrint("Rental CANCELLED for", pPlayer:Nick(), "- player not in scooter")
                    
                    playerActiveRentals[pPlayer] = nil
                    
                    eScooter.StartRentTime = nil
                    eScooter.GC_RenterSteamID = nil
                    eScooter.GC_IsRentalPending = nil
                    ClearScooterReservation(eScooter)
                    
                    pPlayer.GC_ActiveScooter = nil
                    pPlayer.GC_ScooterRentStartTime = nil
                    pPlayer.GC_RentalPending = nil
                    
                    net.Start("gScooters.Net.ResetScooterUI")
                    net.WriteEntity(NULL)
                    net.Send(pPlayer)
                end
            else
                -- Rental durumu değişmiş
                DebugPrint("Rental state changed during activation timer")
            end
        else
            DebugPrint("Rental timer failed - player or scooter invalid")
            
            if IsValid(pPlayer) then
                if playerActiveRentals[pPlayer] then
                    playerActiveRentals[pPlayer] = nil
                end
                
                net.Start("gScooters.Net.ResetScooterUI")
                net.WriteEntity(NULL)
                net.Send(pPlayer)
            end
            
            if IsValid(eScooter) then
                ClearScooterReservation(eScooter)
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

-- FİX: Rezervasyon temizleme timer'ı
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
    
    if cleanedCount > 0 and gScooters.Config.DebugMode then
        print("[gScooters] Cleaned", cleanedCount, "expired reservations")
    end
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
    
    -- FİX: Debug komutu - rezervasyonları göster
    concommand.Add("gc_debug_reservations", function(ply)
        if not ply:IsAdmin() then return end
        
        ply:ChatPrint("[gScooters] Active Reservations:")
        local count = 0
        for scooter, reservation in pairs(scooterReservations) do
            if IsValid(scooter) and IsValid(reservation.player) then
                local remaining = reservation.expireTime - CurTime()
                ply:ChatPrint(string.format("- Scooter %s: %s (%.1fs left)", 
                    tostring(scooter:EntIndex()), 
                    reservation.player:Nick(), 
                    remaining))
                count = count + 1
            end
        end
        if count == 0 then
            ply:ChatPrint("- No active reservations")
        end
    end)
    
    -- FİX: Aktif kiralar debug komutu
    concommand.Add("gc_debug_rentals", function(ply)
        if not ply:IsAdmin() then return end
        
        ply:ChatPrint("[gScooters] Active Rentals:")
        local count = 0
        for player, rental in pairs(playerActiveRentals) do
            if IsValid(player) then
                ply:ChatPrint(string.format("- %s: Scooter %s, Pending: %s", 
                    player:Nick(),
                    IsValid(rental.scooter) and rental.scooter:EntIndex() or "INVALID",
                    tostring(rental.isPending)))
                count = count + 1
            end
        end
        if count == 0 then
            ply:ChatPrint("- No active rentals")
        end
    end)
    
    -- FİX: Force cleanup komutu
    concommand.Add("gc_force_cleanup", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        
        local target = args[1]
        if not target then
            ply:ChatPrint("[gScooters] Usage: gc_force_cleanup <player_name>")
            return
        end
        
        local targetPlayer = nil
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), string.lower(target)) then
                targetPlayer = p
                break
            end
        end
        
        if not IsValid(targetPlayer) then
            ply:ChatPrint("[gScooters] Player not found!")
            return
        end
        
        -- Force cleanup using the new system
        if playerActiveRentals[targetPlayer] then
            playerActiveRentals[targetPlayer] = nil
        end
        
        for scooter, reservation in pairs(scooterReservations) do
            if reservation.player == targetPlayer then
                scooterReservations[scooter] = nil
            end
        end
        
        targetPlayer.GC_ActiveScooter = nil
        targetPlayer.GC_ScooterRentStartTime = nil
        targetPlayer.GC_RentalPending = nil
        
        net.Start("gScooters.Net.ResetScooterUI")
        net.WriteEntity(NULL)
        net.Send(targetPlayer)
        
        ply:ChatPrint("[gScooters] Force cleanup completed for " .. targetPlayer:Nick())
    end)
end