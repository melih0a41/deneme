function SWEP:CanBackstab(melee2, ent)
    if !self:GetBuff_Override("Override_Backstab", self.Backstab) then return false end
    local reach = 32 + self:GetBuff_Add("Add_MeleeRange") + (melee2 and self.Melee2Range or self.MeleeRange)

    if (!IsValid(ent)) then
        local tr = util.TraceLine({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = {self:GetOwner()},
            mask = MASK_SHOT_HULL
        })
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            ent = tr.Entity
        end
    end

    if (!IsValid(ent)) then
        local tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = {self:GetOwner()},
            mins = Vector(-16, -16, -8),
            maxs = Vector(16, 16, 8),
            mask = MASK_SHOT_HULL
        })
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            ent = tr.Entity
        end
    end

    if IsValid(ent) then
        local angle = math.NormalizeAngle(self:GetOwner():GetAngles().y - ent:GetAngles().y)
        return angle <= 90 and angle >= -90
    end

    return false
end

function SWEP:DoLunge(melee2)
    if ArcCW.ConVars["override_lunge_off"]:GetBool() then return end
    local var = self:GetBuff_Override("Override_Lunge", self.Lunge)
    if var == false or var == nil and self.PrimaryBash then return end
    if !self:GetOwner():IsPlayer() or self:GetOwner():Crouching() then return end

    local reach = 32 + self:GetBuff_Add("Add_MeleeRange") + (melee2 and self.Melee2Range or self.MeleeRange)
    local tr = self:GetOwner():GetEyeTrace()
    local tgt = tr.Entity

    if IsValid(tgt) and (tgt:IsPlayer() or tgt:IsNPC() or tgt:IsNextBot()) then

        local dist = (tr.HitPos - tr.StartPos):Length()

        if dist > reach and dist < reach + self:GetBuff("LungeLength") then
            local dir = tr.Normal
            dir.z = math.min(dir.z, 0)
            dir:Normalize()
            self:GetOwner():SetVelocity(dir * (self:GetOwner():IsOnGround() and 5 or 2.5) * dist)
        end
    end
end

function SWEP:Bash(melee2)
    melee2 = melee2 or false
    if self:GetState() == ArcCW.STATE_SIGHTS
            or (self:GetState() == ArcCW.STATE_SPRINT and !self:CanShootWhileSprint())
            or self:GetState() == ArcCW.STATE_CUSTOMIZE then
        return
    end
    if self:GetNextPrimaryFire() > CurTime() or self:GetGrenadePrimed() or self:GetPriorityAnim() then return end

    if !self.CanBash and !self:GetBuff_Override("Override_CanBash") then return end

    self:GetBuff_Hook("Hook_PreBash")

    self.Primary.Automatic = true

    local mult = self:GetBuff_Mult("Mult_MeleeTime")
    local mt = self.MeleeTime * mult

    if melee2 then
        mt = self.Melee2Time * mult
    end

    mt = mt * self:GetBuff_Mult("Mult_MeleeWaitTime")

    local bashanim = "bash"
    local canbackstab = self:CanBackstab(melee2)

    if melee2 then
        bashanim = canbackstab and self:SelectAnimation("bash2_backstab") or self:SelectAnimation("bash2") or bashanim
    else
        bashanim = canbackstab and self:SelectAnimation("bash_backstab") or self:SelectAnimation("bash") or bashanim
    end

    bashanim = self:GetBuff_Hook("Hook_SelectBashAnim", bashanim) or bashanim

    if bashanim and self.Animations[bashanim] then
        if SERVER then self:PlayAnimation(bashanim, mult, true, 0, true) end
    else
        self:ProceduralBash()

        self:MyEmitSound(self.MeleeSwingSound, 75, 100, 1, CHAN_USER_BASE + 1)
    end

    if CLIENT then
        self:OurViewPunch(-self.BashPrepareAng * 0.05)
    end
    self:SetNextPrimaryFire(CurTime() + mt )

    if melee2 then
        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
        else
            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
        end
    else
        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
        else
            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
        end
    end

    local mat = self.MeleeAttackTime

    if melee2 then
        mat = self.Melee2AttackTime
    end

    mat = mat * self:GetBuff_Mult("Mult_MeleeAttackTime") * math.pow(mult, 1.5)

    self:SetTimer(mat or (0.125 * mt), function()
        if !IsValid(self) then return end
        if !IsValid(self:GetOwner()) then return end
        if self:GetOwner():GetActiveWeapon() != self then return end

        if CLIENT then
            self:OurViewPunch(-self.BashAng * 0.05)
        end

        self:MeleeAttack(melee2)
    end)

    self:DoLunge()
