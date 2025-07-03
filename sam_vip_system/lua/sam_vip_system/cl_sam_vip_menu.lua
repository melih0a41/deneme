-- SAM VIP Yönetim Sistemi - Client Menü
-- lua/sam_vip_system/cl_sam_vip_menu.lua

-- VIP rankları tanımı
local VIP_RANKS = VIP_RANKS or {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

local PANEL = {}

-- Ana panel
function PANEL:Init()
    self:SetSize(1600, 900)
    self:Center()
    self:SetTitle("")
    self:MakePopup()
    self:ShowCloseButton(false)
    
    self.Paint = function(s, w, h)
        -- Arka plan
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        
        -- Başlık alanı
        draw.RoundedBoxEx(12, 0, 0, w, 55, Color(35, 35, 35, 255), true, true, false, false)
        
        -- Başlık çizgisi
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(0, 55, w, 2)
        
        -- Başlık metni
        draw.SimpleText("VIP Yönetim Sistemi", "DermaLarge", w/2, 28, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Kapat butonu
        draw.RoundedBox(6, w - 45, 12, 30, 30, Color(220, 53, 69, s.CloseHover and 255 or 200))
        draw.SimpleText("✕", "DermaLarge", w - 30, 27, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Kapat butonu
    self.CloseBtn = vgui.Create("DButton", self)
    self.CloseBtn:SetPos(self:GetWide() - 45, 10)
    self.CloseBtn:SetSize(30, 30)
    self.CloseBtn:SetText("")
    self.CloseBtn.Paint = function() end
    self.CloseBtn.DoClick = function() self:Close() end
    self.CloseBtn.OnCursorEntered = function() self.CloseHover = true end
    self.CloseBtn.OnCursorExited = function() self.CloseHover = false end
    
    -- İçerik paneli
    self.Content = vgui.Create("DPanel", self)
    self.Content:Dock(FILL)
    self.Content:DockMargin(10, 65, 10, 10)
    self.Content.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35, 230))
    end
    
    -- Üst panel - Butonlar ve İstatistikler
    self.TopPanel = vgui.Create("DPanel", self.Content)
    self.TopPanel:Dock(TOP)
    self.TopPanel:SetTall(140)
    self.TopPanel:DockMargin(10, 10, 10, 10)
    self.TopPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45, 230))
    end
    
    -- İstatistik paneli
    self.StatsPanel = vgui.Create("DPanel", self.TopPanel)
    self.StatsPanel:Dock(TOP)
    self.StatsPanel:SetTall(80)
    self.StatsPanel:DockMargin(10, 10, 10, 5)
    self.StatsPanel.Paint = function(s, w, h)
        -- VIP rank bazlı sayılar
        local rankCounts = {}
        for _, rank in ipairs(VIP_RANKS) do
            rankCounts[rank.id] = 0
        end
        rankCounts["vip"] = 0 -- Eski VIP için
        
        -- Sayımları yap
        for _, line in pairs(self.VIPList:GetLines() or {}) do
            local rank = line.data and line.data.rank
            if rank and rankCounts[rank] then
                rankCounts[rank] = rankCounts[rank] + 1
            end
        end
        
        -- Her VIP türü için kutu çiz
        local totalRanks = #VIP_RANKS + 1 -- +1 eski VIP için
        local boxWidth = (w - (totalRanks * 10)) / totalRanks
        
        -- Eski VIP için
        local x = 0
        draw.RoundedBox(6, x, 0, boxWidth - 10, h, Color(60, 60, 60, 200))
        draw.RoundedBoxEx(6, x, 0, boxWidth - 10, 25, Color(255, 215, 0), true, true, false, false)
        draw.SimpleText("Eski VIP", "VIPRankFont", x + (boxWidth - 10) / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(rankCounts["vip"] or 0), "DermaLarge", x + (boxWidth - 10) / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Yeni VIP'ler için
        for i, rank in ipairs(VIP_RANKS) do
            x = i * boxWidth + (i * 10)
            
            draw.RoundedBox(6, x, 0, boxWidth - 10, h, Color(60, 60, 60, 200))
            draw.RoundedBoxEx(6, x, 0, boxWidth - 10, 25, rank.color, true, true, false, false)
            draw.SimpleText(rank.name, "VIPRankFont", x + (boxWidth - 10) / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(rankCounts[rank.id] or 0), "DermaLarge", x + (boxWidth - 10) / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Butonlar paneli
    self.ButtonsPanel = vgui.Create("DPanel", self.TopPanel)
    self.ButtonsPanel:Dock(FILL)
    self.ButtonsPanel:DockMargin(10, 5, 10, 10)
    self.ButtonsPanel.Paint = function() end
    
    -- Yeni VIP ekle butonu
    self.AddVIPBtn = vgui.Create("DButton", self.ButtonsPanel)
    self.AddVIPBtn:Dock(LEFT)
    self.AddVIPBtn:SetWide(200)
    self.AddVIPBtn:DockMargin(0, 0, 5, 0)
    self.AddVIPBtn:SetText("Yeni VIP Ekle")
    self.AddVIPBtn:SetFont("DermaDefault")
    self.AddVIPBtn:SetTextColor(Color(255, 255, 255))
    self.AddVIPBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 167, 69, s:IsHovered() and 255 or 200))
    end
    self.AddVIPBtn.DoClick = function()
        self:OpenAddVIPMenu()
    end
    
    -- Filtre dropdown
    self.FilterCombo = vgui.Create("DComboBox", self.ButtonsPanel)
    self.FilterCombo:Dock(LEFT)
    self.FilterCombo:SetWide(200)
    self.FilterCombo:DockMargin(5, 0, 5, 0)
    self.FilterCombo:SetValue("Tüm VIP'ler")
    self.FilterCombo:AddChoice("Tüm VIP'ler", "all")
    self.FilterCombo:AddChoice("Eski VIP", "vip")
    
    -- VIP rankları filtreleri
    for _, rank in ipairs(VIP_RANKS) do
        self.FilterCombo:AddChoice(rank.name, rank.id)
    end
    
    self.FilterCombo.OnSelect = function(s, index, value, data)
        self:ApplyFilter(data)
    end
    
    -- Yenile butonu
    self.RefreshBtn = vgui.Create("DButton", self.ButtonsPanel)
    self.RefreshBtn:Dock(RIGHT)
    self.RefreshBtn:SetWide(100)
    self.RefreshBtn:DockMargin(5, 0, 0, 0)
    self.RefreshBtn:SetText("Yenile")
    self.RefreshBtn:SetFont("DermaDefault")
    self.RefreshBtn:SetTextColor(Color(255, 255, 255))
    self.RefreshBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(23, 162, 184, s:IsHovered() and 255 or 200))
    end
    self.RefreshBtn.DoClick = function()
        self:RefreshList()
    end
    
    -- VIP listesi
    self.VIPList = vgui.Create("DListView", self.Content)
    self.VIPList:Dock(FILL)
    self.VIPList:DockMargin(10, 0, 10, 10)
    self.VIPList:SetMultiSelect(false)
    
    -- Sütunları ekle
    local col1 = self.VIPList:AddColumn("Oyuncu")
    col1:SetMinWidth(300)
    col1:SetMaxWidth(300)
    
    local col2 = self.VIPList:AddColumn("Steam ID")
    col2:SetMinWidth(200)
    col2:SetMaxWidth(200)
    
    local col3 = self.VIPList:AddColumn("VIP Türü")
    col3:SetMinWidth(150)
    col3:SetMaxWidth(150)
    
    local col4 = self.VIPList:AddColumn("Kalan Süre")
    col4:SetMinWidth(350)
    col4:SetMaxWidth(350)
    
    local col5 = self.VIPList:AddColumn("İşlemler")
    col5:SetMinWidth(500)
    col5:SetMaxWidth(500)
    
    self.VIPList:SetDataHeight(50)
    
    -- Liste renklendirme ve stil
    self.VIPList.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
    end
    
    -- Header yüksekliğini ayarla
    self.VIPList:SetHeaderHeight(35)
    
    -- Header stilini özelleştir
    for k, v in pairs(self.VIPList.Columns) do
        v.Header:SetTextColor(Color(255, 215, 0))
        v.Header:SetFont("DermaDefaultBold")
        v.Header.Paint = function(s, w, h)
            -- Header arka planı
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 255))
            
            -- Alt çizgi
            surface.SetDrawColor(255, 215, 0, 150)
            surface.DrawRect(0, h-2, w, 2)
            
            -- Sütun ayırıcı
            if k < #self.VIPList.Columns then
                surface.SetDrawColor(70, 70, 70)
                surface.DrawLine(w-1, 5, w-1, h-5)
            end
        end
        
        -- Header text'i ortala
        v.Header:SetContentAlignment(5)
    end
    
    -- VIP rankları listesini al (opsiyonel)
    timer.Simple(0.1, function()
        if IsValid(self) then
            net.Start("SAM_VIP_GetRanks")
            net.SendToServer()
        end
    end)
    
    -- Listeyi başlat
    self:RefreshList()
