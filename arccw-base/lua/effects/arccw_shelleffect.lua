
EFFECT.Sounds = {}
EFFECT.Pitch = 90
EFFECT.Scale = 1.5
EFFECT.PhysScale = 1
EFFECT.Model = "models/shells/shell_57.mdl"
EFFECT.Material = nil
EFFECT.JustOnce = true
EFFECT.AlreadyPlayedSound = false
EFFECT.ShellTime = 1

EFFECT.SpawnTime = 0

function EFFECT:Init(data)

    local att = data:GetAttachment()
    local ent = data:GetEntity()
    local mag = data:GetMagnitude()

    local mdl = LocalPlayer():GetViewModel()

    if LocalPlayer():ShouldDrawLocalPlayer() then
        mdl = ent.WMModel or ent
    end

    if !IsValid(ent) then self:Remove() return end

    local owner = ent:GetOwner()
    if owner != LocalPlayer() then
        mdl = ent.WMModel or ent
    end

    if owner != LocalPlayer() and !ArcCW.ConVars["shelleffects"]:GetBool() then self:Remove() return end
    if !IsValid(mdl) then self:Remove() return end
    if !mdl:GetAttachment(att) then self:Remove() return end

    local origin, ang = mdl:GetAttachment(att).Pos, mdl:GetAttachment(att).Ang

    ang:RotateAroundAxis(ang:Right(), -90 + ent.ShellRotate)

    ang:RotateAroundAxis(ang:Right(), (ent.ShellRotateAngle or Angle(0, 0, 0))[1])
    ang:RotateAroundAxis(ang:Up(), (ent.ShellRotateAngle or Angle(0, 0, 0))[2])
    ang:RotateAroundAxis(ang:Forward(), (ent.ShellRotateAngle or Angle(0, 0, 0))[3])

    local dir = ang:Up()

    local st = ArcCW.ConVars["shelltime"]:GetFloat()

    if ent then
        self.Model = ent:GetBuff_Override("Override_ShellModel") or ent.ShellModel
        self.Material = ent:GetBuff_Override("Override_ShellMaterial") or ent.ShellMaterial
        self.Scale = ent:GetBuff("ShellScale") or 1--ent:GetBuff_Override("Override_ShellScale") or ent.ShellScale or 1
        self.PhysScale = ent:GetBuff_Override("Override_ShellPhysScale") or ent.ShellPhysScale or 1
        self.Pitch = ent:GetBuff_Override("Override_ShellPitch") or ent.ShellPitch or 100
        self.Sounds = ent:GetBuff_Override("Override_ShellSounds") or ent.ShellSounds
        self.ShellTime = (ent.ShellTime or 0) + st

        if self.Sounds == "autocheck" and ent:GetPrimaryAmmoType() then
            local t = ent:GetPrimaryAmmoType()
            if t == game.GetAmmoID("buckshot") then
                self.Sounds = ArcCW.ShotgunShellSoundsTable
            elseif ent.Trivia_Calibre and string.find(ent.Trivia_Calibre, ".22") then
                self.Sounds = ArcCW.TinyShellSoundsTable
            elseif t == game.GetAmmoID("pistol") or t == game.GetAmmoID("357") or t == game.GetAmmoID("AlyxGun") then
                self.Sounds = ArcCW.PistolShellSoundsTable
            elseif t == game.GetAmmoID("ar2") then
                self.Sounds = ArcCW.MediumShellSoundsTable
            else
                self.Sounds = ArcCW.ShellSoundsTable
            end
        end
    end

    self:SetPos(origin)
    self:SetModel(self.Model)
    self:SetModelScale(self.Scale)
    self:DrawShadow(true)
    self:SetAngles(ang)

    if self.Material then
        self:SetMaterial(self.Material)
    end

    local pb_vert = 2 * self.Scale * self.PhysScale
    local pb_hor = 0.5 * self.Scale * self.PhysScale

    self:PhysicsInitBox(Vector(-pb_vert,-pb_hor,-pb_hor), Vector(pb_vert,pb_hor,pb_hor))

    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

    local phys = self:GetPhysicsObject()

    local plyvel = Vector(0, 0, 0)

    if IsValid(owner) then
        plyvel = owner:GetAbsVelocity()
    end


    phys:Wake()
    phys:SetDamping(0, 0)
    phys:SetMass(1)
    phys:SetMaterial("gmod_silent")

    phys:SetVelocity((dir * mag * math.Rand(1, 2)) + plyvel)

    phys:AddAngleVelocity(VectorRand() * 100)
    phys:AddAngleVelocity(ang:Up() * 2500 * math.Rand(0.75, 1.25))

    self.HitPitch = self.Pitch + math.Rand(-5,5)

    local emitter = ParticleEmitter(origin)

    for i = 1, 3 do
        local particle = emitter:Add("particles/smokey", origin + (dir * 2))

        if (particle) then
            particle:SetVelocity(VectorRand() * 10 + (dir * i * math.Rand(48, 64)) + plyvel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.05, 0.15))
            particle:SetStartAlpha(math.Rand(40, 60))
            particle:SetEndAlpha(0)
            particle:SetStartSize(0)
            particle:SetEndSize(math.Rand(18, 24))
            particle:SetRoll(math.rad(math.Rand(0, 360)))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetLighting(true)
            particle:SetAirResistance(96)
            particle:SetGravity(Vector(-7, 3, 20))
            particle:SetColor(150, 150, 150)
        end
    end

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide()
    if self.AlreadyPlayedSound and self.JustOnce then return end

    sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)

    self.AlreadyPlayedSound = true
end

function EFFECT:Think()
    if (self.SpawnTime + self.ShellTime) <= CurTime() then
        if !IsValid(self) then return end
        self:SetRenderFX( kRenderFxFadeFast )
        if (self.SpawnTime + self.ShellTime + 1) <= CurTime() then
            if !IsValid(self:GetPhysicsObject()) then return end
            self:GetPhysicsObject():EnableMotion(false)
            if (self.SpawnTime + self.ShellTime + 1.5) <= CurTime() then
                self:Remove()
                return
            end
        end
    end
    return true
end

function EFFECT:Render()
    if !IsValid(self) then return end
    self:DrawModel()
end