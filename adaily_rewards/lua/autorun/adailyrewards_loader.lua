if SERVER then
	resource.AddWorkshop( "3361234443" ) -- a daily rewards content

	AddCSLuaFile( "adailyrewards/adailyrewards_config.lua" )
	include( "adailyrewards/adailyrewards_config.lua" )
	

	local folder = "base"
	local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
	for i, f in pairs( files ) do
		if string.StartWith( f, "sh_" ) then
			AddCSLuaFile( "adailyrewards/" .. folder .. "/" .. f )
			include( "adailyrewards/" .. folder .. "/" .. f )
		elseif string.StartWith( f, "sv_" ) then
			include( "adailyrewards/" .. folder .. "/" .. f )
		elseif string.StartWith( f, "cl_" ) then
			AddCSLuaFile( "adailyrewards/" .. folder .. "/" .. f )
		end
	end

	local folder = "themes"
	local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
	for i, f in pairs( files ) do
		AddCSLuaFile( "adailyrewards/" .. folder .. "/" .. f )
		include( "adailyrewards/" .. folder .. "/" .. f )
	end
end

if CLIENT then
	include( "adailyrewards/adailyrewards_config.lua" )

	local folder = "base"
	local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
	for i, f in pairs( files ) do
		if string.StartWith( f, "sh_" ) then
			include( "adailyrewards/" .. folder .. "/" .. f )
		elseif string.StartWith( f, "cl_" ) then
			include( "adailyrewards/" .. folder .. "/" .. f )
		end
	end

	local folder = "themes"
	local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
	for i, f in pairs( files ) do
		include( "adailyrewards/" .. folder .. "/" .. f )
	end
end

/*---------------------------------------------------------------------------
MODULES
---------------------------------------------------------------------------*/

local folder = "rewards"
local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
for i, f in pairs( files ) do
	if SERVER then AddCSLuaFile( "adailyrewards/" .. folder .. "/" .. f ) end
	include( "adailyrewards/" .. folder .. "/" .. f )
end

local folder = "tasks"
local files, directories = file.Find( "adailyrewards/" .. folder .. "/*", "LUA" )
for i, f in pairs( files ) do
	if SERVER then  AddCSLuaFile( "adailyrewards/" .. folder .. "/" .. f ) end
	include( "adailyrewards/" .. folder .. "/" .. f )
end

hook.Add( "InitPostEntity", "AdrModulesLoad", function()
	 -- some third-party addons may not load in time --
	 timer.Simple(1, function()
		if !ADRewards then return end
		for k, v in ipairs(ADRewards.RewardsQueue) do
			if v.CheckLoad and !v.CheckLoad() then continue end
			ADRewards.Rewards[v.Name] = v
		end

		for k, v in ipairs(ADRewards.TasksQueue) do
			if v.CheckLoad and !v.CheckLoad() then continue end
			if SERVER then if v.AddHook then v.AddHook() end end

			ADRewards.Tasks[v.Name] = v
		end

		ADRewards.RewardsQueue = {}
		ADRewards.TasksQueue = {}
		ADRewards.ModulesLoaded = true
	end )
end )