end

function PANEL:ApplyFilter(filter)
    for _, line in pairs(self.VIPList:GetLines()) do
        if filter == "all" then
            line:SetVisible(true)
        else
            line:SetVisible(line.data and line.data.rank == filter)
        end
    end
end

function PANEL:RefreshList()
    net.Start("SAM_VIP_GetList")
    net.SendToServer()
end

function PANEL:OpenAddVIPMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 450)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(12, 0, 0, w, 45, Color(35, 35, 35, 255), true, true, false, false)
        draw.SimpleText("Yeni VIP Ekle", "DermaLarge", w/2, 22, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(0, 45, w, 2)
    end
    
    -- Kapat butonu
    local close = vgui.Create("DButton", frame)
    close:SetPos(frame:GetWide() - 40, 10)
    close:SetSize(25, 25)
    close:SetText("✕")
    close:SetTextColor(Color(255, 255, 255))
    close.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
    end
    close.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        frame:Close() 
    end
    
    -- İçerik
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockMargin(20, 50, 20, 20)
    content.Paint = function() end
    
    -- Oyuncu seçimi
    local plylbl = vgui.Create("DLabel", content)
    plylbl:Dock(TOP)
    plylbl:SetText("Oyuncu Seç:")
    plylbl:SetFont("DermaDefault")
    plylbl:SetTextColor(Color(255, 255, 255))
    
    local plycombo = vgui.Create("DComboBox", content)
    plycombo:Dock(TOP)
    plycombo:DockMargin(0, 5, 0, 15)
    plycombo:SetTall(30)
    
    -- VIP olmayan oyuncuları listele
    local hasNonVIP = false
    for _, ply in ipairs(player.GetAll()) do
        local userGroup = ply:GetUserGroup()
        local isVIP = userGroup == "vip"
        
        -- Yeni VIP rankları için kontrol
        if not isVIP then
            for _, rank in ipairs(VIP_RANKS) do
                if userGroup == rank.id then
                    isVIP = true
                    break
                end
            end
        end
        
        if not isVIP then
            plycombo:AddChoice(ply:Nick(), ply:SteamID())
            hasNonVIP = true
        end
    end
    
    if not hasNonVIP then
        plycombo:AddChoice("VIP olmayan oyuncu yok", nil)
    end
    
    -- VIP türü seçimi
    local typelbl = vgui.Create("DLabel", content)
    typelbl:Dock(TOP)
    typelbl:SetText("VIP Türü:")
    typelbl:SetFont("DermaDefault")
    typelbl:SetTextColor(Color(255, 255, 255))
    
    local typecombo = vgui.Create("DComboBox", content)
    typecombo:Dock(TOP)
    typecombo:DockMargin(0, 5, 0, 15)
    typecombo:SetTall(30)
    
    -- VIP türlerini ekle
    for _, rank in ipairs(VIP_RANKS) do
        typecombo:AddChoice(rank.name, rank.id)
    end
    typecombo:SetValue("Silver VIP")
    
    -- Süre seçimi
    local timelbl = vgui.Create("DLabel", content)
    timelbl:Dock(TOP)
    timelbl:SetText("Süre Seç:")
    timelbl:SetFont("DermaDefault")
    timelbl:SetTextColor(Color(255, 255, 255))
    
    local timecombo = vgui.Create("DComboBox", content)
    timecombo:Dock(TOP)
    timecombo:DockMargin(0, 5, 0, 15)
    timecombo:SetTall(30)
    timecombo:AddChoice("1 Saat", 60)
    timecombo:AddChoice("1 Gün", 1440)
    timecombo:AddChoice("1 Hafta", 10080)
    timecombo:AddChoice("1 Ay", 43200)
    timecombo:AddChoice("3 Ay", 129600)
    timecombo:AddChoice("6 Ay", 259200)
    timecombo:AddChoice("Kalıcı", 0)
    timecombo:SetValue("1 Gün")
    
    -- Ekle butonu
    local addbtn = vgui.Create("DButton", content)
    addbtn:Dock(BOTTOM)
    addbtn:SetTall(40)
    addbtn:SetText("VIP Ekle")
    addbtn:SetFont("DermaDefault")
    addbtn:SetTextColor(Color(255, 255, 255))
    addbtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 167, 69, s:IsHovered() and 255 or 200))
    end
    addbtn.DoClick = function()
        local nick, steamid = plycombo:GetSelected()
        local typename, typeid = typecombo:GetSelected()
        local timelabel, time = timecombo:GetSelected()
        
        if steamid and typeid and time then
            -- vipver komutundan VIP türünü çıkar
            local vipType = typeid:gsub("vip$", "")
            
            if time == 0 then
                -- Kalıcı VIP için büyük bir sayı kullan
                RunConsoleCommand("sam", "vipver", nick, vipType, "525600") -- 1 yıl
            else
                RunConsoleCommand("sam", "vipver", nick, vipType, tostring(time))
            end
            
            frame:Close()
            timer.Simple(0.5, function()
                self:RefreshList()
            end)
        end
    end
