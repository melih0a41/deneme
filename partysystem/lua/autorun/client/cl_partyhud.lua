-- GUI base created by billy - OPTIMIZE EDILDI
-- Dosya: lua/autorun/client/cl_partyhud.lua
-- Versiyon: 3.0 - Performans optimizasyonları

local Party = {}
local disconnectedicon = "icon16/disconnect.png"
local leadericon = "icon16/award_star_gold_1.png"
local wantedicon = "icon16/exclamation.png"

-- HUD Cache sistemi (performans için)
local HUDCache = {
    lastUpdate = 0,
    updateRate = 0.1, -- Her 0.1 saniyede bir güncelle
    partyData = nil,
    memberData = {},
    needsUpdate = true
}

-- HUD pozisyonunu sol orta kisma sabitle
party.hudverticalpos = ScrH() / 2 - 100
party.hudhorizontalpos = 10

surface.CreateFont("roboto16", {
    size = 16,
    font = "Roboto",
})

party.DisplayParty = party.DisplayParty or true

-- Safe text fonksiyonu
local function safeText(text)
    if not text then return "" end
    text = tostring(text)
    if string.match(text, "^#([a-zA-Z_]+)$") then
        return text .. " "
    end
    return text
end

-- DrawNonParsedText fonksiyonu
if not draw.DrawNonParsedText then
    draw.DrawNonParsedText = function(text, font, x, y, color, xAlign)
        return draw.DrawText(safeText(text), font, x, y, color, xAlign)
    end
end

-- Hook temizleme fonksiyonu
local function CleanupPartyHooks()
    hook.Remove("Think", "PartyHUDContextCheck")
    hook.Remove("Think", "Partykeylistener")
end

-- Baslangicta problematik hook'lari temizle
CleanupPartyHooks()

-- ============================
-- PARTİ SÜRE GÖSTERGE SİSTEMİ - YENİ
-- ============================
local PartyLeaveTime = {
    canLeaveAt = 0,
    lastUpdate = 0
}

-- Network receiver - süre bilgisi
net.Receive("PartyLeaveTimeInfo", function()
    PartyLeaveTime.canLeaveAt = net.ReadFloat()
    PartyLeaveTime.lastUpdate = CurTime()
end)

-- ============================
-- CACHE GÜNCELLEME FONKSİYONU
-- ============================
local function UpdateHUDCache()
    if not LocalPlayer():GetParty() then 
        HUDCache.partyData = nil
        return 
    end
    
    if not parties or not parties[LocalPlayer():GetParty()] then
        HUDCache.partyData = nil
        return
    end
    
    local partyData = parties[LocalPlayer():GetParty()]
    
    HUDCache.partyData = {
        name = partyData.name,
        members = {}
    }
    
    HUDCache.memberData = {} -- Reset member data
    
    -- Üye verilerini cache'le
    for v, k in pairs(partyData.members) do
        local member = player.GetBySteamID64(k)
        local memberCache = {
            steamID = k,
            position = v,
            valid = IsValid(member)
        }
        
        if memberCache.valid then
            memberCache.nick = string.Left(member:Nick(), 18)
            memberCache.health = member:Health()
            memberCache.maxHealth = member:GetMaxHealth()
            memberCache.armor = member:Armor()
            memberCache.alive = member:Alive()
            memberCache.wanted = DarkRP and member.isWanted and member:isWanted() or false
            memberCache.job = DarkRP and member.getDarkRPVar and member:getDarkRPVar("job") or ""
            memberCache.team = member:Team()
        end
        
        table.insert(HUDCache.memberData, memberCache)
    end
    
    HUDCache.lastUpdate = CurTime()
    HUDCache.needsUpdate = false
end

