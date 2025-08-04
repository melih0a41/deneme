
AddCSLuaFile()

SWEP.PrintName = "Metal Detektörü" -- change the name
SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to scan a player for weapons"

SWEP.Category = "DarkRP SWEP Replacements" -- change the name


SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/sterling/c_enhanced_metaldetector.mdl" ) -- just change the model 
SWEP.WorldModel = ( "models/sterling/w_enhanced_metaldetector.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( "pistol" )
end

function SWEP:GetStrippableWeapons(ent, callback)
    CAMI.PlayerHasAccess(ent, "DarkRP_GetAdminWeapons", function(access)
        for _, v in pairs(ent:GetWeapons()) do
            if not v:IsValid() then continue end
            local class = v:GetClass()

            if GAMEMODE.Config.weaponCheckerHideDefault and (table.HasValue(GAMEMODE.Config.DefaultWeapons, class) or
                access and table.HasValue(GAMEMODE.Config.AdminWeapons, class) or
                ent:getJobTable() and ent:getJobTable().weapons and table.HasValue(ent:getJobTable().weapons, class)) then
                continue
            end

            if (GAMEMODE.Config.weaponCheckerHideNoLicense and GAMEMODE.NoLicense[class]) or GAMEMODE.Config.noStripWeapons[class] then continue end

            callback(v)
        end
    end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:SetNextPrimaryFire(CurTime() + 1.7)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    local ent = trace.Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GetPos():DistToSqr(self:GetOwner():GetPos()) > 10000 then
        return
    end

    if not IsFirstTimePredicted() then return end

    local weps = {}
    self:GetStrippableWeapons(ent, function(wep)
        table.insert(weps, wep)
    end)

	hook.Call("playerWeaponsChecked", nil, self:GetOwner(), ent, weps)

	timer.Simple( 1, function() 
        if( not IsValid( ent ) or not IsValid( self.Owner ) or self.Owner:GetActiveWeapon() != self.Weapon ) then return end 

		self:EmitSound("bricksenhancedsweps/beep.wav", 50, 100)

        if( timer.Exists( "BES_WeaponChecker_BG_" .. self.Owner:SteamID64() ) ) then
            timer.Remove( "BES_WeaponChecker_BG_" .. self.Owner:SteamID64() )
        end

		if( #weps > 0 ) then
            self.Owner:GetViewModel():SetBodygroup( 1, 2 )
        else
			self.Owner:GetViewModel():SetBodygroup( 1, 1 )
        end
        
        timer.Create( "BES_WeaponChecker_BG_" .. self.Owner:SteamID64(), 2, 1, function() 
            if( not IsValid( self.Owner ) or self.Owner:GetActiveWeapon() != self.Weapon ) then return end 

            self.Owner:GetViewModel():SetBodygroup( 1, 0 )
        end )
		
		if not CLIENT then return end
		
		self:PrintWeapons(ent, DarkRP.getPhrase("persons_weapons", ent:Nick()))
    end )
end 

function SWEP:PrintWeapons(ent, weaponsFoundPhrase)
    local result = {}
    local weps = {}
    self:GetStrippableWeapons(ent, function(wep)
        table.insert(weps, wep)
    end)

    for _, wep in ipairs(weps) do
        table.insert(result, wep:GetPrintName() and language.GetPhrase(wep:GetPrintName()) or wep:GetClass())
    end

    result = table.concat(result, ", ")

    if result == "" then
        self:GetOwner():ChatPrint(DarkRP.getPhrase("no_illegal_weapons", ent:Nick()))
        return
    end

    self:GetOwner():ChatPrint(weaponsFoundPhrase)
    if string.len(result) >= 126 then
        local amount = math.ceil(string.len(result) / 126)
        for i = 1, amount, 1 do
            self:GetOwner():ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
        end
    else
        self:GetOwner():ChatPrint(result)
    end
end

function SWEP:SecondaryAttack()
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:Reload()
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
end