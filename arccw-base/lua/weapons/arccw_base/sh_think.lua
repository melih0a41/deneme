if CLIENT then
    ArcCW.LastWeapon = nil
end

-- Cache vector/angle değerleri
local vec1 = Vector(1, 1, 1)
local vec0 = Vector(0, 0, 0)
local ang0 = Angle(0, 0, 0)

-- Cache sık kullanılan değişkenler
local lastUBGL = 0
local frameCounter = 0
local lastBoneUpdate = 0

function SWEP:Think()
    -- Erken return kontrolü
    local owner = self:GetOwner()
    if !IsValid(owner) or owner:IsNPC() then return end
    
    if self:GetClass() == "arccw_base" then
        self:Remove()
        return
    end

    -- CurTime() cache'le
    local ct = CurTime()
    frameCounter = frameCounter + 1
    
    -- STATE kontrolleri
    if self:GetState() == ArcCW.STATE_DISABLE and !self:GetPriorityAnim() then
        self:SetState(ArcCW.STATE_IDLE)
        if CLIENT and self.UnReady then
            self.UnReady = false
        end
    end

    -- Event table - optimize edilmiş döngü
    if self.EventTable and #self.EventTable > 0 then
        for i = #self.EventTable, 1, -1 do -- Tersten döngü, silme işlemleri için daha verimli
            local v = self.EventTable[i]
            if v then
                for ed, bz in pairs(v) do
                    if ed <= ct then
                        if !bz.AnimKey or (bz.AnimKey == self.LastAnimKey and bz.StartTime == self.LastAnimStartTime) then
                            self:PlayEvent(bz)
                            v[ed] = nil
                            if next(v) == nil and i != 1 then
                                table.remove(self.EventTable, i)
                            end
                        end
                    end
                end
            end
        end
    end

    -- CLIENT side HUD kontrolü - frame skip ekle
    if CLIENT and frameCounter % 5 == 0 then -- Her 5 frame'de bir kontrol et
        if (!game.SinglePlayer() and IsFirstTimePredicted() or true)
                and owner == LocalPlayer() and ArcCW.InvHUD
                and !ArcCW.Inv_Hidden and ArcCW.Inv_Fade == 0 then
            ArcCW.InvHUD:Remove()
            ArcCW.Inv_Fade = 0.01
        end
    end

    -- Burst count cache
    self.BurstCount = self:GetBurstCount()

    -- Shotgun reload kontrolü
    local sg = self:GetShotgunReloading()
    if sg > 0 then
        if (sg == 2 or sg == 4) and owner:KeyPressed(IN_ATTACK) then
            self:SetShotgunReloading(sg + 1)
        elseif sg >= 2 and self:GetReloadingREAL() <= ct then
            self:ReloadInsert(sg >= 4)
        end
    end

    -- Bipod kontrolü
    self:InBipod()

    -- Cycle kontrolü - optimize edilmiş koşullar
    if self:GetNeedCycle() and !self.Throwing and !self:GetReloading() 
        and self:GetWeaponOpDelay() < ct and self:GetNextPrimaryFire() < ct then
        
        local clicktocycle = ArcCW.ConVars["clicktocycle"]:GetBool()
        local firemode = self:GetCurrentFiremode().Mode
        
        if (!clicktocycle and (firemode == 2 or !owner:KeyDown(IN_ATTACK)))
            or (clicktocycle and (firemode == 2 or owner:KeyPressed(IN_ATTACK))) then
            
            local anim = self:SelectAnimation("cycle")
            anim = self:GetBuff_Hook("Hook_SelectCycleAnimation", anim) or anim
            local mult = self:GetBuff_Mult("Mult_CycleTime")
            
            if self:PlayAnimation(anim, mult, true, 0, true) then
                self:SetNeedCycle(false)
                self:SetPriorityAnim(ct + self:GetAnimKeyTime(anim, true) * mult)
            end
        end
    end

    -- Grenade handling
    if self:GetGrenadePrimed() then
        if !(owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)) and (!game.SinglePlayer() or SERVER) then
            self:Throw()
        elseif self.GrenadePrimeTime > 0 and self.isCooked then
            local heldtime = ct - self.GrenadePrimeTime
            local ft = self:GetBuff_Override("Override_FuseTime") or self.FuseTime
            
            if ft and heldtime >= ft and (!game.SinglePlayer() or SERVER) then
                self:Throw()
            end
        end
    end

    -- Bipod toggle
    if IsFirstTimePredicted() and self:GetNextPrimaryFire() < ct and owner:KeyReleased(IN_USE) then
        if self:InBipod() then
            self:ExitBipod()
        else
            self:EnterBipod()
        end
    end

    -- Trigger delay handling
    local triggerDelay = self:GetBuff_Override("Override_TriggerDelay", self.TriggerDelay)
    if ((game.SinglePlayer() and SERVER) or !game.SinglePlayer()) and triggerDelay then
        if owner:KeyReleased(IN_ATTACK) and self:GetBuff_Override("Override_TriggerCharge", self.TriggerCharge) 
            and self:GetTriggerDelta(true) >= 1 then
            self:PrimaryAttack()
        else
            self:DoTriggerDelay()
        end
    end

    -- Runaway burst handling
    local currentFiremode = self:GetCurrentFiremode()
    if currentFiremode.RunawayBurst then
        if self:GetBurstCount() > 0 and ((game.SinglePlayer() and SERVER) or !game.SinglePlayer()) then
            self:PrimaryAttack()
        end

        if self:Clip1() < self:GetBuff("AmmoPerShot") or self:GetBurstCount() == self:GetBurstLength() then
            self:SetBurstCount(0)
            if !currentFiremode.AutoBurst then
                self.Primary.Automatic = false
            end
        end
    end

    -- Attack release handling
    if owner:KeyReleased(IN_ATTACK) then
        if !currentFiremode.RunawayBurst then
            self:SetBurstCount(0)
            self.LastTriggerTime = -1
            self.LastTriggerDuration = 0
        end

        if currentFiremode.Mode < 0 and !currentFiremode.RunawayBurst then
            local postburst = currentFiremode.PostBurstDelay or 0
            if (ct + postburst) > self:GetWeaponOpDelay() then
                self:SetWeaponOpDelay(ct + postburst * self:GetBuff_Mult("Mult_PostBurstDelay") + self:GetBuff_Add("Add_PostBurstDelay"))
            end
        end
    end

    -- Auto reload
    if owner:GetInfoNum("arccw_automaticreload", 0) == 1 
        and self:Clip1() == 0 and !self:GetReloading() and ct > self:GetNextPrimaryFire() + 0.2 then
        self:Reload()
    end

    -- Sight handling
    local reloadInSights = self:GetBuff_Override("Override_ReloadInSights") or self.ReloadInSights
    if !reloadInSights and (self:GetReloading() or owner:KeyDown(IN_RELOAD)) then
        self:ExitSights()
    end

    if self:GetBuff_Hook("Hook_ShouldNotSight") and (self.Sighted or self:GetState() == ArcCW.STATE_SIGHTS) then
        self:ExitSights()
    elseif self:GetHolster_Time() > 0 then
        self:ExitSights()
    else
        local sighted = self:GetState() == ArcCW.STATE_SIGHTS
        local toggle = owner:GetInfoNum("arccw_toggleads", 0) >= 1
        local suitzoom = owner:KeyDown(IN_ZOOM)
        local sp_cl = game.SinglePlayer() and CLIENT

        if toggle and !sp_cl then
            if owner:KeyPressed(IN_ATTACK2) then
                if sighted then
                    self:ExitSights()
                elseif !suitzoom then
                    self:EnterSights()
                end
            elseif suitzoom and sighted then
                self:ExitSights()
            end
        elseif !toggle then
            if owner:KeyDown(IN_ATTACK2) and !suitzoom and !sighted then
                self:EnterSights()
            elseif (!owner:KeyDown(IN_ATTACK2) or suitzoom) and sighted then
                self:ExitSights()
            end
        end
    end

    -- Sprint handling
    if (!game.SinglePlayer() and IsFirstTimePredicted()) or game.SinglePlayer() then
        if self:InSprint() and self:GetState() != ArcCW.STATE_SPRINT then
            self:EnterSprint()
        elseif !self:InSprint() and self:GetState() == ArcCW.STATE_SPRINT then
            self:ExitSprint()
        end
    end

    -- Delta calculations
    if game.SinglePlayer() or IsFirstTimePredicted() then
        local ft = FrameTime()
        self:SetSightDelta(math.Approach(self:GetSightDelta(), self:GetState() == ArcCW.STATE_SIGHTS and 0 or 1, ft / self:GetSightTime()))
        self:SetSprintDelta(math.Approach(self:GetSprintDelta(), self:GetState() == ArcCW.STATE_SPRINT and 1 or 0, ft / self:GetSprintTime()))
    end

    -- CLIENT side işlemler
    if CLIENT then
        if game.SinglePlayer() or IsFirstTimePredicted() then
            self:ProcessRecoil()
        end

        -- Bone manipülasyonu - optimize edilmiş (frame skip ile)
        local vm = owner:GetViewModel()
        if IsValid(vm) and ct - lastBoneUpdate > 0.05 then -- 20 FPS'de güncelle
            lastBoneUpdate = ct
            
            -- Reset all bones
            for i = 1, vm:GetBoneCount() do
                vm:ManipulateBoneScale(i, vec1)
            end

            -- Case bones
            local caseBones = self:GetBuff_Override("Override_CaseBones", self.CaseBones)
            if caseBones then
                local visualClip = self:GetVisualClip()
                for i, k in pairs(caseBones) do
                    if isnumber(i) then
                        local bones = istable(k) and k or {k}
                        for _, b in ipairs(bones) do
                            local bone = vm:LookupBone(b)
                            if bone then
                                vm:ManipulateBoneScale(bone, visualClip >= i and vec1 or vec0)
                            end
                        end
                    end
                end
            end

            -- Bullet bones
            local bulletBones = self:GetBuff_Override("Override_BulletBones", self.BulletBones)
            if bulletBones then
                local visualBullets = self:GetVisualBullets()
                for i, k in pairs(bulletBones) do
                    if isnumber(i) then
                        local bones = istable(k) and k or {k}
                        for _, b in ipairs(bones) do
                            local bone = vm:LookupBone(b)
                            if bone then
                                vm:ManipulateBoneScale(bone, visualBullets >= i and vec1 or vec0)
                            end
                        end
                    end
                end
            end

            -- Stripper clip bones
            local stripperBones = self:GetBuff_Override("Override_StripperClipBones", self.StripperClipBones)
            if stripperBones then
                local visualLoad = self:GetVisualLoadAmount()
                for i, k in pairs(stripperBones) do
                    if isnumber(i) then
                        local bones = istable(k) and k or {k}
                        for _, b in ipairs(bones) do
                            local bone = vm:LookupBone(b)
                            if bone then
                                vm:ManipulateBoneScale(bone, visualLoad >= i and vec1 or vec0)
                            end
                        end
                    end
                end
            end
        end

        self:DoOurViewPunch()
        self:BarrelHitWall()
    end

    -- Diğer işlemler
    self:DoHeat()
    self:ThinkFreeAim()

    -- Attachment damage
    if frameCounter % 10 == 0 then -- Her 10 frame'de bir kontrol et
        local ft = FrameTime() * 10
        for i, k in pairs(self.Attachments) do
            if k.Installed then
                local atttbl = ArcCW.AttachmentTable[k.Installed]
                if atttbl and atttbl.DamagePerSecond then
                    self:DamageAttachment(i, atttbl.DamagePerSecond * ft)
                end
            end
        end
    end

    -- Grenade replenish
    if self.Throwing and self:Clip1() == 0 and self:Ammo1() > 0 then
        self:SetClip1(1)
        owner:SetAmmo(self:Ammo1() - 1, self.Primary.Ammo)
    end

    -- Magazine timing
    if self:GetMagUpIn() != 0 and ct > self:GetMagUpIn() then
        self:ReloadTimed()
        self:SetMagUpIn(0)
    end

    -- Bottomless clip handling
    local hasBottomless = self:HasBottomlessClip()
    local currentClip = self:Clip1()
    
    if hasBottomless and currentClip != ArcCW.BottomlessMagicNumber then
        self:Unload()
        self:SetClip1(ArcCW.BottomlessMagicNumber)
    elseif !hasBottomless and currentClip == ArcCW.BottomlessMagicNumber then
        self:SetClip1(0)
    end

    -- Hook
    self:GetBuff_Hook("Hook_Think")

    -- Process timers
    self:ProcessTimers()

    -- Idle animation
    if self:GetNextIdle() != 0 and self:GetNextIdle() <= ct and !self:GetNeedCycle()
            and self:GetHolster_Time() == 0 and self:GetShotgunReloading() == 0 then
        self:SetNextIdle(0)
        self:PlayIdleAnimation(true)
    end

    -- UBGL debounce
    if self:GetUBGLDebounce() and !owner:KeyDown(IN_RELOAD) then
        self:SetUBGLDebounce(false)
    end
