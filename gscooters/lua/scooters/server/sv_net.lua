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
util.AddNetworkString("gScooters.Net.CloseScooterUI") -- YENİ

local tCooldowns = {}
local iTimeout = 0.5

-- UI kilitleme sistemi için
local activeScooterUIs = {} -- {[scooter] = player} UI açık olan scooterları takip eder

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

-- SPAWN DÜZELTMESİ BAŞLANGIÇ
function gScooters:SpawnEntities()
    if bSpawning then 
        print("[gScooters] Already spawning entities, skipping...")
        return 
    end

    print("[gScooters] Starting to spawn entities...")
    bSpawning = true

    -- Önce mevcut entity'leri temizle
    for _, eEntity in ipairs(gScooters.Entities) do
        if IsValid(eEntity) then 
            eEntity:Remove() 
        end
    end
    
    -- Tabloları sıfırla
    gScooters.Entities = {}
    gScooters.RackEntities = {}

    local tDataExisting
    if file.Exists("gscooters/maps/"..sMap..".json", "DATA") then 
        local fileContent = file.Read("gscooters/maps/"..sMap..".json", "DATA")
        tDataExisting = util.JSONToTable(fileContent)
        print("[gScooters] Loaded map data for:", sMap)
    else
        print("[gScooters] No map data found for:", sMap)
        tDataExisting = {}
        bSpawning = false
        return
    end

    tDataExisting[GC_RACK] = tDataExisting[GC_RACK] or {}
    tDataExisting[GC_NPC] = tDataExisting[GC_NPC] or {}

    gScooters.Data = tDataExisting

    local iCount = 0
    local iTotalScooters = 0
    local iSpawnedScooters = 0

    -- Önce toplam scooter sayısını hesapla
    for iRackIndex, tRack in pairs(tDataExisting[GC_RACK]) do
        if tRack.Scooters then
            iTotalScooters = iTotalScooters + #tRack.Scooters
        end
    end

    print("[gScooters] Total scooters to spawn:", iTotalScooters)

    -- Scooter'ları spawn et
    for iRackIndex, tRack in pairs(tDataExisting[GC_RACK]) do
        gScooters.RackEntities[iRackIndex] = {}

        if tRack.Scooters then
            for iScooterIndex, vPos in ipairs(tRack.Scooters) do
                iCount = iCount + 0.1

                timer.Simple(iCount, function()
                    -- Pozisyon ve açı kontrolü
                    if not vPos or not tRack.Angle then
                        print("[gScooters] Invalid position or angle for scooter")
                        iSpawnedScooters = iSpawnedScooters + 1 -- Hatalı olsa bile say
                        return
                    end

                    local eScooter = gScooters:CreateScooter(vPos, tRack.Angle)
                    if IsValid(eScooter) then
                        table.insert(gScooters.Entities, eScooter)
                        table.insert(gScooters.RackEntities[iRackIndex], eScooter)
                        eScooter.GC_OriginalRack = iRackIndex
                        
                        iSpawnedScooters = iSpawnedScooters + 1
                        print("[gScooters] Spawned scooter", iSpawnedScooters, "/", iTotalScooters)
                    else
                        print("[gScooters] Failed to create scooter at position:", vPos)
                        iSpawnedScooters = iSpawnedScooters + 1 -- Hatalı olsa bile say
                    end
                    
                    -- Son scooter spawn edildiğinde
                    if iSpawnedScooters >= iTotalScooters then
                        bSpawning = false
                        print("[gScooters] All scooters processed!")
                    end
                end)
            end
        end
    end

    -- NPC'leri spawn et
    local iNPCCount = 0
    for sName, tNPC in pairs(tDataExisting[GC_NPC]) do
        timer.Simple(0.5, function()
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
                
                iNPCCount = iNPCCount + 1
                print("[gScooters] Spawned NPC:", sName)
            else
                print("[gScooters] Failed to create NPC:", sName)
            end
        end)
    end

    -- Eğer hiç scooter yoksa spawning durumunu sıfırla
    if iTotalScooters == 0 then
        bSpawning = false
        print("[gScooters] No scooters to spawn")
    end
end

-- Debug komutları
concommand.Add("gscooter_debug_spawn", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    print("=== G-Scooter Debug Info ===")
    print("Total Entities:", #gScooters.Entities)
    print("Spawning Status:", bSpawning)
    
    local validCount = 0
    for _, ent in ipairs(gScooters.Entities) do
        if IsValid(ent) then
            validCount = validCount + 1
        end
    end
    print("Valid Entities:", validCount)
    
    print("\n=== Rack Info ===")
    for rackID, scooters in pairs(gScooters.RackEntities) do
        local validScooters = 0
        for _, scooter in ipairs(scooters) do
            if IsValid(scooter) then
                validScooters = validScooters + 1
            end
        end
        print("Rack", rackID, ":", validScooters, "valid scooters")
    end
end)

concommand.Add("gscooter_force_spawn", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    print("[gScooters] Force spawning entities...")
    bSpawning = false -- Reset spawn lock
    gScooters:SpawnEntities()
end)

concommand.Add("gscooter_check_data", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local filePath = "gscooters/maps/"..sMap..".json"
    
    if file.Exists(filePath, "DATA") then
        local data = file.Read(filePath, "DATA")
        local tData = util.JSONToTable(data)
        
        print("=== Map Data for", sMap, "===")
        
        if tData[GC_RACK] then
            local totalScooters = 0
            for rackID, rack in pairs(tData[GC_RACK]) do
                if rack.Scooters then
                    print("Rack", rackID, "has", #rack.Scooters, "scooter positions")
                    totalScooters = totalScooters + #rack.Scooters
                end
            end
            print("Total scooter positions:", totalScooters)
        else
            print("No rack data found!")
        end
        
        if tData[GC_NPC] then
            local npcCount = 0
            for name, _ in pairs(tData[GC_NPC]) do
                npcCount = npcCount + 1
            end
            print("Total NPCs:", npcCount)
        else
            print("No NPC data found!")
        end
    else
        print("No data file found at:", filePath)
    end
end)
-- SPAWN DÜZELTMESİ BİTİŞ

-- YENİ: UI kapatma network receiver
net.Receive("gScooters.Net.CloseScooterUI", function(len, pPlayer)
    local eScooter = net.ReadEntity()
    if IsValid(eScooter) and activeScooterUIs[eScooter] == pPlayer then
        activeScooterUIs[eScooter] = nil
    end
end)

-- NOT: RentScooter artık sv_hooks.lua dosyasında tanımlı!

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