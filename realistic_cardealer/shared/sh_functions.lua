/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.9 (stable)
*/

--[[ Make sure sentence exist and also langage exist]]
function RCD.GetSentence(key)
    local result = "Lang Problem"
    local lang = RCD.GetSetting("lang", "string")

    if istable(RCD.Language) && RCD.Language[lang] && RCD.Language[lang][key] then
        result = RCD.Language[lang][key]
    elseif istable(RCD.Language) && RCD.Language["en"] && RCD.Language["en"][key] then
        result = RCD.Language["en"][key]
    end

    return result
end

--[[ Convert a number to a format number ]]
function RCD.formatMoney(moneyValue)
    moneyValue = tonumber(moneyValue)
    if not isnumber(moneyValue) then return 0 end

    local money = string.Comma(math.Round(moneyValue))
    return isfunction(RCD.Currencies[RCD.GetSetting("currency", "string")]) and RCD.Currencies[RCD.GetSetting("currency", "string")](money) or money
end

--[[ Get the vehicle spawn function ]]
function RCD.GetVehicleAddon(class)
    for k,v in pairs(list.Get("simfphys_vehicles") or {}) do
        if k != class then continue end

        return "simfphys"
    end

    return "default"
end

--[[ Get all vehicle groups ]]
function RCD.GetAllVehicleGroups()
    return (RCD.AdvancedConfiguration["groupsList"] or {})
end

function RCD.GetVariablesWithoutEntities(key)
    RCD.NWVariables = RCD.NWVariables or {}
    RCD.NWVariables["variablesWithoutEntities"] = RCD.NWVariables["variablesWithoutEntities"] or {}

    return RCD.NWVariables["variablesWithoutEntities"][key] or ""
end

-- [[ Get all vehicles list ]]
function RCD.GetAllVehicles()
    local vehicles = {}

    for k, v in ipairs(RCD.VehiclesListNames) do
        local tableToStore = {}
        
        if isfunction(RCD.VehiclesListFunction[v]) then
            tableToStore = RCD.VehiclesListFunction[v](list.Get(v)) or {}
        else
            tableToStore = list.Get(v)
        end

        table.Merge(vehicles, tableToStore)
    end
    
    for k, v in pairs(list.Get("SWVehicles")) do
        if not isstring(v["EntModel"]) or not isstring(v["ClassName"]) or not isstring(v["PrintName"]) then continue end
        
        vehicles[v["ClassName"]] = {
            ["Model"] = v["EntModel"],
            ["Class"] = v["ClassName"],
            ["Name"] = v["PrintName"],
        }
    end

    if Glide && istable(Glide) then
        for class, _ in pairs(scripted_ents.GetList()) do

            if scripted_ents.IsBasedOn(class, "base_glide") then
                local vehicleTable = scripted_ents.Get(class)
                if not istable(vehicleTable) then continue end

                local model = vehicleTable["ChassisModel"]
                if not isstring(model) then continue end

                vehicles[class] = {
                    ["Model"] = model,
                    ["Class"] = class,
                    ["Name"] = class,
                }
            end
        end
    end

    for k, v in pairs(scripted_ents.GetList()) do
        local tableTest = v["t"]

        local model
        if isstring(tableTest["MDL"]) then
            model = tableTest["MDL"]
        elseif isstring(tableTest["Model"]) then
            model = tableTest["Model"]
        end
        if not isstring(model) then continue end
        
        local class
        if isstring(tableTest["ClassName"]) then
            class = tableTest["ClassName"]
        elseif isstring(tableTest["Class"]) then
            class = tableTest["Class"]
        end

        if not isstring(class) then continue end
        
        vehicles[class] = {
            ["Model"] = model,
            ["Class"] = class,
            ["Name"] = class,
        }
    end

    return vehicles
end

--[[ Get all vehicles ]]
function RCD.GetVehicles()
    return RCD.AdvancedConfiguration["vehiclesList"] or {}
end

function RCD.GetVehicleParams(vehicleId, key)
    local vehicleTable = RCD.GetVehicles()[vehicleId]
    if not istable(vehicleTable) then return end

    local options = vehicleTable["options"] or {}

    return (options[key] or false)
end

--[[ Get networked variables ]]
function RCD.GetNWVariables(key, ent)
    return (IsValid(ent) and (ent.RCDNWVariables or {}) or (RCD.NWVariables or {}))[key]
end

--[[ Get the vehicle speed with the unit conversion ]]
function RCD.GetSpeedVehicle(ent, unitName)
    if not IsValid(ent) then return end

    local vehc = RCD.GetVehicle(ent)
    
    local speed = 0
    if IsValid(vehc) then
        speed = vehc:GetVelocity():Length()
    else
        speed = ent:GetVelocity():Length()
    end
    
    local mult = RCD.UnitConvertion[unitName]
    if not isnumber(mult) then mult = 0.09144 end

	local unit = math.Round(speed * mult)

    return unit
end

