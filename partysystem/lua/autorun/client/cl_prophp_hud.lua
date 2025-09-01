-- Client Side HUD & Interface (EMOJILER VE TURKCE KARAKTERLER KALDIRILDI)
-- Dosya Yolu: lua/autorun/client/cl_prophp_hud.lua
-- HP Havuzu artik parti HUD'unda gosteriliyor
-- Versiyon: 2.6 NO EFFECTS

PropHP_Client = {
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
    size = 22,  -- 24'ten 22'ye düşürüldü
    weight = 800
})

surface.CreateFont("PropHP_Medium", {
    font = "Roboto",
    size = 16,  -- 18'den 16'ya düşürüldü
    weight = 600
})

surface.CreateFont("PropHP_Small", {
    font = "Roboto",
    size = 12,  -- 14'ten 12'ye düşürüldü
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
    size = 14,  -- 16'dan 14'e düşürüldü
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
        notification.AddLegacy("YAGMA ASAMASI BASLADI!", NOTIFY_GENERIC, 5)
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
        startTime = CurTime(),
        attackerParty = attackerParty,  -- YENİ
        defenderParty = defenderParty   -- YENİ
    }
    
    PropHP_Client.LootingPhase = false
    
    -- Bildirim
    if preparation then
        notification.AddLegacy("RAID HAZIRLANIYOR!", NOTIFY_ERROR, 5)
        notification.AddLegacy("Prop koyabilirsiniz!", NOTIFY_HINT, 3)
    else
        notification.AddLegacy("RAID BASLADI!", NOTIFY_ERROR, 5)
        notification.AddLegacy("Artik prop koyamazsiniz!", NOTIFY_ERROR, 3)
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
    if winner == "canceled" then
        notification.AddLegacy("RAID IPTAL EDILDI!", NOTIFY_ERROR, 5)
    else
        notification.AddLegacy("RAID BITTI!", NOTIFY_GENERIC, 5)
    end
end)

net.Receive("PropHP_PropDestroyed", function()
    local pos = net.ReadVector()
    
    -- EFEKTLER KALDIRILDI - ARTIK PARTİCLE YOK
    -- Sadece ses efekti kaldı
    
    -- Ses efekti
    sound.Play("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", pos, 80, 100)
end)

-- Raid iptal network receiver - YENİ
net.Receive("PropHP_CancelRaid", function()
    -- Client tarafında özel bir şey yapmaya gerek yok, server zaten RaidEnd gönderiyor
end)

-- ============================
-- RAID GLOW SISTEMI (GERCEK GLOW)
-- ============================
hook.Add("PreDrawHalos", "PropHP_RaidGlow", function()
    -- Config kontrolu
    if not PropHP or not PropHP.Config then return end
    if not PropHP.Config.Raid then return end
    if not PropHP.Config.Raid.UseRaidGlow then return end
    
    -- Raid durumu kontrolu
    if not PropHP_Client.RaidData and not PropHP_Client.LootingPhase then return end
    if not PropHP_Client.LocalPlayerSide then return end
    
    local teamPlayers = {}  -- Yesil glow (takim arkadaslari)
    local enemyPlayers = {}  -- Kirmizi glow (dusmanlar)
    
    -- Oyunculari kategorize et
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply != LocalPlayer() and ply:Alive() then
            local steamID = ply:SteamID64()
            
            -- Duvar arkasi kontrolu (opsiyonel - performans icin kapatilabilir)
            local trace = util.TraceLine({
                start = LocalPlayer():EyePos(),
                endpos = ply:EyePos(),
                filter = {LocalPlayer(), ply},
                mask = MASK_BLOCKLOS
            })
            
            -- Eger duvar varsa glow gosterme
            if trace.Hit and trace.Entity != ply then
                continue
            end
            
            -- Takim arkadasi mi?
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
    
    -- Takim arkadaslari - YESIL GLOW
    if #teamPlayers > 0 then
        local size = PropHP.Config.Raid.TeamGlowSize or 5
        local passes = PropHP.Config.Raid.TeamGlowPasses or 2
        local color = PropHP.Config.Raid.TeamGlowColor or Color(0, 255, 0, 255)
        
        halo.Add(
            teamPlayers,
            color,     -- Renk
            size,      -- Blur X genisligi
            size,      -- Blur Y yuksekligi  
            passes,    -- Pass sayisi (kalinlik)
            true,      -- Additive blend (parlak efekt)
            false      -- IgnoreZ false = duvar arkasi gorunmez
        )
    end
    
    -- Dusmanlar - KIRMIZI GLOW
    if #enemyPlayers > 0 then
        local size = PropHP.Config.Raid.EnemyGlowSize or 5
        local passes = PropHP.Config.Raid.EnemyGlowPasses or 2
        local color = PropHP.Config.Raid.EnemyGlowColor or Color(255, 0, 0, 255)
        
        halo.Add(
            enemyPlayers,
            color,     -- Renk
            size,      -- Blur X genisligi
            size,      -- Blur Y yuksekligi
            passes,    -- Pass sayisi (kalinlik)
            true,      -- Additive blend (parlak efekt)
            false      -- IgnoreZ false = duvar arkasi gorunmez
        )
    end
end)