end

function PANEL:CreateActionButtons(line, data)
    local actions = vgui.Create("DPanel", line)
    actions:SetWide(490)
    actions:Dock(RIGHT)
    actions:DockMargin(10, 5, 10, 5)
    actions.Paint = function() end
    
    -- Yükselt butonu (sadece diamond değilse)
    if data.rank ~= "diamondvip" then
        local upgrade = vgui.Create("DButton", actions)
        upgrade:Dock(LEFT)
        upgrade:SetWide(110)
        upgrade:DockMargin(0, 0, 5, 0)
        upgrade:SetText("Yükselt")
        upgrade:SetFont("DermaDefaultBold")
        upgrade:SetTextColor(Color(255, 255, 255))
        upgrade.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(46, 125, 50, s:IsHovered() and 255 or 200))
        end
        upgrade.DoClick = function()
            self:OpenUpgradeMenu(data)
        end
    end
    
    -- Süre azalt butonu (sadece süreli VIP'ler için)
    if data.expiry and data.expiry > 0 then
        local reduce = vgui.Create("DButton", actions)
        reduce:Dock(LEFT)
        reduce:SetWide(110)
        reduce:DockMargin(5, 0, 5, 0)
        reduce:SetText("Süre Azalt")
        reduce:SetFont("DermaDefaultBold")
        reduce:SetTextColor(Color(255, 255, 255))
        reduce.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 140, 0, s:IsHovered() and 255 or 200))
        end
        reduce.DoClick = function()
            self:OpenReduceTimeMenu(data)
        end
    end
    
    -- Süre ekle butonu
    local extend = vgui.Create("DButton", actions)
    extend:Dock(LEFT)
    extend:SetWide(110)
    extend:DockMargin(5, 0, 5, 0)
    extend:SetText("Süre Ekle")
    extend:SetFont("DermaDefaultBold")
    extend:SetTextColor(Color(255, 255, 255))
    extend.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(23, 162, 184, s:IsHovered() and 255 or 200))
    end
    extend.DoClick = function()
        self:OpenExtendMenu(data.steamid)
    end
    
    -- Kaldır butonu
    local remove = vgui.Create("DButton", actions)
    remove:Dock(RIGHT)
    remove:SetWide(110)
    remove:SetText("VIP Kaldır")
    remove:SetFont("DermaDefaultBold")
    remove:SetTextColor(Color(255, 255, 255))
    remove.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
    end
    remove.DoClick = function()
        Derma_Query("Bu oyuncudan " .. data.rankName .. " rankını kaldırmak istediğinize emin misiniz?", "VIP Kaldır",
            "Evet", function()
                net.Start("SAM_VIP_Action")
                net.WriteString("remove")
                net.WriteString(data.steamid)
                net.SendToServer()
                
                timer.Simple(0.5, function()
                    self:RefreshList()
                end)
            end,
            "Hayır", function() end
        )
    end
    
    return actions
