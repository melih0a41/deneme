include("shared.lua")
include("cl_menu.lua")

function ENT:Initialize()
    self.yOffset = 0
    self.earnings = {}
    self.workEnergy = 100
    self.Corp = nil
    self.worker = nil
end

local materials = {
    Material("materials/corporate_takeover/cto_clock.png"),
    Material("materials/corporate_takeover/cto_energy.png"),
    Material("materials/corporate_takeover/cto_xp.png")
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
    if(val > max || max == 0) then
        bar = barWidth
    end

    draw.RoundedBox(0,-w/2 + x + 2,y + 2, bar,h - 4,color)
    if(val != 0 && max != 0) then
       draw.SimpleText(math.Round(val, 0)..unitFirst.."/"..math.Round(max, 0)..unitSecond, "cto_15", x, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
    else
        draw.SimpleText(string.sub(unitSecond, 7), "cto_15", x, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
    end
end

local level_lang, xp_lang, energy_lang
function ENT:PrintDesk(pos, ang, offset)
    level_lang = level_lang || Corporate_Takeover:Lang("level")
    xp_lang = xp_lang || Corporate_Takeover:Lang("xp")
    energy_lang = energy_lang || Corporate_Takeover:Lang("energy")
    
    if(self:GetWorkerEnergy() >= 99) then
        self.workEnergy = 100
    else
        self.workEnergy = Lerp(FrameTime() * 2, self.workEnergy, self:GetWorkerEnergy())
    end

    cam.Start3D2D(pos, ang, 0.15)
        local Corp = Corporate_Takeover.Corps[self:GetCorpID()]
        if(Corp) then

            local worker = Corporate_Takeover.Corps[self:GetCorpID()].workers[self:GetWorkerID()]
            local pos1, pos2, pos3 = -100, -65, -30

            if(!self.XP) then
                pos1 = -65
                pos2 = -30
            end

            if(worker && worker != 0) then


                drawBar(0,pos1,200,20, self.workEnergy, 100, "", " "..energy_lang, nil, 2)

                local tick = self:GetTickTime() - CurTime()
                if(tick < 0) then
                    tick = 0
                end


                drawBar(0,pos2,200,20, tick, Corporate_Takeover.Config.TickDelay, "s", "s", self:GetSleeping() && Corporate_Takeover.Config.Colors.Red, 1)

                if(self.XP) then
                    local xp = worker.xp
                    local level = worker.level
                    local needed = worker.xpNeeded || Corporate_Takeover.Config.XPNeededForWorkerLevel(level)

                    local xpPerc = 100 / needed * xp
                    local xpang = 360/100 * xpPerc

                    drawBar(0,pos3,200,20, xp, needed, "", " "..xp_lang.." | "..level_lang.." "..level, nil, 3) 
                end
            end 
        end

        draw.DrawText(Corporate_Takeover.Desks[self:GetDeskClass()].name, "cto_40", 0, 0, Corporate_Takeover.Config.Colors.Text, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end


function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 200 * 200 then
        return false
    end
    
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

