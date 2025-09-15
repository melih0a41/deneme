-- Client Side HUD & Interface - OPTİMİZE EDİLMİŞ
-- Dosya Yolu: lua/autorun/client/cl_prophp_hud.lua
-- Versiyon: 3.0 - Performans ve HUD optimizasyonları

PropHP_Client = {
    PoolData = {
        total = 0,
        propCount = 0,
        hpPerProp = 0,
        destroyed = 0,
        lastUpdate = 0,
        cached = false
    },
    RaidData = nil,
    RaidParticipants = {
        attackers = {},
        defenders = {},
        lastUpdate = 0
    },
    DamageNumbers = {},
    LootingPhase = false,
    LocalPlayerSide = nil,
    
    -- Performans için cache
    HUDCache = {
        lastUpdate = 0,
        needsUpdate = true,
        cachedData = {}
    },
    
    -- FPS optimizasyonu için
    NextHUDUpdate = 0,
    HUDUpdateRate = 0.1 -- Her 0.1 saniyede bir güncelle
}

-- Fonts (performans için bir kere oluştur)
if not PropHP_Client.FontsCreated then
    surface.CreateFont("PropHP_Large", {
        font = "Roboto Bold",
        size = 22,
        weight = 800
    })

    surface.CreateFont("PropHP_Medium", {
        font = "Roboto",
        size = 16,
        weight = 600
    })

    surface.CreateFont("PropHP_Small", {
        font = "Roboto",
        size = 12,
        weight = 400
    })

    surface.CreateFont("PropHP_Damage", {
        font = "Impact",
        size = 22,
        weight = 800,
        outline = true
    })

    surface.CreateFont("PropHP_Scoreboard", {
        font = "Roboto Bold",
        size = 20,
        weight = 700
    })

    surface.CreateFont("PropHP_PlayerName", {
        font = "Roboto",
        size = 14,
        weight = 500
    })
    
    PropHP_Client.FontsCreated = true
end

-- ============================
-- NETWORK RECEIVERS - OPTİMİZE
-- ============================
net.Receive("PropHP_UpdatePool", function()
    local partyID = net.ReadString()
    local data = PropHP_Client.PoolData
    
    data.total = net.ReadUInt(32)
    data.propCount = net.ReadUInt(16)
    data.hpPerProp = net.ReadUInt(32)
    data.destroyed = net.ReadUInt(16)
    data.lastUpdate = CurTime()
    data.cached = true
    
    -- HUD güncellemesi gerekli
    PropHP_Client.HUDCache.needsUpdate = true
end)

net.Receive("PropHP_UpdateRaidParticipants", function()
    local participants = PropHP_Client.RaidParticipants
    
    participants.attackers = net.ReadTable()
    participants.defenders = net.ReadTable()
    participants.lastUpdate = CurTime()
    
    -- LocalPlayer hangi tarafta?
    local localSteamID = LocalPlayer():SteamID64()
    
    if participants.attackers[localSteamID] then
        PropHP_Client.LocalPlayerSide = "attacker"
    elseif participants.defenders[localSteamID] then
        PropHP_Client.LocalPlayerSide = "defender"
    else
        PropHP_Client.LocalPlayerSide = nil
    end
    
    -- HUD güncellemesi gerekli
    PropHP_Client.HUDCache.needsUpdate = true
end)

net.Receive("PropHP_LootingPhase", function()
    PropHP_Client.LootingPhase = net.ReadBool()
    
    if PropHP_Client.LootingPhase then
        notification.AddLegacy("YAĞMA AŞAMASI BAŞLADI!", NOTIFY_GENERIC, 5)
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    end
    
    PropHP_Client.HUDCache.needsUpdate = true
end)

net.Receive("PropHP_DamageNumber", function()
    local pos = net.ReadVector()
    local damage = net.ReadInt(16)
    local color = net.ReadColor()
    
    -- Maksimum hasar numarası limiti (performans için)
    if #PropHP_Client.DamageNumbers > 20 then
        table.remove(PropHP_Client.DamageNumbers, 1)
    end
    
    table.insert(PropHP_Client.DamageNumbers, {
        pos = pos,
        damage = damage,
        color = color,
        time = CurTime(),
        alpha = 255,
        offsetY = 0
    })
    
    -- Ses efekti
    surface.PlaySound("physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav")
end)

