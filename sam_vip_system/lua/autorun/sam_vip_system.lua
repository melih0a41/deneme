-- SAM VIP Yönetim Sistemi
-- Profesyonel VIP yönetimi için gelişmiş addon

if SERVER then
    local sam = sam
    local command = sam.command
    
    -- Komut kategorisini ayarla
    command.set_category("VIP Yönetimi")
    
    -- !vipmenu komutunu oluştur
    command.new("vipmenu")
        :SetPermission("vip_menu", "superadmin")
        :SetCategory("User Management") -- User Management kategorisine ekle
        :Help("VIP yönetim menüsünü açar")
        :OnExecute(function(ply)
            net.Start("SAM_VIP_OpenMenu")
            net.Send(ply)
        end)
    :End()
    
    -- !vipver komutunu oluştur
    command.new("vipver")
        :SetPermission("vip_ver", "superadmin")
        :SetCategory("User Management")
        :AddArg("player", {single_target = true})
        :AddArg("length", {hint = "süre (dakika)", optional = true, default = 1440}) -- Varsayılan 1 gün
        :Help("Oyuncuya VIP verir")
        :OnExecute(function(ply, targets, length)
            local target = targets[1]
            local duration = length * 60
            
            target:sam_set_rank("vip", duration)
            
            sam.player.send_message(nil, "{A} {T} oyuncusuna {V} süreliğine VIP verdi", {
                A = ply, 
                T = targets, 
                V = sam.format_length(length)
            })
        end)
    :End()
    
    -- !vipuzat komutunu oluştur
    command.new("vipuzat")
        :SetPermission("vip_uzat", "superadmin")
        :SetCategory("User Management")
        :AddArg("player", {single_target = true})
        :AddArg("length", {hint = "eklenecek süre (dakika)"})
        :Help("VIP süresini uzatır")
        :OnExecute(function(ply, targets, length)
            local target = targets[1]
            
            if target:GetUserGroup() ~= "vip" then
                return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets})
            end
            
            -- SQL'den mevcut bitiş zamanını al
            local current_expiry = 0
            local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(target:SteamID()))
            if query then
                current_expiry = tonumber(query) or 0
            end
            
            local new_expiry = math.max(current_expiry, os.time()) + (length * 60)
            
            -- SQL'de güncelle
            sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(target:SteamID()))
            
            -- SAM'a bildir
            if sam.player and sam.player.set_rank then
                sam.player.set_rank(target:SteamID(), "vip", new_expiry)
            end
            
            sam.player.send_message(nil, "{A} {T} oyuncusunun VIP süresine {V} ekledi", {
                A = ply,
                T = targets,
                V = sam.format_length(length)
            })
        end)
    :End()
    
    -- !vipkaldir komutunu oluştur
    command.new("vipkaldir")
        :SetPermission("vip_kaldir", "superadmin")
        :SetCategory("User Management")
        :AddArg("player", {single_target = true})
        :Help("VIP rankını kaldırır")
        :OnExecute(function(ply, targets)
            local target = targets[1]
            
            if target:GetUserGroup() ~= "vip" then
                return ply:sam_send_message("{T} oyuncusunun VIP rankı yok!", {T = targets})
            end
            
            -- Rank'ı user yap
            target:sam_set_rank("user")
            
            -- SQL'de de güncelle
            sql.Query("UPDATE sam_players SET rank = 'user', expiry_date = 0 WHERE steamid = " .. sql.SQLStr(target:SteamID()))
            
            sam.player.send_message(nil, "{A} {T} oyuncusundan VIP rankını kaldırdı", {
                A = ply,
                T = targets
            })
        end)
    :End()
    
    -- VIP listesi için network
    util.AddNetworkString("SAM_VIP_OpenMenu")
    util.AddNetworkString("SAM_VIP_GetList")
    util.AddNetworkString("SAM_VIP_SendList")
    util.AddNetworkString("SAM_VIP_Action")
    
    -- VIP listesini gönder
    net.Receive("SAM_VIP_GetList", function(len, ply)
        if not ply:HasPermission("vip_menu") then return end
        
        local vip_list = {}
        local added_steamids = {}
        
        -- Online oyuncuları kontrol et
        for _, p in ipairs(player.GetAll()) do
            if p:GetUserGroup() == "vip" then
                local expiry = 0
                
                -- SQL'den expiry bilgisini al
                local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(p:SteamID()))
                if query then
                    expiry = tonumber(query) or 0
                end
                
                local time_left = expiry > 0 and (expiry - os.time()) or -1
                
                table.insert(vip_list, {
                    steamid = p:SteamID(),
                    nick = p:Nick(),
                    time_left = time_left,
                    expiry = expiry,
                    online = true
                })
                
                added_steamids[p:SteamID()] = true
            end
        end
        
        -- SQL'den tüm VIP'leri al (offline olanlar dahil)
        local query = [[
            SELECT steamid, name, rank, expiry_date 
            FROM sam_players 
            WHERE rank = 'vip'
        ]]
        
        local result = sql.Query(query)
        if result then
            for _, row in ipairs(result) do
                if not added_steamids[row.steamid] then
                    local expiry = tonumber(row.expiry_date) or 0
                    local time_left = expiry > 0 and (expiry - os.time()) or -1
                    
                    -- Süresi dolmuş VIP'leri gösterme (0 kalıcı demek)
                    if expiry == 0 or time_left > 0 then
                        table.insert(vip_list, {
                            steamid = row.steamid,
                            nick = row.name or row.steamid,
                            time_left = time_left,
                            expiry = expiry,
                            online = false
                        })
                    end
                end
            end
        end
        
        -- Listeyi gönder
        net.Start("SAM_VIP_SendList")
        net.WriteTable(vip_list)
        net.Send(ply)
    end)
    
    -- VIP aksiyonları
    net.Receive("SAM_VIP_Action", function(len, ply)
        if not ply:HasPermission("vip_menu") then return end
        
        local action = net.ReadString()
        local steamid = net.ReadString()
        
        if action == "remove" then
            -- Önce oyuncuyu bul
            local target = player.GetBySteamID(steamid)
            local target_name = "Bilinmeyen"
            
            if IsValid(target) then
                -- Online oyuncu - direkt SAM komutu
                target_name = target:Nick()
                target:sam_set_rank("user")
            else
                -- Offline oyuncu - SQL'den ismi al ve rankı güncelle
                local name_query = sql.QueryValue("SELECT name FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
                if name_query then
                    target_name = name_query
                end
                
                sql.Query("UPDATE sam_players SET rank = 'user', expiry_date = 0 WHERE steamid = " .. sql.SQLStr(steamid))
            end
            
            -- Log mesajı - isim bilgisiyle
            sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusundan VIP rankını kaldırdı", {
                A = ply
            })
            
        elseif action == "extend" then
            local days = net.ReadUInt(16)
            local minutes = days * 1440
            
            -- Oyuncu bilgilerini al
            local target = player.GetBySteamID(steamid)
            local target_name = "Bilinmeyen"
            
            if IsValid(target) then
                target_name = target:Nick()
            else
                -- Offline oyuncu - SQL'den ismi al
                local name_query = sql.QueryValue("SELECT name FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
                if name_query then
                    target_name = name_query
                end
            end
            
            -- Mevcut süreyi al
            local current_expiry = 0
            local query = sql.QueryValue("SELECT expiry_date FROM sam_players WHERE steamid = " .. sql.SQLStr(steamid))
            if query then
                current_expiry = tonumber(query) or 0
            end
            
            local new_expiry = math.max(current_expiry, os.time()) + (minutes * 60)
            
            -- SQL'de güncelle
            sql.Query("UPDATE sam_players SET expiry_date = " .. new_expiry .. " WHERE steamid = " .. sql.SQLStr(steamid))
            
            -- Online oyuncuyu güncelle
            if IsValid(target) then
                target:sam_set_rank("vip", new_expiry)
            end
            
            -- Log mesajı - isim bilgisiyle
            sam.player.send_message(nil, "{A} " .. target_name .. " oyuncusunun VIP süresine {V} ekledi", {
                A = ply,
                V = sam.format_length(minutes)
            })
        end
    end)
    
    -- VIP rankını oluştur
    hook.Add("SAM.LoadedRanks", "CreateVIPRank", function()
        if not sam.ranks.is_rank("vip") then
            sam.ranks.add_rank("vip", "user", 10, 0)
            
            timer.Simple(1, function()
                sam.ranks.give_permission("vip", "physgun_player")
                sam.ranks.give_permission("vip", "noclip")
                sam.ranks.set_limit("vip", "props", 150)
                sam.ranks.set_limit("vip", "vehicles", 5)
            end)
        end
    end)
    
    -- VIP süresi dolduğunda
    hook.Add("SAM.Player.OnRankExpire", "VIPExpired", function(ply, old_rank)
        if old_rank == "vip" then
            ply:sam_send_message("VIP süreniz doldu!")
        end
    end)
    
    -- Konsol komutları
    concommand.Add("sam_vip_menu", function(ply)
        if IsValid(ply) and ply:HasPermission("vip_menu") then
            net.Start("SAM_VIP_OpenMenu")
            net.Send(ply)
        end
    end)
    
    -- Debug komutu - VIP listesini konsola yazdır
    concommand.Add("sam_vip_debug", function(ply)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        print("=== SAM VIP Debug ===")
        
        -- Online VIP'ler
        print("Online VIP'ler:")
        for _, p in ipairs(player.GetAll()) do
            if p:GetUserGroup() == "vip" then
                print("  - " .. p:Nick() .. " (" .. p:SteamID() .. ")")
            end
        end
        
        -- SQL tablo yapısını kontrol et
        print("\nSQL Tablo Yapısı:")
        if sql.TableExists("sam_players") then
            print("  sam_players tablosu mevcut")
            
            -- Tablo sütunlarını göster
            local columns = sql.Query("PRAGMA table_info(sam_players)")
            if columns then
                print("  Sütunlar:")
                for _, col in ipairs(columns) do
                    print("    - " .. col.name .. " (" .. col.type .. ")")
                end
            end
            
            -- VIP kayıtlarını detaylı göster
            local result = sql.Query("SELECT * FROM sam_players WHERE rank = 'vip' LIMIT 5")
            if result then
                print("\n  VIP Kayıtları (detaylı):")
                for i, row in ipairs(result) do
                    print("    Kayıt " .. i .. ":")
                    for k, v in pairs(row) do
                        print("      " .. k .. " = " .. tostring(v))
                    end
                end
            end
        else
            print("  sam_players tablosu bulunamadı")
        end
        
        print("=== Debug Sonu ===")
    end)
