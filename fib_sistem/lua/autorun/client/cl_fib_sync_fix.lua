-- fib_sistem/lua/autorun/client/cl_fib_sync_fix.lua
-- Client Senkronizasyon - v9.0 CLEAN

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
-- BASİT AMA ETKİLİ OYUNCU BULMA
-- ============================================
local function GetPlayerBySteamID(steamid)
    -- Sadece player.GetAll() üzerinden dene
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local sid = ply:SteamID()
            -- SteamID kontrolü
            if sid and sid == steamid then
                return ply
            end
        end
    end
    return nil -- Entity bulunamadı ama bu sorun değil
end

-- ============================================
-- SERVER'DAN GELEN LİSTEYİ KABUL ET
-- ============================================
local function ProcessServerAgentList(serverAgents)
    local processedList = {}
    
    for _, agentData in ipairs(serverAgents) do
        -- Server'dan gelen her ajanı kabul et
        local agent = {
            steamid = agentData.steamid,
            nick = agentData.nick,
            rank = agentData.rank,
            username = agentData.username,
            undercover = agentData.undercover,
            loginTime = agentData.loginTime,
            fromServer = true -- Server'dan geldiğini işaretle
        }
        
        -- Entity'yi bulmayı dene (opsiyonel)
        local ply = GetPlayerBySteamID(agentData.steamid)
        if IsValid(ply) then
            agent.entity = ply
            agent.nick = ply:Nick() -- Güncel nick'i al
        else
            agent.entity = nil -- Entity yok ama sorun değil
        end
        
        table.insert(processedList, agent)
        
        -- Cache'e kaydet
        agentCache[agentData.steamid] = agent
    end
    
    return processedList
end

-- ============================================
-- SADECE ENTITY GÜNCELLEME (LİSTEDEN ÇIKARMA YOK!)
-- ============================================
local function UpdateEntityReferences()
    local updated = false
    
    -- SADECE entity referanslarını güncelle, LİSTEDEN ASLA ÇIKARMA!
    for i, agent in ipairs(FIB.OnlineAgents) do
        local ply = GetPlayerBySteamID(agent.steamid)
        
        if IsValid(ply) then
            -- Entity bulundu, bilgileri güncelle
            if agent.entity ~= ply or agent.nick ~= ply:Nick() then
                agent.entity = ply
                agent.nick = ply:Nick()
                updated = true
            end
        else
            -- Entity bulunamadı - SORUN DEĞİL, LİSTEDE KAL!
            if agent.entity then
                agent.entity = nil
                updated = true
            end
        end
    end
    
    return updated
end

-- ============================================
-- FULL SYNC RECEIVER - SIMPLIFIED
-- ============================================
net.Receive("FIB_FullSync", function()
    local serverAgents = net.ReadTable()
    FIB.AllAgents = net.ReadTable()
    FIB.Missions = net.ReadTable()
    
    -- Server'dan geleni direkt kabul et ve DEĞIŞTIRME
    FIB.OnlineAgents = ProcessServerAgentList(serverAgents)
    FIB_ActiveAgents = FIB.OnlineAgents
    
    lastFullSync = CurTime()
    
    -- Dashboard varsa güncelle
    if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
    
    -- Departman listesi varsa güncelle
    if IsValid(FIB.DepartmentListView) then
        FIB.RefreshDepartmentList()
    end
end)

-- ============================================
-- QUICK SYNC RECEIVER - SIMPLIFIED
-- ============================================
net.Receive("FIB_QuickSync", function()
    local serverAgents = net.ReadTable()
    
    -- Server'dan geleni direkt kabul et
    FIB.OnlineAgents = ProcessServerAgentList(serverAgents)
    FIB_ActiveAgents = FIB.OnlineAgents
    
    -- Dashboard varsa güncelle
    if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
end)

