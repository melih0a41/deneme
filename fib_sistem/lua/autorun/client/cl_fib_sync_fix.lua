-- fib_sistem/lua/autorun/client/cl_fib_sync_fix.lua
-- Client Senkronizasyon - v10.1 FIXED NULL PANEL

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
local syncPending = false

-- ============================================
-- OYUNCU BULMA - OPTIMIZED
-- ============================================
local function GetPlayerBySteamID(steamid)
    -- Cache kontrol
    if agentCache[steamid] and IsValid(agentCache[steamid].entity) then
        return agentCache[steamid].entity
    end
    
    -- Player tablosunda ara
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID() == steamid then
            -- Cache'e kaydet
            if not agentCache[steamid] then
                agentCache[steamid] = {}
            end
            agentCache[steamid].entity = ply
            return ply
        end
    end
    
    return nil
end

-- ============================================
-- SERVER'DAN GELEN LİSTEYİ İŞLE - OPTIMIZED
-- ============================================
local function ProcessServerAgentList(serverAgents)
    if not serverAgents then return {} end
    
    local processedList = {}
    
    for _, agentData in ipairs(serverAgents) do
        if agentData and agentData.steamid then
            local agent = {
                steamid = agentData.steamid,
                nick = agentData.nick or "Unknown",
                rank = agentData.rank or "Ajan",
                username = agentData.username or "Unknown",
                undercover = agentData.undercover or false,
                loginTime = agentData.loginTime or 0,
                fromServer = true
            }
            
            -- Entity'yi bul
            local ply = GetPlayerBySteamID(agentData.steamid)
            if IsValid(ply) then
                agent.entity = ply
                agent.nick = ply:Nick() -- Güncel nick
            end
            
            table.insert(processedList, agent)
            
            -- Cache güncelle
            agentCache[agentData.steamid] = agent
        end
    end
    
    return processedList
end

