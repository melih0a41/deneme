AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/freeman/duffel_bag.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self.cooldown = 0
	self:SetValue(0)
end

function ENT:Use(ply)
	if not perfectVault.Core.ActiveBags[ply:SteamID64()] then
		perfectVault.Core.ActiveBags[ply:SteamID64()] = {}
	end

	if #perfectVault.Core.ActiveBags[ply:SteamID64()] >= perfectVault.Config.MaxBagCarry then
		perfectVault.Core.Msg(perfectVault.Translation.Chat.CarryingMax, ply)
		return
	end

	table.insert(perfectVault.Core.ActiveBags[ply:SteamID64()], {color = self:GetColor(), amount = self:GetValue()})

	net.Start("pvault_update_ply_bags")
		net.WriteEntity(ply)
		net.WriteInt(#perfectVault.Core.ActiveBags[ply:SteamID64()], 32)
	net.Broadcast()

	if perfectVault.Config.MoneybagWalkSpeed then
		if not ply.pv_walkSpeed then ply.pv_walkSpeed = ply:GetWalkSpeed() end
		ply:SetWalkSpeed(perfectVault.Config.MoneybagWalkSpeed)
	end
	if perfectVault.Config.MoneybagRunSpeed then
		if not ply.pv_runSpeed then ply.pv_runSpeed = ply:GetRunSpeed() end
		ply:SetRunSpeed(perfectVault.Config.MoneybagRunSpeed)
	end

	self:Remove()
end