include("shared.lua")
include("cl_menu.lua")

function ENT:Initialize()
    self.yOffset = 0
    self.earnings = {}
end

function ENT:PrintDesk(pos, ang, offset)
    cam.Start3D2D(pos, ang, offset)
        for k, v in ipairs(self.earnings) do
            if(v.lerpText < 100) then
                self.earnings[k].lerpFade = math.Round(Lerp(FrameTime() * 2.5, self.earnings[k].lerpFade, -20), 0)
                if(self.earnings[k].lerpFade < 10) then
                    self.earnings[k].lerpFade = 0
                end
            elseif(v.lerpText > 190) then
                self.earnings[k] = nil
                continue
            end

            draw.DrawText(DarkRP.formatMoney(v.amount), "cto_30", 0, -10 + (-v.lerpText), Color(v.color.r, v.color.g, v.color.b, v.lerpFade), TEXT_ALIGN_CENTER)

            self.earnings[k].lerpText = Lerp(FrameTime() * .5, self.earnings[k].lerpText, 255)
        end

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

        self:PrintDesk(yPos, ang, 0.1)
        ang:RotateAroundAxis(ang:Right(), 180)
        self:PrintDesk(yPos, ang, 0.1)

        local CorpID = self:GetCorpID()
        local Corp = Corporate_Takeover.Corps[CorpID]
        if(Corp) then
            local money = Corp.money
            local col = (money >= 0) && Corporate_Takeover.Config.Colors.Green || Corporate_Takeover.Config.Colors.Red
            local level = Corp.level

            local font = "cto_40"
            local addY = 0

            local name = Corp.name
            local ts = #name

            if(ts > 35) then
                name = string.sub(name, 1, 33).."..."
                font = "cto_20"
                addY = 25
            elseif(ts > 28) then
                font = "cto_20"
                addY = 25
            elseif(ts > 22) then
                font = "cto_25"
                addY = 15
            elseif(ts > 17) then
                font = "cto_30"
                addY = 10
            end

            ang:RotateAroundAxis(ang:Right(), 31.75)
            cam.Start3D2D(pos + ang:Right() * -59 + ang:Forward() * 14 + ang:Up() * -25.63, ang, 0.1)
                local w, h = 75, 75
                draw.RoundedBox(0, 0, 0, w, h, Corporate_Takeover.Config.Colors.Primary)
                draw.RoundedBox(0, 2, 2, w-4, h-4, Corporate_Takeover.Config.Colors.Background)
                draw.DrawText(level, "cto_40", w/2, h/4, Corporate_Takeover.Config.Colors.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.DrawText(name, font, w/2, -50 + addY, Corporate_Takeover.Config.Colors.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end

function ENT:AddEarning(amount)
    local color = Corporate_Takeover.Config.Colors.Green

    local push_down = 0

    if(amount < 0) then
        color = Corporate_Takeover.Config.Colors.Red
        push_down = -40
    end

    table.insert(self.earnings, {
        amount = amount,
        lerpText = 0,
        lerpFade = 255,
        color = color
    })
end

net.Receive("cto_AddMoneyToCorp", function()
    local amount = net.ReadInt(32)
    local ent = net.ReadEntity()
    if(ent && ent:IsValid() && ent:GetClass() == "corporate_desk") then
        if LocalPlayer():GetPos():DistToSqr(ent:GetPos()) < 200 * 200 then
            ent:AddEarning(amount)
        end
    end
end)