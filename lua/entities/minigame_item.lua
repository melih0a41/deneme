--[[------------------------------------------------
                    Minigame Item
------------------------------------------------]]--

AddCSLuaFile()

ENT.PrintName = "Minigame Item"
ENT.Category = "Minigame Tool Assistant"

ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Type = "anim"
ENT.Base = "base_anim"


ENT.InactiveColor = Color(0, 0, 0)

ENT.BoundRadius = Vector(16, 16, 16)
ENT.Trigger = NULL


--[[------------------------------------------------
                 Spawn Entity Types
------------------------------------------------]]--

local SpawnEntityType = {
    "minigame_spawnpoint",
    "minigame_ammo",
    "minigame_weapon",
    "minigame_health",
    "minigame_armor",
}

local SpawnEntityTypeColor = {
    color_white,
    Color(255, 255, 0),
    Color(255, 150, 0),
    Color(0, 255, 0),
    Color(0, 255, 255),
}

local SpawnEntityTypeModel = {
    "models/props_phx2/garbage_metalcan001a.mdl",
    "models/Items/BoxMRounds.mdl",
    "models/Items/item_item_crate.mdl",
    "models/Items/HealthKit.mdl",
    "models/Items/battery.mdl",
}

local SpawnEntityTypeSize = {
    1.5,
    0.9,
    0.5,
    1.0,
    1.0,
}

