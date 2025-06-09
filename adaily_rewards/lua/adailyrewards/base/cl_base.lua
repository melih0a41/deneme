net.Receive("adrewards_OpenMenu", function(len)
	local seasonStarted = net.ReadBool()
	local ply = LocalPlayer()
	ply.LangADR = GetConVar("gmod_language"):GetString()
	if seasonStarted then
		ADRewards.OpenRewardsMenu()
	else
		ADRewards.OpenSettings(seasonStarted)
	end
end)

net.Receive("adrewards_SeasonSync", function(len)
	local sname = net.ReadString() -- season name
	local sfile = net.ReadString() -- season file
	local stheme = net.ReadString() -- season theme
	local send = net.ReadUInt(31) -- season end time

	local strTable = false
	local haveSTR = net.ReadBool()
	if haveSTR then -- task reward
		local strAmount = net.ReadUInt(30)
		local strModule = net.ReadString()
		local strKey = net.ReadBool()
		if strKey then
			strKey = net.ReadString()
			local tnmb = tonumber(strKey)
			if tnmb then strKey = tnmb end
		end
		strTable = {
			Amount = strAmount,
			Module = strModule,
			Key = strKey or nil,
		}
	end

	local maxReward = net.ReadUInt(7)

	ADRewards.SeasonNow = {
		SName = sname,
		SFile = sfile,
		STheme = stheme,
		SEnd = send,
		SRewards = {
			Default = {},
			Premium = {},
		},
		STRewards = strTable,
		MaxReward = maxReward,
		Pages = math.ceil(maxReward/7)
	}
end)

net.Receive("adrewards_TasksSync", function(len)
	local ply = LocalPlayer()
	local tasksTbl = {}
	for i = 1, 3 do
		local moduleName = net.ReadString()
		local valNeed = net.ReadUInt(ADRewards.Config.TaskBit)
		local valNow = net.ReadUInt(ADRewards.Config.TaskBit)
		tasksTbl[moduleName] = {
			["ValNeed"] = valNeed,
			["ValNow"] = valNow,
		}
	end

	ply.TasksADR = tasksTbl
end)

net.Receive("adrewards_RewardsSync", function(len)
	local ply = LocalPlayer()
	local premium = net.ReadBool()
	ply.SeasonADR = {
		Premium = premium,
		Rewards = {},
	}
	local numrewards = net.ReadUInt(7)
	for i = 1, numrewards do
		local time = net.ReadUInt(31)
		local defReward = net.ReadBool()
		local premReward = net.ReadBool()
		ply.SeasonADR.Rewards[i] = {
			Time = time,
			Default = defReward,
			Premium = premReward
		}
	end
end)

net.Receive("adrewards_RewardsRequest", function(nlen)
	local rID = net.ReadUInt(7)
	local idnow = rID
	while (net.ReadBool()) do
		//-----------//
		//--Default--//
		//-----------//
		local slotFull = net.ReadBool()
		if slotFull then
			local rAmount = net.ReadUInt(30)
			local rModule = net.ReadString()
			if rModule == "" then break end -- fix while bug
			local strKey = net.ReadBool()
			if strKey then
				strKey = net.ReadString()
				local tnmb = tonumber(strKey)
				if tnmb then strKey = tnmb end
			end
			ADRewards.SeasonNow.SRewards.Default[idnow] = {
				Amount = rAmount,
				Module = rModule,
				Key = strKey or nil,
			}
		else
			ADRewards.SeasonNow.SRewards.Default[idnow] = false
		end
		//-----------//
		//--Premium--//
		//-----------//
		local slotFull = net.ReadBool()
		if slotFull then
			local rAmount = net.ReadUInt(30)
			local rModule = net.ReadString()
			local strKey = net.ReadBool()
			if strKey then
				strKey = net.ReadString()
				local tnmb = tonumber(strKey)
				if tnmb then strKey = tnmb end
			end
			ADRewards.SeasonNow.SRewards.Premium[idnow] = {
				Amount = rAmount,
				Module = rModule,
				Key = strKey or nil,
			}
		else
			ADRewards.SeasonNow.SRewards.Premium[idnow] = false
		end
		//-----------//
		idnow = idnow + 1
	end
	if IsValid(ADRewards.RewardsMenu) then
		local page = math.ceil(rID/7)
		ADRewards.RewardsMenu.rewardsPanel.BuildList(page)
	end
end)

hook.Add( "PlayerButtonDown", "ShowADailyRewards", function( ply, button )
	if !ADRewards.Config.KEY then return end
	if !IsFirstTimePredicted() then return end
	if button != ADRewards.Config.KEY then return end

	RunConsoleCommand("dailyrewards")
end )

function ADRewards.CreateReward(tbl)
	if !ADRewards.ModulesLoaded then table.insert(ADRewards.RewardsQueue, tbl) return end
	if tbl.CheckLoad and !tbl.CheckLoad() then return end
	
	ADRewards.Rewards[tbl.Name] = tbl
end

function ADRewards.CreateTask(tbl)
	if ADRewards.Config.DisabledTasks[tbl.Name] then return end
	if !ADRewards.ModulesLoaded then table.insert(ADRewards.TasksQueue, tbl) return end
	if tbl.CheckLoad and !tbl.CheckLoad() then return end

	ADRewards.Tasks[tbl.Name] = tbl
end

function ADRewards.CreateTheme(tbl)
	ADRewards.Themes[tbl.Name] = tbl
end

function ADRewards.HavePremium(ply)
	if ADRewards.Config.PremiumGropus[ply:GetUserGroup()] then return true end
	if ply.SeasonADR then return ply.SeasonADR.Premium end -- If the data has not been updated, it will output the last value!
	return false
end