end

function PANEL:OpenReduceTimeMenu(data)
    -- Kalıcı VIP'lerin süresini azaltamazsın
    if data.expiry == 0 then
        Derma_Message("Kalıcı VIP'lerin süresi azaltılamaz!", "Uyarı", "Tamam")
        return
    end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 350)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(12, 0, 0, w, 45, Color(35, 35, 35, 255), true, true, false, false)
        draw.SimpleText("VIP Süresini Azalt", "DermaLarge", w/2, 22, Color(255, 140, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(255, 140, 0, 100)
        surface.DrawRect(0, 45, w, 2)
    end
    
    -- Kapat butonu
    local close = vgui.Create("DButton", frame)
    close:SetPos(frame:GetWide() - 40, 10)
    close:SetSize(25, 25)
    close:SetText("✕")
    close:SetTextColor(Color(255, 255, 255))
    close.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
    end
    close.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        frame:Close() 
    end
    
    -- İçerik
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockMargin(20, 50, 20, 20)
    content.Paint = function() end
    
    -- Bilgi
    local info = vgui.Create("DLabel", content)
    info:Dock(TOP)
    info:SetText("Oyuncu: " .. data.nick)
    info:SetFont("DermaDefaultBold")
    info:SetTextColor(Color(255, 255, 255))
    info:DockMargin(0, 0, 0, 10)
    
    local currentRank = vgui.Create("DLabel", content)
    currentRank:Dock(TOP)
    currentRank:SetText("Rank: " .. data.rankName)
    currentRank:SetFont("DermaDefault")
    currentRank:SetTextColor(data.rankColor)
    currentRank:DockMargin(0, 0, 0, 10)
    
    -- Mevcut süre
    local currentTime = vgui.Create("DLabel", content)
    currentTime:Dock(TOP)
    currentTime:SetWrap(true)
    currentTime:SetTall(40)
    currentTime:SetFont("DermaDefault")
    currentTime:SetTextColor(Color(200, 200, 200))
    currentTime:DockMargin(0, 0, 0, 20)
    
    -- Mevcut süreyi hesapla
    local time_left = data.expiry - os.time()
    local current_days = 0
    if time_left > 0 then
        current_days = math.floor(time_left / 86400)
        local days = math.floor(time_left / 86400)
        local hours = math.floor((time_left % 86400) / 3600)
        local minutes = math.floor((time_left % 3600) / 60)
        
        local time_text = ""
        if days > 0 then
            time_text = string.format("%d gün %d saat %d dakika", days, hours, minutes)
        elseif hours > 0 then
            time_text = string.format("%d saat %d dakika", hours, minutes)
        else
            time_text = string.format("%d dakika", minutes)
        end
        
        currentTime:SetText("Mevcut Süre: " .. time_text)
    else
        currentTime:SetText("VIP süresi dolmuş!")
        timer.Simple(0.1, function() frame:Close() end)
        return
    end
    
    -- Gün girişi için label
    local daysLabel = vgui.Create("DLabel", content)
    daysLabel:Dock(TOP)
    daysLabel:SetText("Kaç gün kaldığını girin:")
    daysLabel:SetFont("DermaDefault")
    daysLabel:SetTextColor(Color(255, 255, 255))
    daysLabel:DockMargin(0, 10, 0, 5)
    
    -- Gün girişi
    local daysEntry = vgui.Create("DTextEntry", content)
    daysEntry:Dock(TOP)
    daysEntry:SetTall(35)
    daysEntry:SetNumeric(true)
    daysEntry:SetValue("7")
    daysEntry:SetFont("DermaDefault")
    daysEntry:DockMargin(0, 0, 0, 20)
    daysEntry.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 255))
        s:DrawTextEntryText(Color(255, 255, 255), Color(255, 140, 0), Color(255, 255, 255))
    end
    
    -- Hızlı seçim butonları
    local quickPanel = vgui.Create("DPanel", content)
    quickPanel:Dock(TOP)
    quickPanel:SetTall(30)
    quickPanel:DockMargin(0, 0, 0, 20)
    quickPanel.Paint = function() end
    
    local quickButtons = {
        {text = "1 Gün", days = 1},
        {text = "7 Gün", days = 7},
        {text = "30 Gün", days = 30},
        {text = "90 Gün", days = 90}
    }
    
    local btnWidth = 90
    local spacing = 10
    
    for i, option in ipairs(quickButtons) do
        local quickBtn = vgui.Create("DButton", quickPanel)
        quickBtn:SetPos((i-1) * (btnWidth + spacing), 0)
        quickBtn:SetSize(btnWidth, 30)
        quickBtn:SetText(option.text)
        quickBtn:SetFont("DermaDefaultBold")
        quickBtn:SetTextColor(Color(255, 255, 255))
        quickBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60, s:IsHovered() and 255 or 200))
        end
        quickBtn.DoClick = function()
            daysEntry:SetValue(tostring(option.days))
        end
    end
    
    -- Azalt butonu
    local reduceBtn = vgui.Create("DButton", content)
    reduceBtn:Dock(BOTTOM)
    reduceBtn:SetTall(45)
    reduceBtn:SetText("Süreyi Değiştir")
    reduceBtn:SetFont("DermaDefaultBold")
    reduceBtn:SetTextColor(Color(255, 255, 255))
    reduceBtn.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(255, 140, 0, s:IsHovered() and 255 or 200))
    end
    reduceBtn.DoClick = function()
        local days = tonumber(daysEntry:GetValue())
        if days and days > 0 then
            -- Server tarafına gönder
            local new_expiry = os.time() + (days * 86400)
            
            net.Start("SAM_VIP_Action")
            net.WriteString("settime")
            net.WriteString(data.steamid)
            net.WriteUInt(days, 16)
            net.SendToServer()
            
            frame:Close()
            timer.Simple(0.5, function()
                self:RefreshList()
            end)
        else
            Derma_Message("Lütfen geçerli bir gün sayısı girin!", "Hata", "Tamam")
        end
    end
