-- Client Side HUD & Interface (DÜZELTILMIŞ VERSIYON)
-- Dosya Yolu: lua/autorun/client/cl_prophp_hud.lua
-- 5v5 Scoreboard, Glow Efektleri ve Yağma Aşaması Dahil

local PropHP_Client = {
    PoolData = {
        total = 0,
        propCount = 0,
        hpPerProp = 0,
        destroyed = 0
    },
    RaidData = nil,
    RaidParticipants = {
        attackers = {},
        defenders = {}
    },
    DamageNumbers = {},
    LootingPhase = false,
    LocalPlayerSide = nil  -- "attacker" veya "defender"
}

-- Fonts
surface.CreateFont("PropHP_Large", {
    font = "Roboto Bold",
    size = 24,
    weight = 800
})

surface.CreateFont("PropHP_Medium", {
    font = "Roboto",
    size = 18,
    weight = 600
})

surface.CreateFont("PropHP_Small", {
    font = "Roboto",
    size = 14,
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
    size = 16,
    weight = 500
})

-- ============================
-- NETWORK RECEIVERS
-- ============================
net.Receive("PropHP_UpdatePool", function()
    local partyID = net.ReadString()
    PropHP_Client.PoolData.total = net.ReadUInt(32)
    PropHP_Client.PoolData.propCount = net.ReadUInt(16)
    PropHP_Client.PoolData.hpPerProp = net.ReadUInt(32)
    PropHP_Client.PoolData.destroyed = net.ReadUInt(16)
end)

net.Receive("PropHP_UpdateRaidParticipants", function()
    PropHP_Client.RaidParticipants.attackers = net.ReadTable()
    PropHP_Client.RaidParticipants.defenders = net.ReadTable()
    
    -- LocalPlayer hangi tarafta?
    local localSteamID = LocalPlayer():SteamID64()
    
    if PropHP_Client.RaidParticipants.attackers[localSteamID] then
        PropHP_Client.LocalPlayerSide = "attacker"
    elseif PropHP_Client.RaidParticipants.defenders[localSteamID] then
        PropHP_Client.LocalPlayerSide = "defender"
    else
        PropHP_Client.LocalPlayerSide = nil
    end
end)

net.Receive("PropHP_LootingPhase", function()
    PropHP_Client.LootingPhase = net.ReadBool()
    
    if PropHP_Client.LootingPhase then
        notification.AddLegacy("💰 YAĞMA AŞAMASI BAŞLADI!", NOTIFY_GENERIC, 5)
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    end
end)

net.Receive("PropHP_DamageNumber", function()
    local pos = net.ReadVector()
    local damage = net.ReadInt(16)
    local color = net.ReadColor()
    
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
        startTime = CurTime()
    }
    
    PropHP_Client.LootingPhase = false
    
    -- Bildirim
    if preparation then
        notification.AddLegacy("RAID HAZIRLANIYOR!", NOTIFY_ERROR, 5)
    else
        notification.AddLegacy("RAID BAŞLADI!", NOTIFY_ERROR, 5)
    end
end)

net.Receive("PropHP_RaidTimer", function()
    local timeLeft = net.ReadFloat()
    local isPrep = net.ReadBool()
    
    if PropHP_Client.RaidData then
        PropHP_Client.RaidData.timeLeft = timeLeft
        PropHP_Client.RaidData.preparation = isPrep
        PropHP_Client.RaidData.active = not isPrep and not PropHP_Client.LootingPhase
    end
end)

net.Receive("PropHP_RaidEnd", function()
    local winner = net.ReadString()
    local winnerParty = net.ReadString()
    local loserParty = net.ReadString()
    
    PropHP_Client.RaidData = nil
    PropHP_Client.RaidParticipants = {
        attackers = {},
        defenders = {}
    }
    PropHP_Client.LootingPhase = false
    PropHP_Client.LocalPlayerSide = nil
    
    -- Bildirim
    notification.AddLegacy("RAID BİTTİ!", NOTIFY_GENERIC, 5)
end)

