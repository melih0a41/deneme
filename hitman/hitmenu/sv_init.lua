--[[
Hitman Sistemi - Sunucu Tarafı (Final Fixed)
Net message handler düzeltildi
--]]

local plyMeta = FindMetaTable("Player")
local hits = {}
local questionCallback

-- String cache
local coloredMessages = {
    hitAccepted = "<rgb:255,255,0>[Suikast] <rgb:255,0,0>%s <rgb:255,255,255>adlı oyuncuya suikast düzenlenecek.",
    hitCompleted = "<rgb:255,255,0>[Suikast] <rgb:0,255,0>Suikast tamamlandı.",
    hitFailed = "<rgb:255,255,0>[Suikast] <rgb:255,0,0>Suikast başarısız."
}

-- Player cache for broadcasts
local playerCache = {}
local playerCacheTime = 0
local playerCacheInterval = 1

local function GetCachedPlayers()
    local curTime = CurTime()
    if curTime - playerCacheTime > playerCacheInterval then
        playerCache = player.GetAll()
        playerCacheTime = curTime
    end
    return playerCache
end

--[[---------------------------------------------------------------------------
Net messages
---------------------------------------------------------------------------]]
util.AddNetworkString("HitQuestion")
util.AddNetworkString("HitQuestionResponse")
util.AddNetworkString("onHitAccepted")
util.AddNetworkString("onHitCompleted")
util.AddNetworkString("onHitFailed")
util.AddNetworkString("HitmanRequestHit") -- YENİ NET MESSAGE

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
DarkRP.getHits = fp{fn.Id, hits}

function plyMeta:requestHit(customer, target, price)
    print("[HitMenu-SV] requestHit çağrıldı")
    print("  Hitman:", self:Nick())
    print("  Customer:", customer:Nick())
    print("  Target:", target:Nick())
    print("  Price:", price)
    
    -- Validasyon
    if not IsValid(self) or not self:isHitman() then
        print("[HitMenu-SV] HATA: Geçersiz hitman!")
        return false
    end
    
    if not IsValid(customer) then
        print("[HitMenu-SV] HATA: Geçersiz customer!")
        return false
    end
    
    if not IsValid(target) then
        print("[HitMenu-SV] HATA: Geçersiz target!")
        DarkRP.notify(customer, 1, 4, "Geçersiz hedef!")
        return false
    end
    
    -- Hook kontrolü
    local canRequest, msg, cost = hook.Call("canRequestHit", DarkRP.hooks, self, customer, target, price)
    price = cost or price

    if canRequest == false then
        print("[HitMenu-SV] Hit talebi hook tarafından reddedildi:", msg)
        DarkRP.notify(customer, 1, 4, msg or "Hit talebi reddedildi!")
        return false
    end

    -- Hit zaten var mı kontrol et
    if self:hasHit() then
        print("[HitMenu-SV] Hitman'in zaten bir görevi var!")
        DarkRP.notify(customer, 1, 4, "Bu tetikçinin zaten aktif bir görevi var!")
        return false
    end

    -- MODERN MENÜ SİSTEMİ - EĞER USE_MODERN_HIT_MENU true ise
    local USE_MODERN_HIT_MENU = true -- Bu değeri false yaparsanız eski DarkRP sorusu kullanılır
    
    if USE_MODERN_HIT_MENU then
        -- Modern menü için net message gönder
        net.Start("HitQuestion")
            net.WriteEntity(customer)
            net.WriteEntity(target)
            net.WriteFloat(price)
        net.Send(self)
        
        -- Müşteriye bildirim
        DarkRP.notify(customer, 0, 4, "Suikast talebi gönderildi. Tetikçinin yanıtını bekleyin.")
        
        -- Timeout için timer
        timer.Create("HitQuestion_" .. self:UserID() .. "_" .. customer:UserID(), 20, 1, function()
            if IsValid(customer) then
                DarkRP.notify(customer, 1, 4, "Tetikçi cevap vermedi, talep iptal edildi.")
            end
        end)
        
        print("[HitMenu-SV] Modern menü gönderildi")
    else
        -- ESKİ SİSTEM - DarkRP Sorusu
        local questionID = string.format("hit_%d_%d_%d_%d", 
            self:UserID(), 
            customer:UserID(), 
            target:UserID(),
            os.time()
        )
        
        print("[HitMenu-SV] Soru oluşturuluyor ID:", questionID)
        
        DarkRP.createQuestion(
            string.format("%s adlı oyuncu %s adlı oyuncuya %s karşılığında suikast talep ediyor. Kabul ediyor musun?",
                customer:Nick(), 
                target:Nick(), 
                DarkRP.formatMoney(price)
            ),
            questionID,
            self,
            20,
            questionCallback,
            customer,
            target,
            price
        )

        DarkRP.notify(customer, 0, 4, "Suikast talebi gönderildi. Tetikçinin yanıtını bekleyin.")
        print("[HitMenu-SV] Eski soru sistemi kullanıldı")
    end
    
    return true
