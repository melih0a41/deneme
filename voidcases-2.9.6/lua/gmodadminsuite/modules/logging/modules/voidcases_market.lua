local MODULE = GAS.Logging:MODULE()

MODULE.Category = "VoidCases" -- The name of the category we want this module to be a part of
MODULE.Name = "Marketplace" -- The name of the module itself
MODULE.Colour = Color(52, 152, 219) -- The colour of the module which is seen in the menu, typically this is identical to every module that is in the same category

MODULE:Setup(function()

	MODULE:Hook("VoidCases.MarketplaceListingCreated", "VoidCases.GAS.Marketplace", function(ply, item, itemID, amount, price)
		MODULE:Log("{1} listed {2}x {3} for {4}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(amount), GAS.Logging:Highlight(item.name), GAS.Logging:FormatMoney(price))
	end)

    MODULE:Hook("VoidCases.MarketplaceListingPurchase", "VoidCases.GAS.MarketplacePurchase", function(ply, sellerSID, item, itemID, amount, price)
		MODULE:Log("{1} purchased {2}x {3} from {4} for {5}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(amount), GAS.Logging:Highlight(item.name), GAS.Logging:FormatPlayer(sellerSID), GAS.Logging:FormatMoney(price))
	end)

	MODULE:Hook("VoidCases.MarketplaceListingRemoved", "VoidCases.GAS.MarketplaceRemove", function (ply, item, itemID, amount)
		MODULE:Log("{1} unlisted {2}x {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(amount), GAS.Logging:Highlight(item.name))
	end)


end)

GAS.Logging:AddModule(MODULE)