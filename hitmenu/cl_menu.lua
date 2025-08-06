--[[
Modern Hitman Menu (Optimized)
Performans iyileştirmeleri: Think throttling, cached calculations
--]]

local PANEL
local minHitDistanceSqr = GM.Config.minHitDistance * GM.Config.minHitDistance

-- Güncellenmiş Modern Renk Paleti
local colors = {
    background = Color(38, 40, 48, 245),
    panelBorder = Color(80, 85, 95, 100),
    primaryText = Color(245, 245, 245, 255),
    secondaryText = Color(160, 165, 175, 220),
    accent = Color(60, 180, 160, 255),
    accentDark = Color(45, 150, 130, 255),
    price = Color(220, 180, 90, 255),
    error = Color(210, 75, 75, 255),
    errorDark = Color(180, 55, 55, 255),
    rowDefault = Color(48, 50, 60, 180),
    rowHover = Color(60, 62, 72, 210),
    rowSelected = Color(70, 72, 82, 230),
    rowSelectedBorder = Color(255, 255, 255, 50)
}

-- OPTIMIZASYON: Hover renkleri önceden hesapla
local accentHover = Color(colors.accent.r * 1.1, colors.accent.g * 1.1, colors.accent.b * 1.1, colors.accent.a)
local errorHover = Color(colors.error.r * 1.1, colors.error.g * 1.1, colors.error.b * 1.1, colors.error.a)

-- OPTIMIZASYON: Font cache
local font_trebuchet24 = "Trebuchet24"
local font_dermaDefaultBold = "DermaDefaultBold" 
local font_dermaDefault = "DermaDefault"

-- Özel Arkaplan Çizim Fonksiyonları
local draw_RoundedBox = draw.RoundedBox -- Cache native function
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect

local function DrawBackground(x, y, w, h, color)
    draw_RoundedBox(10, x, y, w, h, color)
end

local function DrawInsetBox(x, y, w, h, color, iSize)
    surface_SetDrawColor(ColorAlpha(color_black, color.a * 0.4))
    surface_DrawRect(x + iSize, y + iSize, w - iSize * 2, h - iSize * 2)

    surface_SetDrawColor(color)
    surface_DrawOutlinedRect(x, y, w, h)
    surface_DrawOutlinedRect(x + iSize, y + iSize, w - iSize * 2, h - iSize * 2)
end

--[[---------------------------------------------------------------------------
Hitman menu (Ana Panel)
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "hitman", "Hitman")
AccessorFunc(PANEL, "target", "Target")
AccessorFunc(PANEL, "selected", "Selected")

function PANEL:Init()
    self.BaseClass.Init(self)

    -- OPTIMIZASYON: Cache panel size
    self:SetSize(500, 620)
    self:Center()

    self.btnClose = vgui.Create("DButton", self)
    self.btnClose:SetText("")
    self.btnClose.DoClick = function() self:Remove() end
    self.btnClose.Paint = function(panel, w, h)
        local bgColor = panel.hovered and colors.error or colors.errorDark
        draw_RoundedBox(4, 0, 0, w, h, bgColor)
        surface_SetDrawColor(colors.primaryText)
        local pad = w * 0.3
        surface.DrawLine(pad, pad, w - pad, h - pad)
        surface.DrawLine(w - pad, pad, pad, h - pad)
    end
    -- OPTIMIZASYON: Hover state cache
    self.btnClose.OnCursorEntered = function(s) s.hovered = true end
    self.btnClose.OnCursorExited = function(s) s.hovered = false end

    self.icon = vgui.Create("SpawnIcon", self)
    self.icon:SetDisabled(true)
    self.icon.PaintOver = function(icon) icon:SetTooltip() end
    self.icon:SetTooltip()

    self.title = vgui.Create("DLabel", self)
    self.title:SetText(DarkRP.getPhrase("hitman"))
    self.title:SetColor(colors.primaryText)
    self.title:SetFont(font_trebuchet24)

    self.name = vgui.Create("DLabel", self)
    self.name:SetColor(colors.secondaryText)
    self.name:SetFont(font_trebuchet24)

    self.price = vgui.Create("DLabel", self)
    self.price:SetColor(colors.price)
    self.price:SetFont(font_trebuchet24)

    self.playerList = vgui.Create("DScrollPanel", self)
    local sb = self.playerList:GetVBar()
    if sb then
        sb:SetWide(8)
        sb.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, Color(colors.background.r, colors.background.g, colors.background.b, 200)) end
        sb.btnUp.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.secondaryText) end
        sb.btnDown.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.secondaryText) end
        sb.btnGrip.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.accent) end
    end

    self.btnRequest = vgui.Create("HitmanMenuButton", self)
    self.btnRequest:SetText(DarkRP.getPhrase("hitmenu_request"))
    self.btnRequest.DoClick = function()
        local target = self:GetTarget()
        if IsValid(target) then
            RunConsoleCommand("darkrp", "requesthit", target:SteamID(), self:GetHitman():UserID())
            self:Remove()
        end
    end

    self.btnCancel = vgui.Create("HitmanMenuButton", self)
    self.btnCancel:SetText(DarkRP.getPhrase("cancel"))
    self.btnCancel.DoClick = function() self:Remove() end

    -- OPTIMIZASYON: Think interval
    self.NextThink = 0
    self.LastPrice = 0
    
    self:InvalidateLayout()
