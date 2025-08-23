-- fib_sistem/lua/autorun/client/cl_fib_mainmenu.lua
-- PARÇA 1/4 (Satır 1-400)

-- FIB tablosunu kontrol et
FIB = FIB or {}
FIB.Config = FIB.Config or {}

-- Config yüklenmemişse varsayılan değerler
if not FIB.Config.Colors then
    FIB.Config.Colors = {
        primary = Color(5, 10, 20, 255),
        secondary = Color(10, 20, 35, 255),
        accent = Color(0, 120, 255, 255),
        background = Color(2, 15, 35, 255),
        panel_bg = Color(5, 15, 30, 240),
        text = Color(255, 255, 255, 255),
        text_dim = Color(180, 180, 190, 255),
        error = Color(255, 65, 65, 255),
        success = Color(65, 255, 65, 255),
        warning = Color(255, 200, 0, 255),
        hover = Color(0, 150, 255, 255),
        glow = Color(0, 200, 255, 100),
        border = Color(0, 100, 200, 200)
    }
end

-- Font tanımlamaları
surface.CreateFont("FIB_Menu_Title", {
    font = "Roboto",
    size = 28,
    weight = 600,
    antialias = true
})

surface.CreateFont("FIB_Menu_Tab", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

surface.CreateFont("FIB_Menu_Section", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont("FIB_Menu_Text", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true
})

surface.CreateFont("FIB_Menu_Small", {
    font = "Roboto",
    size = 14,
    weight = 400,
    antialias = true
})

surface.CreateFont("FIB_Menu_Stats", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true
})

