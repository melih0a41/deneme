include("shared.lua")
include("cl_menu.lua")

local circleMaterial = Material("vgui/white")

function ENT:Initialize()
    self.yOffset = 0
    self.earnings = {}
    self.workEnergy = 100
    self.Corp = nil
    self.worker = nil
    self.tickLerp = 0
end

local materials = {
    Material("materials/corporate_takeover/cto_clock.png"),
    Material("materials/corporate_takeover/cto_energy.png"),
    Material("materials/corporate_takeover/cto_xp.png")
}

function ENT:drawBar(x, y, w, h, val, max, unitFirst, unitSecond, color, icon)
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
    if(val >= max) then
        bar = barWidth
    end

    draw.RoundedBox(0,-w/2 + x + 2,y + 2, bar,h - 4,color)

    draw.SimpleText(math.Round(val, 0)..unitFirst.."/"..math.Round(max, 0)..unitSecond, "cto_15", x, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local color_lightblue = Color(255, 128, 0)
local lang
function ENT:drawBarResearch(x, y, w, h, val, max, color, icon, name)
    lang = lang || Corporate_Takeover:Lang("research_waiting")

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
    if(val >= max) then
        bar = barWidth
    end

    local text = string.FormattedTime(math.Round((val), 1), "%02i:%02i")
    if(name != "") then
        local rname = Corporate_Takeover:Lang(name)
        if(#rname > 23) then
            rname = string.sub(rname, 0, 23).."..."
        end
        text = text.." ("..rname..")"
    end

    if(val == 0 && max == 0) then
        color = color_lightblue
        text = "..."
    end

    draw.RoundedBox(0,-w/2 + x + 2,y + 2, bar,h - 4,color)

    draw.SimpleText(text, "cto_15", x, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:PrintDesk(pos, ang, offset)
    if(self:GetWorkerEnergy() >= 99) then
        self.workEnergy = 100
    else
        self.workEnergy = Lerp(FrameTime() * 2, self.workEnergy, self:GetWorkerEnergy())
    end

    cam.Start3D2D(pos, ang, 0.15)
        local Corp = Corporate_Takeover.Corps[self:GetCorpID()]
        if(Corp) then

            local worker = Corporate_Takeover.Corps[self:GetCorpID()].workers[self:GetWorkerID()]

            if(worker && worker != 0) then


                self:drawBar(-0,-65,200,20, self.workEnergy, 100, "", " Energy", nil, 2)

                local tick = self:GetTickTime()
                if(tick < 0) then
                    tick = 0
                end

                local name = ""
                if(self:GetResearchingItem() != "") then
                    name = self:GetResearchingItem()
                end

                if(self.tickLerp == 0 && tick != 0) then
                    self.tickLerp = tick
                end

                self.tickLerp = Lerp(FrameTime() * 2, self.tickLerp, tick)
                if(tick == 0) then
                    self.tickLerp = 0
                end

                self:drawBarResearch(0,-30,200,20, self.tickLerp, self:GetTickTimeMax(), self:GetSleeping() && Corporate_Takeover.Config.Colors.Red, 1, name)
            end 
        end

        draw.DrawText(Corporate_Takeover.Desks[self:GetDeskClass()].name, "cto_40", 1, 1, Corporate_Takeover.Config.Colors.Primary, TEXT_ALIGN_CENTER)
        draw.DrawText(Corporate_Takeover.Desks[self:GetDeskClass()].name, "cto_40", 0, 0, Corporate_Takeover.Config.Colors.Text, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end


function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 200 * 200 then
        local pos = self:GetPos()
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Forward(), 90)

        self.yOffset = Lerp(FrameTime() * 4, self.yOffset, math.sin(CurTime()) * 2)

        local yPos = pos + ang:Right() * (-70 + self.yOffset) + ang:Up() * 16.5

        ang:RotateAroundAxis(ang:Right(), 180)

        local plyAng = LocalPlayer():GetAngles().y

        self:PrintDesk(yPos, Angle(ang.x, plyAng - 90, ang.z), 0.1)

        local namePos = pos + ang:Up() * -10 + ang:Right() * -8.5 + ang:Forward() * 37

        ang:RotateAroundAxis(ang:Forward(), -20)

        cam.Start3D2D(namePos, ang, 0.02)
            draw.DrawText(self:GetWorkerName(), "cto_40", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()

    end
end

