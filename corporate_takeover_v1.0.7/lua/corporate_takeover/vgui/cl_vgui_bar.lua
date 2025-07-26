local PANEL = {}

function PANEL:Init()
    self:SetText("0 / 0")
    self:SetFont("cto_20")
    self:SetTextColor(Corporate_Takeover.Config.Colors.Text)
    self:SetContentAlignment(5)

    self.current = 0
    self.max = 0
    self.percent = 0
    self.Cooldown = CurTime()
    self.Lerp = 0
    self.addText = ""
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Corporate_Takeover.Config.Colors.BrightBackground)
    draw.RoundedBox(0, 2, 2, w - 4, h - 4, Corporate_Takeover.Config.Colors.Background)

    self.Lerp = Lerp(FrameTime() * 10, self.Lerp, self.percent)

    local barWidth = w - 4

    local bar = barWidth * self.Lerp
    if(bar < 0) then
        bar = 0
    end

    if(bar > barWidth) then
        bar = barWidth
    end

    draw.RoundedBox(0, 2, 2, bar, h - 4, Corporate_Takeover.Config.Colors.Primary)
end

function PANEL:UpdateValues(current, max)
    self.current = current
    self.max = max
end

function PANEL:AddText(text)
    self.addText = text
end

function PANEL:Update()
    if(self.current and self.max) then
        self.percent = (1 / self.max) * self.current
        self:SetText(self.addText..self:FormatText(self.current) .. " / " .. self:FormatText(self.max))
    end
end

function PANEL:Think()
    if(self.Cooldown > CurTime()) then return end
    self.Cooldown = CurTime() + 0.5

    if(self.FetchValues) then
        self:FetchValues()
    end

    self:Update()
end

function PANEL:FormatText(text)
    return text
end

vgui.Register("cto_bar", PANEL, "DLabel")