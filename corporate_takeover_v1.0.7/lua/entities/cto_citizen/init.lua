AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:SetMaxYawSpeed(90)

    self.sequence = "sitchair1"
    self.gender = "female"
    self.desk = nil

    self.useDelay = CurTime()

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetAsleep(false)
end

function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        if(self.useDelay > CurTime()) then return end
        self.useDelay = CurTime() + 1

        if(self.desk && IsValid(self.desk)) then
            if(self.desk:GetSleeping()) then
                local energy = self.desk:GetWorkerEnergy()
                if(energy < 20) then
                    local message = Corporate_Takeover:Lang("too_tired")
                    message = string.Replace(message, "%name", self.desk:GetWorkerName())
                    DarkRP.notify(activator, 1, 5, message)
                else
                    local ind = #Corporate_Takeover.Config.Sounds.sorry[self.gender]
                    local snd = Corporate_Takeover.Config.Sounds.sorry[self.gender][math.random(1, ind)]
                    self:EmitSound(snd)
                    self.desk:SetSleeping(false)
                    self.desk:SetWorking(true)
                    self.sequence = "sitchair1"
                    self:SetAsleep(false)
                end
            end
        end
    end
end

function ENT:Think()
    self:SetSequence(self.sequence || "sitchair1")
end

function ENT:OnTakeDamage()
    return true
end