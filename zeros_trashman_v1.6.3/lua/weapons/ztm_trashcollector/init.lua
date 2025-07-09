/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	ztm.TrashCollector.Initialize(self)
end

function SWEP:PrimaryAttack()
	if self:GetIsBusy() == false then
		self:SetIsBusy(true)
		self:DoPrimaryAnims()
	end

	self:SetNextPrimaryFire(CurTime() + ztm.config.TrashSWEP.level[self:GetPlayerLevel()].primaty_interval + 0.1)
end

function SWEP:DoPrimaryAnims()
	if not IsValid(self) then return end -- Safety first!
	self:SetLast_Primary(CurTime())
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- Play primary anim
	local interval = ztm.config.TrashSWEP.level[self:GetPlayerLevel()].primaty_interval
	local vm_speed = math.Clamp(0.8 / interval, 1.7, 3)
	local m_owner = self:GetOwner()
	if not IsValid(m_owner) then return end
	m_owner:GetViewModel():SetPlaybackRate(vm_speed)
	m_owner:SetAnimation(PLAYER_ATTACK1)
	ztm.TrashCollector.Primary(self)
	local timerID = "ztm_tc_primaryanim_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	zclib.Timer.Create(timerID, interval, 1, function()
		if IsValid(self) and IsValid(m_owner) then
			self:Stop_PrimaryAnims()
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

function SWEP:Stop_PrimaryAnims()
	local m_owner = self:GetOwner()
	if not IsValid(m_owner) then return end
	m_owner:GetViewModel():SetPlaybackRate(1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

	if IsValid(m_owner) and IsValid(m_owner:GetActiveWeapon()) and m_owner:GetActiveWeapon():GetClass() == "ztm_trashcollector" then
		self:PlayIdleAnim()
	end
end

function SWEP:SecondaryAttack()
	if self:GetIsBusy() == false and self:GetTrash() < ztm.config.TrashSWEP.level[self:GetPlayerLevel()].inv_cap then
		self:SetIsBusy(true)
		self:DoSecondaryAnims()
	end

	self:SetNextSecondaryFire(CurTime() + ztm.config.TrashSWEP.level[self:GetPlayerLevel()].secondary_interval)
end

function SWEP:DoSecondaryAnims()
	if not IsValid(self) then return end -- Safety first!
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) -- Play primary anim
	local m_owner = self:GetOwner()
	if not IsValid(m_owner) then return end
	m_owner:SetAnimation(PLAYER_ATTACK1)
	m_owner:EmitSound("ztm_airsuck_start")
	local timerID = "ztm_tc_secondaryanim_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID, 0.6, 1, function()
		if IsValid(self) and IsValid(m_owner) then
			ztm.TrashCollector.CollectTrash(self)
		end
	end)
end

function SWEP:Stop_SecondaryAnims()
	self.TrashIncrease = false
	local m_owner = self:GetOwner()
	self:SetIsCollectingTrash(false)

	if IsValid(m_owner) and IsValid(m_owner:GetActiveWeapon()) and m_owner:GetActiveWeapon():GetClass() == "ztm_trashcollector" then
		m_owner:GetViewModel():SetBodygroup(0, 0)
		m_owner:EmitSound("ztm_airsuck_stop")
		self:PlayIdleAnim()
	end

	self:SetIsBusy(false)
	self.LastTrashHit = CurTime() + 0.5
end

function SWEP:Think()
	if self:GetIsCollectingTrash() == true and self.LastTrashHit < CurTime() then
		local m_owner = self:GetOwner()

		if self:GetTrash() < ztm.config.TrashSWEP.level[self:GetPlayerLevel()].inv_cap and IsValid(m_owner) and m_owner:KeyDown(IN_ATTACK2) then
			ztm.TrashCollector.CollectTrash(self)
		else
			self:Stop_SecondaryAnims()
		end
	end
end

function SWEP:Deploy()
	-- Initializes the Level Data if it doesent exist allready
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	ztm.Data.Init(ply)
	self:SetPlayerLevel(ply.ztm_data.lvl)
	self:SetPlayerXP(ply.ztm_data.xp)
	ply:SetAnimation(PLAYER_IDLE)
	self:PlayDrawAnim()

	return true
end

function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end -- Safety first!
	self:SendWeaponAnim(ACT_VM_DRAW) -- Play draw anim
	local timerID = "ztm_tc_drawanim_" .. self:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

	zclib.Timer.Create(timerID, 0.64, 1, function()
		if not IsValid(self) then return end

		local ply = self:GetOwner()
		if IsValid(ply) then
			self:PlayIdleAnim()
		end
	end)
end

function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end -- Safety first!
	local m_owner = self:GetOwner()
	if not IsValid(m_owner) then return end

	self:SendWeaponAnim(ACT_VM_IDLE) -- Player idle anim
	m_owner:SetAnimation(PLAYER_IDLE)
	self:SetIsBusy(false)
end

function SWEP:Holster(swep)
	self:SendWeaponAnim(ACT_VM_HOLSTER)
	local m_owner = self:GetOwner()

	if IsValid(m_owner) and IsValid(m_owner:GetViewModel()) then
		m_owner:GetViewModel():SetBodygroup(0, 0)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

	self:SetIsCollectingTrash(false)
	self:SetIsBusy(false)
	zclib.Timer.Remove("ztm_tc_drawanim_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("ztm_tc_secondaryanim_" .. self:EntIndex() .. "_timer")
	zclib.Timer.Remove("ztm_tc_primaryanim_" .. self:EntIndex() .. "_timer")

	return true
end

function SWEP:OnRemove()
	local m_owner = self:GetOwner()

	if IsValid(m_owner) and IsValid(m_owner:GetViewModel()) then
		m_owner:GetViewModel():SetBodygroup(0, 0)
	end
end

function SWEP:ShouldDropOnDie()
	return false
end
