-- Client Side HUD & Interface
-- Dosya Yolu: lua/autorun/client/cl_prophp_hud.lua

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
    LootingPhase = false
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
end)

net.Receive("PropHP_LootingPhase", function()
    PropHP_Client.LootingPhase = net.ReadBool()
    
    if PropHP_Client.LootingPhase then
        notification.AddLegacy("💰 YAĞMA AŞAMASI BAŞLADI!", NOTIFY_GENERIC, 5)
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
        PropHP_Client.RaidData.active = not isPrep
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
    
    -- Bildirim
    notification.AddLegacy("RAID BİTTİ!", NOTIFY_GENERIC, 5)
end)

net.Receive("PropHP_PropDestroyed", function()
    local pos = net.ReadVector()
    
    -- Yıkım efekti için pozisyon sakla
    local emitter = ParticleEmitter(pos)
    if emitter then
        for i = 1, 20 do
            local part = emitter:Add("effects/spark", pos)
            if part then
                part:SetVelocity(VectorRand() * 200)
                part:SetDieTime(1)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(5)
                part:SetEndSize(0)
                part:SetColor(255, 100, 0)
            end
        end
        emitter:Finish()
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
    if PropHP_Client.RaidData then
        PropHP_DrawRaidStatus()
        PropHP_DrawRaidScoreboard()  -- Yeni scoreboard
    end
    
    -- Prop HP göstergesi
    PropHP_DrawPropInfo()
    
    -- Hasar numaraları
    PropHP_DrawDamageNumbers()
end)

