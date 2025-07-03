-- SAM VIP Yönetim Sistemi - Client Tarafı
-- lua/sam_vip_system/cl_sam_vip.lua

-- VIP rankları cache
local VIP_RANKS = VIP_RANKS or {
    {id = "bronzvip", name = "Bronz VIP", color = Color(205, 127, 50)},
    {id = "silvervip", name = "Silver VIP", color = Color(192, 192, 192)},
    {id = "goldvip", name = "Gold VIP", color = Color(255, 215, 0)},
    {id = "platinumvip", name = "Platinum VIP", color = Color(229, 228, 226)},
    {id = "diamondvip", name = "Diamond VIP", color = Color(185, 242, 255)}
}

-- Özel fontlar oluştur
surface.CreateFont("VIPButtonFont", {
    font = "Trebuchet MS",
    extended = false,
    size = 24,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPRankFont", {
    font = "Arial",
    extended = false,
    size = 18,
    weight = 600,
    blursize = 0,
    scanlines = 0,
    antialias = true,
})

-- VIP duyurusu
net.Receive("SAM.VIPAnnouncement", function()
    local nick = net.ReadString()
    local vipName = net.ReadString()
    local vipColor = net.ReadColor()
    
    -- Sesli bildirim
    surface.PlaySound("garrysmod/content_downloaded.wav")
    
    -- Duyuru paneli
    local w, h = 400, 100
    local panel = vgui.Create("DPanel")
    panel:SetSize(w, h)
    panel:SetPos(ScrW() / 2 - w / 2, -h)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 240))
        draw.RoundedBoxEx(8, 0, 0, w, 30, vipColor, true, true, false, false)
        draw.SimpleText("VIP DUYURUSU", "DermaDefaultBold", w/2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(nick .. " artık " .. vipName .. "!", "DermaLarge", w/2, 60, vipColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Animasyon
    panel:MoveTo(ScrW() / 2 - w / 2, 50, 0.5, 0, -1, function()
        timer.Simple(5, function()
            if IsValid(panel) then
                panel:MoveTo(ScrW() / 2 - w / 2, -h, 0.5, 0, -1, function()
                    if IsValid(panel) then
                        panel:Remove()
                    end
                end)
            end
        end)
    end)
end)

-- VIP rankları listesini al
net.Receive("SAM_VIP_SendRanks", function()
    local received_ranks = net.ReadTable()
    if received_ranks and #received_ranks > 0 then
        VIP_RANKS = received_ranks
    end
end)