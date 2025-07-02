AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("ezquadcopter_sync_radio_controller")

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    self.idleHorizontal = CurTime()
    self.idleVertical = CurTime()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local hand = owner:LookupBone("ValveBiped.Bip01_R_Finger2")
    if hand then
        self:FollowBone(owner, hand)
    end
end

function SWEP:PrimaryAttack()
    local quadcopter = self.quadcopter

    if not quadcopter then return end
    if not quadcopter.sound then return end

    local curTime = CurTime()

	if quadcopter.on then
        quadcopter.sound:Stop()
        quadcopter.on = false
    elseif not quadcopter.broken and quadcopter.battery > 0 then
        quadcopter.sound:Play()
        quadcopter.on = true
        quadcopter.lastBatteryRefresh = curTime
    end

	easzy.quadcopter.SyncQuadcopter(quadcopter)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    local quadcopter = self.quadcopter
    if not IsValid(quadcopter) then
        self:Remove()
    end
end

function SWEP:OnRemove()
    if IsValid(self.quadcopter) then
        self.quadcopter:Remove()
    end
end
