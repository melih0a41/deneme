local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self:SetTall(Corporate_Takeover.Scale(40))
    self:SetFont("cto_20")
    self:SetTextColor(Corporate_Takeover.Config.Colors.Text)
    self:SetContentAlignment(5)
end

local bright = Corporate_Takeover.Config.Colors.BrightBackground
local dark = Corporate_Takeover.Config.Colors.Background
local red = Corporate_Takeover.Config.Colors.Red

function PANEL:DangerTheme()
    self.Danger = true
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, self.Danger and red or bright)
    draw.RoundedBox(0, 2, 2, w - 4, h - 4, self:IsHovered() and (self.Danger and red or bright) or dark)
end

vgui.Register("cto_button", PANEL, "DButton")