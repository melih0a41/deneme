-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/* 
	Gmod and custom fonts are bugged for some OS users, incase the font isn't loaded we use our own fallback
*/

local customFont = file.Read( "resource/fonts/yugothil.ttf", "GAME" )
local isCustomFontLoaded = customFont ~= nil
local font = isCustomFontLoaded and "Yu Gothic Light" or "Roboto Th"

surface.CreateFont( "z_anticrash_menu_title", {
	font = "Roboto Cn",
	size = 28,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_graph_label", {
	font = "Roboto Cn",
	size = 20,
	weight = 1,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_graph_btn", {
	font = "Roboto Cn",
	size = 22,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_flag_count", {
	font = "Roboto Cn",
	size = 20,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_global_btn", {
	font = "Roboto Cn",
	size = 18,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_user_info_label", {
	font = "Roboto Cn",
	size = 16,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_user_info_button", {
	font = "Roboto Cn",
	size = 16,
	weight = 500,
	additive = true,
	antialias = true
} )

surface.CreateFont( "z_anticrash_user_info_search", {
	font = "Roboto Cn",
	size = 16,
	weight = 500,
	additive = true,
	antialias = true
} )