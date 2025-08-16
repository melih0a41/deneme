-- fib_sistem/lua/autorun/client/cl_fib_sync_fix.lua
-- Client Senkronizasyon Düzeltmesi - TAMAMEN DÜZELTİLMİŞ

-- Global değişkenler
FIB = FIB or {}
FIB.OnlineAgents = {}
FIB.AllAgents = {}
FIB.Missions = {}

-- ============================================
-- FULL SYNC RECEIVER
-- ============================================
net.Receive("FIB_FullSync", function()
    -- Eski verileri sakla (animasyon için)
    local oldAgents = FIB.OnlineAgents
    
    FIB.OnlineAgents = net.ReadTable()
    FIB.AllAgents = net.ReadTable()
    FIB.Missions = net.ReadTable()
    
    print("[FIB CLIENT] Sync alindi:")
    print("  - Online Ajanlar: " .. #FIB.OnlineAgents)
    print("  - Toplam Ajan: " .. table.Count(FIB.AllAgents))
    print("  - Gorevler: " .. #FIB.Missions)
    
    -- Dashboard varsa güncelle
    if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
    
    -- Departman listesi varsa güncelle
    if IsValid(FIB.DepartmentListView) then
        FIB.RefreshDepartmentList()
    end
    
    -- Aktivite listesine EKLEME - Sadece önemli olayları ekle
    -- "Sistem senkronize edildi" mesajını KALDIRDIK
    
    -- Yeni ajan girişi kontrolü
    for _, newAgent in ipairs(FIB.OnlineAgents) do
        local found = false
        for _, oldAgent in ipairs(oldAgents) do
            if newAgent.steamid == oldAgent.steamid then
                found = true
                break
            end
        end
        if not found and IsValid(FIB.ActivityList) then
            FIB.AddActivity(newAgent.nick .. " sisteme giris yapti", Color(65, 255, 65))
        end
    end
    
    -- Ajan çıkışı kontrolü
    for _, oldAgent in ipairs(oldAgents) do
        local found = false
        for _, newAgent in ipairs(FIB.OnlineAgents) do
            if oldAgent.steamid == newAgent.steamid then
                found = true
                break
            end
        end
        if not found and IsValid(FIB.ActivityList) then
            FIB.AddActivity(oldAgent.nick .. " sistemden ayrildi", Color(255, 200, 0))
        end
    end
    
    -- HUD için global değişken güncelle
    FIB_ActiveAgents = FIB.OnlineAgents
end)

-- ============================================
-- DASHBOARD LİSTESİNİ GÜNCELLE - SMOOTH UPDATE (DÜZELTİLDİ)
-- ============================================
function FIB.RefreshAgentList()
    if not IsValid(FIB.AgentListView) then return end
    
    -- Mevcut listeyi SAKLA
    local existingLines = {}
    local lines = FIB.AgentListView:GetLines()
    
    if lines and #lines > 0 then
        for _, line in ipairs(lines) do
            if IsValid(line) then
                local nick = line:GetColumnText(1)
                existingLines[nick] = {
                    rank = line:GetColumnText(2),
                    status = line:GetColumnText(3),
                    distance = line:GetColumnText(4),
                    line = line,
                    lineID = line:GetID()
                }
            end
        end
    end
    
    -- Yeni ajanları kontrol et ve SADECE değişenleri güncelle
    local processedNicks = {}
    
    for _, agent in ipairs(FIB.OnlineAgents) do
        if IsValid(agent.entity) then
            local distance = math.Round(LocalPlayer():GetPos():Distance(agent.entity:GetPos()))
            local status = agent.undercover and "Gizli" or "Normal"
            local distanceText = distance .. "m"
            
            processedNicks[agent.nick] = true
            
            -- Mevcut satır var mı?
            if existingLines[agent.nick] then
                -- Sadece değişenleri güncelle
                local existingData = existingLines[agent.nick]
                local line = existingData.line
                
                if IsValid(line) then
                    -- Değişiklikleri kontrol et ve güncelle
                    if existingData.rank ~= agent.rank then
                        line:SetColumnText(2, agent.rank)
                    end
                    if existingData.status ~= status then
                        line:SetColumnText(3, status)
                    end
                    if existingData.distance ~= distanceText then
                        line:SetColumnText(4, distanceText)
                    end
                    
                    -- Renkleri güncelle
                    if agent.undercover then
                        for _, col in pairs(line.Columns) do
                            if IsValid(col) then
                                col:SetTextColor(Color(255, 200, 0))
                            end
                        end
                    elseif agent.entity == LocalPlayer() then
                        for _, col in pairs(line.Columns) do
                            if IsValid(col) then
                                col:SetTextColor(Color(65, 255, 65))
                            end
                        end
                    else
                        for _, col in pairs(line.Columns) do
                            if IsValid(col) then
                                col:SetTextColor(Color(255, 255, 255))
                            end
                        end
                    end
                end
            else
                -- Yeni ajan, ekle
                local line = FIB.AgentListView:AddLine(
                    agent.nick,
                    agent.rank,
                    status,
                    distanceText
                )
                
                -- Renkleri ayarla
                if IsValid(line) then
                    if agent.undercover then
                        for _, col in pairs(line.Columns) do
                            if IsValid(col) then
                                col:SetTextColor(Color(255, 200, 0))
                            end
                        end
                    elseif agent.entity == LocalPlayer() then
                        for _, col in pairs(line.Columns) do
                            if IsValid(col) then
                                col:SetTextColor(Color(65, 255, 65))
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Artık online olmayan ajanları kaldır
    for nick, data in pairs(existingLines) do
        if not processedNicks[nick] and IsValid(data.line) then
            FIB.AgentListView:RemoveLine(data.lineID)
        end
    end
    
    -- İstatistikleri güncelle
    if FIB.MainMenuStats then
        FIB.MainMenuStats[1].value = tostring(#FIB.OnlineAgents)
        
        local undercoverCount = 0
        for _, agent in ipairs(FIB.OnlineAgents) do
            if agent.undercover then
                undercoverCount = undercoverCount + 1
            end
        end
        FIB.MainMenuStats[3].value = tostring(undercoverCount)
    end
end

-- ============================================
-- DEPARTMAN LİSTESİNİ GÜNCELLE
-- ============================================
function FIB.RefreshDepartmentList()
    if not IsValid(FIB.DepartmentListView) then return end
    
    FIB.DepartmentListView:Clear()
    
    print("[FIB CLIENT] Departman listesi guncelleniyor: " .. table.Count(FIB.AllAgents) .. " kayitli ajan")
    
    -- Tüm kayıtlı ajanları göster
    for steamid, data in pairs(FIB.AllAgents) do
        -- Online durumunu kontrol et
        local isOnline = false
        local onlineNick = ""
        
        for _, agent in ipairs(FIB.OnlineAgents) do
            if agent.steamid == steamid then
                isOnline = true
                onlineNick = agent.nick
                break
            end
        end
        
        local line = FIB.DepartmentListView:AddLine(
            steamid,
            data.username,
            data.rank,
            isOnline and "Online" or "Offline"
        )
        
        -- Online olanları yeşil yap
        if isOnline and IsValid(line) then
            for _, col in pairs(line.Columns) do
                if IsValid(col) then
                    col:SetTextColor(Color(65, 255, 65))
                end
            end
        end
    end
end

-- ============================================
-- AKTİVİTE LİSTESİNE EKLE - FİLTRELİ
-- ============================================
function FIB.AddActivity(text, color)
    if not IsValid(FIB.ActivityList) then return end
    
    -- Spam mesajları filtrele
    if text == "Sistem senkronize edildi" then
        return -- Bu mesajı ekleme
    end
    
    local actPanel = FIB.ActivityList:Add("DPanel")
    actPanel:SetSize(360, 30)
    actPanel:Dock(TOP)
    actPanel:DockMargin(5, 5, 5, 0)
    actPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 30, 45, 100))
        draw.SimpleText(os.date("%H:%M"), "FIB_Menu_Small", 10, h/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, "FIB_Menu_Small", 60, h/2, color or Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Eski aktiviteleri sil (max 10)
    local children = FIB.ActivityList:GetChildren()
    if #children > 10 then
        children[#children]:Remove()
    end
end

-- ============================================
-- GİRİŞ YAPILDIĞINDA SYNC İSTE
-- ============================================
hook.Add("FIB_LoginSuccess", "RequestSyncOnLogin", function()
    print("[FIB CLIENT] Giris basarili, sync isteniyor...")
    
    timer.Simple(1, function()
        RunConsoleCommand("fib_client_request_sync")
    end)
end)

-- ============================================
-- CLIENT SYNC İSTEĞİ
-- ============================================
concommand.Add("fib_client_request_sync", function()
    if not LocalPlayer().FIBAuthenticated then
        print("[FIB CLIENT] Sync istegi icin giris yapmalisiniz!")
        return
    end
    
    print("[FIB CLIENT] Sync istegi gonderiliyor...")
    net.Start("FIB_RequestSync")
    net.SendToServer()
end)

-- ============================================
-- MENÜ AÇILDIĞINDA SYNC İSTE
-- ============================================
hook.Add("FIB_MenuOpened", "RequestSyncOnMenu", function()
    if LocalPlayer().FIBAuthenticated then
        RunConsoleCommand("fib_client_request_sync")
    end
end)

-- ============================================
-- KICKED RECEIVER - Sistemden atılma kontrolü
-- ============================================
net.Receive("FIB_KickedFromSystem", function()
    print("[FIB CLIENT] Sistemden atildiniz!")
    
    -- Authentication'ı kaldır
    LocalPlayer().FIBAuthenticated = false
    LocalPlayer().FIBRank = nil
    LocalPlayer().FIBUsername = nil
    LocalPlayer().FIBUndercover = false
    
    -- Ana menü açıksa kapat
    if IsValid(FIB.MainMenu) then
        FIB.MainMenu:Close()
    end
    
    -- Mini indicator varsa kapat
    if IsValid(FIB.MiniIndicator) then
        FIB.MiniIndicator:Remove()
        FIB.MiniIndicator = nil
    end
    
    -- Login panelini aç
    timer.Simple(0.5, function()
        if FIB.CreateLoginPanel then
            FIB.CreateLoginPanel()
        else
            -- cl_fib_panel.lua'dan fonksiyonu çağır
            RunConsoleCommand("fib_open_login")
        end
    end)
    
    -- Bildirim
    notification.AddLegacy("FIB: Sistem erisiminiz kaldirildi!", NOTIFY_ERROR, 5)
    surface.PlaySound("buttons/button10.wav")
end)

-- ============================================
-- DEBUG KOMUTU
-- ============================================
concommand.Add("fib_client_debug", function()
    print("[FIB CLIENT] === CLIENT DEBUG ===")
    print("Authenticated: " .. tostring(LocalPlayer().FIBAuthenticated))
    print("Rank: " .. tostring(LocalPlayer().FIBRank))
    print("Online Ajanlar: " .. #FIB.OnlineAgents)
    print("Toplam Kayitli Ajan: " .. table.Count(FIB.AllAgents))
    print("Gorev Sayisi: " .. #FIB.Missions)
    
    print("\nOnline Ajanlar:")
    for i, agent in ipairs(FIB.OnlineAgents) do
        print("  [" .. i .. "] " .. agent.nick .. " - " .. agent.rank)
    end
    
    -- ListView debug
    if IsValid(FIB.AgentListView) then
        print("\nListView Durumu:")
        print("  - Valid: true")
        print("  - Lines: " .. #FIB.AgentListView:GetLines())
    else
        print("\nListView Durumu: INVALID")
    end
end)

print("[FIB CLIENT] Senkronizasyon sistemi yuklendi! (v2.1 - Full Fix)")