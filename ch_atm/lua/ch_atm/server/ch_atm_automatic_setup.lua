--[[
	Function to replace static props with interactive ATM entity
--]]
local atm_to_replace = {
	["rp_rockford_v2b"] = "models/props_unique/atm01.mdl",
	["rp_truenorth_v1a"] = "models/props_unique/atm01.mdl",
}

local function CH_ATM_ReplaceATMOnMap( ply )
	if not atm_to_replace[ game.GetMap() ] then
		return
	end
	
	MsgC( Color( 52, 152, 219 ), "ATM by Crap-Head | Replacing static ATMs with interactive ATMs is enabled. Scanning...\n" )

	-- Loop through ents
	for k, atm in ipairs( ents.GetAll() ) do
		-- Compare model from our list with the entity to see if it's an ATM
		if atm_to_replace[ game.GetMap() ] == atm:GetModel() then
			-- Entity matches criteria for map. REPLACING
			MsgC( Color( 52, 152, 219 ), "ATM by Crap-Head | ATM found. Replacing at ", color_white, tostring( atm:GetPos() ) .."\n" )
			
			-- Spawn interactive ATM
			local ATM = ents.Create( "ch_atm" )
			ATM:SetPos( atm:GetPos() )
			ATM:SetAngles( atm:GetAngles() )
			ATM:Spawn()
			ATM:Activate()
			
			ATM.CH_ATM_NoSave = true
	
			-- Delete static ATM
			atm:Remove()
		end
	end
end

--[[
	If enabled then run function to replace ATM props on map with ATM entity
--]]
local function CH_ATM_AutomaticSetup()
	if CH_ATM.Config.ReplaceATMPropsOnMap then
		CH_ATM_ReplaceATMOnMap()
	end
end
hook.Add( "InitPostEntity", "CH_ATM_AutomaticSetup", CH_ATM_AutomaticSetup )

--[[
	Dev function to get details of a target entity
--]]
local function CH_ATM_DEV_GetStaticATMDetails( ply )
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	
	print( ent )
	print( ent:GetClass() )
	print( ent:GetModel() )
	print( ent:GetPos() )
	print( ent:GetAngles() )
end
concommand.Add( "ch_atm_dev_get_atm_details", CH_ATM_DEV_GetStaticATMDetails )