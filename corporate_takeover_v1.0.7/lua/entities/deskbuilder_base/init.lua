AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/corporate_takeover/nostras/packet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger()
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.used = CurTime()

	self:SetDeskClass("none")
	self:SetCorpID(0)
end


function ENT:Use(ply)
	if(self.used < CurTime()) then
		self.used = CurTime() + 1

		if(self:Getowning_ent() && IsValid(self:Getowning_ent()) && self:Getowning_ent() == ply) then
			local CID = self:GetCorpID()
			if(CID != 0) then
				if(ply.CTOCorpID != CID) then
					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("old_corp"))
					return false
				end
			end

			local class = self:GetDeskClass()
			if(class != "none") then
				if(ply.PlacingDesk == nil) then
					net.Start("cto_OpenDeskBuilderMenu")
						net.WriteString(class)
					net.Send(ply)

					ply.PlacingDesk = self
				end
			else
				self:Remove()
			end
		else
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("not_yours"))
		end
	end
end

net.Receive("cto_OpenDeskBuilderMenu", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end

	local ent = ply.PlacingDesk
	if(!ent || !IsValid(ent)) then
		return false
	end

	net.Start("cto_OpenDeskBuilder")
		net.WriteEntity(Entity(ent:EntIndex()))
	net.Send(ply)
end)

net.Receive("cto_sellDesk", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end

	local ent = ply.PlacingDesk
	if(!ent || !IsValid(ent)) then
		return false
	end

	local class = ent:GetDeskClass()
	if(!class) then return false end
	local desk = Corporate_Takeover.Desks[class]
	if(!desk) then return false end

	local sell = desk.sell
	if(!sell) then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("cant_sell"))
		return false
	end
	local price = desk.price
	local sold = price * sell

	ply:addMoney(sold)
	ent:Remove()

	local message = Corporate_Takeover:Lang("desk_sold")
	message = string.Replace(message, "%name", Corporate_Takeover:Lang(class))
	message = string.Replace(message, "%price", DarkRP.formatMoney(sold))

	DarkRP.notify(ply, 0, 5, message)

end)