include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	local ang = self:GetAngles();

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), -90)
	local centerx, centery = 0, -30

	cam.Start3D2D(self:GetPos()+self:GetUp()*80, Angle(0, self:GetAngles().y+90, 90), 0.07)
		draw.RoundedBox(0, centerx-350, centery, 700, 130, Color(0, 0, 0, 200))
		draw.RoundedBox(0, centerx-350, centery, 700, 20, Color(0, 0, 0, 200))
		draw.SimpleText(perfectVault.Translation.NPC.Overhead, "_pvault120", centerx, centery+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
	cam.Start3D2D(self:GetPos()+self:GetUp()*80, Angle(180, self:GetAngles().y+90, -90), 0.07);
		draw.SimpleText(perfectVault.Translation.NPC.Overhead, "_pvault120", centerx, centery+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end