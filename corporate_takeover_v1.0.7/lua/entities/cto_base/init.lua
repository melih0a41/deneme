AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(2)
	util.Effect("MetalSpark", EffectData())
end

function ENT:OnTakeDamage(damage)
	local dmg = damage:GetDamage()

	local CorpID = self.GetCorpID && self:GetCorpID()
	if(CorpID) then
		local Corp = Corporate_Takeover.Corps[CorpID]
		if(Corp) then
			local owner = player.GetBySteamID(Corp.owner)
			if(owner) then
				local deskClass = self.GetDeskClass && self:GetDeskClass() || self:GetClass()
				hook.Run("cto_corp_damaged_nonCorp", damage:GetAttacker(), self:Getowning_ent(), math.Round(damage:GetDamage(), 0), self:GetClass())
			end
		else
			hook.Run("cto_corp_damaged_nonCorp", damage:GetAttacker(), self:Getowning_ent(), math.Round(damage:GetDamage(), 0), self:GetClass())
		end
	end

	if(self.EntHealth - dmg <= 0) then
		hook.Run("cto_corp_destroyed", damage:GetAttacker(), self:Getowning_ent(), self:GetClass())
		
		self:Destruct()
		self:Remove()
	else
		self.EntHealth = self.EntHealth - dmg
	end
end
