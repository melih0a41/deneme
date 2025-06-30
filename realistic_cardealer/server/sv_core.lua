/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")

-- [[ Mysql database connection system ]] --
local mysqlDB
RCD.MysqlConnected = false

if RCD.Mysql then
    local succ, err = pcall(function() require("mysqloo") end)
    if not succ then return print("[RCD] Error with MYSQLOO") end
    
    if not mysqloo then
        return print("[RCD] Cannot require mysqloo module :\n"..requireError)
    end

    mysqlDB = mysqloo.connect(RCD.MysqlInformations["host"], RCD.MysqlInformations["username"], RCD.MysqlInformations["password"], RCD.MysqlInformations["database"], RCD.MysqlInformations["port"])
    function mysqlDB:onConnected()  
        print("[RCD] Succesfuly connected to the mysql database !")
        RCD.MysqlConnected = true
    end
    
    function mysqlDB:onConnectionFailed(connectionError)
        print("[RCD] Cannot etablish database connection :\n"..connectionError)
    end
    mysqlDB:connect()
end

--[[ SQL Query function ]] --
function RCD.Query(query, callback)
    if not isstring(query) then return end

    local result = {}
    local isInsertQuery = string.StartWith(query, "INSERT")
    if RCD.Mysql then
        query = mysqlDB:query(query)

        if callback == "wait" then
            query:start()
            query:wait()

            local err = query:error()
            if err == "" then        
                return isInsertQuery and { lastInsertId = query:lastInsert() } or query:getData()
            else
                print("[RCD] "..err)
            end
        else
            function query:onError(err, sql)
                print("[RCD] "..err)
            end

            function query:onSuccess(tbl, data)
                if isfunction(callback) then
                    callback(isInsertQuery and { lastInsertId = query:lastInsert() } or tbl)
                end
            end
            query:start()
        end
    else
        result = sql.Query(query)
        result = isInsertQuery and { lastInsertId = sql.Query("SELECT last_insert_rowid()")[1]["last_insert_rowid()"] } or result

        if callback == "wait" then
            return result
            
        elseif isfunction(callback) then
            callback(result)

            return
        end
    end

    return (result or {})
end

-- [[ Escape the string ]] --  
function RCD.Escape(str)
    return RCD.MysqlConnected and ("'%s'"):format(mysqlDB:escape(tostring(str))) or SQLStr(str)    
end

--[[ Convert a string to a vector or an angle ]]
function RCD.ToVectorOrAngle(toConvert, typeToSet)
    if not isstring(toConvert) or (typeToSet != Vector and typeToSet != Angle) then return end

    local convertArgs = string.Explode(" ", toConvert)
    local x, y, z = (tonumber(convertArgs[1]) or 0), (tonumber(convertArgs[2]) or 0), (tonumber(convertArgs[3]) or 0)
    
    return typeToSet == Vector and Vector(x, y, z) or Angle(x, y, z)
end

-- [[ Function to add a compatibility with autoincrement ]]
function RCD.AutoIncrement()
    return (RCD.Mysql and "AUTO_INCREMENT" or "AUTOINCREMENT")
end 

