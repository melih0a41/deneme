/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")
local RCDMap = string.lower(game.GetMap())

--[[ Open the car dealer menu ]]
function PLAYER:RCDOpenResellerMenu(npc)
    if not IsValid(npc) then return end

    local canOpen = hook.Run("RCD:CanOpenReseller", self, npc)
    if canOpen == false then return end
    
    self.RCD = self.RCD or {}
    self.RCD["resellerUse"] = npc

    net.Start("RCD:Insurance")
        net.WriteUInt(1, 4)
    net.Send(self)

    return true
end

--[[ Check if the vehicle has an insurance ]]
function PLAYER:RCDCheckInsurance(vehicleId)
    self.RCD = self.RCD or {}
    self.RCD["vehicleBought"] = self.RCD["vehicleBought"] or {}

    if not self.RCD["vehicleBought"][vehicleId] or not self.RCD["vehicleBought"][vehicleId]["customization"] then return end
    local hasInsurance = self.RCD["vehicleBought"][vehicleId]["customization"]["hasInsurance"]

    return hasInsurance
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

--[[ Buy the insurance for a specific steamID ]]
function PLAYER:RCDInsurance(vehicleId)
    local insuranceModuleActivated = RCD.GetSetting("insuranceModuleActivated", "boolean")
    if not insuranceModuleActivated then return end

    vehicleId = tonumber(vehicleId)
    if not isnumber(vehicleId) then return end

    local success, vehicleTable = self:RCDCanAccessVehicle(vehicleId)
    if not success then return end

    local canCustom = hook.Run("RCD:CanPayInsurance", self, vehicleTable)
    if canCustom == false then return end

    if not self:RCDCheckVehicleBuyed(vehicleId) then return false end

    local vehc = self:RCDGetVehicleWithId(vehicleId)
    if IsValid(vehc) then
        if vehc:GetPos():DistToSqr(self:GetPos()) > RCD.GetSetting("distToReturn", "number")^2 then 
            self:RCDNotification(5, RCD.GetSentence("vehicleTooFar"))
            return 
        end
    end

    self.RCD["vehicleBought"][vehicleId] = self.RCD["vehicleBought"][vehicleId] or {}
    self.RCD["vehicleBought"][vehicleId]["customization"] = self.RCD["vehicleBought"][vehicleId]["customization"] or {}
    
    local hasInsurance = self.RCD["vehicleBought"][vehicleId]["customization"]["hasInsurance"]
    
    --[[ If the player don't have insurance check if he can buy it ]]
    if not hasInsurance then
        local insurancePourcentPrice = RCD.GetSetting("insurancePourcentPrice", "number")
        
        local options = vehicleTable["options"] or {}
        if options["pourcentInsuranceVehicle"] && options["pourcentInsuranceVehicle"] != 0 then
            insurancePourcentPrice = options["pourcentInsuranceVehicle"] 
        end
    
        local price = tonumber((vehicleTable["price"] or 0))*insurancePourcentPrice/100
        if not isnumber(price) then return end

        local maxInsurancePrice = RCD.GetSetting("maxInsurancePrice", "number")
        price = math.Clamp(price, 0, maxInsurancePrice)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499
    
        if self:RCDGetMoney() < price then 
            self:RCDNotification(5, RCD.GetSentence("insurancePrice"))
            return false 
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

        self:RCDAddMoney(-price)
    end

    self.RCD["vehicleBought"][vehicleId]["customization"]["hasInsurance"] = !hasInsurance

    net.Start("RCD:Main:Client")
        net.WriteUInt(13, 4)
        net.WriteUInt(vehicleId, 32)
        net.WriteBool(self.RCD["vehicleBought"][vehicleId]["customization"]["hasInsurance"])
    net.Send(self)

    RCD.Query(("UPDATE rcd_bought_vehicles SET customization = %s WHERE vehicleId = %s AND playerId = %s"):format(RCD.Escape(util.TableToJSON(self.RCD["vehicleBought"][vehicleId]["customization"])), RCD.Escape(vehicleId), RCD.Escape(self:SteamID64())))
end

--[[ Check if the vehicle is near a reseller ]]
function RCD.CheckResellerNPC(vehc)
    for k,v in ipairs(ents.GetAll()) do
        if v:GetClass() != "rcd_reseller" then continue end
        if v:GetPos():DistToSqr(vehc:GetPos()) > RCD.GetSetting("distanceToSell", "number") then continue end

        return true
    end
end

--[[ Sell the vehicle ]]
function RCD.ResellVehicle(vehc, ply)
    RCD.StolenVehicleCooldown = RCD.StolenVehicleCooldown or {}

    local osTime = os.time()
    local waitingTime = RCD.StolenVehicleCooldown[ply:SteamID64()]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

    if isnumber(waitingTime) then
        if waitingTime > osTime then
            local timeToWait = (waitingTime - os.time())
            local dateString = RCD.FormatNumber(timeToWait)

            ply:RCDNotification(5, RCD.GetSentence("notifyToStoleNewVehicle"):format(os.date(dateString, timeToWait)))
            return 
        end
    end

    if not IsValid(vehc) then return end
    
    local owner = vehc.RCDOwner
    if not IsValid(owner) then return end
    
    if owner == ply then
        ply:RCDNotification(5, RCD.GetSentence("cantSellOwnVehicle"))
        return 
    end

    if not RCD.CheckResellerNPC(vehc) then return end

    local driver = vehc:GetDriver()
    if IsValid(driver) then
        ply:RCDNotification(5, RCD.GetSentence("someoneInVehicle"))
        return 
    end

    local unitName = RCD.GetSetting("unitChoose", "string")
    local speed = RCD.GetSpeedVehicle(vehc, unitName)
    if speed > 0 then 
        ply:RCDNotification(5, RCD.GetSentence("vehicleSpeedSell"))
        return 
    end

    local vehicleId = RCD.GetNWVariables("RCDVehicleId", vehc)
    if not isnumber(vehicleId) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

    local vehicleTable = RCD.GetVehicleInfo(vehicleId)
    if not istable(vehicleTable) then return end

    local options = vehicleTable["options"] or {}
    local resellPourcentPrice = RCD.GetSetting("resellPourcentPrice", "number")

    if options["pourcentPriceSellVehicle"] && options["pourcentPriceSellVehicle"] != 0 then
        resellPourcentPrice = options["pourcentPriceSellVehicle"] 
    end
    
    local price = tonumber((vehicleTable["price"] or 0))*resellPourcentPrice/100
    if not isnumber(price) then return end

    local maxResellPrice = RCD.GetSetting("maxResellPrice", "number")
    price = math.Clamp(price, 0, maxResellPrice)

    local cooldownBeforeSell = RCD.GetSetting("timeToStoleNewVehicle", "number")

    RCD.StolenVehicleCooldown[ply:SteamID64()] = osTime + cooldownBeforeSell

    ply:RCDNotification(5, RCD.GetSentence("soldStolenVehicle"):format(RCD.formatMoney(price)))
    ply:RCDAddMoney(price)

    local insuranceModuleActivated = RCD.GetSetting("insuranceModuleActivated", "boolean")

    if insuranceModuleActivated then
        local vehicleBuyTable = owner:RCDGetVehicleBought(vehicleId)
        local customization = vehicleBuyTable["customization"] or {}
   
        if customization["hasInsurance"] then
            vehc.RCDWaitingTime = os.time() + RCD.GetSetting("timeWithInsurance", "number")
            owner:RCDNotification(5, RCD.GetSentence("vehicleStolenNotRemove"))
        else
            vehc.RCDWaitingTime = os.time() + RCD.GetSetting("timeWithoutInsurance", "number")
            
            local removeVehicle = RCD.GetSetting("removeVehicleStolen", "boolean")
            if removeVehicle then
                RCD.RemoveVehicle(owner:SteamID64(), vehicleId)
                owner:RCDNotification(5, RCD.GetSentence("vehicleStolenRemove"))
            else
                owner:RCDNotification(5, RCD.GetSentence("vehicleStolenNotRemove"))
            end
        end
        owner:RCDUpdateOptionsCompatibilities(vehc, vehicleId)
    end
    
    vehc:Remove()
end

--[[ Create reseller NPC ]]
function RCD.CreateResellerNPC(npcId, name, model, pos, ang, map)
    if not isvector(pos) then return end
    if not isangle(ang) then return end

    local edit = isnumber(npcId)
    pos, ang = tostring(pos), tostring(ang)
    
    if edit then
        RCD.Query(("UPDATE rcd_resellernpc SET map = %s, name = %s, model = %s, pos = %s, ang = %s WHERE map = %s AND id = %s"):format(RCD.Escape(RCDMap), RCD.Escape(name), RCD.Escape(model), RCD.Escape(pos), RCD.Escape(ang), RCD.Escape(RCDMap), RCD.Escape(npcId)), function()
            RCD.CreateResellerEntity(pos, ang, model, npcId)
        end)
    else
        RCD.Query(("INSERT INTO rcd_resellernpc (map, name, model, pos, ang) VALUES (%s, %s, %s, %s, %s)"):format(RCD.Escape(RCDMap), RCD.Escape(name), RCD.Escape(model), RCD.Escape(pos), RCD.Escape(ang)), function(tbl)
            npcId = tonumber(tbl["lastInsertId"])
            
            RCD.CreateResellerEntity(pos, ang, model, npcId)
        end)
    end
end

--[[ Create NPC entity ]]
function RCD.CreateResellerEntity(pos, ang, model, npcId)
    if not isstring(model) then return end

    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc_reseller"] = RCD.Entity["npc_reseller"] or {}

    local npc = ents.Create("rcd_reseller")
    if not IsValid(npc) then return end
    npc:SetPos(RCD.ToVectorOrAngle(pos, Vector))
    npc:SetAngles(RCD.ToVectorOrAngle(ang, Angle))
    npc:SetModel(model)
    npc:Spawn()
    npc:Activate()
    RCD.SetNPCResellerParams(npcId, npc)

    RCD.Entity["npc_reseller"][#RCD.Entity["npc_reseller"] + 1] = npc
end

--[[ Set all settings on the npc ]]
function RCD.SetNPCResellerParams(npcId, npc)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end
    if not IsValid(npc) then return end

    RCD.Query(("SELECT * FROM rcd_resellernpc WHERE map = %s AND id = %s"):format(RCD.Escape(RCDMap), RCD.Escape(npcId)), function(npcTable)
        npcTable = npcTable[1] or {}
        
        npc.SettingsTable = npcTable
        npc.NPCId = npcId
        
        timer.Simple(1, function()
            if not IsValid(npc) then return end
    
            RCD.SetNWVariable("rcd_npc_name", npcTable["name"], npc, true, nil, true)
        end)
    
        hook.Run("RCD:OnInitializeNPC", id, npc, npcTable)
    end)
end

--[[ Reload all entity on the server ]]
function RCD.LoadResellerNPC()
    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc_reseller"] = RCD.Entity["npc_reseller"] or {}

    RCD.RemoveAllResellerNPC()
    RCD.Query(("SELECT * FROM rcd_resellernpc WHERE map = %s"):format(RCD.Escape(RCDMap)), function(npcTable)
        npcTable = npcTable or {}

        for k,v in ipairs(npcTable) do
            RCD.CreateResellerEntity(v.pos, v.ang, v.model, v.id)
        end 
    end)
end

--[[ Get position and angle of the npc ]]
function RCD.GetResellerNPCPosAng(npcId)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    for k,v in ipairs(RCD.Entity["npc_reseller"]) do
        if not IsValid(v) or v.NPCId != npcId then continue end

        return v:GetPos(), v:GetAngles()
    end
end

--[[ Remove a NPC with his id on the server ]]
function RCD.RemoveResellerNPC(npcId, deleteDb)
    npcId = tonumber(npcId)
    if not isnumber(npcId) then return end

    if deleteDb then    
        RCD.Query(("DELETE FROM rcd_resellernpc WHERE id = %s"):format(RCD.Escape(npcId)))
    end

    for k,v in ipairs(RCD.Entity["npc_reseller"]) do
        if not IsValid(v) or v.NPCId != npcId then continue end

        v:Remove()
    end
end

--[[ Remove all entity on the server ]]
function RCD.RemoveAllResellerNPC()
    RCD.Entity = RCD.Entity or {}
    RCD.Entity["npc_reseller"] = RCD.Entity["npc_reseller"] or {}

    for k,v in ipairs(RCD.Entity["npc_reseller"]) do
        if not IsValid(v) then continue end

        v:Remove()
    end
end
