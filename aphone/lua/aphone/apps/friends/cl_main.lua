local APP = {}

APP.name = "Twitter"
APP.icon = "akulla/aphone/app_twitter.png" -- Varsayılan, sonra imgur'dan değişecek

-- IMGUR ICON YÜKLEME
local iconURL = "https://i.imgur.com/JpKSdYV.png" -- Twitter logo URL
local iconPath = "twitter_icon_" .. util.CRC(iconURL) .. ".png"

-- Icon'u yükle veya cache'den al
timer.Simple(2, function()
    -- Cache kontrolü
    if file.Exists(iconPath, "DATA") then
        -- Material oluştur
        local mat = Material("data/" .. iconPath, "noclamp smooth")
        
        if not mat:IsError() then
            APP.icon = mat
            
            if aphone and aphone.Apps and aphone.Apps["Twitter"] then
                aphone.Apps["Twitter"].icon = mat
            end
        end
    else
        -- Imgur'dan indir
        http.Fetch(iconURL, 
            function(body, size, headers, code)
                -- Dosyaya kaydet
                file.Write(iconPath, body)
                
                -- Material oluştur
                timer.Simple(0.1, function()
                    local mat = Material("data/" .. iconPath, "noclamp smooth")
                    
                    if not mat:IsError() then
                        APP.icon = mat
                        
                        -- aPhone'a güncelle
                        if aphone and aphone.Apps and aphone.Apps["Twitter"] then
                            aphone.Apps["Twitter"].icon = mat
                        end
                    end
                end)
            end,
            function(error)
                print("[Twitter] Icon indirme hatasi: " .. error)
            end
        )
    end
end)

local m = Material("akulla/aphone/avatar_unknown.png", "smooth 1")
local red = Color(255, 82, 82)
local last_closedpic

