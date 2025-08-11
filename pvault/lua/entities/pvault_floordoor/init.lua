AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/freeman/vault/floor_safe_door.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetAutomaticFrameAdvance(true)
	self:SetPlaybackRate(1)

	local seq = self:LookupSequence("close")
	self:ResetSequence(seq)

	self.doorUsable = true
	self.cooldown = 0
	self.data = {}
end

function ENT:PostData()
	self:SetRobable(true)
	self:SetMoneybags(tonumber(self.data.general.bagStart))
	self:SetLocked(true)
	self:SetAlarm(false)
	self:SetCooldownEnd(0)
	self:SetOpenTimeLeft(0)

	timer.Create("pvault_newbag_"..self:EntIndex(), tonumber(self.data.general.newBagTimer), 0, function()
		if not IsValid(self) then return end
		local count = self:GetMoneybags()
		if count >= tonumber(self.data.general.bagCount) then return end

		self:SetMoneybags(count+1)
	end)
end

function ENT:Think() -- Used so that the animation runs at the correct FPS
	self:NextThink(CurTime())
	return true
end

function ENT:Unlock()
	self:SetLocked(false)
	timer.Remove("pvault_newbag_"..self:EntIndex())

	local seq = self:LookupSequence("open")
	self:ResetSequence(seq)

	self:EmitSound("doors/metal_move1.wav")

	timer.Simple(1.8, function()
		if not IsValid(self) then return end
		self:EmitSound("doors/gate_move1.wav")
	end)

	self.doorUsable = false
	timer.Simple(4.5, function()
		if not IsValid(self) then return end
		local seq = self:LookupSequence("openidle")
		self:ResetSequence(seq)
		self.doorUsable = true
	end)

	self:SetOpenTimeLeft(CurTime() + self.data.general.openTime)
	timer.Create("pvault_opentimeleft_"..self:EntIndex(), tonumber(self.data.general.openTime), 1, function()
		if not IsValid(self) then return end
		self:Lock()
		self:RobberyCooldown()
	end)
end

function ENT:Lock()
	self:SetLocked(true)
	timer.Create("pvault_newbag_"..self:EntIndex(), tonumber(self.data.general.newBagTimer), 0, function()
		if not IsValid(self) then return end
		local count = self:GetMoneybags()
		if count >= tonumber(self.data.general.bagCount) then return end

		self:SetMoneybags(count+1)
		timer.Simple(0.1, function()
			if not IsValid(self) then return end
			net.Start("pvault_vault_updatebags")
				net.WriteEntity(self)
			net.Broadcast()
		end)
	end)

	local seq = self:LookupSequence("close")
	self:ResetSequence(seq)

		self:EmitSound("doors/gate_move1.wav")

	timer.Simple(2, function()
		if not IsValid(self) then return end
		self:EmitSound("doors/metal_move1.wav")
	end)

	self.doorUsable = false
	timer.Simple(3.5, function()
		if not IsValid(self) then return end
		local seq = self:LookupSequence("closedidle")
		self:ResetSequence(seq)

		self.doorUsable = true
	end)
	
	hook.Run("pVaultVaultClosed", self)
end

function ENT:AlarmOn()
	self:SetRobable(false)
	self:SetAlarm(true)

	sound.Add( {
		name = "pvault_alarm",
		channel = CHAN_STREAM,
		volume = 1.0,
		level = 80,
		pitch = {95, 110},
		sound = perfectVault.Config.AlarmSound
	})

	self:EmitSound("pvault_alarm")

	timer.Simple(tonumber(self.data.alarm.lasts), function()
		if not IsValid(self) then return end
		self:AlarmOff()
	end)
end

function ENT:AlarmOff()
	self:SetAlarm(false)
	self:StopSound("pvault_alarm")
end

function ENT:RobberyCooldown()
	self:SetRobable(false)
	self:SetCooldownEnd(CurTime()+self.data.general.cooldown)
	timer.Create("pvault_cooldown_"..self:EntIndex(), self.data.general.cooldown, 1, function()
		if not IsValid(self) then return end
		self:SetRobable(true)
	end)
end

function ENT:Use(ply)
	if self.cooldown > CurTime() then return end
	self.cooldown = CurTime() + 1

	perfectVault.Core.RobEnt(self, ply)
end

function ENT:StartTouch(ent)
	if ent:GetClass() != "pvault_moneybag" then return end
	if ent.cooldown > CurTime() then return end

	if self:GetMoneybags() < tonumber(self.data.general.bagCount) then
		self:SetMoneybags(self:GetMoneybags()+1)
	end

	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		net.Start("pvault_vault_updatebags")
			net.WriteEntity(self)
		net.Broadcast()
	end)
	ent:Remove()
end

function ENT:OnRemove()
	self:AlarmOff()
end