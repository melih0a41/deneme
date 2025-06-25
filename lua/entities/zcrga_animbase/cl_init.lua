/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c342b127afdf542b621f89d5d7f1fe28190f83a669677e45d028bc5b66d3917c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

function ENT:Think()
	self:SetNextClientThink(CurTime())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 049b4e254ea84b6bbd8714673e122cc1e8af2018030f6cc079898e33e35e9c0c

	return true
end
