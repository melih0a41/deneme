/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

function ENT:Initialize()
	ztm.Manhole.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

function ENT:Draw()
	self:DrawModel()
	ztm.Manhole.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ENT:Think()
	ztm.Manhole.Think(self)
	self:SetNextClientThink(CurTime())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:OnRemove()
	ztm.Manhole.OnRemove(self)
end
