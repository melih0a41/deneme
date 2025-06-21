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
    self:SetRadius(8) -- Rounded corners

    -- Modern color scheme
    self:SetColor(Color(0, 123, 255, 255)) -- Primary blue
    self:SetHoveredColor(Color(0, 86, 179, 255)) -- Darker blue on hover
    self:SetSelectColor(Color(40, 167, 69, 255)) -- Green for selected

    self:SetTextColor(Color(255, 255, 255))
    self:SetHoveredTextColor(Color(255, 255, 255))
    self:SetSelectTextColor(Color(255, 255, 255))

    self:SetSelect(false)
    
    -- Animation variables
    self.lerpColor = self:GetColor()
    self.animStartTime = 0
    self.animDuration = 0.15
end

function PANEL:OnCursorEntered()
    self.animStartTime = SysTime()
    self.startColor = self.lerpColor
    self.targetColor = self:GetSelect() and self:GetSelectColor() or self:GetHoveredColor()
end

function PANEL:OnCursorExited()
    self.animStartTime = SysTime()
    self.startColor = self.lerpColor
    self.targetColor = self:GetSelect() and self:GetSelectColor() or self:GetColor()
end

function PANEL:Paint(w, h)
    -- Smooth color animation
    if self.startColor and self.targetColor then
        local elapsed = SysTime() - self.animStartTime
        local progress = math.min(elapsed / self.animDuration, 1)
        
        -- Smooth easing function
        progress = progress * progress * (3 - 2 * progress)
        
        self.lerpColor = Color(
            Lerp(progress, self.startColor.r, self.targetColor.r),
            Lerp(progress, self.startColor.g, self.targetColor.g),
            Lerp(progress, self.startColor.b, self.targetColor.b),
            255
        )
    else
        local color = self:GetSelect() and self:GetSelectColor() or (self:IsHovered() and self:GetHoveredColor() or self:GetColor())
        self.lerpColor = color
    end
    
    local textcolor = self:GetSelect() and self:GetSelectTextColor() or (self:IsHovered() and self:GetHoveredTextColor() or self:GetTextColor())

    -- Button shadow
    draw.RoundedBox(self:GetRadius(), 2, 2, w, h, Color(0, 0, 0, 30))
    
    -- Main button
    draw.RoundedBox(self:GetRadius(), 0, 0, w, h, self.lerpColor)
    
    -- Subtle highlight on top
    if not self:GetSelect() then
        draw.RoundedBoxEx(self:GetRadius(), 0, 0, w, h/3, Color(255, 255, 255, 15), true, true, false, false)
    end
    
    -- Text with shadow
    draw.SimpleText(self:GetText(), self:GetFont(), w/2 + 1, h/2 + 1, Color(0, 0, 0, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    return true
end

vgui.Register("EZQuadcopterButton", PANEL, "DButton")