-- Raid bitince parti halo'sunu geri ac
hook.Add("Think", "PropHP_RestorePartyHalo", function()
    if party and party.halos ~= nil then
        if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
            -- Raid sirasinda parti halo'sunu kapat
            if party.halos == true then
                party.halos = false
            end
        else
            -- Raid bitince parti halo'sunu ac
            if party.halos == false then
                party.halos = true
            end
        end
    end
end)

-- ============================
-- HUD CIZIMI
-- ============================
hook.Add("HUDPaint", "PropHP_DrawHUD", function()
    local ply = LocalPlayer()
    if not ply:GetParty() then return end
    
    -- HP Havuz gostergesi KALDIRILDI - Artik parti HUD'unda gosteriliyor
    -- PropHP_DrawPoolInfo() -- DEVRE DISI
    
    -- Raid durumu
    if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
        PropHP_DrawRaidStatus()
        PropHP_DrawRaidScoreboard()  -- 5v5 Scoreboard
    end
    
    -- Prop HP gostergesi
    PropHP_DrawPropInfo()
    
    -- Hasar numaralari
    PropHP_DrawDamageNumbers()
end)

-- ============================
-- HP HAVUZ GOSTERGESI - KALDIRILDI/BOS
-- ============================
function PropHP_DrawPoolInfo()
    -- Artik parti HUD'unda gosteriliyor, burada birsey cizmeye gerek yok
    return
end

