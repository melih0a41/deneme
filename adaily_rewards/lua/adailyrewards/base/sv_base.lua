util.AddNetworkString("adrewards_OpenMenu")
util.AddNetworkString("adrewards_ActionMenu")
util.AddNetworkString("adrewards_SeasonSync")
util.AddNetworkString("adrewards_TasksSync")
util.AddNetworkString("adrewards_RewardsSync")
util.AddNetworkString("adrewards_RewardRequest")
util.AddNetworkString("adrewards_RewardsRequest")
util.AddNetworkString("adrewards_RewardClaim")

file.CreateDir("adailyrewards")

ADRewards.PlayersTasks = ADRewards.PlayersTasks or {}

local function InitSeson()
	ADRewards.ContinueSeason()
end
hook.Add( "InitPostEntity", "InitAdrSeason", InitSeson )

local function SavePlysTasks()
	ADRewards.SavePlayersTasks()
end
hook.Add( "PlayerDisconnected", "SaveTaskDisconnect", SavePlysTasks )
hook.Add( "ShutDown", "SaveTaskShutDown", SavePlysTasks )

/*---------------------------------------------------------------------------
Init spawn hack
---------------------------------------------------------------------------*/
local load_queue = {}

hook.Add( "PlayerInitialSpawn", "AdrInitialSpawn", function( ply )
	load_queue[ ply ] = true
end )

hook.Add( "StartCommand", "AdrInitialSpawnFix", function( ply, cmd )
	if load_queue[ ply ] and not cmd:IsForced() then
		load_queue[ ply ] = nil

		ADRewards.PlayerInitial(ply)
	end
end )
/*-------------------------------------------------------------------------*/

net.Receive("adrewards_ActionMenu", function(len, ply)
	if !ADRewards.Config.Admins[ply:GetUserGroup()] then return end
	//----------------------------//
	//-----Admin spam warrning----//
	//----------------------------//
	local timenow = CurTime()
	if ply.ActionSpamADR then
		if ply.ActionSpamADR.NextUse > timenow then
			ply.ActionSpamADR.NextUse = timenow+5
			ply.ActionSpamADR.NumberTries = ply.ActionSpamADR.NumberTries + 1
			if ply.ActionSpamADR.NumberTries > 6 then
				ServerLog( "[ADR] "..tostring( ply ).." tried to spams high-cost net!\n" )
			end
		else
			ply.ActionSpamADR.NextUse = timenow+5
			ply.ActionSpamADR.NumberTries = 1
		end
	else
		ply.ActionSpamADR = {
			["NextUse"] = timenow+5,
			["NumberTries"] = 1,
		}
	end
	/*---------------------------------------------------------------------------
	1 — load list
	2 — load season
	3 — save
	4 — remove
	5 — start season
	---------------------------------------------------------------------------*/
	local actionType = net.ReadUInt(3)
	if actionType == 1 then
		//------------------//
		//-----load list----//
		//------------------//
		net.Start("adrewards_ActionMenu")
			net.WriteBool(true) -- isList
			local files, directories = file.Find( "adailyrewards/*.txt", "DATA" )
			local tojson = util.TableToJSON(files)
			local compressedJSON = util.Compress( tojson )
			local len = #compressedJSON
			net.WriteData( compressedJSON, len )
		net.Send(ply)
	elseif actionType == 2 then
		//------------------//
		//----load season---//
		//------------------//
		local fname = net.ReadString() -- file name
		local path = "adailyrewards/"..fname..".txt"
		local fileR = file.Read( path, "DATA" )
		if !fileR then return end
		local compressedJSON = util.Compress( fileR )
		net.Start("adrewards_ActionMenu")
			net.WriteBool(false) -- isList
			local len = #compressedJSON
			net.WriteData( compressedJSON, len )
		net.Send(ply)
	elseif actionType == 3 then
		//------------------//
		//-------save-------//
		//------------------//
		local fname = net.ReadString() -- file name
		local sname = net.ReadString() -- season name
		local stheme = net.ReadString() -- theme name
		local days = net.ReadUInt(7) -- days


		local trwrd = net.ReadBool()
		if trwrd then
			local trmodule = net.ReadString()
			local tramount = net.ReadUInt(20)
			local trkey = net.ReadString()
			if trkey == "" then trkey = nil end
			trwrd = {
				Module = trmodule,
				Amount = tramount,
				Key = trkey
			}
		end

		local len = net.ReadUInt(10)
		local compressed = net.ReadData(len)
		local uncompressed = util.Decompress( compressed )
		local toTBL = util.JSONToTable(uncompressed)
		local treward = trwrd
		local rewards = toTBL
		ADRewards.CreateSeason(sname, fname, stheme, days, rewards, treward)
	elseif actionType == 4 then
		//------------------//
		//------remove------//
		//------------------//
		local sfile = net.ReadString()
		ADRewards.RemoveSeason(sfile)
	elseif actionType == 5 then
		//------------------//
		//---start season---//
		//------------------//
		local sfile = net.ReadString()
		ADRewards.StartSeason(sfile)
	elseif actionType == 6 then
		//-------------------//
		//----stop season----//
		//-------------------//
		ADRewards.StopSeason()
	end
end)