-- ============================================
-- AJAN AYRILDI - SADECE BU DURUMDA ÇIKAR!
-- ============================================
net.Receive("FIB_AgentLeft", function()
    local steamid = net.ReadString()
    local nick = net.ReadString()
    
    -- SADECE BU DURUMDA listeden çıkar
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
-- DASHBOARD LİSTESİNİ GÜNCELLE - NEW LOGIC
-- ============================================
function FIB.RefreshAgentList()
    if not IsValid(FIB.AgentListView) then return end
    
    -- Entity referanslarını güncelle (ama listeden çıkarma!)
    UpdateEntityReferences()
    
    -- Listeyi temizle
    FIB.AgentListView:Clear()
    
    local addedCount = 0
    
    -- SERVER'DAN GELEN TÜM AJANLARI GÖSTER
    for i, agent in ipairs(FIB.OnlineAgents) do
        -- Entity'yi tekrar bulmayı dene
        local ply = GetPlayerBySteamID(agent.steamid)
        
        local nick = agent.nick
        local distance = "N/A"
        local isValidEntity = false
        
        if IsValid(ply) then
            -- Entity bulundu, güncel bilgileri al
            nick = ply:Nick()
            agent.entity = ply
            
            if ply == LocalPlayer() then
                distance = "0m"
            else
                distance = math.Round(LocalPlayer():GetPos():Distance(ply:GetPos())) .. "m"
            end
            isValidEntity = true
        else
            -- Entity bulunamadı ama YINE DE GÖSTER
            distance = "Uzak"
            agent.entity = nil
        end
        
        local status = agent.undercover and "Gizli" or "Normal"
        
        -- HER DURUMDA LİSTEYE EKLE
        local line = FIB.AgentListView:AddLine(
            nick,
            agent.rank,
            status,
            distance
        )
        
        if IsValid(line) then
            addedCount = addedCount + 1
            
            -- Renkleri ayarla
            if agent.steamid == LocalPlayer():SteamID() then
                -- Kendimiz - yeşil
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(65, 255, 65))
                    end
                end
            elseif not isValidEntity then
                -- Entity görünmüyor ama online - açık mavi
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(100, 200, 255))
                    end
                end
            elseif agent.undercover then
                -- Gizli modda - sarı
                for _, col in pairs(line.Columns) do
                    if IsValid(col) then
                        col:SetTextColor(Color(255, 200, 0))
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
        end
    end
    
    -- İstatistikleri güncelle - DOĞRU SAYI
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
    -- Cache'leri temizle
    agentCache = {}
    FIB.OnlineAgents = {}
    FIB_ActiveAgents = {}
    
    -- Sync iste
    timer.Simple(1, function()
        net.Start("FIB_RequestSync")
        net.SendToServer()
    end)
    
    timer.Simple(3, function()
        net.Start("FIB_RequestSync")
        net.SendToServer()
    end)
end)

-- ============================================
-- MENÜ AÇILDIĞINDA SYNC İSTE
-- ============================================
hook.Add("FIB_MenuOpened", "RequestSyncOnMenu", function()
    if LocalPlayer().FIBAuthenticated then
        timer.Simple(0.5, function()
            net.Start("FIB_RequestSync")
            net.SendToServer()
        end)
    end
end)

-- ============================================
-- SADECE ENTITY GÜNCELLEME (LİSTEDEN ÇIKARMA YOK!)
-- ============================================
timer.Create("FIB_UpdateEntities", 5, 0, function()
    if not LocalPlayer().FIBAuthenticated then return end
    if #FIB.OnlineAgents == 0 then return end
    
    -- SADECE entity referanslarını güncelle, ASLA listeden çıkarma!
    local updated = UpdateEntityReferences()
    
    -- HUD için güncelle
    FIB_ActiveAgents = FIB.OnlineAgents
    
    -- Liste açıksa ve güncelleme varsa refresh et
    if updated and IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
end)

-- ============================================
-- PERİYODİK SYNC İSTEĞİ
-- ============================================
timer.Create("FIB_ClientPeriodicSync", 20, 0, function()
    if LocalPlayer().FIBAuthenticated and (CurTime() - lastFullSync) > 15 then
        net.Start("FIB_RequestSync")
        net.SendToServer()
    end
end)

-- ============================================
-- PLAYER FULLY LOADED
-- ============================================
hook.Add("InitPostEntity", "FIB_PlayerFullyLoaded", function()
    timer.Simple(2, function()
        if LocalPlayer().FIBAuthenticated then
            net.Start("FIB_RequestSync")
            net.SendToServer()
        end
    end)
end)

-- ============================================
-- KICKED RECEIVER
-- ============================================
net.Receive("FIB_KickedFromSystem", function()
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
        end
    end)
    
    notification.AddLegacy("FIB: Sistem erisiminiz kaldirildi!", NOTIFY_ERROR, 5)
    surface.PlaySound("buttons/button10.wav")
end)