-- SAM VIP Yönetim Sistemi - Client Menü (KESİN ÇÖZÜM)
-- lua/sam_vip_system/cl_sam_vip_menu.lua

-- Önceki paneli temizle
if IsValid(SAM_VIP_MENU) then
    SAM_VIP_MENU:Remove()
    SAM_VIP_MENU = nil
end

-- Modern fontlar
surface.CreateFont("VIP.Title", {
    font = "Roboto",
    extended = true,
    size = 28,
    weight = 700,
    antialias = true,
})

surface.CreateFont("VIP.Subtitle", {
    font = "Roboto",
    extended = true,
    size = 18,
    weight = 600,
    antialias = true,
})

surface.CreateFont("VIP.Button", {
    font = "Roboto",
    extended = true,
    size = 14,
    weight = 600,
    antialias = true,
})

surface.CreateFont("VIP.Label", {
    font = "Roboto",
    extended = true,
    size = 13,
    weight = 500,
    antialias = true,
})

surface.CreateFont("VIP.Stats", {
    font = "Roboto",
    extended = true,
    size = 24,
    weight = 700,
    antialias = true,
})

-- VIP rankları
local VIP_RANKS = VIP_RANKS or {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

-- Network mesajlarını dinle
net.Receive("SAM_VIP_OpenMenu", function()
    -- Eğer menü zaten açıksa
    if IsValid(SAM_VIP_MENU) then
        SAM_VIP_MENU:SetVisible(true)
        SAM_VIP_MENU:MakePopup()
        SAM_VIP_MENU:Center()
        
        -- Verileri yenile
        if SAM_VIP_MENU.RefreshData then
            SAM_VIP_MENU:RefreshData()
        end
        return
    end
    
    -- Yeni menü oluştur
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.85, ScrH() * 0.8)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(true)
    
    SAM_VIP_MENU = frame
    
    -- Tema renkleri
    local Colors = {
        Background = Color(18, 18, 18, 250),
        Surface = Color(25, 25, 25, 255),
        Card = Color(30, 30, 30, 255),
        Accent = Color(255, 215, 0),
        Success = Color(76, 175, 80),
        Warning = Color(255, 152, 0),
        Danger = Color(244, 67, 54),
        Text = Color(255, 255, 255),
        TextSecondary = Color(180, 180, 180)
    }
    
    frame.Colors = Colors
    frame.VIPData = {}
    frame.CurrentTab = "overview"
    
    -- Paint
    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Colors.Background)
        surface.SetDrawColor(Colors.Surface)
        surface.DrawRect(0, 0, w, 60)
        surface.SetDrawColor(Colors.Accent)
        surface.DrawRect(0, 60, w, 2)
        draw.SimpleText("VIP YÖNETİM SİSTEMİ", "VIP.Title", 25, 30, Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local timeText = os.date("%H:%M")
        draw.SimpleText(timeText, "VIP.Label", w - 60, 30, Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Kapat butonu
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frame:GetWide() - 40, 15)
    closeBtn:SetText("✕")
    closeBtn:SetFont("VIP.Subtitle")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(s, w, h)
        local color = s:IsHovered() and Colors.Danger or Color(100, 100, 100, 200)
        draw.RoundedBox(6, 0, 0, w, h, color)
    end
    closeBtn.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        frame:SetVisible(false)
    end
    
    -- Sol menü
    local sidebar = vgui.Create("DPanel", frame)
    sidebar:SetPos(0, 62)
    sidebar:SetSize(200, frame:GetTall() - 62)
    sidebar.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Colors.Surface)
    end
    
    -- Ana içerik
    local content = vgui.Create("DPanel", frame)
    content:SetPos(200, 62)
    content:SetSize(frame:GetWide() - 200, frame:GetTall() - 62)
    content.Paint = function() end
    
    -- Sekmeler
    local tabs = {
        {name = "📊 Genel Bakış", panel = "overview"},
        {name = "📋 VIP Listesi", panel = "list"},
        {name = "➕ VIP Ekle", panel = "add"},
        {name = "📈 İstatistikler", panel = "stats"},
        {name = "📜 İşlem Geçmişi", panel = "history"},
        {name = "⚙️ Ayarlar", panel = "settings"}
    }
    
    frame.TabPanels = {}
    
    -- Sol menü butonları
    for i, tab in ipairs(tabs) do
        local btn = vgui.Create("DButton", sidebar)
        btn:SetPos(5, 10 + (i-1) * 45)
        btn:SetSize(190, 40)
        btn:SetText("")
        btn.Paint = function(s, w, h)
            local isActive = frame.CurrentTab == tab.panel
            
            if isActive then
                draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(Colors.Accent, 30))
                draw.RoundedBox(6, 0, 0, 3, h, Colors.Accent)
            elseif s:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(Colors.Card, 150))
            end
            
            local textColor = isActive and Colors.Accent or Colors.Text
            draw.SimpleText(tab.name, "VIP.Button", 15, h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            for name, panel in pairs(frame.TabPanels) do
                if IsValid(panel) then
                    panel:SetVisible(false)
                end
            end
            
            if frame.TabPanels[tab.panel] then
                frame.TabPanels[tab.panel]:SetVisible(true)
            end
            
            frame.CurrentTab = tab.panel
            surface.PlaySound("UI/buttonclick.wav")
        end
    end
    
    -- Geri al butonu
    local undoBtn = vgui.Create("DButton", sidebar)
    undoBtn:SetPos(5, sidebar:GetTall() - 50)
    undoBtn:SetSize(190, 40)
    undoBtn:SetText("")
    undoBtn.Paint = function(s, w, h)
        local color = s:IsHovered() and Colors.Warning or ColorAlpha(Colors.Warning, 150)
        draw.RoundedBox(6, 0, 0, w, h, color)
        draw.SimpleText("⏪ Son İşlemi Geri Al", "VIP.Button", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    undoBtn.DoClick = function()
        Derma_Query(
            "Son işlemi geri almak istediğinize emin misiniz?",
            "İşlemi Geri Al",
            "Evet", function()
                net.Start("SAM_VIP_UndoLast")
                net.SendToServer()
            end,
            "Hayır"
        )
    end
    
    -- PANEL OLUŞTURMA
    
    -- 1. GENEL BAKIŞ
    local overviewPanel = vgui.Create("DPanel", content)
    overviewPanel:Dock(FILL)
    overviewPanel:DockMargin(20, 20, 20, 20)
    overviewPanel.Paint = function() end
    overviewPanel:SetVisible(true)
    
    local overviewTitle = vgui.Create("DLabel", overviewPanel)
    overviewTitle:SetPos(0, 0)
    overviewTitle:SetSize(500, 30)
    overviewTitle:SetText("Genel Bakış")
    overviewTitle:SetFont("VIP.Subtitle")
    overviewTitle:SetTextColor(Colors.Text)
    
    local statsContainer = vgui.Create("DPanel", overviewPanel)
    statsContainer:SetPos(0, 40)
    statsContainer:SetSize(800, 120)
    statsContainer.Paint = function() end
    
    overviewPanel.StatCards = {
        {title = "Toplam VIP", value = 0, color = Colors.Accent},
        {title = "Online VIP", value = 0, color = Colors.Success},
        {title = "Bu Ay Eklenen", value = 0, color = Color(33, 150, 243)},
        {title = "Yakında Bitecek", value = 0, color = Colors.Warning}
    }
    
    for i, card in ipairs(overviewPanel.StatCards) do
        local cardPanel = vgui.Create("DPanel", statsContainer)
        cardPanel:SetPos((i-1) * 200, 0)
        cardPanel:SetSize(190, 100)
        cardPanel.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Colors.Card)
            draw.RoundedBoxEx(8, 0, 0, w, 4, card.color, true, true, false, false)
            draw.SimpleText(card.value, "VIP.Stats", w/2, h/2 - 10, Colors.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(card.title, "VIP.Label", w/2, h - 20, Colors.TextSecondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        card.panel = cardPanel
    end
    
    frame.TabPanels["overview"] = overviewPanel
    
    -- 2. VIP LİSTESİ
    local listPanel = vgui.Create("DPanel", content)
    listPanel:Dock(FILL)
    listPanel:DockMargin(20, 20, 20, 20)
    listPanel.Paint = function() end
    listPanel:SetVisible(false)
    
    local listControls = vgui.Create("DPanel", listPanel)
    listControls:Dock(TOP)
    listControls:SetTall(50)
    listControls:DockMargin(0, 0, 0, 10)
    listControls.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Colors.Card)
    end
    
    local search = vgui.Create("DTextEntry", listControls)
    search:SetPos(10, 10)
    search:SetSize(200, 30)
    search:SetPlaceholderText("Oyuncu ara...")
    search:SetFont("VIP.Label")
    search.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Colors.Surface)
        s:DrawTextEntryText(Colors.Text, Colors.Accent, Colors.Text)
    end
    
    local filter = vgui.Create("DComboBox", listControls)
    filter:SetPos(220, 10)
    filter:SetSize(180, 30)
    filter:SetValue("Tüm VIP'ler")
    filter:SetFont("VIP.Label")
    filter:AddChoice("Tüm VIP'ler", "all")
    for _, rank in ipairs(VIP_RANKS) do
        filter:AddChoice(rank.name, rank.id)
    end
    
    local refresh = vgui.Create("DButton", listControls)
    refresh:SetPos(listControls:GetWide() - 100, 10)
    refresh:SetSize(90, 30)
    refresh:SetText("")
    refresh.Paint = function(s, w, h)
        local color = s:IsHovered() and Colors.Success or ColorAlpha(Colors.Success, 150)
        draw.RoundedBox(6, 0, 0, w, h, color)
        draw.SimpleText("🔄 Yenile", "VIP.Button", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    refresh.DoClick = function()
        frame:RefreshData()
    end
    
    local listScroll = vgui.Create("DScrollPanel", listPanel)
    listScroll:Dock(FILL)
    
    frame.VIPGrid = vgui.Create("DListLayout", listScroll)
    frame.VIPGrid:Dock(TOP)
    
    frame.TabPanels["list"] = listPanel
    
    -- 3. VIP EKLE
    local addPanel = vgui.Create("DPanel", content)
    addPanel:Dock(FILL)
    addPanel:DockMargin(20, 20, 20, 20)
    addPanel.Paint = function() end
    addPanel:SetVisible(false)
    
    local formContainer = vgui.Create("DPanel", addPanel)
    formContainer:SetSize(500, 450)
    formContainer:Center()
    formContainer.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Colors.Card)
    end
    
    local formTitle = vgui.Create("DLabel", formContainer)
    formTitle:SetPos(30, 20)
    formTitle:SetSize(440, 30)
    formTitle:SetText("Yeni VIP Ekle")
    formTitle:SetFont("VIP.Subtitle")
    formTitle:SetTextColor(Colors.Accent)
    
    local playerCombo = vgui.Create("DComboBox", formContainer)
    playerCombo:SetPos(30, 85)
    playerCombo:SetSize(440, 35)
    playerCombo:SetFont("VIP.Label")
    playerCombo:SetValue("Oyuncu seçin...")
    
    local timeCombo = vgui.Create("DComboBox", formContainer)
    timeCombo:SetPos(30, 275)
    timeCombo:SetSize(440, 35)
    timeCombo:SetFont("VIP.Label")
    timeCombo:AddChoice("1 Saat", 60)
    timeCombo:AddChoice("1 Gün", 1440)
    timeCombo:AddChoice("1 Hafta", 10080)
    timeCombo:AddChoice("1 Ay", 43200)
    timeCombo:AddChoice("3 Ay", 129600)
    timeCombo:AddChoice("6 Ay", 259200)
    timeCombo:AddChoice("1 Yıl", 525600)
    timeCombo:AddChoice("Kalıcı", 0)
    timeCombo:SetValue("1 Ay")
    
    frame.TabPanels["add"] = addPanel
    
    -- 4. İSTATİSTİKLER
    local statsPanel = vgui.Create("DPanel", content)
    statsPanel:Dock(FILL)
    statsPanel:DockMargin(20, 20, 20, 20)
    statsPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Colors.Card)
        draw.SimpleText("İstatistikler", "VIP.Subtitle", 20, 20, Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    statsPanel:SetVisible(false)
    
    frame.TabPanels["stats"] = statsPanel
    
    -- 5. İŞLEM GEÇMİŞİ - ÇÖZÜM: SCROLLPANEL KULLAN
    local historyPanel = vgui.Create("DPanel", content)
    historyPanel:Dock(FILL)
    historyPanel:DockMargin(20, 20, 20, 20)
    historyPanel.Paint = function() end
    historyPanel:SetVisible(false)
    
    local historyTitle = vgui.Create("DLabel", historyPanel)
    historyTitle:SetPos(0, 0)
    historyTitle:SetSize(500, 30)
    historyTitle:SetText("İşlem Geçmişi")
    historyTitle:SetFont("VIP.Subtitle")
    historyTitle:SetTextColor(Colors.Text)
    
    -- ScrollPanel kullan
    local historyScroll = vgui.Create("DScrollPanel", historyPanel)
    historyScroll:SetPos(0, 40)
    historyScroll:SetSize(historyPanel:GetWide(), historyPanel:GetTall() - 50)
    
    -- İşlem geçmişini liste olarak göster
    frame.HistoryContainer = vgui.Create("DListLayout", historyScroll)
    frame.HistoryContainer:Dock(TOP)
    
    frame.TabPanels["history"] = historyPanel
    
    -- 6. AYARLAR
    local settingsPanel = vgui.Create("DPanel", content)
    settingsPanel:Dock(FILL)
    settingsPanel:DockMargin(20, 20, 20, 20)
    settingsPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Colors.Card)
        draw.SimpleText("Ayarlar", "VIP.Subtitle", 20, 20, Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("VIP Sistemi v2.0", "VIP.Label", 20, 60, Colors.Text)
        draw.SimpleText("SAM Admin ile entegre çalışır", "VIP.Label", 20, 80, Colors.TextSecondary)
    end
    settingsPanel:SetVisible(false)
    
    frame.TabPanels["settings"] = settingsPanel
    
    -- RefreshData fonksiyonu
    frame.RefreshData = function(self)
        net.Start("SAM_VIP_GetList")
        net.SendToServer()
        
        net.Start("SAM_VIP_GetHistory")
        net.SendToServer()
    end
    
    -- CreateVIPCard fonksiyonu
    frame.CreateVIPCard = function(self, data)
        local card = vgui.Create("DPanel")
        card:SetTall(80)
        card:DockMargin(0, 0, 0, 5)
        card.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Colors.Card)
            draw.RoundedBox(8, 0, 0, 4, h, data.rankColor)
            
            local statusColor = data.online and Colors.Success or Color(100, 100, 100)
            draw.RoundedBox(4, 15, 35, 8, 8, statusColor)
            
            draw.SimpleText(data.nick, "VIP.Subtitle", 35, 25, Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.steamid, "VIP.Label", 35, 45, Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            draw.RoundedBox(14, 250, 25, 100, 28, data.rankColor)
            draw.SimpleText(data.rankName, "VIP.Label", 300, 39, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local timeText = "Kalıcı"
            if data.expiry and data.expiry > 0 then
                local timeLeft = data.expiry - os.time()
                if timeLeft > 0 then
                    local days = math.floor(timeLeft / 86400)
                    timeText = days .. " gün"
                else
                    timeText = "Dolmuş"
                end
            end
            draw.SimpleText(timeText, "VIP.Label", 370, 39, Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        return card
    end
    
    -- İlk veri yüklemesi
    frame:RefreshData()
end)

-- VIP listesi güncelleme
net.Receive("SAM_VIP_SendList", function()
    if not IsValid(SAM_VIP_MENU) then return end
    
    local vipList = net.ReadTable()
    SAM_VIP_MENU.VIPData = vipList
    
    if SAM_VIP_MENU.VIPGrid then
        SAM_VIP_MENU.VIPGrid:Clear()
        
        for _, data in ipairs(vipList) do
            local card = SAM_VIP_MENU:CreateVIPCard(data)
            SAM_VIP_MENU.VIPGrid:Add(card)
        end
    end
    
    -- İstatistikleri güncelle
    if SAM_VIP_MENU.TabPanels["overview"] then
        local total = #vipList
        local online = 0
        local expiringSoon = 0
        
        for _, vip in ipairs(vipList) do
            if vip.online then online = online + 1 end
            if vip.expiry and vip.expiry > 0 then
                local remaining = vip.expiry - os.time()
                if remaining > 0 and remaining < 604800 then
                    expiringSoon = expiringSoon + 1
                end
            end
        end
        
        local panel = SAM_VIP_MENU.TabPanels["overview"]
        if panel.StatCards then
            panel.StatCards[1].value = total
            panel.StatCards[2].value = online
            panel.StatCards[3].value = 0
            panel.StatCards[4].value = expiringSoon
        end
    end
end)

-- İşlem geçmişi güncelleme - DListView KULLANMA, DListLayout KULLAN
net.Receive("SAM_VIP_SendHistory", function()
    if not IsValid(SAM_VIP_MENU) or not SAM_VIP_MENU.HistoryContainer then return end
    
    local history = net.ReadTable()
    SAM_VIP_MENU.HistoryContainer:Clear()
    
    if history then
        for _, entry in ipairs(history) do
            if entry.timestamp then
                local dateStr = os.date("%d/%m/%Y %H:%M", tonumber(entry.timestamp))
                
                -- Her kayıt için bir panel oluştur
                local historyCard = vgui.Create("DPanel")
                historyCard:SetTall(50)
                historyCard:DockMargin(0, 0, 0, 5)
                historyCard.Paint = function(s, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, SAM_VIP_MENU.Colors.Card)
                    
                    -- Bilgileri göster
                    draw.SimpleText(dateStr, "VIP.Label", 10, h/2, SAM_VIP_MENU.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(entry.admin_steamid or "N/A", "VIP.Label", 200, h/2, SAM_VIP_MENU.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(entry.target_steamid or "N/A", "VIP.Label", 400, h/2, SAM_VIP_MENU.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(entry.action or "N/A", "VIP.Label", 600, h/2, SAM_VIP_MENU.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(entry.new_data or "N/A", "VIP.Label", 700, h/2, SAM_VIP_MENU.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                SAM_VIP_MENU.HistoryContainer:Add(historyCard)
            end
        end
    end
end)

-- Geri alma sonucu
net.Receive("SAM_VIP_UndoResult", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    
    if success then
        notification.AddLegacy(message, NOTIFY_GENERIC, 3)
        if IsValid(SAM_VIP_MENU) then
            SAM_VIP_MENU:RefreshData()
        end
    else
        notification.AddLegacy(message, NOTIFY_ERROR, 3)
    end
end)

print("[SAM VIP] Menü sistemi yüklendi - DListView kullanılmıyor")