-- ============================
-- RAID SCOREBOARD - PARTI MENUSU TEMASI ILE
-- ============================
function PropHP_DrawRaidScoreboard()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    -- Hazırlık aşamasında daha şeffaf renkler
    local isPrep = PropHP_Client.RaidData and PropHP_Client.RaidData.preparation
    
    -- Parti temasi renkleri - hazırlık için şeffaf
    local bgColor = isPrep and Color(50, 50, 50, 100) or (party.backgroundcolor or Color(50, 50, 50, 255))
    local innerBgColor = isPrep and Color(0, 0, 0, 50) or Color(0, 0, 0, 200)
    
    -- Sol ust - Saldiranlar
    local leftX = 15  -- 20'den 15'e düşürüldü
    local leftY = 95  -- 90'dan 95'e - ÜSTTEKI PANELE ÇARPMAMASI İÇİN
    local boxWidth = 160  -- 200'den 160'a düşürüldü
    local boxHeight = 160  -- 180'den 160'a düşürüldü
    
    -- Saldiran kutusu arka plan (parti menusu stili)
    draw.RoundedBox(5, leftX, leftY, boxWidth, boxHeight, bgColor)
    draw.RoundedBox(5, leftX + 3, leftY + 3, boxWidth - 6, boxHeight - 6, innerBgColor)
    
    -- Saldiran baslik - hazırlık için daha soft renk
    local attackerTitleColor = isPrep and Color(255, 200, 200) or Color(255, 100, 100)
    draw.SimpleText("SALDIRAN", "PropHP_Medium", leftX + 80, leftY + 8, attackerTitleColor, TEXT_ALIGN_CENTER)
    
    -- Saldiran oyuncular
    local attackerY = leftY + 30  -- 35'ten 30'a düşürüldü
    local attackerCount = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if attackerCount < 7 then  -- Maksimum 7 goster (8'den düşürüldü)
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            -- Su an yasiyor mu?
            if data.alive then
                color = isPrep and Color(100, 255, 100, 200) or Color(100, 255, 100)
                prefix = "[+]"  -- Yasiyor
            else
                color = isPrep and Color(255, 100, 100, 150) or Color(255, 100, 100, 200)
                prefix = "[X]"  -- Olu
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            -- Baslangicta oluyse
            if not data.initialAlive then
                prefix = "[-]"  -- Bastan olu
                color = isPrep and Color(150, 150, 150, 100) or Color(150, 150, 150, 150)
            end
            
            -- Golge efekti
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX + 6, attackerY + 1, Color(0, 0, 0, 150))  -- 7'den 6'ya
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", leftX + 4, attackerY, color)  -- 5'ten 4'e
            
            attackerY = attackerY + 18  -- 20'den 18'e düşürüldü
            attackerCount = attackerCount + 1
        end
    end
    
    -- Sag ust - Savunanlar
    local rightX = ScrW() - 175  -- 180'den 175'e düşürüldü (160 genişlik + 15 boşluk)
    local rightY = 95  -- 90'dan 95'e - ÜSTTEKI PANELE ÇARPMAMASI İÇİN
    
    -- Savunan kutusu arka plan (parti menusu stili)
    draw.RoundedBox(5, rightX, rightY, 160, 160, bgColor)  -- boxHeight 160'a düşürüldü
    draw.RoundedBox(5, rightX + 3, rightY + 3, 160 - 6, 160 - 6, innerBgColor)
    
    -- Savunan baslik - hazırlık için daha soft renk
    local defenderTitleColor = isPrep and Color(200, 200, 255) or Color(100, 100, 255)
    draw.SimpleText("SAVUNAN", "PropHP_Medium", rightX + 80, rightY + 8, defenderTitleColor, TEXT_ALIGN_CENTER)
    
    -- Savunan oyuncular
    local defenderY = rightY + 30  -- 35'ten 30'a düşürüldü
    local defenderCount = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if defenderCount < 7 then  -- Maksimum 7 goster (8'den düşürüldü)
            local color = Color(255, 255, 255)
            local prefix = ""
            local suffix = ""
            
            -- Su an yasiyor mu? (SAVUNANLAR)
            if data.alive then
                color = isPrep and Color(100, 255, 100, 200) or Color(100, 255, 100)
                prefix = "[+]"  -- Yasiyor
            else
                color = isPrep and Color(255, 100, 100, 150) or Color(255, 100, 100, 200)
                prefix = "[X]"  -- Olu
                if data.deaths and data.deaths > 0 then
                    suffix = " [NLR]"
                end
            end
            
            -- Baslangicta oluyse
            if not data.initialAlive then
                prefix = "[-]"  -- Bastan olu
                color = isPrep and Color(150, 150, 150, 100) or Color(150, 150, 150, 150)
            end
            
            -- Golge efekti
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX + 6, defenderY + 1, Color(0, 0, 0, 150))  -- 7'den 6'ya
            draw.SimpleText(prefix .. " " .. data.nick .. suffix, "PropHP_PlayerName", rightX + 4, defenderY, color)  -- 5'ten 4'e
            
            defenderY = defenderY + 18  -- 20'den 18'e düşürüldü
            defenderCount = defenderCount + 1
        end
    end
    
    -- Orta ust - VS gostergesi KALDIRILDI
    local centerX = ScrW()/2
    local centerY = 85  -- 70'ten 85'e - RAID DURUMU PANELİNE ÇARPMAMASI İÇİN
    
    -- Sadece yasayanlari say (scoreboard icin) - VERİ TOPLAMA DEVAM EDİYOR AMA GÖSTERİLMİYOR
    local attackersAlive = 0
    local defendersAlive = 0
    local attackersTotal = 0
    local defendersTotal = 0
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if data.initialAlive then
            attackersTotal = attackersTotal + 1
            if data.alive then
                attackersAlive = attackersAlive + 1
            end
        end
    end
    
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if data.initialAlive then
            defendersTotal = defendersTotal + 1
            if data.alive then
                defendersAlive = defendersAlive + 1
            end
        end
    end
    
    -- VS VE BAŞLANGIÇ SAYILARI KALDIRILDI
    
    -- Durum mesaji (raid durumu göstergesi) - ARTIK GÖSTERİLMİYOR, ÜSTTE ZATEN VAR
    
    -- Kazanan durumu - Sadece tüm takım öldüğünde göster
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