end

-- Client tarafı
if CLIENT then
    local PANEL = {}
    
    -- Ana panel
    function PANEL:Init()
        self:SetSize(1400, 800)
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
        self.TopPanel:SetTall(120)
        self.TopPanel:DockMargin(10, 10, 10, 10)
        self.TopPanel.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45, 230))
        end
        
        -- İstatistik paneli
        self.StatsPanel = vgui.Create("DPanel", self.TopPanel)
        self.StatsPanel:Dock(TOP)
        self.StatsPanel:SetTall(60)
        self.StatsPanel:DockMargin(10, 10, 10, 5)
        self.StatsPanel.Paint = function(s, w, h)
            local boxWidth = w / 3
            
            -- Toplam VIP
            draw.RoundedBox(6, 5, 0, boxWidth - 10, h, Color(60, 60, 60, 200))
            draw.SimpleText("Toplam VIP", "DermaDefault", boxWidth/2, 15, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(#(self.VIPList:GetLines() or {})), "DermaLarge", boxWidth/2, 35, Color(255, 215, 0), TEXT_ALIGN_CENTER)
            
            -- Online sayısı
            local onlineCount = 0
            for _, line in pairs(self.VIPList:GetLines() or {}) do
                if line:GetColumnText(1):find("●") then
                    onlineCount = onlineCount + 1
                end
            end
            
            draw.RoundedBox(6, boxWidth + 5, 0, boxWidth - 10, h, Color(60, 60, 60, 200))
            draw.SimpleText("Online", "DermaDefault", boxWidth + boxWidth/2, 15, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(onlineCount), "DermaLarge", boxWidth + boxWidth/2, 35, Color(100, 255, 100), TEXT_ALIGN_CENTER)
            
            -- Bilgi
            draw.RoundedBox(6, boxWidth * 2 + 5, 0, boxWidth - 10, h, Color(60, 60, 60, 200))
            draw.SimpleText("● Online | ○ Offline", "DermaDefaultBold", boxWidth * 2 + boxWidth/2, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        end
        
        -- Yeni VIP ekle butonu
        self.AddVIPBtn = vgui.Create("DButton", self.TopPanel)
        self.AddVIPBtn:Dock(LEFT)
        self.AddVIPBtn:SetWide(200)
        self.AddVIPBtn:DockMargin(10, 10, 5, 10)
        self.AddVIPBtn:SetText("Yeni VIP Ekle")
        self.AddVIPBtn:SetFont("DermaDefault")
        self.AddVIPBtn:SetTextColor(Color(255, 255, 255))
        self.AddVIPBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 167, 69, s:IsHovered() and 255 or 200))
        end
        self.AddVIPBtn.DoClick = function()
            self:OpenAddVIPMenu()
        end
        
        -- Yenile butonu
        self.RefreshBtn = vgui.Create("DButton", self.TopPanel)
        self.RefreshBtn:Dock(RIGHT)
        self.RefreshBtn:SetWide(100)
        self.RefreshBtn:DockMargin(5, 10, 10, 10)
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
        col1:SetMinWidth(350)
        col1:SetMaxWidth(350)
        
        local col2 = self.VIPList:AddColumn("Steam ID")
        col2:SetMinWidth(250)
        col2:SetMaxWidth(250)
        
        local col3 = self.VIPList:AddColumn("Kalan Süre")
        col3:SetMinWidth(400)
        col3:SetMaxWidth(400)
        
        local col4 = self.VIPList:AddColumn("İşlemler")
        col4:SetMinWidth(350)
        col4:SetMaxWidth(350)
        
        self.VIPList:SetDataHeight(45) -- Satır yüksekliği
        
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
        
        -- Listeyi başlat
        self:RefreshList()
    end
    
    function PANEL:RefreshList()
        net.Start("SAM_VIP_GetList")
        net.SendToServer()
    end
    
    function PANEL:OpenAddVIPMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 350)
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
        
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetUserGroup() ~= "vip" then
                plycombo:AddChoice(ply:Nick(), ply:SteamID())
            end
        end
        
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
            local timelabel, time = timecombo:GetSelected()
            
            if steamid and time then
                RunConsoleCommand("sam", "vipver", nick, tostring(time))
                frame:Close()
                timer.Simple(0.5, function()
                    self:RefreshList()
                end)
            end
        end
    end
    
    function PANEL:CreateActionButtons(line, steamid)
        -- Daha büyük ve daha iyi aralıklı butonlar
        local actions = vgui.Create("DPanel", line)
        actions:SetWide(340)
        actions:Dock(RIGHT)
        actions:DockMargin(10, 5, 10, 5)
        actions.Paint = function() end
        
        -- Süre ekle butonu
        local extend = vgui.Create("DButton", actions)
        extend:Dock(LEFT)
        extend:SetWide(160)
        extend:DockMargin(0, 0, 10, 0)
        extend:SetText("Süre Ekle")
        extend:SetFont("DermaDefaultBold")
        extend:SetTextColor(Color(255, 255, 255))
        extend.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(23, 162, 184, s:IsHovered() and 255 or 200))
        end
        extend.DoClick = function()
            self:OpenExtendMenu(steamid)
        end
        
        -- Kaldır butonu
        local remove = vgui.Create("DButton", actions)
        remove:Dock(RIGHT)
        remove:SetWide(160)
        remove:SetText("VIP Kaldır")
        remove:SetFont("DermaDefaultBold")
        remove:SetTextColor(Color(255, 255, 255))
        remove.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(220, 53, 69, s:IsHovered() and 255 or 200))
        end
        remove.DoClick = function()
            Derma_Query("Bu oyuncudan VIP rankını kaldırmak istediğinize emin misiniz?", "VIP Kaldır",
                "Evet", function()
                    net.Start("SAM_VIP_Action")
                    net.WriteString("remove")
                    net.WriteString(steamid)
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
    
    function PANEL:OpenExtendMenu(steamid)
        Derma_StringRequest("VIP Süresini Uzat", "Kaç gün eklemek istiyorsunuz?", "1", function(days)
            local num = tonumber(days)
            if num and num > 0 then
                net.Start("SAM_VIP_Action")
                net.WriteString("extend")
                net.WriteString(steamid)
                net.WriteUInt(num, 16)
                net.SendToServer()
                
                timer.Simple(0.5, function()
                    self:RefreshList()
                end)
            end
        end)
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
            
            local line = SAM_VIP_MENU.VIPList:AddLine(nick_text, data.steamid, time_text, "")
            
            -- Satır için font ayarı
            for i = 1, 4 do
                if line.Columns[i] then
                    line.Columns[i]:SetFont("DermaDefaultBold")
                    line.Columns[i]:SetTextColor(Color(255, 255, 255))
                    line.Columns[i]:SetContentAlignment(5) -- Ortala
                end
            end
            
            -- Satır renklendirme
            if data.online then
                line.Columns[1]:SetTextColor(Color(100, 255, 100)) -- Online oyuncular yeşil
            else
                line.Columns[1]:SetTextColor(Color(200, 200, 200)) -- Offline oyuncular gri
            end
            
            -- Sol hizalama için oyuncu ismini
            line.Columns[1]:SetContentAlignment(4) -- Sol ortala
            
            -- Satır arka plan rengi ve yükseklik
            line:SetTall(45) -- Satır yüksekliğini artır
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
                
                -- Süre az kaldıysa kırmızı arka plan
                if data.expiry and data.expiry > 0 then
                    local time_left = data.expiry - os.time()
                    if time_left > 0 and time_left < 86400 then -- 1 günden az
                        surface.SetDrawColor(255, 0, 0, 20)
                        surface.DrawRect(0, 0, w, h)
                    end
                end
            end
            
            SAM_VIP_MENU:CreateActionButtons(line, data.steamid)
        end
    end)
end

print("[SAM VIP Sistemi] Başarıyla yüklendi!")
print("[SAM VIP Sistemi] Komutlar: !vipmenu, !vipver, !vipuzat, !vipkaldir")