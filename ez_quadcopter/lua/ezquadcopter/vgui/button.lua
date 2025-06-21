local PANEL = {}

AccessorFunc(PANEL, "font", "Font")
AccessorFunc(PANEL, "text", "Text")
AccessorFunc(PANEL, "radius", "Radius")

AccessorFunc(PANEL, "select", "Select")

AccessorFunc(PANEL, "default_color", "Color")
AccessorFunc(PANEL, "hovered_color", "HoveredColor")
AccessorFunc(PANEL, "select_color", "SelectColor")

AccessorFunc(PANEL, "default_textcolor", "TextColor")
AccessorFunc(PANEL, "hovered_textcolor", "HoveredTextColor")
AccessorFunc(PANEL, "select_textcolor", "SelectTextColor")

function PANEL:Init()
    self:SetFont("EZFont20")
    self:SetText("Button")
    self:SetRadius(0)

    self:SetColor(easzy.quadcopter.colors.black04)
    self:SetHoveredColor(easzy.quadcopter.colors.black03)
    self:SetSelectColor(easzy.quadcopter.colors.black03)

    self:SetTextColor(easzy.quadcopter.colors.white04)
    self:SetHoveredTextColor(easzy.quadcopter.colors.white03)
    self:SetSelectTextColor(easzy.quadcopter.colors.white03)

    self:SetSelect(false)
end

function PANEL:Paint(w, h)
    local color = self:GetSelect() and self:GetSelectColor() or (self:IsHovered() and self:GetHoveredColor() or self:GetColor())
    local textcolor = self:GetSelect() and self:GetSelectTextColor() or (self:IsHovered() and self:GetHoveredTextColor() or self:GetTextColor())

    draw.RoundedBox(self:GetRadius() or h/2, 0, 0, w, h, color)
    draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    return true
end

vgui.Register("EZQuadcopterButton", PANEL, "DButton")
