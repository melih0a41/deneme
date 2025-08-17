-- fib_sistem/lua/autorun/client/cl_fib_sync_fix.lua
-- Client Senkronizasyon Düzeltmesi - STABLE VERSION

-- Global değişkenler
FIB = FIB or {}
FIB.OnlineAgents = {}
FIB.AllAgents = {}
FIB.Missions = {}

-- Global for HUD
FIB_ActiveAgents = {}

-- Cache sistemi
local agentCache = {}
local lastFullSync = 0

-- ============================================
-- STEAMID'DEN OYUNCU BULMA
-- ============================================
local function GetPlayerBySteamID(steamid)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID() == steamid then
            return ply
        end
    end
    return false -- nil yerine false dön
end

-- ============================================
-- AJAN LİSTESİNİ GÜNCELLE (MERGE)
-- ============================================
local function MergeAgentList(newAgents)
    local mergedList = {}
    local processedSteamIDs = {}
    
    -- Yeni ajanları ekle
    for _, agentData in ipairs(newAgents) do
        local ply = GetPlayerBySteamID(agentData.steamid)
        
        -- Her durumda ekle (entity olsun veya olmasın)
        local agent = {
            entity = ply or nil,
            steamid = agentData.steamid,
            nick = agentData.nick,
            rank = agentData.rank,
            username = agentData.username,
            undercover = agentData.undercover,
            loginTime = agentData.loginTime
        }
        
        -- Entity varsa nick'i güncelle
        if IsValid(ply) then
            agent.nick = ply:Nick()
        end
        
        table.insert(mergedList, agent)
        processedSteamIDs[agentData.steamid] = true
        
        -- Cache'e ekle
        agentCache[agentData.steamid] = agent
    end
    
    return mergedList
end

