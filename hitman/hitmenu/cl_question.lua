--[[
Modern Hit Question Menu
Tetikçiye gelen hit taleplerini kabul/reddetme menüsü
--]]

-- Renk paleti (cl_menu.lua ile uyumlu)
local colors = {
    background = Color(38, 40, 48, 245),
    panelBorder = Color(80, 85, 95, 100),
    primaryText = Color(245, 245, 245, 255),
    secondaryText = Color(160, 165, 175, 220),
    accent = Color(60, 180, 160, 255),
    accentDark = Color(45, 150, 130, 255),
    error = Color(210, 75, 75, 255),
    errorDark = Color(180, 55, 55, 255),
    price = Color(220, 180, 90, 255),
    timerBar = Color(255, 180, 0, 200),
    timerBarBg = Color(50, 50, 60, 180)
}

-- Font tanımlamaları
surface.CreateFont("HitQuestionTitle", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true
})

surface.CreateFont("HitQuestionInfo", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

surface.CreateFont("HitQuestionPrice", {
    font = "Roboto Bold",
    size = 28,
    weight = 700,
    antialias = true
})

surface.CreateFont("HitQuestionTimer", {
    font = "Roboto",
    size = 16,
    weight = 600,
    antialias = true
})

-- Ana panel
local PANEL = {}

function PANEL:Init()
    self:SetSize(450, 340) -- Biraz daha uzun panel
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(true)
    self:MakePopup()
    
    -- Animasyon değişkenleri
    self.startTime = CurTime()
    self.duration = 20 -- 20 saniye
    self.animAlpha = 0
    
    -- Başlık
    self.lblTitle = vgui.Create("DLabel", self)
    self.lblTitle:SetText("SUIKAST TALEBI")
    self.lblTitle:SetFont("HitQuestionTitle")
    self.lblTitle:SetTextColor(colors.primaryText)
    self.lblTitle:SetContentAlignment(5)
    self.lblTitle:Dock(TOP)
    self.lblTitle:DockMargin(20, 25, 20, 5)
    self.lblTitle:SetTall(30)
    
    -- Müşteri bilgisi
    self.lblCustomer = vgui.Create("DLabel", self)
    self.lblCustomer:SetFont("HitQuestionInfo")
    self.lblCustomer:SetTextColor(colors.secondaryText)
    self.lblCustomer:SetContentAlignment(5)
    self.lblCustomer:Dock(TOP)
    self.lblCustomer:DockMargin(20, 10, 20, 0)
    self.lblCustomer:SetTall(25)
    
    -- Hedef bilgisi
    self.lblTarget = vgui.Create("DLabel", self)
    self.lblTarget:SetFont("HitQuestionInfo")
    self.lblTarget:SetTextColor(colors.primaryText)
    self.lblTarget:SetContentAlignment(5)
    self.lblTarget:Dock(TOP)
    self.lblTarget:DockMargin(20, 5, 20, 0)
    self.lblTarget:SetTall(25)
    
    -- Fiyat
    self.lblPrice = vgui.Create("DLabel", self)
    self.lblPrice:SetFont("HitQuestionPrice")
    self.lblPrice:SetTextColor(colors.price)
    self.lblPrice:SetContentAlignment(5)
    self.lblPrice:Dock(TOP)
    self.lblPrice:DockMargin(20, 15, 20, 0)
    self.lblPrice:SetTall(35)
    
    -- Süre göstergesi
    self.lblTimer = vgui.Create("DLabel", self)
    self.lblTimer:SetFont("HitQuestionTimer")
    self.lblTimer:SetTextColor(colors.secondaryText)
    self.lblTimer:SetContentAlignment(5)
    self.lblTimer:Dock(TOP)
    self.lblTimer:DockMargin(20, 10, 20, 0)
    self.lblTimer:SetTall(20)
    
    -- Buton paneli
    self.btnPanel = vgui.Create("DPanel", self)
    self.btnPanel:Dock(BOTTOM)
    self.btnPanel:SetTall(60)
    self.btnPanel:DockMargin(20, 15, 20, 20) -- Üst margin artırıldı
    self.btnPanel.Paint = function() end
    
    -- Kabul butonu
    self.btnAccept = vgui.Create("DButton", self.btnPanel)
    self.btnAccept:SetText("KABUL ET")
    self.btnAccept:SetFont("HitQuestionInfo")
    self.btnAccept:SetTextColor(colors.primaryText)
    self.btnAccept:Dock(LEFT)
    self.btnAccept:SetWide(190)
    self.btnAccept:DockMargin(0, 0, 5, 0)
    
    self.btnAccept.Paint = function(panel, w, h)
        local col = colors.accent
        if panel:IsDown() then
            col = colors.accentDark
        elseif panel:IsHovered() then
            col = Color(col.r * 1.1, col.g * 1.1, col.b * 1.1)
        end
        
        draw.RoundedBox(8, 0, 0, w, h, col)
        
        -- İç gölge efekti
        draw.RoundedBox(8, 1, 1, w-2, h-2, ColorAlpha(color_black, 20))
        
        -- Üst highlight
        if not panel:IsDown() then
            draw.RoundedBox(8, 1, 1, w-2, h-3, ColorAlpha(color_white, 10))
        end
    end
    
    self.btnAccept.DoClick = function()
        surface.PlaySound("buttons/button14.wav")
        self:Accept()
    end
    
    -- Reddet butonu
    self.btnDecline = vgui.Create("DButton", self.btnPanel)
    self.btnDecline:SetText("REDDET")
    self.btnDecline:SetFont("HitQuestionInfo")
    self.btnDecline:SetTextColor(colors.primaryText)
    self.btnDecline:Dock(RIGHT)
    self.btnDecline:SetWide(190)
    self.btnDecline:DockMargin(5, 0, 0, 0)
    
    self.btnDecline.Paint = function(panel, w, h)
        local col = colors.error
        if panel:IsDown() then
            col = colors.errorDark
        elseif panel:IsHovered() then
            col = Color(col.r * 1.1, col.g * 1.1, col.b * 1.1)
        end
        
        draw.RoundedBox(8, 0, 0, w, h, col)
        
        -- İç gölge efekti
        draw.RoundedBox(8, 1, 1, w-2, h-2, ColorAlpha(color_black, 20))
        
        -- Üst highlight
        if not panel:IsDown() then
            draw.RoundedBox(8, 1, 1, w-2, h-3, ColorAlpha(color_white, 10))
        end
    end
    
    self.btnDecline.DoClick = function()
        surface.PlaySound("buttons/button10.wav")
        self:Decline()
    end
    
    -- Fade-in animasyonu
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)
    
    -- Ses efekti
    surface.PlaySound("ambient/alarms/warningbell1.wav")
