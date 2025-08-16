-- fib_sistem/lua/autorun/client/cl_fib_panel.lua

-- Config'in yüklenmesini bekle
if not FIB or not FIB.Config then
    FIB = FIB or {}
    FIB.Config = FIB.Config or {}
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
    FIB.Config.Texts = {
        title = "FEDERAL ISTIHBARAT BUROSU",
        subtitle = "GUVENLI ERISIM TERMINALI",
        auth_required = "KIMLIK DOGRULAMA GEREKLI",
        agent_id = "AJAN KODU:",
        password = "SIFRE:",
        id_placeholder = "Ajan kodunuzu girin",
        pass_placeholder = "Sifrenizi girin",
        access_system = "SISTEME GIRIS YAP",
        authenticating = "Dogrulaniyor...",
        fill_fields = "! Tum alanlari doldurun",
        access_denied = "Erisim Reddedildi - Yetkisiz",
        invalid_creds = "Gecersiz Kimlik Bilgileri",
        access_granted = "Erisim Onaylandi - Hos Geldin",
        connecting = "Baglaniyor...",
        verifying = "Kimlik kontrol ediliyor...",
        welcome_title = "HOS GELDIN",
        system_ready = "Sistem Hazir",
        main_menu = "Ana Menuye Gec",
        auth_step1 = "Sunucuya baglaniyor...",
        auth_step2 = "Kimlik bilgileri gonderiliyor...",
        auth_step3 = "Veritabani sorgusu yapiliyor...",
        auth_step4 = "Guvenlik protokolleri kontrol ediliyor...",
        auth_step5 = "Yetki seviyesi belirleniyor...",
        auth_success = "Kimlik dogrulandi!",
        auth_fail = "Kimlik dogrulama basarisiz!",
        system_init = "FIB Sistemi baslatiliyor...",
        system_secure = "Guvenli baglanti kuruldu",
        system_encrypt = "256-bit sifreleme aktif",
        database_connect = "FIB veritabanina baglaniyor...",
        database_query = "Kullanici bilgileri sorgulaniyor..."
    }
end

-- Smooth animasyon için
local mathApproach = math.Approach
local mathSin = math.sin
local curTime = CurTime

-- Font oluştur
surface.CreateFont("FIB_Title", {
    font = "Roboto",
    size = 32,
    weight = 600,
    antialias = true,
    extended = false
})

surface.CreateFont("FIB_Subtitle", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true
})

surface.CreateFont("FIB_Bold", {
    font = "Roboto",
    size = 18,
    weight = 600,
    antialias = true
})

surface.CreateFont("FIB_Normal", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true
})

