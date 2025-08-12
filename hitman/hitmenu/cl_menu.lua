--[[
Modern Hitman Menu (Final Fixed Version)
Tüm sorunlar çözüldü - Direkt net message kullanımı
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
local draw_RoundedBox = draw.RoundedBox
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect

local function DrawBackground(x, y, w, h, color)
    draw_RoundedBox(10, x, y, w, h, color)
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

    self:SetSize(500, 620)
    self:Center()

    -- KAPAT BUTONU
    self.btnClose = vgui.Create("DButton", self)
    self.btnClose:SetText("")
    self.btnClose.DoClick = function() 
        print("[HitMenu] Kapat butonu tıklandı")
        self:Remove() 
    end
    self.btnClose.Paint = function(panel, w, h)
        local bgColor = panel.hovered and colors.error or colors.errorDark
        draw_RoundedBox(4, 0, 0, w, h, bgColor)
        surface_SetDrawColor(colors.primaryText)
        local pad = w * 0.3
        surface.DrawLine(pad, pad, w - pad, h - pad)
        surface.DrawLine(w - pad, pad, pad, h - pad)
    end
    self.btnClose.OnCursorEntered = function(s) s.hovered = true end
    self.btnClose.OnCursorExited = function(s) s.hovered = false end

    -- İKON
    self.icon = vgui.Create("SpawnIcon", self)
    self.icon:SetDisabled(true)
    self.icon.PaintOver = function(icon) icon:SetTooltip() end
    self.icon:SetTooltip()

    -- BAŞLIK
    self.title = vgui.Create("DLabel", self)
    self.title:SetText(DarkRP.getPhrase("hitman") or "Tetikçi")
    self.title:SetColor(colors.primaryText)
    self.title:SetFont(font_trebuchet24)

    -- İSİM
    self.name = vgui.Create("DLabel", self)
    self.name:SetColor(colors.secondaryText)
    self.name:SetFont(font_trebuchet24)

    -- FİYAT
    self.price = vgui.Create("DLabel", self)
    self.price:SetColor(colors.price)
    self.price:SetFont(font_trebuchet24)

    -- OYUNCU LİSTESİ
    self.playerList = vgui.Create("DScrollPanel", self)
    local sb = self.playerList:GetVBar()
    if sb then
        sb:SetWide(8)
        sb.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, Color(colors.background.r, colors.background.g, colors.background.b, 200)) end
        sb.btnUp.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.secondaryText) end
        sb.btnDown.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.secondaryText) end
        sb.btnGrip.Paint = function(panel, w, h) draw_RoundedBox(4, 0, 0, w, h, colors.accent) end
    end

    -- TALEP BUTONU - DÜZELTME
    self.btnRequest = vgui.Create("DButton", self)
    self.btnRequest:SetText(DarkRP.getPhrase("hitmenu_request") or "Talep Et")
    self.btnRequest:SetFont(font_dermaDefaultBold)
    self.btnRequest:SetTextColor(colors.primaryText)
    
    self.btnRequest.Paint = function(panel, w, h)
        local col = colors.accent
        if panel:IsDown() then
            col = colors.accentDark
        elseif panel:IsHovered() then
            col = accentHover
        end
        draw_RoundedBox(6, 0, 0, w, h, col)
        draw_RoundedBox(6, 1, 1, w - 2, h - 2, ColorAlpha(color_black, 30))
        if not panel:IsDown() then
            draw_RoundedBox(6, 1, 1, w - 2, h - 3, ColorAlpha(color_white, 15))
        end
    end
    
    self.btnRequest.DoClick = function(btn)
        print("[HitMenu] Talep butonu DoClick başladı")
        
        local target = self:GetTarget()
        local hitman = self:GetHitman()
        
        print("[HitMenu] Target:", IsValid(target) and target:Nick() or "GEÇERSİZ")
        print("[HitMenu] Hitman:", IsValid(hitman) and hitman:Nick() or "GEÇERSİZ")
        
        if not IsValid(target) then
            Derma_Message("Lütfen bir hedef seçin!", "Hata", "Tamam")
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        if not IsValid(hitman) then
            chat.AddText(Color(255, 0, 0), "[Hata] ", Color(255, 255, 255), "Tetikçi artık geçerli değil!")
            self:Remove()
            return
        end
        
        -- DÜZELTME: Direkt net message gönder
        print("[HitMenu] Net message gönderiliyor...")
        net.Start("HitmanRequestHit")
            net.WriteEntity(hitman)
            net.WriteEntity(target)
        net.SendToServer()
        
        -- Bildirim
        chat.AddText(Color(0, 255, 0), "[Suikast] ", Color(255, 255, 255), "Suikast talebi gönderildi!")
        surface.PlaySound("buttons/button9.wav")
        
        print("[HitMenu] Talep gönderildi, menü kapatılıyor")
        
        -- Menüyü kapat
        self:Remove()
    end

    -- İPTAL BUTONU - DÜZELTME
    self.btnCancel = vgui.Create("DButton", self)
    self.btnCancel:SetText(DarkRP.getPhrase("cancel") or "İptal")
    self.btnCancel:SetFont(font_dermaDefaultBold)
    self.btnCancel:SetTextColor(colors.primaryText)
    
    self.btnCancel.Paint = function(panel, w, h)
        local col = colors.error
        if panel:IsDown() then
            col = colors.errorDark
        elseif panel:IsHovered() then
            col = errorHover
        end
        draw_RoundedBox(6, 0, 0, w, h, col)
        draw_RoundedBox(6, 1, 1, w - 2, h - 2, ColorAlpha(color_black, 30))
        if not panel:IsDown() then
            draw_RoundedBox(6, 1, 1, w - 2, h - 3, ColorAlpha(color_white, 15))
        end
    end
    
    self.btnCancel.DoClick = function(btn)
        print("[HitMenu] İptal butonu tıklandı")
        surface.PlaySound("buttons/button10.wav")
        self:Remove()
    end

    -- Think interval
    self.NextThink = 0
    self.LastPrice = 0
    
    self:InvalidateLayout()
