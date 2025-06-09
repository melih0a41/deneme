-- DOSYA: addons/vape/lua/weapons/weapon_vape/shared.lua (2. KOD)

if SERVER then
    AddCSLuaFile("shared.lua")
end

SWEP.Author = "Swamp Onions"
SWEP.Instructions = "LMB: Basılı tut ve bırak\nRMB & Reload: Ses çıkar\n\nVape Nation!"
SWEP.PrintName = "Vape"
SWEP.Category = "Vapes"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.ViewModelFOV = 62
SWEP.ViewModel = "models/swamponions/vape.mdl"
SWEP.WorldModel = "models/swamponions/vape.mdl"
SWEP.HoldType = "slam"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.VapeID = 1 -- Her vape türü için bu ID'yi değiştirmelisin.

function SWEP:Initialize()
    self.NextVapeTick = 0
    self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    -- Boş bırakıyoruz, işi :Think() yapıyor.
end

function SWEP:SecondaryAttack()
    if GetConVar("vape_block_sounds"):GetBool() then return end
    local pitch = 100 + (self.SoundPitchMod or 0) + (self.Owner:Crouching() and 40 or 0)
    self:EmitSound("vapegogreen1.wav", 80, pitch + math.Rand(-5,5))
    if SERVER then
        net.Start("VapeTalking"); net.WriteEntity(self.Owner); net.WriteFloat(CurTime() + (0.6*100/pitch)); net.Broadcast()
    end
end

function SWEP:Reload()
    if GetConVar("vape_block_sounds"):GetBool() or self.reloading then return end
    self.reloading=true
    timer.Simple(0.5, function() if IsValid(self) then self.reloading=false end end)
    local pitch = 100 + (self.SoundPitchMod or 0) + (self.Owner:Crouching() and 40 or 0)
    self:EmitSound("vapenaysh1.wav", 80, pitch + math.Rand(-5,5))
    if SERVER then
        net.Start("VapeTalking"); net.WriteEntity(self.Owner); net.WriteFloat(CurTime() + (2.2*100/pitch)); net.Broadcast()
    end
end

function SWEP:Holster()
    if SERVER and IsValid(self.Owner) then ReleaseVape(self.Owner) end
    return true
end

SWEP.OnDrop = SWEP.Holster
SWEP.OnRemove = SWEP.Holster

--[[
    BU FONKSİYON, SORUNUN KAYNAĞIYDI VE ŞİMDİ DÜZELTİLDİ.
    'if CLIENT then' bloğu, bu kodun sadece oyuncu tarafında çalışmasını sağlar.
    Böylece sunucu, 'SendToServer' gibi bilmediği bir fonksiyonu çalıştırmaya kalkmaz.
]]--
function SWEP:Think()
    if not IsValid(self:GetOwner()) then return end

    if CLIENT then
        if self:GetOwner():KeyDown(IN_ATTACK) then
            if CurTime() > self.NextVapeTick then
                net.Start("VapeUpdateServer")
                net.WriteUInt(self.VapeID, 8)
                net.SendToServer()
                self.NextVapeTick = CurTime() + 0.1
            end
        end
    end
end