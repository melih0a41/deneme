/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

util.AddNetworkString( "OnePrintNW" )

if GSmartWatch then
	util.AddNetworkString( "GSmartWatch_OnePrintSupport" )
end

--[[

    downloadFolderContent

]]--

-- local function downloadFolderContent( sPath )
-- 	local tFiles, tFolders = file.Find( sPath .. "/*", "GAME" )

--     for _, v in pairs( tFiles ) do
-- 		resource.AddFile( sPath .. "/" .. v )
-- 	end

-- 	for _, v in pairs( tFolders ) do
-- 		downloadFolderContent( sPath .. "/" .. v )
-- 	end
-- end

-- downloadFolderContent( "materials/oneprint" )
-- downloadFolderContent( "materials/models/ogl" )
-- downloadFolderContent( "models/ogl" )
-- downloadFolderContent( "sound/oneprint" )

-- resource.AddFile( "resource/fonts/Rajdhani-Bold.ttf" )
-- resource.AddFile( "resource/fonts/Rajdhani-Regular.ttf" )

-- downloadFolderContent = nil

resource.AddWorkshop( "2207914195" )

--[[

	OnePrint:Withdraw

]]--

function OnePrint:Withdraw( pPlayer, ePrinter )
	if not pPlayer or not IsValid( pPlayer ) then
		return
	end

	if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
		return
	end

	local iMoney = ePrinter:GetMoney()
	if not iMoney or ( iMoney <= 0 ) then
		return
	end

	ePrinter:SetMoney( 0 )
	OnePrint:AddMoney( pPlayer, iMoney )

    ePrinter:LogAction( 1, pPlayer:Name(), iMoney )
	hook.Run( "OnePrint_OnWithdraw", pPlayer, iMoney, ePrinter )

	ePrinter:EmptyStatic()
end

--[[

	OnePrint:Repair

]]--

function OnePrint:Repair( pPlayer, ePrinter )
	if not pPlayer or not IsValid( pPlayer ) then
		return
	end

	if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
		return
	end

	if ( ePrinter:Health() == ePrinter:GetMaxHealth() ) then
		return
	end

    local iHPPercent = ( ePrinter:Health() * 100 / ePrinter:GetMaxHealth() )
    local iRepairPrice = OnePrint.Cfg.RepairPrice - math.ceil( OnePrint.Cfg.RepairPrice * iHPPercent / 100 )

	if not pPlayer:OP_CanAfford( iRepairPrice ) then
		return
	end

	OnePrint:AddMoney( pPlayer, - iRepairPrice )
	ePrinter:SetHealth( ePrinter:GetMaxHealth() )

	ePrinter:LogAction( 2, pPlayer:Name(), OnePrint:L( "Reparation" ) .. " [" .. OnePrint:FormatMoney( iRepairPrice ) .. "]" )
end

--[[
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

	OnePrint:BuyUpgrade

]]--

function OnePrint:BuyUpgrade( pPlayer, ePrinter, iUpgrade, upgradeNeeded )
	upgradeNeeded = upgradeNeeded or 1

	if not pPlayer or not IsValid( pPlayer ) then
		return false
	end

	if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
		return false
	end

	if not iUpgrade or not OnePrint.Upgrade[ iUpgrade ] then
		return false 
	end

	local tUpgrade = OnePrint.Upgrade[ iUpgrade ]

	local price = tUpgrade.price * upgradeNeeded
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

	if not pPlayer:OP_CanAfford( price ) then
		OnePrint:Notify( pPlayer, OnePrint:L( "Not enough money" ), 1 )
		return false
	end

	for i=1, upgradeNeeded do
		local bUpgrade = ePrinter:Upgrade( iUpgrade )

		if not bUpgrade then
			continue
		end
	end

	OnePrint:AddMoney( pPlayer, - price )
	ePrinter:LogAction( 2, pPlayer:Name(), tUpgrade.name, price )

	hook.Run( "OnePrint_BuyUpgrade", pPlayer, tUpgrade, price )

	if RFSYS and RFSYS.AddPriceToEnt then
		RFSYS:AddPriceToEnt( ePrinter, price )
	end
end

--[[
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

	OnePrint:SetTab

]]--

local tValidTabs = {}
for i = 0, 4 do
	tValidTabs[ i ] = true
end

function OnePrint:SetTab( pPlayer, ePrinter, iTab, bHack )
	if not pPlayer or not IsValid( pPlayer ) then
		return
	end

	if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) then
		return
	end

	if not bHack and not ePrinter:CanPlayerUse( pPlayer ) then
		return
	end

	if not iTab or not tValidTabs[ iTab ] then
		return
	end

	ePrinter:SetCurrentTab( iTab )
end

--[[

	OnePrint:UpdateGSmartWatch

]]--

