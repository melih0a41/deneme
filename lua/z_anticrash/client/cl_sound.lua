-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local sounds = {
	["catPress"] = "z_anticrash/cat_press.mp3",
	["plyPress"] = "z_anticrash/cat_press.mp3",
	["runAntiLag"] = "buttons/button14.wav",
	["gmodPress"] = "buttons/button15.wav",
	["togglePress"] = "garrysmod/content_downloaded.wav"
}

-- precache
for _, path in pairs( sounds ) do
	sound.Play( path, Vector(), 20, 100, 0 )
end

function CL_ANTICRASH.PlaySound( id )
	surface.PlaySound( sounds[id] )
end