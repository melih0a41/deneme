/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(zlm.config.NPC.Model)
	self:SetSolid(SOLID_BBOX)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetHullType(HULL_HUMAN)
	self:SetUseType(SIMPLE_USE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

	self:SetMaxYawSpeed(90)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	if zlm.config.NPC.Capabilities then
		self:CapabilitiesAdd(CAP_ANIMATEDFACE)
		self:CapabilitiesAdd(CAP_TURN_HEAD)
	end

	zlm.f.NPC_Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) and zlm.f.InDistance(ply:GetPos(), self:GetPos(), 100) then
		self.lastUsed = CurTime() + 0.25
		zlm.f.NPC_USE(self, ply)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:RefreshBuyRate()
	self:SetPriceModifier(math.random(zlm.config.NPC.MinBuyRate, zlm.config.NPC.MaxBuyRate))
end