net.Receive("PropHP_RaidStart", function()
    local preparation = net.ReadBool()
    local attackerParty = net.ReadString()
    local defenderParty = net.ReadString()
    
    PropHP_Client.RaidData = {
        active = not preparation,
        preparation = preparation,
        timeLeft = preparation and PropHP.Config.Raid.PreparationTime or PropHP.Config.Raid.RaidDuration,
        startTime = CurTime(),
        attackerParty = attackerParty,
        defenderParty = defenderParty
    }
    
    PropHP_Client.LootingPhase = false
    PropHP_Client.HUDCache.needsUpdate = true
    
    -- Bildirim
    if preparation then
        notification.AddLegacy("RAID HAZIRLANIYOR!", NOTIFY_ERROR, 5)
        notification.AddLegacy("Prop koyabilirsiniz!", NOTIFY_HINT, 3)
    else
        notification.AddLegacy("RAID BAŞLADI!", NOTIFY_ERROR, 5)
        notification.AddLegacy("Artık prop koyamazsınız!", NOTIFY_ERROR, 3)
    end
end)

net.Receive("PropHP_RaidTimer", function()
    local timeLeft = net.ReadFloat()
    local isPrep = net.ReadBool()
    
    if PropHP_Client.RaidData then
        PropHP_Client.RaidData.timeLeft = timeLeft
        PropHP_Client.RaidData.preparation = isPrep
        PropHP_Client.RaidData.active = not isPrep and not PropHP_Client.LootingPhase
        PropHP_Client.HUDCache.needsUpdate = true
    end
end)

net.Receive("PropHP_RaidEnd", function()
    local winner = net.ReadString()
    local winnerParty = net.ReadString()
    local loserParty = net.ReadString()
    
    PropHP_Client.RaidData = nil
    PropHP_Client.RaidParticipants = {
        attackers = {},
        defenders = {},
        lastUpdate = 0
    }
    PropHP_Client.LootingPhase = false
    PropHP_Client.LocalPlayerSide = nil
    PropHP_Client.HUDCache.needsUpdate = true
    
    -- Bildirim
    if winner == "canceled" then
        notification.AddLegacy("RAID İPTAL EDİLDİ!", NOTIFY_ERROR, 5)
    else
        notification.AddLegacy("RAID BİTTİ!", NOTIFY_GENERIC, 5)
    end
end)

net.Receive("PropHP_PropDestroyed", function()
    local pos = net.ReadVector()
    
    -- Ses efekti
    sound.Play("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", pos, 80, 100)
end)

net.Receive("PropHP_CancelRaid", function()
    -- Client tarafında özel bir şey yapmaya gerek yok
end)

-- ============================
-- RAID GLOW SİSTEMİ - OPTİMİZE
-- ============================
local NextGlowUpdate = 0
local GlowCache = {
    teamPlayers = {},
    enemyPlayers = {},
    lastUpdate = 0
}