end

function plyMeta:placeHit(customer, target, price)
    print("[HitMenu-SV] placeHit çağrıldı")
    print("  Hitman:", self:Nick())
    print("  Target:", target:Nick())
    print("  Customer:", customer:Nick())
    print("  Price:", price)
    
    if hits[self] then 
        print("[HitMenu-SV] HATA: Hitman'in zaten aktif hit'i var!")
        DarkRP.error("This person has an active hit!", 2) 
        return
    end

    if not customer:canAfford(price) then
        print("[HitMenu-SV] HATA: Müşteri parayı karşılayamıyor!")
        DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit")))
        return
    end

    -- Hit'i kaydet
    hits[self] = {
        price = price,
        customer = customer,
        target = target
    }

    self:setHitCustomer(customer)
    self:setHitTarget(target)

    -- Para transferi
    DarkRP.payPlayer(customer, self, price)

    print("[HitMenu-SV] Hit başarıyla yerleştirildi")
    
    -- Hook'u çağır
    hook.Call("onHitAccepted", DarkRP.hooks, self, target, customer)
end

function plyMeta:setHitTarget(target)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end

    self:setSelfDarkRPVar("hitTarget", target)
    self:setDarkRPVar("hasHit", target and true or nil)
end

function plyMeta:setHitPrice(price)
    self:setDarkRPVar("hitPrice", math.Min(GAMEMODE.Config.maxHitPrice or 50000, math.Max(GAMEMODE.Config.minHitPrice or 200, price)))
end

function plyMeta:setHitCustomer(customer)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end
    hits[self].customer = customer
end

function plyMeta:getHitCustomer()
    return hits[self] and hits[self].customer or nil
end

function plyMeta:abortHit(message)
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end

    message = message or ""
    hook.Call("onHitFailed", DarkRP.hooks, self, self:getHitTarget(), message)
    self:finishHit()
end

function plyMeta:cancelHit()
    if not hits[self] then DarkRP.error("This person has no active hit!", 2) end
    if not self:canAfford(hits[self].price) then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit_cancel")))
        return
    end

    DarkRP.payPlayer(self, hits[self].customer, hits[self].price)
    self:abortHit(DarkRP.getPhrase("hit_cancelled"))
end

function plyMeta:finishHit()
    self:setHitCustomer(nil)
    self:setHitTarget(nil)
    hits[self] = nil
end

-- Callback fonksiyonu
function questionCallback(answer, hitman, customer, target, price)
    print("[HitMenu-SV] Question callback çağrıldı")
    print("  Answer:", answer)
    print("  Hitman:", IsValid(hitman) and hitman:Nick() or "INVALID")
    print("  Customer:", IsValid(customer) and customer:Nick() or "INVALID")
    print("  Target:", IsValid(target) and target:Nick() or "INVALID")
    
    if not IsValid(hitman) or not hitman:isHitman() then 
        print("[HitMenu-SV] Callback: Hitman geçersiz veya artık tetikçi değil")
        return 
    end

    if not IsValid(customer) then
        DarkRP.notify(hitman, 1, 4, "Müşteri sunucudan ayrıldı!")
        print("[HitMenu-SV] Callback: Müşteri sunucudan ayrıldı")
        return
    end

    if not IsValid(target) then
        DarkRP.notify(hitman, 1, 4, "Hedef sunucudan ayrıldı!")
        DarkRP.notify(customer, 1, 4, "Hedef sunucudan ayrıldı!")
        print("[HitMenu-SV] Callback: Hedef sunucudan ayrıldı")
        return
    end

    if not tobool(answer) then
        DarkRP.notify(customer, 1, 4, "Tetikçi suikast talebinizi reddetti!")
        print("[HitMenu-SV] Callback: Tetikçi talebi reddetti")
        return
    end

    if hits[hitman] then 
        DarkRP.notify(customer, 1, 4, "Tetikçi başka bir görevi kabul etti!")
        print("[HitMenu-SV] Callback: Hitman'in zaten görevi var")
        return 
    end

    print("[HitMenu-SV] Callback: Hit kabul edildi!")
    DarkRP.notify(hitman, 0, 4, "Suikast görevi kabul edildi!")
    hitman:placeHit(customer, target, price)
