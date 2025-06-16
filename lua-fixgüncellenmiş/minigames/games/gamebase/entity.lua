--[[--------------------------------------------
        COMPLETE ENTITY SYSTEM FIX
        Bu dosyayı entity.lua'nın üzerine yazın
--------------------------------------------]]--

-- Debug için yükleme kontrolü
print("[Minigames Debug] Entity.lua yükleniyor...")

-- MinigameObject'in var olup olmadığını kontrol et
if not MinigameObject then
    print("[Minigames] HATA: MinigameObject bulunamadı!")
    
    -- Geç yükleme denemesi
    timer.Simple(1, function()
        if MinigameObject then
            print("[Minigames] MinigameObject geç yükleme ile bulundu, entity sistemini başlatılıyor...")
            include("minigames/games/gamebase/entity.lua")
        else
            print("[Minigames] HATA: MinigameObject hala bulunamadı!")
        end
    end)
    return
end

print("[Minigames Debug] MinigameObject bulundu, entity sistemi başlatılıyor...")

-- Güvenli başlatma
MinigameObject.__Entities = MinigameObject.__Entities or {}
MinigameObject.__EntitiesAlias = MinigameObject.__EntitiesAlias or {}

--[[----------------------------
        Entity Functions
----------------------------]]--

function MinigameObject:AddEntity(Ent, AliasTable)
    -- Güvenli checker kullanımı
    if self.Checker then
        self:Checker(Ent, "entity", 1)
    elseif not IsValid(Ent) then
        error("[Minigames] Invalid entity passed to AddEntity")
        return
    end

    if ( AliasTable ~= nil ) then
        if self.Checker then
            self:Checker(AliasTable, "string", 2)
        elseif type(AliasTable) ~= "string" then
            error("[Minigames] AliasTable must be string")
            return
        end

        if not self.__EntitiesAlias[ AliasTable ] then
            self.__EntitiesAlias[ AliasTable ] = {}

            self["GetAll" .. AliasTable] = function(copy)
                return ( copy == true ) and table.Copy( self.__EntitiesAlias[ AliasTable ] ) or self.__EntitiesAlias[ AliasTable ]
            end
        end

        local Index = table.insert( self.__EntitiesAlias[ AliasTable ], Ent )
        return Index
    else
        self.__Entities[ Ent ] = true
    end
end

function MinigameObject:GetEntities(GetKeyValue, ClassTarget)
    local Entities = {}

    if ( GetKeyValue == nil ) and ( ClassTarget == nil ) then
        return self.__Entities or {}
    end

    if ( GetKeyValue == true ) then
        if self.__Entities then
            for _, Ent in ipairs( table.GetKeys( self.__Entities ) ) do
                if IsValid(Ent) then
                    table.insert( Entities, Ent )
                end
            end
        end
        return Entities
    end

    if ( ClassTarget ~= nil ) then
        if self.Checker then
            self:Checker(ClassTarget, "string", 2)
        end

        if self.__Entities then
            for Ent, _ in pairs( self.__Entities ) do
                if IsValid(Ent) and ( Ent:GetClass() == ClassTarget ) then
                    table.insert( Entities, Ent )
                end
            end
        end
        return Entities
    end

    return self.__Entities or {}
end

function MinigameObject:GetAllEntities(AliasTable)
    if self.Checker then
        self:Checker(AliasTable, "string", 1)
    end

    if not self.__EntitiesAlias then
        self.__EntitiesAlias = {}
    end

    if ( self.__EntitiesAlias[ AliasTable ] == nil ) then
        self.__EntitiesAlias[ AliasTable ] = {}
    end

    return table.Copy( self.__EntitiesAlias[ AliasTable ] )
end

function MinigameObject:AliasTableExists(AliasTable)
    if self.Checker then
        self:Checker(AliasTable, "string", 1)
    end

    return self.__EntitiesAlias and ( self.__EntitiesAlias[ AliasTable ] ~= nil )
end

