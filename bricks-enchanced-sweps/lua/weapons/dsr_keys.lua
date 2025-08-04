AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Anahtarlar"
    SWEP.Slot = 1
    SWEP.SlotPos = 0
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to lock\nRight click to unlock\nReload for door settings or animation menu"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IsDarkRPKeys = true

SWEP.ViewModel = Model( "models/sterling/c_enhanced_keys.mdl" )
SWEP.WorldModel = ( "models/sterling/w_enhanced_keys.mdl" )
SWEP.ViewModelFOV = 85
SWEP.AnimPrefix  = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP SWEP Replacements"
SWEP.Sound = "doors/door_latch3.wav"

SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

hook.Add( "Initialize", "BESHooks_Initialize_AddKeys", function( ply )
	if( not table.HasValue( GAMEMODE.Config.DefaultWeapons, "dsr_keys" ) ) then
		table.insert( GAMEMODE.Config.DefaultWeapons, "dsr_keys" )
	end
end )

function SWEP:Initialize()
    self:SetHoldType( "normal" )
    self:SetCarkeys( true )
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Carkeys" )
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(false)
    if( not self:GetCarkeys() ) then
        self.Weapon:SendWeaponAnim( ACT_VM_IDLE_TO_LOWERED )
    end
    return true
end

function SWEP:Holster()
    return true
end

local function lookingAtLockable(ply, ent, hitpos)
    local eyepos = ply:EyePos()
    return IsValid(ent)             and
        ent:isKeysOwnable()         and
        (
            ent:isDoor()    and eyepos:DistToSqr(hitpos) < 3000
            or
            ent:IsVehicle() and eyepos:DistToSqr(hitpos) < 100000
        )
end

local function lockUnlockAnimation(ply, snd, car)
    if( not car ) then
        ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")
        timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)
    else
        ply:EmitSound("bricksenhancedsweps/car_lock.wav")
    end

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("usekeys")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end

local function doKnock(ply, sound)
    ply:EmitSound(sound, 100, math.random(90, 110))

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("knocking")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end

function SWEP:SetNextFire( time )
    self:SetNextPrimaryFire( time )
    self:SetNextSecondaryFire( time )
end

function SWEP:PrimaryAttack()
    local trace = self:GetOwner():GetEyeTrace()

    if not lookingAtLockable(self:GetOwner(), trace.Entity, trace.HitPos) then return end

    if CLIENT then return end

    if self:GetOwner():canKeysLock(trace.Entity) then
        if( trace.Entity:IsVehicle() ) then
            if( self:GetCarkeys() ) then
                trace.Entity:keysLock()
                lockUnlockAnimation(self:GetOwner(), self.Sound, true)
                self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
                timer.Simple( 1, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end )
                self:SetNextFire( CurTime() + 1.1 )
            else
                self:SetCarkeys( true )
                self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_LOW )
                timer.Simple( 0.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end )
                self:SetNextFire( CurTime() + 0.6 )
            end
        else
            if( not self:GetCarkeys() ) then
                trace.Entity:keysLock()
                lockUnlockAnimation(self:GetOwner(), self.Sound)
                self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
                timer.Simple( 1.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE_TO_LOWERED ) end )
                self:SetNextFire( CurTime() + 1.6 )
            else
                self:SetCarkeys( false )
                self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK )
                timer.Simple( 0.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE_TO_LOWERED ) end )
                self:SetNextFire( CurTime() + 0.6 )
            end
        end
    elseif trace.Entity:IsVehicle() then
        DarkRP.notify(self:GetOwner(), 1, 3, DarkRP.getPhrase("do_not_own_ent"))
    else
        doKnock(self:GetOwner(), "physics/wood/wood_crate_impact_hard2.wav")
    end
end

function SWEP:SecondaryAttack()
    local trace = self:GetOwner():GetEyeTrace()

    if not lookingAtLockable(self:GetOwner(), trace.Entity, trace.HitPos) then return end

    if CLIENT then return end

    if self:GetOwner():canKeysUnlock(trace.Entity) then
        if( trace.Entity:IsVehicle() ) then
            if( self:GetCarkeys() ) then
                trace.Entity:keysUnLock()
                lockUnlockAnimation(self:GetOwner(), self.Sound, true)
                self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
                timer.Simple( 1, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end )
                self:SetNextFire( CurTime() + 1.1 )
            else
                self:SetCarkeys( true )
                self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_LOW )
                timer.Simple( 0.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end )
                self:SetNextFire( CurTime() + 0.6 )
            end
        else
            if( not self:GetCarkeys() ) then
                trace.Entity:keysUnLock()
                lockUnlockAnimation(self:GetOwner(), self.Sound)
                self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
                timer.Simple( 1.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE_TO_LOWERED ) end )
                self:SetNextFire( CurTime() + 1.6 )
            else
                self:SetCarkeys( false )
                self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK )
                timer.Simple( 0.5, function() if( self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE_TO_LOWERED ) end )
                self:SetNextFire( CurTime() + 0.6 )
            end
        end
    elseif trace.Entity:IsVehicle() then
        DarkRP.notify(self:GetOwner(), 1, 3, DarkRP.getPhrase("do_not_own_ent"))
    else
        doKnock(self:GetOwner(), "physics/wood/wood_crate_impact_hard3.wav")
    end
end

function SWEP:Reload()
    local trace = self:GetOwner():GetEyeTrace()
    if not IsValid(trace.Entity) or ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():DistToSqr(trace.HitPos) > 40000) then
        if CLIENT and not DarkRP.disabledDefaults["modules"]["animations"] then RunConsoleCommand("_DarkRP_AnimationMenu") end
        return
    end
    if SERVER then
        umsg.Start("KeysMenu", self:GetOwner())
        umsg.End()
    end
end

if( CLIENT ) then
    local mat = Material( "sterling/enhanced_brand" )
    local mat2, id = BES.GetImage( BES.CONFIG.Keys.ServerLogo )
    local originalTexture = false
    function SWEP:PreDrawViewModel( viewmodel, weapon )
        if( not originalTexture ) then
            originalTexture = mat:GetTexture( "$basetexture" )
        end

        if( BES.CONFIG.Keys.ServerLogo ) then
            if( id == BES.CONFIG.Keys.ServerLogo and mat2 != nil and type( mat2:GetTexture( "$basetexture" ) ) == "ITexture" ) then
                mat:SetTexture( "$basetexture", mat2:GetTexture( "$basetexture" ) )
            else
                mat:SetTexture( "$basetexture", originalTexture )
                mat2, id = BES.GetImage( BES.CONFIG.Keys.ServerLogo )
            end
        else
            mat:SetTexture( "$basetexture", originalTexture )
        end
    end
end