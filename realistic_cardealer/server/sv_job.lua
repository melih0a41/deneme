/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")

--[[ This function permit to solve a lot of exploit ]]
function PLAYER:RCDCheckShowcasePos(showcase)
    if not IsValid(showcase) then return false end

    local dist = self:GetPos():DistToSqr(showcase:GetPos())
    if dist > 3000 then return false end

    return true
end

function PLAYER:RCDManageJobVehicle(showcase, vehicleParams)
    if not IsValid(showcase) or not istable(vehicleParams) then return end
    
    local vehicleId = vehicleParams["vehicleId"]
    if not self:RCDCheckShowcasePos(showcase) then return end
    
    local vehicleTable = RCD.AdvancedConfiguration["vehiclesList"][vehicleId]
    if not istable(vehicleTable) then return end

    self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9
    
    local options = vehicleTable["options"] or {}
    if not options["canSellWithJob"] then return end

    local commission = tonumber(vehicleParams["vehicleCommission"]) or 0
    if commission > (tonumber(options["maxCommissionPrice"]) or 1000) or commission < (tonumber(options["minCommissionPrice"]) or 0) then return end

    local vehicleColor = vehicleParams["vehicleColor"]
    vehicleColor.a = 255

    self.RCD = self.RCD or {}
    if not istable(showcase.RCDVehicle) then
        if istable(self.RCD["jobVehicles"][vehicleId]) then self:RCDNotification(5, RCD.GetSentence("alreadyRented")) return end

        local rentPrice = options["rentPrice"] or 0
        if self:RCDGetMoney() < tonumber(rentPrice) then self:RCDNotification(5, RCD.GetSentence("notEnoughtMoney")) return end

        self:RCDAddMoney(-rentPrice)
        self:RCDNotification(5, RCD.GetSentence("rentVehc"):format(vehicleTable["name"], RCD.formatMoney(rentPrice)))

        local addAng = 90
        if options["addon"] == "simfphys" then
            addAng = RCD.VehiclesList[vehicleTable["class"]]["SpawnAngleOffset"] or 0
        end        

        local pos, ang = showcase:LocalToWorld(RCD.Constants["vectorJob"]), showcase:LocalToWorldAngles(Angle(0, addAng, 0))
        
        local vehc = self:RCDCreateVehicle(vehicleTable["class"], pos, ang, (options["addon"] or "default"), vehicleId, true)
        if not IsValid(vehc) then return end

        vehc.vehicleId = vehicleId
        vehc.isRented = true
        vehc.rentPrice = rentPrice

        vehc:CallOnRemove("rcd_showcase_vehc:"..vehc.vehicleId, function(ent) 
            if IsValid(showcase) then
                if IsValid(self) && self.RCD then
                    self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
                    self.RCD["jobVehicles"][vehc.vehicleId] = nil
                    
                    net.Start("RCD:Main:Job")
                        net.WriteUInt(3, 4)
                        net.WriteEntity(showcase)
                        net.WriteBool(false)
                    net.Send(self)
                end
                
                showcase.RCDVehicle = nil
            end
        end)
        
        showcase:CallOnRemove("rcd_showcase_deleted:"..showcase:EntIndex(), function(ent) 
            if IsValid(vehc) then
                if IsValid(self) && self.RCD then
                    self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
                    self.RCD["jobVehicles"][vehc.vehicleId] = nil
                    
                    vehc:Remove()
                end
            end
        end)
        
        timer.Simple(1, function()
            if not IsValid(vehc) then return end
            
            local phys = vehc:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end

            vehc:SetParent(showcase)
        end)
        
        showcase.RCDVehicle = vehicleTable or {}
        showcase.RCDVehicle["vehc"] = vehc
        
        local phys = showcase:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        vehc:SetColor(vehicleColor)
        vehc:SetSkin(vehicleParams["vehicleSkin"])

        RCD.GenerateUnderGlow(vehc, vehicleParams["vehicleUnderglow"])
        
        for k,v in pairs(vehicleParams["vehicleBodygroups"]) do
            vehc:SetBodygroup(k, v)
        end
        
        self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
        self.RCD["jobVehicles"][vehc.vehicleId] = vehicleTable
        self.RCD["jobVehicles"][vehc.vehicleId]["vehicleCommission"] = commission
        
        net.Start("RCD:Main:Job")
            net.WriteUInt(3, 4)
            net.WriteEntity(showcase)
            net.WriteBool(true)
        net.Send(self)
    else
        local vehc = showcase.RCDVehicle["vehc"]
        if not IsValid(vehc) then return end

        if vehc.RCDOwner != self then return end

        vehc:SetColor(vehicleColor)
        vehc:SetSkin(vehicleParams["vehicleSkin"])

        RCD.GenerateUnderGlow(vehc, vehicleParams["vehicleUnderglow"])

        for k,v in pairs(vehicleParams["vehicleBodygroups"]) do
            vehc:SetBodygroup(k, v)
        end

        self:RCDNotification(5, RCD.GetSentence("modifyRentVehicle"))
        
        self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
        self.RCD["jobVehicles"][vehc.vehicleId] = self.RCD["jobVehicles"][vehc.vehicleId] or {}
        self.RCD["jobVehicles"][vehc.vehicleId]["vehicleCommission"] = commission
    end