end

function PANEL:Think()
    -- OPTIMIZASYON: Throttle think
    local curTime = CurTime()
    if curTime < self.NextThink then return end
    self.NextThink = curTime + 0.5 -- 500ms interval
    
    local hitman = self:GetHitman()
    if not IsValid(hitman) or hitman:GetPos():DistToSqr(LocalPlayer():GetPos()) > minHitDistanceSqr then
        self:Remove()
        return
    end
    
    -- OPTIMIZASYON: Sadece fiyat değiştiğinde güncelle
    local currentPrice = hitman:getHitPrice()
    if self.LastPrice ~= currentPrice then
        self.LastPrice = currentPrice
        self.price:SetText(DarkRP.getPhrase("priceTag", DarkRP.formatMoney(currentPrice), ""))
        self.price:SizeToContents()
    end
end

function PANEL:PerformLayout()
    local w, h = 500, 620 -- Cached values

    self.btnClose:SetSize(20, 20)
    self.btnClose:SetPos(w - 30, 10)

    local iconSize = 90
    self.icon:SetSize(iconSize, iconSize)
    self.icon:SetModel(self:GetHitman():GetModel())
    self.icon:SetPos(25, 45)

    self.title:SetPos(iconSize + 50, 50)
    self.title:SizeToContents()

    self.name:SetText(DarkRP.getPhrase("name", self:GetHitman():Nick()))
    self.name:SetPos(iconSize + 50, 80)
    self.name:SizeToContents()

    self.price:SetPos(iconSize + 50, 110)

    local listTop = 145
    local listBottomMargin = 70
    local btnHeight = 45
    local listHeight = h - listTop - listBottomMargin

    self.playerList:SetPos(20, listTop)
    self.playerList:SetSize(w - 40, listHeight)

    local btnWidth = 225 -- (500 - 50) / 2
    self.btnRequest:SetSize(btnWidth, btnHeight)
    self.btnCancel:SetSize(btnWidth, btnHeight)

    self.btnRequest:SetPos(20, h - btnHeight - 20)
    self.btnRequest:SetButtonColor(colors.accent)

    self.btnCancel:SetPos(255, h - btnHeight - 20)
    self.btnCancel:SetButtonColor(colors.error)

    local sb = self.playerList:GetVBar()
    if IsValid(sb) and sb:IsVisible() then
        self.playerList:GetCanvas():SetWide(self.playerList:GetWide() - sb:GetWide())
    end

    self.BaseClass.PerformLayout(self)
end

-- OPTIMIZASYON: Paint içinde hesaplama azaltıldı
function PANEL:Paint(w, h)
    DrawBackground(0, 0, w, h, colors.background)
    surface_SetDrawColor(colors.panelBorder)
    surface_DrawOutlinedRect(0, 0, w, h, 1)
    surface.DrawLine(15, 140, w - 15, 140) -- Sabit çizgi konumu
end

function PANEL:AddPlayerRows()
    local players = player.GetAll()
    local validPlayers = {}
    
    -- OPTIMIZASYON: Filtreleme ve sıralama ayrıldı
    local localPlayer = LocalPlayer()
    local hitman = self:GetHitman()
    local hitPrice = hitman:getHitPrice()
    
    for _, v in pairs(players) do
        if v ~= localPlayer and v ~= hitman then
            local canRequest = hook.Call("canRequestHit", DarkRP.hooks, hitman, localPlayer, v, hitPrice)
            if canRequest then
                table.insert(validPlayers, v)
            end
        end
    end

    table.sort(validPlayers, function(a, b)
        local aTeam, bTeam = a:Team(), b:Team()
        if aTeam == bTeam then
            return string.lower(a:Nick()) < string.lower(b:Nick())
        end
        return team.GetName(aTeam) < team.GetName(bTeam)
    end)

    self.playerList:Clear()

    for _, v in ipairs(validPlayers) do
        local line = vgui.Create("HitmanMenuPlayerRow", self.playerList)
        line:SetPlayer(v)
        line:SetTall(28)
        line:Dock(TOP)
        line:DockMargin(0, 0, 0, 2)

        line.DoClick = function(panel)
            self:SetTarget(panel:GetPlayer())

            local previousSelected = self:GetSelected()
            if IsValid(previousSelected) and previousSelected ~= panel then
                if previousSelected.SetSelected then
                    previousSelected:SetSelected(false)
                end
            end

            panel:SetSelected(true)
            self:SetSelected(panel)
        end
    end
    
    self.playerList:InvalidateLayout(true)
end

vgui.Register("HitmanMenu", PANEL, "DPanel")

