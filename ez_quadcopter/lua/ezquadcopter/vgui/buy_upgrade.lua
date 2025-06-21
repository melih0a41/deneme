local PANEL = {}

AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "textcolor", "TextColor")

AccessorFunc(PANEL, "iconsize", "IconSize")

AccessorFunc(PANEL, "quadcopter", "Quadcopter")
AccessorFunc(PANEL, "upgrade", "Upgrade")

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
    local quadcopter = self:GetQuadcopter()
    local upgrade = self:GetUpgrade()

    local currentUpgradeLevel = quadcopter.upgrades[upgrade.key]
    local upgradePrice = upgrade.prices[currentUpgradeLevel]

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
        surface.SetMaterial(upgrade.icon)
        surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
    end

    -- Label with text wrapping
    local description = vgui.Create("DLabel", containter)
    description:Dock(FILL)
    description:DockMargin(0, 0, easzy.quadcopter.RespX(10), 0)
    description:SetFont("EZFont20")
    description:SetColor(easzy.quadcopter.colors.black)
    description:SetText(upgrade.description)
    description:SetWrap(true)

    local action = vgui.Create("EZQuadcopterButton", self)
    action:Dock(BOTTOM)
    action:SetTall(easzy.quadcopter.RespY(40))

    if quadcopter.upgrades[upgrade.key] == table.Count(upgrade.levels) then
        action:SetText(easzy.quadcopter.languages.maximum)
        action.DoClick = function() return end
    else
        action:SetText(easzy.quadcopter.languages.buy .. " " .. easzy.quadcopter.FormatCurrency(upgradePrice))
        action.DoClick = function()
            easzy.quadcopter.Upgrade(quadcopter, upgrade.key)
            self:Remove()
        end
    end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite)
	surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    return true
end

vgui.Register("EZQuadcopterBuyUpgrade", PANEL, "EZQuadcopterFrame")
