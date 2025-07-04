include("shared.lua")

local bUse2d3d = gScooters.Config.Use3d2d
local sName = gScooters:GetPhrase("retriever")

local iHeight = 60
local iMargin = 4
local iIconWidth = 60
local cBGcolor = Color(10, 10, 10, 180)	
local mIconStore = Material("gScooters/retriever.png")

function ENT:Draw()
	self:DrawModel()

	local vPos = self:GetPos()
	
	if bUse2d3d then
		local iDistSqr = LocalPlayer():GetPos():DistToSqr(vPos)

		self.Lerp = self.Lerp or 0

		if iDistSqr < 130000 then 
			self.Lerp = Lerp(0.05, self.Lerp, 1)
		else
			self.Lerp = Lerp(0.05, self.Lerp, 0)
		end

		if iDistSqr < 180000 then 
			surface.SetFont("gScooters.Font.LargeText")
			local iTextW, iTextH = surface.GetTextSize(sName)
			local iWidth = (iMargin*4) + iTextW + iIconWidth
			local iZero = (iWidth/2)*-1
			local iMax = (iWidth/2)

			local aAng = self:GetAngles()

			cam.Start3D2D(vPos + aAng:Up()*78, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)	
			
			surface.SetAlphaMultiplier(self.Lerp)

			draw.RoundedBox(10, iZero, 0, iWidth - iIconWidth, iHeight, cBGcolor)

			draw.RoundedBox(10, iMax - iIconWidth + iMargin, 0, iIconWidth, iHeight, cBGcolor)

			draw.SimpleText(sName, "gScooters.Font.LargeText", iZero + iMargin, 0, color_white)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(mIconStore)
			surface.DrawTexturedRect(iMax - iIconWidth + iMargin + 4, 4, iIconWidth - 8, iIconWidth - 8)

			surface.SetAlphaMultiplier(1)

			cam.End3D2D()
		end -- ad5bc2e066fcd4695f5419fe126f29017883f120d6f9ddaf626e263b05ab77bf
	end
end

