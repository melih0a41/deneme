util.AddNetworkString("SAM.VIPAnnouncement")

hook.Add("SAM.ChangedPlayerRank", "AnnounceVIPRank", function(ply, rank, oldRank)
    if rank == "vip" and oldRank ~= "vip" then
        net.Start("SAM.VIPAnnouncement")
            net.WriteString(ply:Nick())
        net.Broadcast()
    end
end)
