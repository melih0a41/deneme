--[[------------------------------------------------
                Minigame NPC - Weapons
------------------------------------------------]]--

ENT.ActiveWeapon = false

--[[----------------------------
         Main Functions
----------------------------]]--

function ENT:EnableWeapon()
    self.WeaponEnt:SetNoDraw(false)
    self:StartActivity(ACT_IDLE_ANGRY_PISTOL)
    self.ActiveWeapon = true
end

function ENT:DisableWeapon()
    self.WeaponEnt:SetNoDraw(true)
    self:StartActivity(ACT_IDLE)
    self.ActiveWeapon = false
end

function ENT:StripWeapon()
    self:DisableWeapon()
end

--[[----------------------------
            Post-Init
----------------------------]]--

ENT:AddModule(function(self)
    self.WeaponEnt = ents.Create("prop_physics")
    self.WeaponEnt:SetModel("models/weapons/w_357.mdl")
    self.WeaponEnt:SetPos(self:GetPos())
    self.WeaponEnt:SetParent(self)
    self.WeaponEnt:Spawn()

    self.WeaponEnt:FollowBone(self, self:LookupBone("ValveBiped.Bip01_R_Hand"))

    -- Forward the weapon
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 170)
    ang:RotateAroundAxis(ang:Up(), 14)

    self.WeaponEnt:SetAngles(ang)
    self.WeaponEnt:SetSolid(SOLID_NONE)
    self.WeaponEnt:SetMoveType(MOVETYPE_NONE)
    self.WeaponEnt:SetCollisionGroup(COLLISION_GROUP_NONE)
    self.WeaponEnt:SetOwner(self)
    self.WeaponEnt:SetNoDraw(true)
end)