net.Receive("adrewards_RewardRequest", function(len, ply)
	local rewardModule = net.ReadString()
	local rewardVal = net.ReadString()
	local rewardTbl = ADRewards.Rewards[rewardModule]
	if !rewardTbl then return end
	if !rewardTbl.NetWrite then return end

	net.Start("adrewards_RewardRequest")
		net.WriteString(rewardModule)
		net.WriteString(rewardVal)
		rewardTbl.NetWrite(rewardVal)
	net.Send(ply)
end)

net.Receive("adrewards_RewardsRequest", function(len, ply)
	if !ADRewards.SeasonNow then return end
	local rID = net.ReadUInt(7)
	if ADRewards.SeasonNow.SRewards.Default[rID] == nil then return end

	net.Start("adrewards_RewardsRequest")
		net.WriteUInt(rID, 7)
		local idnow = rID
		local maxid = rID+6

		local snum = 1
		while ADRewards.SeasonNow.SRewards.Default[idnow] != nil and idnow <= maxid do
			net.WriteBool(true) -- can read
			//-----------//
			//--Default--//
			//-----------//
			local rewardInfo = ADRewards.SeasonNow.SRewards.Default[idnow]
			net.WriteBool(rewardInfo) -- is full slot
			if rewardInfo then
				net.WriteUInt(rewardInfo.Amount, 30)
				net.WriteString(rewardInfo.Module)
				local strKey = rewardInfo.Key
				net.WriteBool(strKey)
				if strKey then
					net.WriteString(strKey)
				end
			end
			//-----------//
			//--Premium--//
			//-----------//
			local rewardInfo = ADRewards.SeasonNow.SRewards.Premium[idnow]
			net.WriteBool(rewardInfo) -- is full slot
			if rewardInfo then
				net.WriteUInt(rewardInfo.Amount, 30)
				net.WriteString(rewardInfo.Module)
				local strKey = rewardInfo.Key
				net.WriteBool(strKey)
				if strKey then
					net.WriteString(strKey)
				end
			end
			//-----------//
			idnow = idnow + 1
		end
	net.Send(ply)
end)

net.Receive("adrewards_RewardClaim", function(len, ply)
	local rewardID = net.ReadUInt(7)
	local isDefault = net.ReadBool()
	
	ADRewards.ClaimDayReward(ply, rewardID, isDefault)
end)


/*-------------------------------------------------------------------------------------------------------
Create Tables
-------------------------------------------------------------------------------------------------------*/
function ADRewards.CreateReward(tbl)
	if !ADRewards.ModulesLoaded then table.insert(ADRewards.RewardsQueue, tbl) return end
	if tbl.CheckLoad and !tbl.CheckLoad() then return end
	
	ADRewards.Rewards[tbl.Name] = tbl
end

function ADRewards.CreateTask(tbl)
	if ADRewards.Config.DisabledTasks[tbl.Name] then return end
	if !ADRewards.ModulesLoaded then table.insert(ADRewards.TasksQueue, tbl) return end
	if tbl.CheckLoad and !tbl.CheckLoad() then return end
	if tbl.AddHook then tbl.AddHook() end
	
	ADRewards.Tasks[tbl.Name] = tbl
end

function ADRewards.CreateTheme(tbl)
	ADRewards.Themes[tbl.Name] = true
end

