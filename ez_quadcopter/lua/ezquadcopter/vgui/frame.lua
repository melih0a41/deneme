local PANEL = {}

AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "textcolor", "TextColor")

function PANEL:Init()
    local scrW = ScrW()
    local scrH = ScrH()

    self:SetPos(0, 0)
    self:SetSize(scrW, scrH)
    self:Center()
    self:SetColor(Color(15, 15, 15, 220)) -- Modern dark background
    self:SetTextColor(Color(255, 255, 255))

    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()

    self:LoadQuitButton()
end

function PANEL:LoadQuitButton()
    local quitMargin = easzy.quadcopter.RespY(15)
    local quitSize = easzy.quadcopter.RespY(40)

    -- Modern padding
    self:DockPadding(0, quitMargin + quitSize, 0, 0)

    local quit = vgui.Create("DButton", self)
    quit:SetSize(quitSize, quitSize)
    quit:SetPos(self:GetWide() - quitSize - quitMargin, quitMargin)
    quit:SetText("")
    quit.DoClick = function()
        self:Remove()
    end
    quit.Paint = function(s, w, h)
        -- Modern close button with hover effect
        local color = s:IsHovered() and Color(220, 53, 69) or Color(108, 117, 125)
        
        draw.RoundedBox(8, 0, 0, w, h, color)
        
        -- X symbol
        surface.SetDrawColor(255, 255, 255, 255)
        local thickness = 3
        local margin = w * 0.25
        
        -- Draw X lines
        surface.DrawLine(margin, margin, w - margin, h - margin)
        surface.DrawLine(margin + 1, margin, w - margin + 1, h - margin)
        surface.DrawLine(margin, margin + 1, w - margin, h - margin + 1)
        
        surface.DrawLine(w - margin, margin, margin, h - margin)
        surface.DrawLine(w - margin - 1, margin, margin - 1, h - margin)
        surface.DrawLine(w - margin, margin + 1, margin, h - margin + 1)

        return true
    end

    self.quit = quit
    self.quitSize = quitSize
    self.quitMargin = quitMargin
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.quit) then
        self.quit:SetPos(w - self.quitSize - self.quitMargin, self.quitMargin)
    end
end

function PANEL:Paint(w, h)
    -- Modern gradient background
    local gradient = {}
    for i = 0, h do
        local alpha = math.min(220, 180 + (i / h) * 40)
        gradient[i] = Color(15, 15, 15, alpha)
    end
    
    -- Background with blur effect
    Derma_DrawBackgroundBlur(self, 0.3)
    
    -- Main background
    draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 15, 200))
    
    -- Subtle border
    surface.SetDrawColor(Color(40, 40, 40, 100))
    surface.DrawOutlinedRect(0, 0, w, h, 2)
end

vgui.Register("EZQuadcopterFrame", PANEL, "DFrame")