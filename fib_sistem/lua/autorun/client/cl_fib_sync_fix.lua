-- fib_sistem/lua/autorun/client/cl_fib_sync_fix.lua
-- Client Senkronizasyon Düzeltmesi

-- Global değişkenler
FIB = FIB or {}
FIB.OnlineAgents = {}
FIB.AllAgents = {}
FIB.Missions = {}

-- ============================================
-- FULL SYNC RECEIVER
-- ============================================
net.Receive("FIB_FullSync", function()
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
    
    -- Aktivite listesine ekle
    if IsValid(FIB.ActivityList) then
        FIB.AddActivity("Sistem senkronize edildi", Color(0, 120, 255))
    end
    
    -- HUD için global değişken güncelle
    FIB_ActiveAgents = FIB.OnlineAgents
end)

-- ============================================
-- DASHBOARD LİSTESİNİ GÜNCELLE
-- ============================================
function FIB.RefreshAgentList()
    if not IsValid(FIB.AgentListView) then return end
    
    FIB.AgentListView:Clear()
    
    print("[FIB CLIENT] Ajan listesi guncelleniyor: " .. #FIB.OnlineAgents .. " ajan")
    
    for _, agent in ipairs(FIB.OnlineAgents) do
        if IsValid(agent.entity) then
            local distance = math.Round(LocalPlayer():GetPos():Distance(agent.entity:GetPos()))
            local status = agent.undercover and "Gizli" or "Normal"
            local line = FIB.AgentListView:AddLine(
                agent.nick,
                agent.rank,
                status,
                distance .. "m"
            )
            
            -- Gizli moddakileri sarı yap
            if agent.undercover and IsValid(line) then
                for _, col in pairs(line.Columns) do
                    col:SetTextColor(Color(255, 200, 0))
                end
            end
            
            -- Kendini yeşil yap
            if agent.entity == LocalPlayer() then
                for _, col in pairs(line.Columns) do
                    col:SetTextColor(Color(65, 255, 65))
                end
            end
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
                col:SetTextColor(Color(65, 255, 65))
            end
        end
    end
end

-- ============================================
-- AKTİVİTE LİSTESİNE EKLE
-- ============================================
function FIB.AddActivity(text, color)
    if not IsValid(FIB.ActivityList) then return end
    
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
end)

print("[FIB CLIENT] Senkronizasyon sistemi yuklendi!")