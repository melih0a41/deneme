AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_menu.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetCorpID(0)

	self.used = CurTime()
	self:SetDoorOpen(false)
	self.ThinkDelay = CurTime()
	self.cachedMoney = 0
end

function ENT:ToggleVaultDoor()
	if(self:GetDoorOpen()) then
		self:EmitSound(Corporate_Takeover.Config.Sounds.General["vault_close"])
		self:SetDoorOpen(false)
		self:SetBodygroup(0, 0)
	else
		self:EmitSound(Corporate_Takeover.Config.Sounds.General["vault_open"])
		self:SetDoorOpen(true)
		self:SetBodygroup(0, 1)
	end
end

function ENT:Use(ply)
	if(self.used < CurTime()) then
		self.used = CurTime() + 1

		if(self:Getowning_ent() != ply) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("not_your_desk"))
			return false
		end

		ply.CTO_Selected_Desk = self

		if(self:GetCorpID() != 0) then
			local CorpID = self:GetCorpID()
			local Corp = Corporate_Takeover:GetData(CorpID)
			if(Corp) then
				ply.CTOVault = self
				net.Start("cto_OpenVaultMenu")
					net.WriteUInt(CorpID, 8)
					net.WriteEntity(Entity(self:EntIndex()))
				net.Send(ply)
			end
		end
	end
end

net.Receive("cto_ToggleVaultDoor", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end

	local ent = ply.CTOVault
	if(ent && IsValid(ent)) then
		if(ent.Getowning_ent && ent:Getowning_ent() == ply) then
			ent:ToggleVaultDoor()
		end


		ply.CTOVault = nil
	end
end)

function ENT:OnRemove()
	local CorpID = self:GetCorpID()
	local Corp = Corporate_Takeover:GetData(self:GetCorpID())

	local deskclass = self:GetDeskClass()
	if(deskclass != "none" && Corp) then
		local exists = Corp.desks[deskclass]
		if(exists) then
			Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] = Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] - 1

			if(Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] < 0) then
				Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] = 0
			end
		end
	end


	local money = self.cachedMoney

	if(Corp) then
		money = Corp.money
	end

	local diff = money - Corporate_Takeover.Config.DefaultVault
	if(diff > 0) then
		if(Corporate_Takeover.Config.DropVaultMoney) then
			DarkRP.createMoneyBag(self:GetPos(), diff)
		end

		if(Corp) then
		    Corporate_Takeover.Corps[Corp.CorpID].money = Corporate_Takeover.Config.DefaultVault
		end
	end

	if(Corp) then
	    Corporate_Takeover.Corps[Corp.CorpID].maxMoney = Corporate_Takeover.Config.DefaultVault
	end

	Corporate_Takeover:SyncDesks(CorpID)
	Corporate_Takeover:SyncMoneyAndLevel(CorpID)
end

function ENT:Think()
	if(self.ThinkDelay > CurTime()) then
		return false
	end
	self.ThinkDelay = CurTime() + 1

	if(self:GetCorpID() != 0) then
		local CorpID = self:GetCorpID()
		local Corp = Corporate_Takeover:GetData(self:GetCorpID())
		if(Corp) then
			if(self.cachedMoney == Corp.money) then
				return false
			end

			local money = Corp.money
			local max = Corp.maxMoney
			local perc = (100 / max) * money

			self.cachedMoney = money

			if(perc > 80) then
				self:SetBodygroup(1, 4)
			elseif(perc > 60) then
				self:SetBodygroup(1, 3)
			elseif(perc > 30) then
				self:SetBodygroup(1, 2)
			elseif(perc > 1) then
				self:SetBodygroup(1, 1)
			else
				self:SetBodygroup(1, 0)
			end
		end
	end
end