end

function PANEL:OpenUpgradeMenu(data)
    local currentRankIndex = 0
    local upgradeRank = nil
    
    -- Mevcut rank'ın index'ini bul
    if data.rank == "vip" then
        -- Eski VIP'i Silver'a yükselt
        upgradeRank = VIP_RANKS[2] -- Silver VIP
    else
        for i, rank in ipairs(VIP_RANKS) do
            if rank.id == data.rank then
                currentRankIndex = i
                break
            end
        end
        
        if currentRankIndex > 0 and currentRankIndex < #VIP_RANKS then
            upgradeRank = VIP_RANKS[currentRankIndex + 1]
        end
    end
    
    if not upgradeRank then
        Derma_Message(data.nick .. " zaten en yüksek VIP rankına sahip!", "Uyarı", "Tamam")
        return
    end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(12, 0, 0, w, 45, Color(35, 35, 35, 255), true, true, false, false)
        draw.SimpleText("VIP Yükselt", "DermaLarge", w/2, 22, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(0, 45, w, 2)
    end
    
    -- Kapat butonu
    local close = vgui.Create("DButton", frame)
    close:SetPos(frame:GetWide() - 40, 10)
    close:SetSize(25, 25)
    close:SetText("✕")
    close:SetTextColor(Color(255, 255, 255))
    close.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
    end
    close.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        frame:Close() 
    end
    
    -- İçerik
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockMargin(20, 50, 20, 20)
    content.Paint = function() end
    
    -- Bilgi
    local info = vgui.Create("DLabel", content)
    info:Dock(TOP)
    info:SetText("Oyuncu: " .. data.nick)
    info:SetFont("DermaDefaultBold")
    info:SetTextColor(Color(255, 255, 255))
    info:DockMargin(0, 0, 0, 10)
    
    local currentRank = vgui.Create("DLabel", content)
    currentRank:Dock(TOP)
    currentRank:SetText("Mevcut Rank: " .. data.rankName)
    currentRank:SetFont("DermaDefault")
    currentRank:SetTextColor(data.rankColor)
    currentRank:DockMargin(0, 0, 0, 20)
    
    -- Yeni rank bilgisi
    local newRank = vgui.Create("DLabel", content)
    newRank:Dock(TOP)
    newRank:SetText("Yeni Rank: " .. upgradeRank.name)
    newRank:SetFont("DermaDefaultBold")
    newRank:SetTextColor(upgradeRank.color)
    newRank:DockMargin(0, 0, 0, 30)
    
    -- Onay mesajı
    local confirm = vgui.Create("DLabel", content)
    confirm:Dock(TOP)
    confirm:SetText("Bu işlem geri alınamaz. Devam etmek istiyor musunuz?")
    confirm:SetFont("DermaDefault")
    confirm:SetTextColor(Color(255, 255, 100))
    confirm:SetWrap(true)
    confirm:SetTall(40)
    
    -- Yükselt butonu
    local upgradebtn = vgui.Create("DButton", content)
    upgradebtn:Dock(BOTTOM)
    upgradebtn:SetTall(40)
    upgradebtn:SetText("Yükselt")
    upgradebtn:SetFont("DermaDefault")
    upgradebtn:SetTextColor(Color(255, 255, 255))
    upgradebtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(46, 125, 50, s:IsHovered() and 255 or 200))
    end
    upgradebtn.DoClick = function()
        net.Start("SAM_VIP_Action")
        net.WriteString("upgrade")
        net.WriteString(data.steamid)
        net.WriteString(upgradeRank.id)
        net.SendToServer()
        
        frame:Close()
        timer.Simple(0.5, function()
            self:RefreshList()
        end)
    end