net.Receive("PropHP_PropDestroyed", function()
    local pos = net.ReadVector()
    
    -- Yıkım efekti
    local emitter = ParticleEmitter(pos)
    if emitter then
        for i = 1, 30 do
            local part = emitter:Add("effects/spark", pos)
            if part then
                part:SetVelocity(VectorRand() * 300)
                part:SetDieTime(1.5)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(8)
                part:SetEndSize(0)
                part:SetColor(255, 100, 0)
                part:SetGravity(Vector(0, 0, -600))
            end
        end
        emitter:Finish()
    end
    
    -- Ses efekti
    sound.Play("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", pos, 80, 100)
end)

-- ============================
-- RAID GLOW SİSTEMİ (GERÇEK GLOW)
-- ============================
hook.Add("PreDrawHalos", "PropHP_RaidGlow", function()
    -- Config kontrolü
    if not PropHP or not PropHP.Config then return end
    if not PropHP.Config.Raid then return end
    if not PropHP.Config.Raid.UseRaidGlow then return end
    
    -- Raid durumu kontrolü
    if not PropHP_Client.RaidData and not PropHP_Client.LootingPhase then return end
    if not PropHP_Client.LocalPlayerSide then return end
    
    local teamPlayers = {}  -- Yeşil glow (takım arkadaşları)
    local enemyPlayers = {}  -- Kırmızı glow (düşmanlar)
    
    -- Oyuncuları kategorize et
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply != LocalPlayer() and ply:Alive() then
            local steamID = ply:SteamID64()
            
            -- Duvar arkası kontrolü (opsiyonel - performans için kapatılabilir)
            local trace = util.TraceLine({
                start = LocalPlayer():EyePos(),
                endpos = ply:EyePos(),
                filter = {LocalPlayer(), ply},
                mask = MASK_BLOCKLOS
            })
            
            -- Eğer duvar varsa glow gösterme
            if trace.Hit and trace.Entity != ply then
                continue
            end
            
            -- Takım arkadaşı mı?
            if PropHP_Client.LocalPlayerSide == "attacker" then
                if PropHP_Client.RaidParticipants.attackers[steamID] and PropHP_Client.RaidParticipants.attackers[steamID].alive then
                    table.insert(teamPlayers, ply)
                elseif PropHP_Client.RaidParticipants.defenders[steamID] and PropHP_Client.RaidParticipants.defenders[steamID].alive then
                    table.insert(enemyPlayers, ply)
                end
            elseif PropHP_Client.LocalPlayerSide == "defender" then
                if PropHP_Client.RaidParticipants.defenders[steamID] and PropHP_Client.RaidParticipants.defenders[steamID].alive then
                    table.insert(teamPlayers, ply)
                elseif PropHP_Client.RaidParticipants.attackers[steamID] and PropHP_Client.RaidParticipants.attackers[steamID].alive then
                    table.insert(enemyPlayers, ply)
                end
            end
        end
    end
    
    -- Takım arkadaşları - YEŞİL GLOW
    if #teamPlayers > 0 then
        local size = PropHP.Config.Raid.TeamGlowSize or 5
        local passes = PropHP.Config.Raid.TeamGlowPasses or 2
        local color = PropHP.Config.Raid.TeamGlowColor or Color(0, 255, 0, 255)
        
        halo.Add(
            teamPlayers,
            color,     -- Renk
            size,      -- Blur X genişliği
            size,      -- Blur Y yüksekliği  
            passes,    -- Pass sayısı (kalınlık)
            true,      -- Additive blend (parlak efekt)
            false      -- IgnoreZ false = duvar arkası görünmez
        )
    end
    
    -- Düşmanlar - KIRMIZI GLOW
    if #enemyPlayers > 0 then
        local size = PropHP.Config.Raid.EnemyGlowSize or 5
        local passes = PropHP.Config.Raid.EnemyGlowPasses or 2
        local color = PropHP.Config.Raid.EnemyGlowColor or Color(255, 0, 0, 255)
        
        halo.Add(
            enemyPlayers,
            color,     -- Renk
            size,      -- Blur X genişliği
            size,      -- Blur Y yüksekliği
            passes,    -- Pass sayısı (kalınlık)
            true,      -- Additive blend (parlak efekt)
            false      -- IgnoreZ false = duvar arkası görünmez
        )
    end
end)