function APP:Open(main, main_x, main_y, screenmode)
    -- Main panel cursor'unu hemen gizle
    main:SetCursor("blank")
    
    local clr_black2 = aphone:Color("Black2")
    local clr_black1 = aphone:Color("Black1")
    local color_white180 = aphone:Color("Text_White180")
    local Roboto60 = aphone:GetFont("Roboto60")
    local font_mediumheader = aphone:GetFont("MediumHeader_500")
    local font_header = aphone:GetFont("Roboto40")
    local font_little = aphone:GetFont("Little_NoWeight")
    local font_small = aphone:GetFont("Small")
    local font_littlew = aphone:GetFont("Little")
    local svg_30 = aphone:GetFont("SVG_30")
    local svg_25 = aphone:GetFont("SVG_25") 
    
    -- Twitter renkleri
    local twitter_blue = Color(29, 161, 242)
    local twitter_dark = Color(15, 20, 25)
    local twitter_gray = Color(136, 153, 166)
    local twitter_light_gray = Color(196, 207, 214)
    local twitter_hover = Color(26, 145, 218)
    local white = Color(255, 255, 255)

    -- Unique session ID oluştur (Enter tuşu için)
    local sessionID = "Twitter_" .. os.time() .. "_" .. math.random(1000, 9999)
    
    -- Enter tuşu kontrolü için değişken
    local waitingForEnter = false

    if !screenmode then
        main:Phone_DrawTop(main_x, main_y, false) -- true yerine false
    end
    
    -- Get player ids
    local already_ids = {}

    for k, v in ipairs(player.GetHumans()) do
        already_ids[v:aphone_GetID()] = v
    end

    function main:Paint(w, h)
        -- Gradient arka plan
        surface.SetDrawColor(29, 161, 242) -- Twitter mavisi
        surface.DrawRect(0, 0, w, h/7) -- 1/5 yerine 1/7 yapıldı (daha da küçük)
        
        surface.SetDrawColor(245, 248, 250) -- Çok açık gri/beyaz
        surface.DrawRect(0, h/7, w, h)
    end

    -- Alt mesaj yazma alanı
    local message_writing = vgui.Create("DPanel", main)
    message_writing:Dock(BOTTOM)
    message_writing:DockMargin(main_x * 0.04, main_y * 0.025, main_x * 0.04, main_y * 0.025)
    message_writing:SetTall(screenmode and main_x*0.07 or main_y * 0.07)
    message_writing:SetCursor("blank") -- Cursor'u gizle

    local perfect_h = main_y * 0.035

    function message_writing:Paint(w, h)
        draw.RoundedBox(perfect_h, 0, 0, w, h, Color(245, 248, 250)) -- Çok açık gri arka plan
        draw.RoundedBox(perfect_h, 1, 1, w-2, h-2, Color(255, 255, 255)) -- Beyaz iç kısım
    end

    surface.SetFont(svg_30)
    local msg_writingtall = message_writing:GetTall()

    local message_send = vgui.Create("DLabel", message_writing)
    message_send:Dock(RIGHT)
    message_send:DockMargin(0, 0, msg_writingtall / 4, 0)
    message_send:SetWide(select(1, surface.GetTextSize("i")))
    message_send:SetFont(svg_30)
    message_send:SetText("i")
    message_send:SetTextColor(twitter_dark) -- Koyu renk yap
    message_send:SetMouseInputEnabled(true)
    message_send:SetCursor("blank") -- Cursor'u gizle
    -- Phone_AlphaHover() kaldırıldı - renk sorununa neden olabilir
    
    -- Manuel hover efekti
    function message_send:OnCursorEntered()
        self:SetTextColor(twitter_blue)
    end
    
    function message_send:OnCursorExited()
        self:SetTextColor(twitter_dark)
    end

    -- aphone_OnlinePictureList
    local messages_pic = vgui.Create("DLabel", message_writing)
    messages_pic:Dock(RIGHT)
    messages_pic:DockMargin(0, 0, msg_writingtall / 4, 0)
    messages_pic:SetWide(select(1, surface.GetTextSize("m")))
    messages_pic:SetFont(svg_30)
    messages_pic:SetText("m")
    messages_pic:SetTextColor(twitter_dark) -- Koyu renk yap
    messages_pic:SetMouseInputEnabled(true)
    messages_pic:SetCursor("blank") -- Cursor'u gizle
    -- Phone_AlphaHover() kaldırıldı - renk sorununa neden olabilir
    
    -- Manuel hover efekti
    function messages_pic:OnCursorEntered()
        self:SetTextColor(twitter_blue)
    end
    
    function messages_pic:OnCursorExited()
        self:SetTextColor(twitter_dark)
    end

    local message_writingEntry = vgui.Create("DLabel", message_writing)
    message_writingEntry:Dock(FILL)
    message_writingEntry:DockMargin(msg_writingtall / 2, 0, msg_writingtall / 2, 0)
    message_writingEntry:SetFont(font_mediumheader)
    message_writingEntry:SetText("Neler oluyor?") -- Twitter tarzı placeholder
    message_writingEntry:SetTextColor(twitter_gray) -- Gri placeholder
    message_writingEntry:SetMouseInputEnabled(true)
    message_writingEntry:SetCursor("blank") -- Cursor'u gizle

    -- Create a panel to select online pictures, then set the dlabel text to the link
    function messages_pic:DoClick()
        local messages_picmain = vgui.Create("aphone_OnlinePictureList", main)
        messages_picmain:SetCursor("blank") -- Cursor'u gizle
        function messages_picmain:OnSelected(imgur_url)
            -- Önce resmi gönder
            local fullImgUrl = "imgur://" .. imgur_url
            aphone.Contacts.Send(id, fullImgUrl, true)
            
            -- BİLDİRİM SİSTEMİ İÇİN EKLENEN KOD
            -- Sunucuya resimli tweet bildir - TAM URL ile
            net.Start("aphone_tweet_sent")
                net.WriteString("") -- Boş metin, çünkü sadece resim var
                net.WriteBool(true) -- Resim var
                net.WriteString(fullImgUrl) -- TAM imgur URL'si
            net.SendToServer()
            
            -- YENİ EKLENEN: Resim gönderildikten sonra en alta kaydır
            timer.Simple(0.1, function()
                if IsValid(message_scroll) then
                    message_scroll:GetVBar():SetScroll(message_scroll.pnlCanvas:GetTall())
                end
            end)
        end
    end

    local placeholder = "Neler oluyor?"
    function message_writingEntry:DoClick()
        -- Enter kontrolünü başlat
        waitingForEnter = true
        
        self:Phone_AskTextEntry(message_writingEntry:GetText() == placeholder and "" or self:GetText(), 140, message_writing, (main_x * 0.92 - msg_writingtall * 1.25 - messages_pic:GetWide() - message_send:GetWide()))
    end

    function message_writingEntry:textEnd(clean_txt, wrapped_txt)
        self:SetText(wrapped_txt)
        self.goodtext = clean_txt
        
        -- Sadece text değiştiğinde renk ayarla
        if not self.lastText or self.lastText ~= wrapped_txt then
            self.lastText = wrapped_txt
            -- DÜZELTME: Yazı yazıldığında rengi koyu yapıyoruz
            if wrapped_txt ~= placeholder and wrapped_txt ~= "" then
                self:SetTextColor(twitter_dark) -- Koyu renk
            else
                self:SetTextColor(twitter_gray) -- Placeholder rengi
            end
        end
    end

    -- Header Twitter yazısı
    local player_text = vgui.Create("DLabel", main)
    player_text:Dock(TOP)
    player_text:DockMargin(main_x * 0.05, main_y * 0.06, 0, 0) -- Üst margin daha da azaltıldı
    player_text:SetText("Twitter")
    player_text:SetTextColor(white) -- Beyaz (mavi arka plan üzerinde)
    player_text:SetFont(aphone:GetFont("Header_Friends"))
    player_text:SetContentAlignment(5)
    player_text:SetTall(select(2, player_text:GetTextSize()))
    player_text:SetCursor("blank") -- Cursor'u gizle

    -- ===============================================
    -- BİLDİRİM TOGGLE BUTONU - TEMİZ VE ÇALIŞAN
    -- ===============================================
    
    local notif_toggle = vgui.Create("DPanel", main)
    notif_toggle:SetSize(80, 80)
    notif_toggle:SetZPos(1000)
    -- Global durumu kullan
    notif_toggle.isEnabled = APHONE_TWITTER_NOTIFICATIONS_ENABLED or true
    notif_toggle:SetMouseInputEnabled(true)
    notif_toggle:SetCursor("blank")
    
    print("[Twitter] ✓ Bildirim toggle butonu oluşturuldu")
    
    -- Map-specific PNG ikonları yükle
    local currentMap = game.GetMap()
    local bell_on, bell_off
    
    if currentMap == "rp_downtown_baso" then
        bell_on = Material("icons/bell_on.png", "smooth")
        bell_off = Material("icons/bell_off.png", "smooth")
        
        if bell_on:IsError() or bell_off:IsError() then
            print("[Twitter] Map ikonları bulunamadı, varsayılan kullanılacak")
            bell_on = Material("akulla/aphone/app_twitter.png", "smooth")
            bell_off = Material("icon16/cancel.png", "smooth")
        else
            print("[Twitter] ✓ Map-specific ikonlar yüklendi")
        end
    else
        bell_on = Material("akulla/aphone/app_twitter.png", "smooth")
        bell_off = Material("icon16/cancel.png", "smooth")
    end
    
    -- Pozisyon ayarla
    timer.Simple(0.1, function()
        if IsValid(notif_toggle) and IsValid(main) then
            local x = main:GetWide() - 90 -- Sağdan aynı mesafe
            local y = 40 -- ÇOOK AZ YUKARIDA: 50'den 45'e
            notif_toggle:SetPos(x, y)
            print("[Twitter] İDEAL buton pozisyonu: " .. x .. ", " .. y .. " (80x80)")
        end
    end)

    -- Buton çizimi
    function notif_toggle:Paint(w, h)
        local isEnabled = self.isEnabled
        
        -- PNG ikonları kullanmayı dene
        local iconMat = isEnabled and bell_on or bell_off
        
        if iconMat and not iconMat:IsError() then
            -- SADECE PNG İKON - HİÇ ARKA PLAN YOK
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(0, 0, w, h) -- TAM BOYUT ikon
        else
            -- PNG fallback - SADECE RENK KUTU
            if isEnabled then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 255, 0, 255)) -- Yeşil
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 255)) -- Kırmızı
            end
        end
    end
    
    -- Click eventi - DPanel için
    function notif_toggle:OnMousePressed(keyCode)
        if keyCode == MOUSE_LEFT then
            -- Durumu değiştir
            self.isEnabled = not self.isEnabled
            
            -- Gerçek toggle fonksiyonunu çağır
            if APHONE_TwitterNotifToggle then
                APHONE_TwitterNotifToggle()
            end
            
            -- Ses efekti
            surface.PlaySound("ui/buttonclick.wav")
            
            -- Log
            print("[Twitter] Bildirimler " .. (self.isEnabled and "AÇILDI" or "KAPATILDI"))
        end
    end
    
    -- Hover sesi - DPanel için
    function notif_toggle:OnCursorEntered()
        surface.PlaySound("ui/buttonrollover.wav")
    end

    local message_scroll = vgui.Create("DScrollPanel", main)
    message_scroll:Dock(FILL)
    message_scroll:aphone_PaintScroll()
    message_scroll:DockMargin(screenmode and main_x * 0.03 or 0, 0, 0, 0)
    message_scroll:SetCursor("blank") -- Cursor'u gizle

    aphone.Friends_PanelList = {}
    local lastpanel

    function aphone.InsertNewMessage_Friend(userid, body, msg_id, last_name, likes, local_vote)
        if IsValid(message_scroll) then
            local sub

            if !lastpanel or lastpanel.userid ~= userid then
                sub = message_scroll:Add("DPanel")
                sub:SetTall(aphone.GUI.ScaledSizeY(54))
                sub:Dock(TOP)
                sub:SetPaintBackground(false)
                sub:DockMargin(0, 0, 0, main_y*0.02)
                sub:SetCursor("blank") -- Cursor'u gizle
                sub.userid = userid

                -- Tweet arka planı
                function sub:Paint(w, h)
                    surface.SetDrawColor(255, 255, 255) -- Beyaz tweet arka planı
                    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255))
                    
                    -- Alt border
                    surface.SetDrawColor(230, 236, 240)
                    surface.DrawLine(0, h-1, w, h-1)
                end

                local sub_mainpnl = vgui.Create("DPanel", sub)
                sub_mainpnl:SetTall(sub:GetTall())
                sub_mainpnl:Dock(TOP)
                sub_mainpnl:SetPaintBackground(false)
                sub_mainpnl:SetCursor("blank") -- Cursor'u gizle

                local avatar

                -- try to get the player
                if isnumber(userid) and already_ids[userid] then
                    userid = already_ids[userid]
                end

                local connected = !isnumber(userid) and IsValid(userid)
                local plyname = connected and userid:Nick() or last_name

                if !isnumber(userid) and IsValid(userid) then
                    avatar = vgui.Create("aphone_CircleAvatar", sub_mainpnl)
                    avatar:SetPlayer(userid, 64)
                    avatar:SetCursor("blank") -- Cursor'u gizle
                else
                    avatar = vgui.Create("DPanel", sub_mainpnl)
                    avatar:SetCursor("blank") -- Cursor'u gizle

                    function avatar:Paint(w, h)
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(m)
                        surface.DrawTexturedRect(0, 0, h, h)
                    end
                end

                avatar:Dock(LEFT)
                avatar:SetWide(sub_mainpnl:GetTall())
                avatar:DockMargin(sub_mainpnl:GetTall()/6*2, 0, sub_mainpnl:GetTall()/6, 0)

                local bottom_name = vgui.Create("DLabel", sub_mainpnl)
                bottom_name:Dock(BOTTOM)
                bottom_name:SetText("@" .. string.Replace(plyname, " ", ""))
                bottom_name:SetFont(font_little)
                bottom_name:SetTextColor(twitter_gray) -- Twitter gri
                bottom_name:SetAutoStretchVertical(true)
                bottom_name:DockMargin(5, 0, 0, 0)
                bottom_name:SetMouseInputEnabled(false)
                bottom_name:SetCursor("blank") -- Cursor'u gizle

                local subtitle = vgui.Create("DPanel", sub_mainpnl)
                subtitle:Dock(FILL)
                subtitle:SetPaintBackground(false)
                subtitle:SetCursor("blank") -- Cursor'u gizle

                sub.like_logo = vgui.Create("DLabel", subtitle)
                sub.like_logo:Dock(RIGHT)
                sub.like_logo:SetWide(aphone.GUI.ScaledSizeX(25))
                sub.like_logo:SetTextColor(local_vote == 1 and red or twitter_gray)
                sub.like_logo:SetText("3") -- Kalp ikonu
                sub.like_logo:SetFont(svg_25)
                sub.like_logo:SetContentAlignment(5)
                sub.like_logo:SetMouseInputEnabled(true)
                sub.like_logo:SetCursor("blank") -- Cursor'u gizle
                sub.like_logo:DockMargin(0, 0, main_x*0.1, 0)

                function sub.like_logo:DoClick()
                    net.Start("aphone_AddLike") 
                        net.WriteUInt(msg_id, 29)
                    net.SendToServer()
                end

                surface.SetFont(font_littlew)

                sub.like_count = vgui.Create("DLabel", subtitle)
                sub.like_count:Dock(RIGHT)
                sub.like_count:SetWide(select(1, surface.GetTextSize("9999")))
                sub.like_count:SetTextColor(twitter_gray) -- Gri sayı
                sub.like_count:SetText(likes)
                sub.like_count:SetFont(font_littlew)
                sub.like_count:SetContentAlignment(6)
                sub.like_count:DockMargin(3, 0, 3, 0)
                sub.like_count:SetMouseInputEnabled(true)
                sub.like_count:SetCursor("blank") -- Cursor'u gizle

                function sub.like_count:DoClick()
                    sub.like_logo:DoClick()
                end

                local name = vgui.Create("DLabel", subtitle)
                name:Dock(FILL)
                name:SetText(plyname)
                name:SetFont(font_mediumheader)
                name:SetTextColor(twitter_dark) -- Koyu siyah isim
                name:SetAutoStretchVertical(true)
                name:DockMargin(5, 0, 0, 0)
                name:SetCursor("blank") -- Cursor'u gizle

                aphone.Friends_PanelList[tonumber(msg_id)] = sub
                lastpanel = sub
            else
                sub = lastpanel
            end

            local sub_size = aphone.GUI.ScaledSizeY(54)
            local left_margin = sub_size*1.5 + 5

            if string.StartWith(body, "imgur://") then
                local sub_messagepnl = vgui.Create("aphone_MessageImage", sub)
                sub_messagepnl:Dock(TOP)
                sub_messagepnl:Left_Avatar(false)
                sub_messagepnl:SetImgur(body)
                sub_messagepnl:SetTall(main_x * 0.35)
                sub_messagepnl:DockMargin(sub_size * 1.25, 5, sub_size/2, 0)
                sub_messagepnl:SetCursor("blank") -- Cursor'u gizle
                sub:SetTall(sub:GetTall() + sub_messagepnl:GetTall())

                function sub_messagepnl:DoClick()
                    local show_pic = vgui.Create("aphone_ShowImage", main)
                    show_pic:SetMat(aphone.GetImgurMat(body))
                    show_pic:SetCursor("blank") -- Cursor'u gizle
                    last_closedpic = msg_id

                    function show_pic.onclose()
                        last_closedpic = nil
                    end
                end

                if last_closedpic and last_closedpic == msg_id then
                    sub_messagepnl:DoClick()
                end
            else
                local text_panel = vgui.Create("DLabel", sub)
                text_panel:DockMargin(sub_size*1.5 + 5, 5, sub_size/2, 0)
                text_panel:Dock(TOP)
                text_panel:SetCursor("blank") -- Cursor'u gizle

                local wrapped = aphone.GUI.WrapText(body, font_small, main_x - left_margin - sub_size)

                text_panel:SetWrap(true)
                text_panel:SetText(wrapped)
                text_panel:SetFont(font_small)
                text_panel:SetAutoStretchVertical(true)
                text_panel:SetTextColor(twitter_dark) -- Koyu metin rengi
                
                sub:SetTall(sub:GetTall() + select(2, surface.GetTextSize(wrapped)))
            end

            sub:SetTall(sub:GetTall() + aphone.GUI.ScaledSizeY(10))
            sub:aphone_RemoveCursor()
            
            -- Tüm alt elementlerde de cursor'u gizle
            for _, child in ipairs(sub:GetChildren()) do
                if IsValid(child) then
                    child:SetCursor("blank")
                end
            end

            return lastpanel
        end
    end

    function message_send:DoClick()
        if !message_writingEntry.goodtext then return end
        
        local tweetText = message_writingEntry.goodtext

        aphone.Contacts.Send(id, tweetText, true)
        
        -- BİLDİRİM SİSTEMİ İÇİN EKLENEN KOD
        -- Sunucuya tweet gönderildiğini bildir
        net.Start("aphone_tweet_sent")
            net.WriteString(tweetText)
            net.WriteBool(false) -- Resim yok
        net.SendToServer()

        self:GetParent():SetTall(main_y * 0.07)
        message_writingEntry:SetText("Neler oluyor?")
        message_writingEntry:SetTextColor(twitter_gray) -- DÜZELTME: Placeholder rengine geri döndür
        message_writingEntry.goodtext = nil
        
        -- YENİ EKLENEN: Mesaj gönderildikten sonra en alta kaydır
        timer.Simple(0.1, function()
            if IsValid(message_scroll) then
                message_scroll:GetVBar():SetScroll(message_scroll.pnlCanvas:GetTall())
            end
        end)
    end

    -- ENTER TUŞU KONTROLÜ - DEEPWEB'DEN ALINIP UYARLANDI
    hook.Add("Think", "TwitterEnterCheck_" .. sessionID, function()
        if waitingForEnter and input.IsKeyDown(KEY_ENTER) then
            waitingForEnter = false
            
            timer.Simple(0.1, function()
                if IsValid(message_writingEntry) and message_writingEntry.goodtext and message_writingEntry.goodtext ~= "" then
                    if IsValid(message_send) then
                        message_send:DoClick()
                    end
                end
            end)
        end
        
        -- Twitter kapalıysa hook'u kaldır
        if not IsValid(main) then
            hook.Remove("Think", "TwitterEnterCheck_" .. sessionID)
        end
    end)

    -- Let's not load ALL messages. Imagine if he got a lot of messages
    -- IP kontrolünü kaldırıyoruz ki darkweb'den de mesajlar gelsin
    local msg_tbl = sql.Query("SELECT * FROM aphone_Friends WHERE timestamp > " .. os.time() - 604800) or {}

    local scrollto
    for k, v in ipairs(msg_tbl) do
        scrollto = aphone.InsertNewMessage_Friend(tonumber(v.user), v.body, tonumber(v.id), v.last_name, v.likes, tonumber(v.local_vote), false)
    end

    if scrollto then
        -- We need to wait that dock size everything, I think ?
        timer.Simple(0.33, function()
            message_scroll:ScrollToChild(scrollto)
        end)
    end

    main:aphone_RemoveCursor()
    
    -- Normal cursor'u gizle
    main:SetCursor("blank")
    
    -- Alt panellerde de cursor'u gizle
    timer.Simple(0.1, function()
        if IsValid(main) then
            for _, child in ipairs(main:GetChildren()) do
                if IsValid(child) then
                    child:SetCursor("blank")
                end
            end
        end
    end)
    
    -- Cleanup fonksiyonu
    main.OnRemove = function(self)
        -- Enter hook'unu temizle
        hook.Remove("Think", "TwitterEnterCheck_" .. sessionID)
    end
    
    -- Global cursor kontrolü
    local function HideAllCursors(panel)
        if not IsValid(panel) then return end
        panel:SetCursor("blank")
        for _, child in ipairs(panel:GetChildren()) do
            HideAllCursors(child)
        end
    end
    
    -- Hemen ve biraz sonra cursor kontrolü yap
    HideAllCursors(main)
    timer.Simple(0.5, function()
        if IsValid(main) then
            HideAllCursors(main)
        end
    end)
end

function APP:OnClose()
    last_closedpic = nil
    aphone.InsertNewMessage_Friend = nil
    
    -- Tüm Twitter bildirimlerini temizle
    if notifications then
        notifications = {}
    end
    
    -- HUD'daki bildirimleri de temizlemek için
    hook.Run("ClearTwitterNotifications")
end

function APP:Open2D(main, main_x, main_y)
    APP:Open(main, main_x, main_y, true)
end

aphone.RegisterApp(APP)