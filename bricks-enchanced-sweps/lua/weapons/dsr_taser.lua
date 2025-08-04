
AddCSLuaFile()

SWEP.PrintName = "Şok Tabancası" -- change the name
SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to tase a player"

SWEP.Category = "DarkRP SWEP Replacements" -- change the name


SWEP.Slot = 1
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/sterling/c_enhanced_taser.mdl" ) -- just change the model 
SWEP.WorldModel = ( "models/sterling/w_enhanced_taser.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Recoil = 5.1
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 1
SWEP.Primary.Delay = 0.3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "stungun"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = true
SWEP.Base = "weapon_base"

SWEP.Secondary.Ammo = "none"

game.AddAmmoType({
	name = "stungun",
	dmgtype = DMG_GENERIC,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	minsplash = 0,
	maxsplash = 0
})

if( CLIENT ) then
	language.Add( "stungun_ammo", "Stungun Cartridge" )
end

--DarkRP.createAmmoType("stungun", {
--	name = "Stungun Cartridge",
--	model = "models/sterling/enhanced_taser_ammobox.mdl",
--	price = 150,
--	amountGiven = 12
--})

sound.Add( {
	name = "bes_taser",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "ambient/energy/electric_loop.wav"
} )

function SWEP:Initialize()
	self:SetWeaponHoldType( "pistol" )
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
	self:TakePrimaryAmmo( 1 )

	self.Owner:LagCompensation(true)
	local tr = util.TraceLine(util.GetPlayerTrace( self.Owner ))
	self.Owner:LagCompensation(false)

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "ToolTracer", effectdata )

	self:EmitSound("npc/turret_floor/shoot1.wav",100,100)

	if( tr.Entity and IsValid( tr.Entity ) and tr.Entity:IsPlayer() and not tr.Entity:GetNWBool( "BES_TASERED", false ) and tr.Entity:GetPos():DistToSqr( self:GetPos() ) < 60000 ) then
		local jobTable = RPExtraTeams[tr.Entity:Team() or 1] or {}
        if( not table.HasValue( BES.CONFIG.Taser.JobBlacklist, (jobTable.command or "ERROR") ) ) then
			local UserID = tr.Entity:UserID()
			timer.Create( "BES_TIMER_TASER_" .. UserID, 1, 0, function()
				if( tr.Entity and IsValid( tr.Entity ) and tr.Entity:IsPlayer() and tr.Entity:GetNWBool( "BES_TASERED", false ) ) then
					tr.Entity:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_GESTURE, table.Random( { 117, 119, 124 } ) )
				else
					timer.Remove( "BES_TIMER_TASER_" .. UserID )
				end
			end )

			if SERVER then
				tr.Entity:EmitSound( "bes_taser" )
				tr.Entity:SetNWBool( "BES_TASERED", true )
				tr.Entity:Freeze( true )
				timer.Simple( 5, function()
					if( tr.Entity and IsValid( tr.Entity ) and tr.Entity:IsPlayer() and tr.Entity:GetNWBool( "BES_TASERED", false ) ) then
						tr.Entity:Freeze( false )
						tr.Entity:SetNWBool( "BES_TASERED", false )
						tr.Entity:StopSound( "bes_taser" )
					end
				end )
			end
		end
	end
end 

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

hook.Add( "PlayerDeath", "BES_PlayerDeath_Taser", function( victim )
	if( IsValid( victim ) and victim:GetNWBool( "BES_TASERED", false ) ) then
		victim:Freeze( false )
		victim:SetNWBool( "BES_TASERED", false )
		victim:StopSound( "bes_taser" )
	end
end )

hook.Add( "EntityRemoved", "BES_EntityRemoved_Taser", function( ent )
	if( IsValid( ent ) and ent:GetNWBool( "BES_TASERED", false ) ) then
		ent:SetNWBool( "BES_TASERED", false )
		ent:StopSound( "bes_taser" )
	end
end )