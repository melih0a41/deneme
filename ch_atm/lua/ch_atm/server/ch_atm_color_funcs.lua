--[[
	Set color on the ATM according to actions
--]]
function CH_ATM.ChangeATMColor( atm, color, time )
	if not IsValid( atm ) then
		return
	end
	
	atm:SetColor( color )
	
	if time > 0 then
		timer.Simple( time, function()
			atm:SetColor( CH_ATM.Config.ActiveColor )
		end )
	end
end

net.Receive( "CH_ATM_Net_ChangeATMColor", function( len, ply )
	local atm = net.ReadEntity()
	local color = net.ReadColor()
	local time = net.ReadUInt( 10 )
	
	if IsValid( atm ) and atm:GetClass() != "ch_atm" then
		return
	end

	if ply:GetPos():DistToSqr( atm:GetPos() ) > 10000 then
		return
	end

	CH_ATM.ChangeATMColor( atm, color, time )
end )

--[[
	Set color on the ATM according to actions
--]]
function CH_ATM.ToggleRGBLights( atm )
	if not IsValid( atm ) then
		return
	end

	if atm.RGBLightsEnabled then
		atm:SetBodygroup( 1, 0 )
		
		atm:SetSkin( 0 )
		atm.RGBLightsEnabled = false
	else
		atm:SetColor( CH_ATM.Config.ActiveColor )
		
		atm:SetBodygroup( 1, 1 )
		
		atm:SetSkin( 1 )
		atm.RGBLightsEnabled = true
	end
end

net.Receive( "CH_ATM_RGBLights", function( len, ply )
	local atm = net.ReadEntity()
	
	if IsValid( atm ) and atm:GetClass() != "ch_atm" then
		return
	end

	if ply:GetPos():DistToSqr( atm:GetPos() ) > 10000 then
		return
	end

	CH_ATM.ToggleRGBLights( atm )
end )