-- ============================
-- RAID DURUMU
-- ============================
function PropHP_DrawRaidStatus()
    if not (PropHP_Client.RaidData or PropHP_Client.LootingPhase) then return end
    
    local w = 200  -- 250'den 200'e - DAHA DA KÜÇÜK
    local h = 65   -- 70'den 65'e - DAHA KOMPAKT
    local x = ScrW()/2 - w/2  -- TAM ORTADA SABİT
    local y = 5    -- 10'dan 5'e - EN ÜSTTE
    
    -- Arka plan rengi
    local bgColor
    if PropHP_Client.LootingPhase then
        bgColor = Color(255, 215, 0, 230)  -- Altin rengi (yagma)
        
        -- Yanip sonen efekt
        local pulse = math.sin(CurTime() * 3) * 30
        bgColor.r = math.min(255, bgColor.r + pulse)
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        bgColor = Color(100, 100, 100, 40)  -- ÇOK ŞEFFAF - DAHA DA HAFİF
    else
        bgColor = Color(255, 0, 0, 200)    -- Kirmizi (aktif raid) - BİRAZ ŞEFFAF
    end
    
    draw.RoundedBox(6, x, y, w, h, bgColor)
    
    -- Ic cerceve - hazırlık için neredeyse yok
    local innerColor = (PropHP_Client.RaidData and PropHP_Client.RaidData.preparation) and Color(0, 0, 0, 20) or Color(0, 0, 0, 100)
    draw.RoundedBox(4, x + 2, y + 2, w - 4, h - 4, innerColor)
    
    -- Baslik
    local title
    if PropHP_Client.LootingPhase then
        title = "YAĞMA"  -- KISALTILDI
    elseif PropHP_Client.RaidData and PropHP_Client.RaidData.preparation then
        title = "HAZIRLIK"  -- KISALTILDI
    else
        title = "RAID"  -- KISALTILDI
    end
    
    -- Yazı rengi
    local titleColor = Color(255, 255, 255)
    
    -- Başlık YUKARDA - KESİNLİKLE AYRI
    draw.SimpleText(title, "PropHP_Small", x + w/2, y + 12, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer - AŞAĞIDA TAMAMEN AYRI
    if PropHP_Client.RaidData and PropHP_Client.RaidData.timeLeft then
        local minutes = math.floor(PropHP_Client.RaidData.timeLeft / 60)
        local seconds = math.floor(PropHP_Client.RaidData.timeLeft % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        -- Timer arka plan - MİNİMAL
        local timerBgColor = (PropHP_Client.RaidData and PropHP_Client.RaidData.preparation) and Color(0, 0, 0, 30) or Color(0, 0, 0, 150)
        draw.RoundedBox(3, x + w/2 - 35, y + 32, 70, 20, timerBgColor)  -- Daha küçük
        
        -- Renk (az zaman kaldiysa kirmizi)
        local timerColor = Color(255, 255, 255)
        if PropHP_Client.RaidData.timeLeft < 60 then
            timerColor = Color(255, 100, 100)
            -- Yanip sonen efekt
            if math.floor(CurTime() * 2) % 2 == 0 then
                timerColor = Color(255, 255, 0)
            end
        elseif PropHP_Client.RaidData.timeLeft < 300 then
            timerColor = Color(255, 255, 0)
        end
        
        -- Timer yazısı - NET AYRI
        draw.SimpleText(timeText, "PropHP_Small", x + w/2, y + 42, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Eğer yağma aşamasındaysa altına ek bilgi
    if PropHP_Client.LootingPhase then
        draw.SimpleText("TOPLANIYOR", "PropHP_Small", x + w/2, y + 55, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- ============================
-- PROP BILGISI
-- ============================
function PropHP_DrawPropInfo()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    
    if not IsValid(trace.Entity) then return end
    if trace.Entity:GetClass() != "prop_physics" then return end
    
    -- Partiye ait olmayan prop kontrolu
    if trace.Entity:GetNWBool("WaitingForParty", false) then
        local pos = trace.Entity:GetPos() + Vector(0, 0, 60)
        local screenPos = pos:ToScreen()
        
        if not screenPos.visible then return end
        
        -- Bilgi goster
        draw.SimpleText("PARTI BEKLIYOR", "PropHP_Medium", screenPos.x + 1, screenPos.y + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("PARTI BEKLIYOR", "PropHP_Medium", screenPos.x, screenPos.y, Color(255, 255, 100), TEXT_ALIGN_CENTER)
        
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
    
    -- HP'si olmayan proplari gosterme
    if propMaxHP <= 0 and not isDestroyed then return end
    
    local pos = trace.Entity:GetPos() + Vector(0, 0, 60)
    local screenPos = pos:ToScreen()
    
    if not screenPos.visible then return end
    
    -- Panel
    local w = 150
    local h = 60
    local x = screenPos.x - w/2
    local y = screenPos.y
    
    -- Arka plan (yok edilmisse farkli renk)
    local bgColor = isDestroyed and Color(100, 0, 0, 230) or Color(0, 0, 0, 230)
    draw.RoundedBox(6, x, y, w, h, bgColor)
    draw.RoundedBox(4, x + 2, y + 2, w - 4, h - 4, Color(30, 30, 30, 200))
    
    if isDestroyed then
        -- Ghost prop gorunumu
        draw.SimpleText("YOK EDILDI", "PropHP_Small", screenPos.x, y + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
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
-- RAID MENUSU
-- ============================
net.Receive("PropHP_OpenRaidMenu", function()
    if IsValid(PropHP_RaidMenu) then
        PropHP_RaidMenu:Remove()
    end
    
    PropHP_RaidMenu = vgui.Create("DFrame")
    PropHP_RaidMenu:SetSize(500, 650)  -- Yükseklik artırıldı
    PropHP_RaidMenu:Center()
    PropHP_RaidMenu:SetTitle("RAID MENUSU")
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
    list:AddColumn("Parti Adi")
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
                local status = "Hazir"
                
                -- Durum kontrolu (raid'de mi?)
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
                
                -- Satir renklendirme
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
    
    -- Aktif raid kontrolü - Saldıran mıyız?
    local isAttacker = false
    local hasActiveRaid = false
    
    if PropHP_Client.RaidData or PropHP_Client.LootingPhase then
        hasActiveRaid = true
        -- LocalPlayer saldıran tarafta mı?
        if PropHP_Client.LocalPlayerSide == "attacker" and LocalPlayer():GetParty() == LocalPlayer():SteamID64() then
            isAttacker = true  -- Hem saldıran hem de parti lideri
        end
    end
    
    -- Raid baslat butonu
    local raidBtn = vgui.Create("DButton", PropHP_RaidMenu)
    raidBtn:SetPos(10, 545)
    raidBtn:SetSize(hasActiveRaid and isAttacker and 235 or 480, 45)  -- Eğer raid iptali varsa yarı genişlik
    raidBtn:SetText("RAID BASLAT")
    raidBtn:SetFont("PropHP_Medium")
    raidBtn:SetEnabled(not hasActiveRaid)  -- Aktif raid varsa devre dışı
    
    raidBtn.Paint = function(self, w, h)
        local color
        if not self:IsEnabled() then
            color = Color(100, 100, 100, 255)  -- Gri (devre dışı)
        else
            color = self:IsHovered() and Color(200, 0, 0, 255) or Color(150, 0, 0, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, color)
    end
    
    raidBtn.DoClick = function()
        if not raidBtn:IsEnabled() then
            notification.AddLegacy("Zaten aktif bir raid var!", NOTIFY_ERROR, 3)
            return
        end
        
        local selected = list:GetSelectedLine()
        if selected then
            local line = list:GetLine(selected)
            if line and line.partyID then
                net.Start("PropHP_RaidRequest")
                    net.WriteString(line.partyID)
                net.SendToServer()
                PropHP_RaidMenu:Close()
            else
                notification.AddLegacy("Bir parti secin!", NOTIFY_ERROR, 3)
            end
        else
            notification.AddLegacy("Bir parti secin!", NOTIFY_ERROR, 3)
        end
    end
    
    -- RAID İPTAL BUTONU - YENİ
    if hasActiveRaid and isAttacker then
        local cancelBtn = vgui.Create("DButton", PropHP_RaidMenu)
        cancelBtn:SetPos(255, 545)  -- Sağ tarafa
        cancelBtn:SetSize(235, 45)
        cancelBtn:SetText("RAID IPTAL ET")
        cancelBtn:SetFont("PropHP_Medium")
        
        cancelBtn.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(255, 100, 0, 255) or Color(200, 100, 0, 255)  -- Turuncu
            draw.RoundedBox(4, 0, 0, w, h, color)
        end
        
        cancelBtn.DoClick = function()
            -- Onay penceresi
            Derma_Query(
                "Raid'i iptal etmek istediginizden emin misiniz?\nBu islemi geri alamazsiniz!",
                "Raid Iptal Onay",
                "Evet, Iptal Et",
                function()
                    net.Start("PropHP_CancelRaid")
                    net.SendToServer()
                    PropHP_RaidMenu:Close()
                    notification.AddLegacy("Raid iptal istegi gonderildi!", NOTIFY_HINT, 3)
                end,
                "Hayir",
                function() end
            )
        end
    end
    
    -- Bilgi metni - YENİ
    if hasActiveRaid then
        local infoText = vgui.Create("DLabel", PropHP_RaidMenu)
        infoText:SetPos(10, 595)
        infoText:SetSize(480, 20)
        infoText:SetFont("PropHP_Small")
        
        if isAttacker then
            infoText:SetText("💡 Aktif raid var - Saldiran parti lideri olarak iptal edebilirsiniz")
            infoText:SetTextColor(Color(255, 200, 0))
        else
            infoText:SetText("⚠️ Aktif raid var - Yeni raid baslatamazsiniz")
            infoText:SetTextColor(Color(255, 100, 100))
        end
    end
end)