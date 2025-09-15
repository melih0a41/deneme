-- PropHP Silah Sistemi Yükleyici
-- Dosya Yolu: addons/partysystem/lua/autorun/prophp_weapon_loader.lua
-- Bu dosya silahları otomatik yükler

-- Silahları yükle
local function LoadPropHPWeapons()
    local weaponFiles = file.Find("prophp_weapons/*.lua", "LUA")
    
    for _, filename in pairs(weaponFiles) do
        local weaponPath = "prophp_weapons/" .. filename
        
        if SERVER then
            AddCSLuaFile(weaponPath)
        end
        
        -- Silah kodunu yükle
        SWEP = {}
        include(weaponPath)
        
        -- Silah adını dosya adından al (weapon_ ile başlamalı)
        local weaponName = string.StripExtension(filename)
        
        -- Silahı kaydet
        if SWEP and SWEP.PrintName then
            weapons.Register(SWEP, weaponName)
            
            if SERVER then
                print("[PropHP Weapons] Silah yüklendi: " .. weaponName)
            end
        end
        
        SWEP = nil
    end
end

-- Yüklemeyi başlat
hook.Add("Initialize", "PropHP_LoadWeapons", function()
    LoadPropHPWeapons()
    
    if SERVER then
        print("[PropHP Weapons] Silah sistemi başarıyla yüklendi!")
        
        -- Spawn menüsüne ekle
        timer.Simple(1, function()
            -- Admin silahları kategorisi
            local weapons_list = weapons.GetList()
            for _, wep in pairs(weapons_list) do
                if wep.ClassName and string.find(wep.ClassName, "weapon_prophp_") then
                    -- Spawn menüsüne ekle
                    list.Add("Weapon", {
                        ClassName = wep.ClassName,
                        PrintName = wep.PrintName or wep.ClassName,
                        Category = "PropHP Raid",
                        Author = "PropHP System",
                        Spawnable = true
                    })
                end
            end
        end)
    end
end)

-- Oyuncu spawn olduğunda kontrol
if SERVER then
    hook.Add("PlayerSpawn", "PropHP_WeaponCheck", function(ply)
        timer.Simple(0.5, function()
            if not IsValid(ply) then return end
            
            -- Raid kontrolü
            if PropHP and PropHP.IsPlayerInAnyRaid then
                local inRaid, raidID = PropHP.IsPlayerInAnyRaid(ply)
                
                if inRaid then
                    -- NLR kontrolü
                    if not PropHP.IsPlayerNLR(ply) then
                        -- Config'den otomatik silah verme kontrolü
                        if PropHP.Config and PropHP.Config.Raid and PropHP.Config.Raid.AutoGiveWeapons then
                            if not ply:HasWeapon("weapon_prophp_ar2") then
                                ply:Give("weapon_prophp_ar2")
                                ply:ChatPrint("[RAID] Prop kırma silahı verildi!")
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    -- Chat komutları
    hook.Add("PlayerSay", "PropHP_WeaponCommands", function(ply, text)
        local args = string.Explode(" ", text:lower())
        
        if args[1] == "!raidsilah" or args[1] == "!raidgun" then
            -- Raid kontrolü
            if PropHP and PropHP.IsPlayerInAnyRaid then
                local inRaid, raidID = PropHP.IsPlayerInAnyRaid(ply)
                
                if inRaid then
                    -- NLR kontrolü
                    if PropHP.IsPlayerNLR and PropHP.IsPlayerNLR(ply) then
                        ply:ChatPrint("NLR nedeniyle silah alamazsınız!")
                        return ""
                    end
                    
                    if not ply:HasWeapon("weapon_prophp_ar2") then
                        ply:Give("weapon_prophp_ar2")
                        ply:ChatPrint("Prop kırma silahı verildi!")
                    else
                        ply:ChatPrint("Zaten bu silaha sahipsiniz!")
                    end
                else
                    ply:ChatPrint("Raid'de değilsiniz!")
                end
            else
                ply:ChatPrint("Raid sistemi aktif değil!")
            end
            
            return ""
        elseif args[1] == "!silahlar" or args[1] == "!weapons" then
            ply:ChatPrint("=== PROPHP SİLAHLARI ===")
            
            local weapons_list = weapons.GetList()
            for _, wep in pairs(weapons_list) do
                if wep.ClassName and string.find(wep.ClassName, "weapon_prophp_") then
                    ply:ChatPrint("• " .. (wep.PrintName or wep.ClassName))
                end
            end
            
            ply:ChatPrint("Kullanım: !raidsilah")
            return ""
        end
    end)
end

-- Client tarafı HUD eklentisi
if CLIENT then
    hook.Add("HUDPaint", "PropHP_WeaponHUD", function()
        local wep = LocalPlayer():GetActiveWeapon()
        
        if IsValid(wep) and wep:GetClass() and string.find(wep:GetClass(), "weapon_prophp_") then
            -- Silah aktifse raid durumunu göster
            local x = ScrW() - 150
            local y = 100
            
            -- Arka plan
            draw.RoundedBox(5, x - 50, y, 200, 30, Color(0, 0, 0, 150))
            
            -- Raid durumu
            local text = "RAID GEREKLİ"
            local color = Color(255, 100, 100)
            
            if PropHP_Client and PropHP_Client.RaidData then
                if PropHP_Client.RaidData.preparation then
                    text = "HAZIRLIK"
                    color = Color(255, 255, 100)
                elseif PropHP_Client.RaidData.active then
                    text = "RAID AKTİF"
                    color = Color(100, 255, 100)
                end
            elseif PropHP_Client and PropHP_Client.LootingPhase then
                text = "YAĞMA"
                color = Color(255, 150, 50)
            end
            
            draw.SimpleText(text, "DermaDefault", x + 50, y + 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)
end