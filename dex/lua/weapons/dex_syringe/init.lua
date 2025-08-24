AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

util.AddNetworkString("dex_StartBlackout")
util.AddNetworkString("dex_StartRecovery")
util.AddNetworkString("dex_UpdateRagdollPos")

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

local function SetupRagdoll(target, ragdoll)
    local velocity = target:GetVelocity()
    
    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
        local phys = ragdoll:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            phys:SetVelocity(velocity)
        end
    end

    local activeWeapon = target:GetActiveWeapon()
    if IsValid(activeWeapon) then
        activeWeapon:SetNoDraw(true)
    end

    target.Ragdoll = ragdoll
    target.IsInRagdoll = true
    target:SetNWBool("IsInRagdoll", true)
    target.RagdollStartTime = CurTime()

    DEX_GAGGED_PLAYERS[target] = true
    
    net.Start("dex_UpdateGagged")
        net.WriteEntity(target)
        net.WriteBool(true)
    net.Broadcast()

    target:Freeze(true)
    target:SetNoDraw(true)
    target:SetNotSolid(true)
    
    target:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    
    timer.Create("dex_SyncRagdoll_" .. target:EntIndex(), 0.1, 0, function()
        if IsValid(target) and IsValid(ragdoll) and target.IsInRagdoll then
            local headBone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
            local newPos = ragdoll:GetPos()
            
            if headBone then
                local bonePos = ragdoll:GetBonePosition(headBone)
                if bonePos then
                    newPos = bonePos
                end
            end
            
            target:SetPos(newPos)
            
            net.Start("dex_UpdateRagdollPos")
                net.WriteVector(newPos)
                net.WriteEntity(ragdoll)
            net.Send(target)
        else
            timer.Remove("dex_SyncRagdoll_" .. target:EntIndex())
        end
    end)
end

local function CleanupRagdoll(target, ragdoll)
    if IsValid(target) then
        timer.Remove("dex_SyncRagdoll_" .. target:EntIndex())
        
        target:Freeze(false)
        target:SetNoDraw(false)
        target:SetNotSolid(false)
        target:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        
        local activeWeapon = target:GetActiveWeapon()
        if IsValid(activeWeapon) then
            activeWeapon:SetNoDraw(false)
        end
        
        target.Ragdoll = nil
        target.IsInRagdoll = false
        target:SetNWBool("IsInRagdoll", false)
        target.RagdollStartTime = nil
        
        DEX_GAGGED_PLAYERS[target] = nil
        
        net.Start("dex_UpdateGagged")
            net.WriteEntity(target)
            net.WriteBool(false)
        net.Broadcast()
        
        net.Start("dex_StartRecovery")
        net.Send(target)
    end
    
    if IsValid(ragdoll) then
        ragdoll:Remove()
    end
end

local function PlayViewModelAnimation(self)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local vm = owner:GetViewModel()
    if IsValid(vm) then
        local anim = "shoot"
        local seq = vm:LookupSequence(anim)
        if seq >= 0 then
            vm:SendViewModelMatchingSequence(seq)
            vm:SetPlaybackRate(0.5)
        end
    end
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextPrimaryFire(CurTime() + 1.5)
    
    local trace = owner:GetEyeTrace()
    local target = trace.Entity

    if IsValid(target) and (target:IsPlayer() or target:IsNPC()) and trace.HitPos:Distance(owner:GetShootPos()) <= 100 then
        if target:IsPlayer() and target.IsInRagdoll then
            return
        end
        
        if game.SinglePlayer() then self:CallOnClient("PrimaryAttack") end

        PlayViewModelAnimation(self)

        if target:IsPlayer() then
            local ragdoll = ents.Create("prop_ragdoll")
            ragdoll:SetPos(target:GetPos())
            ragdoll:SetAngles(target:GetAngles())
            ragdoll:SetModel(target:GetModel())
            ragdoll:SetSkin(target:GetSkin())
            
            for i = 0, target:GetNumBodyGroups() - 1 do
                ragdoll:SetBodygroup(i, target:GetBodygroup(i))
            end
            
            ragdoll:Spawn()
            ragdoll:Activate()

            ragdoll.VictimName = target:Nick()
            ragdoll.VictimSteamID = target:SteamID()
            ragdoll:SetOwner(target)
            
            ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
            ragdoll:SetSolid(SOLID_VPHYSICS)
            ragdoll:PhysicsInit(SOLID_VPHYSICS)
            
            for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetMass(50)
                end
            end
            
            SetupRagdoll(target, ragdoll)

            timer.Simple(0.1, function()
                if IsValid(target) and IsValid(ragdoll) then
                    net.Start("dex_StartBlackout")
                        net.WriteEntity(ragdoll)
                    net.Send(target)
                end
            end)

            local time = math.random(DEX_CONFIG.RagdollTimeMin, DEX_CONFIG.RagdollTimeMax)

            timer.Simple(time, function()
                if IsValid(target) and IsValid(ragdoll) and target.IsInRagdoll then
                    target:SetPos(ragdoll:GetPos())
                    CleanupRagdoll(target, ragdoll)
                end
            end)
        elseif target:IsNPC() then
            target:TakeDamage(target:Health(), owner, self)
        end

        timer.Simple(1.3, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function SWEP:SecondaryAttack()
    if DEX_CONFIG.DisableSyringeSecondaryAttack then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SetNextSecondaryFire(CurTime() + 1.0)

    local startPos = owner:GetShootPos()
    local endPos = startPos + owner:GetAimVector() * 100
    
    local tr = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = owner,
        mask = MASK_SHOT
    })
    
    local ent = tr.Entity
    
    if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then
        local nearbyEnts = ents.FindInSphere(owner:GetPos(), 100)
        local bestRagdoll = nil
        local bestDistance = math.huge
        
        for _, entity in ipairs(nearbyEnts) do
            if IsValid(entity) and entity:GetClass() == "prop_ragdoll" then
                local distance = owner:GetPos():Distance(entity:GetPos())
                if distance < bestDistance then
                    bestDistance = distance
                    bestRagdoll = entity
                end
            end
        end
        
        if bestRagdoll then
            ent = bestRagdoll
        end
    end
    
    if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
        PlayViewModelAnimation(self)

        for _, ply in ipairs(player.GetAll()) do
            if ply.Ragdoll == ent and ply.IsInRagdoll then
                ply:SetPos(ent:GetPos())
                CleanupRagdoll(ply, ent)
                break
            end
        end

        timer.Simple(1.3, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
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

hook.Add("PlayerDisconnected", "dex_CleanupRagdollDisconnect", function(ply)
    if ply.IsInRagdoll and IsValid(ply.Ragdoll) then
        ply.Ragdoll:Remove()
        timer.Remove("dex_SyncRagdoll_" .. ply:EntIndex())
    end
end)

hook.Add("PlayerDeath", "dex_CleanupRagdollDeath", function(ply)
    if ply.IsInRagdoll and IsValid(ply.Ragdoll) then
        CleanupRagdoll(ply, ply.Ragdoll)
    end
end)

hook.Add("GetFallDamage", "dex_PreventFallDamage", function(ply, speed)
    if ply.IsInRagdoll or ply.ShouldTakeFallDamage == false then
        return 0
    end
end)