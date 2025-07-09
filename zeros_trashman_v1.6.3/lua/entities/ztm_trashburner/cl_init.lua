/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

function ENT:Initialize()
	ztm.Trashburner.Initialize(self)
end

function ENT:Draw()
	self:DrawModel()
	ztm.Trashburner.Draw(self)
end

function ENT:Think()
	ztm.Trashburner.Think(self)
	self:SetNextClientThink(CurTime())

	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:UpdateVisuals()
	ztm.Trashburner.UpdateVisuals(self)
end

function ENT:Remove()
	ztm.Trashburner.Remove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
