-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/*
	Measures against net spamming
*/

if !SH_ANTICRASH.SETTINGS.EXPLOITS.NETRATELIMITER then return end

local enableNetLog = false
local netMsgNetCount = {}

timer.Create("z_anticrash_NetrateCleanTimer", 1, 0, function()
	table.Empty(netMsgNetCount)
end)

if CLIENT then

	local __oldStart = net.Start
	-- __oldStart = __oldStart or net.Start
	
	-- Client side netrate limiter	
	function net.Start(messageName, unreliable)
		
		if enableNetLog then
			print("Starting net msg: "..messageName)
		end
		
		netMsgNetCount[messageName] = (netMsgNetCount[messageName] or 0) + 1
		
		-- Discard message
		if netMsgNetCount[messageName] > 5 then return end
		
		__oldStart(messageName, unreliable)

	end

	/*
	timer.Create("Spammer",0.001,0,function()
		net.Start("SpamMe")
		net.SendToServer()
	end)
	*/

end

if SERVER then
	
	local function Incoming(len, client, nwName)
		
		if ( !nwName ) then return end
		
		local func = net.Receivers[ nwName:lower() ]
		if ( !func ) then return end

		--
		-- len includes the 16 bit int which told us the message name
		--
		len = len - 16
		
		func( len, client )

	end

	-- Sever side netrate limiter
	function net.Incoming( len, client )

		local nwName = util.NetworkIDToString(net.ReadHeader())

		if enableNetLog then
			print("net.Incoming",nwName, client, len)
		end
	
		netMsgNetCount[client] = netMsgNetCount[client] or {}
		netMsgNetCount[client][nwName] = (netMsgNetCount[client][nwName] or 0) + 1
		
		-- Discard message
		if netMsgNetCount[client][nwName] > 5 then return end
		
		Incoming(len, client, nwName)
		
	end
	
	/*
	util.AddNetworkString("SpamMe")
	local function SpamMe()
		print("Spammed!")
	end
	net.Receive("SpamMe", SpamMe)
	*/

end