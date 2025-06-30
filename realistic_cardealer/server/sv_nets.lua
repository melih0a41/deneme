/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

util.AddNetworkString("RCD:Admin:Configuration")
util.AddNetworkString("RCD:Admin:Players")
util.AddNetworkString("RCD:Main:Client")
util.AddNetworkString("RCD:Main:Job")
util.AddNetworkString("RCD:Notification")
util.AddNetworkString("RCD:Insurance")

net.Receive("RCD:Admin:Configuration", function(len, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not RCD.AdminRank[ply:GetUserGroup()] then return end

    ply.RCD = ply.RCD or {}

    local curTime = CurTime()

    ply.RCD["spamConfig"] = ply.RCD["spamConfig"] or 0
    if ply.RCD["spamConfig"] > curTime then return end
    ply.RCD["spamConfig"] = curTime + 0.5
 
    local uInt = net.ReadUInt(4)

    --[[ Create/Edit a vehicle group ]]
    if uInt == 1 then
        local editGroup = net.ReadBool()

        local groupId = net.ReadUInt(32)
        local groupName = net.ReadString()
        
        local countRankAccess = net.ReadUInt(8)
        local rankAccess = {}
        for i=1, countRankAccess do
            local rankName = net.ReadString()

            rankAccess[rankName] = true
        end

        local countJobAccess = net.ReadUInt(8)
        local jobAccess = {}
        for i=1, countJobAccess do
            local jobName = net.ReadString()

            jobAccess[jobName] = true
        end

        if not isstring(groupName) or groupName == "" or groupName == "default" then ply:RCDNotification(5, RCD.GetSentence("invalidGroupName")) return end
        RCD.ManageVehicleGroup((editGroup and groupId or nil), groupName, rankAccess, jobAccess, false, ply)
    --[[ Remove a vehicle group ]]
    elseif uInt == 2 then
        local groupId = net.ReadUInt(32)
        if not isnumber(groupId) then ply:RCDNotification(5, RCD.GetSentence("invalidGroupVehicle")) return end

        RCD.RemoveVehicleGroup(groupId, false, ply)
    --[[ Create/Edit a vehicle ]]
    elseif uInt == 3 then
        local vehicleName = net.ReadString()
        local vehiclePrice = tonumber(net.ReadString())
        local vehicleClass = net.ReadString()
        local groupId = net.ReadUInt(32)

        local optionsCount = net.ReadUInt(12)
        local vehicleOptions = {}
        for i=1, optionsCount do
            local valueType = net.ReadString()
            local key = net.ReadString()
            local value = net["Read"..RCD.TypeNet[valueType]]((RCD.TypeNet[valueType] == "Int") and 32)

            vehicleOptions[key] = value
        end

        local editVehicle = net.ReadBool()
        local vehicleId = net.ReadUInt(32)

        if not isstring(vehicleClass) or vehicleClass == "" or vehicleClass == "default" then ply:RCDNotification(5, RCD.GetSentence("invalidVehicleClass")) return end
        if not isnumber(groupId) then ply:RCDNotification(5, RCD.GetSentence("invalidGroupVehicle")) return end
        if not isstring(vehicleName) or vehicleName == "" or vehicleName == "default" then ply:RCDNotification(5, RCD.GetSentence("invalidVehicleName")) return end
        if not isnumber(vehiclePrice) or vehiclePrice < 0 or vehiclePrice > 99999999999 then RCD.Notification(5, RCD.GetSentence("invalidVehiclePrice")) return end
    
        RCD.ManageVehicle((editVehicle and vehicleId or nil), vehicleName, vehiclePrice, vehicleClass, vehicleOptions, groupId, false, ply)
    --[[ Remove a vehicle ]]
    elseif uInt == 4 then
        local vehicleId = net.ReadUInt(32)
        if not isnumber(vehicleId) then ply:RCDNotification(5, RCD.GetSentence("invalidGroupVehicle")) return end

        RCD.RemoveConfigVehicle(vehicleId, false, ply)
    --[[ Update NPC info ]]
    elseif uInt == 5 then
        local npcId = net.ReadUInt(32)
        local npcName = net.ReadString()
        local npcModel = net.ReadString()
        local npcClass = net.ReadString()
        
        if npcClass == "rcd_cardealer" then
            local plateforms = {}
            local plateformsCount = net.ReadUInt(12)
            for i=1, plateformsCount do
                local pos, ang = net.ReadVector(), net.ReadAngle()
                
                plateforms[#plateforms + 1] = {
                    ["pos"] = pos, 
                    ["ang"] = ang,
                }
            end
            
            local groups = {}
            local groupsCount = net.ReadUInt(12)
            for i=1, groupsCount do
                local groupId = net.ReadUInt(32)
                local activate = net.ReadBool()
                
                groups[groupId] = activate
            end
            
            local pos, ang =  RCD.GetNPCPosAng(npcId)
            if not isvector(pos) or not isangle(ang) then return end

            local disableGarage = net.ReadBool()
            local disableShop = net.ReadBool() 
            
            RCD.RemoveNPC(npcId, false)
            RCD.CreateNPC(npcId, npcName, npcModel, pos, ang, plateforms, groups, string.lower(game.GetMap()), disableShop, disableGarage)
    
            ply:RCDNotification(5, RCD.GetSentence("pnjUpdated"):format(npcName))
        elseif npcClass == "rcd_reseller" then
            local pos, ang =  RCD.GetResellerNPCPosAng(npcId)
            if not isvector(pos) or not isangle(ang) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499
            
            RCD.RemoveResellerNPC(npcId, false)
            RCD.CreateResellerNPC(npcId, npcName, npcModel, pos, ang, string.lower(game.GetMap()))
    
            ply:RCDNotification(5, RCD.GetSentence("pnjUpdated"):format(npcName))
        end

    --[[ Delete a NPC ]]
    elseif uInt == 6 then
        local npcId = net.ReadUInt(32)
        if not isnumber(npcId) then return end

        local npcClass = net.ReadString()
        if npcClass == "rcd_cardealer" then
            RCD.RemoveNPC(npcId, true)
        elseif npcClass == "rcd_reseller" then
            RCD.RemoveResellerNPC(npcId, true)
        end
        
        ply:RCDNotification(5, RCD.GetSentence("pnjDeleted"):format(npcId))
    --[[ Place plateforms ]]
    elseif uInt == 7 then
        local npcId = net.ReadUInt(32)
        if not isnumber(npcId) then return end

        local plateformsTable = RCD.GetPlateforms(npcId)

        if not ply:HasWeapon("gmod_tool") then
            ply:Give("gmod_tool")
        end
        ply:SelectWeapon("gmod_tool")

        RCD.SetNWVariable("rcd_place_plateform", true, ply, true, ply)
        RCD.SetNWVariable("rcd_npc_id", npcId, ply, true, ply)

        net.Start("RCD:Admin:Configuration")
            net.WriteUInt(9, 4)
            net.WriteUInt(#plateformsTable, 12)
            for k,v in ipairs(plateformsTable) do
                net.WriteVector(v.pos)
                net.WriteAngle(v.ang)
            end
        net.Send(ply)

        ply:RCDNotification(5, RCD.GetSentence("plateformEditMode"))
    --[[ Save plateforms ]]
    elseif uInt == 8 then
        local npcId = RCD.GetNWVariables("rcd_npc_id", ply)
        if not isnumber(npcId) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

        local plateformsTable = {}
        local plateformsCount = net.ReadUInt(8)
        for i=1, plateformsCount do
            plateformsTable[#plateformsTable + 1] = {
                ["pos"] = net.ReadVector(),
                ["ang"] = net.ReadAngle()
            }
        end

        RCD.SetNPCPlateforms(npcId, plateformsTable)
        RCD.SetNWVariable("rcd_place_plateform", false, ply, true, ply)
		RCD.SetNWVariable("rcd_npc_id", false, ply, true, ply)

        ply:RCDNotification(5, RCD.GetSentence("beenSaved"):format(#plateformsTable))
        RCD.LoadNPC()  
    --[[ Remove all plateforms ]]
    elseif uInt == 9 then
        local npcId = net.ReadUInt(32)
        if not isnumber(npcId) then return end

        RCD.SetNPCPlateforms(npcId, {})
        ply:RCDNotification(5, RCD.GetSentence("allPlateformsDeleted"))
    --[[ Save all settings ]]
    elseif uInt == 10 then
        local settings = {}
        local settingsCount = net.ReadUInt(12)

        for i=1, settingsCount do
            local valueType = net.ReadString()
            local key = net.ReadString()
            local value = net["Read"..RCD.TypeNet[valueType]](((RCD.TypeNet[valueType] == "Int") and 32))

            settings[key] = value
        end

        RCD.SetSettings(settings)
        ply:RCDNotification(5, RCD.GetSentence("serverConfigurationUpdated"))        
    end
end)

net.Receive("RCD:Main:Client", function(len, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply.RCD = ply.RCD or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

    local curTime = CurTime()

    ply.RCD["spamClient"] = ply.RCD["spamClient"] or 0
    if ply.RCD["spamClient"] > curTime then return end
    ply.RCD["spamClient"] = curTime + 0.5

    local uInt = net.ReadUInt(4)

    local npc = ply.RCD["ent_used"]
    if not IsValid(npc) then return end

    local dist = ply:GetPos():DistToSqr(npc:GetPos())
    if dist > 30000 then ply:RCDNotification(5, RCD.GetSentence("npcTooFar")) return end

    --[[ Buy/Sell vehicle ]]
    if uInt == 1 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableShop"] then
            ply:RCDNotification(5, RCD.GetSentence("shopDisabled"))
            return 
        end

        local bought = net.ReadBool()
        local vehicleId = net.ReadUInt(32)

        if bought then
            ply:RCDSellVehicle(vehicleId)
        else
            ply:RCDBuyVehicle(vehicleId)
        end
    --[[ Spawn a vehicle with his uniqueId ]]
    elseif uInt == 2 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        local vehicleId = net.ReadUInt(32)

        ply:RCDSpawnVehicle(vehicleId)
    --[[ Spawn a vehicle test with his uniqueId ]]
    elseif uInt == 3 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        local vehicleId = net.ReadUInt(32)

        ply:RCDSpawnVehicle(vehicleId, true)
    --[[ Return a vehicle with his unique id ]]
    elseif uInt == 4 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        local vehicleId = net.ReadUInt(32)

        ply:RCDReturnVehicle(vehicleId)
    --[[ Buy a customization for a specific vehicle ]]
    elseif uInt == 5 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        local vehicleId = net.ReadUInt(32)

        local vehicleSkin = net.ReadUInt(8)
        local vehicleNitro = net.ReadUInt(2)
        local hasColor = net.ReadBool()
        local vehicleColor = net.ReadColor()
        local hasUnderglow = net.ReadBool()
        local vehicleUnderglow = net.ReadColor()
        local bodygroupCount = net.ReadUInt(8)

        local vehicleBodygroups = {}
        for i=1, bodygroupCount do
            local k = net.ReadUInt(8)
            local v = net.ReadUInt(8)

            vehicleBodygroups[k] = v
        end

        local customization = {
            ["vehicleSkin"] = vehicleSkin,
            ["vehicleNitro"] = vehicleNitro,
            ["vehicleColor"] = (hasColor and vehicleColor or nil),
            ["vehicleUnderglow"] = (hasUnderglow and vehicleUnderglow or nil),
            ["vehicleBodygroups"] = vehicleBodygroups,
        }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9
        
        ply:RCDBuyCustomization(vehicleId, customization)
    --[[ Return all vehicles around the player ]]
    elseif uInt == 6 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        ply:RCDReturnAroundVehicles()

    --[[ Pay insurance system ]]
    elseif uInt == 7 then
        local npcTable = RCD.GetNPCInfo(npc)
        if npcTable["disableGarage"] then 
            ply:RCDNotification(5, RCD.GetSentence("garageDisabled"))
            return 
        end

        local vehicleId = net.ReadUInt(32)
        if ply:RCDCheckInsurance(vehicleId) then return end

        ply:RCDInsurance(vehicleId)
    end
end)

net.Receive("RCD:Main:Job", function(len, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    ply.RCD = ply.RCD or {}

    local curTime = CurTime()

    ply.RCD["spamJob"] = ply.RCD["spamJob"] or 0
    if ply.RCD["spamJob"] > curTime then return end
    ply.RCD["spamJob"] = curTime + 1
    
    local uInt = net.ReadUInt(4)
    
    --[[ Print the paper with all information on it ]]
    if uInt == 1 then
        if RCD.GetSetting("carDealerJob", "string") != team.GetName(ply:Team()) then ply:RCDNotification(5, RCD.GetSentence("notGoodTeam")) return end
        if not IsValid(ply.RCD["printerUsed"]) then return end

        local vehicleId = net.ReadUInt(32)
        local vehicleCommission = net.ReadUInt(32)

        local vehicleColor = net.ReadColor()
        local vehicleSkin = net.ReadUInt(5)
        local vehicleUnderglow = net.ReadColor()

        local vehicleParams = {
            ["vehicleId"] = vehicleId,
            ["vehicleCommission"] = vehicleCommission,
            ["vehicleSkin"] = vehicleSkin,
            ["vehicleColor"] = vehicleColor,
            ["vehicleUnderglow"] = vehicleUnderglow,
            ["carDealer"] = ply:Name(),
        }
        
        ply:RCDStartPrinting(ply.RCD["printerUsed"], vehicleId, vehicleParams)

    --[[ Create or customize the vehicle linked to the showcase ]]
    elseif uInt == 2 then
        if RCD.GetSetting("carDealerJob", "string") != team.GetName(ply:Team()) then ply:RCDNotification(5, RCD.GetSentence("notGoodTeam")) return end

        local showcase = net.ReadEntity()
        if not IsValid(showcase) then return end

        local vehicleId = net.ReadUInt(32)
        local vehicleCommission = net.ReadUInt(32)

        local vehicleSkin = net.ReadUInt(8)
        local vehicleColor = net.ReadColor()
        local vehicleUnderglow = net.ReadColor()
        local bodygroupCount = net.ReadUInt(8)

        local vehicleBodygroups = {}
        for i=1, bodygroupCount do
            local k = net.ReadUInt(8)
            local v = net.ReadUInt(8)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

            vehicleBodygroups[k] = v
        end

        local vehicleParams = {
            ["vehicleId"] = vehicleId,
            ["vehicleCommission"] = vehicleCommission,
            ["vehicleSkin"] = vehicleSkin,
            ["vehicleUnderglow"] = vehicleUnderglow,
            ["vehicleColor"] = vehicleColor,
            ["vehicleBodygroups"] = vehicleBodygroups,
        }

        ply:RCDManageJobVehicle(showcase, vehicleParams)
    
    --[[ Remove the vehicle linked to the showcase and refund the player ]]
    elseif uInt == 3 then
        if RCD.GetSetting("carDealerJob", "string") != team.GetName(ply:Team()) then ply:RCDNotification(5, RCD.GetSentence("notGoodTeam")) return end

        local showcase = net.ReadEntity()
        if not IsValid(showcase) then return end
        
        ply:RCDSellJobVehicles(showcase)
    --[[ Buy the vehicle, remove the invoice and add the vehicle to the player ]]
    elseif uInt == 4 then
        ply:RCDAcceptInvoice()
    end
end)

net.Receive("RCD:Admin:Players", function(len, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    ply.RCD = ply.RCD or {}

    local curTime = CurTime()

    ply.RCD["spamAdmin"] = ply.RCD["spamAdmin"] or 0
    if ply.RCD["spamAdmin"] > curTime then return end
    ply.RCD["spamAdmin"] = curTime + 1

    if not RCD.AdminRank[ply:GetUserGroup()] then return end

    local uInt = net.ReadUInt(4)

    --[[ Get all vehicles bought by a player]]
    if uInt == 1 then
        local steamId64 = net.ReadString()
        steamId64 = string.find("STEAM_", steamId64) and util.SteamIDTo64(steamId64) or steamId64

        RCD.Query(("SELECT * FROM rcd_bought_vehicles WHERE playerId = %s"):format(RCD.Escape(steamId64)), function(vehiclesOwned)
            vehiclesOwned = vehiclesOwned or {}
            local tableToSend = {}
            
            net.Start("RCD:Admin:Players")
                net.WriteUInt(1, 4)
                net.WriteString(steamId64)
                net.WriteUInt(table.Count(vehiclesOwned), 12)
                for k, v in ipairs(vehiclesOwned) do
                    net.WriteUInt(tonumber(v.vehicleId), 32)
                end
            net.Send(ply)
        end)
    --[[ Add and remove to the player vehicles ]]
    elseif uInt == 2 then
        local steamId64 = net.ReadString()
        steamId64 = string.find("STEAM_", steamId64) and util.SteamIDTo64(steamId64) or steamId64

        local vehiclesInformationsCount = net.ReadUInt(12)
        for i=1, vehiclesInformationsCount do
            local vehicleId = net.ReadUInt(32)
            local add = net.ReadBool()

            if add then
                RCD.GiveVehicle(steamId64, vehicleId)
            else
                RCD.RemoveVehicle(steamId64, vehicleId)
            end
        end

        local target = player.GetBySteamID64(steamId64)
        ply:RCDNotification(5, RCD.GetSentence("modifiedInformation"):format((IsValid(target) and target:Name() or steamId64)))

        net.Start("RCD:Admin:Players")
            net.WriteUInt(2, 4)
        net.Send(ply)
    end
end)

net.Receive("RCD:Insurance", function(len, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply.RCD = ply.RCD or {}

    local curTime = CurTime()

    ply.RCD["spamInsurance"] = ply.RCD["spamInsurance"] or 0
    if ply.RCD["spamInsurance"] > curTime then return end
    ply.RCD["spamInsurance"] = curTime + 0.5
 
    local uInt = net.ReadUInt(5)
    if uInt == 1 then
        local npc = ply.RCD["resellerUse"]
        if not IsValid(npc) then return end
    
        local dist = ply:GetPos():DistToSqr(npc:GetPos())
        if dist > 30000 then ply:RCDNotification(5, RCD.GetSentence("npcTooFar")) return end

        local vehc = net.ReadEntity()
        RCD.ResellVehicle(vehc, ply)
    end
end)
