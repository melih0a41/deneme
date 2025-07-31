function CH_ATM.DarkRPAdds()
	DarkRP.createEntity("Pos Makinesi", {
		ent = "ch_atm_card_scanner",
		model = "models/craphead_scripts/ch_atm/terminal.mdl",
		price = 250,
		max = 1,
		cmd = "buycreditcardterminal"
	})
end
hook.Add( "loadCustomDarkRPItems", "CH_ATM.DarkRPAdds", CH_ATM.DarkRPAdds )