-- ============================
-- RAID SCOREBOARD (5v5 GÖSTERGESİ)
-- ============================
function PropHP_DrawRaidScoreboard()
    if not PropHP_Client.RaidData then return end
    
    -- Sadece raid aktifken veya yağma aşamasında göster
    if not (PropHP_Client.RaidData.active or PropHP_Client.LootingPhase) then return end
    
    local w = 600
    local h = 250
    local x = ScrW()/2 - w/2
    local y = 120
    
    -- Ana panel
    draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 230))
    draw.RoundedBox(6, x + 2, y + 2, w - 4, h - 4, Color(30, 30, 30, 200))
    
    -- Başlık
    local title = PropHP_Client.LootingPhase and "💰 YAĞMA AŞAMASI" or "⚔️ RAID SAVAŞI"
    draw.SimpleText(title, "PropHP_Scoreboard", x + w/2, y + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    
    -- Skor hesapla
    local attackersAlive = 0
    local defendersAlive = 0
    
    for _, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        if data.alive then attackersAlive = attackersAlive + 1 end
    end
    
    for _, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        if data.alive then defendersAlive = defendersAlive + 1 end
    end
    
    -- VS göstergesi
    local vsText = attackersAlive .. " VS " .. defendersAlive
    draw.SimpleText(vsText, "PropHP_Large", x + w/2, y + 45, Color(255, 255, 0), TEXT_ALIGN_CENTER)
    
    -- Sol taraf - Saldıranlar
    local leftX = x + 10
    local leftY = y + 75
    
    draw.RoundedBox(4, leftX, leftY, (w/2) - 20, 160, Color(150, 0, 0, 100))
    draw.SimpleText("SALDIRAN", "PropHP_Medium", leftX + ((w/2) - 20)/2, leftY + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
    
    -- Saldıran oyuncular
    local attackerY = leftY + 35
    for steamID, data in pairs(PropHP_Client.RaidParticipants.attackers) do
        local color = data.alive and Color(0, 255, 0) or Color(255, 0, 0)
        local prefix = data.alive and "✓" or "✗"
        draw.SimpleText(prefix .. " " .. data.nick, "PropHP_PlayerName", leftX + 10, attackerY, color)
        attackerY = attackerY + 20
    end
    
    -- Sağ taraf - Savunanlar
    local rightX = x + (w/2) + 10
    local rightY = y + 75
    
    draw.RoundedBox(4, rightX, rightY, (w/2) - 20, 160, Color(0, 0, 150, 100))
    draw.SimpleText("SAVUNAN", "PropHP_Medium", rightX + ((w/2) - 20)/2, rightY + 10, Color(100, 100, 255), TEXT_ALIGN_CENTER)
    
    -- Savunan oyuncular
    local defenderY = rightY + 35
    for steamID, data in pairs(PropHP_Client.RaidParticipants.defenders) do
        local color = data.alive and Color(0, 255, 0) or Color(255, 0, 0)
        local prefix = data.alive and "✓" or "✗"
        draw.SimpleText(prefix .. " " .. data.nick, "PropHP_PlayerName", rightX + 10, defenderY, color)
        defenderY = defenderY + 20
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
    
    -- Toplam prop sayısı (ghost dahil)
    infoY = infoY + 20
    draw.SimpleText("Toplam Prop:", "PropHP_Small", x + 10, infoY, Color(200, 200, 200))
    draw.SimpleText(PropHP_Client.PoolData.propCount, "PropHP_Small", x + w - 10, infoY, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
    
    -- HP/Prop (artık TÜM prop'lar baz alınıyor)
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
    if not PropHP_Client.RaidData then return end
    
    local w = 350
    local h = 80
    local x = ScrW()/2 - w/2
    local y = 20
    
    -- Arka plan
    local bgColor
    if PropHP_Client.LootingPhase then
        bgColor = Color(255, 215, 0, 230)  -- Altın rengi (yağma)
    elseif PropHP_Client.RaidData.preparation then
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
    elseif PropHP_Client.RaidData.preparation then
        title = "⏰ HAZIRLIK AŞAMASI"
    else
        title = "⚔️ RAID AKTİF"
    end
    
    draw.SimpleText(title, "PropHP_Large", x + w/2, y + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer
    if PropHP_Client.RaidData.timeLeft then
        local minutes = math.floor(PropHP_Client.RaidData.timeLeft / 60)
        local seconds = math.floor(PropHP_Client.RaidData.timeLeft % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        -- Timer arka plan
        draw.RoundedBox(4, x + w/2 - 50, y + 45, 100, 25, Color(0, 0, 0, 200))
        draw.SimpleText(timeText, "PropHP_Medium", x + w/2, y + 57, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    
    local propHP = trace.Entity:GetNWInt("PropHP", 0)
    local propMaxHP = trace.Entity:GetNWInt("PropMaxHP", 0)
    local isDestroyed = trace.Entity:GetNWBool("PropDestroyed", false)
    
    -- Yok edilmiş veya HP'si olmayan propları gösterme mantığını değiştir
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
    
    -- HP Bar
    local barX = x + 10
    local barY = y + 25
    local barW = w - 20
    local barH = 12
    
    draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50, 255))
    
    if isDestroyed then
        -- Yok edilmiş prop için özel görünüm
        draw.SimpleText("YOK EDİLDİ", "PropHP_Small", screenPos.x, y + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText("HP: 0/" .. string.Comma(propMaxHP), "PropHP_Small", screenPos.x, y + 30, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    else
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
                for _, steamID in pairs(partyData.members) do
                    if IsValid(player.GetBySteamID64(steamID)) then
                        online = online + 1
                    end
                end
                
                local propCount = "?"
                local status = "Hazır"
                
                if PropHP.PartyData and PropHP.PartyData[partyID] then
                    if PropHP.PartyData[partyID].props then
                        propCount = #PropHP.PartyData[partyID].props
                    end
                    if PropHP.PartyData[partyID].raidStatus then
                        status = "Meşgul"
                    end
                end
                
                local line = list:AddLine(partyData.name, online, propCount, status)
                line.partyID = partyID
                
                -- Satır renklendirme
                if status == "Meşgul" then
                    line.Paint = function(self, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(100, 0, 0, 100))
                    end
                elseif online < PropHP.Config.Raid.MinPartyMembers then
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
    frame:SetSize(400, 300)
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
        
        if PropHP_Client.RaidData.preparation then
            info:InsertColorChange(255, 150, 0, 255)
            info:AppendText("Hazırlık Aşaması\n")
        else
            info:InsertColorChange(255, 0, 0, 255)
            info:AppendText("Raid Aktif!\n")
        end
        
        info:InsertColorChange(255, 255, 255, 255)
        info:AppendText("Kalan Süre: " .. math.floor(PropHP_Client.RaidData.timeLeft) .. " saniye\n")
    end
end)-- Client Side HUD & Interface
-- Dosya Yolu: lua/autorun/client/cl_prophp_hud.lua

local PropHP_Client = {
    PoolData = {
        total = 0,
        propCount = 0,
        hpPerProp = 0,
        destroyed = 0
    },
    RaidData = nil,
    DamageNumbers = {}
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
        PropHP_Client.RaidData.active = not isPrep
    end
end)

net.Receive("PropHP_RaidEnd", function()
    local winner = net.ReadString()
    local winnerParty = net.ReadString()
    local loserParty = net.ReadString()
    
    PropHP_Client.RaidData = nil
    
    -- Bildirim
    notification.AddLegacy("RAID BİTTİ!", NOTIFY_GENERIC, 5)
end)

net.Receive("PropHP_PropDestroyed", function()
    local pos = net.ReadVector()
    
    -- Yıkım efekti için pozisyon sakla
    local emitter = ParticleEmitter(pos)
    if emitter then
        for i = 1, 20 do
            local part = emitter:Add("effects/spark", pos)
            if part then
                part:SetVelocity(VectorRand() * 200)
                part:SetDieTime(1)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(5)
                part:SetEndSize(0)
                part:SetColor(255, 100, 0)
            end
        end
        emitter:Finish()
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
    if PropHP_Client.RaidData then
        PropHP_DrawRaidStatus()
    end
    
    -- Prop HP göstergesi
    PropHP_DrawPropInfo()
    
    -- Hasar numaraları
    PropHP_DrawDamageNumbers()
end)

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
    
    -- Toplam prop sayısı (ghost dahil)
    infoY = infoY + 20
    draw.SimpleText("Toplam Prop:", "PropHP_Small", x + 10, infoY, Color(200, 200, 200))
    draw.SimpleText(PropHP_Client.PoolData.propCount, "PropHP_Small", x + w - 10, infoY, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
    
    -- HP/Prop (artık TÜM prop'lar baz alınıyor)
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
    if not PropHP_Client.RaidData then return end
    
    local w = 350
    local h = 80
    local x = ScrW()/2 - w/2
    local y = 100
    
    -- Arka plan
    local bgColor = PropHP_Client.RaidData.preparation and Color(255, 150, 0, 230) or Color(255, 0, 0, 230)
    draw.RoundedBox(8, x, y, w, h, bgColor)
    
    -- İç çerçeve
    draw.RoundedBox(6, x + 2, y + 2, w - 4, h - 4, Color(0, 0, 0, 150))
    
    -- Başlık
    local title = PropHP_Client.RaidData.preparation and "⏰ HAZIRLIK AŞAMASI" or "⚔️ RAID AKTİF"
    draw.SimpleText(title, "PropHP_Large", x + w/2, y + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer
    if PropHP_Client.RaidData.timeLeft then
        local minutes = math.floor(PropHP_Client.RaidData.timeLeft / 60)
        local seconds = math.floor(PropHP_Client.RaidData.timeLeft % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        -- Timer arka plan
        draw.RoundedBox(4, x + w/2 - 50, y + 45, 100, 25, Color(0, 0, 0, 200))
        draw.SimpleText(timeText, "PropHP_Medium", x + w/2, y + 57, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
    
    local propHP = trace.Entity:GetNWInt("PropHP", 0)
    local propMaxHP = trace.Entity:GetNWInt("PropMaxHP", 0)
    local isDestroyed = trace.Entity:GetNWBool("PropDestroyed", false)
    
    -- Yok edilmiş veya HP'si olmayan propları gösterme mantığını değiştir
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
    
    -- HP Bar
    local barX = x + 10
    local barY = y + 25
    local barW = w - 20
    local barH = 12
    
    draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50, 255))
    
    if isDestroyed then
        -- Yok edilmiş prop için özel görünüm
        draw.SimpleText("YOK EDİLDİ", "PropHP_Small", screenPos.x, y + 10, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        draw.SimpleText("HP: 0/" .. string.Comma(propMaxHP), "PropHP_Small", screenPos.x, y + 30, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    else
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
                for _, steamID in pairs(partyData.members) do
                    if IsValid(player.GetBySteamID64(steamID)) then
                        online = online + 1
                    end
                end
                
                local propCount = "?"
                local status = "Hazır"
                
                if PropHP.PartyData and PropHP.PartyData[partyID] then
                    if PropHP.PartyData[partyID].props then
                        propCount = #PropHP.PartyData[partyID].props
                    end
                    if PropHP.PartyData[partyID].raidStatus then
                        status = "Meşgul"
                    end
                end
                
                local line = list:AddLine(partyData.name, online, propCount, status)
                line.partyID = partyID
                
                -- Satır renklendirme
                if status == "Meşgul" then
                    line.Paint = function(self, w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(100, 0, 0, 100))
                    end
                elseif online < PropHP.Config.Raid.MinPartyMembers then
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
    frame:SetSize(400, 300)
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
        
        if PropHP_Client.RaidData.preparation then
            info:InsertColorChange(255, 150, 0, 255)
            info:AppendText("Hazırlık Aşaması\n")
        else
            info:InsertColorChange(255, 0, 0, 255)
            info:AppendText("Raid Aktif!\n")
        end
        
        info:InsertColorChange(255, 255, 255, 255)
        info:AppendText("Kalan Süre: " .. math.floor(PropHP_Client.RaidData.timeLeft) .. " saniye\n")
    end
end)