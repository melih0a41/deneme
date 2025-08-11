AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Sets the players model and basic physics ect..
function ENT:Initialize()
	self:SetModel("models/breen.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:SetPos(self:GetPos()+Vector(0,0,10))
    self:DropToFloor()
	self:SetTrigger(true)

	self.coolDown = 0
	self.cutWanted = 50

	self:SetHolding(0)
end

function ENT:OnTakeDamage()        
	return 0    
end

function ENT:PostData()
	self:SetModel(self.data.general.model)
	self.cutWanted = math.random(self.data.cut.minCut, self.data.cut.maxCut)/100
end

function ENT:StartTouch(ent)
	if self.coolDown > CurTime() then return end
	self.coolDown = CurTime() + 1
	
	if ent:GetClass() != "pvault_moneybag" then return end
	if ent:GetValue() <= 0 then return end

	if tobool(self.data.general.negotiate) then
		local money = self:GetHolding()
		self:SetHolding(money+ent:GetValue())
	else
		if not ent.thrower then return end
		local money = math.Round(ent:GetValue()*((100-self.data.cut.minCut)/100))
		ent.thrower:addMoney(money)
		perfectVault.Core.Msg(string.format(perfectVault.Translation.NPC.BusinessDone, DarkRP.formatMoney(money)), ent.thrower)
		hook.Run("pVaultMoneyCleaned", ent.thrower, money)
	end
	ent:Remove()
end


function ENT:AcceptInput(name, activator, caller)
	if self.coolDown > CurTime() then return end
	self.coolDown = CurTime() + 1
	
	-- Basic checks
	if activator:IsPlayer() == false then return end
	if activator:GetPos():Distance( self:GetPos() ) > 100 then return end
	if perfectVault.Config.Government[activator:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.NPCOfficer, activator) return end
	if activator:isCP() then perfectVault.Core.Msg(perfectVault.Translation.Chat.NPCOfficer, activator) return end

	if not perfectVault.Config.AllowAnyoneToRob then
		if not perfectVault.Config.Criminals[activator:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.NPCCiv, activator) return end
	end

	if self:GetHolding() <= 0 then perfectVault.Core.Msg(perfectVault.Translation.Chat.NPCNoMoney, activator) return end

	net.Start("pvault_ui_sell")
		net.WriteEntity(self)
	net.Send(activator)
end