--[[ Initialize all mysql/sql table ]]
function RCD.InitializeTables()
    local autoIncrement = RCD.AutoIncrement()
    RCD.Query(([[
        CREATE TABLE IF NOT EXISTS rcd_groups (
            id INTEGER NOT NULL PRIMARY KEY %s, 
            name VARCHAR(100), 
            rankAccess LONGTEXT, 
            jobAccess LONGTEXT
        );

        CREATE TABLE IF NOT EXISTS rcd_vehicles(
            id INTEGER NOT NULL PRIMARY KEY %s,
            name VARCHAR(100),
            class VARCHAR(100),
            groupId INT,
            price INT,
            options LONGTEXT
        );

        CREATE TABLE IF NOT EXISTS rcd_resellernpc(
            id INTEGER NOT NULL PRIMARY KEY %s,
            name VARCHAR(100),
            map VARCHAR(100),
            model VARCHAR(100),
            pos VARCHAR(150),
            ang VARCHAR(150)
        );

        CREATE TABLE IF NOT EXISTS rcd_bought_vehicles(
            id INTEGER NOT NULL PRIMARY KEY %s,
            playerId VARCHAR(100),
            vehicleId INT,
            groupId INT,
            customization LONGTEXT,
            discount INT DEFAULT 0,
            compatibilitiesOptions LONGTEXT,
            FOREIGN KEY(vehicleId) REFERENCES rcd_vehicles(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS rcd_settings(
            id INTEGER NOT NULL PRIMARY KEY %s,
            keyName VARCHAR(100),
            value LONGTEXT
        );

        CREATE TABLE IF NOT EXISTS rcd_bough_compatibilities(
            id INTEGER NOT NULL PRIMARY KEY %s,
            playerId VARCHAR(100),
            vehicleId INT,
            groupId INT, customization LONGTEXT,
            FOREIGN KEY(vehicleId) REFERENCES rcd_vehicles(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS rcd_compatibilities_done(
            id INTEGER NOT NULL PRIMARY KEY %s,
            addonName VARCHAR(100)
        );

        CREATE TABLE IF NOT EXISTS rcd_npc(
            id INTEGER NOT NULL PRIMARY KEY %s,
            map VARCHAR(100),
            name VARCHAR(100),
            model VARCHAR(100),
            pos VARCHAR(150),
            ang VARCHAR(150),
            plateforms LONGTEXT,
            groups_npc LONGTEXT
        );

        CREATE TABLE IF NOT EXISTS rcd_npc_params(
            npcId INTEGER NOT NULL,
            params LONGTEXT,
            FOREIGN KEY(npcId) REFERENCES rcd_npc(id) ON DELETE CASCADE
        );
    ]]):format(autoIncrement, autoIncrement, autoIncrement, autoIncrement, autoIncrement, autoIncrement, autoIncrement, autoIncrement))
    
    if RCD.Mysql then
        RCD.Query(("SELECT * FROM information_schema.columns WHERE table_name = 'rcd_npc' AND column_name = 'groups'"), function(check)
            if not check or #check == 0 then return end
            
            RCD.Query([[ ALTER TABLE rcd_npc RENAME COLUMN groups TO groups_npc ]])
        end)
    else
        RCD.Query([[ ALTER TABLE rcd_npc RENAME COLUMN groups TO groups_npc ]])
    end
end

--[[ Intialize settings of the addon ]]
function RCD.InitializeSettings()
    for k,v in pairs(RCD.DefaultSettings) do
        RCD.Query(("SELECT * FROM rcd_settings WHERE keyName = %s"):format(RCD.Escape(k)), function(settings)
            if not settings or #settings == 0 then
                RCD.Query(("INSERT INTO rcd_settings (keyName, value) VALUES (%s, %s)"):format(RCD.Escape(k), RCD.Escape(v)))
            end
        end)
    end
    
    timer.Simple(3, function()
        RCD.Query("SELECT * FROM rcd_settings", function(settings)
            for k,v in pairs(settings) do
                if v.value == "true" or v.value == "false" then
                    v.value = tobool(v.value)
                elseif isnumber(tonumber(v.value)) then
                    v.value = tonumber(v.value)
                elseif string.StartWith(v.value, "{") then
                    v.value = util.JSONToTable(v.value)
                end
                
                RCD.DefaultSettings[v.keyName] = v.value
            end
        end)
    end)
end

--[[ Set Settings on the table ]]
function RCD.SetSettings(settings)
    if not istable(settings) then return end

    for k,v in pairs(settings) do
        if RCD.DefaultSettings[k] == nil or RCD.DefaultSettings[k] != v then
            local valueToSave = v
            if istable(valueToSave) then
                valueToSave = util.TableToJSON(valueToSave)
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9
            
            RCD.Query(("UPDATE rcd_settings SET value = %s WHERE keyName = %s"):format(RCD.Escape(valueToSave), RCD.Escape(k)))
        end
        
        RCD.DefaultSettings[k] = v
    end

    RCD.SendSettings()
end

--[[ Send all settings to the player on the client ]]
function RCD.SendSettings(ply)
    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(10, 4)
        net.WriteUInt(table.Count(RCD.DefaultSettings), 12)
        for k,v in pairs(RCD.DefaultSettings) do
            local valueType = type(v)

            net.WriteString(valueType)
            net.WriteString(k)
            net["Write"..RCD.TypeNet[valueType]](v, ((RCD.TypeNet[valueType] == "Int") and 32))
        end
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function RCD.SetVariablesWithoutEntities(key, value, ply, sync)
    RCD.NWVariables = RCD.NWVariables or {}
    RCD.NWVariables["variablesWithoutEntities"] = RCD.NWVariables["variablesWithoutEntities"] or {}

    RCD.NWVariables["variablesWithoutEntities"][key] = value

    if sync then
        RCD.SyncVariablesWithoutEntities(ply, key)
    end
end

function RCD.SyncVariablesWithoutEntities(ply, key)
    RCD.NWVariables = RCD.NWVariables or {}
    RCD.NWVariables["variablesWithoutEntities"] = RCD.NWVariables["variablesWithoutEntities"] or {}

    net.Start("RCD:Main:Client")
    net.WriteUInt(15, 4)
        local tableToLoop = isstring(key) and {RCD.NWVariables["variablesWithoutEntities"][key]} or RCD.NWVariables["variablesWithoutEntities"]

        net.WriteUInt(table.Count(tableToLoop), 15)
        for k, v in pairs(tableToLoop) do
            local valueType = type(v)

            net.WriteString(k)
            net.WriteString(valueType)
            net["Write"..RCD.TypeNet[valueType]](v, ((RCD.TypeNet[valueType] == "Int") and 32))
        end

    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

--[[ This function permit to create variables on whatever you want networked with all players ]]
function RCD.SetNWVariable(key, value, ent, send, ply, sync)
    if not IsValid(ent) or not isstring(key) then return end

    RCD.NWVariables = RCD.NWVariables or {}

    ent.RCDNWVariables = ent.RCDNWVariables or {}
    ent.RCDNWVariables[key] = value
    
    if sync then
        RCD.NWVariables["networkEnt"] = RCD.NWVariables["networkEnt"] or {}
        RCD.NWVariables["networkEnt"][ent] = ent.RCDNWVariables

        ent:CallOnRemove("rcd_reset_variables:"..ent:EntIndex(), function(ent) RCD.NWVariables["networkEnt"][ent] = nil end) 
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

    if send then
        RCD.SyncNWVariable(key, ent, ply)
    end
end

--[[ Sync variable to the clientside or to everyone ]]
function RCD.SyncNWVariable(key, ent, ply)
    if not IsValid(ent) or not isstring(key) then return end

    ent.RCDNWVariables = ent.RCDNWVariables or {}
    
    local value = ent.RCDNWVariables[key]
    if value == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

    local valueType = type(value)

    net.Start("RCD:Main:Client")
        net.WriteUInt(1, 4)
        net.WriteUInt(1, 12)
        net.WriteUInt(ent:EntIndex(), 32)
        net.WriteUInt(1, 4)
        net.WriteString(valueType)
        net.WriteString(key)
        net["Write"..RCD.TypeNet[valueType]](value, ((RCD.TypeNet[valueType] == "Int") and 32))
    if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

--[[ Sync all variables needed client side ]]
function PLAYER:RCDSyncAllVariables()
    RCD.NWVariables = RCD.NWVariables or {}
    RCD.NWVariables["networkEnt"] = RCD.NWVariables["networkEnt"] or {}
    
    net.Start("RCD:Main:Client")
        net.WriteUInt(1, 4)
        
        local keys = table.GetKeys(RCD.NWVariables["networkEnt"])
        net.WriteUInt(#keys, 12)
        for _, ent in ipairs(keys) do

            net.WriteUInt(ent:EntIndex(), 32)
            local variableKeys = table.GetKeys(RCD.NWVariables["networkEnt"][ent])
            net.WriteUInt(#variableKeys, 4)
            for _, varName in ipairs(variableKeys) do
    
                local value = RCD.NWVariables["networkEnt"][ent][varName]
                local valueType = type(value)

                net.WriteString(valueType)
                net.WriteString(varName)
                net["Write"..RCD.TypeNet[valueType]](value, ((RCD.TypeNet[valueType] == "Int") and 32))
            end
        end
    net.Send(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

--[[ Send a notification to the player ]]
function PLAYER:RCDNotification(time, text)
    local curtime = CurTime()

    self.RCD[text] = self.RCD[text] or 0
    if self.RCD[text] > curtime then return end
    self.RCD[text] = curtime + 0.5

    net.Start("RCD:Notification")
        net.WriteUInt(time, 3)
        net.WriteString(text)
    net.Send(self)
end

--[[ This function permite to add compatibility with other gamemode ]]
function PLAYER:RCDAddMoney(price)
    if DarkRP then
        self:addMoney(price)
    elseif ix then
        if self:GetCharacter() != nil then
            local money = self:RCDGetMoney()
            self:GetCharacter():SetMoney(money + price)
        end
    elseif nut then
        if self:getChar() != nil then
            local money = self:RCDGetMoney()
            self:getChar():setMoney(money + price)
        end
    end
end

--[[ Compress vehicles table ]]
function RCD.RefreshCompressedVehicles()
    local vehiclesTable = RCD.GetVehicles() or {}
    RCD.CompressedVehiclesTable = util.Compress(util.TableToJSON(vehiclesTable))

    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(5, 4)
        net.WriteUInt(#RCD.CompressedVehiclesTable, 32)
        net.WriteData(RCD.CompressedVehiclesTable, #RCD.CompressedVehiclesTable)
    net.Broadcast()
end

--[[ Compress groups table ]]
function RCD.RefreshCompressedGroups()
    local groupsTable = RCD.GetAllVehicleGroups() or {}
    RCD.CompressedGroupsTable = util.Compress(util.TableToJSON(groupsTable))

    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(1, 4)
        net.WriteUInt(#RCD.CompressedGroupsTable, 32)
        net.WriteData(RCD.CompressedGroupsTable, #RCD.CompressedGroupsTable)
    net.Broadcast()
end

--[[ Send all vehicle to the player ]]
function PLAYER:RCDSendAllVehicles()
    if RCD.CompressedVehiclesTable == nil then
        RCD.RefreshCompressedVehicles()
        return
    end

    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(5, 4)
        net.WriteUInt(#RCD.CompressedVehiclesTable, 32)
        net.WriteData(RCD.CompressedVehiclesTable, #RCD.CompressedVehiclesTable)
    net.Send(self)
end

--[[ Send all vehicle groups to the player ]]
function PLAYER:RCDSendAllGroups()
    if RCD.CompressedGroupsTable == nil then
        RCD.RefreshCompressedGroups()
        return
    end

    net.Start("RCD:Admin:Configuration")
        net.WriteUInt(1, 4)
        net.WriteUInt(#RCD.CompressedGroupsTable, 32)
        net.WriteData(RCD.CompressedGroupsTable, #RCD.CompressedGroupsTable)
    net.Send(self)
end

--[[ Set key owner ]]
function PLAYER:RCDSetkeysOwn(vehc)
    if not IsValid(vehc) then return end

    if DarkRP && isfunction(vehc.keysOwn) then
        vehc:keysOwn(self)
    end

    if isfunction(vehc.CPPISetOwner) then
        vehc:CPPISetOwner(self)
    end

    if vehc.IsSimfphyscar then
        simfphys.SetOwner(self, vehc)
    end
end

--[[ Lock vehicle ]]
function RCD.LockVehicle(vehc)
    if not IsValid(vehc) then return end

    if DarkRP && vehc.keysLock && isfunction(vehc.keysLock) then
        pcall(function() vehc:keysLock() end)
    end

    if vehc.Lock && isfunction(vehc.Lock) then
        vehc:Lock()
    elseif vehc.Fire && isfunction(vehc.Fire) then
        vehc:Fire("Lock")
    end
end

--[[ Unlock vehicle ]]
function RCD.UnLockVehicle(vehc)
    if not IsValid(vehc) then return end
       
    if DarkRP && isfunction(vehc.keysLock) then
        vehc:keysUnLock()
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

    if isfunction(vehc.Lock) then
        vehc:UnLock()
    else
        vehc:Fire("Unlock")
    end
end
