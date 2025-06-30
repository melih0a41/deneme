/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.7 (stable)
*/

local PLAYER = FindMetaTable("Player")
local RCDMap = string.lower(game.GetMap())

--[[ Initialize all groups into the advanced configuration table ]]
function RCD.InitializeGroups()
    RCD.AdvancedConfiguration["groupsList"] = RCD.AdvancedConfiguration["groupsList"] or {}

    RCD.Query("SELECT * FROM rcd_groups", function(groupsTable)
        groupsTable = groupsTable or {}

        for k,v in ipairs(groupsTable) do
            v.id = tonumber(v.id)
            v.rankAccess = util.JSONToTable(v.rankAccess or "") or {}
            v.jobAccess = util.JSONToTable(v.jobAccess or "") or {}
            
            RCD.AdvancedConfiguration["groupsList"][v.id] = v
        end
        
        RCD.RefreshCompressedGroups()
    end)
end

--[[ Initialize all vehicles into the advanced configuration table ]]
function RCD.InitializeVehicles()
    RCD.AdvancedConfiguration["vehiclesList"] = RCD.AdvancedConfiguration["vehiclesList"] or {}
    RCD.VehiclesList = RCD.GetAllVehicles() or {}

    RCD.Query("SELECT * FROM rcd_vehicles", function(vehiclesTable)
        vehiclesTable = vehiclesTable or {}

        for k,v in ipairs(vehiclesTable) do
            if not RCD.VehiclesList[v.class] then continue end
    
            v.id = tonumber(v.id)
            v.groupId = tonumber(v.groupId)
            v.options = util.JSONToTable(v.options or "") or {}

            if RCD.GetSetting("precacheModels", "boolean") then 
                if isstring(RCD.VehiclesList[v.class]["Model"]) then
                    util.PrecacheModel(RCD.VehiclesList[v.class]["Model"])
                end
            end
            
            RCD.AdvancedConfiguration["vehiclesList"][v.id] = v             
        end
    
        RCD.RefreshCompressedVehicles()
    end)
end

--[[ Add some params to the npc ]]
function RCD.ParamsNPC(pos, ang, model, npcId, disableShop, disableGarage)
    RCD.Query(("SELECT * FROM rcd_npc_params WHERE npcId = %s"):format(RCD.Escape(npcId)), function(npcTable)
        local params = {
            ["disableShop"] = disableShop,
            ["disableGarage"] = disableGarage,
        }

        params = util.TableToJSON(params)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 38816525778563e1ebed6bf433402b83d60a8b0f4aa587d107b57a8aa40ff761

        if not npcTable or not npcTable[1] then
            RCD.Query(("INSERT INTO rcd_npc_params (npcId, params) VALUES (%s, %s)"):format(RCD.Escape(npcId), RCD.Escape(params)), function()                
                RCD.CreateNPCEntity(pos, ang, model, npcId, disableShop, disableGarage)
            end)
        else
            RCD.Query(("UPDATE rcd_npc_params SET params = %s WHERE npcId = %s"):format(RCD.Escape(params), RCD.Escape(npcId)), function()
                RCD.CreateNPCEntity(pos, ang, model, npcId, disableShop, disableGarage)
            end)
        end
    end)
end

