--[[--------------------------------------------
            Minigame Module - Entity
--------------------------------------------]]--

MinigameObject.__Entities = {}
MinigameObject.__EntitiesAlias = {}

--[[----------------------------
        Entity Functions
----------------------------]]--

function MinigameObject:AddEntity(Ent, AliasTable)
    self:Checker(Ent, "entity", 1)

    if ( AliasTable ~= nil ) then
        self:Checker(AliasTable, "string", 2)

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
        return self.__Entities
    end


    if ( GetKeyValue == true ) then
        for _, Ent in ipairs( table.GetKeys( self.__Entities ) ) do
            if IsValid(Ent) then -- FIX: Entity validation
                table.insert( Entities, Ent )
            end
        end

        return Entities
    end

    if ( ClassTarget ~= nil ) then
        self:Checker(ClassTarget, "string", 2)

        for Ent, _ in pairs( self.__Entities ) do
            if IsValid(Ent) and ( Ent:GetClass() == ClassTarget ) then -- FIX: Entity validation
                table.insert( Entities, Ent )
            end
        end

        return Entities
    end

    -- Idk if the code reaches here
    return self.__Entities
end


function MinigameObject:GetAllEntities(AliasTable)
    self:Checker(AliasTable, "string", 1)

    if ( self.__EntitiesAlias[ AliasTable ] == nil ) then
        -- self.ThrowError("The alias table \"" .. AliasTable .. "\" does not exist.", nil, "Entity")
        self.__EntitiesAlias[ AliasTable ] = {}
    end

    return table.Copy( self.__EntitiesAlias[ AliasTable ] )
end

function MinigameObject:AliasTableExists(AliasTable)
    self:Checker(AliasTable, "string", 1)

    return ( self.__EntitiesAlias[ AliasTable ] ~= nil )
end


function MinigameObject:CreateEntity(Class, AliasTable)
    self:Checker(Class, "string", 1)

    -- FIX: Entity limit kontrolü
    local totalEntities = table.Count(self.__Entities)
    if totalEntities > 500 then
        self.ThrowError("Entity limit reached! Too many entities created.", totalEntities, "< 500")
        return NULL
    end

    local NewEntity = ents.Create( Class )
    if not IsValid( NewEntity ) then
        self.ThrowError("There was an error when creating the entity \"" .. Class .. "\".", NewEntity, "Entity")
    end

    NewEntity:Setowning_ent( self:GetOwner() )
    if CPPI then
        NewEntity:CPPISetOwner( self:GetOwner() )
    end

    local IndexAlias = self:AddEntity( NewEntity, AliasTable )

    return NewEntity, IndexAlias
end


function MinigameObject:RemoveEntityByIndex(Index, AliasTable, ForceDelete)
    self:Checker(Index, "number", 1)
    self:Checker(AliasTable, "string", 2)

    if ( self.__EntitiesAlias[ AliasTable ] == nil ) then
        self.ThrowError("The alias table \"" .. AliasTable .. "\" does not exist.", AliasTable, "Entity")
    end

    if ( self.__EntitiesAlias[ AliasTable ][ Index ] == nil ) then
        self.ThrowError("The entity with the index \"" .. Index .. "\" does not exist in the alias table \"" .. AliasTable .. "\".", Index, "Entity")
    end

    if ( ForceDelete == true ) then
        if IsValid(self.__EntitiesAlias[ AliasTable ][ Index ]) then -- FIX: Entity validation
            self.__EntitiesAlias[ AliasTable ][ Index ]:Remove()
        end
    end

    self.__EntitiesAlias[ AliasTable ][ Index ] = nil
end


function MinigameObject:RemoveAllEntities()
    for Ent, _ in pairs( self.__Entities ) do
        if IsValid(Ent) then -- FIX: Entity validation
            Ent:Remove()
        end
    end

    for AliasTable, Entities in pairs( self.__EntitiesAlias ) do
        for Index, Ent in ipairs( Entities ) do
            if IsValid(Ent) then -- FIX: Entity validation
                Ent:Remove()
            end
        end
    end

    self.__Entities = {}
    self.__EntitiesAlias = {}
end