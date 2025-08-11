local MODULE = GAS.Logging:MODULE()

MODULE.Category = "VoidCases" -- The name of the category we want this module to be a part of
MODULE.Name = "Unboxings" -- The name of the module itself
MODULE.Colour = Color(52, 152, 219) -- The colour of the module which is seen in the menu, typically this is identical to every module that is in the same category

MODULE:Setup(function()

	MODULE:Hook("VoidCases.CaseUnboxed", "VoidCases.GAS.Unbox", function(ply, item, itemID, case)
		--[[
			The following function adds a log to bLogs.

			The first argument is the text of the log, it is formatted in a way so that the arguments that follow it are
			injected into the log when it is being formatted. For example:

			{1} arrested {2}
			-> {1} will be replaced with the person who is arresting the criminal
			-> {2} will be replaced with the criminal

			The FormatPlayer function takes a player, SteamID, SteamID64 or AccountID as its argument and dynamically adds the
			player's information (name, team, HP, armor, etc.) to the log in the specified position.
		]]

		MODULE:Log("{1} unboxed {2} from {3}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(item.name), GAS.Logging:Escape(case.name))
	end)

end)

GAS.Logging:AddModule(MODULE)