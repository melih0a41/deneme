-- NPC integration

function SWEP:NPC_Initialize()
    if CLIENT then return end

    if !IsValid(self:GetOwner()) then return end
    if !self:GetOwner():IsNPC() then return end

    self:NPC_SetupAttachments()

    self:SetHoldType(self.HoldtypeNPC or self:GetBuff_Override("Override_HoldtypeActive") or self.HoldtypeActive)

    self:SetNextPrimaryFire(CurTime())

    self:SetClip1(self:GetCapacity() or self.Primary.ClipSize)

    -- print(self:Clip1())

    local range = self:GetBuff("Range") / ArcCW.HUToM

    if self:GetBuff("DamageMin") >= self:GetBuff("Damage") or (self:GetBuff_Override("Override_ManualAction") or self.ManualAction) and self:GetBuff("Num") == 1 then
        range = math.max(range, 10000) * 2
    end

    range = math.Clamp(range, 2048, 36000)

    self:GetOwner():Input("SetMaxLookDistance", nil, nil, range)

    self:SetNextPrimaryFire(CurTime())
    self:SetNextSecondaryFire(CurTime() + 30)
    self:GetOwner():NextThink(CurTime())
end

function SWEP:AssignRandomAttToSlot(slot)
    if slot.DoNotRandomize then return end
    if slot.Installed then return end

    local att = ArcCW:RollRandomAttachment(true, self, slot)
    if !att then return end
    slot.Installed = att

    local atttbl = ArcCW.AttachmentTable[slot.Installed]

    --if !ArcCW:SlotAcceptsAtt(slot.Slot, self, slot.Installed) then return end
    --if !self:CheckFlags(atttbl.ExcludeFlags, atttbl.RequireFlags) then return end

    if atttbl.MountPositionOverride then
        slot.SlidePos = atttbl.MountPositionOverride
    end
end

function SWEP:NPC_SetupAttachments()
    if self:GetOwner():IsNPC() and !ArcCW.ConVars["npc_atts"]:GetBool() then return end

    local pick = self:GetPickX()

    local chance = 25 * ArcCW.ConVars["mult_attchance"]:GetFloat()
    local chancestep = 0

    if pick > 0 then
        chancestep = chance / pick
        --chance = chancestep
    else
        pick = 1000
    end

    local n = 0

    for i, slot in pairs(self.Attachments) do
        if n > pick then continue end
        if !self:CheckFlags(slot.ExcludeFlags, slot.RequireFlags) then continue end
        if math.Rand(0, 100) > (chance * (slot.RandomChance or 1)) then continue end

        if slot.Hidden then continue end

        local s = i

        if slot.MergeSlots then
            local ss = {i}
            table.Add(ss, slot.MergeSlots)

            s = table.Random(ss) or i
        end
        if !self.Attachments[s] then s = i end

        chance = chance - chancestep

        self:AssignRandomAttToSlot(self.Attachments[s])

        n = n + 1
    end

    self.ActiveElementCache = nil -- Reset cache so we have the proper attachments to check with
    for i, slot in pairs(self.Attachments) do
        if !slot.Installed then continue end
        local atttbl = ArcCW.AttachmentTable[slot.Installed]
        if !ArcCW:SlotAcceptsAtt(slot.Slot, self, slot.Installed) then slot.Installed = nil continue end
        if !self:CheckFlags(slot.ExcludeFlags, slot.RequireFlags) then slot.Installed = nil continue end
        if !self:CheckFlags(atttbl.ExcludeFlags, atttbl.RequireFlags) then slot.Installed = nil continue end
    end

    if self:GetBuff_Override("UBGL") and self:GetBuff_Override("UBGL_Capacity") then
        self:SetClip2(self:GetBuff_Override("UBGL_Capacity"))
    end

    self:AdjustAtts()
    self:RefreshBGs()

    if self:GetOwner():IsNPC() then
        timer.Simple(0.1, function()
            if !IsValid(self) then return end
            self:NetworkWeapon()
        end)
    else
        self:NetworkWeapon()
        self:SetupModel(false)
        self:SetupModel(true)
    end
end

