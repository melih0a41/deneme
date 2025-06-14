
local overlay = nil

function CL_ANTICRASH.OverlayIsOpen()
	return overlay ~= nil and overlay:IsVisible()
end

local function OpenOverlayByConCommand( ply, cmd, args )
	if !SH_ANTICRASH.HasAccess() then return end

	if overlay ~= nil then
	
		overlay:Remove()
		overlay = nil
		
	else
		overlay = vgui.Create( "p_anticrash_overlay" )
	end
end
concommand.Add( "anticrash_overlay_open", OpenOverlayByConCommand) 