end

function PANEL:OpenExtendMenu(steamid)
    -- Oyuncu datasını bul
    local data = nil
    for _, line in pairs(self.VIPList:GetLines()) do
        if line.data and line.data.steamid == steamid then
            data = line.data
            break
        end
    end
    
    if not data then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 350)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(12, 0, 0, w, 45, Color(35, 35, 35, 255), true, true, false, false)
        draw.SimpleText("VIP Süresini Uzat", "DermaLarge", w/2, 22, Color(23, 162, 184), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(23, 162, 184, 100)
        surface.DrawRect(0, 45, w, 2)
    end
    
    -- Kapat butonu
    local close = vgui.Create("DButton", frame)
    close:SetPos(frame:GetWide() - 40, 10)
    close:SetSize(25, 25)
    close:SetText("✕")
    close:SetTextColor(Color(255, 255, 255))
    close.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
    end
    close.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        frame:Close() 
    end
    
    -- İçerik
    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockMargin(20, 50, 20, 20)
    content.Paint = function() end
    
    -- Bilgi
    local info = vgui.Create("DLabel", content)
    info:Dock(TOP)
    info:SetText("Oyuncu: " .. data.nick)
    info:SetFont("DermaDefaultBold")
    info:SetTextColor(Color(255, 255, 255))
    info:DockMargin(0, 0, 0, 10)
    
    local currentRank = vgui.Create("DLabel", content)
    currentRank:Dock(TOP)
    currentRank:SetText("Rank: " .. data.rankName)
    currentRank:SetFont("DermaDefault")
    currentRank:SetTextColor(data.rankColor)
    currentRank:DockMargin(0, 0, 0, 10)
    
    -- Mevcut süre
    local currentTime = vgui.Create("DLabel", content)
    currentTime:Dock(TOP)
    currentTime:SetWrap(true)
    currentTime:SetTall(40)
    currentTime:SetFont("DermaDefault")
    currentTime:SetTextColor(Color(200, 200, 200))
    currentTime:DockMargin(0, 0, 0, 20)
    
    -- Mevcut süreyi hesapla ve göster
    if data.expiry and data.expiry > 0 then
        local time_left = data.expiry - os.time()
        if time_left > 0 then
            local days = math.floor(time_left / 86400)
            local hours = math.floor((time_left % 86400) / 3600)
            local minutes = math.floor((time_left % 3600) / 60)
            
            local time_text = ""
            if days > 0 then
                time_text = string.format("%d gün %d saat %d dakika", days, hours, minutes)
            elseif hours > 0 then
                time_text = string.format("%d saat %d dakika", hours, minutes)
            else
                time_text = string.format("%d dakika", minutes)
            end
            
            currentTime:SetText("Mevcut Süre: " .. time_text)
        else
            currentTime:SetText("VIP süresi dolmuş!")
        end
    else
        currentTime:SetText("Kalıcı VIP\n\nNot: Kalıcı VIP'lere süre eklenemez!")
        currentTime:SetTextColor(Color(255, 100, 100))
        timer.Simple(2, function() 
            if IsValid(frame) then frame:Close() end 
        end)
        return
    end
    
    -- Gün girişi için label
    local daysLabel = vgui.Create("DLabel", content)
    daysLabel:Dock(TOP)
    daysLabel:SetText("Eklenecek gün sayısını girin:")
    daysLabel:SetFont("DermaDefault")
    daysLabel:SetTextColor(Color(255, 255, 255))
    daysLabel:DockMargin(0, 10, 0, 5)
    
    -- Gün girişi
    local daysEntry = vgui.Create("DTextEntry", content)
    daysEntry:Dock(TOP)
    daysEntry:SetTall(35)
    daysEntry:SetNumeric(true)
    daysEntry:SetValue("30")
    daysEntry:SetFont("DermaDefault")
    daysEntry:DockMargin(0, 0, 0, 20)
    daysEntry.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 255))
        s:DrawTextEntryText(Color(255, 255, 255), Color(23, 162, 184), Color(255, 255, 255))
    end
    
    -- Hızlı seçim butonları
    local quickPanel = vgui.Create("DPanel", content)
    quickPanel:Dock(TOP)
    quickPanel:SetTall(30)
    quickPanel:DockMargin(0, 0, 0, 20)
    quickPanel.Paint = function() end
    
    local quickButtons = {
        {text = "7 Gün", days = 7},
        {text = "30 Gün", days = 30},
        {text = "90 Gün", days = 90},
        {text = "180 Gün", days = 180}
    }
    
    local btnWidth = 90
    local spacing = 10
    local totalWidth = (#quickButtons * btnWidth) + ((#quickButtons - 1) * spacing)
    local startX = (quickPanel:GetWide() - totalWidth) / 2
    
    for i, option in ipairs(quickButtons) do
        local quickBtn = vgui.Create("DButton", quickPanel)
        quickBtn:SetPos((i-1) * (btnWidth + spacing), 0)
        quickBtn:SetSize(btnWidth, 30)
        quickBtn:SetText(option.text)
        quickBtn:SetFont("DermaDefaultBold")
        quickBtn:SetTextColor(Color(255, 255, 255))
        quickBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60, s:IsHovered() and 255 or 200))
        end
        quickBtn.DoClick = function()
            daysEntry:SetValue(tostring(option.days))
        end
    end
    
    -- Ekle butonu
    local addBtn = vgui.Create("DButton", content)
    addBtn:Dock(BOTTOM)
    addBtn:SetTall(45)
    addBtn:SetText("Süre Ekle")
    addBtn:SetFont("DermaDefaultBold")
    addBtn:SetTextColor(Color(255, 255, 255))
    addBtn.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(23, 162, 184, s:IsHovered() and 255 or 200))
    end
    addBtn.DoClick = function()
        local days = tonumber(daysEntry:GetValue())
        if days and days > 0 then
            net.Start("SAM_VIP_Action")
            net.WriteString("extend")
            net.WriteString(data.steamid)
            net.WriteUInt(days, 16)
            net.SendToServer()
            
            frame:Close()
            timer.Simple(0.5, function()
                self:RefreshList()
            end)
        else
            Derma_Message("Lütfen geçerli bir gün sayısı girin!", "Hata", "Tamam")
        end
    end