end

function PANEL:Think()
    local curTime = CurTime()
    if curTime < self.NextThink then return end
    self.NextThink = curTime + 0.5
    
    local hitman = self:GetHitman()
    if not IsValid(hitman) then
        self:Remove()
        return
    end
    
    -- Mesafe kontrolü
    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) or hitman:GetPos():DistToSqr(localPlayer:GetPos()) > minHitDistanceSqr then
        chat.AddText(Color(255, 0, 0), "[Suikast] ", Color(255, 255, 255), "Tetikçiden çok uzaklaştınız!")
        self:Remove()
        return
    end
    
    -- Fiyat güncelleme
    local currentPrice = hitman:getHitPrice()
    if self.LastPrice ~= currentPrice then
        self.LastPrice = currentPrice
        local priceText = DarkRP.formatMoney(currentPrice)
        self.price:SetText(DarkRP.getPhrase("priceTag", priceText, "") or "Fiyat: " .. priceText)
        self.price:SizeToContents()
    end
end

function PANEL:PerformLayout()
    local w, h = 500, 620

    self.btnClose:SetSize(20, 20)
    self.btnClose:SetPos(w - 30, 10)

    local iconSize = 90
    self.icon:SetSize(iconSize, iconSize)
    if IsValid(self:GetHitman()) then
        self.icon:SetModel(self:GetHitman():GetModel())
    end
    self.icon:SetPos(25, 45)

    self.title:SetPos(iconSize + 50, 50)
    self.title:SizeToContents()

    if IsValid(self:GetHitman()) then
        self.name:SetText(DarkRP.getPhrase("name", self:GetHitman():Nick()) or "İsim: " .. self:GetHitman():Nick())
    end
    self.name:SetPos(iconSize + 50, 80)
    self.name:SizeToContents()

    self.price:SetPos(iconSize + 50, 110)

    local listTop = 145
    local listBottomMargin = 70
    local btnHeight = 45
    local listHeight = h - listTop - listBottomMargin

    self.playerList:SetPos(20, listTop)
    self.playerList:SetSize(w - 40, listHeight)

    local btnWidth = 225
    self.btnRequest:SetSize(btnWidth, btnHeight)
    self.btnCancel:SetSize(btnWidth, btnHeight)

    self.btnRequest:SetPos(20, h - btnHeight - 20)
    self.btnCancel:SetPos(255, h - btnHeight - 20)

    local sb = self.playerList:GetVBar()
    if IsValid(sb) and sb:IsVisible() then
        self.playerList:GetCanvas():SetWide(self.playerList:GetWide() - sb:GetWide())
    end

    self.BaseClass.PerformLayout(self)
end