/*-------------------------------------------------------------------------------------------------------
Season Actions
-------------------------------------------------------------------------------------------------------*/

function ADRewards.CreateSeason(sname, sfile, stheme, stime, srewards, strewards)
	sfile = string.lower( sfile )
	/*----------------*/
	local seasontbl = {
		SName = sname,
		SFile = sfile,
		STheme = stheme,
		STime = stime,
		SRewards = srewards,
		STRewards = strewards
	}

	local path = "adailyrewards/"..sfile..".txt"
	local tofile = util.TableToJSON(seasontbl)

	file.Write( path, tofile )
	file.CreateDir("adailyrewards/"..sfile)


	return sfile
end

function ADRewards.RemoveSeason(sfile)
	local path = "adailyrewards/"..sfile..".txt"
	local path2 = "adailyrewards/"..sfile

	file.Delete( path )
	local files, directories = file.Find(path2.."/*", "DATA" )
	for i, f in pairs( files ) do
		file.Delete( path2.."/"..f )
	end
	file.Delete( path2 )

	if ADRewards.SeasonNow and ADRewards.SeasonNow.SFile == sfile then
		ADRewards.StopSeason()
	end
end

function ADRewards.StartSeason(sfile)
	local path = "adailyrewards/"..sfile..".txt"
	local fileR = file.Read( path, "DATA" )
	if !fileR then return end
	local totable = util.JSONToTable(fileR)

	local timenow = os.time()
	local seasonEnd = timenow+((totable.STime-1)*86400)
	local ddata = os.date( "*t" , seasonEnd )
	local allsecs = (ddata.hour*3600)+(ddata.min*60)+ddata.sec
	seasonEnd = seasonEnd + (86400 - allsecs)

	local wtofile = sfile..","..seasonEnd
	file.Write( "adailyrewards/season.dat", wtofile )

	ADRewards.SeasonNow = totable
	ADRewards.SeasonNow.SEnd = seasonEnd

	ADRewards.CreateFileTasks()


	for k, v in ipairs(player.GetAll()) do
		if !v.UpdateADR then continue end
		ADRewards.LoadPlayerSeasonInfo(v)
		ADRewards.LoadPlayerTasks(v)
		v.UpdateADR.Season = true
	end

	ADRewards.SavePlayersTasks()
end

function ADRewards.ContinueSeason()
	local seasonInfo = file.Read( "adailyrewards/season.dat", "DATA" )
	if !seasonInfo then return end
	seasonInfo = string.Split( seasonInfo, "," )

	local timenow = os.time()
	local timeend = tonumber(seasonInfo[2])
	if timeend <= timenow then return end

	local path = "adailyrewards/"..seasonInfo[1]..".txt"
	local fileR = file.Read( path, "DATA" )
	if !fileR then return end
	local totable = util.JSONToTable(fileR)

	ADRewards.SeasonNow = totable
	ADRewards.SeasonNow.SEnd = timeend

	ADRewards.LoadFileTasks()
end

function ADRewards.StopSeason()
	ADRewards.SeasonNow = nil
	file.Delete( "adailyrewards/season.dat" )
	file.Delete( "adailyrewards/tasks.dat" )
end

/*-------------------------------------------------------------------------------------------------------
Player Info
-------------------------------------------------------------------------------------------------------*/

function ADRewards.PlayerInitial(ply)
	ply.UpdateADR = {
		["Season"] = true,
		["Tasks"] = true,
		["Rewards"] = true,
	}
	if ADRewards.SeasonNow then
		ADRewards.LoadPlayerTasks(ply, true)
		ADRewards.LoadPlayerSeasonInfo(ply)
		if ADRewards.Config.OpenJoin then
			ply:ConCommand( "dailyrewards" )
		end
	end
end

function ADRewards.LoadPlayerSeasonInfo(ply)
	if !ADRewards.SeasonNow then return end
	local seasonInfo = ADRewards.SeasonNow
	local sid64 = ply:SteamID64()
	local path = "adailyrewards/"..seasonInfo.SFile.."/"..sid64..".txt"
	local plyFile = file.Read( path, "DATA" )

	if plyFile then
		local toTable = util.JSONToTable(plyFile)
		ply.SeasonADR = {
			["SFile"] = seasonInfo.SFile,
			["Premium"] = toTable.Premium,
			["Rewards"] = toTable.Rewards,
		}
	else
		local json = '{"Premium":false,"Rewards":[]}'
		ply.SeasonADR = {
			["SFile"] = seasonInfo.SFile,
			["Premium"] = false,
			["Rewards"] = {}
		}
		file.Write( path, json )
	end

	ADRewards.CheckDayReward(ply)

	ply.UpdateADR.Rewards = true

	return ply.SeasonADR
