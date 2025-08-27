util.AddNetworkString("dex_bag_removetime")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/weapons/w_musor.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.NextUseTime = 0
    self.Lifetime = DEX_CONFIG.TimeBag
    self.RemoveTime = CurTime() + self.Lifetime

    self:BroadcastRemoveTime()

    timer.Simple(self.Lifetime, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

function ENT:BroadcastRemoveTime(ply)
    net.Start("dex_bag_removetime")
        net.WriteEntity(self)
        net.WriteFloat(self.RemoveTime)
    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

hook.Add("OnEntityCreated", "dex_bag_sync_removetime", function(ent)
    if not IsValid(ent) then return end

    timer.Simple(0.1, function()
        if not IsValid(ent) or ent:GetClass() ~= "dex_bag" then return end
        
        if ent.RemoveTime then
            ent:BroadcastRemoveTime()
        end
    end)
end)

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    if self.NextUseTime > CurTime() then return end
    self.NextUseTime = CurTime() + 1

    local swep = caller:GetWeapon("dex_w_bag")
    if not IsValid(swep) then
        caller:Give("dex_w_bag")
        caller:SelectWeapon("dex_w_bag")
        self:Remove()
    else
        caller:ChatPrint(DEX_LANG.Get("bag_warning"))
    end
end

hook.Add("PlayerInitialSpawn", "dex_bag_sync_existing", function(ply)
    timer.Simple(5, function()
        if not IsValid(ply) then return end
        
        for _, ent in pairs(ents.FindByClass("dex_bag")) do
            if IsValid(ent) and ent.RemoveTime then
                ent:BroadcastRemoveTime(ply)
            end
        end
    end)
end)

