--GUI base created by billy
--https://scriptfodder.com/users/view/76561198040894045/scripts

local Party = {}
local disconnectedicon = "icon16/disconnect.png"
local leadericon = "icon16/award_star_gold_1.png"
local wantedicon = "icon16/exclamation.png"

-- HUD pozisyonunu sol orta kisma sabitle
party.hudverticalpos = ScrH() / 2 - 100  -- Ekranin ortasindan biraz yukari
party.hudhorizontalpos = 10              -- Sol kenardan 10 pixel

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

-- Hook temizleme fonksiyonu
local function CleanupPartyHooks()
	hook.Remove("Think", "PartyHUDContextCheck")
	hook.Remove("Think", "Partykeylistener")
end

-- Baslangicta problematik hook'lari temizle
CleanupPartyHooks()

-- Ana HUD cizim fonksiyonu - HP HAVUZU EKLENDI
hook.Add("HUDPaint", "drawpartyhud", function()
	if GetConVar("party_showhud"):GetInt() != 1 then
		if parties != nil and parties[LocalPlayer():GetParty()] != nil and parties[LocalPlayer():GetParty()].members != nil then
			-- HUD pozisyonunu otomatik guncelle (cozunurluk degisirse)
			party.hudverticalpos = ScrH() / 2 - 100
			party.hudhorizontalpos = 10
			
			-- HUD cizimi
			draw.DrawText(party.language["Party Name"] ..": " ..parties[LocalPlayer():GetParty()].name, "roboto16", party.hudhorizontalpos, party.hudverticalpos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			
			-- Uye listesi
			local lastMemberY = party.hudverticalpos
			for v,k in pairs(parties[LocalPlayer():GetParty()].members) do
				local position = v * 55 - 30 + v * 5 + party.hudverticalpos
				lastMemberY = position + 55 -- Son uyenin Y pozisyonunu kaydet
				
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
			
			-- ============================
			-- HP HAVUZU BILGISI
			-- ============================
			if PropHP and PropHP_Client and PropHP_Client.PoolData then
				-- HP Havuzu panelini uyelerin altina ekle
				local hpPanelY = lastMemberY + 10 -- Son uyeden 10 pixel asagi
				local hpPanelHeight = 80
				
				-- HP Havuzu arka plani (parti uyeleri ile ayni stil)
				draw.RoundedBox(5, party.hudhorizontalpos, hpPanelY, 150, hpPanelHeight, party.backgroundcolor)
				draw.RoundedBox(5, 3 + party.hudhorizontalpos, hpPanelY + 3, 150 - 6, hpPanelHeight - 6, Color(0, 0, 0, 200))
				
				-- HP HAVUZU basligi
				draw.DrawText("HP HAVUZU", "roboto16", party.hudhorizontalpos + 75, hpPanelY + 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				
				-- Toplam Havuz
				local totalHP = PropHP_Client.PoolData.total
				local displayHP = "0 HP"
				if totalHP > 0 then
					if totalHP >= 1000000 then
						displayHP = string.format("%.1fM", totalHP / 1000000)
					elseif totalHP >= 1000 then
						displayHP = string.format("%.0fK", totalHP / 1000)
					else
						displayHP = totalHP .. " HP"
					end
				end
				draw.DrawText("Havuz: " .. displayHP, "roboto16", 5 + party.hudhorizontalpos, hpPanelY + 20, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
				
				-- Prop sayisi
				local propText = "Prop: " .. PropHP_Client.PoolData.propCount
				draw.DrawText(propText, "roboto16", 5 + party.hudhorizontalpos, hpPanelY + 35, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				
				-- HP/Prop
				local hpPerProp = PropHP_Client.PoolData.hpPerProp
				local hpPerPropText = "0"
				if hpPerProp > 0 then
					if hpPerProp >= 1000 then
						hpPerPropText = string.format("%.0fK", hpPerProp / 1000)
					else
						hpPerPropText = tostring(hpPerProp)
					end
				end
				
				-- HP/Prop rengi
				local hpColor = Color(255, 255, 255, 255)
				if hpPerProp < 10000 then
					hpColor = Color(255, 100, 100, 255) -- Kirmizi
				elseif hpPerProp < 50000 then
					hpColor = Color(255, 255, 0, 255) -- Sari
				else
					hpColor = Color(100, 255, 100, 255) -- Yesil
				end
				
				draw.DrawText("HP/Prop: " .. hpPerPropText, "roboto16", 5 + party.hudhorizontalpos, hpPanelY + 50, hpColor, TEXT_ALIGN_LEFT)
				
				-- Yok edilen prop sayısı (eğer varsa)
				if PropHP_Client.PoolData.destroyed > 0 then
					draw.DrawText("Yıkılan: " .. PropHP_Client.PoolData.destroyed, "roboto16", 5 + party.hudhorizontalpos, hpPanelY + 65, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT)
				end
			end
		end
	end
	
	-- Oyuncu uzerinde parti adi gosterme
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

-- Sunucu degisikliginde veya disconnect'te temizle
hook.Add("Disconnect", "PartyHUDCleanup", CleanupPartyHooks)
hook.Add("ShutDown", "PartyHUDCleanup", CleanupPartyHooks)