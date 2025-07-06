-- Client-side AFK Demote System
-- Bu dosyayı: garrysmod/addons/afk_demote_system/lua/afk_demote/cl_afk_demote.lua olarak kaydedin

-- Fontlar
surface.CreateFont("AFKDemote_Title", {
    font = "Roboto Bold",
    size = 28,
    weight = 800,
    antialias = true,
    extended = true -- Türkçe karakterler için
})

surface.CreateFont("AFKDemote_Text", {
    font = "Roboto",
    size = 20,
    weight = 500,
    antialias = true,
    extended = true -- Türkçe karakterler için
})

surface.CreateFont("AFKDemote_Timer", {
    font = "Roboto Bold",
    size = 48,
    weight = 900,
    antialias = true
})

surface.CreateFont("AFKDemote_Button", {
    font = "Roboto Medium",
    size = 18,
    weight = 600,
    antialias = true,
    extended = true -- Türkçe karakterler için
})

-- AFK uyarı paneli
local warningPanel = nil
local demoteEndTime = 0
local demoteBy = nil

-- Uyarı panelini göster
net.Receive("AFKDemote.ShowWarning", function()
    demoteBy = net.ReadEntity()
    demoteEndTime = CurTime() + 300 -- 5 dakika
    
    -- Ses efekti
    surface.PlaySound("buttons/button10.wav")
    system.FlashWindow()
    
    -- Eğer panel açıksa kapat
    if IsValid(warningPanel) then
        warningPanel:Remove()
    end
    
    -- Ana panel
    warningPanel = vgui.Create("DFrame")
    warningPanel:SetSize(500, 350)
    warningPanel:Center()
    warningPanel:SetTitle("")
    warningPanel:ShowCloseButton(false)
    warningPanel:SetDraggable(false)
    warningPanel:MakePopup()
    
    -- Panel paint
    warningPanel.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 250))
        
        -- Üst kırmızı bant
        draw.RoundedBoxEx(8, 0, 0, w, 50, Color(200, 0, 0), true, true, false, false)
        
        -- Başlık
        draw.SimpleText("⚠ AFK UYARISI ⚠", "AFKDemote_Title", w/2, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Kalan süre
        local timeLeft = math.max(0, demoteEndTime - CurTime())
        local minutes = math.floor(timeLeft / 60)
        local seconds = math.floor(timeLeft % 60)
        
        -- Timer arka plan
        draw.RoundedBox(8, w/2 - 100, 70, 200, 80, Color(0, 0, 0, 150))
        
        -- Timer
        local timerColor = Color(255, 255, 255)
        if timeLeft < 60 then -- Son 1 dakika kırmızı
            timerColor = Color(255, 100, 100)
        elseif timeLeft < 120 then -- Son 2 dakika sarı
            timerColor = Color(255, 255, 100)
        end
        
        draw.SimpleText(string.format("%02d:%02d", minutes, seconds), "AFKDemote_Timer", w/2, 110, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Uyarı metni - Panel yerine draw kullan
    local warningTexts = {
        "Oyunda AFK olduğunuz tespit edildi!",
        "",
        (IsValid(demoteBy) and demoteBy:Nick() or "Biri") .. " sizi meslekten atmak istiyor.",
        "",
        "Eğer AFK değilseniz aşağıdaki butona tıklayın!"
    }
    
    -- Panel paint fonksiyonunu güncelle
    warningPanel.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 250))
        
        -- Üst kırmızı bant
        draw.RoundedBoxEx(8, 0, 0, w, 50, Color(200, 0, 0), true, true, false, false)
        
        -- Başlık
        draw.SimpleText("⚠ AFK UYARISI ⚠", "AFKDemote_Title", w/2, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Kalan süre
        local timeLeft = math.max(0, demoteEndTime - CurTime())
        local minutes = math.floor(timeLeft / 60)
        local seconds = math.floor(timeLeft % 60)
        
        -- Timer arka plan
        draw.RoundedBox(8, w/2 - 100, 70, 200, 80, Color(0, 0, 0, 150))
        
        -- Timer
        local timerColor = Color(255, 255, 255)
        if timeLeft < 60 then
            timerColor = Color(255, 100, 100)
        elseif timeLeft < 120 then
            timerColor = Color(255, 255, 100)
        end
        
        draw.SimpleText(string.format("%02d:%02d", minutes, seconds), "AFKDemote_Timer", w/2, 110, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Uyarı metni
        local yPos = 170
        for _, text in ipairs(warningTexts) do
            draw.SimpleText(text, "AFKDemote_Text", w/2, yPos, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            yPos = yPos + 25
        end
    end
    
    -- AFK değilim butonu
    local notAFKButton = vgui.Create("DButton", warningPanel)
    notAFKButton:SetSize(200, 40)
    notAFKButton:SetPos(warningPanel:GetWide()/2 - 100, 290)
    notAFKButton:SetText("AFK DEĞİLİM!")
    notAFKButton:SetFont("AFKDemote_Button")
    notAFKButton:SetTextColor(Color(255, 255, 255))
    notAFKButton.Paint = function(self, w, h)
        local col = Color(0, 150, 0)
        if self:IsHovered() then
            col = Color(0, 200, 0)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    notAFKButton.DoClick = function()
        -- Sunucuya AFK olmadığını bildir
        net.Start("AFKDemote.Response")
            net.WriteBool(false) -- AFK değil
        net.SendToServer()
        
        -- Paneli kapat
        if IsValid(warningPanel) then
            warningPanel:Remove()
            warningPanel = nil
        end
        
        -- Ses efekti
        surface.PlaySound("buttons/button15.wav")
    end
    
    -- Panel zamanlayıcısı
    warningPanel.Think = function(self)
        if CurTime() > demoteEndTime then
            self:Remove()
            warningPanel = nil
        end
    end
end)

-- Aktivite kontrolü
net.Receive("AFKDemote.CheckActivity", function()
    -- Eğer panel açıksa ve kullanıcı henüz yanıt vermediyse
    if IsValid(warningPanel) then
        -- Pencere odakta değilse uyarı sesi çal
        if not system.HasFocus() then
            surface.PlaySound("buttons/button10.wav")
            system.FlashWindow()
        end
    end
end)

-- ESC tuşu ile kapatmayı engelle
hook.Add("Think", "AFKDemote.PreventClose", function()
    if IsValid(warningPanel) and gui.IsGameUIVisible() then
        gui.HideGameUI()
    end
end)