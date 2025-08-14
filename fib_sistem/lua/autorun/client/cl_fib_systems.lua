-- fib_sistem/lua/autorun/client/cl_fib_systems.lua

-- FIB HUD için font
surface.CreateFont("FIB_HUD", {
    font = "Roboto",
    size = 14,
    weight = 500,
    antialias = true
})

-- Network receivers
net.Receive("FIB_UpdateUndercover", function()
    local isUndercover = net.ReadBool()
    LocalPlayer().FIBUndercover = isUndercover
    
    if isUndercover then
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(255, 200, 0), "Gizli mod AKTIF")
        
        -- Bildirim
        notification.AddLegacy("FIB: Gizli mod aktif!", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button9.wav")
    else
        chat.AddText(Color(0, 120, 255), "[FIB] ", Color(65, 255, 65), "Normal mod aktif")
        
        notification.AddLegacy("FIB: Normal moda donuldu", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button10.wav")
    end
end)

net.Receive("FIB_ChatMessage", function()
    local sender = net.ReadEntity()
    local message = net.ReadString()
    local rank = net.ReadString()
    local isUndercover = net.ReadBool()
    
    -- Özel chat mesajını göster (zaten server'da chat'e yazılıyor, burada ekstra UI ekleyebiliriz)
    
    -- Bildirim sesi
    surface.PlaySound("buttons/button24.wav")
end)

net.Receive("FIB_MissionUpdate", function()
    local action = net.ReadString()
    local missionData = net.ReadTable()
    
    if action == "new" then
        notification.AddLegacy("FIB: Yeni gorev eklendi - " .. missionData.name, NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button3.wav")
    end
end)

net.Receive("FIB_DepartmentUpdate", function()
    local action = net.ReadString()
    local steamid = net.ReadString()
    
    if action == "add" then
        local username = net.ReadString()
        local rank = net.ReadString()
        
        notification.AddLegacy("FIB: Yeni ajan eklendi", NOTIFY_GENERIC, 5)
    elseif action == "remove" then
        notification.AddLegacy("FIB: Bir ajan sistemden cikarildi", NOTIFY_ERROR, 5)
    end
end)

-- Senkronizasyon
local FIB_ActiveAgents = {}
local FIB_ActiveMissions = {}

net.Receive("FIB_SyncData", function()
    FIB_ActiveAgents = net.ReadTable()
    FIB_ActiveMissions = net.ReadTable()
end)

-- HUD elementi - Gizli moddaki ajanları göster
hook.Add("HUDPaint", "FIB_HUD", function()
    if not LocalPlayer().FIBAuthenticated then return end
    
    -- Gizli mod göstergesi
    if LocalPlayer().FIBUndercover then
        -- Sol üst köşede gizli mod bildirimi
        draw.RoundedBox(8, 10, 10, 200, 30, Color(0, 0, 0, 200))
        draw.SimpleText("GIZLI MOD AKTIF", "FIB_HUD", 110, 25, Color(255, 200, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Yanıp sönen nokta
        local alpha = math.sin(CurTime() * 5) * 100 + 155
        surface.SetDrawColor(255, 200, 0, alpha)
        surface.DrawCircle(25, 25, 5, Color(255, 200, 0, alpha))
    end
    
    -- Diğer gizli ajanların üzerinde işaret
    for _, agent in ipairs(FIB_ActiveAgents) do
        if IsValid(agent.entity) and agent.entity != LocalPlayer() and agent.undercover then
            local pos = agent.entity:GetPos() + Vector(0, 0, 85)
            local screenPos = pos:ToScreen()
            
            if screenPos.visible then
                -- FIB ikonu
                draw.RoundedBox(4, screenPos.x - 20, screenPos.y - 10, 40, 20, Color(0, 0, 0, 150))
                draw.SimpleText("FIB", "FIB_HUD", screenPos.x, screenPos.y, Color(0, 120, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- İsim ve mesafe
                local distance = math.Round(LocalPlayer():GetPos():Distance(agent.entity:GetPos()))
                draw.SimpleText(agent.nick, "FIB_HUD", screenPos.x, screenPos.y + 15, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)
                draw.SimpleText(distance .. "m", "FIB_HUD", screenPos.x, screenPos.y + 30, Color(200, 200, 200, 150), TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- Sağ üstte aktif ajan sayısı
    if #FIB_ActiveAgents > 0 then
        local x = ScrW() - 150
        local y = 10
        
        draw.RoundedBox(8, x - 10, y, 150, 60, Color(0, 0, 0, 200))
        draw.SimpleText("AKTIF AJANLAR", "FIB_HUD", x + 65, y + 15, Color(0, 120, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText(#FIB_ActiveAgents .. " KISI", "FIB_HUD", x + 65, y + 35, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Gizli moddakiler
        local undercoverCount = 0
        for _, agent in ipairs(FIB_ActiveAgents) do
            if agent.undercover then
                undercoverCount = undercoverCount + 1
            end
        end
        
        if undercoverCount > 0 then
            draw.SimpleText(undercoverCount .. " gizli modda", "FIB_HUD", x + 65, y + 50, Color(255, 200, 0, 200), TEXT_ALIGN_CENTER)
        end
    end
end)

-- 3D2D HUD - Gizli ajanlar için halka
hook.Add("PostDrawTranslucentRenderables", "FIB_3D2D", function()
    if not LocalPlayer().FIBAuthenticated then return end
    
    for _, agent in ipairs(FIB_ActiveAgents) do
        if IsValid(agent.entity) and agent.entity != LocalPlayer() and agent.undercover then
            local pos = agent.entity:GetPos()
            local ang = Angle(0, 0, 0)
            
            cam.Start3D2D(pos, ang, 0.1)
                -- Zemin halkası
                surface.SetDrawColor(0, 120, 255, 100)
                draw.NoTexture()
                
                -- Dönen halka efekti
                local segments = 32
                local radius = 300
                local rotation = CurTime() * 50
                
                for i = 1, segments do
                    local angle1 = (i - 1) / segments * math.pi * 2 + math.rad(rotation)
                    local angle2 = i / segments * math.pi * 2 + math.rad(rotation)
                    
                    local x1 = math.cos(angle1) * radius
                    local y1 = math.sin(angle1) * radius
                    local x2 = math.cos(angle2) * radius
                    local y2 = math.sin(angle2) * radius
                    
                    surface.DrawLine(x1, y1, x2, y2)
                end
                
                -- İç halka
                local innerRadius = 250
                surface.SetDrawColor(0, 200, 255, 50)
                
                for i = 1, segments do
                    local angle1 = (i - 1) / segments * math.pi * 2 - math.rad(rotation)
                    local angle2 = i / segments * math.pi * 2 - math.rad(rotation)
                    
                    local x1 = math.cos(angle1) * innerRadius
                    local y1 = math.sin(angle1) * innerRadius
                    local x2 = math.cos(angle2) * innerRadius
                    local y2 = math.sin(angle2) * innerRadius
                    
                    surface.DrawLine(x1, y1, x2, y2)
                end
            cam.End3D2D()
        end
    end
end)

-- Quick access menu (Q tuşu ile)
hook.Add("OnSpawnMenuOpen", "FIB_QuickMenu", function()
    if LocalPlayer().FIBAuthenticated and input.IsKeyDown(KEY_LALT) then
        -- Alt+Q ile FIB menüsü aç
        FIB.CreateMainMenu()
        return false -- Normal spawn menüsünü engelle
    end
end)

-- Hızlı komutlar
concommand.Add("fib_toggle", function()
    if LocalPlayer().FIBAuthenticated then
        RunConsoleCommand("fibgec")
    end
end)

-- Bildirim sistemi
local function FIBNotification(text, type, duration)
    local notif = vgui.Create("DPanel")
    notif:SetSize(300, 60)
    notif:SetPos(ScrW(), 100)
    notif.StartTime = CurTime()
    notif.Duration = duration or 5
    notif.Text = text
    notif.Type = type or NOTIFY_GENERIC
    
    notif.Paint = function(self, w, h)
        local timeLeft = self.Duration - (CurTime() - self.StartTime)
        if timeLeft <= 0 then
            self:Remove()
            return
        end
        
        -- Fade efekti
        local alpha = math.min(255, timeLeft * 255)
        
        -- Arka plan
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, alpha * 0.8))
        
        -- Sol kenarlık
        local barColor = self.Type == NOTIFY_ERROR and Color(255, 0, 0, alpha) or Color(0, 120, 255, alpha)
        surface.SetDrawColor(barColor)
        surface.DrawRect(0, 0, 4, h)
        
        -- Metin
        draw.SimpleText("FIB SISTEM", "FIB_HUD", 10, 15, Color(0, 120, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.Text, "FIB_HUD", 10, 35, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    notif.Think = function(self)
        -- Slide in animasyonu
        if self:GetX() > ScrW() - 310 then
            self:SetX(math.Approach(self:GetX(), ScrW() - 310, FrameTime() * 500))
        end
        
        -- Süre dolunca slide out
        local timeLeft = self.Duration - (CurTime() - self.StartTime)
        if timeLeft < 0.5 then
            self:SetX(math.Approach(self:GetX(), ScrW(), FrameTime() * 500))
        end
    end
end

-- Export fonksiyon
FIB.Notify = FIBNotification