function PANEL:Paint(w, h)
    DrawBackground(0, 0, w, h, colors.background)
    surface_SetDrawColor(colors.panelBorder)
    surface_DrawOutlinedRect(0, 0, w, h, 1)
    surface.DrawLine(15, 140, w - 15, 140)
    
    -- Hedef seçimi göstergesi
    if IsValid(self:GetTarget()) then
        draw.SimpleText("Seçili Hedef: " .. self:GetTarget():Nick(), font_dermaDefault, 
            250, 555, colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("Hedef seçilmedi", font_dermaDefault, 
            250, 555, colors.error, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:AddPlayerRows()
    local players = player.GetAll()
    local validPlayers = {}
    
    local localPlayer = LocalPlayer()
    local hitman = self:GetHitman()
    
    if not IsValid(hitman) then
        print("[HitMenu] Hata: Hitman geçersiz!")
        return
    end
    
    local hitPrice = hitman:getHitPrice()
    
    print("[HitMenu] Oyuncu listesi hazırlanıyor. Toplam oyuncu:", #players)
    
    for _, v in pairs(players) do
        if v ~= localPlayer and v ~= hitman then
            -- canRequestHit hook'u kontrol et
            local canRequest, message = hook.Call("canRequestHit", DarkRP.hooks, hitman, localPlayer, v, hitPrice)
            
            -- Hook yoksa veya true dönerse ekle
            if canRequest ~= false then
                table.insert(validPlayers, v)
                print("[HitMenu] Oyuncu eklendi:", v:Nick())
            else
                print("[HitMenu] Oyuncu reddedildi:", v:Nick(), "- Sebep:", message or "Bilinmiyor")
            end
        end
    end

    print("[HitMenu] Geçerli oyuncu sayısı:", #validPlayers)

    -- Sıralama
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
        line:SetTall(32)
        line:Dock(TOP)
        line:DockMargin(2, 2, 2, 2)

        line.DoClick = function(panel)
            -- Hedefi seç
            self:SetTarget(panel:GetPlayer())

            -- Önceki seçimi temizle
            local previousSelected = self:GetSelected()
            if IsValid(previousSelected) and previousSelected ~= panel then
                if previousSelected.SetSelected then
                    previousSelected:SetSelected(false)
                end
            end

            -- Yeni seçimi işaretle
            panel:SetSelected(true)
            self:SetSelected(panel)
            
            -- Ses efekti
            surface.PlaySound("buttons/lightswitch2.wav")
            
            print("[HitMenu] Hedef seçildi:", panel:GetPlayer():Nick())
        end
    end
    
    self.playerList:InvalidateLayout(true)
end

vgui.Register("HitmanMenu", PANEL, "DPanel")

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
    
    self.hovered = false
end

function PANEL:OnCursorEntered() 
    self.hovered = true 
end

function PANEL:OnCursorExited() 
    self.hovered = false 
end

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
        
        -- Seçili göstergesi
        draw_RoundedBox(corner, 0, 0, w, h, ColorAlpha(colors.accent, 30))
    elseif self.hovered then
        bgColor = colors.rowHover
        leftBarColor = ColorAlpha(jobColor, 180)
    end

    draw_RoundedBox(corner, 0, 0, w, h, bgColor)

    -- Sol çizgi
    if leftBarColor.a > 0 then
        draw.RoundedBoxEx(corner, 0, 0, 5, h, leftBarColor, true, false, true, false)
    end

    -- Seçili border
    if self:GetSelected() then
        surface_SetDrawColor(colors.accent)
        surface_DrawOutlinedRect(0, 0, w, h, 2)
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
Open the hit menu - Ana fonksiyon
---------------------------------------------------------------------------]]
function DarkRP.openHitMenu(hitman)
    print("[HitMenu] openHitMenu çağrıldı")
    
    -- Eski menüyü kapat
    if IsValid(g_HitmanMenu) then 
        g_HitmanMenu:Remove() 
    end
    
    -- Hitman kontrolü
    if not IsValid(hitman) or not hitman:IsPlayer() or not hitman:isHitman() then
        chat.AddText(Color(255, 0, 0), "[Hata] ", Color(255, 255, 255), "Geçersiz tetikçi!")
        print("[HitMenu] Hata: Geçersiz tetikçi")
        return
    end
    
    -- Zaten hit'i var mı kontrol et
    if hitman:hasHit() then
        chat.AddText(Color(255, 0, 0), "[Hata] ", Color(255, 255, 255), "Bu tetikçinin zaten aktif bir görevi var!")
        return
    end

    print("[HitMenu] Menü açılıyor - Tetikçi:", hitman:Nick())

    -- Yeni menü oluştur
    local frame = vgui.Create("HitmanMenu")
    frame:SetHitman(hitman)
    frame:AddPlayerRows()
    frame:SetVisible(true)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false) -- Sadece mouse kullanımı

    g_HitmanMenu = frame
    
    print("[HitMenu] Menü başarıyla açıldı")
end

-- Debug komutu
concommand.Add("hitmenu_debugmode", function(ply, cmd, args)
    local mode = tonumber(args[1]) or 0
    if mode == 1 then
        print("[HitMenu] Debug mode aktif")
    else
        print("[HitMenu] Debug mode kapalı")
    end
end)