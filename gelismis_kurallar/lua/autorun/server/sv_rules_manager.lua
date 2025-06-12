-- sh_rules_config.lua dosyasını dahil et
include("gelismis_kurallar/sh_rules_config.lua")

-- Gerekli dosyaları client'a gönder
AddCSLuaFile("gelismis_kurallar/sh_rules_config.lua")

-- Kuralları saklamak için bir tablo
RulesDB = {}

local DATA_PATH = "gelismis_kurallar/rules.json"

-- Kuralları JSON dosyasına kaydetme fonksiyonu
function SaveRules()
    -- HATA DÜZELTMESİ: Kaydetme işleminden önce "data" klasörü içinde
    -- eklentinin klasörünün var olduğundan emin oluyoruz.
    file.CreateDir("gelismis_kurallar")

    local json = util.TableToJSON(RulesDB, true)
    
    -- HATA DÜZELTMESİ: Dosyayı doğru konuma ("garrysmod/data/") yazmak için
    -- "DATA" parametresi eklendi. Bu, kaydın kalıcı olmasını sağlar.
    file.Write(DATA_PATH, json, "DATA")
end

-- Kuralları JSON dosyasından yükleme fonksiyonu
function LoadRules()
    if (file.Exists(DATA_PATH, "DATA")) then
        local content = file.Read(DATA_PATH, "DATA")
        if content and content ~= "" then
            local success, data = pcall(util.JSONToTable, content)
            if success and type(data) == "table" then
                RulesDB = data
            else
                MsgC(Color(255, 0, 0), "[Kurallar] rules.json dosyası okunamadı veya bozuk!\n")
            end
        end
    else
        -- Eğer dosya yoksa, varsayılan kategorilerle oluştur ve kaydet
        RulesDB = {
            ["Genel Kurallar"] = {"Kural 1: Saygılı olun.", "Kural 2: Hile kullanmak yasaktır."},
            ["Base Kuralları"] = {},
            ["Gang Kuralları"] = {},
            ["Rol Kurallar"] = {},
            ["Meslek Kuralları"] = {},
        }
        SaveRules()
    end
end

-- Sunucu başladığında kuralları yükle
LoadRules()

-- Tüm oyunculara güncel kuralları gönderme fonksiyonu
function BroadcastUpdatedRules()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            net.Start("Rules_SendToClient")
                net.WriteTable(RulesDB)
            net.Send(ply)
        end
    end
end


-- Ağ (Network) Mesajlarını Tanımlama
util.AddNetworkString("Rules_SendToClient")
util.AddNetworkString("Rules_OpenMenu")
util.AddNetworkString("Rules_Request")
util.AddNetworkString("Rules_Admin_AddCategory")
util.AddNetworkString("Rules_Admin_DeleteCategory")
util.AddNetworkString("Rules_Admin_AddRule")
util.AddNetworkString("Rules_Admin_DeleteRule")


-- Admin İşlemlerini Dinleme
local function IsPlayerAdmin(ply)
    if not IsValid(ply) then return false end
    local steamID = ply:SteamID()
    local steamID64 = ply:SteamID64()
    return RULES_CONFIG.AdminSteamIDs[steamID] or RULES_CONFIG.AdminSteamIDs[steamID64]
end

net.Receive("Rules_Request", function(len, ply)
    if not IsValid(ply) then return end
    net.Start("Rules_SendToClient")
        net.WriteTable(RulesDB)
    net.Send(ply)
end)

net.Receive("Rules_Admin_AddCategory", function(len, ply)
    if not IsPlayerAdmin(ply) then return end
    local categoryName = net.ReadString()
    if categoryName and categoryName ~= "" and not RulesDB[categoryName] then
        RulesDB[categoryName] = {}
        SaveRules()
        BroadcastUpdatedRules()
    end
end)

net.Receive("Rules_Admin_DeleteCategory", function(len, ply)
    if not IsPlayerAdmin(ply) then return end
    local categoryName = net.ReadString()
    if RulesDB[categoryName] then
        RulesDB[categoryName] = nil
        SaveRules()
        BroadcastUpdatedRules()
    end
end)

net.Receive("Rules_Admin_AddRule", function(len, ply)
    if not IsPlayerAdmin(ply) then return end
    local category = net.ReadString()
    local rule = net.ReadString()
    if RulesDB[category] and rule and rule ~= "" then
        table.insert(RulesDB[category], rule)
        SaveRules()
        BroadcastUpdatedRules()
    end
end)

net.Receive("Rules_Admin_DeleteRule", function(len, ply)
    if not IsPlayerAdmin(ply) then return end
    local category = net.ReadString()
    local ruleIndex = net.ReadUInt(32)
    if RulesDB[category] and RulesDB[category][ruleIndex] then
        table.remove(RulesDB[category], ruleIndex)
        SaveRules()
        BroadcastUpdatedRules()
    end
end)


-- Sohbet komutunu dinle
hook.Add("PlayerSay", "Rules_ChatCommand", function(ply, text)
    if string.lower(text) == RULES_CONFIG.Command then
        net.Start("Rules_OpenMenu")
        net.Send(ply)
        return ""
    end
end)

-- Oyuncu ilk kez girdiğinde menüyü aç
hook.Add("PlayerInitialSpawn", "Rules_FirstJoin", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            net.Start("Rules_OpenMenu")
            net.Send(ply)
        end
    end)
end)