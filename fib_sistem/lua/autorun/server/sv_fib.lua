-- fib_sistem/lua/autorun/server/sv_fib.lua

-- Config'in yüklenmesini garantile
if not FIB or not FIB.Config then
    FIB = FIB or {}
    FIB.Config = FIB.Config or {}
    FIB.Config.Users = FIB.Config.Users or {}
    
    print("[FIB SERVER] Config yukleniyor...")
end

util.AddNetworkString("FIB_AttemptLogin")
util.AddNetworkString("FIB_LoginResponse")

-- Login denemelerini takip et (brute force koruması)
local loginAttempts = {}

net.Receive("FIB_AttemptLogin", function(len, ply)
    local username = net.ReadString()
    local password = net.ReadString()
    local steamid = ply:SteamID()
    
    print("[FIB DEBUG] Giris denemesi - Kullanici: " .. ply:Nick() .. " | SteamID: " .. steamid)
    print("[FIB DEBUG] Girilen: " .. username .. " / " .. password)
    print("[FIB DEBUG] Config Users tablosu:", table.Count(FIB.Config.Users), "kullanici")
    
    -- Brute force koruması
    loginAttempts[steamid] = loginAttempts[steamid] or {count = 0, lastAttempt = 0}
    
    if loginAttempts[steamid].count >= 5 and (CurTime() - loginAttempts[steamid].lastAttempt) < 60 then
        print("[FIB] Brute force korumasi aktif: " .. ply:Nick())
        net.Start("FIB_LoginResponse")
        net.WriteBool(false)
        net.WriteString("Cok fazla basarisiz deneme - 1 dakika bekleyin")
        net.Send(ply)
        return
    end
    
    -- Whitelist kontrolü
    if not FIB.Config.Users[steamid] then
        print("[FIB] Yetkisiz giris denemesi: " .. ply:Nick() .. " (" .. steamid .. ")")
        
        net.Start("FIB_LoginResponse")
        net.WriteBool(false)
        net.WriteString("Erisim Reddedildi - Yetkisiz Kullanici")
        net.Send(ply)
        
        -- Deneme sayısını artır
        loginAttempts[steamid].count = loginAttempts[steamid].count + 1
        loginAttempts[steamid].lastAttempt = CurTime()
        return
    end
    
    local userData = FIB.Config.Users[steamid]
    
    -- Kullanıcı adı ve şifre kontrolü
    if userData.username == username and userData.password == password then
        print("[FIB] Basarili giris: " .. ply:Nick() .. " (" .. steamid .. ") - Rutbe: " .. userData.rank)
        
        -- Başarılı giriş
        net.Start("FIB_LoginResponse")
        net.WriteBool(true)
        net.WriteString("Erisim Onaylandi - Hos Geldin")
        net.WriteString(userData.rank) -- Rütbeyi gönder
        net.WriteString(userData.username) -- Username'i gönder
        net.Send(ply)
        
        -- Giriş durumunu kaydet
        ply.FIBAuthenticated = true
        ply.FIBRank = userData.rank
        ply.FIBUsername = userData.username
        ply.FIBLoginTime = CurTime()
        
        -- Deneme sayısını sıfırla
        loginAttempts[steamid] = {count = 0, lastAttempt = 0}
        
        -- Diğer FIB ajanlarına bildir
        for _, v in ipairs(player.GetAll()) do
            if v.FIBAuthenticated and v != ply then
                v:ChatPrint("[FIB] " .. userData.rank .. " " .. ply:Nick() .. " sisteme giris yapti.")
            end
        end
        
        -- Log kaydet
        ServerLog("[FIB] " .. ply:Nick() .. " (" .. steamid .. ") sisteme giris yapti - Rutbe: " .. userData.rank .. "\n")
    else
        print("[FIB] Basarisiz giris denemesi: " .. ply:Nick() .. " - Beklenen: " .. (userData.username or "?") .. " / Girilen: " .. username)
        
        -- Hatalı giriş
        net.Start("FIB_LoginResponse")
        net.WriteBool(false)
        net.WriteString("Gecersiz Kimlik Bilgileri")
        net.Send(ply)
        
        -- Deneme sayısını artır
        loginAttempts[steamid].count = loginAttempts[steamid].count + 1
        loginAttempts[steamid].lastAttempt = CurTime()
        
        -- Log kaydet
        ServerLog("[FIB] Basarisiz giris denemesi: " .. ply:Nick() .. " (" .. steamid .. ")\n")
    end
end)

-- Oyuncu çıkış yaptığında FIB durumunu temizle
hook.Add("PlayerDisconnected", "FIB_PlayerDisconnect", function(ply)
    if ply.FIBAuthenticated then
        -- Diğer ajanlara bildir
        for _, v in ipairs(player.GetAll()) do
            if v.FIBAuthenticated and v != ply then
                v:ChatPrint("[FIB] " .. (ply.FIBRank or "Ajan") .. " " .. ply:Nick() .. " sistemden ayrildi.")
            end
        end
        
        print("[FIB] " .. ply:Nick() .. " sistemden cikis yapti.")
        ServerLog("[FIB] " .. ply:Nick() .. " sistemden cikis yapti.\n")
        
        -- Durumu temizle
        ply.FIBAuthenticated = false
        ply.FIBRank = nil
        ply.FIBUsername = nil
        ply.FIBUndercover = false
    end
end)

