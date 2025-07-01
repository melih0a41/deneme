if SERVER then
    util.AddNetworkString("SAM.VIPAnnouncement")

    -- SAM yetki verme hook'u (örneğin kullanıcı grubu değiştirilince)
    hook.Add("SAM.ChangedPlayerRank", "AnnounceVIPRank", function(ply, rank, oldRank)
        if rank == "vip" and oldRank ~= "vip" then
            net.Start("SAM.VIPAnnouncement")
                net.WriteString(ply:Nick())
            net.Broadcast()
        end
    end)
end

if CLIENT then
    net.Receive("SAM.VIPAnnouncement", function()
        local vipname = net.ReadString()
        chat.AddText(Color(255, 215, 0), "[VIP] ", Color(255,255,255), vipname .. " adlı oyuncu VIP satın aldı! Tebrikler!")
        
        notification.AddLegacy(vipname .. " VIP satın aldı! Tebrikler!", NOTIFY_GENERIC, 10)
        surface.PlaySound("garrysmod/content_downloaded.wav")
    end)
end
