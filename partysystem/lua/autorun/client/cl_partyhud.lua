--GUI base created by billy
--https://scriptfodder.com/users/view/76561198040894045/scripts

local Party = {}
local disconnectedicon = "icon16/disconnect.png"
local leadericon = "icon16/award_star_gold_1.png"
local wantedicon = "icon16/exclamation.png"
CreateClientConVar("party.hudhorizontalpos", party.hudhorizontalpos, true)
CreateClientConVar("party.hudverticalpos", party.hudverticalpos, true)
party.hudverticalpos = GetConVar( "party.hudverticalpos" ):GetInt()
party.hudhorizontalpos = GetConVar( "party.hudhorizontalpos" ):GetInt()

surface.CreateFont("roboto16",{
	size = 16,
	font = "Roboto",
})
party.DisplayParty = party.DisplayParty or true

local function safeText(text)
	return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
end

if !draw.DrawNonParsedText then
	function draw.DrawNonParsedText(text, font, x, y, color, xAlign)
		return draw.DrawText(safeText(text), font, x, y, color, xAlign)
	end
end

-- HUD pozisyonunu güncelleme için yeni fonksiyon
local function UpdateHUDPosition(x, y)
	party.hudhorizontalpos = math.Clamp(x, 0, ScrW() - 175)
	party.hudverticalpos = math.Clamp(y, 0, ScrH() - 300)
	GetConVar("party.hudhorizontalpos"):SetInt(party.hudhorizontalpos)
	GetConVar("party.hudverticalpos"):SetInt(party.hudverticalpos)
end

-- Mouse kontrolü için değişkenler
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0

-- F5 tuşu kontrolü
local contextMenuOpen = false
hook.Add("Think", "PartyHUDContextCheck", function()
	if input.IsKeyDown(KEY_F5) then
		if not contextMenuOpen then
			contextMenuOpen = true
		end
	else
		if contextMenuOpen then
			contextMenuOpen = false
			UpdateHUDPosition(party.hudhorizontalpos, party.hudverticalpos)
		end
	end
end)

