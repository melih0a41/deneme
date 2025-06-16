--[[------------------------------------------------
                        BASE
------------------------------------------------]]--
AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Spawnable = false
ENT.AdminOnly = true
-- ENT.Type = "anim"
-- ENT.Base = "base_anim"

ENT.Category = "Minigame Tool Assistant"

ENT.PhysicsDisabled = true


--[[------------------------------------------------
                    Configuration
------------------------------------------------]]--

ENT.STATES = {
   [-12] = Color(200, 200, 200),
    [-2] = color_white,
    [-1] = Color(0, 0, 0),
    [ 0] = Color(0, 0, 0),
    [ 1] = Color(0, 220, 0),
    [11] = Color(0, 120, 0),
    [ 2] = Color(255, 30, 30),
    [12] = Color(180, 0, 0),
    [ 3] = Color(50, 50, 250),
    [13] = Color(0, 0, 160),
    [ 4] = Color(0, 255, 200),
    [14] = Color(20, 130, 100),
    [ 5] = Color(220, 220, 40),
    [15] = Color(140, 140, 0),
    [ 6] = Color(255, 115, 0),
    [16] = Color(130, 80, 20),
    [ 7] = Color(240, 50, 240),
    [17] = Color(130, 0, 130),
}


--[[------------------------------------------------
                    Functions
------------------------------------------------]]--

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Entity", 0, "owning_ent")

    if ( SERVER ) then
        self:NetworkVarNotify("State", self.OnVarChanged)
    end
end

function ENT:Initialize()
    self:SetCustomCollisionCheck(true)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:DrawShadow(false)

    if SERVER and not self.PhysicsDisabled then
        self:PhysicsInit(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end

function ENT:OnVarChanged(name, old, new)
    self:SetColor( self.STATES[new] or ENT.STATES[-1] )

    if ( new == 0 ) then
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        self:SetRenderMode(RENDERMODE_NONE)
    else
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetRenderMode(RENDERMODE_NORMAL)
    end
end

function ENT:SetType(ClassName)
    if CLIENT then return end

    hook.Add("OnPhysgunPickup", ClassName, function(ply, ent)
        if ent:GetClass() == ClassName then
            return false
        end
    end)

    hook.Add("GravGunPickupAllowed", ClassName, function(ply, ent)
        if ent:GetClass() == ClassName then
            return false
        end
    end)
end

local NotAllowed = {
    ["remover"] = true
}
function ENT:CanTool(ply, tr, tool, tooltbl, button)
    if NotAllowed[tool] then
        return false
    end

    return true
end

if ( SERVER ) then

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end

    function ENT:IsActive()
        local GameScript = Minigames.GetOwnerGame(self:Getowning_ent())
        return GameScript and GameScript:IsActive() or false
    end

    hook.Add("PhysgunDrop", "Minigames.PreventPickup", function(ply, ent)
        if ent.Base == "minigame_square_base" then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end
        end
    end)

elseif ( CLIENT ) then

    function ENT:Draw()
        self:DrawModel()
    end

end