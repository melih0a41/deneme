local PANEL = {}

AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "textcolor", "TextColor")

AccessorFunc(PANEL, "iconsize", "IconSize")

AccessorFunc(PANEL, "quadcopter", "Quadcopter")
AccessorFunc(PANEL, "quadcopterview", "QuadcopterView")
AccessorFunc(PANEL, "part", "Part")
AccessorFunc(PANEL, "submaterialindex", "SubMaterialIndex")

function PANEL:Init()
    self:SetColor(easzy.quadcopter.colors.black)
    self:SetTextColor(easzy.quadcopter.colors.white)
    self:SetIconSize(easzy.quadcopter.RespY(128))

    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()
end

function PANEL:LoadInterface()
    local chosenColor

    local quadcopter = self:GetQuadcopter()
    local quadcopterView = self:GetQuadcopterView()
    local part = self:GetPart()

    -- Set SubMaterial index
    for index, material in ipairs(quadcopterView:GetMaterials()) do
        if material == part.material then
            self:SetSubMaterialIndex(index)
            break
        end
    end

    local containter = vgui.Create("DPanel", self)
    containter:Dock(FILL)
    containter:DockMargin(0, 0, 0, easzy.quadcopter.RespY(20))
    containter.Paint = function(s, w, h) end

    local iconSize = self:GetIconSize()
    local icon = vgui.Create("DPanel", containter)
    icon:SetWide(iconSize * 1.4)
    icon:Dock(LEFT)
    icon.Paint = function(s, w, h)
        surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())
        surface.SetMaterial(part.icon)
        surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
    end

    -- Label with text wrapping
    local description = vgui.Create("DLabel", containter)
    description:Dock(FILL)
    description:DockMargin(0, 0, easzy.quadcopter.RespX(10), 0)
    description:SetFont("EZFont20")
    description:SetColor(easzy.quadcopter.colors.black)
    description:SetText(part.description)
    description:SetWrap(true)

    local bottom = vgui.Create("DPanel", self)
    bottom:Dock(BOTTOM)
    bottom:SetTall(easzy.quadcopter.RespY(40))
    bottom.Paint = function() return end

    local buttonWide = self:GetWide()/2
    local buy = vgui.Create("EZQuadcopterButton", bottom)
    buy:Dock(LEFT)
    buy:SetWide(buttonWide)
    buy:SetText(easzy.quadcopter.languages.buy .. " " .. easzy.quadcopter.FormatCurrency(part.price))
    buy.DoClick = function()
        if not chosenColor then return end

        local subMaterialIndex = self:GetSubMaterialIndex()
        easzy.quadcopter.BuyColor(quadcopter, subMaterialIndex, part.key, chosenColor)
    end

    local reset = vgui.Create("EZQuadcopterButton", bottom)
    reset:Dock(RIGHT)
    reset:SetWide(buttonWide)
    reset:SetText(easzy.quadcopter.languages.reset .. " " .. easzy.quadcopter.FormatCurrency(part.price))
    reset.DoClick = function()
        local subMaterialIndex = self:GetSubMaterialIndex()
        easzy.quadcopter.ChangeSubMaterialColor(quadcopter, subMaterialIndex, part.key)
        easzy.quadcopter.ChangeSubMaterialColor(quadcopterView, subMaterialIndex, part.key)
    end

    local colorPalette = vgui.Create("DColorPalette", self)
    colorPalette:Dock(BOTTOM)
    colorPalette:SetButtonSize(self:GetWide()/25)
    colorPalette:SetColor(Color(255, 255, 255))
    colorPalette.Paint = function(s, w, h) end
    colorPalette.OnValueChanged = function(s, color)
        local color = Color(color.r, color.g, color.b, 255)
        local subMaterialIndex = self:GetSubMaterialIndex()
        easzy.quadcopter.ChangeSubMaterialColor(quadcopterView, subMaterialIndex, part.key, color)

        chosenColor = color
    end
end

function PANEL:OnRemove()
    local quadcopter = self:GetQuadcopter()
    local quadcopterView = self:GetQuadcopterView()
    local subMaterialIndex = self:GetSubMaterialIndex()
    local part = self:GetPart()

    easzy.quadcopter.ResetSubMaterialColor(quadcopter, quadcopterView, subMaterialIndex, part.key)
    easzy.quadcopter.buyFrame = nil
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite)
	surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    return true
end

vgui.Register("EZQuadcopterBuyColor", PANEL, "EZQuadcopterFrame")