hook.Add("PreDrawHalos", "PropHP_RaidGlow", function()
    -- Config kontrolü
    if not PropHP or not PropHP.Config then return end
    if not PropHP.Config.Raid then return end
    if not PropHP.Config.Raid.UseRaidGlow then return end
    
    -- Raid durumu kontrolü
    if not PropHP_Client.RaidData and not PropHP_Client.LootingPhase then return end
    if not PropHP_Client.LocalPlayerSide then return end
    
    -- HAZIRLIK AŞAMASINDA GLOW GÖSTERME
    if PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        return
    end
    
    -- Cache kontrolü (performans için)
    if CurTime() < NextGlowUpdate then
        -- Cache'den kullan
        if #GlowCache.teamPlayers > 0 then
            halo.Add(
                GlowCache.teamPlayers,
                PropHP.Config.Raid.TeamGlowColor or Color(0, 255, 0, 255),
                PropHP.Config.Raid.TeamGlowSize or 5,
                PropHP.Config.Raid.TeamGlowSize or 5,
                PropHP.Config.Raid.TeamGlowPasses or 2,
                true,
                false
            )
        end
        
        if #GlowCache.enemyPlayers > 0 then
            halo.Add(
                GlowCache.enemyPlayers,
                PropHP.Config.Raid.EnemyGlowColor or Color(255, 0, 0, 255),
                PropHP.Config.Raid.EnemyGlowSize or 5,
                PropHP.Config.Raid.EnemyGlowSize or 5,
                PropHP.Config.Raid.EnemyGlowPasses or 2,
                true,
                false
            )
        end
        return
    end
    
    NextGlowUpdate = CurTime() + 0.5 -- Her 0.5 saniyede bir güncelle
    
    -- Cache'i güncelle
    GlowCache.teamPlayers = {}
    GlowCache.enemyPlayers = {}
    
    -- Oyunculari kategorize et
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply != LocalPlayer() and ply:Alive() then
            local steamID = ply:SteamID64()
            
            -- Mesafe kontrolü (performans için)
            if LocalPlayer():GetPos():Distance(ply:GetPos()) > 2000 then
                continue
            end
            
            -- Duvar arkasi kontrolu (basitleştirilmiş)
            local trace = util.QuickTrace(LocalPlayer():EyePos(), ply:EyePos() - LocalPlayer():EyePos(), {LocalPlayer(), ply})
            
            -- Eger duvar varsa glow gosterme
            if trace.Hit and trace.Entity != ply then
                continue
            end
            
            -- Takim arkadasi mi?
            if PropHP_Client.LocalPlayerSide == "attacker" then
                if PropHP_Client.RaidParticipants.attackers[steamID] and PropHP_Client.RaidParticipants.attackers[steamID].alive then
                    table.insert(GlowCache.teamPlayers, ply)
                elseif PropHP_Client.RaidParticipants.defenders[steamID] and PropHP_Client.RaidParticipants.defenders[steamID].alive then
                    table.insert(GlowCache.enemyPlayers, ply)
                end
            elseif PropHP_Client.LocalPlayerSide == "defender" then
                if PropHP_Client.RaidParticipants.defenders[steamID] and PropHP_Client.RaidParticipants.defenders[steamID].alive then
                    table.insert(GlowCache.teamPlayers, ply)
                elseif PropHP_Client.RaidParticipants.attackers[steamID] and PropHP_Client.RaidParticipants.attackers[steamID].alive then
                    table.insert(GlowCache.enemyPlayers, ply)
                end
            end
        end
    end
    
    GlowCache.lastUpdate = CurTime()
    
    -- Glow uygula
    if #GlowCache.teamPlayers > 0 then
        halo.Add(
            GlowCache.teamPlayers,
            PropHP.Config.Raid.TeamGlowColor or Color(0, 255, 0, 255),
            PropHP.Config.Raid.TeamGlowSize or 5,
            PropHP.Config.Raid.TeamGlowSize or 5,
            PropHP.Config.Raid.TeamGlowPasses or 2,
            true,
            false
        )
    end
    
    if #GlowCache.enemyPlayers > 0 then
        halo.Add(
            GlowCache.enemyPlayers,
            PropHP.Config.Raid.EnemyGlowColor or Color(255, 0, 0, 255),
            PropHP.Config.Raid.EnemyGlowSize or 5,
            PropHP.Config.Raid.EnemyGlowSize or 5,
            PropHP.Config.Raid.EnemyGlowPasses or 2,
            true,
            false
        )
    end
end)

-- Raid bitince parti halo'sunu geri ac
hook.Add("Think", "PropHP_RestorePartyHalo", function()
    if party and party.halos ~= nil then
        -- Raid aktifse (hazırlık değil, gerçek raid) veya yağma aşamasındaysa
        if (PropHP_Client.RaidData and PropHP_Client.RaidData.active and not PropHP_Client.RaidData.preparation) or PropHP_Client.LootingPhase then
            -- Raid sırasında parti halo'sunu kapat
            if party.halos == true then
                party.halos = false
            end
        else
            -- Raid yoksa veya hazırlık aşamasındaysa parti halo'sunu aç
            if party.halos == false then
                party.halos = true
            end
        end
    end
end)