-- Ana menü fonksiyonu
function FIB.CreateMainMenu()
    -- Eğer zaten açıksa
    if IsValid(FIB.MainMenu) then
        if FIB.MainMenu:IsVisible() then
            -- Görünürse kapat
            FIB.MainMenu:Close()
        else
            -- Görünmezse görünür yap
            FIB.MainMenu:SetVisible(true)
            -- Mini indicator varsa kaldır
            if IsValid(FIB.MiniIndicator) then
                FIB.MiniIndicator:Remove()
                FIB.MiniIndicator = nil
            end
        end
        return
    end
    
    -- Ana frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.85, ScrH() * 0.85)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.3, 0)
    
    -- Sync isteği gönder
    if LocalPlayer().FIBAuthenticated then
        timer.Simple(0.5, function()
            net.Start("FIB_RequestSync")
            net.SendToServer()
        end)
    end
    
    -- Hook'u tetikle
    hook.Run("FIB_MenuOpened")
    
    FIB.MainMenu = frame
    
    -- Seçili sekme
    local activeTab = "dashboard"
    local tabButtons = {}
    local tabPanels = {}
    
    -- Ana panel paint
    frame.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(12, 0, 0, w, h, Color(0, 0, 0, 250))
        
        -- İç ekran - Çok koyu mavi
        draw.RoundedBox(8, 10, 10, w-20, h-20, FIB.Config.Colors.background)
        
        -- Üst bar
        draw.RoundedBox(8, 10, 10, w-20, 70, FIB.Config.Colors.secondary)
        draw.RoundedBoxEx(8, 10, 10, w-20, 70, FIB.Config.Colors.secondary, true, true, false, false)
        
        -- Gradient overlay
        surface.SetDrawColor(0, 50, 100, 50)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(10, 10, w-20, 200)
        
        -- FIB Başlığı
        draw.SimpleText("FEDERAL ISTIHBARAT BUROSU", "FIB_Menu_Title", w/2, 35, FIB.Config.Colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("KOMUTA MERKEZI", "FIB_Menu_Text", w/2, 55, FIB.Config.Colors.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Animasyonlu alt çizgi
        local lineWidth = 400 + math.sin(CurTime() * 2) * 50
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawRect(w/2 - lineWidth/2, 75, lineWidth, 2)
        
        -- Glow efekti
        surface.SetDrawColor(FIB.Config.Colors.glow)
        surface.DrawRect(w/2 - lineWidth/2 - 20, 75, lineWidth + 40, 2)
        
        -- Sağ üst bilgiler
        draw.SimpleText(os.date("%H:%M:%S"), "FIB_Menu_Text", w - 20, 25, FIB.Config.Colors.text_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(LocalPlayer():Nick(), "FIB_Menu_Text", w - 20, 45, FIB.Config.Colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(LocalPlayer().FIBRank or "Ajan", "FIB_Menu_Small", w - 20, 65, FIB.Config.Colors.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        
        -- Sol menü arka planı
        draw.RoundedBox(0, 0, 80, 200, h - 80, Color(10, 20, 35, 200))
    end
    
    -- Logo
    local logo = vgui.Create("DPanel", frame)
    logo:SetSize(60, 60)
    logo:SetPos(10, 10)
    logo.Paint = function(self, w, h)
        local logoMat = Material("fib/logo.png", "smooth")
        if not logoMat:IsError() then
            surface.SetMaterial(logoMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, w, h)
        else
            -- Logo yoksa FIB yazısı
            draw.RoundedBox(8, 0, 0, w, h, FIB.Config.Colors.accent)
            draw.SimpleText("FIB", "FIB_Menu_Title", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Kapatma butonu (X)
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frame:GetWide() - 40, 10)
    closeBtn:SetText("✕")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn:SetFont("FIB_Menu_Text")
    closeBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(255, 50, 50, 200) or Color(255, 50, 50, 100)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    closeBtn.DoClick = function()
        frame:AlphaTo(0, 0.2, 0, function()
            frame:Close()
        end)
    end
    
    -- Minimize butonu
    local minBtn = vgui.Create("DButton", frame)
    minBtn:SetSize(30, 30)
    minBtn:SetPos(frame:GetWide() - 75, 10)
    minBtn:SetText("─")
    minBtn:SetTextColor(Color(255, 255, 255))
    minBtn:SetFont("FIB_Menu_Text")
    minBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(100, 100, 100, 200) or Color(100, 100, 100, 100)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    minBtn.DoClick = function()
        frame:SetVisible(false)
        
        -- Eğer mini indicator varsa önce kaldır
        if IsValid(FIB.MiniIndicator) then
            FIB.MiniIndicator:Remove()
        end
        
        -- Mini gösterge oluştur
        FIB.MiniIndicator = vgui.Create("DButton")
        FIB.MiniIndicator:SetSize(200, 40)
        FIB.MiniIndicator:SetPos(ScrW() - 210, 10)
        FIB.MiniIndicator:SetText("FIB SISTEM")
        FIB.MiniIndicator:SetTextColor(Color(255, 255, 255))
        FIB.MiniIndicator:SetFont("FIB_Menu_Text")
        FIB.MiniIndicator.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 120, 255, 200))
            
            -- Yanıp sönen efekt
            local alpha = math.sin(CurTime() * 3) * 50 + 50
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, alpha))
            
            -- Minimize ikonu
            draw.SimpleText("▼", "FIB_Menu_Text", w - 20, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        FIB.MiniIndicator.DoClick = function()
            if IsValid(frame) then
                frame:SetVisible(true)
            end
            FIB.MiniIndicator:Remove()
            FIB.MiniIndicator = nil
        end
    end
    
    -- Tab sistemi
    local tabs = {
        {id = "dashboard", name = "DASHBOARD", icon = "◉", access = "all"},
        {id = "undercover", name = "GIZLI MOD", icon = "◎", access = "all"},
        {id = "communication", name = "ILETISIM", icon = "✉", access = "all"},
        {id = "missions", name = "GOREVLER", icon = "⚡", access = "all"},
        {id = "department", name = "DEPARTMAN", icon = "⚙", access = "chief"}
    }
    
    -- Sol menü - Tab butonları
    local yPos = 100
    for _, tab in ipairs(tabs) do
        -- Erişim kontrolü
        if not (tab.access == "chief" and LocalPlayer().FIBRank ~= "Sef") then
            local tabBtn = vgui.Create("DButton", frame)
            tabBtn:SetSize(180, 45)
            tabBtn:SetPos(10, yPos)
            tabBtn:SetText("")
            tabBtn.TabData = tab
            tabBtn.HoverAnim = 0
            tabBtn.Paint = function(self, w, h)
                self.HoverAnim = math.Approach(self.HoverAnim, self:IsHovered() and 1 or 0, FrameTime() * 5)
                
                -- Aktif veya hover durumu
                local isActive = activeTab == tab.id
                local bgAlpha = isActive and 200 or (100 + self.HoverAnim * 50)
                local bgColor = isActive and FIB.Config.Colors.accent or Color(30, 40, 60)
                
                draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(bgColor, bgAlpha))
                
                -- İkon
                draw.SimpleText(tab.icon, "FIB_Menu_Tab", 15, h/2, Color(255, 255, 255, 200 + self.HoverAnim * 55), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Metin
                local textColor = isActive and Color(255, 255, 255) or Color(200, 200, 200, 200 + self.HoverAnim * 55)
                draw.SimpleText(tab.name, "FIB_Menu_Tab", 45, h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Sol kenarlık (aktif göstergesi)
                if isActive then
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawRect(0, 5, 3, h - 10)
                end
            end
            tabBtn.DoClick = function()
                activeTab = tab.id
                -- Tüm panelleri gizle
                for id, panel in pairs(tabPanels) do
                    if IsValid(panel) then
                        panel:SetVisible(false)
                    end
                end
                -- Seçili paneli göster
                if IsValid(tabPanels[tab.id]) then
                    tabPanels[tab.id]:SetVisible(true)
                end
            end
            
            tabButtons[tab.id] = tabBtn
            yPos = yPos + 50
        end
    end
    
    -- İçerik alanı
    local contentArea = vgui.Create("DPanel", frame)
    contentArea:SetSize(frame:GetWide() - 210, frame:GetTall() - 100)
    contentArea:SetPos(200, 90)
    contentArea.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(10, 15, 25, 200))
    end
-- PARÇA 2/4 (Satır 401-800)
    
    -- DASHBOARD PANELİ
    local dashboardPanel = vgui.Create("DPanel", contentArea)
    dashboardPanel:Dock(FILL)
    dashboardPanel:DockMargin(10, 10, 10, 10)
    dashboardPanel:SetVisible(true)
    tabPanels["dashboard"] = dashboardPanel
    dashboardPanel.Paint = function() end
    
    -- Scroll panel
    local dashScroll = vgui.Create("DScrollPanel", dashboardPanel)
    dashScroll:Dock(FILL)
    
    -- Dashboard içeriği
    local dashContent = dashScroll:Add("DPanel")
    dashContent:SetSize(dashScroll:GetWide(), 1000)
    dashContent:Dock(TOP)
    dashContent.Paint = function() end
    
    -- Dashboard başlık
    local dashTitle = dashContent:Add("DLabel")
    dashTitle:SetPos(10, 10)
    dashTitle:SetSize(400, 30)
    dashTitle:SetText("SISTEM DURUMU")
    dashTitle:SetFont("FIB_Menu_Section")
    dashTitle:SetTextColor(FIB.Config.Colors.accent)
    
    -- İstatistik kartları
    local stats = {
        {title = "ONLINE AJANLAR", value = "0", color = FIB.Config.Colors.success},
        {title = "AKTIF GOREVLER", value = "0", color = FIB.Config.Colors.warning},
        {title = "GIZLI MODDAKILER", value = "0", color = FIB.Config.Colors.accent},
        {title = "SISTEM GUVENLIGI", value = "%100", color = FIB.Config.Colors.success}
    }
    
    for i, stat in ipairs(stats) do
        local statCard = dashContent:Add("DPanel")
        statCard:SetSize(190, 120)
        statCard:SetPos(10 + ((i-1) * 200), 50)
        statCard.AnimValue = 0
        statCard.Paint = function(self, w, h)
            -- Kart arka planı
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 30, 45, 200))
            
            -- Üst renkli bar
            draw.RoundedBoxEx(8, 0, 0, w, 5, stat.color, true, true, false, false)
            
            -- Başlık
            draw.SimpleText(stat.title, "FIB_Menu_Small", w/2, 25, FIB.Config.Colors.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Değer
            local displayValue = stat.value
            draw.SimpleText(displayValue, "FIB_Menu_Stats", w/2, 65, stat.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Alt bilgi
            draw.SimpleText("Son guncelleme: " .. os.date("%H:%M"), "FIB_Menu_Small", w/2, 95, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        statCard.StatData = stat
    end
    
    -- Online ajanlar listesi
    local agentListTitle = dashContent:Add("DLabel")
    agentListTitle:SetPos(10, 200)
    agentListTitle:SetSize(400, 30)
    agentListTitle:SetText("ONLINE AJANLAR")
    agentListTitle:SetFont("FIB_Menu_Section")
    agentListTitle:SetTextColor(FIB.Config.Colors.accent)
    
    local agentList = dashContent:Add("DListView")
    agentList:SetPos(10, 240)
    agentList:SetSize(380, 250)
    agentList:SetMultiSelect(false)
    agentList:AddColumn("Isim"):SetWidth(140)
    agentList:AddColumn("Rutbe"):SetWidth(90)
    agentList:AddColumn("Durum"):SetWidth(80)
    agentList:AddColumn("Konum"):SetWidth(70)
    
    -- Global referans (sync için)
    FIB.AgentListView = agentList
    
    -- Liste arka plan rengi
    agentList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Header (başlık) renkleri
    for _, col in pairs(agentList.Columns) do
        col.Header.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 30, 45, 200))
            draw.SimpleText(self:GetText(), "FIB_Menu_Small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        col.Header:SetTextColor(Color(255, 255, 255))
    end
    
    -- Satır renkleri
    agentList.OnRowSelected = function(self, rowIndex, row)
        -- Seçili satır
    end
    
    agentList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Line paint override
    local oldAddLine = agentList.AddLine
    agentList.AddLine = function(self, ...)
        local line = oldAddLine(self, ...)
        
        -- Satır arka plan ve metin renkleri
        line.Paint = function(pnl, w, h)
            if pnl:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 50))
            elseif pnl:IsSelected() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 100))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
            end
        end
        
        -- Her sütunun metin rengini beyaz yap
        for _, col in pairs(line.Columns) do
            col:SetTextColor(Color(255, 255, 255))
            col:SetFont("FIB_Menu_Small")
        end
        
        return line
    end
    
    -- Son aktiviteler
    local activityTitle = dashContent:Add("DLabel")
    activityTitle:SetPos(410, 200)
    activityTitle:SetSize(400, 30)
    activityTitle:SetText("SON AKTIVITELER")
    activityTitle:SetFont("FIB_Menu_Section")
    activityTitle:SetTextColor(FIB.Config.Colors.accent)
    
    local activityList = dashContent:Add("DScrollPanel")
    activityList:SetPos(410, 240)
    activityList:SetSize(380, 250)
    activityList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Global referans (sync için)
    FIB.ActivityList = activityList
    
    -- Aktivite örnekleri
    local activities = {
        {time = os.date("%H:%M"), text = "Sistem baslatildi", color = FIB.Config.Colors.success},
        {time = os.date("%H:%M"), text = LocalPlayer():Nick() .. " giris yapti", color = FIB.Config.Colors.accent},
        {time = os.date("%H:%M"), text = "Guvenlik protokolleri aktif", color = FIB.Config.Colors.warning}
    }
    
    for i, activity in ipairs(activities) do
        local actPanel = activityList:Add("DPanel")
        actPanel:SetSize(360, 30)
        actPanel:Dock(TOP)
        actPanel:DockMargin(5, 5, 5, 0)
        actPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
            draw.SimpleText(activity.time, "FIB_Menu_Small", 10, h/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(activity.text, "FIB_Menu_Small", 60, h/2, activity.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Sistem bilgileri
    local sysInfoTitle = dashContent:Add("DLabel")
    sysInfoTitle:SetPos(10, 510)
    sysInfoTitle:SetSize(400, 30)
    sysInfoTitle:SetText("SISTEM BILGILERI")
    sysInfoTitle:SetFont("FIB_Menu_Section")
    sysInfoTitle:SetTextColor(FIB.Config.Colors.accent)
    
    local sysInfo = dashContent:Add("DPanel")
    sysInfo:SetPos(10, 550)
    sysInfo:SetSize(780, 100)
    sysInfo.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
        
        -- Bilgiler
        draw.SimpleText("FIB Sistem Versiyonu: 1.0", "FIB_Menu_Text", 20, 25, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT)
        draw.SimpleText("Guvenlik Durumu: AKTIF", "FIB_Menu_Text", 20, 50, FIB.Config.Colors.success, TEXT_ALIGN_LEFT)
        draw.SimpleText("Sifreleme: 256-bit AES", "FIB_Menu_Text", 20, 75, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT)
        
        draw.SimpleText("Sunucu: " .. game.GetIPAddress(), "FIB_Menu_Text", 300, 25, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT)
        draw.SimpleText("Harita: " .. game.GetMap(), "FIB_Menu_Text", 300, 50, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT)
        draw.SimpleText("Oyuncu: " .. #player.GetAll() .. "/" .. game.MaxPlayers(), "FIB_Menu_Text", 300, 75, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT)
        
        draw.SimpleText("Kullanici: " .. LocalPlayer():Nick(), "FIB_Menu_Text", 550, 25, FIB.Config.Colors.text, TEXT_ALIGN_LEFT)
        draw.SimpleText("Rutbe: " .. (LocalPlayer().FIBRank or "Ajan"), "FIB_Menu_Text", 550, 50, FIB.Config.Colors.warning, TEXT_ALIGN_LEFT)
        draw.SimpleText("Durum: " .. (LocalPlayer().FIBUndercover and "Gizli Mod" or "Normal"), "FIB_Menu_Text", 550, 75, LocalPlayer().FIBUndercover and FIB.Config.Colors.error or FIB.Config.Colors.success, TEXT_ALIGN_LEFT)
    end
    
    -- GİZLİ MOD PANELİ
    local undercoverPanel = vgui.Create("DPanel", contentArea)
    undercoverPanel:Dock(FILL)
    undercoverPanel:DockMargin(10, 10, 10, 10)
    undercoverPanel:SetVisible(false)
    tabPanels["undercover"] = undercoverPanel
    undercoverPanel.Paint = function(self, w, h)
        draw.SimpleText("GIZLI MOD YONETIMI", "FIB_Menu_Section", 20, 20, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawLine(20, 45, 250, 45)
        
        -- Durum
        local isUndercover = LocalPlayer().FIBUndercover or false
        local statusText = isUndercover and "GIZLI MOD AKTIF" or "NORMAL MOD"
        local statusColor = isUndercover and FIB.Config.Colors.warning or FIB.Config.Colors.success
        
        draw.RoundedBox(8, 20, 60, 300, 100, Color(20, 30, 45, 200))
        draw.SimpleText("MEVCUT DURUM:", "FIB_Menu_Text", 170, 90, FIB.Config.Colors.text_dim, TEXT_ALIGN_CENTER)
        draw.SimpleText(statusText, "FIB_Menu_Section", 170, 120, statusColor, TEXT_ALIGN_CENTER)
    end
    
    -- Gizli mod toggle butonu
    local toggleUndercoverBtn = vgui.Create("DButton", undercoverPanel)
    toggleUndercoverBtn:SetPos(20, 180)
    toggleUndercoverBtn:SetSize(300, 50)
    toggleUndercoverBtn:SetText("")
    toggleUndercoverBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
        draw.RoundedBox(8, 0, 0, w, h, col)
        
        local btnText = LocalPlayer().FIBUndercover and "GIZLI MODU KAPAT" or "GIZLI MODA GEC"
        draw.SimpleText(btnText, "FIB_Menu_Tab", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    toggleUndercoverBtn.DoClick = function()
        net.Start("FIB_ToggleUndercover")
        net.SendToServer()
        timer.Simple(0.5, function()
            if IsValid(undercoverPanel) then
                undercoverPanel:InvalidateLayout()
            end
        end)
    end
    
    -- İLETİŞİM PANELİ
    local commPanel = vgui.Create("DPanel", contentArea)
    commPanel:Dock(FILL)
    commPanel:DockMargin(10, 10, 10, 10)
    commPanel:SetVisible(false)
    tabPanels["communication"] = commPanel
    commPanel.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(8, 0, 0, w, h, Color(10, 15, 25, 100))
    end
    
    -- Başlık paneli
    local commHeader = vgui.Create("DPanel", commPanel)
    commHeader:Dock(TOP)
    commHeader:SetTall(70)
    commHeader.Paint = function(self, w, h)
        -- Başlık
        draw.SimpleText("FIB OZEL ILETISIM KANALI", "FIB_Menu_Section", 20, 20, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawLine(20, 45, 300, 45)
        
        -- Alt bilgi
        draw.SimpleText("Bu kanal tum FIB ajanlari tarafindan gorulebilir", "FIB_Menu_Small", 20, 50, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT)
    end
    
    -- Şef için temizle butonu (header'a ekle)
    if LocalPlayer().FIBRank == "Sef" then
        local clearBtn = vgui.Create("DButton", commHeader)
        clearBtn:SetPos(commHeader:GetWide() - 160, 20)
        clearBtn:SetSize(140, 30)
        clearBtn:SetText("SOHBETI TEMIZLE")
        clearBtn:SetTextColor(Color(255, 255, 255))
        clearBtn:SetFont("FIB_Menu_Small")
        clearBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(200, 50, 50) or Color(150, 50, 50)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        clearBtn.DoClick = function()
            Derma_Query(
                "Tum sohbet gecmisi silinecek. Emin misiniz?",
                "Sohbet Temizleme Onayi",
                "Evet, Temizle",
                function()
                    net.Start("FIB_ClearChat")
                    net.SendToServer()
                    
                    -- Local olarak da temizle
                    if IsValid(FIB.ChatContent) then
                        FIB.ChatContent:Clear()
                        FIB.ChatContent:SetTall(0)
                    end
                end,
                "Iptal"
            )
        end
        
        -- Panel boyutu değiştiğinde butonu yeniden konumlandır
        commHeader.PerformLayout = function(self)
            if IsValid(clearBtn) then
                clearBtn:SetPos(self:GetWide() - 160, 20)
            end
        end
    end
-- PARÇA 3/4 (Satır 801-1200)
    
    -- Alt input container (önce oluştur ki chat scroll doğru boyutlansın)
    local inputContainer = vgui.Create("DPanel", commPanel)
    inputContainer:Dock(BOTTOM)
    inputContainer:SetTall(80)
    inputContainer:DockMargin(10, 5, 10, 10)
    inputContainer.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Chat scroll panel
    local chatScroll = vgui.Create("DScrollPanel", commPanel)
    chatScroll:Dock(FILL)
    chatScroll:DockMargin(10, 5, 10, 5)
    chatScroll.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(10, 15, 25, 200))
        
        -- İç kenarlık
        surface.SetDrawColor(FIB.Config.Colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Scrollbar stilleri
    local scrollBar = chatScroll:GetVBar()
    scrollBar:SetWide(10)
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    scrollBar.btnUp.Paint = function() end
    scrollBar.btnDown.Paint = function() end
    
    -- Chat içeriği container
    local chatContent = chatScroll:Add("DPanel")
    chatContent:Dock(TOP)
    chatContent:SetTall(0) -- Otomatik büyüyecek
    chatContent.Paint = function() end
    
    -- Global referans (mesaj eklemek için)
    FIB.ChatContent = chatContent
    FIB.ChatScroll = chatScroll
    
    -- Mesaj ekleme fonksiyonu
    function FIB.AddChatMessage(sender, message, rank, time, isUndercover)
        if not IsValid(FIB.ChatContent) then return end
        
        local msgPanel = FIB.ChatContent:Add("DPanel")
        msgPanel:Dock(TOP)
        msgPanel:DockMargin(5, 5, 5, 0)
        msgPanel:SetTall(70) -- Biraz daha yüksek yaptım
        
        msgPanel.Paint = function(self, w, h)
            -- Arka plan
            local bgColor = sender == LocalPlayer():Nick() and Color(0, 60, 120, 50) or Color(20, 30, 45, 100)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            -- Sol kenarlık (rank göstergesi)
            local rankColor = Color(100, 100, 100)
            if rank == "Sef" then
                rankColor = Color(255, 200, 0)
            elseif rank == "Kidemli Ajan" then
                rankColor = Color(0, 200, 255)
            else
                rankColor = Color(100, 150, 200)
            end
            surface.SetDrawColor(rankColor)
            surface.DrawRect(0, 0, 3, h)
            
            -- Üst bilgi (isim, rank, zaman)
            draw.SimpleText(sender, "FIB_Menu_Text", 10, 8, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            
            -- Rank
            local nameWidth = surface.GetTextSize(sender)
            draw.SimpleText("[" .. rank .. "]", "FIB_Menu_Small", 15 + nameWidth, 9, rankColor, TEXT_ALIGN_LEFT)
            
            -- Gizli mod göstergesi
            if isUndercover then
                draw.SimpleText("[GIZLI MOD]", "FIB_Menu_Small", 200, 9, Color(255, 100, 0), TEXT_ALIGN_LEFT)
            end
            
            -- Zaman
            draw.SimpleText(time, "FIB_Menu_Small", w - 10, 8, Color(150, 150, 150), TEXT_ALIGN_RIGHT)
            
            -- Mesaj (word wrap için)
            local lines = {}
            local words = string.Explode(" ", message)
            local currentLine = ""
            local maxWidth = w - 20
            
            surface.SetFont("FIB_Menu_Text")
            
            for _, word in ipairs(words) do
                local testLine = currentLine == "" and word or (currentLine .. " " .. word)
                local tw, th = surface.GetTextSize(testLine)
                
                if tw > maxWidth then
                    if currentLine ~= "" then
                        table.insert(lines, currentLine)
                        currentLine = word
                    else
                        table.insert(lines, word)
                        currentLine = ""
                    end
                else
                    currentLine = testLine
                end
            end
            
            if currentLine ~= "" then
                table.insert(lines, currentLine)
            end
            
            -- Mesajı çiz (max 2 satır)
            for i = 1, math.min(2, #lines) do
                draw.SimpleText(lines[i], "FIB_Menu_Text", 10, 25 + (i-1) * 18, Color(220, 220, 220), TEXT_ALIGN_LEFT)
            end
            
            if #lines > 2 then
                draw.SimpleText("...", "FIB_Menu_Text", 10, 25 + 2 * 18, Color(150, 150, 150), TEXT_ALIGN_LEFT)
            end
        end
        
        -- Content yüksekliğini güncelle
        local totalHeight = 0
        for _, child in ipairs(FIB.ChatContent:GetChildren()) do
            totalHeight = totalHeight + child:GetTall() + 5
        end
        FIB.ChatContent:SetTall(totalHeight)
        
        -- Otomatik scroll to bottom
        timer.Simple(0.05, function()
            if IsValid(FIB.ChatScroll) then
                FIB.ChatScroll:GetVBar():SetScroll(FIB.ChatScroll:GetCanvas():GetTall())
            end
        end)
    end
    
    -- Mesaj giriş alanı
    local messageEntry = vgui.Create("DTextEntry", inputContainer)
    messageEntry:Dock(FILL)
    messageEntry:DockMargin(10, 10, 120, 10)
    messageEntry:SetPlaceholderText("Mesajinizi yazin... (Enter ile gonder)")
    messageEntry:SetFont("FIB_Menu_Text")
    messageEntry:SetMultiline(true)
    messageEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(20, 30, 45, 200))
        
        -- Focus efekti
        if self:IsEditing() then
            surface.SetDrawColor(FIB.Config.Colors.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        
        self:DrawTextEntryText(Color(255, 255, 255), FIB.Config.Colors.accent, Color(255, 255, 255))
    end
    
    -- Gönder butonu
    local sendBtn = vgui.Create("DButton", inputContainer)
    sendBtn:Dock(RIGHT)
    sendBtn:DockMargin(0, 10, 10, 10)
    sendBtn:SetWide(100)
    sendBtn:SetText("GONDER")
    sendBtn:SetTextColor(Color(255, 255, 255))
    sendBtn:SetFont("FIB_Menu_Text")
    sendBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
        draw.RoundedBox(6, 0, 0, w, h, col)
        
        -- İkon
        draw.SimpleText("➤", "FIB_Menu_Text", w - 20, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Mesaj gönderme fonksiyonu
    local function SendMessage()
        local msg = messageEntry:GetValue()
        if msg ~= "" and string.Trim(msg) ~= "" then
            -- Server'a gönder
            net.Start("FIB_SendChatMessage")
            net.WriteString(msg)
            net.SendToServer()
            
            messageEntry:SetValue("")
            messageEntry:RequestFocus()
        end
    end
    
    sendBtn.DoClick = SendMessage
    
    -- Enter ile gönderme
    messageEntry.OnEnter = SendMessage
    
    -- SHIFT+Enter için yeni satır desteği
    messageEntry.OnKeyCodeTyped = function(self, keyCode)
        if keyCode == KEY_ENTER and not input.IsShiftDown() then
            SendMessage()
            return true
        end
    end
    
    -- Chat geçmişini yükle (menü açıldığında)
    timer.Simple(0.5, function()
        if LocalPlayer().FIBAuthenticated then
            net.Start("FIB_RequestChatHistory")
            net.SendToServer()
        end
    end)
    
    -- GÖREV PANELİ - YENİLENMİŞ VE DÜZELTİLMİŞ
    local missionPanel = vgui.Create("DPanel", contentArea)
    missionPanel:Dock(FILL)
    missionPanel:DockMargin(10, 10, 10, 10)
    missionPanel:SetVisible(false)
    tabPanels["missions"] = missionPanel
    missionPanel.Paint = function() end
    
    -- Görev başlığı
    local missionTitle = missionPanel:Add("DLabel")
    missionTitle:SetPos(20, 20)
    missionTitle:SetSize(400, 30)
    missionTitle:SetText("GOREV YONETIMI")
    missionTitle:SetFont("FIB_Menu_Section")
    missionTitle:SetTextColor(FIB.Config.Colors.accent)
    
    -- Görev listesi
    local missionList = vgui.Create("DListView", missionPanel)
    missionList:SetPos(20, 60)
    missionList:SetSize(contentArea:GetWide() - 60, 300)
    missionList:SetMultiSelect(false)
    
    -- Global referans
    FIB.MissionListView = missionList
    
    -- Sütunları ekle
    local col1 = missionList:AddColumn("Gorev Adi")
    col1:SetWidth(200)
    
    local col2 = missionList:AddColumn("Hedef")
    col2:SetWidth(150)
    
    local col3 = missionList:AddColumn("Oncelik")
    col3:SetWidth(100)
    
    local col4 = missionList:AddColumn("Durum")
    col4:SetWidth(120)
    
    local col5 = missionList:AddColumn("Atanan")
    col5:SetWidth(150)
    
    -- Liste arka planı
    missionList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Header'ları düzelt
    for k, col in pairs(missionList.Columns) do
        if IsValid(col.Header) then
            col.Header:SetFont("FIB_Menu_Small")
            col.Header:SetTextColor(Color(255, 255, 255))
            
            -- Header paint override
            col.Header.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(20, 30, 45, 200))
                
                -- Kenarlık
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            
            col.Header.DoClick = function() end -- Sıralama iptal
        end
    end
    
    -- Line paint override
    local oldMissionAddLine = missionList.AddLine
    missionList.AddLine = function(self, ...)
        local line = oldMissionAddLine(self, ...)
        
        -- Görev verilerini line'a ekle
        line.missionData = {
            name = line:GetColumnText(1),
            target = line:GetColumnText(2),
            priority = line:GetColumnText(3),
            status = line:GetColumnText(4),
            assigned = line:GetColumnText(5)
        }
        
        -- Satır renkleri
        line.Paint = function(pnl, w, h)
            if pnl:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 50))
            elseif pnl:IsSelected() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 100))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
            end
        end
        
        -- Metin renkleri
        for _, col in pairs(line.Columns) do
            col:SetTextColor(Color(255, 255, 255))
            col:SetFont("FIB_Menu_Small")
        end
        
        -- Öncelik renklendir
        if line.Columns[3] then
            local priority = line.Columns[3]:GetText()
            if priority == "KRITIK" then
                line.Columns[3]:SetTextColor(Color(255, 0, 0))
            elseif priority == "YUKSEK" then
                line.Columns[3]:SetTextColor(Color(255, 150, 0))
            elseif priority == "ORTA" then
                line.Columns[3]:SetTextColor(Color(255, 255, 0))
            else
                line.Columns[3]:SetTextColor(Color(100, 255, 100))
            end
        end
        
        -- Durum renklendir
        if line.Columns[4] then
            local status = line.Columns[4]:GetText()
            if status == "Tamamlandi" then
                line.Columns[4]:SetTextColor(Color(100, 255, 100))
            elseif status == "Devam Ediyor" then
                line.Columns[4]:SetTextColor(Color(255, 200, 0))
            elseif status == "Beklemede" then
                line.Columns[4]:SetTextColor(Color(200, 200, 200))
            elseif status == "Iptal" then
                line.Columns[4]:SetTextColor(Color(255, 100, 100))
            else
                line.Columns[4]:SetTextColor(Color(0, 200, 255))
            end
        end
        
        return line
    end
    
    -- ÖRNEK GÖREVLERİ KALDIRDIM - Server'dan gelecek
    -- Server'dan görevleri yükle
    -- ÖRNEK GÖREVLERİ KALDIRDIM - Server'dan gelecek
-- Server'dan görevleri yükle
local function LoadMissions()
    if not IsValid(FIB.MissionListView) then 
        FIB.Missions = FIB.Missions or {}
        return 
    end
    
    -- Safe clear with error handling
    local success, err = pcall(function()
        FIB.MissionListView:Clear()
    end)
    
    if not success then
        print("[FIB] Mission list view is invalid, skipping refresh")
        FIB.MissionListView = nil
        return
    end
    
    for _, mission in ipairs(FIB.Missions or {}) do
        if mission and mission.name then
            local line = FIB.MissionListView:AddLine(
                mission.name or "Isimsiz", 
                mission.target or "Bilinmiyor", 
                mission.priority or "ORTA", 
                mission.status or "Beklemede", 
                mission.assigned or "Atanmadi"
            )
            
            -- Görev verisini satıra ekle
            if line then
                line.missionData = mission
            end
        end
    end
end

-- Global fonksiyon olarak tanımla
FIB.RefreshMissionList = LoadMissions
    
    
    -- İlk yükleme
    timer.Simple(0.5, function()
        LoadMissions()
    end)
-- PARÇA 4/4 (Satır 1201-SON)
    
    -- GÖREV YÖNETİM BUTONLARI - ŞEF VE KIDEMLİ AJAN İÇİN
    if LocalPlayer().FIBRank == "Sef" or LocalPlayer().FIBRank == "Kidemli Ajan" then
        -- Yeni görev oluştur butonu
        local createMissionBtn = vgui.Create("DButton", missionPanel)
        createMissionBtn:SetPos(20, 380)
        createMissionBtn:SetSize(180, 40)
        createMissionBtn:SetText("YENI GOREV OLUSTUR")
        createMissionBtn:SetTextColor(Color(255, 255, 255))
        createMissionBtn:SetFont("FIB_Menu_Text")
        createMissionBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.success
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        createMissionBtn.DoClick = function()
            -- Görev oluşturma penceresi
            local missionDialog = vgui.Create("DFrame")
            missionDialog:SetSize(400, 420)
            missionDialog:Center()
            missionDialog:SetTitle("Yeni Gorev Olustur")
            missionDialog:MakePopup()
            missionDialog.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(20, 30, 45, 250))
                draw.RoundedBoxEx(8, 0, 0, w, 25, Color(0, 120, 255, 200), true, true, false, false)
            end
            
            -- Görev adı
            local nameLabel = vgui.Create("DLabel", missionDialog)
            nameLabel:SetPos(20, 40)
            nameLabel:SetSize(360, 20)
            nameLabel:SetText("Gorev Adi:")
            nameLabel:SetTextColor(Color(255, 255, 255))
            nameLabel:SetFont("FIB_Menu_Text")
            
            local nameEntry = vgui.Create("DTextEntry", missionDialog)
            nameEntry:SetPos(20, 65)
            nameEntry:SetSize(360, 30)
            nameEntry:SetFont("FIB_Menu_Text")
            nameEntry.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(10, 20, 35, 200))
                self:DrawTextEntryText(Color(255, 255, 255), Color(0, 120, 255), Color(255, 255, 255))
            end
            
            -- Hedef
            local targetLabel = vgui.Create("DLabel", missionDialog)
            targetLabel:SetPos(20, 105)
            targetLabel:SetSize(360, 20)
            targetLabel:SetText("Hedef:")
            targetLabel:SetTextColor(Color(255, 255, 255))
            targetLabel:SetFont("FIB_Menu_Text")
            
            local targetEntry = vgui.Create("DTextEntry", missionDialog)
            targetEntry:SetPos(20, 130)
            targetEntry:SetSize(360, 30)
            targetEntry:SetFont("FIB_Menu_Text")
            targetEntry.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(10, 20, 35, 200))
                self:DrawTextEntryText(Color(255, 255, 255), Color(0, 120, 255), Color(255, 255, 255))
            end
            
            -- Öncelik
            local priorityLabel = vgui.Create("DLabel", missionDialog)
            priorityLabel:SetPos(20, 170)
            priorityLabel:SetSize(360, 20)
            priorityLabel:SetText("Oncelik:")
            priorityLabel:SetTextColor(Color(255, 255, 255))
            priorityLabel:SetFont("FIB_Menu_Text")
            
            local priorityCombo = vgui.Create("DComboBox", missionDialog)
            priorityCombo:SetPos(20, 195)
            priorityCombo:SetSize(360, 30)
            priorityCombo:SetFont("FIB_Menu_Text")
            priorityCombo:SetTextColor(Color(255, 255, 255))
            priorityCombo:AddChoice("DUSUK", "DUSUK")
            priorityCombo:AddChoice("ORTA", "ORTA")
            priorityCombo:AddChoice("YUKSEK", "YUKSEK")
            priorityCombo:AddChoice("KRITIK", "KRITIK")
            priorityCombo:SetValue("ORTA")
            
            -- Durum
            local statusLabel = vgui.Create("DLabel", missionDialog)
            statusLabel:SetPos(20, 235)
            statusLabel:SetSize(360, 20)
            statusLabel:SetText("Baslangic Durumu:")
            statusLabel:SetTextColor(Color(255, 255, 255))
            statusLabel:SetFont("FIB_Menu_Text")
            
            local statusCombo = vgui.Create("DComboBox", missionDialog)
            statusCombo:SetPos(20, 260)
            statusCombo:SetSize(360, 30)
            statusCombo:SetFont("FIB_Menu_Text")
            statusCombo:SetTextColor(Color(255, 255, 255))
            statusCombo:AddChoice("Planlama", "Planlama")
            statusCombo:AddChoice("Beklemede", "Beklemede")
            statusCombo:AddChoice("Devam Ediyor", "Devam Ediyor")
            statusCombo:SetValue("Planlama")
            
            -- Ajan ata
            local assignLabel = vgui.Create("DLabel", missionDialog)
            assignLabel:SetPos(20, 300)
            assignLabel:SetSize(360, 20)
            assignLabel:SetText("Ajana Ata (Opsiyonel):")
            assignLabel:SetTextColor(Color(255, 255, 255))
            assignLabel:SetFont("FIB_Menu_Text")
            
            local assignCombo = vgui.Create("DComboBox", missionDialog)
            assignCombo:SetPos(20, 325)
            assignCombo:SetSize(360, 30)
            assignCombo:SetFont("FIB_Menu_Text")
            assignCombo:SetTextColor(Color(255, 255, 255))
            assignCombo:AddChoice("Atanmadi", "")
            
            -- FIB.OnlineAgents'tan ajanları ekle
            for _, agent in ipairs(FIB.OnlineAgents or {}) do
                if agent and agent.nick then
                    assignCombo:AddChoice(agent.nick, agent.nick)
                end
            end
            assignCombo:SetValue("Atanmadi")
            
            -- Oluştur butonu
            local createBtn = vgui.Create("DButton", missionDialog)
            createBtn:SetPos(20, 370)
            createBtn:SetSize(360, 35)
            createBtn:SetText("GOREVI OLUSTUR")
            createBtn:SetTextColor(Color(255, 255, 255))
            createBtn:SetFont("FIB_Menu_Text")
            createBtn.Paint = function(self, w, h)
                local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
                draw.RoundedBox(6, 0, 0, w, h, col)
            end
            createBtn.DoClick = function()
                local name = nameEntry:GetValue()
                local target = targetEntry:GetValue()
                local priority = priorityCombo:GetValue()
                local status = statusCombo:GetValue()
                local assigned = assignCombo:GetValue()
                
                if name ~= "" then
                    -- Server'a gönder
                    net.Start("FIB_CreateMission")
                    net.WriteString(name)
                    net.WriteString(target ~= "" and target or "Bilinmiyor")
                    net.WriteString(priority)
                    net.WriteString(status)
                    net.WriteString(assigned ~= "Atanmadi" and assigned or "")
                    net.SendToServer()
                    
                    -- Dialogu kapat
                    missionDialog:Close()
                    
                    -- Bildirim
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Gorev olusturma istegi gonderildi!")
                else
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Gorev adi bos olamaz!")
                end
            end
        end
        
        -- Görevi sil butonu
        local deleteMissionBtn = vgui.Create("DButton", missionPanel)
        deleteMissionBtn:SetPos(210, 380)
        deleteMissionBtn:SetSize(180, 40)
        deleteMissionBtn:SetText("SECILI GOREVI SIL")
        deleteMissionBtn:SetTextColor(Color(255, 255, 255))
        deleteMissionBtn:SetFont("FIB_Menu_Text")
        deleteMissionBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.error
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        deleteMissionBtn.DoClick = function()
            local selected = missionList:GetSelectedLine()
            if selected then
                local line = missionList:GetLine(selected)
                if line and line.missionData then
                    local missionName = line.missionData.name or line:GetColumnText(1)
                    
                    -- Onay iste
                    Derma_Query(
                        "'" .. missionName .. "' gorevini silmek istediginize emin misiniz?",
                        "Gorev Silme Onayi",
                        "Evet, Sil",
                        function()
                            -- Server'a gönder
                            net.Start("FIB_DeleteMission")
                            net.WriteString(missionName)
                            net.SendToServer()
                            
                            chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 200, 0), "Gorev silme istegi gonderildi!")
                        end,
                        "Iptal"
                    )
                end
            else
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Lutfen bir gorev secin!")
            end
        end
        
        -- Görev durumu düzenle butonu (SADECE ŞEF İÇİN)
        if LocalPlayer().FIBRank == "Sef" then
            local editStatusBtn = vgui.Create("DButton", missionPanel)
            editStatusBtn:SetPos(400, 380)
            editStatusBtn:SetSize(180, 40)
            editStatusBtn:SetText("DURUMU DUZENLE")
            editStatusBtn:SetTextColor(Color(255, 255, 255))
            editStatusBtn:SetFont("FIB_Menu_Text")
            editStatusBtn.Paint = function(self, w, h)
                local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.warning
                draw.RoundedBox(6, 0, 0, w, h, col)
            end
            editStatusBtn.DoClick = function()
                local selected = missionList:GetSelectedLine()
                if not selected then
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Lutfen bir gorev secin!")
                    return
                end
                
                local selectedLine = missionList:GetLine(selected)
                if not selectedLine or not selectedLine.missionData then return end
                
                -- Durum düzenleme penceresi
                local statusDialog = vgui.Create("DFrame")
                statusDialog:SetSize(350, 250)
                statusDialog:Center()
                statusDialog:SetTitle("Gorev Durumu Duzenle")
                statusDialog:MakePopup()
                statusDialog.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(20, 30, 45, 250))
                    draw.RoundedBoxEx(8, 0, 0, w, 25, Color(0, 120, 255, 200), true, true, false, false)
                end
                
                -- Görev adı göster
                local missionNameLabel = vgui.Create("DLabel", statusDialog)
                missionNameLabel:SetPos(20, 40)
                missionNameLabel:SetSize(310, 40)
                missionNameLabel:SetText("Gorev: " .. (selectedLine.missionData.name or selectedLine:GetColumnText(1)))
                missionNameLabel:SetTextColor(Color(255, 255, 255))
                missionNameLabel:SetFont("FIB_Menu_Text")
                missionNameLabel:SetWrap(true)
                
                -- Mevcut durum
                local currentStatusLabel = vgui.Create("DLabel", statusDialog)
                currentStatusLabel:SetPos(20, 85)
                currentStatusLabel:SetSize(310, 20)
                currentStatusLabel:SetText("Mevcut Durum: " .. (selectedLine.missionData.status or selectedLine:GetColumnText(4)))
                currentStatusLabel:SetTextColor(Color(200, 200, 200))
                currentStatusLabel:SetFont("FIB_Menu_Small")
                
                -- Yeni durum seçimi
                local newStatusLabel = vgui.Create("DLabel", statusDialog)
                newStatusLabel:SetPos(20, 110)
                newStatusLabel:SetSize(310, 20)
                newStatusLabel:SetText("Yeni Durum:")
                newStatusLabel:SetTextColor(Color(255, 255, 255))
                newStatusLabel:SetFont("FIB_Menu_Text")
                
                local statusCombo = vgui.Create("DComboBox", statusDialog)
                statusCombo:SetPos(20, 135)
                statusCombo:SetSize(310, 30)
                statusCombo:SetFont("FIB_Menu_Text")
                statusCombo:SetTextColor(Color(255, 255, 255))
                statusCombo:AddChoice("Planlama", "Planlama")
                statusCombo:AddChoice("Beklemede", "Beklemede")
                statusCombo:AddChoice("Devam Ediyor", "Devam Ediyor")
                statusCombo:AddChoice("Tamamlandi", "Tamamlandi")
                statusCombo:AddChoice("Iptal", "Iptal")
                statusCombo:SetValue(selectedLine.missionData.status or selectedLine:GetColumnText(4))
                
                -- Güncelle butonu
                local updateBtn = vgui.Create("DButton", statusDialog)
                updateBtn:SetPos(20, 180)
                updateBtn:SetSize(310, 35)
                updateBtn:SetText("DURUMU GUNCELLE")
                updateBtn:SetTextColor(Color(255, 255, 255))
                updateBtn:SetFont("FIB_Menu_Text")
                updateBtn.Paint = function(self, w, h)
                    local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
                    draw.RoundedBox(6, 0, 0, w, h, col)
                end
                updateBtn.DoClick = function()
                    local newStatus = statusCombo:GetValue()
                    
                    -- Server'a gönder
                    net.Start("FIB_UpdateMissionStatus")
                    net.WriteString(selectedLine.missionData.name or selectedLine:GetColumnText(1))
                    net.WriteString(newStatus)
                    net.SendToServer()
                    
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Gorev durumu guncelleme istegi gonderildi!")
                    statusDialog:Close()
                end
            end
        end
    else
        -- Şef/Kıdemli değilse bilgilendirme
        local infoLabel = vgui.Create("DLabel", missionPanel)
        infoLabel:SetPos(20, 380)
        infoLabel:SetSize(600, 30)
        infoLabel:SetText("* Gorev olusturma/silme: Sef ve Kidemli Ajan | Durum duzenleme: Sadece Sef")
        infoLabel:SetTextColor(Color(255, 200, 0))
        infoLabel:SetFont("FIB_Menu_Text")
    end
    
    -- DEPARTMAN YÖNETİMİ
    local deptPanel = vgui.Create("DPanel", contentArea)
    deptPanel:Dock(FILL)
    deptPanel:DockMargin(10, 10, 10, 10)
    deptPanel:SetVisible(false)
    tabPanels["department"] = deptPanel
    deptPanel.Paint = function(self, w, h)
        draw.SimpleText("DEPARTMAN YONETIMI", "FIB_Menu_Section", 20, 20, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT)
        draw.SimpleText("(SEF YETKISI)", "FIB_Menu_Small", 260, 22, FIB.Config.Colors.error, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawLine(20, 45, 350, 45)
    end
    
    -- Ajan listesi
    local agentManageList = vgui.Create("DListView", deptPanel)
    agentManageList:SetPos(20, 60)
    agentManageList:SetSize(400, 400)
    agentManageList:SetMultiSelect(false)
    agentManageList:AddColumn("SteamID"):SetWidth(150)
    agentManageList:AddColumn("Kullanici"):SetWidth(100)
    agentManageList:AddColumn("Rutbe"):SetWidth(100)
    agentManageList:AddColumn("Durum"):SetWidth(50)
    
    -- Global referans (sync için)
    FIB.DepartmentListView = agentManageList
    
    -- Liste arka planı
    agentManageList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 20, 30, 150))
    end
    
    -- Header renkleri
    for _, col in pairs(agentManageList.Columns) do
        col.Header.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 30, 45, 200))
            draw.SimpleText(self:GetText(), "FIB_Menu_Small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        col.Header:SetTextColor(Color(255, 255, 255))
    end
    
    -- Line paint override
    local oldDeptAddLine = agentManageList.AddLine
    agentManageList.AddLine = function(self, ...)
        local line = oldDeptAddLine(self, ...)
        
        -- Satır renkleri
        line.Paint = function(pnl, w, h)
            if pnl:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 50))
            elseif pnl:IsSelected() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 120, 255, 100))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
            end
        end
        
        -- Metin renkleri
        for _, col in pairs(line.Columns) do
            col:SetTextColor(Color(255, 255, 255))
            col:SetFont("FIB_Menu_Small")
        end
        
        return line
    end
    
    -- Config'den ajanları yükle
    for steamid, data in pairs(FIB.Config.Users) do
        -- FIB.OnlineAgents'tan kontrol et
        local isOnline = false
        for _, agent in ipairs(FIB.OnlineAgents or {}) do
            if agent.steamid == steamid then
                isOnline = true
                break
            end
        end
        agentManageList:AddLine(steamid, data.username, data.rank, isOnline and "Online" or "Offline")
    end
    
    -- Ajan ekle butonu
    local addAgentBtn = vgui.Create("DButton", deptPanel)
    addAgentBtn:SetPos(440, 60)
    addAgentBtn:SetSize(150, 40)
    addAgentBtn:SetText("AJAN EKLE")
    addAgentBtn:SetTextColor(Color(255, 255, 255))
    addAgentBtn:SetFont("FIB_Menu_Text")
    addAgentBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.success
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    addAgentBtn.DoClick = function()
        -- Ajan ekleme kodu (önceki kodda mevcut, sadece referans)
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 255, 255), "Ajan ekleme penceresi aciliyor...")
    end
    
    -- Ajan çıkar butonu
    local removeAgentBtn = vgui.Create("DButton", deptPanel)
    removeAgentBtn:SetPos(440, 110)
    removeAgentBtn:SetSize(150, 40)
    removeAgentBtn:SetText("AJAN CIKAR")
    removeAgentBtn:SetTextColor(Color(255, 255, 255))
    removeAgentBtn:SetFont("FIB_Menu_Text")
    removeAgentBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.error
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    removeAgentBtn.DoClick = function()
        local selected = agentManageList:GetSelectedLine()
        if selected then
            local line = agentManageList:GetLine(selected)
            local steamid = line:GetColumnText(1)
            local username = line:GetColumnText(2)
            
            -- Onay penceresi
            Derma_Query(
                "'" .. username .. "' (" .. steamid .. ") sistemden cikarilacak. Emin misiniz?",
                "Ajan Cikarma Onayi",
                "Evet, Cikar",
                function()
                    net.Start("FIB_RemoveAgent")
                    net.WriteString(steamid)
                    net.SendToServer()
                    
                    agentManageList:RemoveLine(selected)
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 200, 0), username .. " sistemden cikarildi!")
                end,
                "Iptal"
            )
        else
            chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Lutfen bir ajan secin!")
        end
    end
    
    -- Listeyi yenile butonu
    local refreshBtn = vgui.Create("DButton", deptPanel)
    refreshBtn:SetPos(440, 160)
    refreshBtn:SetSize(150, 40)
    refreshBtn:SetText("LISTEYI YENILE")
    refreshBtn:SetTextColor(Color(255, 255, 255))
    refreshBtn:SetFont("FIB_Menu_Text")
    refreshBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or Color(100, 100, 100)
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    refreshBtn.DoClick = function()
        -- Sync isteği gönder
        net.Start("FIB_RequestSync")
        net.SendToServer()
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Liste guncelleniyor...")
    end
    
    -- İlk açılışta dashboard'u göster
    if IsValid(tabPanels["dashboard"]) then
        tabPanels["dashboard"]:SetVisible(true)
    end
    
    -- Frame kapatıldığında timer'ı temizle
