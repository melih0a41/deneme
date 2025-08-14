-- fib_sistem/lua/autorun/client/cl_fib_mainmenu.lua

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
    
    FIB.MainMenu = frame
    
    -- Seçili sekme
    local activeTab = "dashboard"
    local tabButtons = {}
    local tabPanels = {}
    
    -- Ana panel paint
    frame.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(12, 0, 0, w, h, Color(5, 10, 20, 250))
        
        -- Üst bar
        draw.RoundedBox(12, 0, 0, w, 80, Color(10, 20, 35, 255))
        draw.RoundedBoxEx(12, 0, 0, w, 80, Color(10, 20, 35, 255), true, true, false, false)
        
        -- Logo alanı
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawRect(0, 78, w, 2)
        
        -- Başlık
        draw.SimpleText("FEDERAL ISTIHBARAT BUROSU", "FIB_Menu_Title", 80, 25, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("KOMUTA MERKEZI", "FIB_Menu_Text", 80, 50, FIB.Config.Colors.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
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
    
    -- Kapatma butonu
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
        RunConsoleCommand("fibgec")
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
        draw.SimpleText("FIB OZEL ILETISIM", "FIB_Menu_Section", 20, 20, FIB.Config.Colors.accent, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawLine(20, 45, 250, 45)
    end
    
    -- Chat alanı
    local chatHistory = vgui.Create("DScrollPanel", commPanel)
    chatHistory:SetPos(20, 60)
    chatHistory:SetSize(commPanel:GetWide() - 40, 400)
    chatHistory.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(10, 15, 25, 200))
    end
    
    -- Mesaj gönderme
    local messageEntry = vgui.Create("DTextEntry", commPanel)
    messageEntry:SetPos(20, 470)
    messageEntry:SetSize(commPanel:GetWide() - 140, 40)
    messageEntry:SetPlaceholderText("Mesajinizi yazin...")
    messageEntry:SetFont("FIB_Menu_Text")
    messageEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(20, 30, 45, 200))
        self:DrawTextEntryText(Color(255, 255, 255), FIB.Config.Colors.accent, Color(255, 255, 255))
    end
    
    local sendBtn = vgui.Create("DButton", commPanel)
    sendBtn:SetPos(commPanel:GetWide() - 110, 470)
    sendBtn:SetSize(90, 40)
    sendBtn:SetText("GONDER")
    sendBtn:SetTextColor(Color(255, 255, 255))
    sendBtn:SetFont("FIB_Menu_Text")
    sendBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
        draw.RoundedBox(6, 0, 0, w, h, col)
    end
    sendBtn.DoClick = function()
        local msg = messageEntry:GetValue()
        if msg ~= "" then
            RunConsoleCommand("fib_chat", msg)
            messageEntry:SetValue("")
        end
    end
    
    -- GÖREV PANELİ
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
        
        return line
    end
    
    -- Test görevler
    missionList:AddLine("Silah Kacakciligi Takibi", "John Doe", "YUKSEK", "Devam Ediyor", LocalPlayer():Nick())
    missionList:AddLine("Sahte Para Operasyonu", "Bilinmiyor", "ORTA", "Beklemede", "Atanmadi")
    missionList:AddLine("Uyusturucu Baronu", "Tony Montana", "KRITIK", "Planlama", "Atanmadi")
    missionList:AddLine("Banka Soygunu Istihbarat", "Bilinmiyor", "YUKSEK", "Tamamlandi", "AGENT001")
    
    -- Yeni görev oluştur butonu (Şef ve Kıdemli Ajan için)
    print("[FIB DEBUG] Kullanici rutbesi:", LocalPlayer().FIBRank) -- Debug
    
    if LocalPlayer().FIBRank == "Sef" or LocalPlayer().FIBRank == "Kidemli Ajan" then
        local createMissionBtn = vgui.Create("DButton", missionPanel)
        createMissionBtn:SetPos(20, 380)
        createMissionBtn:SetSize(200, 40)
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
            missionDialog:SetSize(400, 350)
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
            
            -- Ajan ata
            local assignLabel = vgui.Create("DLabel", missionDialog)
            assignLabel:SetPos(20, 235)
            assignLabel:SetSize(360, 20)
            assignLabel:SetText("Ajana Ata (Opsiyonel):")
            assignLabel:SetTextColor(Color(255, 255, 255))
            assignLabel:SetFont("FIB_Menu_Text")
            
            local assignCombo = vgui.Create("DComboBox", missionDialog)
            assignCombo:SetPos(20, 260)
            assignCombo:SetSize(360, 30)
            assignCombo:SetFont("FIB_Menu_Text")
            assignCombo:SetTextColor(Color(255, 255, 255))
            assignCombo:AddChoice("Atanmadi", "")
            
            -- Online ajanları ekle
            for _, ply in ipairs(player.GetAll()) do
                if ply.FIBAuthenticated then
                    assignCombo:AddChoice(ply:Nick(), ply:Nick())
                end
            end
            assignCombo:SetValue("Atanmadi")
            
            -- Oluştur butonu
            local createBtn = vgui.Create("DButton", missionDialog)
            createBtn:SetPos(20, 305)
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
                local assigned = assignCombo:GetValue()
                
                if name ~= "" then
                    -- Server'a gönder
                    RunConsoleCommand("fib_mission_create", name, target or "Bilinmiyor", priority)
                    
                    -- Listeye ekle
                    missionList:AddLine(name, target ~= "" and target or "Bilinmiyor", priority, "Yeni", assigned ~= "Atanmadi" and assigned or "Atanmadi")
                    
                    -- Dialogu kapat
                    missionDialog:Close()
                    
                    -- Bildirim
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Gorev basariyla olusturuldu!")
                else
                    chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Gorev adi bos olamaz!")
                end
            end
        end
        
        -- Görevi sil butonu
        local deleteMissionBtn = vgui.Create("DButton", missionPanel)
        deleteMissionBtn:SetPos(230, 380)
        deleteMissionBtn:SetSize(200, 40)
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
                missionList:RemoveLine(selected)
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 200, 0), "Gorev silindi!")
            else
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Lutfen bir gorev secin!")
            end
        end
    else
        -- Şef değilse bilgilendirme
        local infoLabel = vgui.Create("DLabel", missionPanel)
        infoLabel:SetPos(20, 380)
        infoLabel:SetSize(500, 30)
        infoLabel:SetText("* Gorev olusturma yetkisi: Sef ve Kidemli Ajan")
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
        -- Online durumunu kontrol et
        local isOnline = false
        for _, ply in ipairs(player.GetAll()) do
            if ply:SteamID() == steamid then
                isOnline = true
                break
            end
        end
        agentManageList:AddLine(steamid, data.username, data.rank, isOnline and "Online" or "Offline")
    end
    
    -- Ajan ekle butonu - DETAYLI
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
        -- Detaylı ajan ekleme penceresi
        local addDialog = vgui.Create("DFrame")
        addDialog:SetSize(400, 400)
        addDialog:Center()
        addDialog:SetTitle("Yeni Ajan Ekle")
        addDialog:MakePopup()
        addDialog.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 30, 45, 250))
            draw.RoundedBoxEx(8, 0, 0, w, 25, Color(0, 120, 255, 200), true, true, false, false)
        end
        
        -- Online oyuncular listesi
        local playerLabel = vgui.Create("DLabel", addDialog)
        playerLabel:SetPos(20, 40)
        playerLabel:SetText("Oyuncu Sec:")
        playerLabel:SetTextColor(Color(255, 255, 255))
        playerLabel:SetFont("FIB_Menu_Text")
        
        local playerList = vgui.Create("DComboBox", addDialog)
        playerList:SetPos(20, 65)
        playerList:SetSize(360, 30)
        playerList:SetFont("FIB_Menu_Text")
        playerList:SetTextColor(Color(255, 255, 255))
        
        -- Online oyuncuları ekle (FIB'de olmayanlar)
        for _, ply in ipairs(player.GetAll()) do
            if not ply.FIBAuthenticated then
                playerList:AddChoice(ply:Nick() .. " (" .. ply:SteamID() .. ")", ply)
            end
        end
        
        -- Kullanıcı adı
        local usernameLabel = vgui.Create("DLabel", addDialog)
        usernameLabel:SetPos(20, 110)
        usernameLabel:SetText("Kullanici Adi (Giris icin):")
        usernameLabel:SetTextColor(Color(255, 255, 255))
        usernameLabel:SetFont("FIB_Menu_Text")
        
        local usernameEntry = vgui.Create("DTextEntry", addDialog)
        usernameEntry:SetPos(20, 135)
        usernameEntry:SetSize(360, 30)
        usernameEntry:SetFont("FIB_Menu_Text")
        usernameEntry:SetPlaceholderText("Ornek: AGENT001")
        usernameEntry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(10, 20, 35, 200))
            self:DrawTextEntryText(Color(255, 255, 255), Color(0, 120, 255), Color(255, 255, 255))
        end
        
        -- Şifre
        local passwordLabel = vgui.Create("DLabel", addDialog)
        passwordLabel:SetPos(20, 180)
        passwordLabel:SetText("Sifre (Giris icin):")
        passwordLabel:SetTextColor(Color(255, 255, 255))
        passwordLabel:SetFont("FIB_Menu_Text")
        
        local passwordEntry = vgui.Create("DTextEntry", addDialog)
        passwordEntry:SetPos(20, 205)
        passwordEntry:SetSize(360, 30)
        passwordEntry:SetFont("FIB_Menu_Text")
        passwordEntry:SetPlaceholderText("Guvenli bir sifre girin")
        passwordEntry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(10, 20, 35, 200))
            self:DrawTextEntryText(Color(255, 255, 255), Color(0, 120, 255), Color(255, 255, 255))
        end
        
        -- Rastgele oluştur butonu
        local randomBtn = vgui.Create("DButton", addDialog)
        randomBtn:SetPos(20, 240)
        randomBtn:SetSize(360, 25)
        randomBtn:SetText("RASTGELE KULLANICI ADI VE SIFRE OLUSTUR")
        randomBtn:SetTextColor(Color(255, 255, 255))
        randomBtn:SetFont("FIB_Menu_Small")
        randomBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(100, 100, 100) or Color(50, 50, 50)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        randomBtn.DoClick = function()
            usernameEntry:SetValue("AGENT" .. math.random(100, 999))
            passwordEntry:SetValue("FIB#" .. math.random(1000, 9999) .. "!" .. string.char(math.random(65, 90)))
        end
        
        -- Rütbe seçimi
        local rankLabel = vgui.Create("DLabel", addDialog)
        rankLabel:SetPos(20, 275)
        rankLabel:SetText("Rutbe:")
        rankLabel:SetTextColor(Color(255, 255, 255))
        rankLabel:SetFont("FIB_Menu_Text")
        
        local rankCombo = vgui.Create("DComboBox", addDialog)
        rankCombo:SetPos(20, 300)
        rankCombo:SetSize(360, 30)
        rankCombo:SetFont("FIB_Menu_Text")
        rankCombo:SetTextColor(Color(255, 255, 255))
        rankCombo:AddChoice("Ajan", "Ajan")
        rankCombo:AddChoice("Kidemli Ajan", "Kidemli Ajan")
        rankCombo:AddChoice("Sef", "Sef")
        rankCombo:SetValue("Ajan")
        
        -- Ekle butonu
        local confirmBtn = vgui.Create("DButton", addDialog)
        confirmBtn:SetPos(20, 345)
        confirmBtn:SetSize(360, 40)
        confirmBtn:SetText("AJANI SISTEME EKLE")
        confirmBtn:SetTextColor(Color(255, 255, 255))
        confirmBtn:SetFont("FIB_Menu_Text")
        confirmBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and FIB.Config.Colors.hover or FIB.Config.Colors.accent
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        confirmBtn.DoClick = function()
            local _, selectedPlayer = playerList:GetSelected()
            local username = usernameEntry:GetValue()
            local password = passwordEntry:GetValue()
            local rank = rankCombo:GetValue()
            
            if selectedPlayer and username ~= "" and password ~= "" then
                -- Server'a gönder
                net.Start("FIB_AddAgent")
                net.WriteEntity(selectedPlayer)
                net.WriteString(username)
                net.WriteString(password)
                net.WriteString(rank)
                net.SendToServer()
                
                -- Listeye ekle
                agentManageList:AddLine(selectedPlayer:SteamID(), username, rank, "Online")
                
                -- Seçilen oyuncuya bildir
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), selectedPlayer:Nick() .. " sisteme eklendi!")
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 255, 255), "Kullanici: " .. username .. " | Sifre: " .. password)
                
                addDialog:Close()
            else
                chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "Lutfen tum alanlari doldurun!")
            end
        end
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
        agentManageList:Clear()
        
        -- Config'den tekrar yükle
        for steamid, data in pairs(FIB.Config.Users) do
            local isOnline = false
            for _, ply in ipairs(player.GetAll()) do
                if ply:SteamID() == steamid then
                    isOnline = true
                    break
                end
            end
            agentManageList:AddLine(steamid, data.username, data.rank, isOnline and "Online" or "Offline")
        end
        
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Liste yenilendi!")
    end
    
    -- İlk açılışta dashboard'u göster
    if IsValid(tabPanels["dashboard"]) then
        tabPanels["dashboard"]:SetVisible(true)
    end
    
    -- Frame kapatıldığında timer'ı temizle
    frame.OnClose = function()
        timer.Remove("FIB_UpdateStats")
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
        
        -- Online ajan sayısı
        local onlineAgents = 0
        local undercoverCount = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply.FIBAuthenticated then
                onlineAgents = onlineAgents + 1
                if ply.FIBUndercover then
                    undercoverCount = undercoverCount + 1
                end
            end
        end
        
        if FIB.MainMenuStats then
            FIB.MainMenuStats[1].value = tostring(onlineAgents)
            FIB.MainMenuStats[3].value = tostring(undercoverCount)
        end
        
        -- Ajan listesini güncelle
        if IsValid(agentList) then
            agentList:Clear()
            for _, ply in ipairs(player.GetAll()) do
                if ply.FIBAuthenticated then
                    local distance = math.Round(ply:GetPos():Distance(LocalPlayer():GetPos()))
                    local status = ply.FIBUndercover and "Gizli" or "Normal"
                    local line = agentList:AddLine(ply:Nick(), ply.FIBRank or "Ajan", status, distance .. "m")
                    
                    -- Gizli moddakileri farklı renklendir
                    if ply.FIBUndercover and IsValid(line) then
                        for _, col in pairs(line.Columns) do
                            col:SetTextColor(Color(255, 200, 0)) -- Sarı renk gizli modda olanlar için
                        end
                    end
                end
            end
        end
    end)
