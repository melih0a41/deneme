/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")
local RCDMap = string.lower(game.GetMap())

function RCD.AddCompatibilityStatus(addonName)
    if not isstring(addonName) then return end
    
    RCD.Query(("SELECT * FROM rcd_compatibilities_done WHERE addonName = %s"):format(RCD.Escape(addonName)), function(exist)
        if istable(exist) && #exist > 0 then return end
    
        RCD.Query(("INSERT INTO rcd_compatibilities_done (addonName) VALUES (%s)"):format(RCD.Escape(addonName)), function() end)
    end)
end

function RCD.CheckCompatibilityStatus(addonName)
    if not isstring(addonName) then return end

    local exist = RCD.Query(("SELECT * FROM rcd_compatibilities_done WHERE addonName = %s"):format(RCD.Escape(addonName)))
    if istable(exist) && #exist > 0 then return true end

    return false
end

-- [[ Transfer William Car Dealer to Realistic Car Dealer ]]
function RCD.TransfertWCD(ply)
    if not WCD then
        print(RCD.GetSentence("wcdNotInstalled"):format("William Car Dealer")) 
        return false
    end
    
    if RCD.CheckCompatibilityStatus("WCD") then
        if IsValid(ply) then
            ply:RCDNotification(5, RCD.GetSentence("alreadyTransfert"))
        end
        return 
    end

    if IsValid(ply) then
        ply:RCDNotification(5, RCD.GetSentence("transfertStart"))
    end

    print("[RCD] Transferring William Car Dealer to Realistic Car Dealer...")

    local groupsDatas, groupList = (util.JSONToTable((file.Read("wcd/dealergroups.txt", "DATA") or "[]")) or {}), {}

    for k, v in ipairs(groupsDatas) do
        local success, groupTable = RCD.ManageVehicleGroup(nil, v, {["*"] = true}, {["*"] = true}, true, nil, "wait")
        if not success or not isnumber(groupTable["id"]) then continue end

        groupList[k] = groupTable["id"]
    end

    local carsDatas, carsList = file.Find("wcd/cars/*.txt", "DATA"), {}
    for k, carFile in ipairs(carsDatas) do
        local carData = util.JSONToTable((file.Read("wcd/cars/" .. carFile, "DATA") or "[]")) or {}
        
        carData.vehicleId = carFile:sub(1, #carFile - 4)
        carsList[#carsList + 1] = carData
    end

    local npcsList, count = (util.JSONToTable((file.Read(("wcd/%s/dealers.txt"):format(RCDMap), "DATA") or "[]")) or {}), 0
    for k, npcData in ipairs(npcsList) do
        local groups = {}
        if npcData.group then
            if isnumber(groupList[npcData.group]) then
                groups[groupList[npcData.group]] = true
            end
        end

        RCD.CreateNPC(nil, npcData.name, npcData.model, npcData.pos, npcData.ang, (npcData.platforms or {}), groups, RCDMap, false, false)

        count = count + 1
        
        print("[RCD] Transferring npc "..npcData.name.." ("..(count.."/"..#npcsList)..") ...")
    end

    local vehicleTransfert, count = {}, 0
    for k,v in ipairs(carsList) do
        v.vehicleId = tonumber(v.vehicleId)
        
        local optionsTable = {
            ["canChangeUngerglow"] = (!v.disallowBodygroup),
            ["canChangeBodygroup"] = (!v.disallowUnderglow),
            ["canChangeSkin"] = (!v.disallowSkin),
            ["canChangeColor"] = (!v.disallowColor),
            ["canBuyNitro"] = (!v.disallowNitro),
            ["priceUnderglow"] = (v.underglowCost or 2000),
            ["priceBodygroup"] = (v.bodygroupCost or 500),
            ["priceColor"] = (v.colorCost or 500),
            ["priceSkin"] = (v.skinCost or 500),
            ["priceNitro"] = (v.nitroOneCost or 2000),
            ["defaultColor"] = (v.color or RCD.Colors["white"]),
            ["canTestVehicle"] = true,
            ["class"] = v.class,
            ["vector"] = RCD.Constants["vectorCompatibilities"],
            ["angle"] = RCD.Constants["angleOrigin"],
            ["fov"] = 0,
            ["addon"] = RCD.GetVehicleAddon(v.class),
        }
        
        local success, vehicleTable = RCD.ManageVehicle(nil, v.name, v.price, v.class, optionsTable, groupList[v.dealer], true, nil, "wait")
        if not success then continue end
        local rcdId = tonumber(vehicleTable.id)

        vehicleTransfert[v.vehicleId] = rcdId
        count = count + 1
 
        print("[RCD] Transferring vehicles "..v.name.." ("..(count.."/"..#carsList)..") ...")
    end

    print("[RCD] Vehicle transfert done.")

    if WCD.Storage.type == "sqllite" then
        local playerData = sql.Query("SELECT * FROM playerpdata") or {}
        local vehiclesToSave = {}
                        
        for k, data in ipairs(playerData) do
            data["value"] = util.JSONToTable((data["value"] or "[]")) or {}

            local wcdVehicleId = tonumber(table.GetFirstKey(data["value"]))
            local vehicleId = vehicleTransfert[wcdVehicleId]
            if not isnumber(vehicleId) then continue end

            if string.find(data.infoid, "[wcd::owned]", 1, true) then
                local uniqueId = string.Replace(data.infoid, "[wcd::owned]", "")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

                vehiclesToSave[vehicleId] = vehiclesToSave[vehicleId] or {}

                vehiclesToSave[vehicleId]["buy"] = true
                vehiclesToSave[vehicleId]["playerId"] = uniqueId
                vehiclesToSave[vehicleId]["vehicleId"] = vehicleId
                vehiclesToSave[vehicleId]["groupId"] = groupId

            elseif string.find(data.infoid, "[wcd::specifics]", 1, true) then
                vehiclesToSave[vehicleId] = vehiclesToSave[vehicleId] or {}
                vehiclesToSave[vehicleId]["customization"] = vehiclesToSave[vehicleId]["customization"] or {}

                local vehicleCustomization = data["value"][wcdVehicleId]

                vehiclesToSave[vehicleId]["customization"]["vehicleSkin"] = vehicleCustomization["skin"] or 0
                vehiclesToSave[vehicleId]["customization"]["vehicleColor"] = vehicleCustomization["color"] or RCD.Colors["white"]
                vehiclesToSave[vehicleId]["customization"]["vehicleUnderglow"] = vehicleCustomization["underglow"]
                vehiclesToSave[vehicleId]["customization"]["vehicleBodygroups"] = vehicleCustomization["bodygroups"] or {}
                vehiclesToSave[vehicleId]["customization"]["vehicleNitro"] = vehicleCustomization["nitro"] or 0
            end
        end
        
        for k, v in pairs(vehiclesToSave) do
            if not v.buy then continue end
            
            v.customization = util.TableToJSON((v.customization or {})) or ""

            RCD.Query(("INSERT INTO rcd_bough_compatibilities (playerId, vehicleId, groupId, customization) VALUES (%s, %s, %s, %s)"):format(RCD.Escape(v.playerId), RCD.Escape(v.vehicleId), RCD.Escape(v.groupId), RCD.Escape(v.customization)), function() end)
        end

        for k,v in ipairs(player.GetAll()) do
            if not IsValid(v) then continue end
    
            v:RCDGiveVehiclesCompatibilities()
        end
    elseif WCD.Storage.type == "mysqloo9" then
        local query = WCD.__Database:query("SELECT * FROM "..WCD.Storage.table)

        function query:onSuccess(data)
            for k, v in ipairs(data) do
                local ply = player.GetBySteamID(v.steamid)

                v.owned = util.JSONToTable((v.owned or "[]")) or {}
                v.specifics = util.JSONToTable((v.specifics or "[]")) or {}

                for vehicleId, owned in pairs(v.owned) do
                    local rcdVehicleId = vehicleTransfert[tonumber(vehicleId)]
                    local customization = v.specifics[vehicleId] or {}

                    local saveCustomization = {
                        ["vehicleSkin"] = customization["skin"] or 0,
                        ["vehicleColor"] = customization["color"] or RCD.Colors["white"],
                        ["vehicleUnderglow"] = customization["underglow"],
                        ["vehicleBodygroups"] = customization["bodygroups"] or {},
                        ["vehicleNitro"] = customization["nitro"] or 0,
                    }
                    
                    RCD.GiveVehicle((ply or util.SteamIDTo64(v.steamid)), rcdVehicleId, saveCustomization)
                end
            end
        end

        query:start()
    end

    print("[RCD] Transfert vehicles and customizations done.")
    print("[RCD] Transferring William Car Dealer to Realistic Car Dealer done.")

    RCD.RefreshCompressedVehicles()
    RCD.RefreshCompressedGroups()
    RCD.AddCompatibilityStatus("WCD")
end

function RCD.TransfertVCMOD(ply)
    print("[RCD] Transferring VCMOD Car Dealer to Realistic Car Dealer...")
    if RCD.CheckCompatibilityStatus("VCMOD") then
        if IsValid(ply) then
            ply:RCDNotification(5, RCD.GetSentence("alreadyTransfert"))
        end
        return 
    end

    if IsValid(ply) then
        ply:RCDNotification(5, RCD.GetSentence("transfertStart"))
    end

    local files, folder = file.Find(("vcmod/cardealer/maps/%s/*"):format(RCDMap), "DATA")
    local vehicleTransfert = {}

    for fileId, fileTxt in pairs((files or {})) do
        local npcTable = util.JSONToTable((file.Read(("vcmod/cardealer/maps/%s/%s"):format(RCDMap, fileTxt), "DATA") or "[]")) or {}
        
        local rankGroup = {}
        for rankName, v in pairs((npcTable["RankRestrict"] or {})) do
            rankGroup[rankName] = (!v)
        end

        local jobGroup = {}
        for jobName, v in pairs((npcTable["JobRestrict"] or {})) do
            jobGroup[jobName] = (!v)
        end
        
        local success, groupTable = RCD.ManageVehicleGroup(nil, npcTable["Name"], rankGroup, jobGroup, true, nil, "wait")
        if not success then continue end
        groupId = tonumber(groupTable["id"])

        local plateforms = {}
        for k, v in pairs((npcTable["Platforms"] or {})) do
            if not isvector(v.Pos) && not isangle(v.Ang) then continue end

            plateforms[#plateforms + 1] = {
                ["pos"] = v.Pos,
                ["ang"] = v.Ang,
            }
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

        print("[RCD] Transferring npc "..npcTable["Name"].." ...")

        RCD.CreateNPC(nil, npcTable["Name"], npcTable["Model"], npcTable["Pos"], npcTable["Ang"], plateforms, {[groupId] = true}, RCDMap, false, false)

        for k,v in pairs(npcTable["Vehicles"]) do
            local optionsTable = {
                ["canChangeUngerglow"] = true,
                ["canChangeBodygroup"] = true,
                ["canChangeSkin"] = true,
                ["canChangeColor"] = true,
                ["priceUnderglow"] = 2000,
                ["priceBodygroup"] = 500,
                ["priceColor"] = 500,
                ["priceSkin"] = 500,
                ["priceNitro"] = 2000,
                ["defaultColor"] = RCD.Colors["white"],
                ["canTestVehicle"] = true,
                ["class"] = v.Class,
                ["vector"] = RCD.Constants["vectorCompatibilities"],
                ["angle"] = RCD.Constants["angleOrigin"],
                ["fov"] = 0,
                ["addon"] = RCD.GetVehicleAddon(v.Class),
            }

            print("[RCD] Transferring vehicles "..v.Name.." ...")
            
            local success, vehicleTable = RCD.ManageVehicle(nil, v.Name, v.Price, v.Entity, optionsTable, groupId, true, nil, "wait")
            if not success then continue end
            local rcdId = tonumber(vehicleTable.id)
            
            vehicleTransfert[k] = {
                ["vehicleId"] = rcdId,
                ["groupId"] = tonumber(groupId),
            }
        end
    end

    print("[RCD] Vehicle transfert done.")

    local files, folder = file.Find("vcmod/cardealer/plydata/*", "DATA")

    for fileId, fileTxt in pairs((files or {})) do
        local playerTable = util.JSONToTable((file.Read(("vcmod/cardealer/plydata/%s"):format(fileTxt), "DATA") or "[]")) or {}
        local vehiclesList = playerTable["Vehicles"] or {}

        for vehicleId, customization in pairs(vehiclesList) do
            local rcdVehicleTable = vehicleTransfert[vehicleId]
            if not istable(rcdVehicleTable) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

            local rcdVehicleId = rcdVehicleTable["vehicleId"]
            local rcdGroupId = rcdVehicleTable["groupId"]

            local plyUniqueId = string.Replace(fileTxt, ".txt", "")

            local saveCustomization = {
                ["vehicleSkin"] = customization["Skin"] or 0,
                ["vehicleColor"] = customization["Color"] or RCD.Colors["white"],
                ["vehicleBodygroups"] = customization["BGroups"] or {},
            }

            saveCustomization = util.TableToJSON((saveCustomization or {})) 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

            RCD.Query(("INSERT INTO rcd_bough_compatibilities (playerId, vehicleId, groupId, customization) VALUES (%s, %s, %s, %s)"):format(RCD.Escape(plyUniqueId), RCD.Escape(rcdVehicleId), RCD.Escape(rcdGroupId), RCD.Escape(saveCustomization)), function() end)
        end
    end

    for k,v in ipairs(player.GetAll()) do
        if not IsValid(v) then continue end

        v:RCDGiveVehiclesCompatibilities()
    end

    print("[RCD] Transfert vehicles and customizations done.")
    print("[RCD] Transferring VCMOD Car Dealer to Realistic Car Dealer done.")

    RCD.RefreshCompressedVehicles()
    RCD.RefreshCompressedGroups()
    RCD.AddCompatibilityStatus("VCMOD")
end

function PLAYER:RCDGiveVehiclesCompatibilities()
    local uniqueId = self:UniqueID()
    RCD.Query(("SELECT * FROM rcd_bough_compatibilities WHERE playerId = %s"):format(RCD.Escape(uniqueId)), function(vehiclesTable)
        if not istable(vehiclesTable) or #vehiclesTable == 0 then return end
    
        for k,v in ipairs(vehiclesTable) do
            v.vehicleId = tonumber(v.vehicleId)
            v.customization = util.JSONToTable((v.customization or "[]")) or {}
    
            RCD.GiveVehicle(self, v.vehicleId, v.customization)
            
            RCD.Query(("DELETE FROM rcd_bough_compatibilities WHERE playerId = %s AND vehicleId = %s"):format(RCD.Escape(uniqueId), RCD.Escape(v.vehicleId)), function() end)
        end
    end)
end

function RCD.TransfertAdvancedCarDealer(ply)
    if not AdvCarDealer then
        print(RCD.GetSentence("addonNotInstalled"):format("Advanced Car Dealer")) 
        return false
    end

    print("[RCD] Transferring Advanced Car Dealer to Realistic Car Dealer...")
    if RCD.CheckCompatibilityStatus("ADVANCED") then
        if IsValid(ply) then
            ply:RCDNotification(5, RCD.GetSentence("alreadyTransfert"))
        end
        return
    end

    if IsValid(ply) then
        ply:RCDNotification(5, RCD.GetSentence("transfertStart"))
    end

    local success, groupTable = RCD.ManageVehicleGroup(nil, "Advanced Car Dealer", {["*"] = true}, {["*"] = true}, true, nil, "wait")
    if not success then return end
    groupId = tonumber(groupTable["id"])

    local configDatas = (util.JSONToTable((file.Read("adv_cardealer/configuration.txt", "DATA") or "[]")) or {})
    local vehicleTransfert = {}

    for k,v in pairs(configDatas["Vehicles"]) do
        for brandKey, vehicles in pairs(v) do
            local optionsTable = {
                ["canChangeUngerglow"] = vehicles.underglow,
                ["canChangeBodygroup"] = vehicles.bodygroups,
                ["canChangeSkin"] = vehicles.skins,
                ["canChangeColor"] = vehicles.color,
                ["priceUnderglow"] = 2000,
                ["priceBodygroup"] = 500,
                ["priceColor"] = 500,
                ["priceSkin"] = 500,
                ["priceNitro"] = 2000,
                ["defaultColor"] = RCD.Colors["white"],
                ["canTestVehicle"] = true,
                ["class"] = vehicles.Class,
                ["vector"] = RCD.Constants["vectorCompatibilities"],
                ["angle"] = RCD.Constants["angleOrigin"],
                ["fov"] = 0,
                ["addon"] = RCD.GetVehicleAddon(vehicles.Class),
            }
            
            local success, vehicleTable = RCD.ManageVehicle(nil, vehicles.name, (vehicles.priceCatalog or 1000), vehicles.className, optionsTable, groupId, true, nil, "wait")
            if not success then continue end
            local rcdId = tonumber(vehicleTable.id)

            print("[RCD] Transferring vehicles "..vehicles.name.." ...")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132
            
            vehicleTransfert[vehicles.className] = rcdId
        end
    end

    MySQLite.query("SELECT * FROM adv_cardealer_vehicles", function(data)        
        for k,v in ipairs(data) do
            local vehicleId = vehicleTransfert[v.vehicle]
            if not isnumber(vehicleId) then continue end

            local color = string.Explode(" ", (v.color or "")) or {}
            local underglow = (v.color == "" and {} or string.Explode(" ", (v.color or "")))

            color = Color(color[1] or 255, color[2] or 255, color[3] or 255, color[4] or 255)

            local underglow = (v.underglow == "" and {} or string.Explode(" ", (v.underglow or "")))
            underglow = Color(underglow[1] or 255, underglow[2] or 255, underglow[3] or 255, underglow[4] or 255)
            
            local customization = {
                ["vehicleSkin"] = v.skin or 0,
                ["vehicleColor"] = color,
                ["vehicleUnderglow"] = underglow,
            }
            
            local ply = player.GetBySteamID64(v.steamID)
            RCD.GiveVehicle((ply or util.SteamIDTo64(v.steamID)), vehicleId, customization)
        end
    end)

    print("[RCD] Transfert vehicles and customizations done.")
    print("[RCD] Transferring Advanced Car Dealer to Realistic Car Dealer done.")
    
    RCD.RefreshCompressedVehicles()
    RCD.RefreshCompressedGroups()
    RCD.AddCompatibilityStatus("ADVANCED")
end

function RCD.TransfertModernCarDealer(ply)
    print("[RCD] Transferring Modern Car Dealer to Realistic Car Dealer...")
    if RCD.CheckCompatibilityStatus("MODERN") then
        if IsValid(ply) then
            ply:RCDNotification(5, RCD.GetSentence("alreadyTransfert"))
        end
        return 
    end

    if IsValid(ply) then
        ply:RCDNotification(5, RCD.GetSentence("transfertStart"))
    end

    local groupsDatas = (util.JSONToTable((file.Read("moderncardealer/mcd_cardealers.json", "DATA") or "[]")) or {})
    local groupTransfert = {}
    local transfertVehicles = {}

    for groupName, vehiclesTable in pairs(groupsDatas) do
        local success, groupTable = RCD.ManageVehicleGroup(nil, groupName, {["*"] = true}, {["*"] = true}, true, nil, "wait")
        if not success then continue end

        groupId = tonumber(groupTable["id"])
        if not isnumber(groupId) then continue end

        groupTransfert[groupName] = groupId
        
        for k, v in pairs(vehiclesTable) do
            local optionsTable = {
                ["canChangeUngerglow"] = true,
                ["canChangeBodygroup"] = true,
                ["canChangeSkin"] = true,
                ["canChangeColor"] = true,
                ["priceUnderglow"] = 2000,
                ["priceBodygroup"] = 500,
                ["priceColor"] = 500,
                ["priceSkin"] = 500,
                ["priceNitro"] = 2000,
                ["defaultColor"] = RCD.Colors["white"],
                ["canTestVehicle"] = true,
                ["class"] = v.Class,
                ["vector"] = RCD.Constants["vectorCompatibilities"],
                ["angle"] = RCD.Constants["angleOrigin"],
                ["fov"] = 0,
                ["addon"] = RCD.GetVehicleAddon(v.Class),
            }

            local success, vehicleTable = RCD.ManageVehicle(nil, v.Name, (v.Price or 1000), v.Class, optionsTable, groupId, true, nil, "wait")
            if not success then continue end

            transfertVehicles[v.Class..groupName] = vehicleTable.id

            print("[RCD] Transferring vehicles "..v.Name.." ...")
        end
    end

    print("[RCD] Vehicle transfert done.")

    local npcDatas = util.JSONToTable((file.Read("moderncardealer/maps/"..RCDMap..".json", "DATA") or "[]")) or {}
    for k,v in pairs((npcDatas["Dealers"] or {})) do
        local groupId = groupTransfert[v.Dealer]
        if not isnumber(groupId) then continue end

        RCD.CreateNPC(nil, k, v.Model, v.Position, v.Angles, {}, {[groupId] = true}, RCDMap, false, false)

        print("[RCD] Transferring npc "..k.." ...")
    end

    print("[RCD] NPC transfert done.")
    
    local playerData, carsList = file.Find("moderncardealer/playerdata/*.json", "DATA"), {}
    for k, playerFile in ipairs(playerData) do
        local carDatas = util.JSONToTable((file.Read("moderncardealer/playerdata/"..playerFile, "DATA") or "[]")) or {}

        for k, v in pairs(carDatas) do
            local steamID64 = string.Replace(playerFile, ".json", "")

            local vehicleId = transfertVehicles[v.Class..v.Dealer]
            if not isnumber(vehicleId) then continue end

            local customization = {
                ["vehicleSkin"] = v.Skin,
                ["vehicleColor"] = v.Color,
                ["vehicleUnderglow"] = v.Underglow,
            }
            
            local ply = player.GetBySteamID64(steamID64)
            RCD.GiveVehicle((ply or util.SteamIDTo64(steamID64)), vehicleId, customization)
        end
    end

    print("[RCD] Transfert vehicles and customizations done.")
    print("[RCD] Transferring Modern Car Dealer to Realistic Car Dealer done.")

    RCD.RefreshCompressedVehicles()
    RCD.RefreshCompressedGroups()
    RCD.AddCompatibilityStatus("MODERN")
end

concommand.Add("rcd_transfert_wcd", function(ply, cmd, args)
    if ply == NULL && not RCD.AdminRank[ply:GetUserGroup()] then return end

    RCD.TransfertWCD(ply)
end)

concommand.Add("rcd_transfert_vcmod", function(ply, cmd, args)
    if ply == NULL && not RCD.AdminRank[ply:GetUserGroup()] then return end

    RCD.TransfertVCMOD(ply)
end)

concommand.Add("rcd_transfert_modern", function(ply, cmd, args)
    if ply == NULL && not RCD.AdminRank[ply:GetUserGroup()] then return end

    RCD.TransfertModernCarDealer(ply)
end)

concommand.Add("rcd_transfert_advanced", function(ply, cmd, args)
    if ply == NULL && not RCD.AdminRank[ply:GetUserGroup()] then return end

    RCD.TransfertAdvancedCarDealer(ply)
end)

hook.Add("PlayerInitialSpawn", "RCD:Compatibility:WCD", function(ply)
    timer.Simple(5, function()
        if not IsValid(ply) then return end
    
        ply:RCDGiveVehiclesCompatibilities()
    end)
end)

hook.Add("VC_canSwitchSeat", "RCD:Compatibilities:VC_canSwitchSeat", function(ply, ent_from, ent_to)
    local securityBelt = RCD.GetNWVariables("RCDSecurityBelt", ply)
    
    if securityBelt == true then 
        ply:RCDNotification(5, RCD.GetSentence("cantSwitch"))

        return false
    end
end)

hook.Add("CanPlayerAccessDoor", "RCD:Compatibilities:NutscriptDoor", function(ply, vehc)
	if vehc.RCDOwner then
		return veh.RCDOwner == ply
	end
end)

hook.Add("playerSellVehicle", "RCD:Compatibilities:playerSellVehicle", function(ply, vehc)
    if not IsValid(vehc.RCDOwner) then return end

    return false
end)
