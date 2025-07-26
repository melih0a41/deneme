local PANEL = {}

function PANEL:Init()
    self:SetTall(Corporate_Takeover.Scale(40))
    self:SetFont("cto_20")
end

local highlight = Color(30, 130, 255)

function PANEL:Paint(w, h)
    draw.RoundedBox(0,0,0,w,h,Corporate_Takeover.Config.Colors.BrightBackground)
    self:DrawTextEntryText(Corporate_Takeover.Config.Colors.Text, highlight, Corporate_Takeover.Config.Colors.Text)
end

vgui.Register("cto_textentry", PANEL, "DTextEntry")