-- ============================================
-- FULL SYNC RECEIVER - STABLE
-- ============================================
net.Receive("FIB_FullSync", function()
    local serverAgents = net.ReadTable()
    FIB.AllAgents = net.ReadTable()
    FIB.Missions = net.ReadTable()
    
    -- Debug
    print("[FIB CLIENT] Full Sync alindi: " .. #serverAgents .. " ajan")
    
    -- Boş liste kontrolü
    if #serverAgents == 0 and #FIB.OnlineAgents > 0 then
        print("[FIB CLIENT] UYARI: Bos liste geldi, mevcut liste korunuyor!")
        return -- Boş liste geldiyse mevcut listeyi koru
    end
    
    -- Listeyi merge et (sıfırlama yerine)
    local mergedAgents = MergeAgentList(serverAgents)
    
    -- Sadece gerçekten değişiklik varsa güncelle
    if #mergedAgents > 0 then
        FIB.OnlineAgents = mergedAgents
        FIB_ActiveAgents = mergedAgents
        lastFullSync = CurTime()
        
        -- Dashboard varsa güncelle
        if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
            FIB.RefreshAgentList()
        end
        
        -- Departman listesi varsa güncelle
        if IsValid(FIB.DepartmentListView) then
            FIB.RefreshDepartmentList()
        end
    end
end)

-- ============================================
-- QUICK SYNC RECEIVER - STABLE
-- ============================================
net.Receive("FIB_QuickSync", function()
    local serverAgents = net.ReadTable()
    
    -- Boş liste kontrolü
    if #serverAgents == 0 and #FIB.OnlineAgents > 0 then
        print("[FIB CLIENT] UYARI: Quick sync'de bos liste, skip ediliyor!")
        return
    end
    
    print("[FIB CLIENT] Quick Sync alindi: " .. #serverAgents .. " ajan")
    
    -- Listeyi merge et
    local mergedAgents = MergeAgentList(serverAgents)
    
    if #mergedAgents > 0 then
        FIB.OnlineAgents = mergedAgents
        FIB_ActiveAgents = mergedAgents
        
        -- Dashboard varsa güncelle
        if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
            FIB.RefreshAgentList()
        end
    end
end)

-- ============================================
-- AJAN AYRILDI
-- ============================================
net.Receive("FIB_AgentLeft", function()
    local steamid = net.ReadString()
    local nick = net.ReadString()
    
    print("[FIB CLIENT] Ajan ayrildi: " .. nick)
    
    -- Listeden çıkar
    local newList = {}
    for _, agent in ipairs(FIB.OnlineAgents) do
        if agent.steamid ~= steamid then
            table.insert(newList, agent)
        end
    end
    
    FIB.OnlineAgents = newList
    FIB_ActiveAgents = newList
    
    -- Cache'den sil
    agentCache[steamid] = nil
    
    -- Aktivite ekle
    if IsValid(FIB.ActivityList) then
        FIB.AddActivity(nick .. " sistemden ayrildi", Color(255, 200, 0))
    end
    
    -- Dashboard güncelle
    if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
end)

-- ============================================
-- DASHBOARD LİSTESİNİ GÜNCELLE - STABLE
-- ============================================
function FIB.RefreshAgentList()
    if not IsValid(FIB.AgentListView) then return end
    
    -- Listeyi temizle
    FIB.AgentListView:Clear()
    
    -- Debug
    print("[FIB CLIENT] Dashboard guncelleniyor: " .. #FIB.OnlineAgents .. " ajan")
    
    local addedCount = 0
    local skippedCount = 0
    
    for i, agent in ipairs(FIB.OnlineAgents) do
        print("[FIB CLIENT] Ajan " .. i .. ": " .. agent.nick .. " (" .. agent.steamid .. ") isleniyor...")
        
        local ply = GetPlayerBySteamID(agent.steamid)
        
        -- Her durumda ekle (entity olsun veya olmasın)
        local nick = agent.nick
        local distance = "---"
        local isValidEntity = false
        
        if IsValid(ply) then
            -- Entity var
            nick = ply:Nick()
            distance = math.Round(LocalPlayer():GetPos():Distance(ply:GetPos())) .. "m"
            isValidEntity = true
            print("  - Entity bulundu: " .. nick)
        else
            print("  - Entity bulunamadi, cache kullaniliyor: " .. nick)
        end
        
        local status = agent.undercover and "Gizli" or "Normal"
        
        -- Listeye ekle
        local line = FIB.AgentListView:AddLine(
            nick,
            agent.rank,
            status,
            distance
        )
        
        if IsValid(line) then
            addedCount = addedCount + 1
            print("  - Listeye eklendi")
            
            -- Renkleri ayarla
            if not isValidEntity then
                -- Entity bulunamadı - gri
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(150, 150, 150))
                    end
                end
            elseif agent.undercover then
                -- Gizli modda - sarı
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(255, 200, 0))
                    end
                end
            elseif IsValid(ply) and ply == LocalPlayer() then
                -- Kendimiz - yeşil
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(65, 255, 65))
                    end
                end
            else
                -- Normal - beyaz
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(255, 255, 255))
                    end
                end
            end
        else
            skippedCount = skippedCount + 1
            print("  - HATA: AddLine basarisiz!")
        end
    end
    
    print("[FIB CLIENT] ListView'a " .. addedCount .. " satir eklendi, " .. skippedCount .. " atlandı")
    
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
    
    -- Debug: ListView kontrolü
    timer.Simple(0.1, function()
        if IsValid(FIB.AgentListView) then
            local lineCount = #FIB.AgentListView:GetLines()
            if lineCount ~= #FIB.OnlineAgents then
                print("[FIB CLIENT] UYARI: ListView satir sayisi eslesmiiyor!")
                print("  - Beklenen: " .. #FIB.OnlineAgents)
                print("  - Mevcut: " .. lineCount)
            end
        end
    end)
end

-- ============================================
-- DEPARTMAN LİSTESİNİ GÜNCELLE
-- ============================================
function FIB.RefreshDepartmentList()
    if not IsValid(FIB.DepartmentListView) then return end
    
    FIB.DepartmentListView:Clear()
    
    for steamid, data in pairs(FIB.AllAgents) do
        local isOnline = false
        for _, agent in ipairs(FIB.OnlineAgents) do
            if agent.steamid == steamid then
                isOnline = true
                break
            end
        end
        
        local line = FIB.DepartmentListView:AddLine(
            steamid,
            data.username,
            data.rank,
            isOnline and "Online" or "Offline"
        )
        
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
    
    -- Cache'i temizle
    agentCache = {}
    FIB.OnlineAgents = {}
    FIB_ActiveAgents = {}
    
    -- Sync iste
    timer.Simple(1, function()
        RunConsoleCommand("fib_client_request_sync")
    end)
    
    timer.Simple(3, function()
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
    
    -- Çok sık sync isteme
    if (CurTime() - lastFullSync) < 2 then
        print("[FIB CLIENT] Sync istegi cok sik, bekleyin...")
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
        timer.Simple(0.5, function()
            RunConsoleCommand("fib_client_request_sync")
        end)
    end
end)

-- ============================================
-- PERİYODİK ENTİTY GÜNCELLEME
-- ============================================
timer.Create("FIB_UpdateEntities", 5, 0, function()
    if not LocalPlayer().FIBAuthenticated then return end
    if #FIB.OnlineAgents == 0 then return end
    
    local updated = false
    
    -- Entity'leri güncelle
    for i, agent in ipairs(FIB.OnlineAgents) do
        local ply = GetPlayerBySteamID(agent.steamid)
        if IsValid(ply) then
            if agent.entity ~= ply or agent.nick ~= ply:Nick() then
                agent.entity = ply
                agent.nick = ply:Nick()
                updated = true
            end
        elseif agent.entity then
            -- Entity artık geçersiz
            agent.entity = nil
            updated = true
        end
    end
    
    -- HUD için de güncelle
    FIB_ActiveAgents = FIB.OnlineAgents
    
    -- Liste açıksa ve güncelleme varsa refresh et
    if updated and IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        print("[FIB CLIENT] Entity guncelleme sonrasi refresh")
        FIB.RefreshAgentList()
    end
end)

-- ============================================
-- PERİYODİK SYNC İSTEĞİ (DAHA SEYREK)
-- ============================================
timer.Create("FIB_ClientPeriodicSync", 30, 0, function()
    if LocalPlayer().FIBAuthenticated and (CurTime() - lastFullSync) > 25 then
        RunConsoleCommand("fib_client_request_sync")
    end
end)

-- ============================================
-- KICKED RECEIVER
-- ============================================
net.Receive("FIB_KickedFromSystem", function()
    print("[FIB CLIENT] Sistemden atildiniz!")
    
    LocalPlayer().FIBAuthenticated = false
    LocalPlayer().FIBRank = nil
    LocalPlayer().FIBUsername = nil
    LocalPlayer().FIBUndercover = false
    
    agentCache = {}
    FIB.OnlineAgents = {}
    FIB_ActiveAgents = {}
    
    if IsValid(FIB.MainMenu) then
        FIB.MainMenu:Close()
    end
    
    if IsValid(FIB.MiniIndicator) then
        FIB.MiniIndicator:Remove()
        FIB.MiniIndicator = nil
    end
    
    timer.Simple(0.5, function()
        if FIB.CreateLoginPanel then
            FIB.CreateLoginPanel()
        else
            RunConsoleCommand("fib_open_login")
        end
    end)
    
    notification.AddLegacy("FIB: Sistem erisiminiz kaldirildi!", NOTIFY_ERROR, 5)
    surface.PlaySound("buttons/button10.wav")
end)

-- ============================================
-- DEBUG KOMUTU
-- ============================================
concommand.Add("fib_client_debug", function()
    print("[FIB CLIENT] === CLIENT DEBUG ===")
    print("Authenticated: " .. tostring(LocalPlayer().FIBAuthenticated))
    print("Online Ajanlar: " .. #FIB.OnlineAgents)
    print("Cache'deki Ajanlar: " .. table.Count(agentCache))
    print("Son Full Sync: " .. math.Round(CurTime() - lastFullSync) .. " saniye once")
    
    print("\nOnline Ajanlar Detayli:")
    for i, agent in ipairs(FIB.OnlineAgents) do
        local ply = GetPlayerBySteamID(agent.steamid)
        local validStr = IsValid(ply) and "VALID" or "INVALID/CACHED"
        print("  [" .. i .. "] " .. agent.nick .. " (" .. agent.steamid .. ")")
        print("      - Entity: " .. validStr)
        print("      - Rank: " .. agent.rank)
        print("      - Undercover: " .. tostring(agent.undercover))
    end
    
    print("\nPlayer.GetAll() Kontrolu:")
    local fibCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            fibCount = fibCount + 1
            print("  - " .. ply:Nick() .. " [" .. ply:SteamID() .. "] FIB: YES")
        end
    end
    print("Toplam FIB oyuncu: " .. fibCount)
    
    if IsValid(FIB.AgentListView) then
        print("\nListView: VALID - " .. #FIB.AgentListView:GetLines() .. " satir")
        local lines = FIB.AgentListView:GetLines()
        for i, line in ipairs(lines) do
            if IsValid(line) then
                print("  Satir " .. i .. ": " .. line:GetColumnText(1))
            end
        end
    else
        print("\nListView: INVALID")
    end
end)

print("[FIB CLIENT] Senkronizasyon sistemi yuklendi! (v5.0 - Stable)")