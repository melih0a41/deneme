/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")

--[[ Give customization on a specific player and vehicle ]]
function RCD.GiveCustomization(steamId, vehicleId, customization, ply)
    vehicleId = tonumber(vehicleId)
    if not isnumber(vehicleId) then return end

    customization = istable(customization) and customization or {}
    
    local vehicleTable = RCD.GetVehicleInfo(vehicleId)
    if not istable(vehicleTable) then return end

    local options = vehicleTable["options"] or {}

    --[[ This lines permit to solve an exploit with the opacity of vehicles ]]
    customization["vehicleColor"] = customization["vehicleColor"] or (istable(options["defaultColor"]) and Color(options["defaultColor"].r,  options["defaultColor"].g,  options["defaultColor"].b) or RCD.Colors["white"])
    customization["vehicleColor"].a = 255

    RCD.Query(("UPDATE rcd_bought_vehicles SET customization = %s WHERE playerId = %s AND vehicleId = %s"):format(RCD.Escape(util.TableToJSON(customization)), RCD.Escape(steamId), RCD.Escape(vehicleId)), function() 
        local sendTo = IsValid(ply) and ply or (isstring(steamId) and player.GetBySteamID64(steamId) or nil)
        if IsValid(sendTo) then
            net.Start("RCD:Main:Client")
                net.WriteUInt(9, 4)
                net.WriteUInt(vehicleId, 32)
                net.WriteBool(customization["hasInsurance"])
                net.WriteUInt((customization["vehicleSkin"] or 0), 8)
                net.WriteUInt((customization["vehicleNitro"] or 0), 2)
                net.WriteColor(customization["vehicleColor"])
                net.WriteBool(customization["vehicleUnderglow"])
                net.WriteColor((customization["vehicleUnderglow"] or RCD.Colors["white"]))
                local vehicleBodygroups = customization["vehicleBodygroups"] or {}
                net.WriteUInt(table.Count(vehicleBodygroups), 8)
                for k,v in pairs(vehicleBodygroups) do
                    net.WriteUInt(k, 8)
                    net.WriteUInt(v, 8)
                end 
            net.Send(sendTo)
    
            sendTo.RCD = sendTo.RCD or {}
            sendTo.RCD["vehicleBought"] = sendTo.RCD["vehicleBought"] or {}
            sendTo.RCD["vehicleBought"][vehicleId] = sendTo.RCD["vehicleBought"][vehicleId] or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9
    
            sendTo.RCD["vehicleBought"][vehicleId]["customization"] = customization
        end
    end)
end

--[[ Set the color variable on the vehicle ]]
function RCD.GenerateUnderGlow(vehc, color)
    if not IsValid(vehc) then return end
    if not istable(color) then return end

    RCD.SetNWVariable("RCDUnderGlowColor", color, vehc, true, nil, true)
end

--[[ Enable/Disable underglow of the vehicle ]]
function RCD.ActivateUnderGlow(vehc, activate)
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end

    RCD.SetNWVariable("RCDUnderGlowActivate", activate, vehc, true, nil, true)
end

