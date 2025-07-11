/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

	return ent
end

function ENT:Initialize()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

	self.Vehicle = ents.Create("prop_vehicle_jeep")
	self.Vehicle:SetKeyValue("solid", 6)
	self.Vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/zerochain/zlm_tractor.txt")
	self.Vehicle:SetKeyValue("model", "models/zerochain/props_lawnmower/zlm_tractor.mdl")
	self.Vehicle:SetPos(self:GetPos())
	self.Vehicle:SetAngles(self:GetAngles())
	self.Vehicle:Spawn()
	self.Vehicle:Activate()

	if zlm.config.LawnMower.NoCollide then
		self.Vehicle:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	else
		self.Vehicle:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
	//self.Vehicle.PhysgunDisabled = true
	self:SetVehicleEnt(self.Vehicle)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

	self:SetModel("models/props_junk/metal_paintcan001a.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.Vehicle.zlm_LawnMower = self

	self:SetPos(self.Vehicle:LocalToWorld(Vector(0, 5, 25)))
	self:DrawShadow(false)
	self:StartMotionController()

	self:SetParent(self.Vehicle)
	constraint.NoCollide(self.Vehicle, self)

	self.Vehicle:SetBodygroup(1,1)
	self.Vehicle:SetBodygroup(2,1)

	zlm.f.Add_Tractor(self)
	self.LastFuelConsume = 0
	self.LastMowe = 0
	self.LastMowPos = self:GetPos()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	zlm.f.EntList_Add(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnRemove()
	if IsValid(self.Vehicle) then
		self.Vehicle:Remove()
	end
end

function ENT:Think()
	if zlm.f.VCMod_Installed() and CurTime() > self.LastFuelConsume then

		if self:GetIsRunning() and self:GetIsMowing() and IsValid(self.Vehicle) then
			if self.Vehicle:VC_fuelGet(true) <= 0 then
				zlm.f.Stop_Mowing(self)
			else
				self.Vehicle:VC_fuelConsume(zlm.config.LawnMower.Fuel.fc_amount)
			end
		end

		self.LastFuelConsume = CurTime() + zlm.config.LawnMower.Fuel.fc_time
	end

	if self.Vehicle:IsVehicleBodyInWater() and self:GetIsRunning() then
		zlm.f.CrashedInWater(self)
	end

	self:NextThink(CurTime() + 1)
	return true
end
