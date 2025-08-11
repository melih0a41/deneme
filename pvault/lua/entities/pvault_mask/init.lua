AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if perfectVault.Config.HalloweenModels then
		self:SetModel("models/freeman/vault/owain_pumpkin.mdl")
	else
		self:SetModel("models/freeman/vault/owain_hockeymask_prop.mdl")
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:Use(ply)
	if perfectVault.Core.HasMask[ply:SteamID64()] then
		perfectVault.Core.Msg(perfectVault.Translation.Chat.AlreadyHasAMask, ply)
		return
	end

	perfectVault.Core.HasMask[ply:SteamID64()] = true
	perfectVault.Core.MaskOn[ply:SteamID64()] = true

	perfectVault.Core.Msg(perfectVault.Translation.Chat.PickedUpMask, ply)

	net.Start("pvault_update_mask")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.WriteBool(false)
	net.Broadcast()

	self:Remove()
end