if GSmartWatch then
	function OnePrint:UpdateGSmartWatch( pPlayer )
		if not pPlayer or not IsValid( pPlayer ) or not pPlayer:IsPlayer() then
			return
		end

		if not pPlayer.tOwnedPrinters or not istable( pPlayer.tOwnedPrinters ) then
			return
		end

		local tPrinters = {}
		for k, v in ipairs( pPlayer.tOwnedPrinters ) do
			if not IsValid( v ) or ( v:GetClass() ~= "oneprint" ) then
				k = nil
			end

			tPrinters[ #tPrinters + 1 ] = v
		end

		local iOwnedPrinters = table.Count( tPrinters )

	    net.Start( "OnePrintNW" )
			net.WriteUInt( 0, 4 )
			net.WriteUInt( iOwnedPrinters, 8 )
			if ( iOwnedPrinters > 0 ) then
				for k, v in ipairs( tPrinters ) do
					net.WriteUInt( v:GetMoney(), 24 )
					net.WriteUInt( v:Health(), 16 )
					net.WriteUInt( v:GetTemperature(), 9 )
				end
			end
		net.Send( pPlayer )
	end
end

--[[

	OnePrintNW

]]--

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

local tPacket = {
	-- Set tab
	[ 0 ] = function( pPlayer )
		local iTab = net.ReadUInt( 3 )
		local ePrinter = net.ReadEntity()

		OnePrint:SetTab( pPlayer, ePrinter, iTab )
	end,
	-- Withdraw
	[ 1 ] = function( pPlayer )
		local ePrinter = net.ReadEntity()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

		OnePrint:Withdraw( pPlayer, ePrinter )
	end,
	-- Buy upgrade
	[ 2 ] = function( pPlayer )
		local iUpgrade = net.ReadUInt( 4 )
		local ePrinter = net.ReadEntity()

		OnePrint:BuyUpgrade( pPlayer, ePrinter, iUpgrade )
	end,
	-- Power
	[ 3 ] = function( pPlayer )
		local ePrinter = net.ReadEntity()

		if ePrinter and IsValid( ePrinter ) and ( ePrinter:GetClass() == "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
			if ePrinter:GetPowered() then
				ePrinter:Stop()
			else
				ePrinter:Start()
			end
		end
	end,
	-- Repair
	[ 4 ] = function( pPlayer )
		local ePrinter = net.ReadEntity()

		OnePrint:Repair( pPlayer, ePrinter )
	end,
	-- Freeze/Unfreeze
	[ 5 ] = function( pPlayer )
		local ePrinter = net.ReadEntity()

		if ePrinter and IsValid( ePrinter ) and ( ePrinter:GetClass() == "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
			if ePrinter:GetFrozen() then
				ePrinter:Unfreeze()
			else
				ePrinter:Freeze()
			end
		end
	end,
	-- Add user
	[ 6 ] = function( pPlayer )
		if ( OnePrint.Cfg.MaxUsers <= 0 ) then
			return
		end

		local ePrinter = net.ReadEntity()
		local pTarget = net.ReadEntity()

		if ePrinter and IsValid( ePrinter ) and ( ePrinter:GetClass() == "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
			ePrinter:AddUser( pPlayer, pTarget )
		end
	end,
	-- Remove user
	[ 7 ] = function( pPlayer )
		if ( OnePrint.Cfg.MaxUsers <= 0 ) then
			return
		end

		local ePrinter = net.ReadEntity()
		local pTarget = net.ReadEntity()

		if ePrinter and IsValid( ePrinter ) and ( ePrinter:GetClass() == "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
			ePrinter:RemoveUser( pPlayer, pTarget )
		end
	end,
	-- Hack
	[ 8 ] = function( pPlayer )
		if not pPlayer:OP_IsHaxor() then
			return
		end

		local ePrinter = net.ReadEntity()
		if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) then
			return
		end

		if ( ePrinter:GetPos():DistToSqr( pPlayer:GetPos() ) > 10000 ) then
			return
		end

		OnePrint:SetTab( pPlayer, ePrinter, 1, true )

		if ePrinter:GetHackNotif() then
			if ePrinter:GetOwnerObject() and IsValid( ePrinter:GetOwnerObject() ) then
				OnePrint:Notify( ePrinter:GetOwnerObject(), OnePrint:L( "Your printer got hacked" ), 1, 8 )

				if OnePrint.Cfg.NotifyAllUsers then
					local tUsers = ePrinter:GetUsers()
					if tUsers and not table.IsEmpty( tUsers ) then
						OnePrint:Notify( tUsers, OnePrint:L( "Your printer got hacked" ), 1, 8 )
					end
				end
			end
		end

		hook.Run( "OnePrint_OnPrinterHacked", ePrinter, pPlayer )
	end,
	-- Change printer light
	[ 9 ] = function( pPlayer )
		local iLight = net.ReadUInt( 2 )
		local ePrinter = net.ReadEntity()

		if ePrinter and IsValid( ePrinter ) and ( ePrinter:GetClass() == "oneprint" ) or not ePrinter:CanPlayerUse( pPlayer ) then
			ePrinter:SetLight( iLight )
		end
	end,
	-- GSmartWatch : Data update
	[ 10 ] = function( pPlayer )
		if not GSmartWatch then
			return
		end

		OnePrint:UpdateGSmartWatch( pPlayer )
	end,
	-- Buy all upgrade
	[ 11 ] = function( pPlayer )
		if not OnePrint.Cfg.CanUpgradeAll then return end

		local iUpgrade = net.ReadUInt( 4 )
		local ePrinter = net.ReadEntity()
		local upgradeNeeded = net.ReadUInt( 12 )

		OnePrint:BuyUpgrade( pPlayer, ePrinter, iUpgrade, upgradeNeeded )
	end,
}

net.Receive( "OnePrintNW", function( iLen, pPlayer )
    pPlayer.GSW_LastPacketSent = ( pPlayer.GSW_LastPacketSent or 0 )
    if ( CurTime() < ( pPlayer.GSW_LastPacketSent + .2 ) ) then
        return
    end

    pPlayer.GSW_LastPacketSent = CurTime()

	if not OnePrint.Cfg.CanUsePrinter["*"] then
		if not OnePrint.Cfg.CanUsePrinter[team.GetName(pPlayer:Team())] then return end
	end

    local iMsg = net.ReadUInt( 4 )
    if not iMsg or not tPacket[ iMsg ] then
        return
    end

    tPacket[ iMsg ]( pPlayer )    
end )