--[[ Set current boost of the vehicle ]]
function RCD.SetBoost(vehc, ply)
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end

    if timer.Exists("rcd_nitro:"..vehc:EntIndex()) then return end

    local nitro = RCD.GetNitro(vehc)
    if nitro <= 0 or nitro > 3 then return end
    
    local unitChoose = RCD.GetSetting("unitChoose", "string")
    local speed = RCD.GetSpeedVehicle(vehc, unitChoose)
    
    if speed < RCD.GetSetting("minSpeedNitro", "number") then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

    local canChange = hook.Run("RCD:CanChangeEngine", vehc)

    local engineActivate = RCD.GetSetting("engineActivate", "boolean") && not RCD.GetVehicleParams(vehc.RCDUniqueId, "disableEngineVehicle")
    local engineStatut = RCD.GetNWVariables("RCDEngine", vehc)

    if canChange == false or (not engineStatut && engineActivate) then return end
    
    local nitroCooldowns = RCD.GetSetting("nitroCooldowns", "number")
    local curtime = CurTime()

    vehc.RCDNitroCooldowns = vehc.RCDNitroCooldowns or 0
    if vehc.RCDNitroCooldowns > curtime then if IsValid(ply) then ply:RCDNotification(5, RCD.GetSentence("cooldownsNitroNotify"):format(math.Round(vehc.RCDNitroCooldowns - curtime))) end return end
    vehc.RCDNitroCooldowns = curtime + nitroCooldowns

    vehc:EmitSound("rcd_sounds/nitro.wav")
    
    RCD.SetNWVariable("RCDNitro", true, vehc, true, ply)
    
	local phys = vehc:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local time = RCD.GetSetting("nitroDuration", "number")
    
    if not isnumber(ply.RCD["oldFOV"]) then
        ply.RCD["oldFOV"] = ply:GetFOV()
    end
    
    ply:SetFOV(140, time)
    if VC && vehc.VC_doBackfire then
        vehc:VC_doBackfire(false, false)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

	timer.Create("rcd_nitro:"..vehc:EntIndex(), 0.1, time/0.1, function()
        local engineStatut = RCD.GetNWVariables("RCDEngine", vehc)
        local canChange = hook.Run("RCD:CanChangeEngine", vehc)

        if not IsValid(vehc) or canChange == false or (not engineStatut && engineActivate) or not IsValid(phys) then 
            timer.Remove("rcd_nitro:"..vehc:EntIndex())
            return 
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

		phys:ApplyForceCenter((vehc:GetForward() * phys:GetMass() * (nitro*50)) * RCD.GetSetting("nitroSpeed", "number"));
	end)

	timer.Simple(time, function()
        if not IsValid(vehc) then return end

        if IsValid(ply) then
            RCD.SetNWVariable("RCDNitro", false, vehc, true, ply)
            ply:SetFOV(ply.RCD["oldFOV"], 3)
        end
	end)
end

--[[ Get current nitro of the vehicle ]]
function RCD.GetNitro(vehc)
    return (vehc.RCDNitro or 0)
end

--[[ Buy customization ]]
function PLAYER:RCDBuyCustomization(vehicleId, customization)
    vehicleId = tonumber(vehicleId)
    if not isnumber(vehicleId) then return end

    if not istable(customization) then return end

    local success, vehicleTable = self:RCDCanAccessVehicle(vehicleId)
    if not success then return end

    local canCustom = hook.Run("RCD:CanCustomizeVehicle", self, vehicleTable)
    if canCustom == false then return end

    if not self:RCDCheckVehicleBuyed(vehicleId) then return false end

    local vehc = self:RCDGetVehicleWithId(vehicleId)
    if IsValid(vehc) then
        if vehc:GetPos():DistToSqr(self:GetPos()) > RCD.GetSetting("distToReturn", "number")^2 then 
            self:RCDNotification(5, RCD.GetSentence("vehicleTooFar"))
            return 
        end
    end
        
    local oldCustomization = self:RCDGetVehicleBought(vehicleId)
    if not istable(oldCustomization) then return end
    oldCustomization = oldCustomization["customization"] or {}

    customization["hasInsurance"] = oldCustomization["hasInsurance"]
    
    local price = RCD.GetPriceCustomization(vehicleTable["options"], oldCustomization, customization)

    if self:RCDGetMoney() < price then 
        self:RCDNotification(5, RCD.GetSentence("customizePrice"))
        return false 
    end

    self:RCDAddMoney(-price)
    
    self:RCDNotification(5, RCD.GetSentence("customizeVehicleText"):format(RCD.formatMoney(price)))
    RCD.GiveCustomization(self:SteamID64(), vehicleId, customization, self)

    if IsValid(vehc) then
        self:RCDSetVehicleParams(vehc, vehicleId)
    end

    hook.Run("RCD:CustomizeVehicle", self, vehicleTable, vehicleId, customization, price)

    return true, vehicleTable, customization
end
