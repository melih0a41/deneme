local PANEL = {}

AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "textcolor", "TextColor")

function PANEL:Init()
    local scrW = ScrW()
    local scrH = ScrH()

    self:SetPos(0, 0)
    self:SetSize(scrW, scrH)
    self:Center()
    self:SetColor(easzy.quadcopter.colors.black)
    self:SetTextColor(easzy.quadcopter.colors.white)

    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()

    self:LoadQuitButton()
end

function PANEL:LoadQuitButton()
    local quitMargin = easzy.quadcopter.RespY(4)
    local quitSize = easzy.quadcopter.RespY(34)

    -- Otherwise the close button is not accessible
    self:DockPadding(0, quitMargin + quitSize, 0, 0)

    local quit = vgui.Create("EZQuadcopterButton", self)
    quit:SetSize(quitSize, quitSize)
    quit:SetPos(self:GetWide() - quitSize, quitMargin)
    quit.DoClick = function()
        self:Remove()
    end
    quit.Paint = function(s, w, h)
        surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())
        surface.SetMaterial(easzy.quadcopter.materials.close)
        surface.DrawTexturedRect(w - quitSize, 0, quitSize - quitMargin, quitSize - quitMargin)

        return true
    end

    self.quit = quit
    self.quitSize = quitSize
    self.quitMargin = quitMargin
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.quit) then
        self.quit:SetPos(w - self.quitSize, self.quitMargin)
    end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("EZQuadcopterFrame", PANEL, "DFrame")
