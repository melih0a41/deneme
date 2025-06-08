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

local tCooldowns = {}
local iTimeout = 0.5

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

    if not IsValid(pPlayer) then -- Oyuncu geçerli değilse erken çık
        print("[gScooters DEBUG RentScooter] pPlayer is invalid at start of RentScooter net message.")
        return
    end
    if not IsValid(eScooter) then 
        print("[gScooters DEBUG RentScooter] eScooter is invalid for pPlayer: " .. pPlayer:Nick())
        return
    end
    if not eScooter.gScooter then return end
    if IsValid(eScooter:GetPassenger(0)) then return end
    if not (pPlayer:GetPos():DistToSqr(eScooter:GetPos()) < 610000) then return end
    if not gScooters:CanAfford(pPlayer, gScooters.Config.RentalRate) then return end
    if pPlayer:Team() == TEAM_MARTI then return end

    local iBlacklist = gScooters.PlayerBlacklists[pPlayer:SteamID64()]
    if iBlacklist and CurTime() < iBlacklist + (60*5) then return end

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
    timer.Simple(5, function() 
        if IsValid(pPlayer) and IsValid(eScooter) and pPlayer:GetVehicle() == eScooter then
            eScooter:Fire("TurnOn")
            local startTime = CurTime()
            eScooter.StartRentTime = startTime
            eScooter.GC_RenterSteamID = pPlayer:SteamID64() 

            pPlayer.GC_ActiveScooter = eScooter          
            pPlayer.GC_ScooterRentStartTime = startTime 
            
            -- DEBUG PRINT MESAJLARI BAŞLANGIÇ
            print("[gScooters DEBUG] Rental START for " .. pPlayer:Nick() .. ". Scooter EntIndex: " .. eScooter:EntIndex())
            print("[gScooters DEBUG]   eScooter.StartRentTime: " .. tostring(eScooter.StartRentTime))
            print("[gScooters DEBUG]   eScooter.GC_RenterSteamID: " .. tostring(eScooter.GC_RenterSteamID))
            print("[gScooters DEBUG]   pPlayer.GC_ActiveScooter EntIndex: " .. (IsValid(pPlayer.GC_ActiveScooter) and pPlayer.GC_ActiveScooter:EntIndex() or "NIL_OR_INVALID"))
            print("[gScooters DEBUG]   pPlayer.GC_ScooterRentStartTime: " .. tostring(pPlayer.GC_ScooterRentStartTime))
            -- DEBUG PRINT MESAJLARI BİTİŞ
        else
            if IsValid(pPlayer) then 
                print("[gScooters DEBUG] Rental attempt failed or player " .. pPlayer:Nick() .. " left vehicle early. Calling HandleEnd.")
                if IsValid(eScooter) then
                    eScooter.StartRentTime = CurTime() - 5 
                end
                gScooters:HandleEnd(eScooter, pPlayer)
            else
                print("[gScooters DEBUG] Rental attempt failed: Player or Scooter became invalid before 5s timer completion (pPlayer invalid in else).")
            end
        end
    end)

    eScooter:EmitSound("gscooters/scooter_unlock.wav", 45)
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
    if not GC_SpamCheck("gScooters.Net.PickupScooter", pPlayer) then return end

    local eEnt = pPlayer:GetEyeTrace().Entity
    local eVan = pPlayer.GC_Van

    if IsValid(eEnt) and IsValid(eVan) and eEnt.gScooter and IsValid(eVan.GC_Owner) and eVan.GC_Owner.ActiveJob and eEnt:GetPos():DistToSqr(eVan:GetPos()) < 700000 then 
        eVan.GC_ScooterEnts = eVan.GC_ScooterEnts or {}

        if #eVan.GC_ScooterEnts < gScooters.Config.ScooterPickupRequirement and IsValid(eVan.GC_Owner:GetVehicle()) and not eVan.GC_Owner:GetVehicle().GC_Owner then 
            local eScooter = ents.Create("prop_physics")
            if IsValid(eEnt) and eEnt.GC_OriginalSpawnPos and (eEnt:GetPos() - eEnt.GC_OriginalSpawnPos):Length() < 50 then
                DarkRP.notify(pPlayer, 1, 4, "Scooter daha hareket ettirilmemiş, park yerinden toplanamaz!")
                return
            end

            eScooter:SetModel("models/dannio/gscooters.mdl")
            eScooter:SetPos(eVan:LocalToWorld(Vector(0, (#eVan.GC_ScooterEnts*-20), 24)))
            eScooter:SetAngles(eVan:GetAngles() + Angle(0, 90, 0))
            eScooter:SetParent(eVan)
            eScooter:Spawn()
    
            eVan:EmitSound("items/ammocrate_open.wav")

            eScooter.GC_OriginalSpawnPos = eEnt.GC_OriginalSpawnPos 
            eScooter.GC_OriginalSpawnAng = eEnt.GC_OriginalSpawnAng 
            
            eScooter.GC_OriginalRack = eEnt.GC_OriginalRack 
            eEnt:Remove()

            table.insert(eVan.GC_ScooterEnts, eScooter)

            eVan:SetNWInt("GC_ScooterAmount", #eVan.GC_ScooterEnts)

            if #eVan.GC_ScooterEnts == (gScooters.Config.ScooterPickupRequirement) then
                if IsValid(eVan.GC_Owner) then -- eVan.GC_Owner geçerliliğini kontrol et
                    gScooters:ChatMessage(gScooters:GetPhrase("max_scooters"), eVan.GC_Owner)

                    net.Start("gScooters.Net.SendWaypoint")
                    net.WriteEntity(eVan.GC_NPC)
                    net.Send(eVan.GC_Owner)
                end
            end
        else
            if IsValid(eVan.GC_Owner) then 
                 gScooters:ChatMessage(gScooters:GetPhrase("max_scooters"), eVan.GC_Owner)
                if IsValid(eVan.GC_NPC) then -- eVan.GC_NPC geçerliliğini de kontrol et
                    net.Start("gScooters.Net.SendWaypoint")
                    net.WriteEntity(eVan.GC_NPC)
                    net.Send(eVan.GC_Owner)
                end
            end
        end
    else
        if IsValid(pPlayer) and IsValid(eVan) and IsValid(eVan.GC_Owner) then 
            gScooters:ChatMessage(gScooters:GetPhrase("too_far"), eVan.GC_Owner)
        elseif IsValid(pPlayer) then
             -- Oyuncuya eVan veya GC_Owner'ın geçerli olmadığına dair bir mesaj verilebilir, veya sessiz kalabilir.
             -- print("[gScooters DEBUG PickupScooter] too_far check failed, eVan or eVan.GC_Owner invalid for player " .. pPlayer:Nick())
        end
    end
end)