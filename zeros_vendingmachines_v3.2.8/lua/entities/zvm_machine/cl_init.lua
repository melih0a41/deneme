/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

function ENT:Initialize()

	zvm.Machine.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end

// Gets called once the player sees the entity again
function ENT:UpdateVisuals()
	zvm.Machine.UpdateVisuals(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

function ENT:Think()
	zvm.Machine.Think(self)
	self:SetNextClientThink(CurTime())
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnRemove()
	zvm.Machine.OnRemove(self)
end
