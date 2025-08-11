ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "VoidCases NPC"
ENT.Category = "VoidCases"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AdminSpawnable = true

--[[---------------------------------------------------------
	Name: Entity
-----------------------------------------------------------]]

function ENT:Draw()

	self:DrawModel()
	local offset = Vector( 0, 0, 80 )
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset + ang:Up()

	local text = "VoidCases"

	surface.SetFont("VoidUI.R18")
	local width, height = surface.GetTextSize(text)
	local br = 8 -- space outline for text

	local myPos = LocalPlayer():GetPos()
	if myPos:DistToSqr(pos) > 800 * 800 then return end

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local boxWidth = width + (2 * br) + 32

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
		draw.RoundedBox(20, -boxWidth / 2, -br, boxWidth, height + (2 * br), VoidCases.AccentColor)
		draw.SimpleText(text, "VoidUI.R24", 0, height / 2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
