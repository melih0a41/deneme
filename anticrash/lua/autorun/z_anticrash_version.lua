-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/*
	This file is used to check if Anti-Crash is using the latest version
*/

local gmodstoreLink = "https://www.gmodstore.com/api/v3/products/%s/versions"
local apiKey = "bb7fc6fd-d28c-4bcb-b864-db6a409fa50f|l4OpPCggdfo0jd1xBBtEiLcl3SGoWLP4tNjXDwjZ"
local antiCrashID = "e751a065-bea3-4722-95b5-35fe2607415f"
local antiCrashVersion = "1.5.1"
local updateMsg = "[Anti-Crash] New version %s available! (curr: %s)"

local function VersionCheck()

	-- Retrieve versions from gmodstore
	http.Fetch( string.format(gmodstoreLink,antiCrashID),
		function( body, len, headers, code )
				
			local response = util.JSONToTable(body)

			-- Gmodstore api problem -> do nothing
			if response == nil then return end
			
			local data = response.data

			if data and istable(data) and #data > 0 then
			
				local latestVersion = data[1].name
				local latestVersionNum = tonumber(string.Replace( latestVersion, '.', '' ))
				local installedVersionNum = tonumber(string.Replace( antiCrashVersion, '.', '' ))
				
				if installedVersionNum < latestVersionNum then
					
					local updateMsg = string.format(updateMsg,latestVersion,antiCrashVersion)
					
					if SERVER then
						print(updateMsg)
					end
					
					SH_ANTICRASH.VARS.LATESTVERSION = false
					SH_ANTICRASH.VARS.LATESTVERSIONMSG = updateMsg
					
				end
				
			end

		end,
		function( error )
			-- Do nothing
		end,
		{
			["Authorization"] = "Bearer "..apiKey
		}
	)
	
end
timer.Simple(0, VersionCheck)