--[[ Made a function compatible with all vehicles addons]]
function RCD.GetVehicle(ent)
    if not IsValid(ent) then return end
    
    --[[ Check if the player drive the vehicle or is on a passenger seat ]]
    local vehc = ent:GetParent()
    ent = (IsValid(vehc) and vehc or ent)

    if RCD.VehicleBlacklisted[ent:GetClass()] or not RCD.IsVehicle(ent) then return end

    return ent
end

--[[ Format a number ]]
function RCD.FormatNumber(time)
    if not isnumber(time) then return end
    local dateString = "%Ss"

    if time/60 >= 1 then
        dateString = "%Mm %Ss"

        if time/3600 >= 1 then
            dateString = "%Hh %Mm %Ss"

            if time/86400 >= 1 then
                dateString = "%dd %Hh %Mm %Ss"
            end
        end
    end
    return dateString
end

local PLAYER = FindMetaTable("Player")

--[[ This function permite to add compatibility with other gamemode ]]
function PLAYER:RCDGetMoney()
    if DarkRP then
        return self:getDarkRPVar("money")
    elseif ix then
        return (self:GetCharacter() != nil and self:GetCharacter():GetMoney() or 0)
    elseif nut then
        return (self:getChar() != nil and self:getChar():getMoney() or 0)
    end

    return 0
end

function PLAYER:RCDIsVehicleSpawned(vehicleId)  
    if SERVER then
        self.RCD = self.RCD or {}

        self.RCD["vehicleSpawned"] = self.RCD["vehicleSpawned"] or {}
        return self.RCD["vehicleSpawned"][vehicleId]
    else
        RCD.ClientTable["vehicleSpawned"] = RCD.ClientTable["vehicleSpawned"] or {}
        return RCD.ClientTable["vehicleSpawned"][vehicleId]
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fd9ac0afe17b46ce4fa242227d1e5baad11f6eb527fa1fa0a64865568342fe59

function PLAYER:RCDGetAllVehiclesSpawned()  
    if SERVER then
        self.RCD = self.RCD or {}

        self.RCD["vehicleSpawned"] = self.RCD["vehicleSpawned"] or {}
        return self.RCD["vehicleSpawned"]
    else
        RCD.ClientTable["vehicleSpawned"] = RCD.ClientTable["vehicleSpawned"] or {}
        return RCD.ClientTable["vehicleSpawned"]
    end
end

--[[ Get vehicle with his unique id ]]
function RCD.GetVehicleInfo(vehicleId)
    vehicleId = tonumber(vehicleId)
    local vehicleTable = (SERVER and RCD.AdvancedConfiguration["vehiclesList"] or RCD.ClientTable["vehiclesTable"]) or {}

    return vehicleTable[vehicleId] or {}
end

--[[ Get vehicle group with his unique id ]]
function RCD.GetVehicleGroupInfo(groupId)
    RCD.AdvancedConfiguration["groupsList"] = RCD.AdvancedConfiguration["groupsList"] or {}
    RCD.AdvancedConfiguration["groupsList"][groupId] = RCD.AdvancedConfiguration["groupsList"][groupId] or {}
    
    return RCD.AdvancedConfiguration["groupsList"][groupId]
end

--[[ Check if the player can buy the vehicle ]]
function PLAYER:RCDCanAccessVehicle(vehicleId)
    local vehicleTable = RCD.GetVehicleInfo(vehicleId)
    if not istable(vehicleTable) then return end
    
    local groupId = vehicleTable["groupId"]
    if not isnumber(groupId) then return false end

    if SERVER && not self:RCDCheckNPCInfo(groupId) then return end

    local groupTable = RCD.GetVehicleGroupInfo(groupId)
    local rankAccess = groupTable["rankAccess"] or {}
    local jobAccess = groupTable["jobAccess"] or {}

    if not rankAccess["*"] then
        local rank = self:GetUserGroup()

        if not rankAccess[rank] then if SERVER then self:RCDNotification(5, RCD.GetSentence("invalidUsergroup")) end return false end
    end
    
    if not jobAccess["*"] then
        local job = team.GetName(self:Team())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307890

        if not jobAccess[job] then if SERVER then self:RCDNotification(5, RCD.GetSentence("invalidJob")) end return false end
    end
    
    local canAccess = hook.Run("RCD:CanAccessVehicle", self, vehicleTable, vehicleId)
    if canAccess == false then return end

    return true, vehicleTable
end

function PLAYER:RCDCalculateSellPrice(vehiclesTable, vehicleId)
    local vehicleTable = vehiclesTable[vehicleId]
    if not istable(vehicleTable) then return end

    local discount = 0
    if SERVER then
        local boughTable = self.RCD["vehicleBought"] or {}
        discount = self.RCD["vehicleBought"][vehicleId] and tonumber(self.RCD["vehicleBought"][vehicleId]["discount"]) or 0
    else
        local boughTable = RCD.ClientTable["vehiclesBought"] or {}
        discount = RCD.ClientTable["vehiclesBought"][vehicleId] and tonumber(RCD.ClientTable["vehiclesBought"][vehicleId]["discount"]) or 0
    end

    local price = 0
    if discount > 0 then
        price = discount*(RCD.GetSetting("generalPourcentSell", "number")/100)
    else
        price = (vehicleTable["price"] or 0)*(RCD.GetSetting("generalPourcentSell", "number")/100)
    end

    return price
