--[[------------------------------------------------
                    Minigame Brush 
------------------------------------------------]]--

AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "brush"

ENT.FuncStart = function() end
ENT.FuncTouch = function() end
ENT.FuncEnd = function() end


--[[------------------------------------------------
                        Owner
------------------------------------------------]]--

function ENT:GetOwner()
    return self:Getowning_ent()
end


--[[------------------------------------------------
                      Functions
------------------------------------------------]]--

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end


function ENT:IsActive()
    local GameScript = Minigames.GetOwnerGame( self:Getowning_ent() )
    return ( GameScript ~= nil ) and GameScript:IsActive()
end


if ( SERVER ) then

    function ENT:Setup( Owner, Vec1, Vec2, StartTouch, EndTouch, Touch )
        self.StartTouch = StartTouch
        self.EndTouch = EndTouch
        self.Touch = Touch

        self:SetCollisionBoundsWS( Vec1, Vec2 )
        self:Setowning_ent( Owner )
    end

    function ENT:Initialize()
        self:SetSolid( SOLID_BBOX )
        self:SetCollisionBoundsWS( vector_origin, vector_up )
    end

end