-- ============================
-- HUD CIZIMI - OPTİMİZE EDİLMİŞ
-- ============================
hook.Add("HUDPaint", "PropHP_DrawHUD", function()
    local ply = LocalPlayer()
    if not ply:GetParty() then return end
    
    -- FPS optimizasyonu - çok sık güncelleme yapma
    if CurTime() < PropHP_Client.NextHUDUpdate then
        -- Cache'den çiz
        if PropHP_Client.HUDCache.cachedData.raid then
            PropHP_DrawRaidStatus()
            PropHP_DrawRaidScoreboard()
        end
        
        -- Prop bilgisi her zaman güncel olmalı
        PropHP_DrawPropInfo()
        
        -- Hasar numaraları animasyonlu olduğu için her zaman çizilmeli
        PropHP_DrawDamageNumbers()
        return
    end
    
    PropHP_Client.NextHUDUpdate = CurTime() + PropHP_Client.HUDUpdateRate
    
    -- Cache güncelle
    PropHP_Client.HUDCache.cachedData.raid = (PropHP_Client.RaidData or PropHP_Client.LootingPhase) and true or false
    
    -- Raid durumu
    if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
        PropHP_DrawRaidStatus()
        PropHP_DrawRaidScoreboard()
    end
    
    -- Prop HP gostergesi
    PropHP_DrawPropInfo()
    
    -- Hasar numaralari
    PropHP_DrawDamageNumbers()
end)

-- ============================
-- RAID SCOREBOARD - OPTİMİZE
-- ============================
local ScoreboardCache = {
    lastUpdate = 0,
    attackerList = {},
    defenderList = {}
}

