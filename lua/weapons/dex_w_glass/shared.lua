SWEP.PrintName = DEX_LANG.Get("glass_printname")
SWEP.Category = "Dex's Addons"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.Purpose = ''
SWEP.Author = 'Odinzz'
SWEP.UseHands = true

SWEP.HoldType = 'pistol'
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 70
SWEP.BobScale = 0.05

SWEP.ViewModel = Model('models/blood/glassw.mdl')
SWEP.WorldModel = Model('models/blood/glassw.mdl')

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsPicking = false
SWEP.PickTime = 15

function SWEP:SetTargetPlayerName(name)
    self.GlassData = self.GlassData or {}
    self.GlassData.currentName = name
end

function SWEP:GetTargetPlayerName()
    return (self.GlassData and self.GlassData.currentName) or "Ninguém"
end
