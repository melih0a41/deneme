include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function SWEP:Initialize()
    self:SetWeaponHoldType("duel")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local spawnPos = owner:GetPos() + owner:GetForward() * 50 + Vector(-10, 0, 80)

    local ent = ents.Create("dex_bag")
    if not IsValid(ent) then return end

    ent:SetPos(spawnPos)
    ent:Spawn()
    ent:Activate()

    ent.DexOwner = owner

    self:Remove()

    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local vm = owner:GetViewModel()
    if IsValid(vm) then
        vm:ResetSequence(0)
        vm:SetPlaybackRate(1)
    end
end