function MinigameObject:CreateEntity(Class, AliasTable)
    if self.Checker then
        self:Checker(Class, "string", 1)
    elseif type(Class) ~= "string" then
        error("[Minigames] Entity class must be string")
        return NULL, nil
    end

    -- Entity limit kontrolü (güvenli)
    local totalEntities = 0
    if self.__Entities then
        totalEntities = table.Count(self.__Entities)
    end
    
    -- Config'den limit al, yoksa default kullan
    local maxEntities = 250
    if Minigames and Minigames.Config and isnumber(Minigames.Config["MaxEntitiesPerGame"]) then
        maxEntities = Minigames.Config["MaxEntitiesPerGame"]
    end
    
    if totalEntities >= maxEntities then
        local errorMsg = "Entity limit reached! Maximum " .. maxEntities .. " entities per game."
        if self.ThrowError then
            self.ThrowError(errorMsg, totalEntities, "< " .. maxEntities)
        else
            print("[Minigames] " .. errorMsg)
        end
        return NULL, nil
    end

    -- Entity oluştur
    local NewEntity = ents.Create( Class )
    if not IsValid( NewEntity ) then
        local errorMsg = "Failed to create entity: " .. Class
        if self.ThrowError then
            self.ThrowError(errorMsg, NewEntity, "Valid Entity")
        else
            print("[Minigames] " .. errorMsg)
        end
        return NULL, nil
    end

    -- Owner ayarla
    if self.GetOwner and IsValid(self:GetOwner()) then
        NewEntity:Setowning_ent( self:GetOwner() )
        if CPPI then
            NewEntity:CPPISetOwner( self:GetOwner() )
        end
    end

    -- Auto cleanup
    if IsValid(NewEntity) then
        NewEntity:CallOnRemove("MinigamesEntityCleanup", function()
            if self.__Entities and self.__Entities[NewEntity] then
                self.__Entities[NewEntity] = nil
            end
            -- Alias tablosundan da temizle
            if self.__EntitiesAlias then
                for aliasName, aliasTable in pairs(self.__EntitiesAlias) do
                    for i, ent in ipairs(aliasTable) do
                        if ent == NewEntity then
                            table.remove(aliasTable, i)
                            break
                        end
                    end
                end
            end
        end)
    end

    local IndexAlias = self:AddEntity( NewEntity, AliasTable )
    return NewEntity, IndexAlias
end

function MinigameObject:RemoveEntityByIndex(Index, AliasTable, ForceDelete)
    if self.Checker then
        self:Checker(Index, "number", 1)
        self:Checker(AliasTable, "string", 2)
    end

    if not self.__EntitiesAlias or not self.__EntitiesAlias[ AliasTable ] then
        local errorMsg = "Alias table does not exist: " .. (AliasTable or "nil")
        if self.ThrowError then
            self.ThrowError(errorMsg, AliasTable, "Valid alias table")
        else
            print("[Minigames] " .. errorMsg)
        end
        return
    end

    if not self.__EntitiesAlias[ AliasTable ][ Index ] then
        local errorMsg = "Entity index " .. Index .. " does not exist in alias table " .. AliasTable
        if self.ThrowError then
            self.ThrowError(errorMsg, Index, "Valid index")
        else
            print("[Minigames] " .. errorMsg)
        end
        return
    end

    local entity = self.__EntitiesAlias[ AliasTable ][ Index ]
    
    if ( ForceDelete == true ) and IsValid(entity) then
        entity:Remove()
    end

    self.__EntitiesAlias[ AliasTable ][ Index ] = nil
end

function MinigameObject:RemoveAllEntities()
    -- Ana entity tablosunu temizle
    if self.__Entities then
        for Ent, _ in pairs( self.__Entities ) do
            if IsValid(Ent) then
                Ent:Remove()
            end
        end
        self.__Entities = {}
    end

    -- Alias tablolarını temizle
    if self.__EntitiesAlias then
        for AliasTable, Entities in pairs( self.__EntitiesAlias ) do
            if istable(Entities) then
                for Index, Ent in ipairs( Entities ) do
                    if IsValid(Ent) then
                        Ent:Remove()
                    end
                end
            end
        end
        self.__EntitiesAlias = {}
    end
end

-- Başarılı yükleme mesajı
print("[Minigames] Entity sistemi başarıyla yüklendi!")

-- Test fonksiyonu
if SERVER then
    timer.Simple(2, function()
        if MinigameObject and MinigameObject.CreateEntity then
            print("[Minigames] Entity sistemi test: BAŞARILI")
        else
            print("[Minigames] Entity sistemi test: BAŞARISIZ")
        end
    end)
end