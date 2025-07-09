/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local tHook = {}

if DarkRP then
    tHook[ "playerBoughtCustomEntity" ] = function( pPlayer, tEntTable, eEntity, iPrice )
        if ( eEntity:GetClass() == "oneprint" ) then
            eEntity:SetOwnerObject( pPlayer )
            eEntity:CPPISetOwner( pPlayer )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

            pPlayer.tOwnedPrinters = ( pPlayer.tOwnedPrinters or {} )
            table.insert( pPlayer.tOwnedPrinters, eEntity )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

            if GSmartWatch then
                OnePrint:UpdateGSmartWatch( pPlayer )
            end            
        end
    end
end

tHook[ "PlayerSpawnedSENT" ] = function( pPlayer, eEntity )
    if ( eEntity:GetClass() == "oneprint" ) then
        eEntity:SetOwnerObject( pPlayer )

        pPlayer.tOwnedPrinters = ( pPlayer.tOwnedPrinters or {} )
        table.insert( pPlayer.tOwnedPrinters, eEntity )

        if GSmartWatch then
            OnePrint:UpdateGSmartWatch( pPlayer )
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

for k, v in pairs( tHook ) do
    hook.Add( k, "OnePrint_" .. k, v )
end

hook.Add("PlayerChangedTeam", "OnePrint_RemovePrinterOnJobChange", function(ply, oldTeam, newTeam)
    -- Oyuncunun yeni mesleğinin adını al
    local newTeamName = team.GetName(newTeam)

    -- Yeni mesleğin yazıcı kullanma iznini kontrol et
    -- OnePrint.Cfg.CanUsePrinter["*"] true değilse ve yeni meslek tabloda yoksa veya false ise izin yoktur.
    local canUse = OnePrint.Cfg.CanUsePrinter["*"] or OnePrint.Cfg.CanUsePrinter[newTeamName]

    -- Eğer yeni mesleğin izni yoksa veya izin durumu false olarak belirtilmişse
    if not canUse then
        -- Oyuncunun sahip olduğu yazıcılar var mı kontrol et (bu tablo hooks.lua içinde tanımlanmış olmalı)
        if ply.tOwnedPrinters and #ply.tOwnedPrinters > 0 then
            -- Sahip olduğu yazıcıları döngüye al
            -- Not: Döngü sırasında tabloyu değiştirmek sorunlara yol açabileceğinden, silinecekleri ayrı bir listede toplayıp sonra silmek daha güvenli olabilir.
            local printersToRemove = {}
            for _, printerEnt in ipairs(ply.tOwnedPrinters) do
                if IsValid(printerEnt) and printerEnt:GetClass() == "oneprint" then
                     table.insert(printersToRemove, printerEnt)
                end
            end

            -- Silinecek yazıcıları sil
            for _, printerEnt in ipairs(printersToRemove) do
                SafeRemoveEntity(printerEnt)
                -- İsteğe bağlı: Oyuncunun sahip olduğu yazıcılar listesinden de kaldır
                if ply.tOwnedPrinters then
                     table.RemoveByValue(ply.tOwnedPrinters, printerEnt)
                end
                print("[OnePrint] " .. ply:Nick() .. " isimli oyuncunun meslek değiştirmesi nedeniyle yazıcısı silindi.")
            end

             -- Eğer GSmartWatch kullanılıyorsa güncelleme yap (hooks.lua'daki gibi)
            if GSmartWatch and OnePrint and OnePrint.UpdateGSmartWatch then
                OnePrint:UpdateGSmartWatch( ply )
            end
        end
    end
end)
-- Bu kodu oneprint_v1.1.2/lua/oneprint/server/hooks.lua dosyasının sonuna ekleyin

-- Oyuncu girdiğinde printer sahipliklerini güncelle
hook.Add("PlayerInitialSpawn", "OnePrint_UpdatePrinterOwnership", function(ply)
    timer.Simple(2, function() -- Oyuncu tam yüklensin diye bekle
        if not IsValid(ply) then return end
        
        -- Bu oyuncunun SteamID'si ile printer'ları bul ve sahipliği güncelle
        local steamID = ply:SteamID64()
        ply.tOwnedPrinters = ply.tOwnedPrinters or {}
        
        for _, ent in ipairs(ents.FindByClass("oneprint")) do
            if IsValid(ent) then
                local owner = ent:GetOwnerObject()
                
                -- Eğer printer'ın sahibi yok veya geçersizse, SteamID kontrolü yap
                if not IsValid(owner) then
                    -- Bu printer'ın gerçek sahibini bul (CPPI veya diğer yöntemlerle)
                    local realOwner = ent:CPPIGetOwner()
                    if IsValid(realOwner) and realOwner:SteamID64() == steamID then
                        -- Sahipliği güncelle
                        ent:SetOwnerObject(ply)
                        table.insert(ply.tOwnedPrinters, ent)
                        print("[OnePrint] " .. ply:Nick() .. " için printer sahipliği güncellendi.")
                    end
                elseif IsValid(owner) and owner:SteamID64() == steamID and owner ~= ply then
                    -- Aynı SteamID ama farklı player instance
                    ent:SetOwnerObject(ply)
                    table.insert(ply.tOwnedPrinters, ent)
                    print("[OnePrint] " .. ply:Nick() .. " için printer sahipliği güncellendi (farklı instance).")
                elseif owner == ply then
                    -- Zaten doğru sahip, listeye ekle
                    table.insert(ply.tOwnedPrinters, ent)
                end
            end
        end
        
        -- GSmartWatch güncellemesi
        if GSmartWatch and OnePrint and OnePrint.UpdateGSmartWatch then
            OnePrint:UpdateGSmartWatch(ply)
        end
    end)
end)