end

--[[---------------------------------------------------------------------------
YENİ NET MESSAGE HANDLER
---------------------------------------------------------------------------]]
net.Receive("HitQuestionResponse", function(len, ply)
    local accepted = net.ReadBool()
    local customer = net.ReadEntity()
    local target = net.ReadEntity()
    local price = net.ReadFloat()
    
    print("[HitMenu-SV] Hit Question Response alındı")
    print("  Hitman:", ply:Nick())
    print("  Accepted:", accepted)
    print("  Customer:", IsValid(customer) and customer:Nick() or "INVALID")
    print("  Target:", IsValid(target) and target:Nick() or "INVALID")
    
    -- Timer'ı temizle
    timer.Remove("HitQuestion_" .. ply:UserID() .. "_" .. customer:UserID())
    
    -- Validasyon
    if not IsValid(ply) or not ply:isHitman() then
        print("[HitMenu-SV] Response: Hitman geçersiz veya artık tetikçi değil")
        return
    end
    
    if not IsValid(customer) then
        DarkRP.notify(ply, 1, 4, "Müşteri sunucudan ayrıldı!")
        print("[HitMenu-SV] Response: Müşteri sunucudan ayrıldı")
        return
    end
    
    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, "Hedef sunucudan ayrıldı!")
        if IsValid(customer) then
            DarkRP.notify(customer, 1, 4, "Hedef sunucudan ayrıldı!")
        end
        print("[HitMenu-SV] Response: Hedef sunucudan ayrıldı")
        return
    end
    
    if not accepted then
        DarkRP.notify(customer, 1, 4, "Tetikçi suikast talebinizi reddetti!")
        print("[HitMenu-SV] Response: Tetikçi talebi reddetti")
        return
    end
    
    -- Hit zaten var mı kontrol et
    if hits[ply] then
        DarkRP.notify(customer, 1, 4, "Tetikçi başka bir görevi kabul etti!")
        print("[HitMenu-SV] Response: Hitman'in zaten görevi var")
        return
    end
    
    -- Para kontrolü
    if not customer:canAfford(price) then
        DarkRP.notify(customer, 1, 4, "Artık bu suikastı karşılayamazsınız!")
        DarkRP.notify(ply, 1, 4, "Müşteri parayı karşılayamıyor!")
        print("[HitMenu-SV] Response: Müşteri parayı karşılayamıyor")
        return
    end
    
    print("[HitMenu-SV] Response: Hit kabul edildi!")
    DarkRP.notify(ply, 0, 4, "Suikast görevi kabul edildi!")
    ply:placeHit(customer, target, price)
end)

net.Receive("HitmanRequestHit", function(len, ply)
    print("[HitMenu-SV] HitmanRequestHit net message alındı")
    print("  Gönderen:", ply:Nick())
    
    local hitman = net.ReadEntity()
    local target = net.ReadEntity()
    
    print("  Hitman:", IsValid(hitman) and hitman:Nick() or "INVALID")
    print("  Target:", IsValid(target) and target:Nick() or "INVALID")
    
    -- Validasyon
    if not IsValid(hitman) or not hitman:IsPlayer() then
        print("[HitMenu-SV] HATA: Geçersiz hitman entity!")
        DarkRP.notify(ply, 1, 4, "Geçersiz tetikçi!")
        return
    end
    
    if not IsValid(target) or not target:IsPlayer() then
        print("[HitMenu-SV] HATA: Geçersiz target entity!")
        DarkRP.notify(ply, 1, 4, "Geçersiz hedef!")
        return
    end
    
    if not hitman:isHitman() then
        print("[HitMenu-SV] HATA: Oyuncu tetikçi değil!")
        DarkRP.notify(ply, 1, 4, "Bu oyuncu tetikçi değil!")
        return
    end
    
    -- Mesafe kontrolü
    local distSqr = ply:GetPos():DistToSqr(hitman:GetPos())
    local maxDistSqr = (GAMEMODE.Config.minHitDistance or 150) * (GAMEMODE.Config.minHitDistance or 150)
    
    if distSqr > maxDistSqr then
        print("[HitMenu-SV] HATA: Oyuncu tetikçiden çok uzakta!")
        DarkRP.notify(ply, 1, 4, "Tetikçiden çok uzaksınız!")
        return
    end
    
    -- Hit talebini işle
    print("[HitMenu-SV] Hit talebi işleniyor...")
    local success = hitman:requestHit(ply, target, hitman:getHitPrice())
    
    if success then
        print("[HitMenu-SV] Hit talebi başarıyla işlendi")
    else
        print("[HitMenu-SV] Hit talebi işlenemedi")
    end
end)

