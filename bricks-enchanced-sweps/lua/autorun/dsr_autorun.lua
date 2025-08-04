if( SERVER ) then
	resource.AddWorkshop( 1910270104 )
	resource.AddFile( "resource/fonts/bricksenchancedsweps/whitney-medium.ttf")
	resource.AddFile( "resource/fonts/bricksenchancedsweps/uni-sans.heavy-caps.otf")
end

BES = {}
BES.CONFIG = {}

AddCSLuaFile( "bes_config.lua" )
include( "bes_config.lua" )

--[[ LOADS FILES ]]--
for k, v in pairs( file.Find( "bricksenchancedsweps/languages/*", "LUA" ) ) do
	if( string.Replace( v, ".lua" ) == (BES.CONFIG.Language or "") ) then
		AddCSLuaFile( "bricksenchancedsweps/languages/" .. v )
		include( "bricksenchancedsweps/languages/" .. v )
		
		print( "[BES] " .. (BES.CONFIG.Language or "") .. " language loaded" )
	end
end

function BES.L( languageString )
	if( BES.Language and BES.Language[languageString] ) then
		return BES.Language[languageString]
	else
		return "MISSING LANGUAGE"
	end
end

local files, directories = file.Find( "bricksenchancedsweps/*", "LUA" )
for k, v in pairs( files ) do
	AddCSLuaFile( "bricksenchancedsweps/" .. v )
	include( "bricksenchancedsweps/" .. v )
	
	print( "[BRICKSWABESNTEDSYS] SHARED " .. v .. " loaded" )
end

for k, v in pairs( directories ) do
	if( v == "server" ) then
		for key2, val2 in pairs( file.Find( "bricksenchancedsweps/" .. v .. "/*.lua", "LUA" ) ) do
			if( SERVER ) then
				include( "bricksenchancedsweps/" .. v .. "/" .. val2 )
			end
			
			print( "[BES] SERVER " .. val2 .. " loaded" )
		end
	elseif( v == "client" ) then
		for key2, val2 in pairs( file.Find( "bricksenchancedsweps/" .. v .. "/*.lua", "LUA" ) ) do
			if( CLIENT ) then
				include( "bricksenchancedsweps/" .. v .. "/" .. val2 )
			elseif( SERVER ) then
				AddCSLuaFile( "bricksenchancedsweps/" .. v .. "/" .. val2 )
			end
			
			print( "[BES] CLIENT " .. val2 .. " loaded" )
		end
	end
end