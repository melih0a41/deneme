/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

include("shared.lua")
SWEP.PrintName = "Çöp Toplayıcısı" -- The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function SWEP:Initialize()
	ztm.TrashCollector.Initialize(self)
end

function SWEP:Think()
	ztm.TrashCollector.Think(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

function SWEP:PrimaryAttack()
	ztm.TrashCollector.PrimaryAttack(self)
end

function SWEP:SecondaryAttack()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function SWEP:OnRemove()
	ztm.TrashCollector.OnRemove(self)
end

function SWEP:Holster(swep)
	ztm.TrashCollector.Holster(self)
end