surface.CreateFont("FIB_Button", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont("FIB_Welcome", {
    font = "Roboto",
    size = 48,
    weight = 700,
    antialias = true
})

surface.CreateFont("FIB_Status", {
    font = "Consolas",
    size = 14,
    weight = 400,
    antialias = true
})

-- Animasyonlu durum mesajları
local authSteps = {
    {text = FIB.Config.Texts.auth_step1, duration = 0.8, color = "accent"},
    {text = FIB.Config.Texts.auth_step2, duration = 0.6, color = "accent"},
    {text = FIB.Config.Texts.auth_step3, duration = 1.2, color = "warning"},
    {text = FIB.Config.Texts.auth_step4, duration = 0.9, color = "warning"},
    {text = FIB.Config.Texts.auth_step5, duration = 0.7, color = "accent"}
}

-- Global scope'a taşıyoruz
FIB.CreateWelcomeScreen = function(rank, username)
    -- Ana panel
    local welcomeFrame = vgui.Create("DFrame")
    welcomeFrame:SetSize(ScrW(), ScrH())
    welcomeFrame:SetPos(0, 0)
    welcomeFrame:SetTitle("")
    welcomeFrame:SetDraggable(false)
    welcomeFrame:ShowCloseButton(false)
    welcomeFrame:MakePopup()
    welcomeFrame:SetAlpha(0)
    welcomeFrame:AlphaTo(255, 0.5, 0)
    
    local startTime = CurTime()
    local particles = {}
    
    -- Parçacık efekti oluştur
    for i = 1, 30 do
        particles[i] = {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            size = math.random(2, 5),
            speed = math.random(20, 50),
            alpha = math.random(50, 150)
        }
    end
    
    welcomeFrame.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(0, 0, 0, w, h, Color(2, 15, 35, 250))
        
        -- Animasyonlu gradient
        local alpha = math.sin(CurTime() * 2) * 50 + 50
        surface.SetDrawColor(0, 120, 255, alpha)
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, 0, w, h/2)
        
        -- Parçacık efekti
        for i, p in ipairs(particles) do
            p.y = p.y - (p.speed * FrameTime())
            if p.y < -10 then
                p.y = h + 10
                p.x = math.random(0, w)
            end
            
            local pAlpha = math.sin(CurTime() * 3 + i) * 50 + p.alpha
            surface.SetDrawColor(0, 120, 255, pAlpha)
            surface.DrawRect(p.x, p.y, p.size, p.size)
        end
        
        -- Logo (eğer varsa)
        local logoMat = Material("fib/logo.png", "smooth")
        if not logoMat:IsError() then
            surface.SetMaterial(logoMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(w/2 - 100, h/2 - 300, 200, 200)
        end
        
        -- Hoşgeldin metni - animasyonlu
        local textAlpha = math.min(255, (CurTime() - startTime) * 200)
        draw.SimpleText(FIB.Config.Texts.welcome_title, "FIB_Welcome", w/2, h/2 - 50, ColorAlpha(FIB.Config.Colors.accent, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if (CurTime() - startTime) > 0.5 then
            draw.SimpleText(rank .. " " .. LocalPlayer():Nick(), "FIB_Title", w/2, h/2, ColorAlpha(FIB.Config.Colors.text, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        if (CurTime() - startTime) > 1 then
            draw.SimpleText("Kullanici: " .. username, "FIB_Subtitle", w/2, h/2 + 35, ColorAlpha(FIB.Config.Colors.text_dim, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Sistem hazır metni
        if (CurTime() - startTime) > 1.5 then
            local readyAlpha = math.sin(CurTime() * 3) * 100 + 155
            draw.SimpleText(FIB.Config.Texts.system_ready, "FIB_Bold", w/2, h/2 + 80, Color(65, 255, 65, readyAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Sistem bilgileri
        if (CurTime() - startTime) > 2 then
            local infoAlpha = math.min(100, ((CurTime() - startTime) - 2) * 100)
            draw.SimpleText(FIB.Config.Texts.system_secure, "FIB_Status", w/2, h - 100, ColorAlpha(FIB.Config.Colors.success, infoAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(FIB.Config.Texts.system_encrypt, "FIB_Status", w/2, h - 80, ColorAlpha(FIB.Config.Colors.accent, infoAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Grid efekti
        surface.SetDrawColor(0, 100, 200, 5)
        for i = 0, w, 50 do
            surface.DrawLine(i, 0, i, h)
        end
        for i = 0, h, 50 do
            surface.DrawLine(0, i, w, i)
        end
    end
    
    -- Ana menü butonu
    local menuBtn = vgui.Create("DButton", welcomeFrame)
    menuBtn:SetSize(300, 50)
    menuBtn:SetPos(ScrW()/2 - 150, ScrH()/2 + 150)
    menuBtn:SetText(FIB.Config.Texts.main_menu)
    menuBtn:SetTextColor(FIB.Config.Colors.text)
    menuBtn:SetFont("FIB_Button")
    menuBtn:SetAlpha(0)
    menuBtn.HoverAnim = 0
    menuBtn.Paint = function(self, w, h)
        self.HoverAnim = mathApproach(self.HoverAnim, self:IsHovered() and 1 or 0, FrameTime() * 5)
        
        local bgCol = Color(
            FIB.Config.Colors.accent.r + (30 * self.HoverAnim),
            FIB.Config.Colors.accent.g + (30 * self.HoverAnim),
            FIB.Config.Colors.accent.b,
            255
        )
        
        draw.RoundedBox(6, 0, 0, w, h, bgCol)
        
        if self.HoverAnim > 0 then
            surface.SetDrawColor(255, 255, 255, 10 * self.HoverAnim)
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 10 * self.HoverAnim))
        end
        
        -- Kenarlık efekti
        if self:IsHovered() then
            surface.SetDrawColor(255, 255, 255, 50 * self.HoverAnim)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
    end
    menuBtn.DoClick = function()
        welcomeFrame:AlphaTo(0, 0.3, 0, function()
            welcomeFrame:Close()
            -- Ana FIB menüsünü aç
            FIB.CreateMainMenu()
            chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 255, 255), "Ana menu acildi. !fib yazarak menu kontrolu yapabilirsiniz.")
        end)
    end
    
    -- Buton animasyonu
    timer.Simple(2.5, function()
        if IsValid(menuBtn) then
            menuBtn:AlphaTo(255, 0.5, 0)
        end
    end)
end

local function CreateFIBLoginPanel()
    -- Eski panelleri temizle
    if FIB.LoginPanel and IsValid(FIB.LoginPanel.frame) then
        FIB.LoginPanel.frame:Remove()
    end
    if IsValid(FIB.LoginFrame) then
        FIB.LoginFrame:Remove()
    end
    
    -- Ana menü açıksa uyarı ver
    if IsValid(FIB.MainMenu) then
        chat.AddText(Color(255, 200, 0), "[FIB] ", Color(255, 255, 255), "Zaten sisteme giris yapilmis durumda!")
        FIB.MainMenu:SetVisible(true)
        if IsValid(FIB.MiniIndicator) then
            FIB.MiniIndicator:Remove()
            FIB.MiniIndicator = nil
        end
        return
    end
    
    FIB.LoginPanel = nil
    FIB.LoginFrame = nil
    
    -- Ana Panel
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.3, 0)
    
    FIB.LoginFrame = frame
    
    -- Logo material'i
    local logoMat = Material("fib/logo.png", "smooth")
    local scanlineAlpha = 0
    
    -- Arka plan
    frame.Paint = function(self, w, h)
        -- Dış çerçeve
        draw.RoundedBox(12, 0, 0, w, h, Color(0, 0, 0, 250))
        
        -- İç ekran - Çok koyu mavi
        draw.RoundedBox(8, 10, 10, w-20, h-20, FIB.Config.Colors.background)
        
        -- Üst bar
        draw.RoundedBox(8, 10, 10, w-20, 70, FIB.Config.Colors.secondary)
        
        -- Gradient overlay
        surface.SetDrawColor(0, 50, 100, 50)
        surface.SetMaterial(Material("gui/gradient_up"))
        surface.DrawTexturedRect(10, 10, w-20, 200)
        
        -- FIB Başlığı
        draw.SimpleText(FIB.Config.Texts.title, "FIB_Title", w/2, 35, FIB.Config.Colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(FIB.Config.Texts.subtitle, "FIB_Subtitle", w/2, 55, FIB.Config.Colors.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Animasyonlu alt çizgi
        local lineWidth = 400 + mathSin(curTime() * 2) * 50
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawRect(w/2 - lineWidth/2, 75, lineWidth, 2)
        
        -- Glow efekti
        surface.SetDrawColor(FIB.Config.Colors.glow)
        surface.DrawRect(w/2 - lineWidth/2 - 20, 75, lineWidth + 40, 2)
        
        -- Scanline efekti
        scanlineAlpha = mathSin(curTime() * 3) * 30 + 30
        surface.SetDrawColor(255, 255, 255, scanlineAlpha)
        for i = 80, h - 10, 4 do
            surface.DrawLine(10, i, w-10, i)
        end
        
        -- Grid pattern
        surface.SetDrawColor(0, 100, 200, 10)
        for i = 0, w, 40 do
            surface.DrawLine(i, 80, i, h)
        end
        for i = 80, h, 40 do
            surface.DrawLine(10, i, w-10, i)
        end
    end
    
    -- Kapatma butonu (X)
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(35, 35)
    closeBtn:SetPos(frame:GetWide() - 50, 17)
    closeBtn:SetText("")
    closeBtn.HoverAnim = 0
    closeBtn.Paint = function(self, w, h)
        self.HoverAnim = mathApproach(self.HoverAnim, self:IsHovered() and 1 or 0, FrameTime() * 5)
        
        local bgCol = Color(
            255 * self.HoverAnim,
            50,
            50,
            100 + (100 * self.HoverAnim)
        )
        
        draw.RoundedBox(6, 0, 0, w, h, bgCol)
        
        -- X işareti
        surface.SetDrawColor(255, 255, 255, 200 + (55 * self.HoverAnim))
        surface.DrawLine(10, 10, w-10, h-10)
        surface.DrawLine(w-10, 10, 10, h-10)
    end
    closeBtn.DoClick = function()
        frame:AlphaTo(0, 0.2, 0, function()
            frame:Close()
        end)
    end
    
    -- Logo Panel
    local logoPanel = vgui.Create("DPanel", frame)
    logoPanel:SetSize(220, 220)
    logoPanel:SetPos(frame:GetWide()/2 - 110, frame:GetTall()/2 - 260)
    logoPanel.Rotation = 0
    logoPanel.Paint = function(self, w, h)
        -- Logo
        if not logoMat:IsError() then
            surface.SetMaterial(logoMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(10, 10, w-20, h-20)
        end
    end
    
    -- Login Container
    local loginContainer = vgui.Create("DPanel", frame)
    loginContainer:SetSize(450, 380)
    loginContainer:SetPos(frame:GetWide()/2 - 225, frame:GetTall()/2 - 30)
    loginContainer.Paint = function(self, w, h)
        -- Arka plan
        draw.RoundedBox(12, 0, 0, w, h, FIB.Config.Colors.panel_bg)
        
        -- Kenarlık
        surface.SetDrawColor(FIB.Config.Colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- İç glow
        surface.SetDrawColor(FIB.Config.Colors.glow)
        surface.DrawOutlinedRect(2, 2, w-4, h-4, 1)
        
        -- Başlık
        draw.SimpleText(FIB.Config.Texts.auth_required, "FIB_Bold", w/2, 30, FIB.Config.Colors.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Alt çizgi
        surface.SetDrawColor(FIB.Config.Colors.accent)
        surface.DrawLine(30, 50, w-30, 50)
    end
    
    -- ID Label
    local idLabel = vgui.Create("DLabel", loginContainer)
    idLabel:SetPos(50, 80)
    idLabel:SetSize(350, 25)
    idLabel:SetText(FIB.Config.Texts.agent_id)
    idLabel:SetTextColor(FIB.Config.Colors.text)
    idLabel:SetFont("FIB_Bold")
    
    -- ID TextEntry
    local idEntry = vgui.Create("DTextEntry", loginContainer)
    idEntry:SetPos(50, 110)
    idEntry:SetSize(350, 40)
    idEntry:SetPlaceholderText(FIB.Config.Texts.id_placeholder)
    idEntry:SetFont("FIB_Normal")
    idEntry:SetTextColor(FIB.Config.Colors.text)
    idEntry.HoverAnim = 0
    idEntry.Paint = function(self, w, h)
        self.HoverAnim = mathApproach(self.HoverAnim, (self:IsHovered() or self:IsEditing()) and 1 or 0, FrameTime() * 5)
        
        -- Arka plan
        draw.RoundedBox(6, 0, 0, w, h, Color(5, 5, 15, 200))
        
        -- Hover/Focus efekti
        if self.HoverAnim > 0 then
            surface.SetDrawColor(FIB.Config.Colors.accent.r, FIB.Config.Colors.accent.g, FIB.Config.Colors.accent.b, 100 * self.HoverAnim)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        
        -- Sol kenarlık
        if self:IsEditing() then
            surface.SetDrawColor(FIB.Config.Colors.accent)
            surface.DrawRect(0, 0, 3, h)
        end
        
        self:DrawTextEntryText(FIB.Config.Colors.text, FIB.Config.Colors.accent, FIB.Config.Colors.text)
    end
    
    -- Password Label
    local passLabel = vgui.Create("DLabel", loginContainer)
    passLabel:SetPos(50, 165)
    passLabel:SetSize(350, 25)
    passLabel:SetText(FIB.Config.Texts.password)
    passLabel:SetTextColor(FIB.Config.Colors.text)
    passLabel:SetFont("FIB_Bold")
    
    -- Password TextEntry
    local passEntry = vgui.Create("DTextEntry", loginContainer)
    passEntry:SetPos(50, 195)
    passEntry:SetSize(350, 40)
    passEntry:SetPlaceholderText(FIB.Config.Texts.pass_placeholder)
    passEntry:SetFont("FIB_Normal")
    passEntry:SetTextColor(FIB.Config.Colors.text)
    passEntry.HoverAnim = 0
    passEntry.Paint = function(self, w, h)
        self.HoverAnim = mathApproach(self.HoverAnim, (self:IsHovered() or self:IsEditing()) and 1 or 0, FrameTime() * 5)
        
        -- Arka plan
        draw.RoundedBox(6, 0, 0, w, h, Color(5, 5, 15, 200))
        
        -- Hover/Focus efekti
        if self.HoverAnim > 0 then
            surface.SetDrawColor(FIB.Config.Colors.accent.r, FIB.Config.Colors.accent.g, FIB.Config.Colors.accent.b, 100 * self.HoverAnim)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        
        -- Sol kenarlık
        if self:IsEditing() then
            surface.SetDrawColor(FIB.Config.Colors.accent)
            surface.DrawRect(0, 0, 3, h)
        end
        
        -- Şifre gizleme
        local text = self:GetText()
        if #text > 0 and not self:IsEditing() then
            draw.SimpleText(string.rep("•", #text), "FIB_Normal", 10, h/2, FIB.Config.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            self:DrawTextEntryText(FIB.Config.Colors.text, FIB.Config.Colors.accent, FIB.Config.Colors.text)
        end
    end
    
    -- Error/Status Label
    local errorLabel = vgui.Create("DLabel", loginContainer)
    errorLabel:SetPos(50, 245)
    errorLabel:SetSize(350, 25)
    errorLabel:SetText("")
    errorLabel:SetTextColor(FIB.Config.Colors.error)
    errorLabel:SetFont("FIB_Status")
    
    -- Status icon
    local statusIcon = vgui.Create("DPanel", loginContainer)
    statusIcon:SetPos(25, 245)
    statusIcon:SetSize(20, 20)
    statusIcon:SetVisible(false)
    statusIcon.rotation = 0
    statusIcon.Paint = function(self, w, h)
        self.rotation = self.rotation + FrameTime() * 200
        
        -- Dönen loading icon
        surface.SetDrawColor(FIB.Config.Colors.accent)
        draw.NoTexture()
        
        local cx, cy = w/2, h/2
        for i = 0, 7 do
            local angle = (i * 45 + self.rotation) * math.pi / 180
            local x = cx + math.cos(angle) * 6
            local y = cy + math.sin(angle) * 6
            local alpha = 255 - (i * 30)
            surface.SetDrawColor(FIB.Config.Colors.accent.r, FIB.Config.Colors.accent.g, FIB.Config.Colors.accent.b, alpha)
            surface.DrawRect(x - 1, y - 1, 2, 2)
        end
    end
    
    -- Login Button
    local loginBtn = vgui.Create("DButton", loginContainer)
    loginBtn:SetPos(50, 290)
    loginBtn:SetSize(350, 45)
    loginBtn:SetText(FIB.Config.Texts.access_system)
    loginBtn:SetTextColor(FIB.Config.Colors.text)
    loginBtn:SetFont("FIB_Button")
    loginBtn.HoverAnim = 0
    loginBtn.ClickAnim = 0
    loginBtn.Paint = function(self, w, h)
        self.HoverAnim = mathApproach(self.HoverAnim, self:IsHovered() and 1 or 0, FrameTime() * 5)
        self.ClickAnim = mathApproach(self.ClickAnim, 0, FrameTime() * 5)
        
        -- Arka plan rengi
        local bgCol = Color(
            FIB.Config.Colors.accent.r + (30 * self.HoverAnim),
            FIB.Config.Colors.accent.g + (30 * self.HoverAnim),
            FIB.Config.Colors.accent.b,
            255
        )
        
        draw.RoundedBox(6, 0, 0, w, h, bgCol)
        
        -- Hover glow
        if self.HoverAnim > 0 then
            surface.SetDrawColor(255, 255, 255, 10 * self.HoverAnim)
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 10 * self.HoverAnim))
        end
        
        -- Click efekti
        if self.ClickAnim > 0 then
            surface.SetDrawColor(255, 255, 255, 50 * self.ClickAnim)
            draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 50 * self.ClickAnim))
        end
    end
    
    -- Animasyonlu login işlemi
    local function AnimatedLogin(username, password)
        statusIcon:SetVisible(true)
        loginBtn:SetEnabled(false)
        
        local stepIndex = 1
        local function ShowNextStep()
            if stepIndex <= #authSteps then
                local step = authSteps[stepIndex]
                errorLabel:SetText(step.text)
                errorLabel:SetTextColor(FIB.Config.Colors[step.color])
                
                timer.Simple(step.duration, function()
                    stepIndex = stepIndex + 1
                    ShowNextStep()
                end)
            else
                -- Son adım - server'a gönder
                errorLabel:SetText(FIB.Config.Texts.verifying)
                errorLabel:SetTextColor(FIB.Config.Colors.accent)
                
                net.Start("FIB_AttemptLogin")
                net.WriteString(username)
                net.WriteString(password)
                net.SendToServer()
            end
        end
        
        ShowNextStep()
    end
    
    loginBtn.DoClick = function()
        loginBtn.ClickAnim = 1
        
        local username = idEntry:GetValue()
        local password = passEntry:GetValue()
        
        if username == "" or password == "" then
            errorLabel:SetText(FIB.Config.Texts.fill_fields)
            errorLabel:SetTextColor(FIB.Config.Colors.error)
            return
        end
        
        -- Animasyonlu login başlat
        AnimatedLogin(username, password)
        
        print("[FIB CLIENT] Login gonderiliyor: " .. username)
        
        -- Timeout - 10 saniye
        timer.Create("FIB_LoginTimeout", 10, 1, function()
            if IsValid(errorLabel) then
                errorLabel:SetText("✗ Sunucu yanit vermiyor!")
                errorLabel:SetTextColor(FIB.Config.Colors.error)
                statusIcon:SetVisible(false)
                loginBtn:SetEnabled(true)
                print("[FIB CLIENT] Login timeout!")
            end
        end)
    end
    
    -- Enter tuşu desteği
    idEntry.OnEnter = function()
        passEntry:RequestFocus()
    end
    
    passEntry.OnEnter = function()
        loginBtn:DoClick()
    end
    
    -- Global erişim için sakla - HER İKİSİNİ DE AYRI SAKLA
    FIB.LoginPanel = {
        frame = frame,
        errorLabel = errorLabel
    }
    FIB.LoginFrame = frame  -- Direkt frame referansı
    FIB.LoginErrorLabel = errorLabel  -- Direkt errorLabel referansı
    FIB.LoginStatusIcon = statusIcon  -- Status icon referansı
    FIB.LoginButton = loginBtn  -- Buton referansı
end

-- Server'dan gelen cevap - EN BASİT HALİ
net.Receive("FIB_LoginResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    local rank = success and net.ReadString() or ""
    local username = success and net.ReadString() or ""
    
    print("[FIB CLIENT] Login yaniti alindi: " .. tostring(success) .. " - " .. message)
    print("[FIB CLIENT] Rank: " .. rank .. " | Username: " .. username)
    
    -- Timeout timer'ını temizle
    timer.Remove("FIB_LoginTimeout")
    
    -- Status icon'u gizle
    if IsValid(FIB.LoginStatusIcon) then
        FIB.LoginStatusIcon:SetVisible(false)
    end
    
    -- Butonu tekrar aktif et
    if IsValid(FIB.LoginButton) then
        FIB.LoginButton:SetEnabled(true)
    end
    
    if success then
        -- Başarılı mesajı göster
        if IsValid(FIB.LoginErrorLabel) then
            FIB.LoginErrorLabel:SetText("✓ " .. FIB.Config.Texts.auth_success)
            FIB.LoginErrorLabel:SetTextColor(FIB.Config.Colors.success)
        end
        
        -- Authentication flag'ini set et
        LocalPlayer().FIBAuthenticated = true
        LocalPlayer().FIBRank = rank
        LocalPlayer().FIBUsername = username
        
        -- Hook'u tetikle (sync için) - YENİ!
        hook.Run("FIB_LoginSuccess")
        
        -- Chat'e mesaj
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "✓ ", Color(255, 255, 255), message)
        
        -- 1 saniye bekle sonra kapat
        timer.Simple(1, function()
            if IsValid(FIB.LoginFrame) then
                FIB.LoginFrame:AlphaTo(0, 0.3, 0, function()
                    FIB.LoginFrame:Close()
                    -- Hoşgeldin ekranını aç
                    FIB.CreateWelcomeScreen(rank, username)
                end)
            end
        end)
    else
        -- Hata mesajını göster
        if IsValid(FIB.LoginErrorLabel) then
            FIB.LoginErrorLabel:SetText("✗ " .. message)
            FIB.LoginErrorLabel:SetTextColor(FIB.Config.Colors.error)
        else
            chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 65, 65), "✗ ", Color(255, 255, 255), message)
        end
    end
end)

-- Chat komutu
hook.Add("OnPlayerChat", "FIB_OpenPanel", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!fib" then
        -- Eğer zaten giriş yapmışsa
        if LocalPlayer().FIBAuthenticated then
            -- Ana menü açıksa kapat, kapalıysa aç
            if IsValid(FIB.MainMenu) then
                if FIB.MainMenu:IsVisible() then
                    -- Görünürse kapat
                    FIB.MainMenu:Close()
                else
                    -- Minimize edilmişse görünür yap
                    FIB.MainMenu:SetVisible(true)
                    -- Mini indicator varsa kaldır
                    if IsValid(FIB.MiniIndicator) then
                        FIB.MiniIndicator:Remove()
                        FIB.MiniIndicator = nil
                    end
                end
            else
                -- Menü yoksa oluştur
                FIB.CreateMainMenu()
            end
        else
            -- Giriş yapmamışsa login paneli aç
            CreateFIBLoginPanel()
        end
        return true
    end
end)

-- Debug komutları
concommand.Add("fib_debug", function()
    print("[FIB] === DEBUG ===")
    print("LoginPanel tablosu var mi?", FIB.LoginPanel ~= nil)
    if FIB.LoginPanel then
        print("  - frame valid mi?", IsValid(FIB.LoginPanel.frame))
        print("  - errorLabel valid mi?", IsValid(FIB.LoginPanel.errorLabel))
    end
    print("LoginFrame direkt var mi?", IsValid(FIB.LoginFrame))
    print("LoginErrorLabel direkt var mi?", IsValid(FIB.LoginErrorLabel))
    print("MainMenu var mi?", IsValid(FIB.MainMenu))
    print("MiniIndicator var mi?", IsValid(FIB.MiniIndicator))
    print("Authenticated mi?", LocalPlayer().FIBAuthenticated)
    print("FIB Rank:", LocalPlayer().FIBRank)
    print("Config yuklu mu?", FIB.Config ~= nil)
    print("CreateWelcomeScreen fonksiyonu var mi?", FIB.CreateWelcomeScreen ~= nil)
    print("CreateMainMenu fonksiyonu var mi?", FIB.CreateMainMenu ~= nil)
end)

-- Login panelini açma komutu (kicked durumu için)
concommand.Add("fib_open_login", function()
    CreateFIBLoginPanel()
end)

-- Global fonksiyon olarak da tanımla
FIB.CreateLoginPanel = CreateFIBLoginPanel