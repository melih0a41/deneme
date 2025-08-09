CH_ATM.Currencies[ "helix" ] = {
	Name = "Helix Money",
	
	AddMoney = function( ply, amount )
		ply:GetCharacter():GiveMoney( amount )
	end,
	
	TakeMoney = function( ply, amount )
		ply:GetCharacter():TakeMoney( amount )
	end,
	
	GetMoney = function( ply )
		return ply:GetCharacter():GetMoney()
	end,
	
	CanAfford = function( ply, amount )
		return ply:GetCharacter():HasMoney( amount )
	end,
	
	FormatMoney = function( amount )
		return ix.currency.Get( amount or 0 )
	end,
	
	CurrencyAbbreviation = function()
		return "USD"
	end,
}