local SpawnEntityTypeFunction = {
    function() end,
    function(self, ply)
        -- Get the current weapon and try to give ammo to it
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then return false end

        local ammo = wep:GetPrimaryAmmoType()
        if ammo == -1 then return false end

        ply:GiveAmmo(200, ammo)
    end,
    function(self, ply)
        local wpns = table.Copy( Minigames.Config["WeaponsKit"][ self:GetItemWeaponKit() ] )
        -- remove all weapons that the player already has
        for _, wep in ipairs(wpns) do
            if ply:HasWeapon(wep) then
                table.RemoveByValue(wpns, wep)
            end
        end

        -- If the player has all the weapons, return false
        if #wpns == 0 then return false end

        ply:Give( wpns[ math.random(1, #wpns) ] )
    end,
    function(self, ply)
        if ply:Health() >= ply:GetMaxHealth() then return false end

        local healthamount = self:GetItemAmount()
        ply:SetHealth( math.min(ply:Health() + healthamount, ply:GetMaxHealth()) )
    end,
    function(self, ply)
        if ply:Armor() >= ply:GetMaxArmor() then return false end

        local armoramount = self:GetItemAmount()
        ply:SetArmor( math.min(ply:Armor() + armoramount, ply:GetMaxArmor()) )
    end
}



--[[------------------------------------------------
                  Trigger Functions
------------------------------------------------]]--

local TRIGGER = {}

function TRIGGER:GetGameScript()
    return Minigames.GetOwnerGame( self:GetParent():Getowning_ent() )
end

function TRIGGER:PlayerInGame(ply)
    return self:GetGameScript():HasPlayer(ply)
end

function TRIGGER:IsActive()
    return self:GetGameScript():IsActive()
end

function TRIGGER:OnStartTouch(ply)
    if not self:IsActive() then return end
    if not ( ply:IsPlayer() and self:PlayerInGame(ply) ) then return end
    if self:GetParent():GetIsCooldown() then return end

    self:GetParent():SpawnEntityItem(ply)
end



--[[------------------------------------------------
                      Functions
------------------------------------------------]]--

function ENT:SetupDataTables()
    -- Principal Config
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Int", 0, "SpawnEntityType")
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Bool", 1, "IsCooldown")

    -- Minigame Config
    self:NetworkVar("Int", 1, "ItemAmount")
    self:NetworkVar("Float", 0, "ItemRespawnTime")
    self:NetworkVar("String", 0, "ItemWeaponKit")

    -- Networking
    self:NetworkVarNotify("SpawnEntityType", self.OnSpawnEntityChange)
    self:NetworkVarNotify("IsCooldown", self.Cooldown)
end

function ENT:GetGameScript()
    return Minigames.GetOwnerGame( self:Getowning_ent() )
end

function ENT:IsActive()
    local GameScript = self:GetGameScript()
    return ( GameScript ~= nil ) and GameScript:IsActive()
end


function ENT:OnSpawnEntityChange(_, _, new)
    if ( CLIENT ) then
        if not SpawnEntityTypeModel[new] then return end
        self:CreateDisplayModel()

        self.DisplayModel:SetModel(SpawnEntityTypeModel[new])
        self.DisplayModel:SetModelScale(SpawnEntityTypeSize[new])
    end

    if SERVER then
        if ( new == 1 ) then
            self.Trigger.StartTouch = function() end
        else
            self.Trigger.StartTouch = TRIGGER.OnStartTouch
        end
    end
end

function ENT:Cooldown(_, _, CooldownState)
    if ( CLIENT ) then
        if not self.DisplayModel then return end
        self:CreateDisplayModel()

        if CooldownState then
            self.DisplayModel:SetNoDraw(true)
        else
            self.DisplayModel:SetNoDraw(false)
        end
    end
end

function ENT:CreateDisplayModel()
    if ( SERVER ) then return end
    if self.DisplayModel then return end

    self.DisplayModel = ClientsideModel( SpawnEntityTypeModel[self:GetSpawnEntityType()] or "models/hunter/blocks/cube025x025x025.mdl", RENDERGROUP_OPAQUE )
    self.DisplayModel:SetPos( self:GetPos() )
    self.DisplayModel:Spawn()
    self.DisplayModel:SetParent( self )
    self.DisplayModel:SetModelScale(SpawnEntityTypeSize[self:GetSpawnEntityType()] or 1)
end

function ENT:Initialize()
    if ( SERVER ) then
        self.Trigger = ents.Create("minigame_trigger")
        self.Trigger:SetPos( self:GetPos() )
        self.Trigger:Setowning_ent( self:Getowning_ent() )
        self.Trigger:Spawn()
        self.Trigger:SetParent( self )

        self.Trigger:SetCollisionBounds(-self.BoundRadius, self.BoundRadius)

        self.Trigger.GetGameScript = TRIGGER.GetGameScript
        self.Trigger.IsActive = TRIGGER.IsActive
        self.Trigger.StartTouch = TRIGGER.OnStartTouch
        self.Trigger.PlayerInGame = TRIGGER.PlayerInGame
    end

    if ( CLIENT ) then
        self.DisplayModel = ClientsideModel( SpawnEntityTypeModel[self:GetSpawnEntityType()] or "models/hunter/blocks/cube025x025x025.mdl", RENDERGROUP_OPAQUE )
        self.DisplayModel:SetPos( self:GetPos() )
        self.DisplayModel:Spawn()
        self.DisplayModel:SetParent( self )
        self.DisplayModel:SetModelScale(SpawnEntityTypeSize[self:GetSpawnEntityType()] or 1)
    end

    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetActive(false)
    self:SetIsCooldown(false)
end

function ENT:OnRemove()
    if ( SERVER ) then
        self.Trigger:Remove()
    elseif ( CLIENT ) then
        self.DisplayModel:Remove()
    end
end



--[[------------------------------------------------
                   Item Functions
------------------------------------------------]]--

if ( SERVER ) then
    function ENT:SpawnEntityItem(ply)
        if not self:IsActive() then return end

        local entitytype = self:GetSpawnEntityType()
        if not entitytype then return end

        local result = SpawnEntityTypeFunction[entitytype](self, ply)
        if result == false then return end

        self:DoRespawn()
    end

    function ENT:GetRandomWeapon()
        return Minigames.Config["WeaponsKit"][ self:GetItemWeaponKit() ][ math.random(1, #Minigames.Config["WeaponsKit"][ self:GetItemWeaponKit() ]) ]
    end

    function ENT:DoRespawn()
        self:SetIsCooldown(true)
        self:SetItemRespawnTime(CurTime() + 5)
    end

    function ENT:Think()
        if self:GetIsCooldown() and CurTime() > self:GetItemRespawnTime() then
            self:SetIsCooldown(false)
        end
    end

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
end



--[[------------------------------------------------
                       Render
------------------------------------------------]]--


if ( CLIENT ) then
    local TextPositionOffset = Vector(0, 0, 12)

    function ENT:DrawText(entitytype)
        draw.SimpleTextOutlined(Minigames.GetPhrase(SpawnEntityType[entitytype]), "DermaLarge", 0, 0, SpawnEntityTypeColor[entitytype], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, color_black )
    end

    function ENT:Think() -- Rotate the displaymodel
        if not IsValid(self.DisplayModel) then return end

        if self:GetIsCooldown() then
            self.DisplayModel:SetAngles(angle_zero)
            self.DisplayModel:SetLocalPos(vector_origin)
            return
        end

        self.DisplayModel:SetAngles(Angle(0, CurTime() * 70, 0))

        -- Levitates the model up and down
        local pos = self.DisplayModel:GetLocalPos()
        pos.z = ( math.sin(CurTime() * 2) * 2 ) - 12
        self.DisplayModel:SetLocalPos(pos)
    end

    function ENT:Draw()
        -- self:DrawModel()

        local entitytype = self:GetSpawnEntityType()
        local pos = self:GetPos() + TextPositionOffset
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        cam.Start3D2D(pos, ang, 0.15)
            self:DrawText(entitytype)
        cam.End3D2D()

        ang:RotateAroundAxis(ang:Up(), 180)
        ang:RotateAroundAxis(ang:Forward(), 180)

        cam.Start3D2D(pos, ang, 0.15)
            self:DrawText(entitytype)
        cam.End3D2D()

        if entitytype == 1 then return end

        -- Draw a box around the trigger
        cam.Start3D()
            render.SetColorMaterial()
            render.DrawWireframeBox(self:GetPos(), self:GetAngles(), -self.BoundRadius, self.BoundRadius, not self:GetIsCooldown() and SpawnEntityTypeColor[entitytype] or self.InactiveColor, true)
        cam.End3D()
    end
end