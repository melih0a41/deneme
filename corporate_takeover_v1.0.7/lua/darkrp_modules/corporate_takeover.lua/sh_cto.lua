hook.Add("loadCustomDarkRPItems", "cto_load_darkrp", function()
print("Corporate Takeover: Loading DarkRP items...")
	if(Corporate_Takeover.Config.LoadDarkRPItems) then
		DarkRP.createCategory({
			name = "Şirket Masası",
			categorises = "entities",
			startExpanded = true,
			color = Color(100,0,255),
            canSee = function(ply)
			return table.HasValue({TEAM_ISADAMI}, ply:Team()) end,
			sortOrder = 100,
		})

		DarkRP.createEntity(Corporate_Takeover:Lang("corporate_desk"), {
		    ent = "deskbuilder_corporate",
		    cmd = "buycorporatedesk",
		    model = "models/corporate_takeover/nostras/packet.mdl",
		    price = 5000,
		    max = 1,
		    category = "Şirket Masası",
			allowed = {TEAM_ISADAMI}, 
		})
	end
end)