--[[---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------]]
DarkRP.defineChatCommand("hitprice", function(ply, args)
    if not ply:isHitman() then return "" end
    local price = DarkRP.toInt(args) or 0
    ply:setHitPrice(price)
    price = ply:getHitPrice()

    DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("hit_price_set", DarkRP.formatMoney(price)))
    return ""
end)

-- requesthit komutu (eski sistem için backup)
DarkRP.defineChatCommand("requesthit", function(ply, args)
    print("[HitMenu-SV] /requesthit chat komutu kullanıldı (eski sistem)")
    
    args = string.Explode(' ', args)
    local targetName = args[1]
    local hitmanUserID = tonumber(args[2] or -1)
    
    local target = DarkRP.findPlayer(targetName)
    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, "Hedef oyuncu bulunamadı!")
        return ""
    end
    
    local hitman = nil
    for _, p in pairs(player.GetAll()) do
        if p:UserID() == hitmanUserID then
            hitman = p
            break
        end
    end
    
    if not IsValid(hitman) then
        local traceEnt = ply:GetEyeTrace().Entity
        if IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt:isHitman() then
            hitman = traceEnt
        end
    end
    
    if not IsValid(hitman) or not hitman:IsPlayer() or not hitman:isHitman() then
        DarkRP.notify(ply, 1, 4, "Geçersiz tetikçi!")
        return ""
    end
    
    hitman:requestHit(ply, target, hitman:getHitPrice())
    return ""
end)

-- İptal komutları
local function cancelHitCommand(ply, args)
    if not hits[ply] then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_active_hit") or "Aktif göreviniz yok!")
        return ""
    end
    ply:cancelHit()
    return ""
end

DarkRP.defineChatCommand("cancelhit", cancelHitCommand)
DarkRP.defineChatCommand("hitiptal", cancelHitCommand)

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
local function BroadcastColoredMessage(message)
    local players = GetCachedPlayers()
    for i = 1, #players do
        players[i]:ChatPrint(message)
    end
end

function DarkRP.hooks:onHitAccepted(hitman, target, customer)
    print("[HitMenu-SV] onHitAccepted hook çağrıldı")
    
    net.Start("onHitAccepted")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteEntity(customer)
    net.Broadcast()

    DarkRP.notify(customer, 0, 8, "Tetikçi görevi kabul etti!")
    customer.lastHitAccepted = CurTime()

    local targetName = IsValid(target) and target:Nick() or "Bilinmeyen Oyuncu"
    local message = string.format(coloredMessages.hitAccepted, targetName)
    BroadcastColoredMessage(message)

    DarkRP.log("Hitman " .. hitman:Nick() .. " accepted a hit on " .. targetName .. ", ordered by " .. customer:Nick() .. " for " .. DarkRP.formatMoney(hits[hitman].price), Color(255, 0, 255))
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
    print("[HitMenu-SV] onHitCompleted hook çağrıldı")
    
    net.Start("onHitCompleted")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteEntity(customer)
    net.Broadcast()

    BroadcastColoredMessage(coloredMessages.hitCompleted)

    local targetname = IsValid(target) and target:Nick() or "disconnected player"
    local customername = IsValid(customer) and customer:Nick() or "disconnected player"

    DarkRP.log("Hitman " .. hitman:Nick() .. " finished a hit on " .. targetname .. ", ordered by " .. customername .. " for " .. DarkRP.formatMoney(hits[hitman].price), Color(255, 0, 255))

    if IsValid(target) then
        target:setDarkRPVar("lastHitTime", CurTime())
    end

    hitman:finishHit()
