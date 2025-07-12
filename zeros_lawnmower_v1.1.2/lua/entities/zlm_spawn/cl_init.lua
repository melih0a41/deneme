/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

include("shared.lua")


function ENT:Draw()
	//self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

	if zlm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		self:DrawInfo()
	end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

local pos_offset = Vector(0,0,0)
local ang_offset = Angle(0,90,0)

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(pos_offset), self:LocalToWorldAngles(ang_offset), 0.1)
		surface.SetDrawColor(zlm.default_colors["white01"])
		surface.SetMaterial(zlm.default_materials["spawn_indicator"])
		surface.DrawTexturedRect(-1000, -1000, 2000, 2000)
	cam.End3D2D()
end


function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
