if CLIENT then
    include("weapon_vape/cl_init.lua")
else
    include("weapon_vape/shared.lua")
end

SWEP.PrintName = "Armor Vape+"
SWEP.Instructions = "Kullanırken saniyede +5 zırh kazandırır, toplamda +100 zırha kadar."
SWEP.VapeID = 32

SWEP.VapeAccentColor = Vector(0.3, 0.3, 1)
SWEP.VapeTankColor = Vector(0.3, 0.3, 1)
