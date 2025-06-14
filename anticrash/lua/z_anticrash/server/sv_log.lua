-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local logPath = "z_anticrash/logs"

local function PostGamemodeLoaded()

	if !file.Exists(logPath, "DATA") then
		file.CreateDir(logPath)
	end

end
hook.Add("PostGamemodeLoaded", "z_anticrash_Log", PostGamemodeLoaded)

function SV_ANTICRASH.Log(msg)

	local logName = string.Replace(tostring(os.date("%d/%m/%y")),"/","-")
	local logLine = "["..tostring(os.date("%X")).."] "..msg.."\n"
	file.Append( logPath.."/"..logName..".txt", logLine )
	
end