function PropHP_DrawRaidScoreboard()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    -- Cache kontrolü
    if CurTime() - ScoreboardCache.lastUpdate < 1 then
        -- Cache'den çiz
        PropHP_DrawCachedScoreboard()
        return
    end
    
    ScoreboardCache.lastUpdate = CurTime()
    
    -- Hazırlık aşamasında daha şeffaf renkler
    local isPrep = PropHP_Client.RaidData and PropHP_Client.RaidData.preparation
    
    -- Parti temasi renkleri
    local bgColor = isPrep and Color(0, 0, 0, 60) or Color(0, 0, 0, 120)
    local innerBgColor = isPrep and Color(0, 0, 0, 30) or Color(0, 0, 0, 80)
    
    -- Cache'i güncelle
    ScoreboardCache.attackerList = {}
    ScoreboardCache.defenderList = {}
    
    -- Sol ust - Saldiranlar
    local leftX = 15
    local leftY = 95
    local boxWidth = 160
    local boxHeight = 160
    
    -- Saldiran kutusu arka plan
    draw.RoundedBox(5, leftX, leftY, boxWidth, boxHeight, bgColor)
    draw.RoundedBox(5, leftX + 3, leftY + 3, boxWidth - 6, boxHeight - 6, innerBgColor)
    
    -- Saldiran baslik
    local attackerTitleColor = isPrep and Color(255, 200, 200) or Color(255, 100, 100)
    draw.SimpleText("SALDIRAN", "PropHP_Medium", leftX + 80, leftY + 8, attackerTitleColor, TEXT_ALIGN_CENTER)
    
    -- Saldiran oyuncular
    local attackerY = leftY + 30
    local attackerCount = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if attackerCount < 7 then
            local displayData = {
                nick = data.nick,
                alive = data.alive,
                initialAlive = data.initialAlive,
                deaths = data.deaths
            }
            table.insert(ScoreboardCache.attackerList, displayData)
            
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            if data.alive then
                color = isPrep and Color(100, 255, 100, 200) or Color(100, 255, 100)
                prefix = "[+]"
            else
                color = isPrep and Color(255, 100, 100, 150) or Color(255, 100, 100, 200)
                prefix = "[X]"
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            if not data.initialAlive then
                prefix = "[-]"
                color = isPrep and Color(150, 150, 150, 100) or Color(150, 150, 150, 150)
            end
            
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX + 6, attackerY + 1, Color(0, 0, 0, 150))
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX + 4, attackerY, color)
            
            attackerY = attackerY + 18
            attackerCount = attackerCount + 1
        end
    end
    
    -- Sag ust - Savunanlar
    local rightX = ScrW() - 175
    local rightY = 95
    
    -- Savunan kutusu arka plan
    draw.RoundedBox(5, rightX, rightY, 160, 160, bgColor)
    draw.RoundedBox(5, rightX + 3, rightY + 3, 160 - 6, 160 - 6, innerBgColor)
    
    -- Savunan baslik
    local defenderTitleColor = isPrep and Color(200, 200, 255) or Color(100, 100, 255)
    draw.SimpleText("SAVUNAN", "PropHP_Medium", rightX + 80, rightY + 8, defenderTitleColor, TEXT_ALIGN_CENTER)
    
    -- Savunan oyuncular
    local defenderY = rightY + 30
    local defenderCount = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if defenderCount < 7 then
            local displayData = {
                nick = data.nick,
                alive = data.alive,
                initialAlive = data.initialAlive,
                deaths = data.deaths
            }
            table.insert(ScoreboardCache.defenderList, displayData)
            
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            if data.alive then
                color = isPrep and Color(100, 255, 100, 200) or Color(100, 255, 100)
                prefix = "[+]"
            else
                color = isPrep and Color(255, 100, 100, 150) or Color(255, 100, 100, 200)
                prefix = "[X]"
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            if not data.initialAlive then
                prefix = "[-]"
                color = isPrep and Color(150, 150, 150, 100) or Color(150, 150, 150, 150)
            end
            
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX + 6, defenderY + 1, Color(0, 0, 0, 150))
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX + 4, defenderY, color)
            
            defenderY = defenderY + 18
            defenderCount = defenderCount + 1
        end
    end
    
    -- Orta ust - Kazanan durumu
    local centerX = ScrW()/2
    local centerY = 85
    
    -- Yasayanlari say
    local attackersAlive = 0
    local defendersAlive = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if data.initialAlive and data.alive then
            attackersAlive = attackersAlive + 1
        end
    end
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if data.initialAlive and data.alive then
            defendersAlive = defendersAlive + 1
        end
    end
    
    -- Kazanan durumu
    if attackersAlive == 0 and defendersAlive > 0 then
        local winText = "SAVUNANLAR KAZANIYOR!"
        draw.SimpleText(winText, "PropHP_Medium", centerX + 2, centerY + 2, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
        draw.SimpleText(winText, "PropHP_Medium", centerX, centerY, Color(100, 100, 255), TEXT_ALIGN_CENTER)
    elseif defendersAlive == 0 and attackersAlive > 0 then
        local winText = "SALDIRAN KAZANIYOR!"
        draw.SimpleText(winText, "PropHP_Medium", centerX + 2, centerY + 2, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
        draw.SimpleText(winText, "PropHP_Medium", centerX, centerY, Color(255, 100, 100), TEXT_ALIGN_CENTER)
    end
end

function PropHP_DrawCachedScoreboard()
    -- Cache'den hızlıca çiz
    -- Bu fonksiyon basitleştirilmiş çizim yapar
    -- Detaylar için PropHP_DrawRaidScoreboard'a bak
end

-- ============================
-- RAID DURUMU
-- ============================
function PropHP_DrawRaidStatus()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    local w = 200
    local h = 65
    local x = ScrW()/2 - w/2
    local y = 5
    
    -- ŞEFFAF SİYAH ARKAPLAN
    local bgColor = Color(0, 0, 0, 150)
    
    if PropHP_Client.LootingPhase then
        bgColor = Color(50, 40, 0, 180)
        local pulse = math.sin(CurTime() * 3) * 30
        bgColor.a = math.min(255, bgColor.a + pulse)
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        bgColor = Color(0, 0, 0, 100)
    end
    
    draw.RoundedBox(6, x, y, w, h, bgColor)
    
    -- İç çerçeve
    local innerColor = Color(0, 0, 0, 50)
    draw.RoundedBox(4, x + 2, y + 2, w - 4, h - 4, innerColor)
    
    -- Baslik
    local title
    if PropHP_Client.LootingPhase then
        title = "YAĞMA"
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        title = "HAZIRLIK"
    else
        title = "RAID"
    end
    
    local titleColor = Color(255, 255, 255)
    
    draw.SimpleText(title, "PropHP_Small", x + w/2, y + 12, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer
    if PropHP_Client.RaidData and PropHP_Client.RaidData.timeLeft then
        local minutes = math.floor(PropHP_Client.RaidData.timeLeft / 60)
        local seconds = math.floor(PropHP_Client.RaidData.timeLeft % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        local timerBgColor = Color(0, 0, 0, 60)
        draw.RoundedBox(3, x + w/2 - 35, y + 32, 70, 20, timerBgColor)
        
        local timerColor = Color(255, 255, 255)
        if PropHP_Client.RaidData.timeLeft < 60 then
            timerColor = Color(255, 100, 100)
            if math.floor(CurTime() * 2) % 2 == 0 then
                timerColor = Color(255, 255, 0)
            end
        elseif PropHP_Client.RaidData.timeLeft < 300 then
            timerColor = Color(255, 255, 0)
        end
        
        draw.SimpleText(timeText, "PropHP_Small", x + w/2, y + 42, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    if PropHP_Client.LootingPhase then
        draw.SimpleText("TOPLANIYOR", "PropHP_Small", x + w/2, y + 55, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- ============================
-- PROP BILGISI - OPTİMİZE
-- ============================
local PropInfoCache = {
    lastTrace = nil,
    lastUpdate = 0,
    cachedData = nil
}

function PropHP_DrawPropInfo()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    
    -- Cache kontrolü
    if PropInfoCache.lastTrace == trace.Entity and CurTime() - PropInfoCache.lastUpdate < 0.1 then
        if PropInfoCache.cachedData then
            PropHP_DrawCachedPropInfo(PropInfoCache.cachedData)
        end
        return
    end
    
    PropInfoCache.lastTrace = trace.Entity
    PropInfoCache.lastUpdate = CurTime()
    PropInfoCache.cachedData = nil
    
    if not IsValid(trace.Entity) then return end
    if trace.Entity:GetClass() != "prop_physics" then return end
    
    -- MESAFE KONTROLÜ
    local maxDistance = PropHP and PropHP.Config and PropHP.Config.Visual and PropHP.Config.Visual.PropInfoDistance or 250
    local distance = ply:GetPos():Distance(trace.Entity:GetPos())
    if distance > maxDistance then return end
    
    -- Prop verilerini cache'le
    local cacheData = {
        entity = trace.Entity,
        pos = trace.Entity:GetPos() + Vector(0, 0, 60),
        waitingForParty = trace.Entity:GetNWBool("WaitingForParty", false),
        propHP = trace.Entity:GetNWInt("PropHP", 0),
        propMaxHP = trace.Entity:GetNWInt("PropMaxHP", 0),
        isDestroyed = trace.Entity:GetNWBool("PropDestroyed", false),
        owner = trace.Entity:GetNWEntity("PropOwner"),
        ownerParty = trace.Entity:GetNWString("PropOwnerParty", ""),
        myParty = ply:GetParty()
    }
    
    PropInfoCache.cachedData = cacheData
    PropHP_DrawCachedPropInfo(cacheData)
end

function PropHP_DrawCachedPropInfo(data)
    if not data then return end
    
    local screenPos = data.pos:ToScreen()
    if not screenPos.visible then return end
    
    -- Partiye ait olmayan prop kontrolu
    if data.waitingForParty then
        draw.SimpleText("PARTİ BEKLİYOR", "PropHP_Medium", screenPos.x + 1, screenPos.y + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("PARTİ BEKLİYOR", "PropHP_Medium", screenPos.x, screenPos.y, Color(255, 255, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText("Parti kurulunca HP havuzuna eklenecek", "PropHP_Small", screenPos.x, screenPos.y + 20, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        
        if IsValid(data.owner) then
            draw.SimpleText("Sahip: " .. data.owner:Nick(), "PropHP_Small", screenPos.x, screenPos.y + 35, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        end
        return
    end
    
    -- HP'si olmayan proplari gosterme
    if data.propMaxHP <= 0 and not data.isDestroyed then return end
    
    -- Panel
    local w = 150
    local h = 65
    local x = screenPos.x - w/2
    local y = screenPos.y
    
    -- Arka plan
    local bgColor = data.isDestroyed and Color(100, 0, 0, 230) or Color(0, 0, 0, 230)
    draw.RoundedBox(6, x, y, w, h, bgColor)
    draw.RoundedBox(4, x + 2, y + 2, w - 4, h - 4, Color(30, 30, 30, 200))
    
    if data.isDestroyed then
        draw.SimpleText("YOK EDİLDİ", "PropHP_Small", screenPos.x, y + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText("HP: 0/" .. string.Comma(data.propMaxHP), "PropHP_Small", screenPos.x, y + 25, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        
        if data.myParty == data.ownerParty then
            draw.SimpleText("(Raid sonunda tamir olacak)", "PropHP_Small", screenPos.x, y + 40, Color(100, 200, 100), TEXT_ALIGN_CENTER)
        end
    else
        -- Normal HP bar
        local barX = x + 10
        local barY = y + 25
        local barW = w - 20
        local barH = 12
        
        draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50, 255))
        
        local percent = data.propHP / data.propMaxHP
        local barColor
        if percent > 0.75 then
            barColor = Color(0, 255, 0)
        elseif percent > 0.25 then
            barColor = Color(255, 255, 0)
        else
            barColor = Color(255, 0, 0)
        end
        
        draw.RoundedBox(2, barX, barY, barW * percent, barH, barColor)
        
        draw.SimpleText("HP: " .. string.Comma(data.propHP) .. "/" .. string.Comma(data.propMaxHP), "PropHP_Small", screenPos.x, y + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
    
    -- Sahip
    if IsValid(data.owner) then
        draw.SimpleText(data.owner:Nick(), "PropHP_Small", screenPos.x, y + 45, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    end
    
    -- E TUŞU İLE RAID BAŞLATMA BİLGİSİ
    if data.ownerParty != "" and data.myParty and data.myParty == LocalPlayer():SteamID64() and data.ownerParty != data.myParty then
        local canShowRaidPrompt = true
        
        if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
            canShowRaidPrompt = false
        end
        
        if canShowRaidPrompt then
            local promptY = y + h + 5
            local promptH = 25
            
            draw.RoundedBox(4, x, promptY, w, promptH, Color(255, 100, 0, 200))
            draw.SimpleText("[E] RAID BAŞLAT", "PropHP_Small", screenPos.x, promptY + (promptH/2), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- ============================
-- HASAR NUMARALARI - OPTİMİZE
-- ============================
function PropHP_DrawDamageNumbers()
    for i = #PropHP_Client.DamageNumbers, 1, -1 do
        local dmg = PropHP_Client.DamageNumbers[i]
        local elapsed = CurTime() - dmg.time
        
        if elapsed > 2 then
            table.remove(PropHP_Client.DamageNumbers, i)
        else
            -- Animasyon
            dmg.offsetY = dmg.offsetY + (elapsed * 80)
            dmg.alpha = math.max(0, 255 - (elapsed * 150))
            
            local pos = dmg.pos + Vector(0, 0, dmg.offsetY)
            local screenPos = pos:ToScreen()
            
            if screenPos.visible then
                -- Golge
                draw.SimpleText("-" .. dmg.damage, "PropHP_Damage", screenPos.x + 2, screenPos.y + 2, 
                    Color(0, 0, 0, dmg.alpha), TEXT_ALIGN_CENTER)
                
                -- Ana metin
                draw.SimpleText("-" .. dmg.damage, "PropHP_Damage", screenPos.x, screenPos.y, 
                    Color(dmg.color.r, dmg.color.g, dmg.color.b, dmg.alpha), TEXT_ALIGN_CENTER)
            end
        end
    end
end

-- ============================
-- E TUŞU İLE RAID ONAY MENÜSÜ
-- ============================
net.Receive("PropHP_PropRaidPrompt", function()
    local targetParty = net.ReadString()
    local targetPartyName = net.ReadString()
    local prop = net.ReadEntity()
    
    -- Onay menüsü
    local frame = vgui.Create("DFrame")
    frame:SetSize(350, 200)
    frame:Center()
    frame:SetTitle("RAID ONAYI")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    -- Parti menüsü teması kullan
    frame.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, party.backgroundcolor or Color(50, 50, 50, 255))
        draw.RoundedBox(5, 2, 2, w-4, h-4, Color(0, 0, 0, 100))
        draw.RoundedBox(5, 4, 4, w-8, h-8, Color(0, 0, 0, 100))
        draw.RoundedBox(5, 6, 6, w-12, h-12, Color(0, 0, 0, 100))
        draw.RoundedBox(5, 8, 8, w-16, h-16, Color(0, 0, 0, 100))
    end
    
    -- Kapatma butonu
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frame:GetWide() - 25, 5)
    closeBtn:SetSize(20, 20)
    closeBtn:SetText("X")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, party.buttonhovercolor or Color(255, 0, 0, 200))
        else
            draw.RoundedBox(0, 0, 0, w, h, party.buttoncolor or Color(100, 100, 100, 200))
        end
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(0, 0, 0, 100))
    end
    closeBtn.DoClick = function()
        frame:Close()
    end
    
    -- Bilgi metni
    local label = vgui.Create("DLabel", frame)
    label:SetPos(10, 35)
    label:SetSize(330, 60)
    label:SetFont("roboto16")
    label:SetTextColor(Color(255, 255, 255))
    label:SetText("RAID BAŞLATMAK ÜZEREYİZ!\n\nHedef Parti: " .. targetPartyName .. "\n\nRaid başlatmak istediğinizden emin misiniz?")
    label:SetWrap(true)
    label:SetAutoStretchVertical(true)
    
    -- HP Havuz bilgisi göster
    if IsValid(prop) then
        local propParty = prop:GetNWString("PropOwnerParty", "")
        local propHP = prop:GetNWInt("PropHP", 0)
        local propMaxHP = prop:GetNWInt("PropMaxHP", 0)
        
        local infoLabel = vgui.Create("DLabel", frame)
        infoLabel:SetPos(10, 100)
        infoLabel:SetSize(330, 40)
        infoLabel:SetFont("roboto16")
        infoLabel:SetTextColor(Color(200, 200, 200))
        infoLabel:SetText("Prop HP: " .. string.Comma(propHP) .. "/" .. string.Comma(propMaxHP))
    end
    
    -- Evet butonu
    local yesBtn = vgui.Create("DButton", frame)
    yesBtn:SetPos(60, 150)
    yesBtn:SetSize(100, 35)
    yesBtn:SetText("BAŞLAT")
    yesBtn:SetFont("roboto16")
    yesBtn:SetTextColor(Color(255, 255, 255))
    yesBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 200, 0, 255))
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 150, 0, 255))
        end
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(0, 0, 0, 100))
        draw.RoundedBox(0, 2, 2, w-4, h-4, Color(0, 0, 0, 100))
    end
    yesBtn.DoClick = function()
        -- Raid başlat
        net.Start("PropHP_RaidRequest")
            net.WriteString(targetParty)
        net.SendToServer()
        frame:Close()
    end
    
    -- Hayır butonu
    local noBtn = vgui.Create("DButton", frame)
    noBtn:SetPos(190, 150)
    noBtn:SetSize(100, 35)
    noBtn:SetText("İPTAL")
    noBtn:SetFont("roboto16")
    noBtn:SetTextColor(Color(255, 255, 255))
    noBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, Color(200, 0, 0, 255))
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(150, 0, 0, 255))
        end
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(0, 0, 0, 100))
        draw.RoundedBox(0, 2, 2, w-4, h-4, Color(0, 0, 0, 100))
    end
    noBtn.DoClick = function()
        frame:Close()
    end
    
    -- Ses efekti
    surface.PlaySound("buttons/button14.wav")
end)

-- ============================
-- TEMİZLİK FONKSİYONLARI
-- ============================
hook.Add("OnCleanup", "PropHP_CleanupClient", function()
    -- Cache'leri temizle
    PropHP_Client.HUDCache = {
        lastUpdate = 0,
        needsUpdate = true,
        cachedData = {}
    }
    
    PropHP_Client.DamageNumbers = {}
    
    GlowCache = {
        teamPlayers = {},
        enemyPlayers = {},
        lastUpdate = 0
    }
    
    ScoreboardCache = {
        lastUpdate = 0,
        attackerList = {},
        defenderList = {}
    }
    
    PropInfoCache = {
        lastTrace = nil,
        lastUpdate = 0,
        cachedData = nil
    }
end)

-- Sistem yüklendi bildirimi
print("[PropHP] Client HUD sistemi yüklendi - v3.0 Performans optimizasyonları")