end

function RCD.GetSetting(key, settingType)
    if settingType == "number" then
        return tonumber(RCD.DefaultSettings[key]) or 0
    elseif settingType == "string" then
        return tostring(RCD.DefaultSettings[key]) or ""
    elseif settingType == "boolean" then
        return tobool(RCD.DefaultSettings[key]) or false
    elseif settingType == "table" then
        return RCD.DefaultSettings[key] or {}
    end

    return RCD.DefaultSettings[key]
end

--[[ Get name of the group vehicle ]]
function RCD.VehicleGroupGetName(id)
    RCD.AdvancedConfiguration["groupsList"] = RCD.AdvancedConfiguration["groupsList"] or {}
    if not istable(RCD.AdvancedConfiguration["groupsList"][id]) then return end

    return RCD.AdvancedConfiguration["groupsList"][id]["name"]
end

--[[ Calcul the price of all customizations ]]
function RCD.GetPriceCustomization(vehicleOptions, oldCustomization, customization)
    if not istable(vehicleOptions) then return 0 end

    local priceBodygroup = vehicleOptions["priceBodygroup"] or 0
    local priceColor = vehicleOptions["priceColor"] or 0
    local priceNitro = vehicleOptions["priceNitro"] or 0
    local priceSkin = vehicleOptions["priceSkin"] or 0
    local priceUnderglow = vehicleOptions["priceUnderglow"] or 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 387f8d7d767b84214633caf55164032cd62eecaca645fdeca95eda015b5730a6
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307883

    local price = 0
    if istable(customization["vehicleColor"]) then
        local oldVehicleColor = oldCustomization["vehicleColor"] or {}

        if istable(oldVehicleColor) && (customization["vehicleColor"].r != oldVehicleColor.r or customization["vehicleColor"].g != oldVehicleColor.g or customization["vehicleColor"].b != oldVehicleColor.b) then
            price = price + vehicleOptions["priceColor"]
        end
    end

    if isnumber(customization["vehicleSkin"]) then
        if customization["vehicleSkin"] != 0 && customization["vehicleSkin"] != oldCustomization["vehicleSkin"] then
            price = price + vehicleOptions["priceSkin"]
        end
    end
    
    if istable(customization["vehicleUnderglow"]) then
        local oldUngerGlow = oldCustomization["vehicleUnderglow"] or {}

        if istable(oldUngerGlow) && (customization["vehicleUnderglow"].r != oldUngerGlow.r or customization["vehicleUnderglow"].g != oldUngerGlow.g or customization["vehicleUnderglow"].b != oldUngerGlow.b) then
            price = price + vehicleOptions["priceUnderglow"]
        end
    end
    
    if istable(customization["vehicleBodygroups"]) then
        local oldBodygroup = oldCustomization["vehicleBodygroups"] or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 387f8d7d767b84214633caf55164032cd62eecaca645fdeca95eda015b5730a6
        
        for k,v in pairs(customization["vehicleBodygroups"]) do
            if customization["vehicleBodygroups"][k] != 0 && customization["vehicleBodygroups"][k] != oldBodygroup[k] then
                price = price + vehicleOptions["priceBodygroup"]
            end
        end
    end
    
    if isnumber(customization["vehicleNitro"]) then
        if customization["vehicleNitro"] != oldCustomization["vehicleNitro"] then
            price = price + (priceNitro*customization["vehicleNitro"])
        end
    end
    
    return price
end

function RCD.IsVehicle(ent)
    if not IsValid(ent) then return false end
    if not isnumber(RCD.GetNWVariables("RCDVehicleId", ent)) && not ent:IsVehicle() then return false end

    return true
end

hook.Add("RCD:CanAccessVehicle", "RCD:Compatibility:CanAccessVehicle", function(ply, vehcTable, vehicleId)
    if RCD.CustomCheck && isfunction(RCD.CustomCheck[vehicleId]) then
        local customCheck = RCD.CustomCheck[vehicleId](ply, vehcTable, vehicleId)

        if isfunction(RCD.CustomCheck["*"]) then
            customCheck = RCD.CustomCheck["*"](ply, vehcTable, vehicleId)
        end
        
        return customCheck
    end
end)

hook.Add("VC_canChangeState", "RCD:VCMOD:Compatibility:VC_canChangeState", function(ent, id, new, old, ply)
    if not IsValid(ent) then return end

    if id == "CruiseOn" then
        local engineStatus = RCD.GetNWVariables("RCDEngine", ent)

        if not engineStatus then 
            return false
        end
    end
end)
