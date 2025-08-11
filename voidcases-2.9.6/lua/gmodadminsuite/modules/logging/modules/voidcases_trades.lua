local MODULE = GAS.Logging:MODULE()

MODULE.Category = "VoidCases" -- The name of the category we want this module to be a part of
MODULE.Name = "Trades" -- The name of the module itself
MODULE.Colour = Color(52, 152, 219) -- The colour of the module which is seen in the menu, typically this is identical to every module that is in the same category

MODULE:Setup(function()

	MODULE:Hook("VoidCases.TradeCompleted", "VoidCases.GAS.Trade", function(plyReq, plyRec, tradeObj)
        local formattedReqItems = ""
        for k, v in pairs(tradeObj.requesterItems) do
            local item = VoidCases.Config.Items[tonumber(k)]
            if (!item) then continue end
            formattedReqItems = formattedReqItems .. item.name .. " (" .. v .. "x)\n"
        end

        local formattedRecItems = ""
        for k, v in pairs(tradeObj.receiverItems) do
            local item = VoidCases.Config.Items[tonumber(k)]
            if (!item) then continue end
            formattedRecItems = formattedRecItems .. item.name .. " (" .. v .. "x)\n"
        end

		MODULE:Log("{1} finished a trade with {2}\n {1}'s items: \n{3} \n {2}'s items: \n{4}", GAS.Logging:FormatPlayer(plyReq), GAS.Logging:FormatPlayer(plyRec), formattedReqItems, formattedRecItems)
	end)

    
end)


GAS.Logging:AddModule(MODULE)
