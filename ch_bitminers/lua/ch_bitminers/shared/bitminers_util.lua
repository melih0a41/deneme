local PMETA = FindMetaTable( "Player" )

--[[
	Meta function to get max miners for a player
--]]
function PMETA:CH_BITMINERS_GetMaxMiners()
	return CH_Bitminers.Config.MaxBitminersInstalled[ self:GetUserGroup() ] or 16
end

--[[
	Language functions
--]]
local function CH_Bitminers_GetLang()
	local lang = CH_Bitminers.Config.Language or "en"

	return lang
end

function CH_Bitminers.LangString( text )
	local translation = text .." (Translation missing)"
	
	if CH_Bitminers.Config.Lang[ text ] then
		translation = CH_Bitminers.Config.Lang[ text ][ CH_Bitminers_GetLang() ]
	end
	
	return translation
end