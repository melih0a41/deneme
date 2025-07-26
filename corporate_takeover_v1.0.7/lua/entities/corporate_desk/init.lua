AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetCorpID(0)

	self.used = CurTime()

	self:SpawnChair()
end

function ENT:SpawnChair()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)

	pos = pos + ang:Right() * 40
	pos = pos + ang:Forward() * 5
	pos = pos - ang:Up() * 0.2

	self.chair = ents.Create("prop_dynamic")
	self.chair:SetModel("models/nova/chair_office02.mdl")
	self.chair:SetPos(pos)
	self.chair:SetAngles(ang)
    self.chair:Spawn()
    self.chair:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self.chair:SetSolid(SOLID_VPHYSICS)
    self.chair:PhysicsInit(SOLID_VPHYSICS)
	self.chair:SetParent(self)
end

function ENT:Use(ply)
	if(self.used < CurTime()) then
		self.used = CurTime() + 1

		if(self:Getowning_ent() != ply) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("not_your_desk"))
			return false
		end

		if(self:GetCorpID() == 0) then
			// No Corp, lets create one
			net.Start("cto_CreateCorp")
				net.WriteBit(0)
			net.Send(ply)
			ply.CorpDesk = self
			ply.CTO_Selected_Desk = self
		else
			local CorpID = self:GetCorpID()
			local Corp = Corporate_Takeover:GetData(CorpID)
			if(Corp) then
				net.Start("cto_CreateCorp")
					net.WriteBit(1)
					net.WriteUInt(CorpID, 8)
				net.Send(ply)
			end
		end
	end
end

function ENT:AddMoney(amount)
	net.Start("cto_AddMoneyToCorp")
		net.WriteInt(amount, 32)
		net.WriteEntity(Entity(self:EntIndex()))
	net.Broadcast()
end

function ENT:OnRemove()
	if(self:GetCorpID() != 0) then
		local CorpID = self:GetCorpID()
		DarkRP.notify(self:Getowning_ent(), 1, 5, Corporate_Takeover:Lang("corp_lost"))
		//Corporate_Takeover:BurnCorp(CorpID)
		Corporate_Takeover:DeleteCorp(CorpID)
	end

	if(IsValid(self.chair)) then
		self.chair:Remove()
	end
end