end

---------------------------------------------------------------------------------------------------------

function ADRewards.CheckDayReward(ply)
	if !ADRewards.SeasonNow then return end
	local needGive = false
	local numrewards = #ply.SeasonADR.Rewards
	local nextreward = numrewards+1
	if ADRewards.SeasonNow.SRewards.Default[nextreward] == nil then return false end
	local plyRewards = ply.SeasonADR.Rewards

	if numrewards == 0 then
		needGive = true
	else
		local timeNow = os.time()
		local rewardTime = plyRewards[numrewards].Time

		local yearNow = tonumber( os.date( "%Y" , timeNow ) )
		local yearReward = tonumber( os.date( "%Y" , rewardTime ) )

		local dayNow = tonumber( os.date( "%j" , timeNow ) )
		local dayReward = tonumber( os.date( "%j" , rewardTime ) )

		if yearNow > yearReward then
			needGive = true
		else
			if dayNow > dayReward then
				needGive = true
			end
		end
	end

	if !needGive then return false end

	ADRewards.GiveDayReward(ply)
end

function ADRewards.GiveDayReward(ply)
	if !ADRewards.SeasonNow then return end
	local numrewards = #ply.SeasonADR.Rewards
	local nextreward = numrewards+1
	if ADRewards.SeasonNow.SRewards.Default[nextreward] == nil then return end
	if ADRewards.Config.TasksForClaim then
		local count = 0
		local tasks = ply.TasksADR or {}
		for k, v in pairs(tasks) do
			if v.ValNow < v.ValNeed then continue end
			count = count + 1
		end
		if count != 3 then return end
	end

	local timeNow = os.time()
	local defReward = ADRewards.SeasonNow.SRewards.Default[nextreward] == false and true or false
	local premReward = ADRewards.SeasonNow.SRewards.Premium[nextreward] == false and true or false

	local drTbl = {
		["Time"] = timeNow,
		["Default"] = defReward,
		["Premium"] = premReward,
	}

	local index = table.insert( ply.SeasonADR.Rewards, drTbl )

	if ADRewards.Config.AutoRewardClaim then
		ADRewards.ClaimDayReward(ply, index)
	else
		local sid64 = ply:SteamID64()
		local path = "adailyrewards/"..ADRewards.SeasonNow.SFile.."/"..sid64..".txt"
		local newTable = {
			["Premium"] = ply.SeasonADR.Premium,
			["Rewards"] = ply.SeasonADR.Rewards,
		}
		local json = util.TableToJSON(newTable)
		file.Write( path, json )

		ply.UpdateADR.Rewards = true
	end
end

