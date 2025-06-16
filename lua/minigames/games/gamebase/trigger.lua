--[[--------------------------------------------
            Minigame Module - Trigger
--------------------------------------------]]--

local EmptyFunc = function() end

MinigameObject.__Triggers = {}

--[[----------------------------
        Trigger Functions
----------------------------]]--

function MinigameObject:AddTrigger(Trigger, AliasTable)
    self:Checker(Trigger, "entity", 1)

    if ( AliasTable ~= nil ) then
        self:Checker(AliasTable, "string", 2)

        if not self.__Triggers[ AliasTable ] then
            self.__Triggers[ AliasTable ] = {}

            self["GetAll" .. AliasTable] = function(copy)
                return ( copy == true ) and table.Copy( self.__Triggers[ AliasTable ] ) or self.__Triggers[ AliasTable ]
            end
        end

        table.insert( self.__Triggers[ AliasTable ], Trigger )

    else
        self.__Triggers[ Trigger ] = true
    end
end


function MinigameObject:GetTriggers(GetKeyValue)
    return ( GetKeyValue == true ) and table.GetKeys( self.__Triggers ) or self.__Triggers
end


function MinigameObject:CreateTrigger(Vec1, Vec2, StartTouch, EndTouch, Touch)
    self:Checker(Vec1, "vector", 1)
    self:Checker(Vec2, "vector", 2)

    if ( StartTouch ~= nil ) then
        self:Checker(StartTouch, "function", 3)
    else
        StartTouch = EmptyFunc
    end

    if ( EndTouch ~= nil ) then
        self:Checker(EndTouch, "function", 4)
    else
        EndTouch = EmptyFunc
    end

    if ( Touch ~= nil ) then
        self:Checker(Touch, "function", 5)
    else
        Touch = EmptyFunc
    end

    local Trigger = ents.Create("minigame_trigger")
    Trigger:Spawn()
    Trigger:Setup(self:GetOwner(), Vec1, Vec2, StartTouch, EndTouch, Touch)

    self:AddTrigger( Trigger )

    return Trigger
end