end

-- ProcessRecoil optimize edilmiş
local lst = SysTime()
function SWEP:ProcessRecoil()
    local owner = self:GetOwner()
    local st = SysTime()
    local ft = (st - lst) * GetConVar("host_timescale"):GetFloat()
    
    local ra = self:GetBuff_Override("Override_RecoilDirection", self.RecoilDirection) * self.RecoilAmount * 0.5
    ra = ra + self:GetBuff_Override("Override_RecoilDirectionSide", self.RecoilDirectionSide) * self.RecoilAmountSide * 0.5

    owner:SetEyeAngles(owner:EyeAngles() - ra)

    -- Recoil punch smoothing
    if self.RecoilPunchBack != 0 then
        self.RecoilPunchBack = math.Approach(self.RecoilPunchBack, 0, ft * self.RecoilPunchBack * 10)
    end
    if self.RecoilPunchSide != 0 then
        self.RecoilPunchSide = math.Approach(self.RecoilPunchSide, 0, ft * self.RecoilPunchSide * 5)
    end
    if self.RecoilPunchUp != 0 then
        self.RecoilPunchUp = math.Approach(self.RecoilPunchUp, 0, ft * self.RecoilPunchUp * 5)
    end

    lst = st
end

-- InSprint optimize edilmiş
function SWEP:InSprint()
    local owner = self:GetOwner()
    
    -- TTT2 kontrolü
    if TTT2 and owner.isSprinting == true then
        return (owner.sprintProgress or 0) > 0 and owner:KeyDown(IN_SPEED) and !owner:Crouching() and owner:GetVelocity():Length() > owner:GetWalkSpeed() and owner:OnGround()
    end

    -- Temel kontroller
    if !owner:KeyDown(IN_SPEED) or !owner:OnGround() or owner:Crouching() then 
        return false 
    end
    
    -- Movement key kontrolü
    if !owner:KeyDown(IN_FORWARD + IN_MOVELEFT + IN_MOVERIGHT + IN_BACK) then 
        return false 
    end

    -- Hız kontrolü
    local sm = self.SpeedMult * self:GetBuff_Mult("Mult_SpeedMult") * self:GetBuff_Mult("Mult_MoveSpeed")
    sm = math.Clamp(sm, 0, 1)
    
    local walkspeed = owner:GetWalkSpeed() * sm
    local sprintspeed = owner:GetRunSpeed() * sm
    local curspeed = owner:GetVelocity():Length()

    if curspeed < Lerp(0.5, walkspeed, sprintspeed) then
        self.LastExitSprintCheck = self.LastExitSprintCheck or CurTime()
        if self.LastExitSprintCheck < CurTime() - 0.25 then
            return false
        end
    else
        self.LastExitSprintCheck = nil
    end

    return true