hook.Add("HUDPaint", "drawpartyhud", function()
	if GetConVar("party_showhud"):GetInt() != 1 then
		if parties != nil and parties[LocalPlayer():GetParty()] != nil and parties[LocalPlayer():GetParty()].members != nil then
			-- HUD çizimi
			draw.DrawText(party.language["Party Name"] ..": " ..parties[LocalPlayer():GetParty()].name, "roboto16", party.hudhorizontalpos, party.hudverticalpos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			
			-- Üye listesi
			for v,k in pairs(parties[LocalPlayer():GetParty()].members) do
				local position = v * 55 - 30 + v * 5 + party.hudverticalpos
				local member = player.GetBySteamID64(k)
				draw.RoundedBox(5,party.hudhorizontalpos,position,150,55, party.backgroundcolor ) 
				draw.RoundedBox(5,3+ party.hudhorizontalpos,position+3,150-6,55-6,Color(0,0,0,200))
				
				if player.GetBySteamID64(k) != false then
					local health = math.Clamp(100*(1/(member:GetMaxHealth() / member:Health())),0,100)
					local armor = math.Clamp(member:Armor(), 0, 100)
					draw.RoundedBoxEx(0, 5+ party.hudhorizontalpos, position + 45, 2.1* health/1.5, 5, Color(200, 25, 25, 255), true, true, true, true)
					draw.RoundedBoxEx(0, 5+ party.hudhorizontalpos, position + 48, 2.1* armor/1.5, 3, Color(25, 25, 200, 255), true, true, true, true)
					draw.DrawText(string.Left(member:Nick(), 18), "roboto16", 5+ party.hudhorizontalpos, position+ 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.DrawText(party.language["offline"], "roboto16", 5+ party.hudhorizontalpos, position+ 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
				
				if player.GetBySteamID64(k) != false then
					if member:Alive() then
						draw.DrawText(member:Health().."/"..member:GetMaxHealth(), "roboto16", 5+ party.hudhorizontalpos, position+ 25, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					else
						draw.DrawText(party.language["Dead"], "roboto16", 5+ party.hudhorizontalpos, position+ 25, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end
					
					if (DarkRP) then
						if member:getDarkRPVar("job") != nil then
							if string.len(member:getDarkRPVar("job")) >= 15 then
								draw.DrawText(string.Left(member:getDarkRPVar("job"), 13).."..", "roboto16", 145+ party.hudhorizontalpos, position+ 25, team.GetColor(member:Team()), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
							else
								draw.DrawText(string.Left(member:getDarkRPVar("job"), 16), "roboto16", 145+ party.hudhorizontalpos, position+ 25, team.GetColor(member:Team()), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
							end
						end
						
						if member:isWanted() then
							surface.SetMaterial(Material(wantedicon))
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawTexturedRect(155+ party.hudhorizontalpos, position + 34, 16, 16)
						else
							surface.SetMaterial(Material(wantedicon))
							surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount)
							surface.DrawTexturedRect(155+ party.hudhorizontalpos, position+ 34, 16, 16)
						end
					end
				end
				
				-- Disconnect icon
				if player.GetBySteamID64(k) != false then
					surface.SetMaterial(Material(disconnectedicon))
					surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount)
					surface.DrawTexturedRect(155+ party.hudhorizontalpos, position + 16, 16, 16)
				else
					surface.SetMaterial(Material(disconnectedicon))
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(155+ party.hudhorizontalpos, position+ 16, 16, 16)
				end
				
				-- Leader icon
				if k == LocalPlayer():GetParty() then
					surface.SetMaterial(Material(leadericon))
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(155+ party.hudhorizontalpos, position + 0, 16, 16)
				else
					surface.SetMaterial(Material(leadericon))
					surface.SetDrawColor(255, 255, 255, party.fadediconsfadeamount)
					surface.DrawTexturedRect(155+ party.hudhorizontalpos, position+ 0, 16, 16)
				end
			end
			
			-- Mouse kontrolü sadece F5 basılıyken
			if contextMenuOpen then
				local mx, my = gui.MousePos()
				local memberCount = #parties[LocalPlayer():GetParty()].members
				local hudHeight = memberCount * 60 + 30
				
				-- HUD alanı kontrolü
				if mx >= party.hudhorizontalpos and mx <= party.hudhorizontalpos + 175 and
				   my >= party.hudverticalpos and my <= party.hudverticalpos + hudHeight then
					
					-- Sol tık ile sürükleme başlat
					if input.IsMouseDown(MOUSE_LEFT) then
						if not isDragging then
							isDragging = true
							dragOffsetX = mx - party.hudhorizontalpos
							dragOffsetY = my - party.hudverticalpos
						end
					else
						isDragging = false
					end
				end
				
				-- Sürükleme
				if isDragging then
					local newX = mx - dragOffsetX
					local newY = my - dragOffsetY
					party.hudhorizontalpos = math.Clamp(newX, 0, ScrW() - 175)
					party.hudverticalpos = math.Clamp(newY, 0, ScrH() - hudHeight)
				end
				
				-- Hareket oklarını göster
				draw.DrawText("↕", "roboto16", party.hudhorizontalpos + 160, party.hudverticalpos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.DrawText("↔", "roboto16", party.hudhorizontalpos + 160, party.hudverticalpos + 15, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				-- Kick butonları
				if parties[LocalPlayer():SteamID64()] then
					for v,k in pairs(parties[LocalPlayer():GetParty()].members) do
						if k != LocalPlayer():SteamID64() then
							local position = v * 60 + 2
							local buttonX = party.hudhorizontalpos + 97
							local buttonY = party.hudverticalpos + position
							
							-- Buton alanı kontrolü
							if mx >= buttonX and mx <= buttonX + 50 and
							   my >= buttonY and my <= buttonY + 20 then
								
								-- Hover efekti
								draw.RoundedBox(2, buttonX, buttonY, 50, 20, Color(100, 100, 100, 200))
								
								-- Tıklama kontrolü
								if input.IsMouseDown(MOUSE_LEFT) then
									net.Start("KickFromParty")
									net.WriteString(k)
									net.SendToServer()
								end
							else
								-- Normal buton görünümü
								draw.RoundedBox(2, buttonX, buttonY, 50, 20, Color(50, 50, 50, 200))
							end
							
							draw.DrawText(party.language["Kick"], "roboto16", buttonX + 25, buttonY + 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					end
				end
			end
		end
	end
	
	-- Oyuncu üzerinde parti adı gösterme
	if(!party.DisplayParty) then return end
	
	if party.DarkrpGamemode then
		local shouldDrawHud, players = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
		if shouldDrawHud == false then return end
	end
	
	local trace = LocalPlayer():GetEyeTrace()
	if trace.Hit == true and trace.HitNonWorld == true then
		if not trace.Entity:IsValid() then return end
		if trace.Entity:IsPlayer() and trace.Entity:Alive() then
			if trace.Entity:GetRenderMode() == RENDERMODE_TRANSALPHA then return end
			if trace.Entity == LocalPlayer() then return end
			
			local PlayersPos = trace.Entity:EyePos()
			local LocalEye = LocalPlayer():EyePos()
			PlayersPos.z = PlayersPos.z + 10
			
			if PlayersPos:Distance(LocalEye) < 250 then
				PlayersPos = PlayersPos:ToScreen()
				if party.DarkrpGamemode then
					if not trace.Entity:getDarkRPVar("wanted") then
						PlayersPos.y = PlayersPos.y - 50
					end
				end
				
				local partyname = trace.Entity:GetPartyName()
				if partyname then
					draw.DrawNonParsedText("Party : " .. partyname, "roboto16", PlayersPos.x + 1, PlayersPos.y + 61, Color(0,0,0), 1)
					draw.DrawNonParsedText("Party : " .. partyname, "roboto16", PlayersPos.x, PlayersPos.y +60, Color(255,255,255), 1)
				end
			end
		end
	end
end)

-- Context menu hook'larını kaldırıyoruz
-- Bunlar diğer HUD'ları engelleyen ana sebep