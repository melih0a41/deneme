include( "shared.lua" )

function ENT:Initialize()
end

local icon_first = Material( "craphead_scripts/ch_atm/leaderboards/first.png", "noclamp smooth" )
local icon_second = Material( "craphead_scripts/ch_atm/leaderboards/second.png", "noclamp smooth" )
local icon_third = Material( "craphead_scripts/ch_atm/leaderboards/third.png", "noclamp smooth" )

function ENT:DrawTranslucent()
	self:DrawModel()
	
	if self:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 1200000 then
		return
	end
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	Ang:RotateAroundAxis( Ang:Forward(), 0 )
	Ang:RotateAroundAxis( Ang:Right(), 90 )

	cam.Start3D2D( Pos + Ang:Up() * -1.2, Ang, 0.22 )
		-- Draw BG
		surface.SetDrawColor( CH_ATM.Colors.LightGray )
		surface.DrawRect( -500, -260, 1000, 520 )
		
		-- Draw top
		surface.SetDrawColor( CH_ATM.Colors.DarkGray )
		surface.DrawRect( -500, -260, 1000, 50 )
		
		draw.SimpleText( "ATM Para Liderleri", "CH_ATM_Font_Leaderboard_Header", 0, -255, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		
		if not CH_ATM.Leaderboard[1] then
			draw.SimpleText( "Leaderboard is not networked to you yet!", "CH_ATM_Font_Leaderboard_Header", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			-- First place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -150, -190, 300, 120 )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( icon_first )
			surface.DrawTexturedRect( -30, -205, 60, 60 )
			
			if CH_ATM.Leaderboard[1] then
				draw.SimpleText( CH_ATM.Leaderboard[1].Name, "CH_ATM_Font_Leaderboard_Header", 0, -145, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[1].Amount ), "CH_ATM_Font_Leaderboard_Title", 0, -110, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Second place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -475, -160, 300, 120 )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( icon_second )
			surface.DrawTexturedRect( -355, -175, 60, 60 )
			
			if CH_ATM.Leaderboard[2] then
				draw.SimpleText( CH_ATM.Leaderboard[2].Name, "CH_ATM_Font_Leaderboard_Header", -325, -117.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[2].Amount ), "CH_ATM_Font_Leaderboard_Title", -325, -80, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Third place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( 175, -160, 300, 120 )
		
			surface.SetDrawColor( color_white )
			surface.SetMaterial( icon_third )
			surface.DrawTexturedRect( 295, -175, 60, 60 )
			
			if CH_ATM.Leaderboard[3] then
				draw.SimpleText( CH_ATM.Leaderboard[3].Name, "CH_ATM_Font_Leaderboard_Header", 325, -117.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[3].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, -80, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Fourth place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -500, -20, 1000, 40 )
			
			if CH_ATM.Leaderboard[4] then
				draw.SimpleText( "#4", "CH_ATM_Font_Leaderboard_Title", -325, -17.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[4].Name, "CH_ATM_Font_Leaderboard_Title", 0, -17.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[4].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, -17.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Fifth place
			if CH_ATM.Leaderboard[5] then
				draw.SimpleText( "#5", "CH_ATM_Font_Leaderboard_Title", -325, 22.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[5].Name, "CH_ATM_Font_Leaderboard_Title", 0, 22.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[5].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 22.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Sixth place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -500, 60, 1000, 40 )
			
			if CH_ATM.Leaderboard[6] then
				draw.SimpleText( "#6", "CH_ATM_Font_Leaderboard_Title", -325, 62.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[6].Name, "CH_ATM_Font_Leaderboard_Title", 0, 62.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[6].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 62.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Seventh place
			if CH_ATM.Leaderboard[7] then
				draw.SimpleText( "#7", "CH_ATM_Font_Leaderboard_Title", -325, 102.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[7].Name, "CH_ATM_Font_Leaderboard_Title", 0, 102.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[7].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 102.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Eighth place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -500, 140, 1000, 40 )
			
			if CH_ATM.Leaderboard[8] then
				draw.SimpleText( "#8", "CH_ATM_Font_Leaderboard_Title", -325, 142.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[8].Name, "CH_ATM_Font_Leaderboard_Title", 0, 142.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[8].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 142.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Ninth place
			if CH_ATM.Leaderboard[9] then
				draw.SimpleText( "#9", "CH_ATM_Font_Leaderboard_Title", -325, 182.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[9].Name, "CH_ATM_Font_Leaderboard_Title", 0, 182.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[9].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 182.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
			
			-- Tenth place
			surface.SetDrawColor( CH_ATM.Colors.DarkGray )
			surface.DrawRect( -500, 220, 1000, 40 )
			
			if CH_ATM.Leaderboard[10] then
				draw.SimpleText( "#10", "CH_ATM_Font_Leaderboard_Title", -325, 222.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.Leaderboard[10].Name, "CH_ATM_Font_Leaderboard_Title", 0, 222.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
				draw.SimpleText( CH_ATM.FormatMoney( CH_ATM.Leaderboard[10].Amount ), "CH_ATM_Font_Leaderboard_Title", 325, 222.5, CH_ATM.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
		end
	cam.End3D2D()
end