/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

-- Money withdraw
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "OnePrint"
MODULE.Name     = "Money withdraw"
MODULE.Colour   = Color(255,130,0)
MODULE:Setup(function()
	MODULE:Hook( "OnePrint_OnWithdraw", "OP_BlogsSupport",function( pPlayer, iMoney, ePrinter )
		MODULE:LogPhrase( "{1} withdrew " .. OnePrint:FormatMoney( iMoney ) .. " in {2}'s printer", GAS.Logging:FormatPlayer( pPlayer ), GAS.Logging:FormatPlayer( ePrinter:GetOwnerObject() ) )
	end )
end )
GAS.Logging:AddModule( MODULE )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

-- Hacked
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "OnePrint"
MODULE.Name     = "Hacked"
MODULE.Colour   = Color(255,130,0)
MODULE:Setup(function()
	MODULE:Hook( "OnePrint_OnPrinterHacked", "OP_BlogsSupport",function( ePrinter, pPlayer )
		MODULE:LogPhrase( "{1} hacked {2}'s printer", GAS.Logging:FormatPlayer( pPlayer ), GAS.Logging:FormatPlayer( ePrinter:GetOwnerObject() ) )
	end )
end )
GAS.Logging:AddModule( MODULE )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

-- Destroyed
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "OnePrint"
MODULE.Name     = "Destroyed"
MODULE.Colour   = Color(255,130,0)
MODULE:Setup(function()
	MODULE:Hook( "OnePrint_OnPlayerDestroyedPrinter", "OP_BlogsSupport",function( pPlayer, ePrinter )
		MODULE:LogPhrase( "{1} destroyed {2}'s printer", GAS.Logging:FormatPlayer( pPlayer ), GAS.Logging:FormatPlayer( ePrinter:GetOwnerObject() ) )
	end )
end )
GAS.Logging:AddModule( MODULE )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

-- Upgrades
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "OnePrint"
MODULE.Name     = "Upgrades"
MODULE.Colour   = Color(255,130,0)
MODULE:Setup(function()
	MODULE:Hook( "OnePrint_BuyUpgrade", "OP_BlogsSupport:Upgrade",function( pPlayer, tUpgrade, price )
		MODULE:LogPhrase( "{1} bought the upgrade {2} for {3}", GAS.Logging:FormatPlayer( pPlayer ), tUpgrade["name"], OnePrint:FormatMoney( price ))
	end )
end )
GAS.Logging:AddModule( MODULE )