-- ============================
-- ANA HUD CIZIM FONKSIYONU - OPTIMIZE EDILDI
-- ============================
hook.Add("HUDPaint", "drawpartyhud", function()
    if GetConVar("party_showhud"):GetInt() == 1 then return end -- HUD kapalıysa gösterme
    
    -- Cache kontrolü
    if CurTime() - HUDCache.lastUpdate > HUDCache.updateRate or HUDCache.needsUpdate then
        UpdateHUDCache()
    end
    
    if not HUDCache.partyData then return end
    
    -- HUD pozisyonunu otomatik guncelle (cozunurluk degisirse)
    party.hudverticalpos = ScrH() / 2 - 100
    party.hudhorizontalpos = 10
    
    -- HUD cizimi
    draw.DrawText(party.language["Party Name"] .. ": " .. HUDCache.partyData.name, "roboto16", 
        party.hudhorizontalpos, party.hudverticalpos, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    
    -- Uye listesi
    local lastMemberY = party.hudverticalpos
    
    for idx, memberCache in ipairs(HUDCache.memberData) do
        local position = memberCache.position * 55 - 30 + memberCache.position * 5 + party.hudverticalpos
        lastMemberY = position + 55
        
        -- Arka plan
        draw.RoundedBox(5, party.hudhorizontalpos, position, 150, 55, party.backgroundcolor)
        draw.RoundedBox(5, 3 + party.hudhorizontalpos, position + 3, 150 - 6, 55 - 6, Color(0, 0, 0, 200))
        
        if memberCache.valid then
            -- HP ve Armor bar
            local healthPercent = math.Clamp(100 * (memberCache.health / memberCache.maxHealth), 0, 100)
            local armorPercent = math.Clamp(memberCache.armor, 0, 100)
            
            draw.RoundedBoxEx(0, 5 + party.hudhorizontalpos, position + 45, 2.1 * healthPercent / 1.5, 5, 
                Color(200, 25, 25, 255), true, true, true, true)
            draw.RoundedBoxEx(0, 5 + party.hudhorizontalpos, position + 48, 2.1 * armorPercent / 1.5, 3, 
                Color(25, 25, 200, 255), true, true, true, true)
            
            -- İsim
            draw.DrawText(memberCache.nick, "roboto16", 5 + party.hudhorizontalpos, position + 5, 
                Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            
            -- HP Text
            if memberCache.alive then
                draw.DrawText(memberCache.health .. "/" .. memberCache.maxHealth, "roboto16", 
                    5 + party.hudhorizontalpos, position + 25, Color(255, 255, 255, 255), 
                    TEXT_ALIGN_LEFT)
            else
                draw.DrawText(party.language["Dead"], "roboto16", 5 + party.hudhorizontalpos, 
                    position + 25, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            end
            
            -- Job (DarkRP)
            if DarkRP and memberCache.job and memberCache.job ~= "" then
                local jobText = string.len(memberCache.job) >= 15 and 
                    string.Left(memberCache.job, 13) .. ".." or 
                    string.Left(memberCache.job, 16)
                
                draw.DrawText(jobText, "roboto16", 145 + party.hudhorizontalpos, position + 25, 
                    team.GetColor(memberCache.team), TEXT_ALIGN_RIGHT)
            end
            
            -- Wanted icon (DarkRP)
            if DarkRP then
                surface.SetMaterial(Material(wantedicon))
                if memberCache.wanted then
                    surface.SetDrawColor(255, 255, 255, 255)
                else
                    surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount or 50)
                end
                surface.DrawTexturedRect(155 + party.hudhorizontalpos, position + 34, 16, 16)
            end
            
            -- Disconnect icon
            surface.SetMaterial(Material(disconnectedicon))
            surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount or 50)
            surface.DrawTexturedRect(155 + party.hudhorizontalpos, position + 16, 16, 16)
        else
            -- Offline üye
            draw.DrawText(party.language["offline"], "roboto16", 5 + party.hudhorizontalpos, 
                position + 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
            
            -- Disconnect icon
            surface.SetMaterial(Material(disconnectedicon))
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(155 + party.hudhorizontalpos, position + 16, 16, 16)
        end
        
        -- Leader icon
        surface.SetMaterial(Material(leadericon))
        if memberCache.steamID == LocalPlayer():GetParty() then
            surface.SetDrawColor(255, 255, 255, 255)
        else
            surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount or 50)
        end
        surface.DrawTexturedRect(155 + party.hudhorizontalpos, position + 0, 16, 16)
    end
    
    -- ============================
    -- HP HAVUZU BILGISI - OPTIMIZE EDILDI
    -- ============================
    if PropHP and PropHP_Client and PropHP_Client.PoolData and PropHP_Client.PoolData.cached then
        local hpPanelY = lastMemberY + 10
        local hpPanelHeight = 80
        
        -- HP Havuzu arka plani
        draw.RoundedBox(5, party.hudhorizontalpos, hpPanelY, 150, hpPanelHeight, party.backgroundcolor)
        draw.RoundedBox(5, 3 + party.hudhorizontalpos, hpPanelY + 3, 150 - 6, hpPanelHeight - 6, Color(0, 0, 0, 200))
        
        -- HP HAVUZU basligi
        draw.DrawText("HP HAVUZU", "roboto16", party.hudhorizontalpos + 75, hpPanelY + 5, 
            Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Toplam Havuz
        local totalHP = PropHP_Client.PoolData.total
        local displayHP = "0 HP"
        if totalHP > 0 then
            if totalHP >= 1000000 then
                displayHP = string.format("%.1fM", totalHP / 1000000)
            elseif totalHP >= 1000 then
                displayHP = string.format("%.0fK", totalHP / 1000)
            else
                displayHP = totalHP .. " HP"
            end
        end
        draw.DrawText("Havuz: " .. displayHP, "roboto16", 5 + party.hudhorizontalpos, 
            hpPanelY + 20, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
        
        -- Prop sayisi
        local propText = "Prop: " .. PropHP_Client.PoolData.propCount
        draw.DrawText(propText, "roboto16", 5 + party.hudhorizontalpos, 
            hpPanelY + 35, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
        
        -- HP/Prop
        local hpPerProp = PropHP_Client.PoolData.hpPerProp
        local hpPerPropText = "0"
        if hpPerProp > 0 then
            if hpPerProp >= 1000 then
                hpPerPropText = string.format("%.0fK", hpPerProp / 1000)
            else
                hpPerPropText = tostring(hpPerProp)
            end
        end
        
        -- HP/Prop rengi
        local hpColor = Color(255, 255, 255, 255)
        if hpPerProp < 10000 then
            hpColor = Color(255, 100, 100, 255) -- Kirmizi
        elseif hpPerProp < 50000 then
            hpColor = Color(255, 255, 0, 255) -- Sari
        else
            hpColor = Color(100, 255, 100, 255) -- Yesil
        end
        
        draw.DrawText("HP/Prop: " .. hpPerPropText, "roboto16", 5 + party.hudhorizontalpos, 
            hpPanelY + 50, hpColor, TEXT_ALIGN_LEFT)
        
        -- Yok edilen prop sayısı
        if PropHP_Client.PoolData.destroyed > 0 then
            draw.DrawText("Yıkılan: " .. PropHP_Client.PoolData.destroyed, "roboto16", 
                5 + party.hudhorizontalpos, hpPanelY + 65, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT)
        end
        
        lastMemberY = hpPanelY + hpPanelHeight -- HP panelinden sonra güncelle
    end
    
    -- ============================
    -- PARTİ SÜRE GÖSTERGESİ - YENİ
    -- ============================
    if party.ShowTimeInHUD and PartyLeaveTime.canLeaveAt > 0 then
        local timeLeft = PartyLeaveTime.canLeaveAt - CurTime()
        
        if timeLeft > 0 then
            -- Süre kutusunu en alta ekle
            local timeBoxY = lastMemberY + 10
            local timeBoxHeight = 40
            
            -- Arka plan
            draw.RoundedBox(5, party.hudhorizontalpos, timeBoxY, 150, timeBoxHeight, Color(100, 50, 50, 200))
            draw.RoundedBox(5, 3 + party.hudhorizontalpos, timeBoxY + 3, 150 - 6, timeBoxHeight - 6, Color(0, 0, 0, 200))
            
            -- Başlık
            draw.DrawText("ÇIKIŞ SÜRESİ", "roboto16", party.hudhorizontalpos + 75, timeBoxY + 5, 
                Color(255, 100, 100, 255), TEXT_ALIGN_CENTER)
            
            -- Kalan süre
            local minutes = math.floor(timeLeft / 60)
            local seconds = math.floor(timeLeft % 60)
            local timeText = string.format("%d:%02d", minutes, seconds)
            
            -- Renk (az zaman kaldıysa yeşil)
            local timeColor = Color(255, 100, 100, 255)
            if timeLeft < 60 then
                timeColor = Color(100, 255, 100, 255)
            elseif timeLeft < 300 then
                timeColor = Color(255, 255, 100, 255)
            end
            
            draw.DrawText(timeText .. " kaldı", "roboto16", party.hudhorizontalpos + 75, 
                timeBoxY + 22, timeColor, TEXT_ALIGN_CENTER)
        end
    end
    
    -- ============================
    -- OYUNCU ÜZERINDE PARTI ADI - OPTIMIZE
    -- ============================
    if not party.DisplayParty then return end
    
    if party.DarkrpGamemode then
        local shouldDrawHud = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
        if shouldDrawHud == false then return end
    end
    
    local trace = LocalPlayer():GetEyeTrace()
    if trace.Hit and trace.HitNonWorld and IsValid(trace.Entity) then
        if trace.Entity:IsPlayer() and trace.Entity:Alive() then
            if trace.Entity:GetRenderMode() == RENDERMODE_TRANSALPHA then return end
            if trace.Entity == LocalPlayer() then return end
            
            local PlayersPos = trace.Entity:EyePos()
            local LocalEye = LocalPlayer():EyePos()
            PlayersPos.z = PlayersPos.z + 10
            
            if PlayersPos:Distance(LocalEye) < 250 then
                PlayersPos = PlayersPos:ToScreen()
                if party.DarkrpGamemode then
                    if trace.Entity.getDarkRPVar and not trace.Entity:getDarkRPVar("wanted") then
                        PlayersPos.y = PlayersPos.y - 50
                    end
                end
                
                local partyname = trace.Entity:GetPartyName()
                if partyname then
                    draw.DrawNonParsedText("Party : " .. partyname, "roboto16", PlayersPos.x + 1, 
                        PlayersPos.y + 61, Color(0, 0, 0), 1)
                    draw.DrawNonParsedText("Party : " .. partyname, "roboto16", PlayersPos.x, 
                        PlayersPos.y + 60, Color(255, 255, 255), 1)
                end
            end
        end
    end
end)

-- Network update'lerde cache'i güncelle
net.Receive("party", function()
    parties = net.ReadTable()
    HUDCache.needsUpdate = true
end)

net.Receive("oneparty", function()
    local partystring = net.ReadString()
    parties[partystring] = net.ReadTable()
    if parties[partystring] and parties[partystring].name == "DeleteMe" then
        parties[partystring] = nil
    end
    HUDCache.needsUpdate = true
end)

net.Receive("onepartytoparty", function()
    local partystring = net.ReadString()
    parties[partystring] = net.ReadTable()
    HUDCache.needsUpdate = true
end)

-- Sunucu degisikliginde veya disconnect'te temizle
hook.Add("Disconnect", "PartyHUDCleanup", function()
    CleanupPartyHooks()
    HUDCache = {
        lastUpdate = 0,
        updateRate = 0.1,
        partyData = nil,
        memberData = {},
        needsUpdate = true
    }
    PartyLeaveTime = {
        canLeaveAt = 0,
        lastUpdate = 0
    }
end)

hook.Add("ShutDown", "PartyHUDCleanup", CleanupPartyHooks)