-- Frame kapatıldığında timer'ı temizle
    frame.OnClose = function()
    timer.Remove("FIB_UpdateStats")
    
    -- Panel referanslarını temizle (NULL hatasını önlemek için)
    FIB.MissionListView = nil
    FIB.AgentListView = nil
    FIB.DepartmentListView = nil
    FIB.ActivityList = nil
    FIB.ChatContent = nil
    FIB.ChatScroll = nil
    
    -- Mini indicator varsa kaldır
        if IsValid(FIB.MiniIndicator) then
            FIB.MiniIndicator:Remove()
            FIB.MiniIndicator = nil
        end
    end
    
    -- İstatistikleri güncelle
    FIB.MainMenuStats = stats
    timer.Create("FIB_UpdateStats", 1, 0, function()
        if not IsValid(frame) then
            timer.Remove("FIB_UpdateStats")
            return
        end
        
        -- FIB.OnlineAgents KULLAN
        local onlineAgents = #(FIB.OnlineAgents or {})
        local undercoverCount = 0
        
        -- Gizli moddakileri say
        for _, agent in ipairs(FIB.OnlineAgents or {}) do
            if agent.undercover then
                undercoverCount = undercoverCount + 1
            end
        end
        
        -- İstatistikleri güncelle
        if FIB.MainMenuStats then
            FIB.MainMenuStats[1].value = tostring(onlineAgents)
            FIB.MainMenuStats[3].value = tostring(undercoverCount)
        end
    end)
end