function ADRewards.ClaimDayReward(ply, num, rtype) -- rtype: true - Default; false - Premium; nil - All;
	if !ADRewards.SeasonNow then return end
	local seasonRewards = ADRewards.SeasonNow.SRewards
	if seasonRewards.Default[num] == nil then return end
	if !ply.SeasonADR.Rewards[num] then return end

	if rtype then
		//-----------//
		//--Default--//
		//-----------//
		if ply.SeasonADR.Rewards[num].Default then return end -- you've already gotten that reward
		local rModule = seasonRewards.Default[num].Module
		local rAmount = seasonRewards.Default[num].Amount
		local rKey = seasonRewards.Default[num].Key
		if !ADRewards.Rewards[rModule] then return end

		ply.SeasonADR.Rewards[num].Default = true
		ADRewards.Rewards[rModule].GiveReward(ply, rAmount, rKey, false)
	else
		local havePrem = ADRewards.HavePremium(ply)
		if rtype == false then
			if !havePrem then return end
			if ply.SeasonADR.Rewards[num].Premium then return end -- you've already gotten that reward
			//-----------//
			//--Premium--//
			//-----------//
			local rModule = seasonRewards.Premium[num].Module
			local rAmount = seasonRewards.Premium[num].Amount
			local rKey = seasonRewards.Premium[num].Key
			if !ADRewards.Rewards[rModule] then return end

			ply.SeasonADR.Rewards[num].Premium = true
			ADRewards.Rewards[rModule].GiveReward(ply, rAmount, rKey, true)
		else
			local rReturn = 0
			//-----------//
			//--Default--//
			//-----------//
			if ply.SeasonADR.Rewards[num].Default then
				rReturn = rReturn + 1 -- you've already gotten that reward
			else
				local rModule = seasonRewards.Default[num].Module
				local rAmount = seasonRewards.Default[num].Amount
				local rKey = seasonRewards.Default[num].Key
				if ADRewards.Rewards[rModule] then
					ply.SeasonADR.Rewards[num].Default = true
					ADRewards.Rewards[rModule].GiveReward(ply, rAmount, rKey, false)
				end
			end
			//-----------//
			//--Premium--//
			//-----------//
			if havePrem then
				if ply.SeasonADR.Rewards[num].Premium then
					rReturn = rReturn + 1 -- you've already gotten that reward
				else
					local rModule = seasonRewards.Premium[num].Module
					local rAmount = seasonRewards.Premium[num].Amount
					local rKey = seasonRewards.Premium[num].Key
					if ADRewards.Rewards[rModule] then
						ply.SeasonADR.Rewards[num].Premium = true
						ADRewards.Rewards[rModule].GiveReward(ply, rAmount, rKey, true)
					end
				end
			end
			if rReturn == 2 then return end -- block file write if all false
		end
	end


	local sid64 = ply:SteamID64()
	local path = "adailyrewards/"..ADRewards.SeasonNow.SFile.."/"..sid64..".txt"
	local newTable = {
		["Premium"] = ply.SeasonADR.Premium,
		["Rewards"] = ply.SeasonADR.Rewards,
	}
	local json = util.TableToJSON(newTable)
	file.Write( path, json )

	ply.UpdateADR.Rewards = true
end

---------------------------------------------------------------------------------------------------------

function ADRewards.CreateFileTasks()
	if !ADRewards.SeasonNow then return end
	local path = "adailyrewards/tasks.dat"
	local timenow = os.time()
	local timeend = timenow
	local ddata = os.date( "*t" , timenow )
	local allsecs = (ddata.hour*3600)+(ddata.min*60)+ddata.sec
	timeend = timeend + (86400 - allsecs)

	local taskTbl = {
		["TimeEnd"] = timeend,
		["SName"] = ADRewards.SeasonNow.SName,
		["Players"] = {}
	}
	local json = util.TableToJSON(taskTbl)

	file.Write( path, json )

	ADRewards.PlayersTasks = taskTbl
end


function ADRewards.LoadFileTasks()
	if !ADRewards.SeasonNow then return end
	local path = "adailyrewards/tasks.dat"
	local timenow = os.time()
	local tasksfile = file.Read( path, "DATA" )
	if tasksfile then
		local playersTasks = util.JSONToTable(tasksfile)
		local timeend = playersTasks.TimeEnd
		if (timenow > timeend) or (playersTasks.SName != ADRewards.SeasonNow.SName) then
			ADRewards.CreateFileTasks()
			return
		end
		ADRewards.PlayersTasks = playersTasks
	else
		ADRewards.CreateFileTasks()
	end
end

function ADRewards.SavePlayersTasks()
	if !ADRewards.SeasonNow then return end
	local path = "adailyrewards/tasks.dat"
	local json = util.TableToJSON(ADRewards.PlayersTasks)

	file.Write( path, json )
end

