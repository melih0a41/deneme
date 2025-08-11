local MODULE = GAS.Logging:MODULE()

MODULE.Category = "VoidCases" -- The name of the category we want this module to be a part of
MODULE.Name = "Purchases" -- The name of the module itself
MODULE.Colour = Color(52, 152, 219) -- The colour of the module which is seen in the menu, typically this is identical to every module that is in the same category

MODULE:Setup(function()

	MODULE:Hook("VoidCases.ItemPurchased", "VoidCases.GAS.Purchase", function(ply, item, itemID, amount)
		MODULE:Log("{1} purchased {2}x {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(amount), GAS.Logging:Highlight(item.name))
	end)

end)

GAS.Logging:AddModule(MODULE)