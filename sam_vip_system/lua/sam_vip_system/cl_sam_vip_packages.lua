-- SAM VIP Yönetim Sistemi - VIP Paketleri Menüsü
-- lua/sam_vip_system/cl_sam_vip_packages.lua

surface.CreateFont("VIPPackageName", {
    font = "Trebuchet MS",
    extended = false,
    size = 28,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    shadow = true,
    outline = true,
})

-- VIP Paketleri Paneli
net.Receive("SAM_VIP_ShowPackages", function()
    if IsValid(VIP_PACKAGES_PANEL) then
        VIP_PACKAGES_PANEL:Remove()
        return
    end
    
    VIP_PACKAGES_PANEL = vgui.Create("DFrame")
    VIP_PACKAGES_PANEL:SetSize(ScrW() * 0.8, ScrH() * 0.7)
    VIP_PACKAGES_PANEL:Center()
    VIP_PACKAGES_PANEL:SetTitle("")
    VIP_PACKAGES_PANEL:MakePopup()
    VIP_PACKAGES_PANEL:ShowCloseButton(false)
    VIP_PACKAGES_PANEL:SetDraggable(false)
    
    VIP_PACKAGES_PANEL.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(12, 0, 0, w, 60, Color(35, 35, 35, 255), true, true, false, false)
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(0, 60, w, 3)
        draw.SimpleText("VIP PAKETLERİ", "DermaLarge", w/2, 30, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(6, w - 50, 15, 30, 30, Color(220, 53, 69, s.CloseHover and 255 or 200))
        draw.SimpleText("✕", "DermaLarge", w - 35, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
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
    
    local container = vgui.Create("DPanel", VIP_PACKAGES_PANEL)
    container:Dock(FILL)
    container:DockMargin(40, 80, 40, 40)
    container.Paint = function() end
    
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
    
    timer.Simple(0.1, function()
        if not IsValid(container) then return end
        
        local containerWidth = container:GetWide()
        local containerHeight = container:GetTall()
        
        local numPackages = #vipPackages
        local spacing = 20
        local totalSpacing = (numPackages - 1) * spacing
        local cardWidth = (containerWidth - totalSpacing) / numPackages
        local cardHeight = containerHeight - 20
        
        for i, package in ipairs(vipPackages) do
            local card = vgui.Create("DPanel", container)
            card:SetPos((i-1) * (cardWidth + spacing), 10)
            card:SetSize(cardWidth, cardHeight)
            card.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
                draw.RoundedBoxEx(8, 0, 0, w, 80, package.color, true, true, false, false)
                
                -- Paket adı
                draw.SimpleText(package.name, "VIPButtonFont", w/2 + 2, 42, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(package.name, "VIPButtonFont", w/2, 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                if package.name == "Silver VIP" or package.name == "Platinum VIP" or package.name == "Diamond VIP" then
                    for i = -2, 2 do
                        for j = -2, 2 do
                            if i ~= 0 or j ~= 0 then
                                draw.SimpleText(package.name, "VIPButtonFont", w/2 + i, 40 + j, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
                        end
                    end
                    draw.SimpleText(package.name, "VIPButtonFont", w/2, 40, Color(20, 20, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            local imagePanel = vgui.Create("DPanel", card)
            imagePanel:SetPos(10, 90)
            imagePanel:SetSize(cardWidth - 20, cardHeight - 160)
            imagePanel.Paint = function(s, w, h)
                if file.Exists(package.image, "GAME") then
                    if s.IsHovered then
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 20))
                    end
                    return
                end
                
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
                local text = "VIP " .. package.name:upper()
                draw.SimpleText(text, "DermaLarge", w/2, h/2 - 15, Color(package.color.r, package.color.g, package.color.b, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("(Seviye " .. i .. ")", "DermaDefault", w/2, h/2 + 15, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            if file.Exists(package.image, "GAME") then
                local image = vgui.Create("DImage", imagePanel)
                image:Dock(FILL)
                image:SetImage(package.image)
                image:SetKeepAspect(true)
            end
            
            local buyBtn = vgui.Create("DButton", card)
            buyBtn:SetPos(10, cardHeight - 60)
            buyBtn:SetSize(cardWidth - 20, 45)
            buyBtn:SetText("SATIN AL")
            buyBtn:SetFont("VIPButtonFont")
            buyBtn:SetTextColor(Color(255, 255, 255))
            buyBtn.Paint = function(s, w, h)
                local btnColor = s:IsHovered() and package.color or Color(60, 60, 60, 255)
                draw.RoundedBox(8, 0, 0, w, h, btnColor)
                if s:IsHovered() then
                    draw.RoundedBox(8, 0, 0, w, h/2, Color(255, 255, 255, 20))
                end
                draw.RoundedBox(8, 0, h-3, w, 3, Color(0, 0, 0, 50))
            end
            buyBtn.DoClick = function()
                surface.PlaySound("UI/buttonclick.wav")
                
                local infoPanel = vgui.Create("DFrame")
                infoPanel:SetSize(900, 550)
                infoPanel:Center()
                infoPanel:SetTitle("")
                infoPanel:MakePopup()
                infoPanel:ShowCloseButton(false)
                infoPanel:SetDraggable(false)
                
                infoPanel.Paint = function(s, w, h)
                    draw.RoundedBox(16, 0, 0, w, h, Color(20, 20, 20, 250))
                    draw.RoundedBoxEx(16, 0, 0, w, 80, Color(30, 30, 30, 255), true, true, false, false)
                    surface.SetDrawColor(255, 215, 0, 255)
                    surface.DrawRect(0, 80, w, 3)
                    draw.SimpleText("VIP SATIN ALMA", "VIPPackageName", w/2, 40, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(8, w - 60, 20, 40, 40, Color(220, 53, 69, s.CloseHover and 255 or 200))
                    draw.SimpleText("✕", "VIPPackageName", w - 40, 40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    local contentY = 110
                    draw.RoundedBox(12, 50, contentY, w - 100, 80, package.color)
                    
                    draw.SimpleText(package.name, "VIPButtonFont", w/2 + 2, contentY + 27, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(package.name, "VIPButtonFont", w/2, contentY + 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    if package.name == "Silver VIP" or package.name == "Platinum VIP" or package.name == "Diamond VIP" then
                        for i = -2, 2 do
                            for j = -2, 2 do
                                if i ~= 0 or j ~= 0 then
                                    draw.SimpleText(package.name, "VIPButtonFont", w/2 + i, contentY + 25 + j, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                end
                            end
                        end
                        draw.SimpleText(package.name, "VIPButtonFont", w/2, contentY + 25, Color(20, 20, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    draw.SimpleText("Web sitemizden satın alabilirsiniz:", "DermaLarge", w/2, contentY + 120, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    local siteY = contentY + 180
                    draw.RoundedBox(12, 100, siteY, w - 200, 70, Color(46, 125, 50, 255))
                    draw.SimpleText("gmodbaso.network", "VIPPackageName", w/2, siteY + 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
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
                
                local siteBtn = vgui.Create("DButton", infoPanel)
                siteBtn:SetPos(300, 380)
                siteBtn:SetSize(300, 60)
                siteBtn:SetText("MAGAZAYA GIT")
                siteBtn:SetFont("VIPButtonFont")
                siteBtn:SetTextColor(Color(255, 255, 255))
                siteBtn.Paint = function(s, w, h)
                    local btnColor = s:IsHovered() and Color(27, 94, 32, 255) or Color(46, 125, 50, 255)
                    draw.RoundedBox(12, 0, 0, w, h, btnColor)
                    if s:IsHovered() then
                        draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(255, 255, 255, 10))
                    end
                end
                siteBtn.DoClick = function()
                    surface.PlaySound("UI/buttonclick.wav")
                    gui.OpenURL("https://gmodbaso.network/store/dark-roleplay/")
                end
            end
        end
    end)
end)