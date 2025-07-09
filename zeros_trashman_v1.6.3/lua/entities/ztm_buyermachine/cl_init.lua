/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	if ztm.Buyermachine then
		ztm.Buyermachine.Initialize(self)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	if ztm.Buyermachine then
		ztm.Buyermachine.Draw(self)
	end
end

function ENT:Think()
	if ztm.Buyermachine then
		ztm.Buyermachine.Think(self)
	end
	self:SetNextClientThink(CurTime())

	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:OnRemove()
	if ztm.Buyermachine then
		ztm.Buyermachine.OnRemove(self)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
