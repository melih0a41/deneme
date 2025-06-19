if SERVER then
	local player = FindMetaTable("Player")
	util.AddNetworkString("SPSTEAMVOICE")
	player.SPSTeamVoiceState = nil

	net.Receive( "SPSTEAMVOICE", function( len, ply )
		 ply.SPSTeamVoiceState = net.ReadBit()

	end )

	


	
	hook.Add("PlayerCanHearPlayersVoice", "SPSVoicechat", function(listener, talker)
		if talker.SPSTeamVoiceState == 1 then
			if !talker:GetParty() then return end
			if talker:GetParty() == listener:GetParty() then
				return true
			else 
				return false
			end
		end
	end)
end


if CLIENT then

	local function SendTeamVoiceState(onoff)
		net.Start("SPSTEAMVOICE")
			  net.WriteBit(onoff)
		net.SendToServer() 
	end
	
	local icon = Material("icon32/unmuted.png")
	local function SPSiconfunc()	
		surface.SetDrawColor(100, 255, 100)
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(party.hudhorizontalpos + 170, party.hudverticalpos + 35, 50,50)
	end


	hook.Add("PlayerStartVoice", "SPSOnVoice", function()
		if !LocalPlayer():GetParty() then return end
		if input.IsKeyDown( KEY_LSHIFT ) then
			SendTeamVoiceState(1)
			hook.Add("HUDPaint", "SPSImageOnVoice", SPSiconfunc)
		end
	end )

	hook.Add("PlayerEndVoice", "SPSOffVoice", function()
		SendTeamVoiceState(0)
		hook.Remove("HUDPaint", "SPSImageOnVoice")
	end)
	

end