-- ============================================
-- FULL SYNC RECEIVER - OPTIMIZED & FIXED
-- ============================================
net.Receive("FIB_FullSync", function()
    if syncPending then return end -- Duplicate sync önleme
    syncPending = true
    
    local serverAgents = net.ReadTable() or {}
    FIB.AllAgents = net.ReadTable() or {}
    FIB.Missions = net.ReadTable() or {}
    
    -- Görevleri işle (sadece gerçek görevler)
    local cleanMissions = {}
    for _, mission in ipairs(FIB.Missions) do
        if mission and mission.name then
            table.insert(cleanMissions, mission)
        end
    end
    FIB.Missions = cleanMissions
    
    -- Online ajanları işle
    FIB.OnlineAgents = ProcessServerAgentList(serverAgents)
    FIB_ActiveAgents = FIB.OnlineAgents
    
    lastFullSync = CurTime()
    syncPending = false
    
    -- UI güncellemeleri (timer ile) - NULL KONTROLÜ EKLENDİ
    timer.Simple(0.1, function()
        -- Dashboard
        if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
            FIB.RefreshAgentList()
        end
        
        -- Departman
        if IsValid(FIB.DepartmentListView) then
            FIB.RefreshDepartmentList()
        end
        
        -- Görevler - NULL KONTROLÜ
        if FIB.RefreshMissionList and IsValid(FIB.MissionListView) then
            FIB.RefreshMissionList()
        end
    end)
    
    -- print("[FIB CLIENT] Full sync alindi: " .. #FIB.OnlineAgents .. " ajan, " .. #FIB.Missions .. " gorev")
end)

-- ============================================
-- QUICK SYNC RECEIVER - OPTIMIZED
-- ============================================
net.Receive("FIB_QuickSync", function()
    local serverAgents = net.ReadTable() or {}
    
    FIB.OnlineAgents = ProcessServerAgentList(serverAgents)
    FIB_ActiveAgents = FIB.OnlineAgents
    
    -- Sadece ajan listesini güncelle - NULL KONTROLÜ
    if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        timer.Simple(0.05, function()
            if IsValid(FIB.AgentListView) then
                FIB.RefreshAgentList()
            end
        end)
    end
end)

-- ============================================
-- AJAN AYRILDI
-- ============================================
net.Receive("FIB_AgentLeft", function()
    local steamid = net.ReadString()
    local nick = net.ReadString()
    
    -- Listeden çıkar
    local newList = {}
    for _, agent in ipairs(FIB.OnlineAgents) do
        if agent.steamid ~= steamid then
            table.insert(newList, agent)
        end
    end
    
    FIB.OnlineAgents = newList
    FIB_ActiveAgents = newList
    
    -- Cache temizle
    agentCache[steamid] = nil
    
    -- Aktivite ekle - NULL KONTROLÜ
    if IsValid(FIB.ActivityList) then
        FIB.AddActivity(nick .. " sistemden ayrildi", Color(255, 200, 0))
    end
    
    -- Dashboard güncelle - NULL KONTROLÜ
    timer.Simple(0.1, function()
        if IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
            FIB.RefreshAgentList()
        end
    end)
end)

-- ============================================
-- DASHBOARD LİSTESİNİ GÜNCELLE - OPTIMIZED
-- ============================================
function FIB.RefreshAgentList()
    if not IsValid(FIB.AgentListView) then return end
    
    -- Listeyi temizle
    FIB.AgentListView:Clear()
    
    local addedCount = 0
    
    -- Ajanları göster
    for i, agent in ipairs(FIB.OnlineAgents) do
        if agent then
            local ply = GetPlayerBySteamID(agent.steamid)
            
            local nick = agent.nick or "Unknown"
            local distance = "N/A"
            
            if IsValid(ply) then
                nick = ply:Nick()
                
                if ply == LocalPlayer() then
                    distance = "0m"
                else
                    local dist = LocalPlayer():GetPos():Distance(ply:GetPos())
                    distance = math.Round(dist) .. "m"
                end
            else
                distance = "Uzak"
            end
            
            local status = agent.undercover and "Gizli" or "Normal"
            
            local line = FIB.AgentListView:AddLine(
                nick,
                agent.rank or "Ajan",
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
                elseif not IsValid(ply) then
                    -- Entity görünmüyor - açık mavi
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
                end
            end
        end
    end
    
    -- İstatistikleri güncelle
    if FIB.MainMenuStats then
        FIB.MainMenuStats[1].value = tostring(#FIB.OnlineAgents)
        
        local undercoverCount = 0
        for _, agent in ipairs(FIB.OnlineAgents) do
            if agent and agent.undercover then
                undercoverCount = undercoverCount + 1
            end
        end
        FIB.MainMenuStats[3].value = tostring(undercoverCount)
        
        -- Görev sayısı
        FIB.MainMenuStats[2].value = tostring(#FIB.Missions)
    end
end

-- ============================================
-- GÖREV LİSTESİNİ GÜNCELLE - NULL KONTROLÜ EKLENDİ
-- ============================================
function FIB.RefreshMissionList()
    -- NULL KONTROLÜ
    if not IsValid(FIB.MissionListView) then 
        return 
    end
    
    -- Children kontrolü
    local success, err = pcall(function()
        FIB.MissionListView:Clear()
    end)
    
    if not success then
        -- Panel geçersizse referansı temizle
        FIB.MissionListView = nil
        return
    end
    
    for _, mission in ipairs(FIB.Missions) do
        if mission and mission.name then
            FIB.MissionListView:AddLine(
                mission.name,
                mission.target or "Bilinmiyor",
                mission.priority or "ORTA",
                mission.status or "Beklemede",
                mission.assigned or "Atanmadi"
            )
        end
    end
end

-- ============================================
-- DEPARTMAN LİSTESİNİ GÜNCELLE - NULL KONTROLÜ
-- ============================================
function FIB.RefreshDepartmentList()
    if not IsValid(FIB.DepartmentListView) then return end
    
    -- Safe clear
    local success, err = pcall(function()
        FIB.DepartmentListView:Clear()
    end)
    
    if not success then
        FIB.DepartmentListView = nil
        return
    end
    
    for steamid, data in pairs(FIB.AllAgents) do
        if data then
            local isOnline = false
            for _, agent in ipairs(FIB.OnlineAgents) do
                if agent and agent.steamid == steamid then
                    isOnline = true
                    break
                end
            end
            
            local line = FIB.DepartmentListView:AddLine(
                steamid,
                data.username or "Unknown",
                data.rank or "Ajan",
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
end

-- ============================================
-- AKTİVİTE LİSTESİNE EKLE - NULL KONTROLÜ
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
    
    -- Max 20 aktivite - NULL KONTROLÜ
    local children = {}
    local success, err = pcall(function()
        children = FIB.ActivityList:GetChildren()
    end)
    
    if success and #children > 20 then
        for i = #children, 21, -1 do
            if IsValid(children[i]) then
                children[i]:Remove()
            end
        end
    end
end

-- ============================================
-- GİRİŞ YAPILDIĞINDA SYNC İSTE
-- ============================================
hook.Add("FIB_LoginSuccess", "RequestSyncOnLogin", function()
    -- Cache temizle
    agentCache = {}
    FIB.OnlineAgents = {}
    FIB_ActiveAgents = {}
    FIB.Missions = {}
    
    -- Sync iste
    timer.Simple(1, function()
        if LocalPlayer().FIBAuthenticated then
            net.Start("FIB_RequestSync")
            net.SendToServer()
        end
    end)
end)

-- ============================================
-- MENÜ AÇILDIĞINDA SYNC İSTE
-- ============================================
hook.Add("FIB_MenuOpened", "RequestSyncOnMenu", function()
    if LocalPlayer().FIBAuthenticated and (CurTime() - lastFullSync) > 10 then
        timer.Simple(0.5, function()
            net.Start("FIB_RequestSync")
            net.SendToServer()
        end)
    end
end)

-- ============================================
-- ENTITY GÜNCELLEME - NULL KONTROLÜ EKLENDİ
-- ============================================
timer.Create("FIB_UpdateEntities", 10, 0, function()
    if not LocalPlayer().FIBAuthenticated then return end
    if #FIB.OnlineAgents == 0 then return end
    
    -- Entity referanslarını güncelle
    local updated = false
    for _, agent in ipairs(FIB.OnlineAgents) do
        if agent then
            local ply = GetPlayerBySteamID(agent.steamid)
            if IsValid(ply) and ply:Nick() ~= agent.nick then
                agent.nick = ply:Nick()
                agent.entity = ply
                updated = true
            end
        end
    end
    
    -- Liste açıksa güncelle - NULL KONTROLÜ
    if updated and IsValid(FIB.MainMenu) and IsValid(FIB.AgentListView) then
        FIB.RefreshAgentList()
    end
end)

-- ============================================
-- PERİYODİK SYNC İSTEĞİ - OPTIMIZED
-- ============================================
timer.Create("FIB_ClientPeriodicSync", 60, 0, function()
    if LocalPlayer().FIBAuthenticated and (CurTime() - lastFullSync) > 50 then
        net.Start("FIB_RequestSync")
        net.SendToServer()
    end
end)

-- ============================================
-- CLEANUP
-- ============================================
hook.Add("ShutDown", "FIB_ClientCleanup", function()
    timer.Remove("FIB_UpdateEntities")
    timer.Remove("FIB_ClientPeriodicSync")
    
    -- Referansları temizle
    FIB.MissionListView = nil
    FIB.AgentListView = nil
    FIB.DepartmentListView = nil
    FIB.ActivityList = nil
end)

-- ============================================
-- KICKED RECEIVER
-- ============================================
net.Receive("FIB_KickedFromSystem", function()
    LocalPlayer().FIBAuthenticated = false
    LocalPlayer().FIBRank = nil
    LocalPlayer().FIBUsername = nil
    LocalPlayer().FIBUndercover = false
    
    -- Temizle
    agentCache = {}
    FIB.OnlineAgents = {}
    FIB_ActiveAgents = {}
    FIB.Missions = {}
    
    -- Referansları temizle
    FIB.MissionListView = nil
    FIB.AgentListView = nil
    FIB.DepartmentListView = nil
    FIB.ActivityList = nil
    
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

print("[FIB CLIENT] Sync sistemi yuklendi! (v10.1 - NULL PANEL FIXED)")