function SWEP:NPC_Shoot()
    -- if self:GetNextPrimaryFire() > CurTime() then return end

    if !IsValid(self:GetOwner()) then return end
    if self:Clip1() <= 0 then self:GetOwner():SetSchedule(SCHED_HIDE_AND_RELOAD) return end

    if self:GetOwner().ArcCW_Smoked then return end


    self.Primary.Automatic = true


    local delay = self:GetFiringDelay()

    if (self:GetBuff_Override("Override_ManualAction") or self.ManualAction) then
        delay = self:GetAnimKeyTime("cycle", true) * self:GetBuff("CycleTime")
    end

    local num = self:GetBuff("Num")

    if num > 0 then
        local spread = ArcCW.MOAToAcc * self:GetBuff("AccuracyMOA")

        local btabl = {
            Attacker = self:GetOwner(),
            Damage = 0,
            Force = 1,
            Distance = 33000,
            Num = num,
            Tracer = self.TracerNum,
            AmmoType = self.Primary.Ammo,
            Dir = self:GetOwner():GetAimVector(),
            Src = self:GetShootSrc(),
            Spread = Vector(spread, spread, spread),
            Callback = function(att, tr, dmg)
                ArcCW:BulletCallback(att, tr, dmg, self)
            end,
            --[[]
            Callback = function(att, tr, dmg)
                local dist = (tr.HitPos - tr.StartPos):Length() * ArcCW.HUToM

                local pen = self:GetBuff("Penetration")

                -- local frags = math.random(1, self.Frangibility)

                -- for i = 1, frags do
                --     self:DoPenetration(tr, (self.Penetration / frags) - 0.5, tr.Entity)
                -- end

                if self.DamageMin > self.Damage then
                    dist = -dist + self.Range + self.Range
                end

                local m = 1 * self:GetBuff_Mult("Mult_DamageNPC")

                local ret = self:GetBuff_Hook("Hook_BulletHit", {
                    range = dist,
                    damage = self:GetDamage(dist, true) * m,
                    dmgtype = self:GetBuff_Override("Override_DamageType") or self.DamageType,
                    penleft = pen,
                    att = att,
                    tr = tr,
                    dmg = dmg
                })

                if !ret then return end

                dmg:SetDamageType(ret.dmgtype)
                dmg:SetDamage(ret.damage)

                if dmg:IsDamageType(DMG_BURN) and hit.range <= self.Range then
                    dmg:SetDamageType(dmg:GetDamageType() - DMG_BURN)

                    local fx = EffectData()
                    fx:SetOrigin(tr.HitPos)
                    util.Effect("arccw_incendiaryround", fx)

                    util.Decal("FadingScorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self:GetOwner())

                    tr.Entity:Ignite(1, 32)
                end
            end
            ]]
        }

        local sp = self:GetBuff_Override("Override_ShotgunSpreadPattern") or self.ShotgunSpreadPattern
        local spo = self:GetBuff_Override("Override_ShotgunSpreadPatternOverrun") or self.ShotgunSpreadPatternOverrun
        local se = self:GetBuff_Override("Override_ShootEntity") or self.ShootEntity

        if sp or spo then
            btabl = self:GetBuff_Hook("Hook_FireBullets", btabl)

            if !btabl then return end
            if btabl.Num == 0 then return end

            for n = 1, btabl.Num do
                btabl.Num = 1
                local ang = self:GetOwner():GetAimVector():Angle() + self:GetShotgunSpreadOffset(n)

                btabl.Dir = ang:Forward()

                self:DoPrimaryFire(false, btabl)
            end
        elseif se then
            self:FireRocket(se, self:GetBuff("MuzzleVelocity"))
        else
            self:GetBuff_Hook("Hook_FireBullets", btabl)

            for n = 1, btabl.Num do
                btabl.Num = 1

                local dispers = self:GetBuff_Override("Override_ShotgunSpreadDispersion", self.ShotgunSpreadDispersion)
                local offset  = self:GetShotgunSpreadOffset(n)
                local calcoff = dispers and (offset * self:GetDispersion() * ArcCW.MOAToAcc / 10) or offset

                local ang = self:GetOwner():GetAimVector():Angle()
                -- ang:RotateAroundAxis(ang:Right(), -1 * calcoff.p)
                -- ang:RotateAroundAxis(ang:Up(), calcoff.y)
                -- ang:RotateAroundAxis(ang:Forward(), calcoff.r)

                btabl.Dir = ang:Forward()

                self:DoPrimaryFire(false, btabl)
            end
        end
    end

    self:DoEffects()

    if !self.RevolverReload then
        self:DoShellEject()
    end

    --[[]
    local ss = self.ShootSound

    if self:GetBuff_Override("Silencer") then
        ss = self.ShootSoundSilenced
    end

    ss = self:GetBuff_Hook("Hook_GetShootSound", ss)

    local dss = self.DistantShootSound

    if self:GetBuff_Override("Silencer") then
        dss = nil
    end

    dss = self:GetBuff_Hook("Hook_GetDistantShootSound", dss)

    local svol = self:GetBuff("ShootVol")
    local spitch = self.ShootPitch * math.Rand(0.95, 1.05) * self:GetBuff_Mult("Mult_ShootPitch")

    svol = svol * 0.75

    svol = math.Clamp(svol, 51, 149)
    spitch = math.Clamp(spitch, 51, 149)

    if dss then
        -- sound.Play(self.DistantShootSound, self:GetPos(), 149, self.ShootPitch * math.Rand(0.95, 1.05), 1)
        self:MyEmitSound(dss, 130, spitch, 0.5, CHAN_BODY)
    end

    if ss then
        self:MyEmitSound(ss, svol, spitch, 1, CHAN_WEAPON)
    end
    ]]

    self:DoShootSound()

    self:SetClip1(self:Clip1() - 1)

    self:SetNextPrimaryFire(CurTime() + delay)
    if delay < 0.1 then
        self:GetOwner():NextThink(CurTime() + delay)
    end

    if self:GetBuff_Override("UBGL_NPCFire") and self:GetNextSecondaryFire() < CurTime() then
        if math.random(0, 100) < (self:GetOwner():GetCurrentWeaponProficiency() + 1) then
            self:SetNextSecondaryFire(CurTime() + math.random(3, 5))
        else
            local func = self:GetBuff_Override("UBGL_NPCFire")
            if func then
                func(self)
            end
            if self:Clip2() == 0 then
                self:SetClip2(self.Secondary.ClipSize)
                self:SetNextSecondaryFire(CurTime() + math.random(300, 600) / (self:GetOwner():GetCurrentWeaponProficiency() + 1))
            else
                self:SetNextSecondaryFire(CurTime() + 1 / ((self:GetBuff_Override("UBGL_RPM") or 300) / 60))
            end
        end
   end
