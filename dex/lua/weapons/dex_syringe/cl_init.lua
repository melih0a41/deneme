include('shared.lua')

local function Scale(size)
    return math.ceil(size * (ScrH() / 1080))
end

local blackoutColor = Color(0, 0, 0, 180)
local fadeColor = Color(0, 0, 0, 0)

local isBlackingOut = false
local blackoutStart = 0
local blackoutDuration = 3
local blackoutAlpha = 0

local myRagdoll = nil
local isInRagdoll = false
local isRecovering = false
local recoveryStart = 0
local recoveryDuration = 3


function SWEP:Initialize()
    self:CreateWorldModel()
end

function SWEP:CreateWorldModel()
    if IsValid(self.WorldModelEnt) then self.WorldModelEnt:Remove() end

    self.WorldModelEnt = ClientsideModel(self.WorldModel)
    self.WorldModelEnt:SetNoDraw(true)
end

function SWEP:OnRemove()
    if IsValid(self.WorldModelEnt) then
        self.WorldModelEnt:Remove()
    end
end

function SWEP:Holster()
    if IsValid(self.WorldModelEnt) then
        self.WorldModelEnt:Remove()
    end
    return true
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        self:DrawModel()
        return
    end

    local boneIndex = owner:LookupBone("ValveBiped.Bip01_R_Hand")
    if not boneIndex then
        self:DrawModel()
        return
    end

    local boneMatrix = owner:GetBoneMatrix(boneIndex)
    if not boneMatrix then
        self:DrawModel()
        return
    end

    local offsetPos = Vector(-15, -2, 6)
    local offsetAng = Angle(0, 0, 90)

    local pos, ang = LocalToWorld(offsetPos, offsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())

    if not IsValid(self.WorldModelEnt) then return end

    self.WorldModelEnt:SetPos(pos)
    self.WorldModelEnt:SetAngles(ang)
    self.WorldModelEnt:SetupBones()
    self.WorldModelEnt:DrawModel()
end

net.Receive("dex_StartBlackout", function()
    local ragdoll = net.ReadEntity()

    timer.Simple(0.1, function()
        if IsValid(ragdoll) then
            isBlackingOut = true
            blackoutStart = CurTime()
            blackoutAlpha = 0
            myRagdoll = ragdoll
            isInRagdoll = true
        end
    end)
end)

net.Receive("dex_StartRecovery", function()
    isBlackingOut = false
    isInRagdoll = false
    myRagdoll = nil
    
    isRecovering = true
    recoveryStart = CurTime()
    
    timer.Create("dex_BlackoutFadeOut", 0.01, 0, function()
        if blackoutAlpha > 0 then
            blackoutAlpha = math.max(0, blackoutAlpha - 3)
        else
            timer.Remove("dex_BlackoutFadeOut")
        end
    end)
end)

local lastAlive = true

hook.Add("HUDPaint", "dex_BlackoutEffect", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if not ply:Alive() and lastAlive then
        isBlackingOut = false
        isInRagdoll = false
        isRecovering = false
        blackoutAlpha = 0
        myRagdoll = nil
        timer.Remove("dex_BlackoutFadeOut")
    end

    lastAlive = ply:Alive()

    if isBlackingOut then
        local progress = math.min((CurTime() - blackoutStart) / blackoutDuration, 1)
        blackoutAlpha = Lerp(progress, 0, 180)

        fadeColor.a = blackoutAlpha
        surface.SetDrawColor(fadeColor)
        surface.DrawRect(0, 0, ScrW(), ScrH())

        if progress >= 1 then
            isBlackingOut = false
        end
    elseif blackoutAlpha > 0 then
        fadeColor.a = blackoutAlpha
        surface.SetDrawColor(fadeColor)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end
end)

hook.Add("CalcView", "dex_CustomCamera", function(ply, pos, angles, fov)
    if isInRagdoll and IsValid(myRagdoll) then
        local rag = myRagdoll
        local boneID = rag:LookupBone("ValveBiped.Bip01_Head1") or 0
        local camPos = rag:GetPos()

        if boneID then
            local bonePos, boneAng = rag:GetBonePosition(boneID)
            if bonePos then
                camPos = bonePos + Vector(-7, 0, 5)
                angles = boneAng
            end
        end

        return {
            origin = camPos,
            angles = angles,
            fov = fov
        }
    end

    if isRecovering then
        local elapsed = CurTime() - recoveryStart
        local progress = math.min(elapsed / recoveryDuration, 1)
        local shake = math.sin(CurTime() * 5) * (1 - progress) * 2

        angles.pitch = angles.pitch + shake
        angles.roll = angles.roll + shake * 0.5

        if progress >= 1 then
            isRecovering = false
        end

        return {
            origin = pos,
            angles = angles,
            fov = fov
        }
    end
end)

hook.Add("PlayerDeath", "dex_CleanupBlackoutDeath", function(ply)
    if ply == LocalPlayer() then
        isBlackingOut = false
        isInRagdoll = false
        isRecovering = false
        blackoutAlpha = 0
        myRagdoll = nil
        timer.Remove("dex_BlackoutFadeOut")
    end
end)