--[[ Create cardealer NPC ]]
function RCD.CreateNPC(npcId, name, model, pos, ang, plateforms, groups, map, disableShop, disableGarage)
    if not isvector(pos) then return end
    if not isangle(ang) then return end

    local edit = isnumber(npcId)

    plateforms = istable(plateforms) and plateforms or {}
    plateforms = util.TableToJSON(plateforms)
    
    groups = istable(groups) and groups or {}
    groups = util.TableToJSON(groups)

    pos, ang = tostring(pos), tostring(ang)
    
    if edit then
        RCD.Query(("UPDATE rcd_npc SET map = %s, name = %s, model = %s, pos = %s, ang = %s, plateforms = %s, groups_npc = %s WHERE map = %s AND id = %s"):format(RCD.Escape(map), RCD.Escape(name), RCD.Escape(model), RCD.Escape(pos), RCD.Escape(ang), RCD.Escape(plateforms), RCD.Escape(groups), RCD.Escape(RCDMap), RCD.Escape(npcId)), function()
            RCD.ParamsNPC(pos, ang, model, npcId, disableShop, disableGarage)        
        end)
    else
        RCD.Query(("INSERT INTO rcd_npc (map, name, model, pos, ang, plateforms, groups_npc) VALUES (%s, %s, %s, %s, %s, %s, %s)"):format(RCD.Escape(map), RCD.Escape(name), RCD.Escape(model), RCD.Escape(pos), RCD.Escape(ang), RCD.Escape(plateforms), RCD.Escape(groups)), function(tbl)
            npcId = tonumber(tbl["lastInsertId"])

            RCD.ParamsNPC(pos, ang, model, npcId, disableShop, disableGarage)
        end)
    end
end

