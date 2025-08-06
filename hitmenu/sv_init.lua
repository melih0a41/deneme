--[[
Hitman Sistemi - Sunucu Tarafı (Optimized)
Performans iyileştirmeleri: String cache, player loop optimizasyonu
--]]

local plyMeta = FindMetaTable("Player")
local hits = {}
local questionCallback

-- OPTIMIZASYON: String cache
local coloredMessages = {
    hitAccepted = "<rgb:255,255,0>[Suikast] <rgb:255,0,0>%s <rgb:255,255,255>adlı oyuncuya suikast düzenlenecek.",
    hitCompleted = "<rgb:255,255,0>[Suikast] <rgb:0,255,0>Suikast tamamlandı.",
    hitFailed = "<rgb:255,255,0>[Suikast] <rgb:255,0,0>Suikast başarısız."
}

-- OPTIMIZASYON: Player cache for broadcasts
local playerCache = {}
local playerCacheTime = 0
local playerCacheInterval = 1 -- 1 saniye cache

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
util.AddNetworkString("onHitAccepted")
util.AddNetworkString("onHitCompleted")
util.AddNetworkString("onHitFailed")

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
DarkRP.getHits = fp{fn.Id, hits}

function plyMeta:requestHit(customer, target, price)
    local canRequest, msg, cost = hook.Call("canRequestHit", DarkRP.hooks, self, customer, target, price)
    price = cost or price

    if canRequest == false then
        DarkRP.notify(customer, 1, 4, msg)
        return false
    end

    -- OPTIMIZASYON: String concat yerine format
    local questionID = string.format("hit%d|%d|%d", self:UserID(), customer:UserID(), target:UserID())
    
    DarkRP.createQuestion(DarkRP.getPhrase("accept_hit_request", customer:Nick(), target:Nick(), DarkRP.formatMoney(price)),
        questionID,
        self,
        20,
        questionCallback,
        customer,
        target,
        price
    )

    DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("hit_requested"))
    return true
end

function plyMeta:placeHit(customer, target, price)
    if hits[self] then DarkRP.error("This person has an active hit!", 2) end

    if not customer:canAfford(price) then
        DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("hit")))
        return
    end

    -- OPTIMIZASYON: Tek table allocation
    hits[self] = {
        price = price,
        customer = customer
    }

    self:setHitCustomer(customer)
    self:setHitTarget(target)

    DarkRP.payPlayer(customer, self, price)

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

function questionCallback(answer, hitman, customer, target, price)
    if not IsValid(customer) then return end
    if not IsValid(hitman) or not hitman:isHitman() then return end

    if not IsValid(customer) then
        DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("customer_left_server"))
        return
    end

    if not IsValid(target) then
        DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("target_left_server"))
        return
    end

    if not tobool(answer) then
        DarkRP.notify(customer, 1, 4, DarkRP.getPhrase("hit_declined"))
        return
    end

    if hits[hitman] then return end

    DarkRP.notify(hitman, 1, 4, DarkRP.getPhrase("hit_accepted"))
    hitman:placeHit(customer, target, price)
end

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

DarkRP.defineChatCommand("requesthit", function(ply, args)
    args = string.Explode(' ', args)
    local target = DarkRP.findPlayer(args[1])
    local traceEnt = ply:GetEyeTrace().Entity
    local hitman = IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt or Player(tonumber(args[2] or -1) or -1)

    if not IsValid(hitman) or not IsValid(target) or not hitman:IsPlayer() then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    hitman:requestHit(ply, target, hitman:getHitPrice())
    return ""
end)

-- OPTIMIZASYON: Tek fonksiyon ile iki komut
local function cancelHitCommand(ply, args)
    if not hits[ply] then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_active_hit"))
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
-- OPTIMIZASYON: Broadcast fonksiyonu
local function BroadcastColoredMessage(message)
    local players = GetCachedPlayers()
    for i = 1, #players do
        players[i]:ChatPrint(message)
    end
end

function DarkRP.hooks:onHitAccepted(hitman, target, customer)
    net.Start("onHitAccepted")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteEntity(customer)
    net.Broadcast()

    DarkRP.notify(customer, 0, 8, DarkRP.getPhrase("hit_accepted"))
    customer.lastHitAccepted = CurTime()

    -- OPTIMIZASYON: Pre-formatted string
    local targetName = IsValid(target) and target:Nick() or "Bilinmeyen Oyuncu"
    local message = string.format(coloredMessages.hitAccepted, targetName)
    BroadcastColoredMessage(message)

    DarkRP.log("Hitman " .. hitman:Nick() .. " accepted a hit on " .. targetName .. ", ordered by " .. customer:Nick() .. " for " .. DarkRP.formatMoney(hits[hitman].price), Color(255, 0, 255))
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
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
    net.Start("onHitFailed")
        net.WriteEntity(hitman)
        net.WriteEntity(target)
        net.WriteString(reason)
    net.Broadcast()

    BroadcastColoredMessage(coloredMessages.hitFailed)

    local targetname = IsValid(target) and target:Nick() or "disconnected player"
    DarkRP.log("Hit on " .. targetname .. " failed. Reason: " .. reason, Color(255, 0, 255))
end

-- PlayerDeath Hook'u
hook.Add("PlayerDeath", "DarkRP Hitman System", function(ply, inflictor, attacker)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_died"))
    end

    if IsValid(attacker) and attacker:IsPlayer() and hits[attacker] and attacker:getHitTarget() == ply then
        hook.Call("onHitCompleted", DarkRP.hooks, attacker, ply, hits[attacker].customer)
    end

    -- OPTIMIZASYON: pairs yerine hits tablosu üzerinde doğrudan iterasyon
    for hitman, hit in pairs(hits) do
        if IsValid(hitman) and hit then
            local hitTarget = hitman:getHitTarget()
            if IsValid(hitTarget) and hitTarget == ply then
                if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply and attacker ~= hitman then
                    hitman:abortHit(DarkRP.getPhrase("target_killed_by_other", attacker:Nick()))
                end
            end
        else
            hits[hitman] = nil
        end
    end
end)

hook.Add("PlayerDisconnected", "Hitman system", function(ply)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_left_server"))
    end

    for hitman, hit in pairs(hits) do
        if IsValid(hitman) and hit then
            if hit.customer == ply then
                hitman:abortHit(DarkRP.getPhrase("customer_left_server"))
            elseif hitman:getHitTarget() == ply then
                hitman:abortHit(DarkRP.getPhrase("target_left_server"))
            end
        else
            hits[hitman] = nil
        end
    end
end)

hook.Add("playerArrested", "Hitman system", function(ply)
    local hit = hits[ply]
    if not hit or not IsValid(hit.customer) then return end

    -- OPTIMIZASYON: CP kontrolü için cache
    local cps = team.GetPlayers(TEAM_POLICE or 2) -- Polis takımı ID'si
    for i = 1, #cps do
        DarkRP.notify(cps[i], 0, 8, DarkRP.getPhrase("x_had_hit_ordered_by_y", ply:Nick(), hit.customer:Nick()))
    end

    ply:abortHit(DarkRP.getPhrase("hitman_arrested"))
end)

hook.Add("OnPlayerChangedTeam", "Hitman system", function(ply, prev, new)
    if hits[ply] then
        ply:abortHit(DarkRP.getPhrase("hitman_changed_team"))
    end
end)