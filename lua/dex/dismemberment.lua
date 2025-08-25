if !SERVER then return end

local ENT = FindMetaTable("Entity")
local DMGINFO = FindMetaTable("CTakeDamageInfo")

local DGM_RAGDOLLS = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DexAddon_ForcePhysBonePos()
    for phys_bone, parent_physbone in pairs(self.DexAddon_GibbedPhysBoneParents) do
        local gibbed_physobj = self:GetPhysicsObjectNum(phys_bone)
        local parent_physobj = self:GetPhysicsObjectNum(parent_physbone)
        gibbed_physobj:SetPos(parent_physobj:GetPos())
        gibbed_physobj:SetAngles(parent_physobj:GetAngles())
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DexAddon_BreakPhysBone(phys_bone_idx, data)
    local gibbed_bone = self:TranslatePhysBoneToBone(phys_bone_idx)

    local function gib_bone_recursive(bone, dismember, MakeLimbRag)
        if bone == 0 or bone == 3 then return end

        self:ManipulateBoneScale(bone, Vector(0, 0, 0))

        local phys_bone = self:TranslateBoneToPhysBone(bone)
        if phys_bone != -1 then
            if !self.DexAddon_GibbedPhysBones then self.DexAddon_GibbedPhysBones = {} end
            if !self.DexAddon_GibbedPhysBones[phys_bone] then
                local phys_obj = self:GetPhysicsObjectNum(phys_bone)
                if phys_obj then
                    phys_obj:EnableCollisions(false)

                    if !self.DexAddon_GibbedPhysBoneParents then self.DexAddon_GibbedPhysBoneParents = {} end
                    if phys_bone != 0 then
                        self.DexAddon_GibbedPhysBoneParents[phys_bone] = self:TranslateBoneToPhysBone(self:GetBoneParent(bone))
                        self:RemoveInternalConstraint(phys_bone)
                    end

                    self.DexAddon_GibbedPhysBones[phys_bone] = true
                end
            end

            for _, v in ipairs(self:GetChildBones(bone)) do
                gib_bone_recursive(v, dismember, phys_bone == 0)
            end
        end
    end

    gib_bone_recursive(gibbed_bone, data.dismember, true)
end

---------------------------------------------------------------------
function ENT:DexAddon_BecomeGibbableRagdoll()
    self.DexAddon_Ragdoll = true
    table.insert(DGM_RAGDOLLS, self)

    self:CallOnRemove("RemoveFrom_DGM_RAGDOLLS", function()
        table.RemoveByValue(DGM_RAGDOLLS, self)
    end)

    self.DexAddon_PhysBoneHPs = {}
    for i = 0, self:GetPhysicsObjectCount() - 1 do
        local physObj = self:GetPhysicsObjectNum(i)
        if IsValid(physObj) then
            local surfaceArea = physObj.GetSurfaceArea and physObj:GetSurfaceArea() or 100
            local multiplier = 2
            self.DexAddon_PhysBoneHPs[i] = surfaceArea * 0.25 * multiplier
        else
            self.DexAddon_PhysBoneHPs[i] = 100
        end
    end
end
---------------------------------------------------------------------
function ENT:DexAddon_DamageRagdoll_Gibbing(dmginfo)
    local _, phys_idx = dmginfo:DexAddon_RagdollHitPhysBone(self)
    if phys_idx then
        local data = {
            damage = 100,
            forceVec = dmginfo:GetDamageForce(),
            dismember = false,
        }
        self:DexAddon_DamagePhysBone(phys_idx, data)
    end
end

function ENT:DexAddon_DamagePhysBone(phys_bone_idx, data)
    local health = self.DexAddon_PhysBoneHPs[phys_bone_idx]
    if health == -1 then return end

    local multiplier = DEX_CONFIG.BoneDamageMultiplier or 1
    self.DexAddon_PhysBoneHPs[phys_bone_idx] = health - (data.damage * multiplier)

    if self.DexAddon_PhysBoneHPs[phys_bone_idx] <= 0 then
        self.DexAddon_PhysBoneHPs[phys_bone_idx] = -1
        self:DexAddon_BreakPhysBone(phys_bone_idx, data)

        local criticalbones = {
            [1] = true,
            [3] = true,
            [2] = true,
            [8] = true,
            [11] = true,
            [10] = true,
        }

        if phys_bone_idx == 1 then
            self:RemoveRagdollAndRespawnPlayer()
            return
        end

        if not self.DexAddon_CriticalBonesDestroyed then
            self.DexAddon_CriticalBonesDestroyed = {}
        end

        if criticalbones[phys_bone_idx] then
            self.DexAddon_CriticalBonesDestroyed[phys_bone_idx] = true
            local count = table.Count(self.DexAddon_CriticalBonesDestroyed)

            if count >= 4 then
                self:RemoveRagdollAndRespawnPlayer()
            end
        end
    end
end

function ENT:RemoveRagdollAndRespawnPlayer()
    local bed = nil
    for _, ent in pairs(ents.FindByClass("dex_bed")) do
        if IsValid(ent.BedPlayer) and IsValid(ent.BedPlayer.ragdoll) and ent.BedPlayer.ragdoll == self then
            bed = ent
            break
        end
    end

    local victim = nil
    if IsValid(bed) and IsValid(bed.BedPlayer) then
        victim = bed.BedPlayer
    end
    
    if IsValid(self.LastAttacker) and self.LastAttacker:IsPlayer() then
        local attacker = self.LastAttacker
        local victimName = victim and victim:Nick() or "Unknown"

        if not attacker:HasWeapon("dex_w_glass") then
            attacker:Give("dex_w_glass")
        end

        if DEX_CONFIG.GiveBagSWEP then
            if not attacker:HasWeapon("dex_w_bag") then
                attacker:Give("dex_w_bag")
            end
        else
            local ent = ents.Create("dex_bag")
            if not IsValid(ent) then return end

            local spawnPos = attacker:GetPos() + attacker:GetForward() * 50 + Vector(-10, 0, 80)
            ent:SetPos(spawnPos)
            ent:Spawn()
            ent:Activate()
        end

        timer.Simple(0.1, function()
            if not IsValid(attacker) then return end

            local swep = attacker:GetWeapon("dex_w_glass")
            if IsValid(swep) and swep.AddGlassName then
                swep:AddGlassName(victimName)
            end
        end)
    end
    
    self:Remove()

    if IsValid(bed) and IsValid(victim) then
        local player = victim

        -- GAG TEMİZLEME - ÖNEMLİ DÜZELTME!
        DEX_GAGGED_PLAYERS[player] = nil
        
        -- Client'a gag durumunu güncelle
        net.Start("dex_UpdateGagged")
            net.WriteEntity(player)
            net.WriteBool(false)
        net.Broadcast()

        net.Start("dex_ExitFirstPersonView")
        net.Send(player)

        player:KillSilent()

        timer.Simple(0.1, function()
            if IsValid(player) then
                player:Spawn()
                
                -- Spawn sonrası tekrar gag temizleme (güvenlik için)
                DEX_GAGGED_PLAYERS[player] = nil
            end
        end)

        bed.Locked = false
        bed.BedPlayer = nil
        
        -- Bed durumunu güncelle
        net.Start("dex_bed_status")
            net.WriteEntity(bed)
            net.WriteBool(false)
            net.WriteEntity(NULL)
        net.Broadcast()
    end
end
---------------------------------------------------------------------
if SERVER then 
    hook.Add("Think", "dex_ForcePhysBoneThink", function()
        for _,rag in ipairs(DGM_RAGDOLLS) do
            if rag.DexAddon_GibbedPhysBoneParents then rag:DexAddon_ForcePhysBonePos() end
        end
    end)
end

hook.Add("EntityTakeDamage", "dex_EntityTakeDamage", function(ent, dmginfo)
    if ent.DexAddon_Ragdoll and ent.IsSpecialBedRagdoll == true then
        local attacker = dmginfo:GetAttacker()
        local inflictor = dmginfo:GetInflictor()

        if IsValid(attacker) and attacker:IsPlayer() and IsValid(inflictor) then
            local wep = attacker:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "dex_butcher_knife" then
                ent.LastAttacker = attacker

                ent:DexAddon_DamageRagdoll_Gibbing(dmginfo)
            end
        end
    end
end)

hook.Add("OnEntityCreated", "dex_OnEntityCreated", function(ent)
    timer.Simple(0, function()
        if IsValid(ent) and not ent.DexAddon_Ragdoll and not ent.DexAddon_IsGibRagdoll then
            ent:DexAddon_BecomeGibbableRagdoll()
        end
    end)
end)

---------------------------------------------------------------------
function DMGINFO:DexAddon_RagdollHitPhysBone(ent)
    local closest_phys_bone
    local closest_phys_bone_idx
    local mindist

    for i = 0, ent:GetPhysicsObjectCount()-1 do
        if ent.DexAddon_PhysBoneHPs and ent.DexAddon_PhysBoneHPs[i] == -1 then continue end

        local phys = ent:GetPhysicsObjectNum(i)
        if not IsValid(phys) then continue end
        local dist = phys:GetPos():DistToSqr(self:GetDamagePosition())

        if not mindist or dist < mindist then
            mindist = dist
            closest_phys_bone = phys
            closest_phys_bone_idx = i
        end
    end

    if closest_phys_bone then
        return closest_phys_bone, closest_phys_bone_idx
    end
end