end

function PANEL:SetHitInfo(customer, target, price)
    self.customer = customer
    self.target = target
    self.price = price
    
    if IsValid(customer) then
        self.lblCustomer:SetText("Müşteri: " .. customer:Nick())
    end
    
    if IsValid(target) then
        self.lblTarget:SetText("Hedef: " .. target:Nick())
    end
    
    self.lblPrice:SetText(DarkRP.formatMoney(price))
end

function PANEL:Think()
    -- Süre güncelleme
    local timeLeft = self.duration - (CurTime() - self.startTime)
    
    if timeLeft <= 0 then
        self:Decline()
        return
    end
    
    self.lblTimer:SetText(string.format("Kalan Süre: %d saniye", math.ceil(timeLeft)))
    
    -- Son 5 saniyede kırmızı yap
    if timeLeft <= 5 then
        self.lblTimer:SetTextColor(colors.error)
    end
end

function PANEL:Paint(w, h)
    -- Arkaplan
    draw.RoundedBox(12, 0, 0, w, h, colors.background)
    
    -- Kenarlık
    surface.SetDrawColor(colors.panelBorder)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    
    -- Başlık altı çizgi
    surface.SetDrawColor(colors.panelBorder)
    surface.DrawLine(20, 60, w - 20, 60)
    
    -- Süre barı
    local timeLeft = self.duration - (CurTime() - self.startTime)
    local barWidth = (w - 40) * (timeLeft / self.duration)
    
    -- Bar arkaplanı
    draw.RoundedBox(4, 20, h - 90, w - 40, 8, colors.timerBarBg)
    
    -- Bar dolgusu
    if timeLeft > 0 then
        local barColor = colors.timerBar
        if timeLeft <= 5 then
            -- Son 5 saniyede yanıp sön
            barColor = ColorAlpha(colors.error, 150 + math.sin(CurTime() * 10) * 50)
        end
        draw.RoundedBox(4, 20, h - 100, barWidth, 8, barColor)
    end
    
    -- Dekoratif üst çizgiler
    surface.SetDrawColor(colors.accent)
    surface.DrawRect(0, 0, w, 2)
end

function PANEL:Accept()
    if self.answered then return end
    self.answered = true
    
    -- Sunucuya bildir
    net.Start("HitQuestionResponse")
        net.WriteBool(true)
        net.WriteEntity(self.customer)
        net.WriteEntity(self.target)
        net.WriteFloat(self.price)
    net.SendToServer()
    
    -- Fade-out ve kapat
    self:AlphaTo(0, 0.2, 0, function()
        self:Remove()
    end)
end

function PANEL:Decline()
    if self.answered then return end
    self.answered = true
    
    -- Sunucuya bildir
    net.Start("HitQuestionResponse")
        net.WriteBool(false)
        net.WriteEntity(self.customer)
        net.WriteEntity(self.target)
        net.WriteFloat(self.price)
    net.SendToServer()
    
    -- Fade-out ve kapat
    self:AlphaTo(0, 0.2, 0, function()
        self:Remove()
    end)
end

vgui.Register("HitQuestionMenu", PANEL, "DFrame")

-- Net message handler
net.Receive("HitQuestion", function()
    local customer = net.ReadEntity()
    local target = net.ReadEntity()
    local price = net.ReadFloat()
    
    -- Eski menü varsa kapat
    if IsValid(g_HitQuestionMenu) then
        g_HitQuestionMenu:Remove()
    end
    
    -- Yeni menü aç
    local menu = vgui.Create("HitQuestionMenu")
    menu:SetHitInfo(customer, target, price)
    
    g_HitQuestionMenu = menu
end)

-- DarkRP'nin standart sorusunu override et (opsiyonel)
hook.Add("onQuestionAsked", "HitQuestionOverride", function(question, questionID, ply, timeleft, callback, ...)
    -- Eğer soru hit ile ilgiliyse
    if string.find(questionID, "hit") then
        -- Standart DarkRP sorusunu engelle
        return true
    end
end)