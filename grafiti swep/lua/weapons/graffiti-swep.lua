-- Created by T1ger / Edit by Fenixor

if (SERVER) then
    AddCSLuaFile('client/graffiti-ui.lua')
    include('client/graffiti-ui.lua')
elseif (CLIENT) then
    include('client/graffiti-ui.lua')
end

SWEP.PrintName = 'Graffiti'
SWEP.Author = 'Edit by Fenxior'
SWEP.Contact = 'https://steamcommunity.com/profiles/76561198888519908/'
SWEP.Category = 'Graffiti - SWEP'
SWEP.Spawnable = true
SWEP.UseHands = false
SWEP.DrawWeaponInfoBox = false
SWEP.AutoSwitchTo = false
SWEP.AdminOnly = false
SWEP.DrawAmmo = false
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelFlip = true
SWEP.Slot = 0
SWEP.SlotPos = 5

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'
SWEP.Secondary.Ammo = 'none'
SWEP.HoldType = 'pistol'

SWEP.Base = 'sck-base'
SWEP.Time = 0
 
SWEP.ViewModel = 'models/weapons/v_smg1.mdl'
SWEP.WorldModel = 'models/weapons/w_pistol.mdl'
 
SWEP.ViewModelBoneMods = 
{
    ['ValveBiped.base'] = {scale = Vector(0, 0, 0), pos = Vector(2.5, -6.853, 11.666), angle = Angle(0, 0, 0)},
    ['ValveBiped.Bip01_L_Hand'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-50, -56.667, 81.111)},
    ['ValveBiped.Bip01_L_Forearm'] = {scale = Vector(1, 1, 1), pos = Vector(-6.853, 6.48, 5.369), angle = Angle(-23.334, -1.111, 43.333)},
    ['ValveBiped.Bip01_L_Finger0'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -30, -47.778)},
    ['ValveBiped.Bip01_L_Finger02'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -14.445, 0)},
    ['ValveBiped.Bip01_L_Finger1'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 21.111, 0)},
    ['ValveBiped.Bip01_L_Finger3'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -12.223, -3.333)},
    ['ValveBiped.Bip01_L_Finger4'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(7.777, -23.334, -12.223)},
    ['ValveBiped.Bip01_L_Finger11'] = {scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 45.555, 0)},
}

SWEP.WepSelectIcon = Material('entities/graffiti-swep-icon.png')