function ADRewards.LoadPlayerTasks(ply, save)
	if !ADRewards.SeasonNow then return end
	local plyTasks = ADRewards.PlayersTasks.Players
	local sid = ply:SteamID()
	if plyTasks[sid] then
		for k, v in pairs(plyTasks[sid]) do
			if ADRewards.Config.DisabledTasks[k] or !ADRewards.Tasks[k] then -- if a module has been added to disabled, and the player still has this module, overwrite it
				ADRewards.PlayersTasks.Players[sid] = nil
				ADRewards.LoadPlayerTasks(ply)
				break
			end
		end
		ply.TasksADR = plyTasks[sid]
	else
		local randomRewards = {}
		for k, v in pairs(ADRewards.Tasks) do
			if ADRewards.Config.DisabledTasks[k] then continue end
			table.insert(randomRewards, k)
		end
		if #randomRewards < 3 then
			ErrorNoHalt( "Not enough tasks to give them to the player!\n" )
			return
		end

		local tasksTbl = {}
		for i = 1, 3 do
			local randNum = math.random(1, #randomRewards)
			local moduleName = randomRewards[randNum]
			local taskInfo = ADRewards.Tasks[moduleName]
			local needVal = 1
			if istable(taskInfo.Values) then
				local randVal = math.random(1, #taskInfo.Values)
				needVal = taskInfo.Values[randVal]
			else
				needVal = taskInfo.Values
			end
			tasksTbl[moduleName] = {
				["ValNeed"] = needVal,
				["ValNow"] = 0,
			}
			table.remove( randomRewards, randNum )
		end

		ADRewards.PlayersTasks.Players[sid] = tasksTbl

		ply.TasksADR = tasksTbl
	end

	ply.UpdateADR.Tasks = true

	if save then
		ADRewards.SavePlayersTasks()
	end

	hook.Run( "ADR_TasksLoaded", ply )
end

function ADRewards.GiveTaskVal(ply, taskname, amount)
	if !ADRewards.SeasonNow then return end
	if !ply.TasksADR or !ply.TasksADR[taskname] then return end
	if !ADRewards.Config.TasksForClaim and !ADRewards.SeasonNow.STRewards then return end
	local plyTask = ply.TasksADR[taskname]
	if plyTask.ValNow >= plyTask.ValNeed then return end

	plyTask.ValNow = math.Clamp(plyTask.ValNow+amount, 0, plyTask.ValNeed)

	ply.UpdateADR.Tasks = true

	if plyTask.ValNow >= plyTask.ValNeed then
		if ADRewards.SeasonNow.STRewards then
			local streward = ADRewards.SeasonNow.STRewards
			local rModule = streward.Module
			local rAmount = streward.Amount
			local rKey = streward.Key
			if !ADRewards.Rewards[rModule] then return end

			ADRewards.Rewards[rModule].GiveReward(ply, rAmount, rKey)
		end

		if ADRewards.Config.TasksForClaim then
			ADRewards.GiveDayReward(ply)
		end

		hook.Run( "ADR_TaskComplete", ply, taskname )
	end
end

---------------------------------------------------------------------------------------------------------

function ADRewards.HavePremium(ply)
	if ADRewards.Config.PremiumGropus[ply:GetUserGroup()] then return true end
	if ADRewards.SeasonNow and ADRewards.SeasonNow.SFile == ply.SeasonADR.SFile then return ply.SeasonADR.Premium end
	return false
end

function ADRewards.GivePremium(sid64, sfile)
	if !file.Exists( "adailyrewards/"..sfile..".txt", "DATA" ) then return end
	local path = "adailyrewards/"..sfile.."/"..sid64..".txt"
	local ply = player.GetBySteamID64( sid64 )
	if ply and ADRewards.SeasonNow and ADRewards.SeasonNow.SFile == sfile then
		ply.SeasonADR.Premium = true

		local json = util.TableToJSON(ply.SeasonADR)
		file.Write( path, json )

		ply.UpdateADR.Rewards = true
	else
		local plyFile = file.Read( path, "DATA" )
		if plyFile then
			local json = string.gsub(plyFile, '{"Premium":false,"Rewards":', '{"Premium":true,"Rewards":', 1)
			--local tbl = util.JSONToTable(plyFile)
			--tbl.Premium = true
			--local json = util.TableToJSON(tbl)
			file.Write( path, json )
		else
			local json = '{"Premium":true,"Rewards":[]}'
			file.Write( path, json )
		end
	end
end

function ADRewards.TakePremium(sid64, sfile)
	if !file.Exists( "adailyrewards/"..sfile..".txt", "DATA" ) then return end
	local path = "adailyrewards/"..sfile.."/"..sid64..".txt"
	local ply = player.GetBySteamID64( sid64 )
	if ply and ADRewards.SeasonNow and ADRewards.SeasonNow.SFile == sfile then
		ply.SeasonADR.Premium = false

		local json = util.TableToJSON(ply.SeasonADR)
		file.Write( path, json )

		ply.UpdateADR.Rewards = true
	else
		local plyFile = file.Read( path, "DATA" )
		if !plyFile then return end
		local json = string.gsub(plyFile, '{"Premium":true,"Rewards":', '{"Premium":false,"Rewards":', 1)
		file.Write( path, json )
	end
end

---------------------------------------------------------------------------------------------------------

function ADRewards.OpenMenu(ply)
	local seasonStarted = ADRewards.SeasonNow and true or false
	if !seasonStarted and !ADRewards.Config.Admins[ply:GetUserGroup()] then return end
	if ply.UpdateADR.Season and seasonStarted then
		local seasontbl = ADRewards.SeasonNow
		net.Start("adrewards_SeasonSync")
			net.WriteString(seasontbl.SName) -- season name
			net.WriteString(seasontbl.SFile) -- season file
			net.WriteString(seasontbl.STheme) -- season theme
			net.WriteUInt(seasontbl.SEnd, 31) -- season end time
			local stRewards = seasontbl.STRewards
			net.WriteBool(stRewards)
			if stRewards then
				net.WriteUInt(seasontbl.STRewards.Amount, 30)
				net.WriteString(seasontbl.STRewards.Module)
				local strKey = seasontbl.STRewards.Key
				net.WriteBool(strKey)
				if strKey then
					net.WriteString(strKey)
				end
			end
			local maxReward = #seasontbl.SRewards.Default
			net.WriteUInt(maxReward, 7)
		net.Send(ply)

		ply.UpdateADR.Season = false
	end

	if ply.UpdateADR.Tasks and seasonStarted then
		net.Start("adrewards_TasksSync")
			for k, v in pairs(ply.TasksADR) do
				net.WriteString(k)
				net.WriteUInt(ply.TasksADR[k].ValNeed, ADRewards.Config.TaskBit)
				net.WriteUInt(ply.TasksADR[k].ValNow, ADRewards.Config.TaskBit)
			end
		net.Send(ply)

		ply.UpdateADR.Tasks = false
	end

	if ply.UpdateADR.Rewards and seasonStarted then
		net.Start("adrewards_RewardsSync")
			net.WriteBool(ply.SeasonADR.Premium)
			local numrewards = #ply.SeasonADR.Rewards
			net.WriteUInt(numrewards, 7)
			for i = 1, numrewards do
				net.WriteUInt(ply.SeasonADR.Rewards[i].Time, 31)
				net.WriteBool(ply.SeasonADR.Rewards[i].Default)
				net.WriteBool(ply.SeasonADR.Rewards[i].Premium)
			end
		net.Send(ply)

		ply.UpdateADR.Rewards = false
	end

	net.Start("adrewards_OpenMenu")
		net.WriteBool(seasonStarted)
	net.Send(ply)
end

/*-------------------------------------------------------------------------------------------------------
Command
-------------------------------------------------------------------------------------------------------*/

concommand.Add( "dailyrewards", function(ply)  
	ADRewards.OpenMenu(ply)
end)

concommand.Add( "dailyrewards_giveprem", function(ply, cmd, args) -- args: 1 - steamid64; 2 - season file
	if IsValid(ply) then
		if !ADRewards.Config.Admins[ply:GetUserGroup()] then return end
	end

	local sid64 = args[1]
	local sfile = args[2]
	if !sid64 or !sfile then return end

	ADRewards.GivePremium(sid64, sfile)
end)

concommand.Add( "dailyrewards_takeprem", function(ply, cmd, args) -- args: 1 - steamid64; 2 - season file
	if IsValid(ply) then
		if !ADRewards.Config.Admins[ply:GetUserGroup()] then return end
	end

	local sid64 = args[1]
	local sfile = args[2]
	if !sid64 or !sfile then return end

	ADRewards.TakePremium(sid64, sfile)
end)

local chatcmd = {
	["!adr"] = true,
	["/adr"] = true,
	["!drewards"] = true,
	["/drewards"] = true,
	["!dailyrewards"] = true,
	["/dailyrewards"] = true,
}
hook.Add( "PlayerSay", "ChatMenuDailyRewards", function( ply, text )
	if chatcmd[text] then
		ply:ConCommand( "dailyrewards" )
		return ""
	end
end )