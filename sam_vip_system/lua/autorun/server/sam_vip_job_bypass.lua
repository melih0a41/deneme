-- /lua/autorun/server/sam_vip_job_bypass.lua (v2 - Daha Güçlü Kontrol)
-- Diamond VIP'ler için meslek sınırı atlama sistemi

hook.Add("PlayerCanChangeJob", "SAM_DiamondVIP_BypassJobLimit_V2", function(ply, jobTable)
    
    -- Oyuncunun geçerli olup olmadığını kontrol et
    if not IsValid(ply) then return end
    
    -- Oyuncunun rank'ının "diamondvip" olup olmadığını kontrol et
    if ply:GetUserGroup() == "diamondvip" then
        
        -- HATA AYIKLAMA MESAJI: Sorunu anlamak için oyuncunun sohbet penceresine bir mesaj gönderir.
        -- Bu mesajı sadece oyuncunun kendisi görür.
        ply:ChatPrint("[VIP Sistemi] Diamond VIP yetkiniz algılandı. Meslek limiti sizin için atlanıyor.")
        
        -- DarkRP'ye bu oyuncunun mesleği kesinlikle alabileceğini söylüyoruz.
        -- "true" döndürmek, diğer tüm limit kontrollerini (meslek sınırı dahil) atlar.
        return true
        
    end
    
    -- Eğer oyuncu Diamond VIP değilse, hiçbir şey döndürmüyoruz (nil).
    -- Bu, DarkRP'nin normal meslek limiti kontrollerine devam etmesini sağlar.
    return nil
    
end)

print("[SAM VIP Sistemi] Diamond VIP meslek sınırı atlama modülü (v2) başarıyla yüklendi.")