end

hook.Add("PhysgunPickup", "RCD:PhysgunPickup:Protect", function(ply, ent)
    if (ent:GetClass() == "rcd_showcase" && istable(ent.RCDVehicle)) or (RCD.IsVehicle(ent) && ent.isRented) then
        return false
    end
end)

--[[ Just sell the vehicle rented and refund the player ]]
function PLAYER:RCDSellJobVehicles(showcase)
    if not IsValid(showcase) then return end
    
    local vehc = showcase.RCDVehicle["vehc"]
    if not IsValid(vehc) then return end

    self.RCD = self.RCD or {}
    
    self.RCD["jobVehicles"] = self.RCD["jobVehicles"] or {}
    if not self.RCD["jobVehicles"] then return end
    self.RCD["jobVehicles"][vehc.vehicleId] = nil

    vehc:Remove()

    if isnumber(vehc.rentPrice) then
        self:RCDAddMoney(vehc.rentPrice)
        self:RCDNotification(5, RCD.GetSentence("refundRentVehicle"):format(RCD.formatMoney(vehc.rentPrice)))
        
        vehc.rentPrice = nil
    end

    net.Start("RCD:Main:Job")
        net.WriteUInt(3, 4)
        net.WriteEntity(showcase)
        net.WriteBool(false)
    net.Send(self)
end

--[[ Create paper ]]--
function PLAYER:RCDCreatePaper(ent, vehicleId, vehicleParams)
    local vehicleTable = RCD.AdvancedConfiguration["vehiclesList"][vehicleId]
    if not istable(vehicleTable) then return end
    
    local options = vehicleTable["options"] or {}
    if not options["canSellWithJob"] then return end

    self.RCD = self.RCD or {}
    if not istable(self.RCD["jobVehicles"]) or not istable(self.RCD["jobVehicles"][vehicleId]) then return end

    local commission = tonumber(vehicleParams["vehicleCommission"]) or 0
    if commission > (tonumber(options["maxCommissionPrice"]) or 1000) or commission < (tonumber(options["minCommissionPrice"]) or 0) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

	ent.RCDCount = ent.RCDCount or 0

	local paper = ents.Create("rcd_paper")
	paper:SetPos(ent:LocalToWorld(RCD.Constants["vectorInvoice"]))
	paper:SetAngles(ent:LocalToWorldAngles(RCD.Constants["angleOrigin"]))
	paper:Spawn()

    paper.RCDInfo = {
        ["vehicleId"] = vehicleId,
        ["vehicleParams"] = vehicleParams,
		["seller"] = self,
    }

	local phys = paper:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(true)
	end

	constraint.NoCollide(paper, ent, 0, 0)

	ent.RCDCount = ent.RCDCount + 1
	paper:CallOnRemove("rcd_paper_remove:"..ent:EntIndex(), function() 
        if IsValid(ent) then
            ent.RCDCount = ent.RCDCount - 1
        end
	end)
end