end

function DarkRP.hooks:onHitFailed(hitman, target, reason)
    print("[HitMenu-SV] onHitFailed hook çağrıldı")
    
    net.Start("onHitFailed")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteString(reason)
    net.Broadcast()

    BroadcastColoredMessage(coloredMessages.hitFailed)

    local targetname = IsValid(target) and target:Nick() or "disconnected player"
    DarkRP.log("Hit on " .. targetname .. " failed. Reason: " .. reason, Color(255, 0, 255))
end

-- PlayerDeath Hook
hook.Add("PlayerDeath", "DarkRP Hitman System", function(ply, inflictor, attacker)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_died") or "Tetikçi öldü!")
    end

    if IsValid(attacker) and attacker:IsPlayer() and hits[attacker] and attacker:getHitTarget() == ply then
        hook.Call("onHitCompleted", DarkRP.hooks, attacker, ply, hits[attacker].customer)
    end

    for hitman, hit in pairs(hits) do
        if IsValid(hitman) and hit then
            local hitTarget = hitman:getHitTarget()
            if IsValid(hitTarget) and hitTarget == ply then
                if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply and attacker ~= hitman then
                    hitman:abortHit(string.format("%s tarafından öldürüldü!", attacker:Nick()))
                end
            end
        else
            hits[hitman] = nil
        end
    end
end)

-- Disconnect Hook
hook.Add("PlayerDisconnected", "Hitman system", function(ply)
    if hits[ply] then
        ply:abortHit("Tetikçi sunucudan ayrıldı!")
    end

    for hitman, hit in pairs(hits) do
        if IsValid(hitman) and hit then
            if hit.customer == ply then
                hitman:abortHit("Müşteri sunucudan ayrıldı!")
            elseif hitman:getHitTarget() == ply then
                hitman:abortHit("Hedef sunucudan ayrıldı!")
            end
        else
            hits[hitman] = nil
        end
    end
end)

-- Arrest Hook
hook.Add("playerArrested", "Hitman system", function(ply)
    local hit = hits[ply]
    if not hit or not IsValid(hit.customer) then return end

    local cps = team.GetPlayers(TEAM_POLICE or 2)
    for i = 1, #cps do
        DarkRP.notify(cps[i], 0, 8, string.format("%s adlı tetikçinin %s tarafından sipariş edilen görevi var!", 
            ply:Nick(), hit.customer:Nick()))
    end

    ply:abortHit("Tetikçi tutuklandı!")
end)

-- Team Change Hook
hook.Add("OnPlayerChangedTeam", "Hitman system", function(ply, prev, new)
    if hits[ply] then
        ply:abortHit("Tetikçi mesleğini değiştirdi!")
    end
end)

-- Debug komutları
concommand.Add("hitmenu_debug", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    print("=== AKTIF HITLER ===")
    for hitman, hit in pairs(hits) do
        if IsValid(hitman) and hit then
            print(string.format("Hitman: %s, Target: %s, Customer: %s, Price: %s",
                hitman:Nick(),
                IsValid(hitman:getHitTarget()) and hitman:getHitTarget():Nick() or "INVALID",
                IsValid(hit.customer) and hit.customer:Nick() or "INVALID",
                DarkRP.formatMoney(hit.price)
            ))
        end
    end
    print("==================")
end)

concommand.Add("hitmenu_test_server", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    print("[HitMenu-SV] Test başlatılıyor...")
    
    -- Test için ilk tetikçiyi bul
    local hitman = nil
    for _, p in pairs(player.GetAll()) do
        if p:isHitman() then
            hitman = p
            break
        end
    end
    
    if not hitman then
        print("[HitMenu-SV] Test: Tetikçi bulunamadı!")
        return
    end
    
    -- İlk hedefi bul
    local target = nil
    for _, p in pairs(player.GetAll()) do
        if p ~= hitman and p ~= ply then
            target = p
            break
        end
    end
    
    if not target then
        print("[HitMenu-SV] Test: Hedef bulunamadı!")
        return
    end
    
    print("[HitMenu-SV] Test hit talebi gönderiliyor...")
    print("  Hitman:", hitman:Nick())
    print("  Customer:", ply:Nick())
    print("  Target:", target:Nick())
    
    hitman:requestHit(ply, target, hitman:getHitPrice())
end)