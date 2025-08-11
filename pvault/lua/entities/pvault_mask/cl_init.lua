include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	if LocalPlayer():GetPos():Distance( self:GetPos() ) > 500 then return end	
	-- Basic setups
	local Pos = self:GetPos()
    local Ang = LocalPlayer():EyeAngles()
    local centerx, centery = 0, -160
	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), 90 )

	cam.Start3D2D(Pos, Ang, 0.07)
		draw.SimpleText(perfectVault.Translation.Mask.Overhead, "_pvault70", centerx, centery, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end