function SWEP:Initialize()

    self:SetHoldType(self.HoldType)

    if (CLIENT) then

        local ply = LocalPlayer()

        if (tostring(file.Find('graffiti-swep/graffiti-include.txt', 'DATA')[1]) != 'graffiti-include.txt') then
            file.CreateDir('graffiti-swep')
            file.Write('graffiti-swep/graffiti-include.txt', '-- This is used to check the directory \n-- Note: you can estimate my add-on \n-- https://steamcommunity.com/sharedfiles/filedetails/?id=2889832721')
        end
        if (tostring(file.Find('graffiti-swep/graffiti-settings-client.txt', 'DATA')[1]) == 'graffiti-settings-client.txt') then
            local settings = file.Open('graffiti-swep/graffiti-settings-client.txt', 'r', 'DATA')
            ply:SetNWBool('GraffitiInterfaceSounds', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWBool('GraffitiSkin', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWInt('GraffitiSkinSelected', settings:ReadLine():gsub('%s+', ''))
            settings:Close()
        else
            ply:SetNWBool('GraffitiInterfaceSounds', true)
            ply:SetNWBool('GraffitiSkin', false)
            ply:SetNWInt('GraffitiSkinSelected', 1)
        end

        if (ply:IsSuperAdmin()) and (tostring(file.Find('graffiti-swep/graffiti-settings-server.txt', 'DATA')[1]) == 'graffiti-settings-server.txt') then
            local settings = file.Open('graffiti-swep/graffiti-settings-server.txt', 'r', 'DATA')
            ply:SetNWBool('GraffitiAdmins', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWBool('GraffitiCanModify', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWBool('GraffitiCanSounds', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWBool('GraffitiCanParticle', tobool(settings:ReadLine():gsub('%s+', '')))
            ply:SetNWBool('GraffitiExplosion', tobool(settings:ReadLine():gsub('%s+', '')))
            settings:Close()

            local commands = {'graffiti_admins_only', 'graffiti_can_sounds', 'graffiti_can_particle', 'graffiti_explosion'}
            local args = {ply:GetNWBool('GraffitiAdmins'), ply:GetNWBool('GraffitiCanSounds'), ply:GetNWBool('GraffitiCanParticle'), ply:GetNWBool('GraffitiExplosion')}
            for i=1,4 do
                if (args[i] == true) then
                    RunConsoleCommand(commands[i], 1)
                elseif (args[i] == false) then
                    RunConsoleCommand(commands[i], 0)
                end
            end
        else
            ply:SetNWBool('GraffitiAdmins', false)
            ply:SetNWBool('GraffitiCanModify', false)
            ply:SetNWBool('GraffitiCanSounds', true)
            ply:SetNWBool('GraffitiCanParticle', true)
            ply:SetNWBool('GraffitiExplosion', false)
        end

        if (tostring(file.Find('graffiti-swep/graffiti-settings.txt', 'DATA')[1]) == 'graffiti-settings.txt') then
            local settings = file.Open('graffiti-swep/graffiti-settings.txt', 'r', 'DATA')
            ply:SetNWString('GraffitiColor', settings:ReadLine():gsub('%s+', ''))
            ply:SetNWString('GraffitiSize', settings:ReadLine():gsub('%s+', ''))
            ply:SetNWBool('GraffitiBrush', settings:ReadLine():gsub('%s+', ''))
            ply:SetNWInt('GraffitiSpraying', settings:ReadLine():gsub('%s+', ''))
            ply:SetNWInt('GraffitiSlider', settings:ReadLine():gsub('%s+', ''))
            settings:Close()
        else
            ply:SetNWString('GraffitiColor', 'Black')
            ply:SetNWString('GraffitiSize', 'Normal')
            ply:SetNWBool('GraffitiBrush', false)
            ply:SetNWInt('GraffitiSpraying', 0)
            ply:SetNWInt('GraffitiSlider', 0)
        end
        net.Start('GraffitiColorChanger')
            net.WriteString(ply:GetNWString('GraffitiColor'))
        net.SendToServer()
        net.Start('GraffitiSizeChanger')
            net.WriteString(ply:GetNWString('GraffitiSize'))
        net.SendToServer()
        net.Start('GraffitiBrushChanger')
            net.WriteBool(tobool(ply:GetNWBool('GraffitiBrush')))
        net.SendToServer()
        net.Start('GraffitiSprayingChanger')
            net.WriteString(ply:GetNWString('GraffitiSpraying'))
        net.SendToServer()

        if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 1) then
            self.VElements = {['m'] = {type = 'Model', model = 'models/props/graffiti-swep-1.mdl', bone = 'ValveBiped.Bip01_L_Hand', rel = '', pos = Vector(-3, -6.6, 1), angle = Angle(66, 66, 87), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
            self.WElements = {['spr'] = {type = 'Model', model = 'models/props/graffiti-swep-1.mdl', bone = 'ValveBiped.Bip01_R_Hand', rel = '', pos = Vector(3, 1.5, 4.7), angle = Angle(0, -100, 180), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
        elseif (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 2) then
            self.VElements = {['m'] = {type = 'Model', model = 'models/props/graffiti-swep-2.mdl', bone = 'ValveBiped.Bip01_L_Hand', rel = '', pos = Vector(-3, -6.6, 1), angle = Angle(66, 66, 87), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
            self.WElements = {['spr'] = {type = 'Model', model = 'models/props/graffiti-swep-2.mdl', bone = 'ValveBiped.Bip01_R_Hand', rel = '', pos = Vector(3, 1.5, 4.7), angle = Angle(0, -100, 180), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
        elseif (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 3) then
            self.VElements = {['m'] = {type = 'Model', model = 'models/props/graffiti-swep-3.mdl', bone = 'ValveBiped.Bip01_L_Hand', rel = '', pos = Vector(-3, -6.6, 1), angle = Angle(66, 66, 87), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
            self.WElements = {['spr'] = {type = 'Model', model = 'models/props/graffiti-swep-3.mdl', bone = 'ValveBiped.Bip01_R_Hand', rel = '', pos = Vector(3, 1.5, 4.7), angle = Angle(0, -100, 180), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = '', skin = 0, bodygroup = {}}}
        end

        self.VElements = table.FullCopy(self.VElements)
        self.WElements = table.FullCopy(self.WElements)
        self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)

        self:CreateModels(self.VElements)
        self:CreateModels(self.WElements)

        if IsValid(self:GetOwner()) then
            local vmodel = self:GetOwner():GetViewModel()
            if IsValid(vmodel) then
                self:ResetBonePositions(vmodel)

                if (self.ShowViewModel == nil or self.ShowViewModel) then
                    vmodel:SetColor(Color(255, 255, 255, 255))
                else
                    vmodel:SetColor(Color(255, 255, 255, 1))
                    vmodel:SetMaterial('Debug/hsv')         
                end
            end
        end
    end
end

function SWEP:PrimaryAttack()
    if (self:CanPrimaryAttack()) and (SERVER) and (self.Time < CurTime()) then

        if (tonumber(self:GetOwner():GetNWInt('GraffitiUIOpen')) == 1) then return end
        if (GetConVar('graffiti_can_sounds'):GetInt() == 0) then
            if (self.spraying != nil) and (self.spraying:IsPlaying()) then
                self.spraying:Stop()
            end
        end
        if (GetConVar('graffiti_admins_only'):GetInt() == 1) and (self:GetOwner():IsAdmin() == false) then
            self:GetOwner():SetNWInt('GraffitiCanSpray', 0)
            if (self.spraying != nil) and (self.spraying:IsPlaying()) then
                self.spraying:Stop()
            end
            return
        elseif (GetConVar('graffiti_admins_only'):GetInt() == 0) and (self:GetOwner():IsAdmin() == false) then
            self:GetOwner():SetNWInt('GraffitiCanSpray', 1)
        end
        
        self.spraying = CreateSound(self:GetOwner(), 'graffiti-swep/spraying.mp3')
        if (!self.spraying:IsPlaying()) then
            if (GetConVar('graffiti_can_sounds'):GetInt() == 1) then
                self.spraying:Play()
            end
        else
            self.spraying:ChangeVolume(1, 0.1)
        end
        if (tonumber(self:GetOwner():GetNWInt('GraffitiSpraying'), 10) > 0.05) then
            self.Weapon:SetNextPrimaryFire(CurTime() + self:GetOwner():GetNWInt('GraffitiSpraying'))
            self.spraying:ChangeVolume(0, 0.2)
        end
        local effect = EffectData()
            effect:SetOrigin(self:GetOwner():GetShootPos())
            effect:SetNormal(self:GetOwner():GetAimVector())
            effect:SetEntity(self.Weapon)
            effect:SetAttachment(1)

            if (GetConVar('graffiti_can_particle'):GetInt() == 1) then
                util.Effect('graffiti-effect', effect)
            end

        local trace = self:GetOwner():GetEyeTrace()

        if (trace.HitPos:Distance(self:GetOwner():GetPos())) <= GetConVar('graffiti_max_distance'):GetInt() then
            if (trace.Entity:IsPlayer()) or (trace.Entity:IsNPC()) then
                trace.Entity:TakeDamage(0.15)
            end
            if (trace.Entity == Entity(0)) then
                if (self:GetOwner():GetNWBool('GraffitiBrush') == true) then
                    if (self:GetOwner():GetNWString('GraffitiColor') == 'EmoTexture') then
                        util.Decal('nothing', trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    elseif (self:GetOwner():GetNWString('GraffitiColor') == 'Amogus') then
                        util.Decal('amogus', trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    elseif (self:GetOwner():GetNWString('GraffitiColor') == 'Floppa') then
                        util.Decal('floppa', trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    elseif (self:GetOwner():GetNWString('GraffitiColor') == 'Shrek') then
                        util.Decal('shrek', trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    end
                else
                    if (self:GetOwner():GetNWString('GraffitiSize') == 'Small') then
                        local decal = string.lower(self:GetOwner():GetNWString('GraffitiColor')) .. '-s'
                        util.Decal(decal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    elseif (self:GetOwner():GetNWString('GraffitiSize') == 'Normal') then
                        local decal = string.lower(self:GetOwner():GetNWString('GraffitiColor')) .. '-n'
                        util.Decal(decal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    elseif (self:GetOwner():GetNWString('GraffitiSize') == 'Large') then
                        local decal = string.lower(self:GetOwner():GetNWString('GraffitiColor')) .. '-l'
                        util.Decal(decal, trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil)
                    end
                end
                if (GetConVar('graffiti_explosion'):GetInt() == 1) then
                    local efdata = EffectData()
                    efdata:SetOrigin(Vector(trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal, nil))
                    util.Effect('Explosion', efdata, false, true)
                end
            end
        end
    elseif (CLIENT) then

        if (self.Time > CurTime()) then return end
        if (tonumber(LocalPlayer():GetNWInt('GraffitiUIOpen')) == 1) then return end
        if (tonumber(LocalPlayer():GetNWInt('GraffitiCanSpray')) == 0) and (self:GetOwner():IsAdmin() == false) then return end
        
        local effect = EffectData()
            effect:SetOrigin(self:GetOwner():GetShootPos())
            effect:SetNormal(self:GetOwner():GetAimVector())
            effect:SetEntity(self.Weapon)
            effect:SetAttachment(1)
            if (LocalPlayer():GetNWBool('GraffitiCanParticle') == true) then
                util.Effect('graffiti-effect', effect)
            end
    end
end
function SWEP:SecondaryAttack()
    if (CurTime() > self.Time) and (self:GetOwner():IsValid()) then
        self.Time = CurTime() + 1
        if (self.spraying != nil) and (self.spraying:IsPlaying()) then
            self.spraying:Stop()
        end
    end
    self.Weapon:CallOnClient('GraffitiUI', nil)
end
 
function SWEP:Deploy()
    return true
end
 
function SWEP:Holster()
    if (CLIENT) and (IsValid(self:GetOwner())) then
        local vmodel = self:GetOwner():GetViewModel()
        if (IsValid(vmodel)) then
            self:ResetBonePositions(vmodel)
        end
    end
    if (SERVER) and (self.spraying != nil) then
        if (self.spraying:IsPlaying()) then
            self.spraying:Stop()
        end
    end
    return true
end
 
function SWEP:Reload()
    if (CurTime() > self.Time) and (self:GetOwner():IsValid()) then
        self.Time = CurTime() + 1.5
        if (self.spraying != nil) and (self.spraying:IsPlaying()) then
            self.spraying:Stop()
        end
        self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
        self:GetOwner():SetAnimation(PLAYER_RELOAD)
        timer.Simple(0.45, function() 
            if (self:IsValid() == true) then 
                if (GetConVar('graffiti_can_sounds'):GetInt() == 1) then
                    self:GetOwner():EmitSound('graffiti-swep/reloading.mp3', 100, math.random(95, 105), 1, CHAN_WEAPON)
                end
            end
        end)
    end
end
 
function SWEP:Think()
    if (SERVER) then
        if (self:GetOwner():KeyReleased(IN_ATTACK)) and (self.spraying != nil) then
            if (self.spraying:IsPlaying()) then
                self.spraying:ChangeVolume(0, 0.1)
            end
        elseif (self:GetOwner():KeyPressed(IN_ZOOM)) and (self.spraying != nil) then
            if (self.spraying:IsPlaying()) then
                self.spraying:ChangeVolume(0, 0.1)
            end
        end
    end
end

function SWEP:OnRemove()
    self:Holster()
end