end

function SWEP:GetNPCBulletSpread(prof)
    local mode = self:GetCurrentFiremode()
    mode = mode.Mode

    if mode < 0 then
        return 15 / (prof + 1)
    elseif mode == 1 then
        if math.Rand(0, 100) < (prof + 5) * 5 then
            return 5 / (prof + 1)
        else
            return 30 / (prof + 1)
        end
    elseif mode > 1 then
        if math.Rand(0, 100) < (prof + 5) * 2 then
            return 15 / (prof + 1)
        else
            return (20 + self:GetBuff("Recoil") * 10) / (prof + 1)
        end

    end

    return 15
end

function SWEP:GetNPCBurstSettings()
    local mode = self:GetCurrentFiremode()
    mode = mode.Mode

    local delay = self:GetFiringDelay()

    if !mode then return 1, 1, delay end

    if self.ManualAction or self:GetBuff_Override("Override_ManualAction") then
        return 1, 1, self:GetAnimKeyTime("cycle") * self:GetBuff("CycleTime")
    end

    if mode < 0 then
        return -mode, -mode, delay
    elseif mode == 0 then
        return 0, 0, delay
    elseif mode == 1 then
        local c = self:GetCapacity()
        return math.ceil(c * 0.075), math.floor(c * math.Rand(0.15, 0.3)), delay + math.Rand(0.2, 0.4)
    elseif mode >= 2 then
        if self:GetCurrentFiremode().RunawayBurst then
            return self:Clip1(), self:Clip1(), delay
        else
            return 2, math.floor(2.5 / delay), delay
        end
    end
end

function SWEP:GetNPCRestTimes()
    local mode = self:GetCurrentFiremode()
    mode = mode.Mode
    local postburst = self:GetCurrentFiremode().PostBurstDelay or 0
    local m = self:GetBuff("Recoil")
    local rs = self:GetBuff("RecoilSide")

    if !mode then return 0.3, 0.6 end

    local o = m * 0.3 + rs * 0.15
    if self.ManualAction or self:GetBuff_Override("Override_ManualAction") then
        local cycle = self:GetAnimKeyTime("cycle") * self:GetBuff("CycleTime")
        return cycle + 0.1 * o, cycle + 0.2 * o
    elseif mode < 0 then
        o = o * 0.5 + postburst * self:GetBuff("PostBurstDelay")
    end

    return 0.4 * o, 0.6 * o
end

function SWEP:CanBePickedUpByNPCs()
    return !self.NotForNPCs
end

function SWEP:OnDrop()
    self.Primary.DefaultClip = 0

    if self.Singleton or self.Primary.ClipSize == -1 then
        self.Primary.DefaultClip = 1
    end

    self.UnReady = false
    -- if engine.ActiveGamemode() == "terrortown" then
    --     self.UnReady = true
    -- else
    --     self.UnReady = false
    -- end
end