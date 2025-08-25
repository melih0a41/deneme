include("shared.lua")

surface.CreateFont("dex_AssassinText", {
    font = "Impact",
    size = 32,
    weight = 500,
    antialias = true,
    additive = false
})

surface.CreateFont("dex_AssassinTimer", {
    font = "Impact",
    size = 64,
    weight = 500,
    antialias = true,
    additive = false
})

local colorDarkRed     = Color(40, 0, 0, 200)
local colorMidRed      = Color(80, 0, 0, 30)
local colorLightRed    = Color(120, 0, 0, 50)
local colorBrightRed   = Color(255, 50, 50)
local colorGrayText    = Color(200, 200, 200)

net.Receive("dex_bag_removetime", function()
    local ent = net.ReadEntity()
    local removetime = net.ReadFloat()

    if not IsValid(ent) then return end
    ent.RemoveTime = removetime
end)

function ENT:Draw()
    self:DrawModel()

    local removeTime = self.RemoveTime or 0
    if removeTime > 0 then
        local timeleft = math.max(0, removeTime - CurTime())
        local pos = self:GetPos() + Vector(10, 0, 20)
        local ang = EyeAngles()
        ang.p = 0
        ang.r = 0
        ang.y = ang.y - 90

        local scale = 1
        if timeleft < 5 then
            scale = 1 + (math.sin(CurTime() * 10) * 0.1)
        end

        local secondsText = DEX_LANG.Get("seconds") or "seconds"

        surface.SetFont("dex_AssassinText")
        local textW, textH = surface.GetTextSize(secondsText)

        local baseW = math.max(100, textW + 40)
        local baseH = 80

        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.15 * scale)
            draw.RoundedBox(8, -baseW / 2, -baseH / 2, baseW, baseH, colorDarkRed)
            draw.RoundedBox(8, -baseW / 2, -baseH / 2, baseW, baseH, colorMidRed)
            draw.RoundedBox(0, -baseW / 2 + 2, -baseH / 2 + 2, baseW - 4, baseH - 4, colorLightRed)

            draw.SimpleText(string.format("%.1f", timeleft), "dex_AssassinTimer", 0, -15, 
                colorBrightRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText(secondsText, "dex_AssassinText", 0, 25, 
                colorGrayText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end
