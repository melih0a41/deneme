AddCSLuaFile()

SWEP.Primary = {ClipSize = -1, DefaultClip = -1, Delay = 2, Automatic = true, Ammo = "None"}
SWEP.Secondary = {ClipSize = -1, DefaultClip = -1, Delay = 2, Automatic = false, Ammo = "None"}
SWEP.Weight = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.UseHands = true
SWEP.Author = "Odinzz"
SWEP.Category = "Dex's Addons"
SWEP.Instructions = DEX_LANG.Get("knife_instructions")
SWEP.ViewModelFOV = 45
SWEP.ViewModel = "models/blood/v_cleaver.mdl"
SWEP.WorldModel = "models/blood/w_cleaver.mdl"
SWEP.PrintName = DEX_LANG.Get("knife_printname")
SWEP.HoldType = "knife"
SWEP.Slot = 0
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Attackdelay, SWEP.Idledelay = 0, 0
SWEP.LoopLock, SWEP.LoopLockidle = true, true
SWEP.NumFacadas, SWEP.MaxFacadas = 0, 8

function SWEP:Initialize()
    self:SetHoldType("knife")
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self.LoopLockidle = false
    self.Idledelay = CurTime() + 1.5

    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:EmitSound("weapons/knife/knife_deploy1.wav", 45)
    end
end

function SWEP:Holster()
    return true
end

function SWEP:CalcView(ply, pos, angles, fov)
    local view = {}
    view.origin = pos + angles:Right() * -5 + angles:Up() * 2
    view.angles = angles
    view.fov = fov
    
    return view
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + (owner:GetAimVector() * 75),
        filter = owner,
        mask = MASK_SHOT
    })

    local ent = tr.Entity
    local dmg = (ent:IsPlayer() and math.random(10, 25)) or 50
    local sound = (ent:IsPlayer() and "weapons/knife/knife_hit" .. math.random(1, 4) .. ".wav") or "weapons/knife/knife_hitwall1.wav"
    local force = 1

    local bullet = {
        Num = 1,
        Src = owner:GetShootPos(),
        Dir = owner:GetAimVector(),
        Spread = Vector(0, 0, 0),
        Tracer = 0,
        Force = force,
        Damage = dmg,
        Distance = 75
    }

    owner:FireBullets(bullet)
    owner:EmitSound(sound, 45)

    if not ent:IsPlayer() and CLIENT then
        util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end

    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self.Idledelay = CurTime() + 1
    self.LoopLockidle = false
end

if CLIENT then
    hook.Add("CalcView", "DexKnifeCalcView", function(ply, pos, angles, fov)
        local wep = ply:GetActiveWeapon()
        
        if IsValid(wep) and wep:GetClass() == "dex_butcher_knife" then
            if wep.CalcView then
                return wep:CalcView(ply, pos, angles, fov)
            end
        end
    end)
end