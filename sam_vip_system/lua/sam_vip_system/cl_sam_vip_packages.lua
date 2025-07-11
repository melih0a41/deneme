-- SAM VIP Yönetim Sistemi - VIP Paketleri Menüsü
-- lua/sam_vip_system/cl_sam_vip_packages.lua

-- Sadece satın alma bilgi penceresindeki fontları güzelleştir
surface.CreateFont("VIPInfoTitle", {
    font = "Trebuchet MS",
    extended = false,
    size = 32,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = true,
})

surface.CreateFont("VIPInfoText", {
    font = "Trebuchet MS",
    extended = false,
    size = 18,
    weight = 600,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPStepNumber", {
    font = "Trebuchet MS",
    extended = false,
    size = 24,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPWebsiteFont", {
    font = "Trebuchet MS",
    extended = false,
    size = 28,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = true,
})

surface.CreateFont("VIPShopButton", {
    font = "Trebuchet MS",
    extended = false,
    size = 26,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPPackageName", {
    font = "Trebuchet MS",
    extended = false,
    size = 28,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = true,
})

-- Resim büyütme fonksiyonu
local function ShowFullscreenImage(imagePath, vipName, vipColor)
    -- Tam ekran resim paneli
    local fullscreenPanel = vgui.Create("DFrame")
    fullscreenPanel:SetSize(ScrW(), ScrH())
    fullscreenPanel:SetPos(0, 0)
    fullscreenPanel:SetTitle("")
    fullscreenPanel:MakePopup()
    fullscreenPanel:ShowCloseButton(false)
    fullscreenPanel:SetDraggable(false)
    
    fullscreenPanel.Paint = function(s, w, h)
        -- Yarı şeffaf siyah arka plan
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        
        -- Üst başlık alanı
        draw.RoundedBox(0, 0, 0, w, 80, Color(20, 20, 20, 230))
        
        -- Başlık
        draw.SimpleText(vipName .. " - Detaylı Görünüm", "DermaLarge", w/2, 40, vipColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Kapat butonu
        draw.RoundedBox(8, w - 60, 20, 40, 40, Color(220, 53, 69, s.CloseHover and 255 or 200))
        draw.SimpleText("X", "DermaLarge", w - 40, 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Alt bilgi alanı
        draw.RoundedBox(0, 0, h - 60, w, 60, Color(20, 20, 20, 230))
        draw.SimpleText("ESC tuşuna basarak veya X butonuna tıklayarak kapatabilirsiniz", "DermaDefault", w/2, h - 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Kapat butonu
    local closeBtn = vgui.Create("DButton", fullscreenPanel)
    closeBtn:SetPos(ScrW() - 60, 20)
    closeBtn:SetSize(40, 40)
    closeBtn:SetText("")
    closeBtn.Paint = function() end
    closeBtn.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        fullscreenPanel:Close() 
    end
    closeBtn.OnCursorEntered = function() fullscreenPanel.CloseHover = true end
    closeBtn.OnCursorExited = function() fullscreenPanel.CloseHover = false end
    
    -- Resim konteyner
    local imageContainer = vgui.Create("DPanel", fullscreenPanel)
    imageContainer:SetPos(100, 100)
    imageContainer:SetSize(ScrW() - 200, ScrH() - 200)
    imageContainer.Paint = function(s, w, h)
        -- Resim çerçevesi
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 255))
        draw.RoundedBox(8, 4, 4, w - 8, h - 8, Color(60, 60, 60, 255))
    end
    
    -- Ana resim - tam ortalanmış
    if file.Exists(imagePath, "GAME") then
        local mainImage = vgui.Create("DImage", imageContainer)
        mainImage:Dock(FILL)
        mainImage:DockMargin(8, 8, 8, 8)
        mainImage:SetImage(imagePath)
        mainImage:SetKeepAspect(true)
        
        -- Resmi tam ortala
        mainImage.Paint = function(s, w, h)
            -- Resim boyutlarını hesapla
            local mat = Material(imagePath)
            if mat and not mat:IsError() then
                local texW, texH = mat:Width(), mat:Height()
                local scale = math.min(w / texW, h / texH)
                local scaledW, scaledH = texW * scale, texH * scale
                
                -- Ortalama hesapla
                local x = (w - scaledW) / 2
                local y = (h - scaledH) / 2
                
                -- Resmi ortala ve çiz
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(x, y, scaledW, scaledH)
            end
        end
    else
        -- Resim yoksa placeholder
        local placeholder = vgui.Create("DPanel", imageContainer)
        placeholder:SetPos(8, 8)
        placeholder:SetSize(imageContainer:GetWide() - 16, imageContainer:GetTall() - 16)
        placeholder.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 255))
            draw.SimpleText("Resim Bulunamadı", "DermaLarge", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- ESC tuşu ile kapama - basit yöntem
    hook.Add("Think", "VIPFullscreenESC", function()
        if IsValid(fullscreenPanel) then
            if input.IsKeyDown(KEY_ESCAPE) then
                fullscreenPanel:Close()
                hook.Remove("Think", "VIPFullscreenESC")
            end
        else
            hook.Remove("Think", "VIPFullscreenESC")
        end
    end)
    
    -- Arka plana tıklayarak kapama
    fullscreenPanel.OnMousePressed = function(s, mouse)
        if mouse == MOUSE_LEFT then
            local x, y = s:CursorPos()
            -- Resim alanının dışına tıklandıysa kapat
            if x < 100 or x > ScrW() - 100 or y < 100 or y > ScrH() - 100 then
                s:Close()
            end
        end
    end
end

-- VIP Paketleri Paneli
net.Receive("SAM_VIP_ShowPackages", function()
    -- Eğer panel zaten açıksa kapat
    if IsValid(VIP_PACKAGES_PANEL) then
        VIP_PACKAGES_PANEL:Remove()
        return
    end
    
    -- Ana panel - ESKİ HALİNE GETİRİLDİ
    VIP_PACKAGES_PANEL = vgui.Create("DFrame")
    VIP_PACKAGES_PANEL:SetSize(ScrW() * 0.8, ScrH() * 0.7)
    VIP_PACKAGES_PANEL:Center()
    VIP_PACKAGES_PANEL:SetTitle("")
    VIP_PACKAGES_PANEL:MakePopup()
    VIP_PACKAGES_PANEL:ShowCloseButton(false)
    VIP_PACKAGES_PANEL:SetDraggable(false)
    
    VIP_PACKAGES_PANEL.Paint = function(s, w, h)
        -- Arkaplan
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        
        -- Başlık alanı
        draw.RoundedBoxEx(12, 0, 0, w, 60, Color(35, 35, 35, 255), true, true, false, false)
        
        -- Başlık çizgisi
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(0, 60, w, 3)
        
        -- Başlık metni - ESKİ FONT
        draw.SimpleText("VIP PAKETLERİ", "DermaLarge", w/2, 30, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Kapat butonu
        draw.RoundedBox(6, w - 50, 15, 30, 30, Color(220, 53, 69, s.CloseHover and 255 or 200))
        draw.SimpleText("✕", "DermaLarge", w - 35, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Kapat butonu
    local closeBtn = vgui.Create("DButton", VIP_PACKAGES_PANEL)
    closeBtn:SetPos(VIP_PACKAGES_PANEL:GetWide() - 50, 15)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.Paint = function() end
    closeBtn.DoClick = function() 
        surface.PlaySound("UI/buttonclick.wav")
        VIP_PACKAGES_PANEL:Close() 
    end
    closeBtn.OnCursorEntered = function() VIP_PACKAGES_PANEL.CloseHover = true end
    closeBtn.OnCursorExited = function() VIP_PACKAGES_PANEL.CloseHover = false end
    
    -- Scroll panel kaldırıldı, direkt container kullanıyoruz
    local container = vgui.Create("DPanel", VIP_PACKAGES_PANEL)
    container:Dock(FILL)
    container:DockMargin(40, 80, 40, 40)
    container.Paint = function() end
    
    -- VIP Paketleri tanımla (güncellendi)
    local vipPackages = {
        {
            name = "Bronz VIP",
            image = "materials/vip_packages/bronze.png",
            color = Color(205, 127, 50),
        },
        {
            name = "Silver VIP", 
            image = "materials/vip_packages/silver.png",
            color = Color(192, 192, 192),
        },
        {
            name = "Gold VIP",
            image = "materials/vip_packages/gold.png",
            color = Color(255, 215, 0),
        },
        {
            name = "Platinum VIP",
            image = "materials/vip_packages/plat.png",
            color = Color(229, 228, 226),
        },
        {
            name = "Diamond VIP",
            image = "materials/vip_packages/diamond.png",
            color = Color(185, 242, 255),
        }
    }
    
    -- Container boyutlarını al
    timer.Simple(0.1, function()
        if not IsValid(container) then return end
        
        local containerWidth = container:GetWide()
        local containerHeight = container:GetTall()
        
        -- Paketleri tam sığdır
        local numPackages = #vipPackages
        local spacing = 20
        local totalSpacing = (numPackages - 1) * spacing
        local cardWidth = (containerWidth - totalSpacing) / numPackages
        local cardHeight = containerHeight - 20
        
        -- Her paket için kart oluştur
        for i, package in ipairs(vipPackages) do
            local card = vgui.Create("DPanel", container)
            card:SetPos((i-1) * (cardWidth + spacing), 10)
            card:SetSize(cardWidth, cardHeight)
            card.Paint = function(s, w, h)
                -- Kart arkaplanı
                draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
                
                -- Üst renkli bölge
                draw.RoundedBoxEx(8, 0, 0, w, 80, package.color, true, true, false, false)
                
                -- Paket adı - ESKİ FONT
                -- Önce siyah gölge
                draw.SimpleText(package.name, "VIPButtonFont", w/2 + 2, 42, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Sonra beyaz yazı (tüm paketler için)
                draw.SimpleText(package.name, "VIPButtonFont", w/2, 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Alternatif: Açık renkli paketler için koyu yazı
                if package.name == "Silver VIP" or package.name == "Platinum VIP" or package.name == "Diamond VIP" then
                    -- Önce beyaz kontur
                    for i = -2, 2 do
                        for j = -2, 2 do
                            if i ~= 0 or j ~= 0 then
                                draw.SimpleText(package.name, "VIPButtonFont", w/2 + i, 40 + j, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
                        end
                    end
                    -- Sonra siyah yazı
                    draw.SimpleText(package.name, "VIPButtonFont", w/2, 40, Color(20, 20, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            -- Resim alanı - dinamik boyut
            local imagePanel = vgui.Create("DPanel", card)
            imagePanel:SetPos(10, 90)
            imagePanel:SetSize(cardWidth - 20, cardHeight - 160)
            imagePanel.Paint = function(s, w, h)
                -- Resim varsa arka plan temiz
                if file.Exists(package.image, "GAME") then
                    -- Hover efekti
                    if s.IsHovered then
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 20))
                    end
                    return
                end
                
                -- Resim yoksa placeholder - daha iyi ortalama
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
                
                -- Ana yazıyı tam ortala
                local text = "VIP " .. package.name:upper()
                surface.SetFont("DermaLarge")
                local tw, th = surface.GetTextSize(text)
                
                -- Tam ortala
                draw.SimpleText(text, "DermaLarge", w/2, h/2 - 15, Color(package.color.r, package.color.g, package.color.b, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Alt yazı
                draw.SimpleText("(Seviye " .. i .. ")", "DermaDefault", w/2, h/2 + 15, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            if file.Exists(package.image, "GAME") then
                local image = vgui.Create("DImage", imagePanel)
                image:Dock(FILL)
                image:SetImage(package.image)
                image:SetKeepAspect(true)
                
                -- Resme tıklanabilir özellik ekle
                local clickablePanel = vgui.Create("DButton", imagePanel)
                clickablePanel:Dock(FILL)
                clickablePanel:SetText("")
                clickablePanel.Paint = function() end
                clickablePanel:SetCursor("hand")
                clickablePanel.OnCursorEntered = function() 
                    imagePanel.IsHovered = true 
                end
                clickablePanel.OnCursorExited = function() 
                    imagePanel.IsHovered = false 
                end
                clickablePanel.DoClick = function()
                    surface.PlaySound("UI/buttonclick.wav")
                    -- Tam ekran resim göster
                    ShowFullscreenImage(package.image, package.name, package.color)
                end
            end
            
            -- Satın al butonu - ESKİ FONT
            local buyBtn = vgui.Create("DButton", card)
            buyBtn:SetPos(10, cardHeight - 60)
            buyBtn:SetSize(cardWidth - 20, 45)
            buyBtn:SetText("SATIN AL")
            buyBtn:SetFont("VIPButtonFont")
            buyBtn:SetTextColor(Color(255, 255, 255))
            buyBtn.Paint = function(s, w, h)
                local btnColor = s:IsHovered() and package.color or Color(60, 60, 60, 255)
                
                -- Buton arka planı gradient efekti
                draw.RoundedBox(8, 0, 0, w, h, btnColor)
                
                -- Üst parlama efekti
                if s:IsHovered() then
                    draw.RoundedBox(8, 0, 0, w, h/2, Color(255, 255, 255, 20))
                end
                
                -- Alt gölge efekti
                draw.RoundedBox(8, 0, h-3, w, 3, Color(0, 0, 0, 50))
            end
            buyBtn.DoClick = function()
                surface.PlaySound("UI/buttonclick.wav")
                
                -- Discord linki veya satın alma talimatları - SADECE BURASI GÜZELLEŞTİRİLDİ
                local infoPanel = vgui.Create("DFrame")
                infoPanel:SetSize(900, 550)
                infoPanel:Center()
                infoPanel:SetTitle("")
                infoPanel:MakePopup()
                infoPanel:ShowCloseButton(false)
                infoPanel:SetDraggable(false)
                
                infoPanel.Paint = function(s, w, h)
                    -- Arka plan
                    draw.RoundedBox(16, 0, 0, w, h, Color(20, 20, 20, 250))
                    
                    -- Başlık alanı
                    draw.RoundedBoxEx(16, 0, 0, w, 80, Color(30, 30, 30, 255), true, true, false, false)
                    
                    -- Başlık çizgisi
                    surface.SetDrawColor(255, 215, 0, 255)
                    surface.DrawRect(0, 80, w, 3)
                    
                    -- Başlık metni - GÜZELLEŞTİRİLDİ
                    draw.SimpleText("VIP SATIN ALMA", "VIPInfoTitle", w/2, 40, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Kapat butonu
                    draw.RoundedBox(8, w - 60, 20, 40, 40, Color(220, 53, 69, s.CloseHover and 255 or 200))
                    draw.SimpleText("✕", "VIPPackageName", w - 40, 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- İçerik alanı
                    local contentY = 110
                    
                    -- Paket bilgisi kutusu
                    draw.RoundedBox(12, 50, contentY, w - 100, 80, package.color)
                    
                    -- Paket adı - Ana menüdeki gibi güzel font ve gölge efekti
                    -- Önce siyah gölge
                    draw.SimpleText(package.name, "VIPButtonFont", w/2 + 2, contentY + 27, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Sonra beyaz yazı (tüm paketler için)
                    draw.SimpleText(package.name, "VIPButtonFont", w/2, contentY + 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Alternatif: Açık renkli paketler için koyu yazı
                    if package.name == "Silver VIP" or package.name == "Platinum VIP" or package.name == "Diamond VIP" then
                        -- Önce beyaz kontur
                        for i = -2, 2 do
                            for j = -2, 2 do
                                if i ~= 0 or j ~= 0 then
                                    draw.SimpleText(package.name, "VIPButtonFont", w/2 + i, contentY + 25 + j, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                end
                            end
                        end
                        -- Sonra siyah yazı
                        draw.SimpleText(package.name, "VIPButtonFont", w/2, contentY + 25, Color(20, 20, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    draw.SimpleText("Paketi almak icin asagidaki adimlari takip edin", "VIPInfoText", w/2, contentY + 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Adımlar başlangıç
                    local stepY = contentY + 110
                    
                    -- Adım 1
                    draw.RoundedBox(12, 60, stepY, 40, 40, Color(46, 125, 50, 255))
                    draw.SimpleText("1", "VIPStepNumber", 80, stepY + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Web sitemizi ziyaret edin", "VIPInfoText", 120, stepY + 20, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    -- Site kutusu
                    local siteY = stepY + 50
                    draw.RoundedBox(12, 100, siteY, w - 200, 70, Color(46, 125, 50, 255))
                    draw.SimpleText("gmodbaso.network", "VIPWebsiteFont", w/2, siteY + 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Adım 2
                    local step2Y = siteY + 90
                    draw.RoundedBox(12, 60, step2Y, 40, 40, Color(46, 125, 50, 255))
                    draw.SimpleText("2", "VIPStepNumber", 80, step2Y + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Mağazadan " .. package.name .. " paketini seçin ve sepete ekleyin", "VIPInfoText", 120, step2Y + 20, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    -- Adım 3
                    local step3Y = step2Y + 50
                    draw.RoundedBox(12, 60, step3Y, 40, 40, Color(46, 125, 50, 255))
                    draw.SimpleText("3", "VIPStepNumber", 80, step3Y + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Odeme sayfasinda PAYTR ile guvenli odeme yapin", "VIPInfoText", 120, step3Y + 20, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    -- Alt bilgi - GÜZELLEŞTİRİLDİ
                    draw.SimpleText("Odemeniz onaylandiktan sonra VIP hemen aktif olur!", "VIPInfoText", w/2, h - 100, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                -- Kapat butonu
                local closeBtn = vgui.Create("DButton", infoPanel)
                closeBtn:SetPos(infoPanel:GetWide() - 60, 20)
                closeBtn:SetSize(40, 40)
                closeBtn:SetText("")
                closeBtn.Paint = function() end
                closeBtn.DoClick = function() 
                    surface.PlaySound("UI/buttonclick.wav")
                    infoPanel:Close() 
                end
                closeBtn.OnCursorEntered = function() infoPanel.CloseHover = true end
                closeBtn.OnCursorExited = function() infoPanel.CloseHover = false end
                
                -- Web Sitesine Git butonu - GÜZELLEŞTİRİLDİ
                local siteBtn = vgui.Create("DButton", infoPanel)
                siteBtn:SetPos(300, 460)
                siteBtn:SetSize(300, 60)
                siteBtn:SetText("MAGAZAYA GIT")
                siteBtn:SetFont("VIPShopButton")
                siteBtn:SetTextColor(Color(255, 255, 255))
                siteBtn.Paint = function(s, w, h)
                    local btnColor = s:IsHovered() and Color(27, 94, 32, 255) or Color(46, 125, 50, 255)
                    draw.RoundedBox(12, 0, 0, w, h, btnColor)
                    
                    if s:IsHovered() then
                        draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(255, 255, 255, 10))
                    end
                    
                    -- Ok işareti - GÜZELLEŞTİRİLDİ
                    draw.SimpleText(">>", "VIPShopButton", w - 40, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                siteBtn.DoClick = function()
                    surface.PlaySound("UI/buttonclick.wav")
                    gui.OpenURL("https://gmodbaso.network/store/dark-roleplay/")
                end
            end
        end
    end)
end)