end

-- Komutlar
concommand.Add("fib_menu", function()
    if LocalPlayer().FIBAuthenticated then
        FIB.CreateMainMenu()
    else
        chat.AddText(Color(255, 0, 0), "[FIB] ", Color(255, 255, 255), "Oncelikle sisteme giris yapmalisiniz! (!fib)")
    end
end)

-- Toggle komutu - menüyü aç/kapat
concommand.Add("fib_menu_toggle", function()
    if not LocalPlayer().FIBAuthenticated then
        chat.AddText(Color(255, 0, 0), "[FIB] ", Color(255, 255, 255), "Sisteme giris yapmalisiniz!")
        return
    end
    
    if IsValid(FIB.MainMenu) then
        if FIB.MainMenu:IsVisible() then
            FIB.MainMenu:SetVisible(false)
            -- Mini indicator oluştur
            if not IsValid(FIB.MiniIndicator) then
                FIB.MiniIndicator = vgui.Create("DButton")
                FIB.MiniIndicator:SetSize(200, 40)
                FIB.MiniIndicator:SetPos(ScrW() - 210, 10)
                FIB.MiniIndicator:SetText("FIB SISTEM")
                FIB.MiniIndicator:SetTextColor(Color(255, 255, 255))
                FIB.MiniIndicator:SetFont("FIB_Menu_Text")
                FIB.MiniIndicator.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(0, 120, 255, 200))
                    local alpha = math.sin(CurTime() * 3) * 50 + 50
                    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, alpha))
                    draw.SimpleText("▼", "FIB_Menu_Text", w - 20, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                FIB.MiniIndicator.DoClick = function()
                    if IsValid(FIB.MainMenu) then
                        FIB.MainMenu:SetVisible(true)
                    end
                    FIB.MiniIndicator:Remove()
                    FIB.MiniIndicator = nil
                end
            end
        else
            FIB.MainMenu:SetVisible(true)
            if IsValid(FIB.MiniIndicator) then
                FIB.MiniIndicator:Remove()
                FIB.MiniIndicator = nil
            end
        end
    else
        FIB.CreateMainMenu()
    end
end)