--[[ Create NPC entity ]]
function RCD.CreateNPCEntity(pos, ang, model, npcId, disableShop, disableGarage)
    if not isstring(model) then return end

    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc"] = RCD.Entity["npc"] or {}

    local npc = ents.Create("rcd_cardealer")
    if not IsValid(npc) then return end
    npc:SetPos(RCD.ToVectorOrAngle(pos, Vector))
    npc:SetAngles(RCD.ToVectorOrAngle(ang, Angle))
    npc:SetModel(model)
    npc:Spawn()
    npc:Activate()
    RCD.SetNPCParams(npcId, npc, disableShop, disableGarage)

    RCD.Entity["npc"][#RCD.Entity["npc"] + 1] = npc
end

--[[ Set all settings on the npc ]]
function RCD.SetNPCParams(npcId, npc, disableShop, disableGarage)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    if not IsValid(npc) then return end

    RCD.Query(("SELECT * FROM rcd_npc WHERE map = %s AND id = %s"):format(RCD.Escape(RCDMap), RCD.Escape(npcId)), function(npcTable)
        if not istable(npcTable) then return end
        npcTable = npcTable[1] or {}
    
        npcTable["plateforms"] = util.JSONToTable(npcTable["plateforms"] or "") or {}
        npcTable["groups"] = util.JSONToTable(npcTable["groups_npc"] or "") or {}

        npcTable["disableShop"] = disableShop
        npcTable["disableGarage"] = disableGarage
    
        RCD.AdvancedConfiguration["plateforms"] = RCD.AdvancedConfiguration["plateforms"] or {}
        RCD.AdvancedConfiguration["plateforms"][npcId] = RCD.AdvancedConfiguration["plateforms"][npcId] or {}
    
        RCD.AdvancedConfiguration["plateforms"][npcId] = npcTable["plateforms"]
        
        npc.SettingsTable = npcTable
        npc.NPCId = npcId

        RCD.Query(("SELECT * FROM rcd_npc_params WHERE npcId = %s"):format(RCD.Escape(npcId)), function(npcParams)
            if not IsValid(npc) then return end

            npcParams = npcParams or {}
            npcParams[1] = npcParams[1] or {}
            
            local paramsJson = npcParams[1]["params"] or ""
            local paramsTable = util.JSONToTable(paramsJson) or {}
            
            if istable(paramsTable) then
                npc.SettingsTable = npc.SettingsTable or {}

                npc.SettingsTable["disableShop"] = paramsTable["disableShop"]
                npc.SettingsTable["disableGarage"] = paramsTable["disableGarage"]
            end

            RCD.SetNWVariable("rcd_npc_name", npcTable["name"], npc, true, nil, true)
            RCD.SetNWVariable("rcd_npc_disable_shop", npc.SettingsTable["disableShop"], npc, true, nil, true)
            RCD.SetNWVariable("rcd_npc_disable_garage", npc.SettingsTable["disableGarage"], npc, true, nil, true)
        end)

        hook.Run("RCD:OnInitializeNPC", id, npc, npcTable)
    end)
end

--[[ Find an npc with his id and set settings ]]
function RCD.SetNPCParamsWithId(npcId)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    for k,v in ipairs(RCD.Entity["npc"]) do
        if not IsValid(v) or v.NPCId != npcId then continue end

        RCD.SetNPCParams(npcId, v)
        break
    end
end

--[[ Reload all entity on the server ]]
function RCD.LoadNPC()
    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc"] = RCD.Entity["npc"] or {}

    RCD.RemoveAllNPC()
    RCD.Query(("SELECT * FROM rcd_npc WHERE map = %s"):format(RCD.Escape(RCDMap)), function(npcTable)
        npcTable = npcTable or {}

        for k,v in ipairs(npcTable) do
            RCD.CreateNPCEntity(v.pos, v.ang, v.model, v.id)
        end 
    end)
end

--[[ Remove a NPC with his id on the server ]]
function RCD.RemoveNPC(npcId, deleteDb)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    if deleteDb then    
        RCD.Query(("DELETE FROM rcd_npc WHERE id = %s"):format(RCD.Escape(npcId)))
    end

    for k,v in ipairs(RCD.Entity["npc"]) do
        if not IsValid(v) or v.NPCId != npcId then continue end

        v:Remove()
    end
end

--[[ Remove all entity on the server ]]
function RCD.RemoveAllNPC()
    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc"] = RCD.Entity["npc"] or {}

    for k,v in ipairs(RCD.Entity["npc"]) do
        if not IsValid(v) then continue end

        v:Remove()
    end
end

--[[ Get position and angle of the npc ]]
function RCD.GetNPCPosAng(npcId)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    for k,v in ipairs(RCD.Entity["npc"]) do
        if not IsValid(v) or v.NPCId != npcId then continue end

        return v:GetPos(), v:GetAngles()
    end
end

--[[ Get information of the npc ]]
function RCD.GetNPCInfo(npc)
    if not IsValid(npc) then return end
    
    return (npc.SettingsTable or {})
end

--[[ Get all plateforms of the npc ]]
function RCD.GetPlateforms(npcId)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cd719b30a85fc9043c9a777151c32d569ac442f94c9f4e233f51ab9286311ad4

    RCD.AdvancedConfiguration["plateforms"] = RCD.AdvancedConfiguration["plateforms"] or {}
    RCD.AdvancedConfiguration["plateforms"][npcId] = RCD.AdvancedConfiguration["plateforms"][npcId] or {}
    
    return RCD.AdvancedConfiguration["plateforms"][npcId]
end

--[[ Find an empty place to spawn the vehicle ]]
function RCD.FindEmptyPlateforms(npc)
    if not IsValid(npc) or not isnumber(npc.NPCId) then return end
    
    local plateforms = RCD.GetPlateforms(npc.NPCId) or {}
    
    local pos, ang
    for k, v in ipairs(plateforms) do
        local entDetected = false
        
        for _, ent in ipairs(ents.FindInSphere(v.pos, 100)) do 
            if ent:IsPlayer() or RCD.IsVehicle(ent) or ent:GetClass() == "prop_physics" then
                entDetected = true
                break
            end
        end

        if not entDetected then
            pos, ang = v.pos, v.ang
        end
    end
    
    return pos, ang
end 

--[[ Set plateforms positions ]]
function RCD.SetNPCPlateforms(npcId, plateforms)
    RCD.Query(("UPDATE rcd_npc SET plateforms = %s WHERE map = %s AND id = %s"):format(RCD.Escape(util.TableToJSON(plateforms)), RCD.Escape(RCDMap), RCD.Escape(npcId)), function()
        npcId = tonumber(npcId)
        if not isnumber(npcId) then return end
    
        plateforms = istable(plateforms) and plateforms or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 38816525778563e1ebed6bf433402b83d60a8b0f4aa587d107b57a8aa40ff761
    
        RCD.AdvancedConfiguration["plateforms"] = RCD.AdvancedConfiguration["plateforms"] or {}
        RCD.AdvancedConfiguration["plateforms"][npcId] = plateforms

        RCD.SetNPCParamsWithId(npcId)
    end)
end

--[[ Add to cache vehicle group ]]
function RCD.AddCacheVehicleGroup(groupId, name, rankAccess, jobAccess, edit, noCompress, ply)
    groupId = tonumber(groupId)
    if not isnumber(groupId) then return end

    rankAccess = rankAccess or {}
    jobAccess = jobAccess or {}

    local tableToSend = {
        ["id"] = groupId,
        ["name"] = name,
        ["rankAccess"] = rankAccess,
        ["jobAccess"] = jobAccess,
    }

    RCD.AdvancedConfiguration["groupsList"] = RCD.AdvancedConfiguration["groupsList"] or {}
    RCD.AdvancedConfiguration["groupsList"][groupId] = tableToSend
    
    if IsValid(ply) then
        ply:RCDNotification(5, edit and RCD.GetSentence("vehicleGroupEdited"):format(name) or RCD.GetSentence("vehicleGroupCreated"):format(name))
        
        net.Start("RCD:Admin:Configuration")
            net.WriteUInt(2, 4)
            net.WriteUInt(groupId, 32)
            net.WriteString(name)
            net.WriteUInt(table.Count(rankAccess), 8)
            for rank, _ in pairs(rankAccess) do
                net.WriteString(rank)
            end
            net.WriteUInt(table.Count(jobAccess), 8)
            for job, _ in pairs(jobAccess) do
                net.WriteString(job)
            end
        net.Send(ply)
    end
        
    if not noCompress then
        RCD.RefreshCompressedGroups()
    end

    hook.Run("RCD:ManageVehicleGroup", edit, tableToSend)

    return tableToSend
end

-- [[ Create/Edit a vehicle group ]]
function RCD.ManageVehicleGroup(groupId, name, rankAccess, jobAccess, noCompress, ply, callback)
    if not isstring(name) then return end

    local edit = isnumber(groupId)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab58b74ce26a7341eba21cbec2eebce9b261948e3f9a4fea066565b4dc6e4b92

    if not istable(rankAccess) or table.IsEmpty(rankAccess) then rankAccess = {["*"] = true} end
    if not istable(jobAccess) or table.IsEmpty(jobAccess) then jobAccess = {["*"] = true} end

    local rank = util.TableToJSON(rankAccess)
    local job = util.TableToJSON(jobAccess)
    
    if edit then
        if not RCD.VehicleGroupExist(groupId) then return end
        
        local result = RCD.Query(("UPDATE rcd_groups SET name = %s, rankAccess = %s, jobAccess = %s WHERE id = %s"):format(RCD.Escape(name), RCD.Escape(rank), RCD.Escape(job), RCD.Escape(groupId)), callback == "wait" and "wait" or function(tbl)
            --[[ This will not be called if the query await ]]
            local cachedTable = RCD.AddCacheVehicleGroup(groupId, name, rankAccess, jobAccess, edit, noCompress, ply)

            if isfunction(callback) then
                callback(cachedTable)
            end
        end)
        
        if istable(result) then
            return true, RCD.AddCacheVehicleGroup(groupId, name, rankAccess, jobAccess, edit, noCompress, ply)
        end
    else
        local result = RCD.Query(("INSERT INTO rcd_groups (name, rankAccess, jobAccess) VALUES (%s, %s, %s)"):format(RCD.Escape(name), RCD.Escape(rank), RCD.Escape(job)), callback == "wait" and "wait" or function(tbl)
            --[[ This will not be called if the query await ]]
            groupId = tonumber(tbl["lastInsertId"])
            
            local cachedTable = RCD.AddCacheVehicleGroup(groupId, name, rankAccess, jobAccess, edit, noCompress, ply)

            if isfunction(callback) then
                callback(cachedTable)
            end
        end)    
        
        if istable(result) then
            groupId = tonumber(result["lastInsertId"])

            return true, RCD.AddCacheVehicleGroup(groupId, name, rankAccess, jobAccess, edit, noCompress, ply)
        end
    end
end

--[[ Remove a vehicle group ]]
function RCD.RemoveVehicleGroup(id, noCompress, ply)
    local groupId = tonumber(id)
    if not isnumber(groupId) then return end

    if not RCD.VehicleGroupExist(groupId) then return end

    RCD.Query(("SELECT * FROM rcd_npc WHERE map = %s"):format(RCD.Escape(RCDMap)), function(npcTable)
        npcTable = npcTable or {}
        
        RCD.Query(("DELETE FROM rcd_groups WHERE id = %s"):format(groupId))
        RCD.AdvancedConfiguration["groupsList"][groupId] = nil
        
        for k,v in ipairs(npcTable) do
            local groups = v.groups or {}
            if not groups[groupId] then continue end
    
            local groupsJson = util.TableToJSON(groups)
    
            RCD.Query(("UPDATE rcd_npc SET groups_npc = %s WHERE id = %s"):format(RCD.Escape(groupsJson), RCD.Escape(v.id)))
        end

        RCD.Entity = RCD.Entity or {}
        for k,v in pairs((RCD.Entity["npc"] or {})) do
            if not IsValid(v) then continue end
    
            RCD.SetNPCParams(v.NPCId, v)
        end
    
        net.Start("RCD:Admin:Configuration")
            net.WriteUInt(3, 4)
            net.WriteUInt(groupId, 32)
        net.Broadcast()
    
        if not noCompress then
            RCD.RefreshCompressedGroups()
        end
        
        if IsValid(ply) then
            ply:RCDNotification(5, RCD.GetSentence("vehicleGroupDeleted"):format(groupId))
        end
    
        hook.Run("RCD:RemoveVehicleGroup", groupId)
    end)
end

--[[ Get a group by his name ]]
function RCD.GetGroupByName(name)
    for k,v in pairs(RCD.AdvancedConfiguration["groupsList"]) do
        if v["name"] == name then
            return v
        end
    end
end

--[[ Add to cache the vehicle ]]
function RCD.AddCacheVehicle(vehicleId, name, price, class, model, options, groupId, vehicleId, edit, noCompress, ply)
    if not isnumber(vehicleId) then return end

    local tableToSend = {
        ["name"] = name,
        ["price"] = tonumber(price),
        ["class"] = class,
        ["model"] = model,
        ["options"] = options,
        ["groupId"] = groupId,
        ["id"] = vehicleId,
    }

    RCD.AdvancedConfiguration["vehiclesList"] = RCD.AdvancedConfiguration["vehiclesList"] or {}
    RCD.AdvancedConfiguration["vehiclesList"][vehicleId] = tableToSend

    if IsValid(ply) then
        net.Start("RCD:Admin:Configuration")
            net.WriteUInt(6, 4)
            net.WriteString(name)
            net.WriteUInt(tonumber(price), 32)
            net.WriteString(class)
            net.WriteUInt(table.Count(options), 12)
            for k,v in pairs(options) do
                local valueType = type(v)
    
                net.WriteString(valueType)
                net.WriteString(k)
                net["Write"..RCD.TypeNet[valueType]](v, ((RCD.TypeNet[valueType] == "Int") and 32))
            end
            net.WriteUInt(groupId, 32)
            net.WriteUInt(vehicleId, 32)
        net.Send(ply)
        
        ply:RCDNotification(5, editVehicle and RCD.GetSentence("vehicleEdited"):format(name) or RCD.GetSentence("vehicleCreated"):format(name))
    end

    if not noCompress then
        RCD.RefreshCompressedVehicles()
    end

    hook.Run("RCD:ManageVehicle", edit, tableToSend)

    return tableToSend
end

-- [[ Create/Edit a vehicle ]]
function RCD.ManageVehicle(vehicleId, name, price, class, options, groupId, noCompress, ply, callback)
    if RCD.VehiclesList && not RCD.VehiclesList[class] then
        if isfunction(callback) then
            callback(nil)
        end
        
        return 
    end

    if not isnumber(groupId) then groupId = 0 end

    options = istable(options) and options or {}
    options["addon"] = RCD.GetVehicleAddon(class)
    
    local optionsJson = util.TableToJSON(options)

    local edit = isnumber(vehicleId)
    if edit then        
        local result = RCD.Query(("UPDATE rcd_vehicles SET name = %s, class = %s, groupId = %s, price = %s, options = %s WHERE id = %s"):format(RCD.Escape(name), RCD.Escape(class), RCD.Escape(groupId), RCD.Escape(price), RCD.Escape(optionsJson), RCD.Escape(vehicleId)), callback == "wait" and "wait" or function(tbl)
            --[[ This will not be called if the query await ]]
            RCD.Query(("UPDATE rcd_bought_vehicles SET groupId = %s WHERE vehicleId = %s"):format(RCD.Escape(groupId), RCD.Escape(vehicleId)))
            
            local cachedTable = RCD.AddCacheVehicle(vehicleId, name, price, class, model, options, groupId, vehicleId, edit, false, ply)

            if isfunction(callback) then
                if istable(cachedTable) then callback(true, cachedTable) else callback(nil) end
            end
        end)

        if istable(result) then
            RCD.Query(("UPDATE rcd_bought_vehicles SET groupId = %s WHERE vehicleId = %s"):format(RCD.Escape(groupId), RCD.Escape(vehicleId)))
            
            return true, RCD.AddCacheVehicle(vehicleId, name, price, class, model, options, groupId, vehicleId, edit, false, ply)
        end
    else
        local result = RCD.Query(("INSERT INTO rcd_vehicles (name, class, groupId, price, options) VALUES (%s, %s, %s, %s, %s)"):format(RCD.Escape(name), RCD.Escape(class), RCD.Escape(groupId), RCD.Escape(price), RCD.Escape(optionsJson)), callback == "wait" and "wait" or function(tbl)
            --[[ This will not be called if the query await ]]
            vehicleId = tonumber(tbl["lastInsertId"])
            
            local cachedTable = RCD.AddCacheVehicle(vehicleId, name, price, class, model, options, groupId, vehicleId, edit, false, ply)  
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f5a05b5fc9224acf286189a72ca3195163b7ff6ee4c4deedbbde464a365386c6

            if isfunction(callback) then
                if istable(cachedTable) then callback(true, cachedTable) else callback(nil) end
            end
        end)

        if istable(result) then
            vehicleId = tonumber(result["lastInsertId"])
            
            return true, RCD.AddCacheVehicle(vehicleId, name, price, class, model, options, groupId, vehicleId, edit, false, ply)  
        end
    end
end

--[[ Check if this group already exist ]]
function RCD.VehicleGroupExist(id)
    RCD.AdvancedConfiguration["groupsList"] = RCD.AdvancedConfiguration["groupsList"] or {}

    return istable(RCD.AdvancedConfiguration["groupsList"][id])
end

--[[ Remove a vehicle ]]
function RCD.RemoveConfigVehicle(id, noCompress, ply)
    local vehicleId = tonumber(id)
    if not isnumber(vehicleId) then return end

    RCD.Query(("DELETE FROM rcd_vehicles WHERE id = %s"):format(vehicleId))

    RCD.AdvancedConfiguration["vehiclesList"] = RCD.AdvancedConfiguration["vehiclesList"] or {}
    RCD.AdvancedConfiguration["vehiclesList"][vehicleId] = nil

    if IsValid(ply) then
        ply:RCDNotification(5, RCD.GetSentence("vehicleDeleted"):format(vehicleId))

        net.Start("RCD:Admin:Configuration")
            net.WriteUInt(7, 4)
            net.WriteUInt(vehicleId, 32)
        net.Send(ply)
    end

    hook.Run("RCD:RemoveVehicle", vehicleId)

    if not noCompress then
        RCD.RefreshCompressedVehicles()
    end
end

--[[ Send all information and open the menu ]]
function PLAYER:RCDOpenAdminMenu()    
    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(4, 4)
    net.Send(self) 
end