end

vgui.Register("SAMVIPMenu", PANEL, "DFrame")

-- Network mesajları
net.Receive("SAM_VIP_OpenMenu", function()
    if IsValid(SAM_VIP_MENU) then
        SAM_VIP_MENU:Remove()
    end
    
    SAM_VIP_MENU = vgui.Create("SAMVIPMenu")
end)

net.Receive("SAM_VIP_SendList", function()
    if not IsValid(SAM_VIP_MENU) then return end
    
    local vip_list = net.ReadTable()
    
    SAM_VIP_MENU.VIPList:Clear()
    
    for _, data in ipairs(vip_list) do
        local time_text = "Kalıcı"
        
        -- Eğer expiry değeri varsa ve 0'dan büyükse
        if data.expiry and data.expiry > 0 then
            local time_left = data.expiry - os.time()
            
            if time_left > 0 then
                local days = math.floor(time_left / 86400)
                local hours = math.floor((time_left % 86400) / 3600)
                local minutes = math.floor((time_left % 3600) / 60)
                
                if days > 0 then
                    time_text = string.format("%d gün %d saat %d dakika", days, hours, minutes)
                elseif hours > 0 then
                    time_text = string.format("%d saat %d dakika", hours, minutes)
                else
                    time_text = string.format("%d dakika", minutes)
                end
            else
                time_text = "Süresi Dolmuş"
            end
        end
        
        -- Online durumu belirt
        local nick_text = data.nick
        if data.online then
            nick_text = "● " .. nick_text -- Yeşil nokta için
        else
            nick_text = "○ " .. nick_text -- Boş nokta için
        end
        
        local line = SAM_VIP_MENU.VIPList:AddLine(nick_text, data.steamid, data.rankName, time_text, "")
        line.data = data -- Veriyi sakla
        
        -- Satır için font ayarı
        for i = 1, 5 do
            if line.Columns[i] then
                line.Columns[i]:SetFont("DermaDefaultBold")
                line.Columns[i]:SetTextColor(Color(255, 255, 255))
                line.Columns[i]:SetContentAlignment(5) -- Ortala
            end
        end
        
        -- Oyuncu ismini sol hizala
        line.Columns[1]:SetContentAlignment(4) -- Sol ortala
        
        -- Satır renklendirme
        if data.online then
            line.Columns[1]:SetTextColor(Color(100, 255, 100)) -- Online oyuncular yeşil
        else
            line.Columns[1]:SetTextColor(Color(200, 200, 200)) -- Offline oyuncular gri
        end
        
        -- VIP türü rengi
        line.Columns[3]:SetTextColor(data.rankColor)
        
        -- Satır arka plan rengi ve yükseklik
        line:SetTall(50) -- Satır yüksekliğini artır
        line.Paint = function(s, w, h)
            if s:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 215, 0, 20))
            elseif s:IsSelected() then
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 215, 0, 30))
            else
                -- Alternatif satır renklendirme
                local _, y = s:GetPos()
                local index = math.floor(y / s:GetTall()) + 1
                if index % 2 == 0 then
                    draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 5))
                end
            end
            
            -- VIP türüne göre sol kenar rengi
            surface.SetDrawColor(data.rankColor)
            surface.DrawRect(0, 0, 4, h)
            
            -- Süre az kaldıysa kırmızı arka plan
            if data.expiry and data.expiry > 0 then
                local time_left = data.expiry - os.time()
                if time_left > 0 and time_left < 86400 then -- 1 günden az
                    surface.SetDrawColor(255, 0, 0, 20)
                    surface.DrawRect(0, 0, w, h)
                end
            end
        end
        
        SAM_VIP_MENU:CreateActionButtons(line, data)
    end
end)