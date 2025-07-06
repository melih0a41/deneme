-- DarkRP Demote Override - Varsayılan sistemi devre dışı bırakır
-- Bu dosyayı: garrysmod/addons/afk_demote_system/lua/autorun/server/sv_demote_override.lua olarak kaydedin

-- DarkRP'nin demote mesajlarını engelle
hook.Add("DarkRPFinishedLoading", "AFKDemote.OverrideMessages", function()
    -- Varsayılan demote phrase'lerini değiştir
    if DarkRP and DarkRP.addPhrase then
        -- Türkçe
        DarkRP.addPhrase("tr", "demote_vote_started", "")
        DarkRP.addPhrase("tr", "demote_vote_text", "")
        
        -- İngilizce
        DarkRP.addPhrase("en", "demote_vote_started", "")
        DarkRP.addPhrase("en", "demote_vote_text", "")
    end
end)

-- Demote vote başlatmayı engelle
hook.Add("canStartVote", "AFKDemote.BlockDemoteVote", function(voteType)
    if voteType == "demote" then
        return false, ""
    end
end)

-- playerCanDemote hook'u ile engelle
hook.Add("playerCanDemote", "AFKDemote.BlockDemote", function(ply, target)
    return false, ""
end)