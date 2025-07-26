include("shared.lua")
include("cl_menu.lua")

function ENT:Initialize()
    self.yOffset = 0
end

local materials = {
    Material("materials/corporate_takeover/cto_money.png")
}

local function drawBar(x, y, w, h, val, max, unitFirst, unitSecond, color, icon)
    color = color || Corporate_Takeover.Config.Colors.Primary
    icon = materials[icon]

    x = x + ((h*1.5)/2)
    // Bar background
    draw.RoundedBox(0,-w/2 + x,y,w,h,Corporate_Takeover.Config.Colors.BrightBackground)
    draw.RoundedBox(0,-w/2 + x + 2,y + 2,w - 4,h - 4,Corporate_Takeover.Config.Colors.Background)

    // Icon background
    draw.RoundedBox(0,0-w/2 - ((h*1.5)/2) ,y-h*.25,h*1.5,h*1.5,Corporate_Takeover.Config.Colors.BrightBackground)
    draw.RoundedBox(0,0-w/2 - ((h*1.5)/2) +2,y-h*.25 + 2,h*1.5-4,h*1.5-4,Corporate_Takeover.Config.Colors.Background)

    // Icon
    surface.SetDrawColor(color_white)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(-w/2 - ((h*1.5)/2) +2, y-h*.25 + 2, h*1.5-4, h*1.5-4)

    local barWidth = w - 4
    local bar = (barWidth / max) * val
    if(val < 0) then
        bar = 0
    end

    draw.RoundedBox(0,-w/2 + x + 2,y + 2, bar,h - 4,color)
    draw.SimpleText(DarkRP.formatMoney(math.Round(val, 0)).."/"..DarkRP.formatMoney(math.Round(max, 0)), "cto_15", x, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:PrintDesk(pos, ang, offset)
    cam.Start3D2D(pos, ang, offset)
        draw.DrawText(Corporate_Takeover.Desks[self:GetDeskClass()].name, "cto_40", 0, 0, color_white, TEXT_ALIGN_CENTER)
    
        local CorpID = self:GetCorpID()
        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            local money = Corp.money
            local max = Corp.maxMoney
            local perc = (100 / max) * money

            drawBar(0, -40, 200, 30, money, max, "", "", Corporate_Takeover.Config.Colors.Primary, 1)
        end

    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 200 * 200 then
        local pos = self:GetPos()
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        self.yOffset = Lerp(FrameTime() * 4, self.yOffset, math.sin(CurTime()) * 2)
        local yPos = pos + ang:Right() * (-70 + self.yOffset) + ang:Up() * 16.5
        local plyAng = LocalPlayer():GetAngles().y

        self:PrintDesk(yPos, Angle(ang.x, plyAng - 90, ang.z), 0.1)
    end
end