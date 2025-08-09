AddCSLuaFile("shared.lua")

-- This Swep was created by [Alpha}Florian on steam, for his darkrp Server Polya RP, please, make sure to let his copyright into his files. thanks.

if CLIENT then
SWEP.PrintName = "Cat Swep"
SWEP.Category         = "[Alpha}Florian"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false
end

SWEP.Spawnable = true -- If you and others can see this in weapon spawn menu (Q---> Weapons)
SWEP.AdminSpawnable = true -- It it's spawnable for admin or superadmins, server settings influence on this
SWEP.HoldType = "knife"
SWEP.Author = "Kedi Swep"
SWEP.Purpose = "Animals Jobs for darkrp"
SWEP.Instructions = "Left mouse to attack, right mouse for angry barking, reload for friendly barking."

SWEP.ViewModel = "" -- WARNING! Here you can set up a view model of the weapon (how you see it when you take it)
SWEP.WorldModel = "" -- WARNING! Here you can set up a world model of the weapon (how others see it when you take it)

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.5 -- WARNING! Here you can set up the interval between attacks

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Precache()
	util.PrecacheModel(self.ViewModel)

    util.PrecacheSound("catswep/growl.wav")
    util.PrecacheSound("catswep/hiss.wav")
    util.PrecacheSound("catswep/meow.wav")
    util.PrecacheSound("catswep/purr.wav")
    util.PrecacheSound("catswep/scratch.wav")
    util.PrecacheSound("catswep/scream.wav")
end

function SWEP:Think()
    if not self.NextHit or CurTime() < self.NextHit then return end
    self.NextHit = nil

    local pl = self.Owner

    local vStart = pl:EyePos() + Vector(0, 0, -10)
    local trace = util.TraceLine({start=vStart, endpos = vStart + pl:GetAimVector() * 71, filter = pl, mask = MASK_SHOT})

    local ent
    if trace.HitNonWorld then
        ent = trace.Entity
    elseif self.PreHit and self.PreHit:IsValid() and not (self.PreHit:IsPlayer() and not self.PreHit:Alive()) and self.PreHit:GetPos():Distance(vStart) < 110 then
        ent = self.PreHit
        trace.Hit = true
    end

    if trace.Hit then
        pl:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav")   ---------------------- WARNING! Here you can set up swinging sounds of the weapon
    end

    pl:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav")   ---------------------------- WARNING! Here you can set up missing sounds of the weapon
    self.PreHit = nil

    if ent and ent:IsValid() and not (ent:IsPlayer() and not ent:Alive()) then
            local damage = 10 -- WARNING! Here you can set change damage numbers of the weapon
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
                local vel = damage * 487 * pl:GetAimVector()

                phys:ApplyForceOffset(vel, (ent:NearestPoint(pl:GetShootPos()) + ent:GetPos() * 2) / 3)
                ent:SetPhysicsAttacker(pl)
            end
            if not CLIENT and SERVER then
            ent:TakeDamage(damage, pl, self)
        end
    end
end

SWEP.NextSwing = 0
function SWEP:PrimaryAttack()
    if CurTime() < self.NextSwing then return end
	
	local attack = math.random(1,2)
	if attack == 1 then self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) else
	if attack == 2 then self:SendWeaponAnim(ACT_VM_HITCENTER) end
end
	
	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
	
    self.Owner:EmitSound("catswep/scream.wav") ----------------------------- WARNING! Here you can change the sounds playing with left mouse button
	timer.Simple(1.4, function(wep) self:SendWeaponAnim(ACT_VM_IDLE) end)
    self.NextSwing = CurTime() + self.Primary.Delay
    self.NextHit = CurTime() + 1
    local vStart = self.Owner:EyePos() + Vector(0, 0, -10)
    local trace = util.TraceLine({start=vStart, endpos = vStart + self.Owner:GetAimVector() * 65, filter = self.Owner, mask = MASK_SHOT})
    if trace.HitNonWorld then
        self.PreHit = trace.Entity
    end
end

SWEP.NextMoan = 0
function SWEP:SecondaryAttack()
    if CurTime() < self.NextMoan then return end

	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
	
    if SERVER and not CLIENT then
        self.Owner:EmitSound("catswep/meow.wav") -- WARNING! Here you can change the sounds playing with right mouse button
    end
    self.NextMoan = CurTime() + 2.5 --- WARNING! Here you can change the inverval between sounds playing with right mouse button and reload buttons, you HAVE TO CHANGE BOTH FOR THIS TO WORK! (2nd one is below)
end

function SWEP:Reload()
    if CurTime() < self.NextMoan then return end

	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
	
    if SERVER and not CLIENT then
        self.Owner:EmitSound("catswep/growl.wav") -- WARNING! Here you can change the sounds playing with reload button
    end
    self.NextMoan = CurTime() + 2.5 --- WARNING! Here you can change the inverval between sounds playing with right mouse button and reload buttons, you HAVE TO CHANGE BOTH FOR THIS TO WORK! (1st one is above)
end