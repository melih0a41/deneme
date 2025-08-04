AddCSLuaFile()

SWEP.PrintName = "Megafon" -- change the name
SWEP.Author = "Brickwall"
SWEP.Instructions = "Left/right click to toggle megaphone"
SWEP.Purpose = "Increases the range of your voice"

SWEP.Category = "DarkRP SWEP Replacements" -- change the name


SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/sterling/c_enhanced_megaphone.mdl" ) -- just change the model 
SWEP.WorldModel = ( "models/sterling/w_enhanced_megaphone.mdl" )
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

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "TurnedOn" )
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end

    if( self:GetTurnedOn() ) then
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    end
    return true
end

function SWEP:Initialize()
	self:SetWeaponHoldType( "pistol" )

	self:SetTurnedOn( false )
end

function SWEP:PrimaryAttack()
	if( not self:GetTurnedOn() ) then
		self:SetTurnedOn( true )
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
end 

function SWEP:SecondaryAttack()
	if( self:GetTurnedOn() ) then
		self:SetTurnedOn( false )
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	end
end

hook.Add( "PlayerCanHearPlayersVoice", "BES_PlayerCanHearPlayersVoice_MegaPhone", function( listener, talker )
	local TalkerWep = talker:GetActiveWeapon()
	if( IsValid( TalkerWep ) and TalkerWep:GetClass() == "dsr_megaphone" and TalkerWep:GetTurnedOn()  ) then 
		if( listener:GetPos():DistToSqr( talker:GetPos() ) < 100000 ) then 
			return true, true
		end
	end
end )