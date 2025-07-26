local MODULE = GAS.Logging:MODULE()

MODULE.Category = "DarkRP"
MODULE.Name = "Corporate Takeover"
MODULE.Colour = Corporate_Takeover.Config.Colors.Primary || Color(0,128,255)

MODULE:Setup(function()
	MODULE:Hook("cto_corp_created", "cto_corp_created_blogs", function(ply, CorpName)
		MODULE:Log("{1} created the Corp "..CorpName, GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_deleted", "cto_corp_deleted_blogs", function(ply, CorpName)
		MODULE:Log("{1} lost the Corp "..CorpName, GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_damaged", "cto_corp_damaged_blogs", function(attacker, ply, damage, class, CorpName)
		MODULE:Log("{1} dealt "..damage.." damage to "..class.." of "..CorpName.." by {2}", GAS.Logging:FormatPlayer(attacker), GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_damaged_nonCorp", "cto_corp_damaged_noCorp_blogs", function(attacker, ply, damage, class)
		MODULE:Log("{1} dealt "..damage.." damage to "..class.." of {2}", GAS.Logging:FormatPlayer(attacker), GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_destroyed", "cto_corp_destroyed_blogs", function(attacker, ply, entclass)
		MODULE:Log("{1} destroyed "..entclass.." of {2}", GAS.Logging:FormatPlayer(attacker), GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_withdrew", "cto_corp_withdrew_blogs", function(ply, money)
		MODULE:Log("{1} withdrew "..money, GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_deposited", "cto_corp_deposited_blogs", function(ply, money)
		MODULE:Log("{1} deposited "..money, GAS.Logging:FormatPlayer(ply))
	end)

	MODULE:Hook("cto_corp_bought", "cto_corp_deposited_blogs", function(ply, class)
		MODULE:Log("{1} bought "..class, GAS.Logging:FormatPlayer(ply))
	end)
end)

GAS.Logging:AddModule(MODULE)