-- Raid bitince parti halo'sunu geri aç
hook.Add("Think", "PropHP_RestorePartyHalo", function()
    if party and party.halos ~= nil then
        if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
            -- Raid sırasında parti halo'sunu kapat
            if party.halos == true then
                party.halos = false
            end
        else
            -- Raid bitince parti halo'sunu aç
            if party.halos == false then
                party.halos = true
            end
        end
    end
end)

-- Debug: Glow ayarlarını değiştir
concommand.Add("prophp_glow_size", function(ply, cmd, args)
    if not LocalPlayer():IsSuperAdmin() then return end
    
    local size = tonumber(args[1]) or 5
    if PropHP and PropHP.Config and PropHP.Config.Raid then
        PropHP.Config.Raid.TeamGlowSize = size
        PropHP.Config.Raid.EnemyGlowSize = size
        LocalPlayer():ChatPrint("Glow Size: " .. size)
    end
end)

concommand.Add("prophp_glow_passes", function(ply, cmd, args)
    if not LocalPlayer():IsSuperAdmin() then return end
    
    local passes = tonumber(args[1]) or 2
    if PropHP and PropHP.Config and PropHP.Config.Raid then
        PropHP.Config.Raid.TeamGlowPasses = passes
        PropHP.Config.Raid.EnemyGlowPasses = passes
        LocalPlayer():ChatPrint("Glow Passes: " .. passes)
    end
end)

-- ============================
-- HUD ÇİZİMİ
-- ============================
hook.Add("HUDPaint", "PropHP_DrawHUD", function()
    local ply = LocalPlayer()
    if not ply:GetParty() then return end
    
    -- HP Havuz göstergesi
    PropHP_DrawPoolInfo()
    
    -- Raid durumu
    if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
        PropHP_DrawRaidStatus()
        PropHP_DrawRaidScoreboard()  -- 5v5 Scoreboard
    end
    
    -- Prop HP göstergesi
    PropHP_DrawPropInfo()
    
    -- Hasar numaraları
    PropHP_DrawDamageNumbers()
end)

