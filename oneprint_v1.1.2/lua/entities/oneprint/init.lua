/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

--[[

    ENT:Initialize

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

function ENT:Initialize()
    self:SetModel( "models/ogl/ogl_oneprint.mdl" )

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )

    for k, v in ipairs( self:GetBodyGroups() ) do
        self:SetBodygroup( k, 1 )
    end

    self:SetMaxHealth( OnePrint.Cfg.MaxHealth )
    self:SetHealth( self:GetMaxHealth() )

    self.fNextIncomeLog = ( CurTime() + OnePrint.Cfg.IncomeHistoryDelay )
    self:SetLight( 2 )
end

--[[

    ENT:OnVarChanged

]]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:OnVarChanged( sName, xOld, xNew )
    if ( sName == "OwnerObject" ) and IsValid( xNew ) and xNew:IsPlayer() then
        self:LogAction( 0, xNew:Name() )

    elseif ( sName == "Servers"  ) then
        timer.Simple( 0, function()
            self:SetServerBodygroups( 4, 0 )
        end )
    end
end

--[[

    ENT:Explode

]]--

local bUnchecked = true
local bFireOnExplosion = false

function ENT:Explode()
    local tPos = self:GetPos()

    local fxData = EffectData()
    fxData:SetOrigin( tPos )

    util.Effect( "Explosion", fxData )

    if bUnchecked then
        bFireOnExplosion = ( OnePrint.Cfg.FireOnExplosion and CH_FireSystem ) or nil
        bUnchecked = nil
    end

    if bFireOnExplosion then
        local iChance = math.random( 0, 100 )
        if ( iChance <= OnePrint.Cfg.FireChance ) then
            timer.Simple( .2, function()
                local eFire = ents.Create( "fire" )
                eFire:SetPos( tPos )
                eFire:Spawn()
            end )
        end
    end

    SafeRemoveEntity( self )
end

--[[

    ENT:OnTakeDamage

]]--

function ENT:OnTakeDamage( tDmg )
	if self.bApplyingDmg then
        return
    end

    self.bApplyingDmg = true

    local iHealth = self:Health()
    local iNewHealth = ( iHealth - tDmg:GetDamage() )

    if ( iNewHealth < 0 ) then
        if ( OnePrint.Cfg.CPDestroyReward > 0 ) then
            if DarkRP then
                if tDmg:GetAttacker() and IsValid( tDmg:GetAttacker() ) and tDmg:GetAttacker():isCP() then
                    if not ( self:GetOwnerObject() == tDmg:GetAttacker() ) or OnePrint.Cfg.CPRewardSelf then
                        OnePrint:AddMoney( tDmg:GetAttacker(), OnePrint.Cfg.CPDestroyReward )
                        OnePrint:Notify( tDmg:GetAttacker(), string.format( OnePrint:L( "You were rewarded %s for destroying a printer" ), OnePrint:FormatMoney( OnePrint.Cfg.CPDestroyReward ) ), 0, 4 )
                    end
                end
            end
        end

        if tDmg:GetAttacker() and IsValid( tDmg:GetAttacker() ) then
            hook.Run( "OnePrint_OnPlayerDestroyedPrinter", tDmg:GetAttacker(), self )
        end

        self:Explode()

        return
    end

    if self:GetLowHPNotif() then
        if ( iHealth > OnePrint.Cfg.CrititalCondition ) and ( iNewHealth <= OnePrint.Cfg.CrititalCondition ) then
			if self:GetOwnerObject() and IsValid( self:GetOwnerObject() ) then
				OnePrint:Notify( self:GetOwnerObject(), OnePrint:L( "Your printer is in critical condition" ), 1, 8 )

				if OnePrint.Cfg.NotifyAllUsers then
					local tUsers = self:GetUsers()
					if tUsers and not table.IsEmpty( tUsers ) then
						OnePrint:Notify( tUsers, OnePrint:L( "Your printer is in critical condition" ), 1, 8 )
					end
				end
			end   
        end
    end

    self:SetHealth( iNewHealth )

    if not self.bWarned then
        if ( self:GetCondition() <= OnePrint.Cfg.CrititalCondition ) then
            self.bWarned = true
            self:EmitSound( "HL1/fvox/warning.wav", 80 )

            timer.Simple( 6, function()
                if self and IsValid( self ) then
                    self.bWarned = nil
                end
            end )
        end
    end

	self.bApplyingDmg = nil
end

--[[

    ENT:AddServer

]]--

local tUpgradeItem = {
    [ 1 ] = function( eEnt )
        eEnt:SetServers( eEnt:GetServers() + 1 )
        eEnt:EmitSound( "physics/metal/metal_computer_impact_soft" .. math.random( 1, 3 ) .. ".wav", 70 )

        if eEnt:GetPowered() then
            eEnt:SetServerBodygroups( { 2, 3 }, 0 )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

            timer.Simple( 1.2, function()
                if eEnt and IsValid( eEnt ) and eEnt:GetPowered() then
                    eEnt:SetServerBodygroups( 1, 0 )
                end
            end )
        end

        eEnt.bEmptyStatic = true
    end,
    [ 2 ] = function( eEnt )
        eEnt:SetDefense( eEnt:GetDefense() + 1 )
        eEnt:SetMaxHealth( eEnt:GetMaxHealth() + OnePrint.Cfg.DefenseBoost )
        eEnt:SetHealth( eEnt:GetMaxHealth() )
    end,
    [ 3 ] = function( eEnt )
        eEnt:SetWatercooling( eEnt:GetWatercooling() + 1 )
    end,
    [ 4 ] = function( eEnt )
        eEnt:SetPower( eEnt:GetPower() + 1 )
    end,
    [ 5 ] = function( eEnt )
        eEnt:SetOverclocking( eEnt:GetOverclocking() + 1 )
    end,
    [ 6 ] = function( eEnt )
        eEnt:SetSecurity( eEnt:GetSecurity() + 1 )
    end,
    [ 7 ] = function( eEnt )
        eEnt:SetSilencer( eEnt:GetSilencer() + 1 )

        if eEnt.CSound then
            eEnt.CSound:Stop()
            eEnt.CSound = nil

            eEnt.CSound = CreateSound( eEnt, "oneprint/printer_loop.wav" )
            eEnt.CSound:SetSoundLevel( math.floor( 90 - ( eEnt:GetSilencer() * 10 ) ) )
            eEnt.CSound:Play()
        end
    end,
    [ 8 ] = function( eEnt )
        eEnt:SetHackNotif( true )
    end,
    [ 9 ] = function( eEnt )
        eEnt:SetLowHPNotif( true )
    end
}

function ENT:Upgrade( iUpgrade )
	if not iUpgrade or not OnePrint.Upgrade[ iUpgrade ] then
		return false
	end

    if not self:CanUpgrade( iUpgrade ) then
        return false
    end

    if not tUpgradeItem[ iUpgrade ] then
        return false
    end

    tUpgradeItem[ iUpgrade ]( self )

	local tUpgrade = OnePrint.Upgrade[ iUpgrade ].mutators
    if tUpgrade.heat then
        self:SetMaxTemperature( self:GetMaxTemperature() + tUpgrade.heat )
    end

    if tUpgrade.income then
        self:SetIncome( self:GetIncome() + tUpgrade.income )
    end

    if tUpgrade.incomeP then
        self:SetIncomeBonus( self:GetIncomeBonus() + tUpgrade.incomeP )
    end

    if tUpgrade.storage then
        self:SetStorage( self:GetStorage() + tUpgrade.storage )
    end

    return true
end

--[[

    ENT:ManageUser

]]--

function ENT:ManageUser( pPlayer, pTarget, bRemove )
	if not OnePrint.Cfg.MaxUsers or ( OnePrint.Cfg.MaxUsers <= 0 ) then
		return false
	end
    if not pPlayer or not IsValid( pPlayer ) or not pPlayer:IsPlayer() then
        return false
    end
    if ( self:GetOwnerObject() ~= pPlayer ) then
		return false
	end
    if not pTarget or not IsValid( pTarget ) or not pTarget:IsPlayer() then
        return false
    end

	local tData = self:GetUsers()
    local sSID3 = tostring( pTarget:AccountID() )

    if bRemove then
        tData[ sSID3 ] = nil
        self:LogAction( 4, pPlayer:Name(), pTarget:Name() )
    else
        if ( table.Count( tData ) > 8 ) then
            return
        end

        tData[ sSID3 ] = true
        self:LogAction( 3, pPlayer:Name(), pTarget:Name() )
    end

    self:SetUnparsedUsers( util.TableToJSON( tData ) )

    return true
end

--[[

    ENT:AddUser

]]--

function ENT:AddUser( pPlayer, pTarget )
    return self:ManageUser( pPlayer, pTarget )
end

--[[

    ENT:RemoveUser

]]--

function ENT:RemoveUser( pPlayer, pTarget )
    return self:ManageUser( pPlayer, pTarget, true )
end

--[[

    ENT:LogAction

]]--

function ENT:LogAction( iAction, xArg1, xArg2, xArg3 )
    if not iAction then
        return
    end

    local tLog = { iAction, os.time(), xArg1, xArg2, xArg3 }

	local tData = self:GetActionLogs()
    if ( table.Count( tData ) >= OnePrint.Cfg.MaxActionsHistory ) then
        for k, v in ipairs( tData ) do
            tData[ k - 1 ] = v
        end

        tData[ 0 ] = nil
        tData[ OnePrint.Cfg.MaxActionsHistory ] = tLog
    else
        table.insert( tData, tLog )
    end    

    self:SetUnparsedActionsLogs( util.TableToJSON( tData ) )
end


--[[

    ENT:LogIncome

]]--

function ENT:LogIncome()
    local iIncome = ( self.iLastIncomeLog or 0 )
    
    if ( iIncome == 0 ) then
        return
    end

	local tData = self:GetIncomeLogs()
    local iMaxIndex = OnePrint.Cfg.MaxIncomeHistory

    if ( #tData >= iMaxIndex ) then
        for k, v in ipairs( tData ) do
            tData[ k - 1 ] = v
        end

        tData[ 0 ] = nil
        tData[ iMaxIndex ] = iIncome
    else
        table.insert( tData, iIncome )
    end

    self:SetUnparsedIncomeLogs( util.TableToJSON( tData ) )
    self.iLastIncomeLog = 0
end

--[[

    ENT:ProcessTemperature

]]--

function ENT:ProcessTemperature()
    local iTemperature = self:GetTemperature()
    local iMaxTemperature = self:GetMaxTemperature()

    if ( iTemperature > OnePrint.Cfg.DamageTemperature ) then
        local iChance = math.random( 0, 100 )
        if ( iChance <= OnePrint.Cfg.DamageChance ) then
            local iAddedDamage = math.random( 0, OnePrint.Cfg.DamageMultiplier )
            local iNewHealth = ( self:Health() - iAddedDamage )

            if ( iNewHealth >= 1 ) then
                self:SetHealth( iNewHealth )

                if ( self:GetCondition() <= OnePrint.Cfg.CrititalCondition ) then
                    self:EmitSound( "HL1/fvox/warning.wav", 80 )
                end
            else
                self:Explode()
            end
        end
    end

    local iAddTemp = math.random( 1, OnePrint.Cfg.TemperatureMultiplier )

    if not self:GetPowered() then
        if ( ( iTemperature - ( iAddTemp * 3 ) ) <= 0 ) then
            self:SetTemperature( 0 )
        else
            if ( iTemperature ~= 0 ) then
                self:SetTemperature( iTemperature - ( iAddTemp * 3 ) )
            end
        end

        return
    end

    if ( iTemperature > iMaxTemperature ) then
        if ( iTemperature - iAddTemp ) > iMaxTemperature then
            self:SetTemperature( iTemperature - iAddTemp )
        end
    else
        if ( iTemperature + iAddTemp ) >= iMaxTemperature then
            self:SetTemperature( iMaxTemperature )
        else
            self:SetTemperature( iTemperature + iAddTemp )
        end
    end
end

--[[

    ENT:ProcessMoney

]]--

function ENT:ProcessMoney()
    if not self:GetPowered() then
        return
    end

    local iMoney = self:GetMoney()
    local iIncome = self:GetTotalIncome()
    local iStorage = self:GetStorage()

    if ( ( iMoney + iIncome ) > iStorage ) then
        self:SetMoney( iStorage )

        if ( iMoney ~= iStorage ) then
            self.iLastIncomeLog = ( self.iLastIncomeLog or 0 ) + iIncome
        end
    else
        self:SetMoney( iMoney + iIncome )
        self.iLastIncomeLog = ( self.iLastIncomeLog or 0 ) + iIncome
    end

    if self:IsStorageFull() then
        if ( self:GetSequence() ~= 2 ) then
            self:ResetSequence( 2 )
        end
    end
end

--[[

    ENT:Start

]]--

function ENT:Start()
    if ( self:GetServers() == 0 ) then
        return
    end

    self:SetNextOccur( CurTime() + OnePrint.Cfg.MoneyDelay )
    self:SetPowered( true )

    if ( self:GetTemperature() < 5 ) then
        self:SetTemperature( 5 )
    end

    self:SetServerBodygroups( { 2, 3 }, 0 )

    if self.bEmptyStatic then
        timer.Simple( 1.2, function()
            if self and IsValid( self ) and self:GetPowered() then
                self:SetServerBodygroups( 1, 0 )
                self.bEmptyStatic = nil
            end
        end )
    end

    self:ResetSequence( 3 )

    self.CSound = CreateSound( self, "oneprint/printer_loop.wav" )
    self.CSound:SetSoundLevel( math.floor( 90 - ( self:GetSilencer() * 10 ) ) )
    self.CSound:Play()
end

--[[

    ENT:Stop

]]--

function ENT:Stop()
    self:SetPowered( false )
    self:ResetSequence( 0 )

    local iMoney = self:GetMoney()

    self:SetServerBodygroups( { 2, 3 }, 1 )

    if ( iMoney <= 0 ) then
        self:SetServerBodygroups( 1, 1 )
        self.bEmptyStatic = true
    end

    if self.CSound then
        self.CSound:Stop()
        self.CSound = nil
    end
end

--[[

    ENT:Freeze

]]--

function ENT:Freeze()
    local oPhys = self:GetPhysicsObject()
    if oPhys and IsValid( oPhys ) then
        oPhys:EnableMotion( false )
        self:SetFrozen( true )
    end
end

--[[

    ENT:Unfreeze

]]--

function ENT:Unfreeze()
    local oPhys = self:GetPhysicsObject()
    if oPhys and IsValid( oPhys ) then
        oPhys:EnableMotion( true )
        self:SetFrozen( false )
    end
end

-- 1 = moneystatic
-- 2 = moneyscroll
-- 3 = fallingmoney
--[[

    ENT:SetServerBodygroups

]]--

function ENT:SetServerBodygroups( xType, iState )
    if not xType then
        return
    end

    local tRef = { 6, 12, 18, 0 }

    if isnumber( xType ) then
        if not tRef[ xType ] then
            return 
        end
        for i = 1, self:GetServers() do
            if ( self:GetBodygroup( ( tRef[ xType ] + i ) ) ~= ( iState or 0 ) ) then
                self:SetBodygroup( ( tRef[ xType ] + i ), ( iState or 0 ) )
            end
        end

    elseif istable( xType ) then
        for _, iBodygroup in ipairs( xType ) do
            if not tRef[ iBodygroup ] then
                continue
            end

            self:SetServerBodygroups( iBodygroup, iState )
        end
    end
end

--[[

    ENT:EmptyStatic

]]--

function ENT:EmptyStatic()
    self:SetServerBodygroups( 1, 1 )
    self.bEmptyStatic = true

    if not self:GetPowered() then
        return
    end

    self:ResetSequence( 3 )

    timer.Simple( 1.2, function()
        if self and IsValid( self ) and self:GetPowered() then
            self:SetServerBodygroups( 1, 0 )
            self.bEmptyStatic = nil
        end
    end )
end

--[[

    ENT:SetLight

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

function ENT:SetLight( iLight )
    if not iLight or ( iLight < 1 ) or ( iLight > 4 ) then
        iLight = 4
    end

    for iBodygroup, v in ipairs( self:GetBodyGroups() ) do
        if ( iBodygroup <= 24 ) then
            continue
        end

        if ( iBodygroup == ( iLight + 24 ) ) then
            self:SetBodygroup( iBodygroup, 0 )
        else
            self:SetBodygroup( iBodygroup, 1 )
        end
    end
end

--[[

    ENT:OnRemove

]]--

function ENT:OnRemove()
    if self.CSound then
        self.CSound:Stop()
    end

    local pOwner = self:GetOwnerObject()
    if pOwner and IsValid( pOwner ) then
        if pOwner.tOwnedPrinters then
            if table.HasValue( pOwner.tOwnedPrinters, self ) then
                table.RemoveByValue( pOwner.tOwnedPrinters, self )
            end

            if GSmartWatch then
                OnePrint:UpdateGSmartWatch( pOwner )
            end
        end
    end
end

--[[

    ENT:Think

]]--

function ENT:Think()
    local fNextOccur = self:GetNextOccur()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	if ( ( fNextOccur - CurTime() ) < 0 ) then
		self:ProcessTemperature()
        self:ProcessMoney()
		self:SetNextOccur( CurTime() + OnePrint.Cfg.MoneyDelay )
	end

	if ( ( self.fNextIncomeLog - CurTime() ) < 0 ) then
        self:LogIncome()
		self.fNextIncomeLog = ( CurTime() + OnePrint.Cfg.IncomeHistoryDelay )
	end

    self:NextThink( CurTime() )

    return true
end
