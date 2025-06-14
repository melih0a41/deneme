-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local menu = nil
local lastOpened = 0

function CL_ANTICRASH.MenuIsOpen()
	return menu ~= nil and menu:IsVisible()
end

function CL_ANTICRASH.ToggleMenu(forceClose)

	if !SH_ANTICRASH.HasAccess() then return end
	
	if forceClose or CL_ANTICRASH.MenuIsOpen() then

		if menu ~= nil then
			
			for _, child in pairs(menu:GetChildren()) do
				child:Remove()
			end
		
			menu:Remove()
			
			menu = nil
			
		end
		
	else
	
		menu = vgui.Create( "p_anticrash_menu" )
		
		-- show one-time notification if new version is available
		if !SH_ANTICRASH.VARS.LATESTVERSION then
		
			SH_ANTICRASH.VARS.LATESTVERSION = true
			
			notification.AddLegacy( SH_ANTICRASH.VARS.LATESTVERSIONMSG, NOTIFY_GENERIC, 15 )
			
		end
		
	end

end

local function OpenMenuByConCommand( ply, cmd, args )
	CL_ANTICRASH.ToggleMenu()
end
concommand.Add( "anticrash_open", OpenMenuByConCommand)