-- Oyuncu spawn olduğunda authentication kontrolü
hook.Add("PlayerInitialSpawn", "FIB_PlayerInit", function(ply)
    -- Başlangıçta authenticated değil
    ply.FIBAuthenticated = false
    ply.FIBRank = nil
    ply.FIBUsername = nil
    ply.FIBUndercover = false
end)

-- Admin komutları
hook.Add("PlayerSay", "FIB_AdminCommands", function(ply, text)
    if not ply:IsAdmin() then return end
    
    local args = string.Explode(" ", text)
    
    if args[1] == "!fib_ekle" and args[2] then
        -- Oyuncu bul
        local target = nil
        for _, v in ipairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
                break
            end
        end
        
        if target then
            local steamid = target:SteamID()
            local username = "AGENT" .. math.random(100, 999)
            local password = "FIB#" .. math.random(1000, 9999)
            
            FIB.Config.Users[steamid] = {
                username = username,
                password = password,
                rank = "Ajan"
            }
            
            ply:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi.")
            ply:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
            target:ChatPrint("[FIB] Sisteme eklendiniz! !fib yazarak giris yapabilirsiniz.")
            target:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
            
            ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. target:Nick() .. " sisteme eklendi.\n")
        else
            ply:ChatPrint("[FIB] Oyuncu bulunamadi!")
        end
        
        return ""
    elseif args[1] == "!fib_sil" and args[2] then
        -- Oyuncu bul
        local target = nil
        for _, v in ipairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
                break
            end
        end
        
        if target then
            local steamid = target:SteamID()
            if FIB.Config.Users[steamid] then
                FIB.Config.Users[steamid] = nil
                target.FIBAuthenticated = false
                target.FIBRank = nil
                target.FIBUsername = nil
                ply:ChatPrint("[FIB] " .. target:Nick() .. " sistemden silindi.")
                target:ChatPrint("[FIB] Sistem erisiminiz kaldirildi.")
                
                ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. target:Nick() .. " sistemden silindi.\n")
            else
                ply:ChatPrint("[FIB] Bu oyuncu zaten sistemde degil!")
            end
        else
            ply:ChatPrint("[FIB] Oyuncu bulunamadi!")
        end
        
        return ""
    elseif args[1] == "!fib_liste" then
        ply:ChatPrint("[FIB] === Yetkili Kullanicilar ===")
        for steamid, data in pairs(FIB.Config.Users) do
            ply:ChatPrint("[FIB] " .. steamid .. " - " .. data.username .. " - " .. data.rank)
        end
        ply:ChatPrint("[FIB] Toplam: " .. table.Count(FIB.Config.Users) .. " kullanici")
        return ""
    elseif args[1] == "!fib_debug" then
        ply:ChatPrint("[FIB] === DEBUG ===")
        ply:ChatPrint("[FIB] Config yuklu: " .. tostring(FIB.Config ~= nil))
        ply:ChatPrint("[FIB] Users tablosu: " .. table.Count(FIB.Config.Users) .. " kullanici")
        ply:ChatPrint("[FIB] Senin SteamID: " .. ply:SteamID())
        ply:ChatPrint("[FIB] Authenticated: " .. tostring(ply.FIBAuthenticated))
        ply:ChatPrint("[FIB] Rutbe: " .. tostring(ply.FIBRank))
        return ""
    elseif args[1] == "!fib_online" then
        ply:ChatPrint("[FIB] === ONLINE AJANLAR ===")
        local count = 0
        for _, v in ipairs(player.GetAll()) do
            if v.FIBAuthenticated then
                ply:ChatPrint("[FIB] " .. v:Nick() .. " - " .. v.FIBRank .. " - " .. v.FIBUsername)
                count = count + 1
            end
        end
        if count == 0 then
            ply:ChatPrint("[FIB] Su anda online ajan yok.")
        else
            ply:ChatPrint("[FIB] Toplam: " .. count .. " online ajan")
        end
        return ""
    end
end)

-- Sunucu başlatıldığında
hook.Add("Initialize", "FIB_ServerInit", function()
    print("[FIB] ===================================")
    print("[FIB] Federal Istihbarat Burosu Sistemi")
    print("[FIB] Versiyon: 1.0")
    print("[FIB] Durum: AKTIF")
    print("[FIB] ===================================")
end)

-- Debug komutu
concommand.Add("fib_server_debug", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB] === SERVER DEBUG ===")
    print("Config yuklu:", FIB.Config ~= nil)
    print("Users sayisi:", table.Count(FIB.Config.Users))
    
    print("\n=== KULLANICILAR ===")
    for steamid, data in pairs(FIB.Config.Users) do
        print(steamid, "->", data.username, "-", data.rank)
    end
    
    print("\n=== ONLINE AJANLAR ===")
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            print(v:Nick(), "->", v.FIBRank, "-", v:SteamID())
        end
    end
end)