end

function SWEP:MeleeAttack(melee2)
    local reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.MeleeRange
    local dmg = self:GetBuff_Override("Override_MeleeDamage", self.MeleeDamage) or 20

    if melee2 then
        reach = 32 + self:GetBuff_Add("Add_MeleeRange") + self.Melee2Range
        dmg = self:GetBuff_Override("Override_MeleeDamage", self.Melee2Damage) or 20
    end

    dmg = dmg * self:GetBuff_Mult("Mult_MeleeDamage")

    self:GetOwner():LagCompensation(true)

    local filter = {self:GetOwner()}

    table.Add(filter, self.Shields)

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
        filter = filter,
        mask = MASK_SHOT_HULL
    })

    if (!IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = filter,
            mins = Vector(-16, -16, -8),
            maxs = Vector(16, 16, 8),
            mask = MASK_SHOT_HULL
        })
    end

    -- Backstab damage if applicable
    local backstab = tr.Hit and self:CanBackstab(melee2, tr.Entity)
    if backstab then
        if melee2 then
            local bs_dmg = self:GetBuff_Override("Override_Melee2DamageBackstab", self.Melee2DamageBackstab)
            if bs_dmg then
                dmg = bs_dmg * self:GetBuff_Mult("Mult_MeleeDamage")
            else
                dmg = dmg * self:GetBuff("BackstabMultiplier") * self:GetBuff_Mult("Mult_MeleeDamage")
            end
        else
            local bs_dmg = self:GetBuff_Override("Override_MeleeDamageBackstab", self.MeleeDamageBackstab)
            if bs_dmg then
                dmg = bs_dmg * self:GetBuff_Mult("Mult_MeleeDamage")
            else
                dmg = dmg * self:GetBuff("BackstabMultiplier") * self:GetBuff_Mult("Mult_MeleeDamage")
            end
        end
    end

    -- We need the second part for single player because SWEP:Think is ran shared in SP
    if !(game.SinglePlayer() and CLIENT) then
        if tr.Hit then
            if tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsPlayer() then
                self:MyEmitSound(self.MeleeHitNPCSound, 75, 100, 1, CHAN_USER_BASE + 2)
            else
                self:MyEmitSound(self.MeleeHitSound, 75, 100, 1, CHAN_USER_BASE + 2)
            end

            if tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_BLOODYFLESH then
                local fx = EffectData()
                fx:SetOrigin(tr.HitPos)

                util.Effect("BloodImpact", fx)
            end
        else
            self:MyEmitSound(self.MeleeMissSound, 75, 100, 1, CHAN_USER_BASE + 3)
        end
    end

    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        local dmginfo = DamageInfo()

        local attacker = self:GetOwner()
        if !IsValid(attacker) then attacker = self end
        dmginfo:SetAttacker(attacker)

        local relspeed = (tr.Entity:GetVelocity() - self:GetOwner():GetAbsVelocity()):Length()

        relspeed = relspeed / 225

        relspeed = math.Clamp(relspeed, 1, 1.5)

        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(dmg * relspeed)
        dmginfo:SetDamageType(self:GetBuff_Override("Override_MeleeDamageType") or self.MeleeDamageType or DMG_CLUB)

        dmginfo:SetDamageForce(self:GetOwner():GetRight() * -4912 + self:GetOwner():GetForward() * 9989)

        SuppressHostEvents(NULL)
        tr.Entity:TakeDamageInfo(dmginfo)
        SuppressHostEvents(self:GetOwner())

        if tr.Entity:GetClass() == "func_breakable_surf" then
            tr.Entity:Fire("Shatter", "0.5 0.5 256")
        end

    end

    if SERVER and IsValid(tr.Entity) then
        local phys = tr.Entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
        end
    end

    self:GetBuff_Hook("Hook_PostBash", {tr = tr, dmg = dmg})

    self:GetOwner():LagCompensation(false)
end