SWEP.PrintName = DEX_LANG.Get("placer_print_name")
SWEP.Author = "Odinzz"
SWEP.Instructions = DEX_LANG.Get("placer_instructions")
SWEP.Category = "Dex's Addons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/phone/phone.mdl"
SWEP.WorldModel = "models/phone/phonew.mdl"
SWEP.UseHands = true
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.ViewModelFOV = 50

SWEP.Secondary = SWEP.Primary

SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"

SWEP.ItemsToBuy = DEX_CONFIG.ItemsToBuy

function SWEP:DrawWorldModel()
    if not IsValid(self:GetOwner()) then
        self:DrawModel()
        return
    end

    local boneIndex = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
    if not boneIndex then return end

    local pos, ang = self:GetOwner():GetBonePosition(boneIndex)
    if not pos or not ang then return end

    local offset = Vector(3, 4, 2)
    local angleOffset = Angle(0, 180, 180)

    pos = pos + ang:Right() * offset.x
    pos = pos + ang:Forward() * offset.y
    pos = pos + ang:Up() * offset.z

    ang:RotateAroundAxis(ang:Up(), angleOffset.y)
    ang:RotateAroundAxis(ang:Right(), angleOffset.p)
    ang:RotateAroundAxis(ang:Forward(), angleOffset.r)

    self:SetRenderOrigin(pos)
    self:SetRenderAngles(ang)
    self:DrawModel()
end
