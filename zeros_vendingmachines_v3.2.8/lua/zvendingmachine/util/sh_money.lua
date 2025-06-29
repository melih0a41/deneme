/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.Money = zvm.Money or {}

/*
    1 = Money
    2 = PS Points
    3 = PS2 Points
    4 = PS2 PremiumPoints
	5 = BitCoin (Zeros BotNet script requiered)
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

zvm.Money.Systems = {}

/*
	Normal money
*/
zvm.Money.Systems[ 1 ] = {}
zvm.Money.Systems[ 1 ].name = zvm.language.General["Money"]
zvm.Money.Systems[ 1 ].HasMoney = function(ply, money) return zclib.Money.Has(ply, money) end
zvm.Money.Systems[ 1 ].TakeMoney = function(ply, money)
	zclib.Money.Take(ply, money)
end

/*
	PS Points
*/
zvm.Money.Systems[ 2 ] = {}
zvm.Money.Systems[ 2 ].name = "PS Points (Requires Pointshop)"
zvm.Money.Systems[ 2 ].HasMoney = function(ply, money) return ply:PS_HasPoints(money) end
zvm.Money.Systems[ 2 ].TakeMoney = function(ply, money)
	ply:PS_TakePoints(money)
end

/*
	PS2 Points
*/
zvm.Money.Systems[ 3 ] = {}
zvm.Money.Systems[ 3 ].name = "PS2 Points (Requires Pointshop 2)"
zvm.Money.Systems[ 3 ].HasMoney = function(ply, money)
	local points = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

	if ply.PS2_Wallet then
		points = ply.PS2_Wallet.points
	end

	return points >= money
end
zvm.Money.Systems[ 3 ].TakeMoney = function(ply, money)
	ply:PS2_AddStandardPoints(-money, "", false)
end

/*
	PS2 PremiumPoints
*/
zvm.Money.Systems[ 4 ] = {}
zvm.Money.Systems[ 4 ].name = "PS2 PremiumPoints (Requires Pointshop 2)"
zvm.Money.Systems[ 4 ].HasMoney = function(ply, money)
	local premiumPoints = 0

	if ply.PS2_Wallet then
		premiumPoints = ply.PS2_Wallet.premiumPoints
	end

	return premiumPoints >= money
end
zvm.Money.Systems[ 4 ].TakeMoney = function(ply, money)
	ply:PS2_AddPremiumPoints(-money)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

/*
	BitCoin (Zeros BotNet script requiered)
*/
zvm.Money.Systems[ 5 ] = {}
zvm.Money.Systems[ 5 ].name = "Bitcoin (Requires Zeros BotNet)"
zvm.Money.Systems[ 5 ].HasMoney = function(ply, money) return zbf.Wallet.GetCurrency(ply, zbf.Currency.GetID("BTC")) >= money end
zvm.Money.Systems[ 5 ].TakeMoney = function(ply, money)
	local c_type = zbf.Currency.GetID("BTC")
	zbf.Wallet.SetCurrency(ply, c_type, zbf.Wallet.GetCurrency(ply, c_type) - money)
end

function zvm.Money.GetSymbol(id)
	return zvm.config.Currency[id]
end

function zvm.Money.GetName(id)
	return zvm.Money.Systems[ id ].name
end

// Tells us if the player has enough from the moneytype
function zvm.Money.HasMoney(ply,moneytype,money)
	return zvm.Money.Systems[moneytype].HasMoney(ply,money)
end

// Takes the specified moneytype from the player
function zvm.Money.TakeMoney(ply,moneytype,money)
	return zvm.Money.Systems[moneytype].TakeMoney(ply,money)
end

function zvm.Money.Display(money, symbol)
	if zvm.config.CurrencyPosInvert then
		return symbol .. zvm.Money.Format(money)
	else
		return zvm.Money.Format(money) .. symbol
	end
end

function zvm.Money.Format(money)
	if not money then return "0" end
	money = math.Round(money,5)
	money = tostring(math.abs(money))
	local sep = ","
	local dp = string.find(money, "%.") or #money + 1

	for i = dp - 4, 1, -3 do
		money = money:sub(1, i) .. sep .. money:sub(i + 1)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	return money
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