--[[---------------------------------------------------------------------------
Hitmenu button
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "btnColor", "ButtonColor")

function PANEL:Init()
    self.BaseClass.Init(self)
    self:SetFont(font_dermaDefaultBold)
    self:SetTextColor(colors.primaryText)
    
    -- OPTIMIZASYON: State cache
    self.hovered = false
    self.down = false
end

function PANEL:OnCursorEntered() self.hovered = true end
function PANEL:OnCursorExited() self.hovered = false end
function PANEL:OnMousePressed(code) if code == MOUSE_LEFT then self.down = true end end
function PANEL:OnMouseReleased(code) if code == MOUSE_LEFT then self.down = false end end

function PANEL:Paint(w, h)
    local col = self:GetButtonColor() or colors.accent
    local corner = 6

    -- OPTIMIZASYON: Pre-calculated colors
    local targetCol = col
    if self.down then
        targetCol = (col == colors.accent) and colors.accentDark or colors.errorDark
    elseif self.hovered then
        targetCol = (col == colors.accent) and accentHover or errorHover
    end

    draw_RoundedBox(corner, 0, 0, w, h, targetCol)
    draw_RoundedBox(corner, 1, 1, w - 2, h - 2, ColorAlpha(color_black, 30))
    draw_RoundedBox(corner, 1, 1, w - 2, h - 3, ColorAlpha(color_white, 15))

    self:DrawTextEntryText(colors.primaryText, colors.primaryText, colors.primaryText)
end

vgui.Register("HitmanMenuButton", PANEL, "DButton")

--[[---------------------------------------------------------------------------
Player row
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "player", "Player")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)

function PANEL:Init()
    self.BaseClass.Init(self)

    self.lblName = vgui.Create("DLabel", self)
    self.lblName:SetMouseInputEnabled(false)
    self.lblName:SetColor(colors.primaryText)
    self.lblName:SetFont(font_dermaDefaultBold)

    self.lblTeam = vgui.Create("DLabel", self)
    self.lblTeam:SetMouseInputEnabled(false)
    self.lblTeam:SetColor(colors.secondaryText)
    self.lblTeam:SetFont(font_dermaDefault)

    self:SetText("")
    self:SetCursor("hand")
    
    -- OPTIMIZASYON: Hover state cache
    self.hovered = false
end

function PANEL:OnCursorEntered() self.hovered = true end
function PANEL:OnCursorExited() self.hovered = false end

function PANEL:PerformLayout(w, h)
    local ply = self:GetPlayer()
    if not IsValid(ply) then self:Remove() return end

    local namePadding = 15
    local jobPadding = 15

    self.lblName:SetText(DarkRP.deLocalise(ply:Nick()))
    self.lblName:SizeToContents()
    self.lblName:SetPos(namePadding, (h - self.lblName:GetTall()) / 2)

    local jobText = (ply.DarkRPVars and DarkRP.deLocalise(ply:getDarkRPVar("job") or "")) or team.GetName(ply:Team())
    self.lblTeam:SetText(jobText)
    self.lblTeam:SizeToContents()
    self.lblTeam:SetPos(w - self.lblTeam:GetWide() - jobPadding, (h - self.lblTeam:GetTall()) / 2)

    local maxNameWidth = w - self.lblTeam:GetWide() - namePadding - jobPadding - 10
    if self.lblName:GetWide() > maxNameWidth then
        self.lblName:SetWide(maxNameWidth)
    end
end

function PANEL:Paint(w, h)
    local ply = self:GetPlayer()
    if not IsValid(ply) then self:Remove() return end

    local corner = 4
    local jobColor = team.GetColor(ply:Team()) or Color(150, 150, 150)
    jobColor.a = 255

    local bgColor = colors.rowDefault
    local leftBarColor = ColorAlpha(jobColor, 0)

    if self:GetSelected() then
        bgColor = colors.rowSelected
        leftBarColor = jobColor
    elseif self.hovered then
        bgColor = colors.rowHover
        leftBarColor = ColorAlpha(jobColor, 180)
    end

    draw_RoundedBox(corner, 0, 0, w, h, bgColor)

    if leftBarColor.a > 0 then
        draw.RoundedBoxEx(corner, 0, 0, 5, h, leftBarColor, true, false, true, false)
    end

    if self:GetSelected() then
        draw_RoundedBox(corner, 1, 1, w - 2, h - 2, colors.rowSelectedBorder)
    end
end

function PANEL:SetSelected(bSelected)
    if self.selected == bSelected then return end
    self.selected = bSelected
    if IsValid(self) and self.Invalidate then
        self:Invalidate()
    end
end

vgui.Register("HitmanMenuPlayerRow", PANEL, "Button")

--[[---------------------------------------------------------------------------
Open the hit menu
---------------------------------------------------------------------------]]
function DarkRP.openHitMenu(hitman)
    if IsValid(g_HitmanMenu) then g_HitmanMenu:Remove() end

    local frame = vgui.Create("HitmanMenu")
    frame:SetHitman(hitman)
    frame:AddPlayerRows()
    frame:SetVisible(true)
    frame:MakePopup()

    g_HitmanMenu = frame
end