include("shared.lua")

function ENT:Initialize()
    self.yOffset = 0
end
local key = input.LookupBinding("+use") || "E"

local text = ""

function ENT:Draw()
    if(text == "") then
        text = Corporate_Takeover:Lang("asleep")
        text = string.Replace(text, "%key", string.upper(key))
    end

    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 200 * 200 then
        local pos = self:GetPos()
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Forward(), 90)

        self.yOffset = Lerp(FrameTime() * 4, self.yOffset, math.sin(CurTime()) * 2)

        local yPos = pos + ang:Right() * (-60 + self.yOffset) + ang:Up() * 3

        local plyAng = LocalPlayer():GetAngles().y

	    cam.Start3D2D(yPos, Angle(ang.x, plyAng -90, ang.z), 0.1)
	        if(self:GetAsleep()) then
	        	draw.DrawText(text, "cto_20", 1, 1, Corporate_Takeover.Config.Colors.Primary, TEXT_ALIGN_CENTER)
	        	draw.DrawText(text, "cto_20", 0, 0, Corporate_Takeover.Config.Colors.Text, TEXT_ALIGN_CENTER)
	        end
	    cam.End3D2D()


    end
end