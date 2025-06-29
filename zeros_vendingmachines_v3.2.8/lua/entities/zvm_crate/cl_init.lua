/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
	self.LastProcess = -1
	self.HSize = 300
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

local pos_offset = Vector(0, 0, 4)
local ang_offset = Angle(0,0,0)

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(pos_offset), self:LocalToWorldAngles(ang_offset), 0.05)
		local _progress = self:GetProgress()
		if _progress > 0 then
			local _size = 300 - (300 / 5) * _progress
			self.HSize = math.Clamp(self.HSize + (300 / 1) * FrameTime(), 0, _size)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

			draw.RoundedBox(150, -150, -150, 300, 300, zclib.colors["black_a100"])
			draw.RoundedBox(150, -self.HSize / 2, -self.HSize / 2, self.HSize, self.HSize, zvm.colors["blue02"])
		end
	cam.End3D2D()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff
