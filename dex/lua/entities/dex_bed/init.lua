AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("dex_EnterFirstPersonView")
util.AddNetworkString("dex_ExitFirstPersonView")
util.AddNetworkString("dex_ShowProgressBar")
util.AddNetworkString("dex_HideProgressBar")
util.AddNetworkString("dex_UpdateProgressBar")
util.AddNetworkString("dex_GagRagdoll")
util.AddNetworkString("dex_UpdateGagged")
util.AddNetworkString("dex_add_ragdoll")
util.AddNetworkString("dex_bed_status")

net.Receive("dex_GagRagdoll", function(len, ply)
    local bed = net.ReadEntity()
    if not IsValid(bed) or bed:GetClass() ~= "dex_bed" then return end
    
    if not IsValid(bed.BedPlayer) then return end
    
    local ragdoll = bed:FindPlayerRagdoll(bed.BedPlayer)
    if not IsValid(ragdoll) then return end

    local isGagged = DEX_GAGGED_PLAYERS[bed.BedPlayer] or false
    local newState = not isGagged

    DEX_GAGGED_PLAYERS[bed.BedPlayer] = newState

    net.Start("dex_UpdateGagged")
        net.WriteEntity(bed.BedPlayer)
        net.WriteBool(newState)
    net.Broadcast()
end)

local BedRagdolls = {}

function ENT:Initialize()
    self:SetModel("models/blood/table.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.IsOnBed = true

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:StartProgressBar(activator)
    net.Start("dex_ShowProgressBar")
    net.Send(activator)
    
    self.ProgressStart = CurTime()
    self.ProgressPlayer = activator
    self.ProgressValue = 0
    
    self.ProgressTimer = timer.Create("DexProgress_"..self:EntIndex(), 0.1, 0, function()
        self:UpdateProgressBar()
    end)
end

function ENT:UpdateProgressBar()
    if not IsValid(self) or not IsValid(self.ProgressPlayer) then
        timer.Remove("DexProgress_"..self:EntIndex())
        return
    end
    
    if not self.ProgressPlayer:KeyDown(IN_USE) then
        self:ResetProgressBar()
        return
    end
    
    self.ProgressValue = math.min(100, self.ProgressValue + 5)
    
    net.Start("dex_UpdateProgressBar")
    net.WriteUInt(self.ProgressValue, 8)
    net.Send(self.ProgressPlayer)
    
    if self.ProgressValue >= 100 then
        self:CompleteProgress()
    end
end

function ENT:ResetProgressBar()
    self.ProgressValue = 0
    net.Start("dex_UpdateProgressBar")
    net.WriteUInt(self.ProgressValue, 8)
    net.Send(self.ProgressPlayer)

    net.Start("dex_HideProgressBar")
    net.Send(self.ProgressPlayer)

    timer.Remove("DexProgress_"..self:EntIndex())
end

function ENT:CompleteProgress()
    timer.Remove("DexProgress_"..self:EntIndex())
    net.Start("dex_HideProgressBar")
    net.Send(self.ProgressPlayer)
    
    self:ReleasePlayer()
end

function ENT:ReleasePlayer()
    if IsValid(self.BedPlayer) then
        local ragdoll = self:FindPlayerRagdoll(self.BedPlayer)
        
        if IsValid(ragdoll) then
            ragdoll:Remove()
        end
        
        DEX_GAGGED_PLAYERS[self.BedPlayer] = nil
        
        net.Start("dex_ExitFirstPersonView")
        net.Send(self.BedPlayer)

        self.BedPlayer:KillSilent()

        timer.Simple(0.1, function()
            if IsValid(self.BedPlayer) then
                self.BedPlayer:Spawn()
                self.BedPlayer:SetPos(self:GetPos() + Vector(0, 0, 50))
            end
        end)
        
        self.Locked = false

        net.Start("dex_bed_status")
            net.WriteEntity(self)
            net.WriteBool(false)
            net.WriteEntity(NULL)
        net.Broadcast()
    end
end

function ENT:FindPlayerRagdoll(ply)
    for _, v in ipairs(BedRagdolls) do
        if IsValid(v) and v:GetOwner() == ply then
            return v
        end
    end
    return nil
end

function ENT:Use(activator)
    if self.Locked ~= true or not IsValid(activator) or not activator:IsPlayer() then return end
    self:StartProgressBar(activator)
end

function ENT:SpawnMemorials(targetPlayer, basePos, baseAng)
    if not IsValid(targetPlayer) or not istable(targetPlayer.victimList) then return end
    
    local directions = {
        Vector(50, 0, 20),
        Vector(-15, 0, 20),
        Vector(15, 60, 20)
    }

    local angles = {
        Angle(0, 180, 0),
        Angle(0, 0, 0),
        Angle(0, 90, 0)
    }

    for i, victim in ipairs(targetPlayer.victimList or {}) do
        local memorial = ents.Create("dex_memorial")
        if IsValid(memorial) then
            local localOffset = directions[i] or Vector(0, 0, 20)
            local rotatedOffset =
                baseAng:Forward() * localOffset.x +
                baseAng:Right()   * localOffset.y +
                baseAng:Up()      * localOffset.z

            memorial:SetPos(basePos + rotatedOffset)
            memorial:SetAngles(baseAng + (angles[i] or Angle(0, 0, 0)))
            memorial:Spawn()
            
            memorial:SetupData(victim.name or "???", victim.model or "models/props_c17/doll01.mdl")

            local phys = memorial:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end

            memorial:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        end
    end
end

local function SyncRagdollsWithPlayer(ply)
    if not IsValid(ply) then return end
    
    for _, ragdoll in ipairs(BedRagdolls) do
        if IsValid(ragdoll) then
            net.Start("dex_add_ragdoll")
                net.WriteEntity(ragdoll)
            net.Send(ply)
        end
    end
    
    for player, isGagged in pairs(DEX_GAGGED_PLAYERS) do
        if IsValid(player) and isGagged then
            net.Start("dex_UpdateGagged")
                net.WriteEntity(player)
                net.WriteBool(isGagged)
            net.Send(ply)
        end
    end
    
    for _, bed in ipairs(ents.FindByClass("dex_bed")) do
        if IsValid(bed) and bed.Locked and IsValid(bed.BedPlayer) then
            net.Start("dex_bed_status")
                net.WriteEntity(bed)
                net.WriteBool(true)
                net.WriteEntity(bed.BedPlayer)
            net.Send(ply)
        end
    end
end

hook.Add("PlayerInitialSpawn", "Dex_SyncRagdollsOnJoin", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            SyncRagdollsWithPlayer(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "Dex_CleanupPlayerData", function(ply)
    DEX_GAGGED_PLAYERS[ply] = nil
    
    for k, ragdoll in pairs(BedRagdolls) do
        if IsValid(ragdoll) and ragdoll:GetOwner() == ply then
            ragdoll:Remove()
        end
    end
end)

function ENT:CreateBedRagdoll(model, skin, owner, pos, ang)
    local newRagdoll = ents.Create("prop_ragdoll")
    if not IsValid(newRagdoll) then return nil end

    newRagdoll:SetModel(model)
    newRagdoll:SetSkin(skin)
    newRagdoll:SetPos(pos)
    newRagdoll:SetAngles(ang)
    newRagdoll:SetOwner(owner)
    newRagdoll.IsSpecialBedRagdoll = true
    newRagdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    newRagdoll:SetKeyValue("spawnflags", "4")
    newRagdoll.IsOnBed = true

    table.insert(BedRagdolls, newRagdoll)
    newRagdoll:Spawn()

    timer.Simple(0, function()
        if IsValid(newRagdoll) then
            net.Start("dex_add_ragdoll")
                net.WriteEntity(newRagdoll)
            net.Broadcast()
        end
    end)

    return newRagdoll
end

function ENT:PositionRagdollLimbs(ragdoll, ragdollPos, ragdollAng)
    timer.Simple(0.1, function()
        if not IsValid(ragdoll) then return end
        
        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
            local phys = ragdoll:GetPhysicsObjectNum(i)
            if IsValid(phys) then
                phys:EnableMotion(false)
            end
        end

        self:PositionLimb(ragdoll, "ValveBiped.Bip01_R_UpperArm", ragdollPos, ragdollAng, Vector(10, 5, 0), Angle(0, -5, -100))
        self:PositionLimb(ragdoll, "ValveBiped.Bip01_R_Forearm", ragdollPos, ragdollAng, Vector(10, 5, 0), Angle(0, -5, -100))
        self:PositionLimb(ragdoll, "ValveBiped.Bip01_L_UpperArm", ragdollPos, ragdollAng, Vector(10, 5, 0), Angle(0, 5, 0))
        self:PositionLimb(ragdoll, "ValveBiped.Bip01_L_Forearm", ragdollPos, ragdollAng, Vector(10, 5, 0), Angle(0, 5, 0))
    end)
end

function ENT:PositionLimb(ragdoll, boneName, basePos, baseAng, offset, angleOffset)
    local boneID = ragdoll:LookupBone(boneName)
    if not boneID then return end
    
    local physIndex = ragdoll:TranslateBoneToPhysBone(boneID)
    local phys = ragdoll:GetPhysicsObjectNum(physIndex)
    if not IsValid(phys) then return end
    
    offset:Rotate(baseAng)
    local pos = basePos + offset
    local ang = Angle(baseAng.p + 90, baseAng.y, baseAng.r) + angleOffset
    
    phys:SetPos(pos)
    phys:SetAngles(ang)
    phys:EnableMotion(false)
end

function ENT:SetupFirstPersonView(targetPlayer, ragdoll)
    timer.Simple(0.5, function()
        if IsValid(ragdoll) and IsValid(targetPlayer) then
            net.Start("dex_EnterFirstPersonView")
            net.WriteEntity(ragdoll)
            net.Send(targetPlayer)
        end
    end)
end

function ENT:SchedulePlayerWakeUp(targetPlayer, ragdoll)
    timer.Simple(DEX_CONFIG.TimeToGetUp, function()
        if not IsValid(self) or not IsValid(targetPlayer) then return end
        if not IsValid(ragdoll) then return end

        ragdoll:Remove()
        
        DEX_GAGGED_PLAYERS[targetPlayer] = nil
        
        net.Start("dex_ExitFirstPersonView")
        net.Send(targetPlayer)
        
        targetPlayer:KillSilent()
        timer.Simple(0.1, function()
            if IsValid(targetPlayer) then
                targetPlayer:Spawn()
                targetPlayer:SetPos(self:GetPos() + Vector(0, 0, 50))
            end
        end)
        self.Locked = false

        net.Start("dex_bed_status")
            net.WriteEntity(self)
            net.WriteBool(false)
            net.WriteEntity(NULL)
        net.Broadcast()
    end)
end

function ENT:Touch(entity)
    if self.Locked or not IsValid(entity) or entity:GetClass() ~= "prop_ragdoll" then return end
    
    local ragdollModel = entity:GetModel()
    local ragdollSkin = entity:GetSkin()
    local ragdollOwner = entity:GetOwner()
    local storedName = entity.VictimName or DEX_LANG.Get("unknown")
    local targetPlayer = nil

    for _, ply in ipairs(player.GetAll()) do
        if ply:Nick() == storedName then
            targetPlayer = ply
            self.BedPlayer = targetPlayer
            break
        end
    end
    
    targetPlayer.Ragdoll = nil
    targetPlayer.IsInRagdoll = false
    targetPlayer:SetNWBool("IsInRagdoll", false)
    targetPlayer.RagdollStartTime = nil

    entity:Remove()
    
    local basePos = self:GetPos()
    local baseAng = self:GetAngles()
    
    self:SpawnMemorials(targetPlayer, basePos, baseAng)
    
    local offsetX = 17
    local offsetY = 32.5
    local offsetZ = 41
    local worldOffset = Vector(offsetX, offsetY, offsetZ)
    worldOffset:Rotate(baseAng)
    local ragdollPos = basePos + worldOffset
    local ragdollAng = Angle(-90, baseAng.y + 90, 0)
    
    local newRagdoll = self:CreateBedRagdoll(ragdollModel, ragdollSkin, ragdollOwner, ragdollPos, ragdollAng)
    if not IsValid(newRagdoll) then return end
    
    self:PositionRagdollLimbs(newRagdoll, ragdollPos, ragdollAng)
    self:SetupFirstPersonView(targetPlayer, newRagdoll)
    self:SchedulePlayerWakeUp(targetPlayer, newRagdoll)
    
    self.Locked = true
    
    net.Start("dex_bed_status")
        net.WriteEntity(self)
        net.WriteBool(true)
        net.WriteEntity(targetPlayer or NULL)
    net.Broadcast()

    timer.Simple(DEX_CONFIG.TimeToGetUp, function()
        if IsValid(self) then
            self.Locked = false

            net.Start("dex_bed_status")
                net.WriteEntity(self)
                net.WriteBool(false)
                net.WriteEntity(NULL)
            net.Broadcast()
        end
    end)
    
    if IsValid(targetPlayer) then
        targetPlayer.ragdoll = newRagdoll
    end
end

hook.Add("PhysgunPickup", "dex_PreventBedRagdollPickup", function(player, entity)
    if entity.IsOnBed then
        return false
    end
end)

hook.Add("CanPlayerUnfreeze", "dex_PreventBedRagdollUnfreeze", function(player, entity, physObj)
    if entity.IsOnBed then
        return false
    end
end)

hook.Add("EntityRemoved", "dex_CleanupBedRagdolls", function(entity)
    if entity.IsOnBed then
        for k, v in pairs(BedRagdolls) do
            if v == entity then
                table.remove(BedRagdolls, k)
                break
            end
        end
        
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply.ragdoll) and ply.ragdoll == entity then
                ply.ragdoll = nil
            end
        end
    end
end)