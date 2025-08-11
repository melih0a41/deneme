perfectVault = {}
perfectVault.Config = {}
perfectVault.Config.Government = {}
perfectVault.Config.Criminals = {}
perfectVault.Translation = {}
perfectVault.Core = {}
perfectVault.Core.ConfigEntities = {}
perfectVault.Core.OpenedUI = {}
perfectVault.Core.StencilCache = {}
perfectVault.UI = {}
perfectVault.Database = {}
perfectVault.Cooldown = {}
perfectVault.Walls = {}

print("Loading perfectVault")

local path = "perfectvault/"
if SERVER then
	resource.AddWorkshop("1401020507")
	local files, folders = file.Find(path .. "*", "LUA")
	
	for _, folder in SortedPairs(folders, true) do
		print("Loading folder:", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	        include(path .. folder .. "/" .. File)
	    end
	
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), true) do
	        include(path .. folder .. "/" .. File)
	    end
	
	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	    end
	end
end

if CLIENT then
	local files, folders = file.Find(path .. "*", "LUA")
	
	for _, folder in SortedPairs(folders, true) do
		print("Loading folder:", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        include(path .. folder .. "/" .. File)
	    end

	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	print("	Loading file:", File)
	        include(path .. folder .. "/" .. File)
	    end
	end

	-- Font was loading funny and this seems to fix it
	hook.Add("PostDrawHUD", "_pvault_fixfonts", function()
		include(path.."derma/cl_fonts.lua") 
		hook.Remove("PostDrawHUD", "_pvault_fixfonts")
	end)
end
print("Loaded perfectVault")