-- ============================
-- RAID SCOREBOARD (MİNİMAL TASARIM)
-- ============================
function PropHP_DrawRaidScoreboard()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    -- Sol üst - Saldıranlar
    local leftX = 20
    local leftY = 100
    local boxWidth = 200
    
    -- Saldıran başlık (arka plansız)
    draw.SimpleText("⚔️ SALDIRAN", "PropHP_Medium", leftX + boxWidth/2, leftY, Color(255, 100, 100), TEXT_ALIGN_CENTER)
    
    -- Saldıran oyuncular
    local attackerY = leftY + 25
    local attackerCount = 0
    local attackersAlive = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if attackerCount < 8 then  -- Maksimum 8 göster
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            if data.alive then
                attackersAlive = attackersAlive + 1
                color = Color(100, 255, 100)
                prefix = "●"  -- Yaşıyor
            else
                color = Color(255, 100, 100, 200)
                prefix = "○"  -- Ölü
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            -- Gölge efekti
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX + 2, attackerY + 1, Color(0, 0, 0, 150))
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX, attackerY, color)
            
            attackerY = attackerY + 20
            attackerCount = attackerCount + 1
        else
            attackersAlive = attackersAlive + (data.alive and 1 or 0)
        end
    end
    
    -- Saldıran sayısı
    draw.SimpleText("Yaşayan: " .. attackersAlive .. "/" .. table.Count(PropHP_Client.RaidParticipants.attackers), 
        "PropHP_Small", leftX + boxWidth/2, attackerY + 5, Color(255, 150, 150), TEXT_ALIGN_CENTER)
    
    -- Sağ üst - Savunanlar
    local rightX = ScrW() - 220
    local rightY = 100
    
    -- Savunan başlık (arka plansız)
    draw.SimpleText("🛡️ SAVUNAN", "PropHP_Medium", rightX + boxWidth/2, rightY, Color(100, 100, 255), TEXT_ALIGN_CENTER)
    
    -- Savunan oyuncular
    local defenderY = rightY + 25
    local defenderCount = 0
    local defendersAlive = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if defenderCount < 8 then  -- Maksimum 8 göster
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            if data.alive then
                defendersAlive = defendersAlive + 1
                color = Color(100, 255, 100)
                prefix = "●"  -- Yaşıyor
            else
                color = Color(255, 100, 100, 200)
                prefix = "○"  -- Ölü
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            -- Gölge efekti
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX + 2, defenderY + 1, Color(0, 0, 0, 150))
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX, defenderY, color)
            
            defenderY = defenderY + 20
            defenderCount = defenderCount + 1
        else
            defendersAlive = defendersAlive + (data.alive and 1 or 0)
        end
    end
    
    -- Savunan sayısı
    draw.SimpleText("Yaşayan: " .. defendersAlive .. "/" .. table.Count(PropHP_Client.RaidParticipants.defenders), 
        "PropHP_Small", rightX + boxWidth/2, defenderY + 5, Color(150, 150, 255), TEXT_ALIGN_CENTER)
    
    -- Orta üst - VS göstergesi (küçük ve şık)
    local centerX = ScrW()/2
    local centerY = 80
    
    -- VS yazısı - büyük ve belirgin
    local vsText = attackersAlive .. " VS " .. defendersAlive
    
    -- Gölge efekti
    draw.SimpleText(vsText, "PropHP_Large", centerX + 2, centerY + 2, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
    draw.SimpleText(vsText, "PropHP_Large", centerX, centerY, Color(255, 255, 0), TEXT_ALIGN_CENTER)
    
    -- Durum mesajı (altında)
    local statusText = ""
    local statusColor = Color(255, 255, 255)
    
    if PropHP_Client.LootingPhase then
        statusText = "💰 YAĞMA AŞAMASI"
        statusColor = Color(255, 215, 0)
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        statusText = "⏰ HAZIRLIK"
        statusColor = Color(255, 150, 0)
    else
        statusText = "⚔️ SAVAŞ"
        statusColor = Color(255, 100, 100)
    end
    
    draw.SimpleText(statusText, "PropHP_Medium", centerX + 1, centerY + 30 + 1, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
    draw.SimpleText(statusText, "PropHP_Medium", centerX, centerY + 30, statusColor, TEXT_ALIGN_CENTER)
    
    -- Kazanan durumu
    if attackersAlive == 0 and defendersAlive > 0 then
        local winText = "SAVUNANLAR KAZANIYOR!"
        draw.SimpleText(winText, "PropHP_Medium", centerX + 2, centerY + 55 + 2, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
        draw.SimpleText(winText, "PropHP_Medium", centerX, centerY + 55, Color(100, 100, 255), TEXT_ALIGN_CENTER)
    elseif defendersAlive == 0 and attackersAlive > 0 then
        local winText = "SALDIRAN KAZANIYOR!"
        draw.SimpleText(winText, "PropHP_Medium", centerX + 2, centerY + 55 + 2, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER)
        draw.SimpleText(winText, "PropHP_Medium", centerX, centerY + 55, Color(255, 100, 100), TEXT_ALIGN_CENTER)
    end
end

-- ============================
-- HP HAVUZ GÖSTERGESİ
-- ============================
function PropHP_DrawPoolInfo()
    local x = 10
    local y = ScrH() - 180
    local w = 280
    local h = 120
    
    -- Ana panel
    draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 200))
    draw.RoundedBoxEx(8, x, y, w, 30, Color(50, 50, 50, 255), true, true, false, false)
    
    -- Başlık
    draw.SimpleText("HP HAVUZU", "PropHP_Medium", x + w/2, y + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Bilgiler
    local infoY = y + 40
    
    -- Toplam havuz
    draw.SimpleText("Toplam Havuz:", "PropHP_Small", x + 10, infoY, Color(200, 200, 200))
    draw.SimpleText(string.Comma(PropHP_Client.PoolData.total) .. " HP", "PropHP_Small", x + w - 10, infoY, Color(0, 255, 0), TEXT_ALIGN_RIGHT)
    
    -- Toplam prop sayısı
    infoY = infoY + 20
    draw.SimpleText("Toplam Prop:", "PropHP_Small", x + 10, infoY, Color(200, 200, 200))
    draw.SimpleText(PropHP_Client.PoolData.propCount, "PropHP_Small", x + w - 10, infoY, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
    
    -- HP/Prop
    infoY = infoY + 20
    draw.SimpleText("HP/Prop:", "PropHP_Small", x + 10, infoY, Color(200, 200, 200))
    local hpColor = Color(255, 255, 255)
    if PropHP_Client.PoolData.hpPerProp < 10000 then
        hpColor = Color(255, 0, 0)
    elseif PropHP_Client.PoolData.hpPerProp < 50000 then
        hpColor = Color(255, 255, 0)
    else
        hpColor = Color(0, 255, 0)
    end
    draw.SimpleText(string.Comma(PropHP_Client.PoolData.hpPerProp), "PropHP_Small", x + w - 10, infoY, hpColor, TEXT_ALIGN_RIGHT)
    
    -- Yok edilen prop
    if PropHP_Client.PoolData.destroyed > 0 then
        infoY = infoY + 20
        draw.SimpleText("Yok Edilen:", "PropHP_Small", x + 10, infoY, Color(255, 100, 100))
        draw.SimpleText(PropHP_Client.PoolData.destroyed, "PropHP_Small", x + w - 10, infoY, Color(255, 100, 100), TEXT_ALIGN_RIGHT)
    end
end

-- ============================
-- RAID DURUMU
-- ============================
function PropHP_DrawRaidStatus()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    local w = 350
    local h = 80
    local x = ScrW()/2 - w/2
    local y = 20
    
    -- Arka plan rengi
    local bgColor
    if PropHP_Client.LootingPhase then
        bgColor = Color(255, 215, 0, 230)  -- Altın rengi (yağma)
        
        -- Yanıp sönen efekt
        local pulse = math.sin(CurTime() * 3) * 30
        bgColor.r = math.min(255, bgColor.r + pulse)
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        bgColor = Color(255, 150, 0, 230)  -- Turuncu (hazırlık)
    else
        bgColor = Color(255, 0, 0, 230)    -- Kırmızı (aktif raid)
    end
    
    draw.RoundedBox(8, x, y, w, h, bgColor)
    
    -- İç çerçeve
    draw.RoundedBox(6, x + 2, y + 2, w - 4, h - 4, Color(0, 0, 0, 150))
    
    -- Başlık
    local title
    if PropHP_Client.LootingPhase then
        title = "💰 YAĞMA AŞAMASI"
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        title = "⏰ HAZIRLIK AŞAMASI"
    else
        title = "⚔️ RAID AKTİF"
    end
    
    draw.SimpleText(title, "PropHP_Large", x + w/2, y + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer
    if PropHP_Client.RaidData and PropHP_Client.RaidData.timeLeft then
        local minutes = math.floor(PropHP_Client.RaidData.timeLeft / 60)
        local seconds = math.floor(PropHP_Client.RaidData.timeLeft % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        -- Timer arka plan
        draw.RoundedBox(4, x + w/2 - 50, y + 45, 100, 25, Color(0, 0, 0, 200))
        
        -- Renk (az zaman kaldıysa kırmızı)
        local timerColor = Color(255, 255, 255)
        if PropHP_Client.RaidData.timeLeft < 60 then
            timerColor = Color(255, 0, 0)
            -- Yanıp sönen efekt
            if math.floor(CurTime() * 2) % 2 == 0 then
                timerColor = Color(255, 255, 0)
            end
        elseif PropHP_Client.RaidData.timeLeft < 300 then
            timerColor = Color(255, 255, 0)
        end
        
        draw.SimpleText(timeText, "PropHP_Medium", x + w/2, y + 57, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- ============================
-- PROP BİLGİSİ
-- ============================
function PropHP_DrawPropInfo()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    
    if not IsValid(trace.Entity) then return end
    if trace.Entity:GetClass() != "prop_physics" then return end
    
    -- Partiye ait olmayan prop kontrolü
    if trace.Entity:GetNWBool("WaitingForParty", false) then
        local pos = trace.Entity:GetPos() + Vector(0, 0, 60)
        local screenPos = pos:ToScreen()
        
        if not screenPos.visible then return end
        
        -- Bilgi göster
        draw.SimpleText("⏳ PARTİ BEKLİYOR", "PropHP_Medium", screenPos.x + 1, screenPos.y + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("⏳ PARTİ BEKLİYOR", "PropHP_Medium", screenPos.x, screenPos.y, Color(255, 255, 100), TEXT_ALIGN_CENTER)
        
        draw.SimpleText("Parti kurulunca HP havuzuna eklenecek", "PropHP_Small", screenPos.x, screenPos.y + 20, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        
        -- Sahip
        local owner = trace.Entity:GetNWEntity("PropOwner")
        if IsValid(owner) then
            draw.SimpleText("Sahip: " .. owner:Nick(), "PropHP_Small", screenPos.x, screenPos.y + 35, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        end
        return
    end
    
    local propHP = trace.Entity:GetNWInt("PropHP", 0)
    local propMaxHP = trace.Entity:GetNWInt("PropMaxHP", 0)
    local isDestroyed = trace.Entity:GetNWBool("PropDestroyed", false)
    
    -- HP'si olmayan propları gösterme
    if propMaxHP <= 0 and not isDestroyed then return end
    
    local pos = trace.Entity:GetPos() + Vector(0, 0, 60)
    local screenPos = pos:ToScreen()
    
    if not screenPos.visible then return end
    
    -- Panel
    local w = 150
    local h = 60
    local x = screenPos.x - w/2
    local y = screenPos.y
    
    -- Arka plan (yok edilmişse farklı renk)
    local bgColor = isDestroyed and Color(100, 0, 0, 230) or Color(0, 0, 0, 230)
    draw.RoundedBox(6, x, y, w, h, bgColor)
    draw.RoundedBox(4, x + 2, y + 2, w - 4, h - 4, Color(30, 30, 30, 200))
    
    if isDestroyed then
        -- Ghost prop görünümü
        draw.SimpleText("👻 YOK EDİLDİ", "PropHP_Small", screenPos.x, y + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText("HP: 0/" .. string.Comma(propMaxHP), "PropHP_Small", screenPos.x, y + 25, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        
        -- Tamir ipucu
        if ply:GetParty() == trace.Entity:GetNWString("PropOwnerParty", "") then
            draw.SimpleText("(Raid sonunda tamir olacak)", "PropHP_Small", screenPos.x, y + 40, Color(100, 200, 100), TEXT_ALIGN_CENTER)
        end
    else
        -- Normal HP bar
        local barX = x + 10
        local barY = y + 25
        local barW = w - 20
        local barH = 12
        
        draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50, 255))
        
        local percent = propHP / propMaxHP
        local barColor
        if percent > 0.75 then
            barColor = Color(0, 255, 0)
        elseif percent > 0.25 then
            barColor = Color(255, 255, 0)
        else
            barColor = Color(255, 0, 0)
        end
        
        draw.RoundedBox(2, barX, barY, barW * percent, barH, barColor)
        
        -- HP Text
        draw.SimpleText("HP: " .. string.Comma(propHP) .. "/" .. string.Comma(propMaxHP), "PropHP_Small", screenPos.x, y + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
    
    -- Sahip
    local owner = trace.Entity:GetNWEntity("PropOwner")
    if IsValid(owner) then
        draw.SimpleText(owner:Nick(), "PropHP_Small", screenPos.x, y + 45, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    end
end

-- ============================
-- HASAR NUMARALARI
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
                -- Gölge
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
-- RAID MENÜSÜ
-- ============================
net.Receive("PropHP_OpenRaidMenu", function()
    if IsValid(PropHP_RaidMenu) then
        PropHP_RaidMenu:Remove()
    end
    
    PropHP_RaidMenu = vgui.Create("DFrame")
    PropHP_RaidMenu:SetSize(500, 600)
    PropHP_RaidMenu:Center()
    PropHP_RaidMenu:SetTitle("🎯 RAID MENÜSÜ")
    PropHP_RaidMenu:MakePopup()
    PropHP_RaidMenu:ShowCloseButton(true)
    
    PropHP_RaidMenu.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 25, Color(50, 50, 50, 255), true, true, false, false)
    end
    
    -- Parti listesi
    local list = vgui.Create("DListView", PropHP_RaidMenu)
    list:SetPos(10, 35)
    list:SetSize(480, 500)
    list:AddColumn("Parti Adı")
    list:AddColumn("Online")
    list:AddColumn("Prop")
    list:AddColumn("Durum")
    
    list.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 200))
    end
    
    -- Partileri listele
    if parties then
        for partyID, partyData in pairs(parties) do
            if partyID != LocalPlayer():GetParty() then
                local online = 0
                local alive = 0
                
                for _, steamID in pairs(partyData.members) do
                    local member = player.GetBySteamID64(steamID)
                    if IsValid(member) then
                        online = online + 1
                        if member:Alive() then
                            alive = alive + 1
                        end
                    end
                end
                
                local propCount = "?"
                local status = "Hazır"
                
                -- Durum kontrolü (raid'de mi?)
                local inRaid = false
                for _, activeParty in pairs(PropHP_Client.RaidParticipants) do
                    if activeParty[partyID] then
                        inRaid = true
                        status = "Raid'de"
                        break
                    end
                end
                
                local line = list:AddLine(
                    partyData.name, 
                    alive .. "/" .. online,
                    propCount, 
                    status
                )
                line.partyID = partyID
                
                -- Satır renklendirme
                if inRaid then
                    line.Paint = function(self, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(100, 0, 0, 100))
                    end
                elseif alive < PropHP.Config.Raid.MinPartyMembers then
                    line.Paint = function(self, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 0, 100))
                    end
                else
                    line.Paint = function(self, w, h)
                        if self:IsHovered() then
                            draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 0, 100))
                        end
                    end
                end
            end
        end
    end
    
    -- Raid başlat butonu
    local raidBtn = vgui.Create("DButton", PropHP_RaidMenu)
    raidBtn:SetPos(10, 545)
    raidBtn:SetSize(480, 45)
    raidBtn:SetText("⚔️ RAID BAŞLAT")
    raidBtn:SetFont("PropHP_Medium")
    
    raidBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and Color(200, 0, 0, 255) or Color(150, 0, 0, 255)
        draw.RoundedBox(4, 0, 0, w, h, color)
    end
    
    raidBtn.DoClick = function()
        local selected = list:GetSelectedLine()
        if selected then
            local line = list:GetLine(selected)
            if line and line.partyID then
                net.Start("PropHP_RaidRequest")
                    net.WriteString(line.partyID)
                net.SendToServer()
                PropHP_RaidMenu:Close()
            else
                notification.AddLegacy("Bir parti seçin!", NOTIFY_ERROR, 3)
            end
        else
            notification.AddLegacy("Bir parti seçin!", NOTIFY_ERROR, 3)
        end
    end
end)

-- ============================
-- DEBUG PANEL
-- ============================
concommand.Add("prophp_menu", function()
    if not LocalPlayer():IsSuperAdmin() then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 400)
    frame:Center()
    frame:SetTitle("PropHP Debug Panel")
    frame:MakePopup()
    
    local info = vgui.Create("RichText", frame)
    info:Dock(FILL)
    
    info:InsertColorChange(255, 255, 255, 255)
    info:AppendText("=== HP HAVUZ BİLGİSİ ===\n\n")
    
    info:InsertColorChange(0, 255, 0, 255)
    info:AppendText("Toplam Havuz: " .. string.Comma(PropHP_Client.PoolData.total) .. " HP\n")
    
    info:InsertColorChange(255, 255, 0, 255)
    info:AppendText("Prop Sayısı: " .. PropHP_Client.PoolData.propCount .. "\n")
    
    info:InsertColorChange(0, 255, 255, 255)
    info:AppendText("HP/Prop: " .. string.Comma(PropHP_Client.PoolData.hpPerProp) .. "\n")
    
    if PropHP_Client.PoolData.destroyed > 0 then
        info:InsertColorChange(255, 0, 0, 255)
        info:AppendText("Yok Edilen: " .. PropHP_Client.PoolData.destroyed .. "\n")
    end
    
    if PropHP_Client.RaidData then
        info:InsertColorChange(255, 255, 255, 255)
        info:AppendText("\n=== RAID DURUMU ===\n")
        
        if PropHP_Client.LootingPhase then
            info:InsertColorChange(255, 215, 0, 255)
            info:AppendText("Yağma Aşaması!\n")
        elseif PropHP_Client.RaidData.preparation then
            info:InsertColorChange(255, 150, 0, 255)
            info:AppendText("Hazırlık Aşaması\n")
        else
            info:InsertColorChange(255, 0, 0, 255)
            info:AppendText("Raid Aktif!\n")
        end
        
        if PropHP_Client.RaidData.timeLeft then
            info:InsertColorChange(255, 255, 255, 255)
            info:AppendText("Kalan Süre: " .. math.floor(PropHP_Client.RaidData.timeLeft) .. " saniye\n")
        end
    end
    
    -- Katılımcılar
    if PropHP_Client.RaidParticipants then
        info:InsertColorChange(255, 255, 255, 255)
        info:AppendText("\n=== RAID KATILIMCILARI ===\n")
        
        local attackerAlive = 0
        local defenderAlive = 0
        
        for _, data in pairs(PropHP_Client.RaidParticipants.attackers) do
            if data.alive then attackerAlive = attackerAlive + 1 end
        end
        
        for _, data in pairs(PropHP_Client.RaidParticipants.defenders) do
            if data.alive then defenderAlive = defenderAlive + 1 end
        end
        
        info:InsertColorChange(255, 100, 100, 255)
        info:AppendText("Saldıran: " .. attackerAlive .. " yaşıyor\n")
        
        info:InsertColorChange(100, 100, 255, 255)
        info:AppendText("Savunan: " .. defenderAlive .. " yaşıyor\n")
    end
    
    if PropHP_Client.LocalPlayerSide then
        info:InsertColorChange(0, 255, 0, 255)
        info:AppendText("\nSizin Taraf: " .. PropHP_Client.LocalPlayerSide .. "\n")
    end
end)