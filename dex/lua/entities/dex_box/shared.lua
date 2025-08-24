ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = DEX_LANG.Get("box_print_name")
ENT.Author = "Odinzz"
ENT.Contact = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Category = "Dex's Addons"

ENT.MaxGlassStorage = 47
ENT.InteractionDistance = 100

function ENT:IsInRange(ply)
    if not IsValid(ply) then return false end
    return self:GetPos():Distance(ply:GetPos()) <= self.InteractionDistance
end

function ENT:CanPlayerInteract(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if not self:IsInRange(ply) then return false end
    
    if SERVER and self.ViewingPlayer and IsValid(self.ViewingPlayer) and self.ViewingPlayer ~= ply then
        return false
    end
    
    return true
end

function ENT:GetStoredGlassCount()
    if not self.StoredGlass then return 0 end
    return #self.StoredGlass
end

function ENT:IsFull()
    return self:GetStoredGlassCount() >= self.MaxGlassStorage
end

function ENT:IsEmpty()
    return self:GetStoredGlassCount() == 0
end