/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

function ENT:Draw()
	self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	if zlm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:DrawInfo()
	local Pos = self:GetPos() + self:GetUp() * 105
	Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime()) * 1)
	local Ang = Angle(0, EyeAngles().y - 90, 90)
	cam.Start3D2D(Pos, Ang, 0.1)
		--draw.SimpleText(self:GetGrassCount() .. zlm.config.UoW, "zlm_grassbuyer_font02", 0, -125, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(zlm.language.General["GrassBuyerTitle"], "zlm_grassbuyer_font01_shadow", 0, 27, zlm.default_colors["black01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(zlm.language.General["GrassBuyerTitle"], "zlm_grassbuyer_font01", 0, 27, zlm.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("⇩", "zlm_grassbuyer_font02", 0, 200, zlm.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
