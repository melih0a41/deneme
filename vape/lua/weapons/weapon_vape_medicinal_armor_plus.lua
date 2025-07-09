if CLIENT then
    include("weapon_vape/cl_init.lua")
else
    include("weapon_vape/shared.lua")
end

SWEP.PrintName = "Medicinal Armor Vape+"
SWEP.Instructions = "Kullanırken saniyede +5 can kazandırır, toplamda +100 cana kadar."
SWEP.VapeID = 34

SWEP.VapeAccentColor = Vector(0, 0, 1)
SWEP.VapeTankColor = Vector(1, 0, 0)