end

-- IsTriggerHeld optimize edilmiş
function SWEP:IsTriggerHeld()
    return self:GetOwner():KeyDown(IN_ATTACK) 
        and (self:CanShootWhileSprint() or (!self.Sprinted or self:GetState() != ArcCW.STATE_SPRINT)) 
        and self:GetHolster_Time() < CurTime() 
        and !self:GetPriorityAnim()
end

-- GetTriggerDelta değişmemiş
SWEP.LastTriggerTime = 0
SWEP.LastTriggerDuration = 0
function SWEP:GetTriggerDelta(noheldcheck)
    if self.LastTriggerTime <= 0 or (!noheldcheck and !self:IsTriggerHeld()) then return 0 end
    return math.Clamp((CurTime() - self.LastTriggerTime) / self.LastTriggerDuration, 0, 1)
end

-- DoTriggerDelay optimize edilmiş
function SWEP:DoTriggerDelay()
    local shouldHold = self:IsTriggerHeld()
    local ct = CurTime()
    local nextFire = self:GetNextPrimaryFire()

    local reserve = self:HasBottomlessClip() and self:Ammo1() or self:Clip1()
    if self.LastTriggerTime == -1 or (!self.TriggerPullWhenEmpty and reserve < self:GetBuff("AmmoPerShot")) and nextFire < ct then
        if !shouldHold then
            self.LastTriggerTime = 0
            self.LastTriggerDuration = 0
        end
        return
    end

    if self:GetBurstCount() > 0 and self:GetCurrentFiremode().Mode == 1 then
        self.LastTriggerTime = -1
        self.LastTriggerDuration = 0
    elseif nextFire < ct and self.LastTriggerTime > 0 and !shouldHold then
        local anim = self:SelectAnimation("untrigger")
        if anim then
            self:PlayAnimation(anim, self:GetBuff_Mult("Mult_TriggerDelayTime"), true, 0)
        end
        self.LastTriggerTime = 0
        self.LastTriggerDuration = 0
        self:GetBuff_Hook("Hook_OnTriggerRelease")
    elseif nextFire < ct and self.LastTriggerTime == 0 and shouldHold then
        local anim = self:SelectAnimation("trigger")
        self:PlayAnimation(anim, self:GetBuff_Mult("Mult_TriggerDelayTime"), true, 0, nil, nil, true)
        self.LastTriggerTime = ct
        self.LastTriggerDuration = self:GetAnimKeyTime(anim, true) * self:GetBuff_Mult("Mult_TriggerDelayTime")
        self:GetBuff_Hook("Hook_OnTriggerHeld")
    end
end