--[[ Start printing function ]]--
function PLAYER:RCDStartPrinting(ent, vehicleId, vehicleParams)
    local vehicleTable = RCD.AdvancedConfiguration["vehiclesList"][vehicleId]
    if not istable(vehicleTable) then return end
    
    local options = vehicleTable["options"] or {}
    if not options["canSellWithJob"] then return end

    self.RCD = self.RCD or {}
    if not istable(self.RCD["jobVehicles"]) or not istable(self.RCD["jobVehicles"][vehicleId]) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

    local commission = tonumber(vehicleParams["vehicleCommission"]) or 0
    if commission > (tonumber(options["maxCommissionPrice"]) or 1000) or commission < (tonumber(options["minCommissionPrice"]) or 0) then return end

	ent.RCDCount = ent.RCDCount or 0
	if ent.RCDCount >= RCD.GetSetting("maxInvoice", "number") then self:RCDNotification(5, self:RCDNotification(5, RCD.GetSentence("invoiceLimit"))) return end
	
	ent:SetSkin(0)
	ent:ResetSequence("printing")
	ent:SetSequence("printing")
	ent:EmitSound("rcd_sounds/printsounds.wav")

	net.Start("RCD:Main:Job")
		net.WriteUInt(5, 4)
		net.WriteBool(false)
	net.Send(self)

	timer.Simple(1, function()
		if not IsValid(ent) then return end

		ent:SetSkin(1)

		timer.Simple(1.2, function()
			if not IsValid(ent) then return end

			self:RCDCreatePaper(ent, vehicleId, vehicleParams)

			ent:ResetSequence("idle")
			ent:SetSequence("idle")
		end)
	end)
end

--[[ Accept the invoice, calcul the price and remove the paper ]]--
function PLAYER:RCDAcceptInvoice()
    local paper = net.ReadEntity()
    if not IsValid(paper) or not paper.RCDInfo then return end

    local seller = paper.RCDInfo["seller"]

    if IsValid(seller) then
        if seller == self then self:RCDNotification(5, RCD.GetSentence("cantAcceptYourInvoice")) return end
    end

    local vehicleId = paper.RCDInfo["vehicleId"]
    if self:RCDCheckVehicleBuyed(vehicleId) then self:RCDNotification(5, RCD.GetSentence("alreadyBought")) return end

    local vehicleTable = RCD.AdvancedConfiguration["vehiclesList"][vehicleId] or {}
    if not istable(vehicleTable) then return end

    local options = vehicleTable["options"] or {}
    if not options["canSellWithJob"] then return end

    local params = paper.RCDInfo["vehicleParams"] or {}
    local price = vehicleTable["price"]*(options["cardealerJobDiscount"]/100) + (params["vehicleCommission"] or 0)

    if params["vehicleSkin"] && params["vehicleSkin"] != 0 then
        price = price + (options["priceSkin"] or 0)
    end
    if params["vehicleColor"] && params["vehicleColor"] != RCD.ColorPaletteColors[40] then
        price = price + (options["priceColor"] or 0)
    end
    if params["vehicleUnderglow"] && params["vehicleUnderglow"] != RCD.ColorPaletteColors[40] then
        price = price + (options["priceUnderglow"] or 0)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
    
    if self:RCDGetMoney() < price then self:RCDNotification(5, RCD.GetSentence("notEnoughtMoney")) return end

    self:RCDAddMoney(-price)
    RCD.GiveVehicle(self, vehicleId, (paper.RCDInfo["vehicleParams"] or {}), price)
    
    self:RCDNotification(5, RCD.GetSentence("buyVehicleText"):format(vehicleTable["name"], RCD.formatMoney(price)))
    
    if IsValid(seller) then
        seller:RCDNotification(5, RCD.GetSentence("acceptedInvoice"):format(self:Name(), vehicleTable["name"], RCD.formatMoney(price)))
        
        seller.RCD["jobVehicles"] = seller.RCD["jobVehicles"] or {}
        seller.RCD["jobVehicles"][vehicleId] = seller.RCD["jobVehicles"][vehicleId] or {}
        
        local vehc = seller.RCD["jobVehicles"][vehicleId]["vehc"]
        if IsValid(vehc) then vehc:Remove() end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

        local priceWon = (params["vehicleCommission"] or 0)
        seller:RCDAddMoney(priceWon)
        seller:RCDNotification(5, RCD.GetSentence("sellVehicleRented"):format(RCD.formatMoney(priceWon), vehicleTable["name"]))
    end

    paper:Remove()

    net.Start("RCD:Main:Job")
        net.WriteUInt(5, 4)
        net.WriteBool(true)
    net.Send(self)
end
