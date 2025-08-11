AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/freeman/vault/pvault_moneywad.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.doorUsable = true
	self.usable = true
	self.data = {}
end

function ENT:PostData()
end

local invis = Color(255, 255, 255, 0)
function ENT:Use(ply)
	if not self.usable then return end

	if perfectVault.Config.AllowAnyoneToRob then
		if perfectVault.Config.Government[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	else
		if not perfectVault.Config.Criminals[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	end

	-- Give them the money
	ply:addMoney(self.data.general.value)

	-- Stop it from being usable
	self.usable = false

	-- Apply physics and visual indications to it being unusable
	self:PhysicsInit(SOLID_NONE)
--	self:SetMaterial("models/wireframe")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(invis)

	-- Apply wanted
	if self.data.other.wanted then
		if self.data.other.smartWant then
			for k, v in pairs(player.GetAll()) do
				if perfectVault.Config.AllowAnyoneToRob then
					if perfectVault.Config.Government[ply:Team()] then continue end
				else
					if not perfectVault.Config.Criminals[ply:Team()] then continue end
				end

				if self:GetPos():Distance(v:GetPos()) < 1000 then
					v:wanted(nil, self.data.other.wantedReason)
				end
			end
		else
			ply:wanted(nil, self.data.other.wantedReason)
		end
	end

	-- Wait for it to respawn
	timer.Simple(self.data.general.respawn, function()
		-- Check if it's valid
		if not IsValid(self) then return end

		-- Reset everything
		self.usable = true
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetColor(color_white)

		local phys = self:GetPhysicsObject()
		if not IsValid(phys) then return end
		phys:EnableMotion(false)
	end)
	
	hook.Run("pVaultStackTaken", self, self.data.general.value)
end