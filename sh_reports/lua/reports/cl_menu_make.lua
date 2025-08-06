local matBack = Material("shenesis/general/back.png")

function SH_REPORTS:ShowMakeReports(c, d)
	if (IsValid(_SH_REPORTS_MAKE)) then
		_SH_REPORTS_MAKE:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local frame = self:MakeWindow(SH_REPORTS:L("new_report"))
	frame:SetSize(500 * ss, 500 * ss)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS_MAKE = frame

		frame:AddHeaderButton(matBack, function()
			frame:Close()
			self:ShowReports()
		end)

		local body = vgui.Create("DPanel", frame)
		body:SetDrawBackground(false)
		body:Dock(FILL)
		body:DockMargin(m, m, m, m)

			local lbl = self:QuickLabel(SH_REPORTS:L("reason") .. ":", "{prefix}Large", styl.text, body)
			lbl:Dock(TOP)

				local reason = self:QuickComboBox(lbl)
				reason:Dock(FILL)
				reason:DockMargin(lbl:GetWide() + m, 0, 0, 0)

				-- Özel renklendirme için override
				reason.OldOpenMenu = reason.OpenMenu
				reason.OpenMenu = function(self, pControlOpener)
					self:OldOpenMenu(pControlOpener)
					
					if IsValid(self.Menu) then
						for _, v in pairs(self.Menu:GetChildren()[1]:GetChildren()) do
							local text = v:GetText()
							local data = v.data
							
							if type(SH_REPORTS.ReportReasons[data]) == "table" then
								local reasonData = SH_REPORTS.ReportReasons[data]
								-- Parantez öncesi kısmı bul
								local mainPart = reasonData.reason:match("^(.-)%s*%(") or reasonData.reason
								local parenPart = reasonData.reason:match("%(.*%)") or ""
								
								-- Panel oluştur
								v:SetText("")
								v.Paint = function(me, w, h)
									-- Arka plan
									if me.Hovered then
										draw.RoundedBox(0, 0, 0, w, h, styl.hover)
									else
										draw.RoundedBox(0, 0, 0, w, h, styl.inbg)
									end
									
									-- Metinleri çiz
									local x = 5
									surface.SetFont("SH_REPORTS.Medium")
									
									-- Ana kısım (kırmızı)
									surface.SetTextColor(styl.failure)
									surface.SetTextPos(x, h/2 - 8)
									surface.DrawText(mainPart)
									
									-- Parantez kısmı (beyaz)
									local tw = surface.GetTextSize(mainPart)
									surface.SetTextColor(styl.text)
									surface.SetTextPos(x + tw + 3, h/2 - 8)
									surface.DrawText(parenPart)
								end
							end
						end
					end
				end

				for rid, r in pairs (self.ReportReasons) do
					local reasonText = r
					if type(r) == "table" then
						reasonText = r.reason
					end
					reason:AddChoice(reasonText, rid)
				end

			local lbl = self:QuickLabel(SH_REPORTS:L("player_to_report") .. ":", "{prefix}Large", styl.text, body)
			lbl:Dock(TOP)
			lbl:DockMargin(0, m, 0, m)

				local target = self:QuickComboBox(lbl)
				target:SetSortItems(false)
				target:Dock(FILL)
				target:DockMargin(lbl:GetWide() + m, 0, 0, 0)

				local toadd = {}
				for _, ply in ipairs (player.GetAll()) do
					if (ply == LocalPlayer()) then
						continue end

					if (self:IsAdmin(ply) and !self.StaffCanBeReported) then
						continue end

					table.insert(toadd, {nick = ply:Nick(), steamid = ply:SteamID64()})
				end

				for _, d in SortedPairsByMemberValue (toadd, "nick") do
					target:AddChoice(d.nick, d.steamid)
				end

				if (self.CanReportOther) then
					target:AddChoice("​[" .. SH_REPORTS:L("other") .. "]", "0")
				end

			local p = vgui.Create("DPanel", body)
			p:SetTall(64 * ss + m)
			p:Dock(TOP)
			p:DockPadding(m2, m2, m2, m2)
			p.Paint = function(me, w, h)
				draw.RoundedBox(4, 0, 0, w, h, styl.inbg)
			end

				local pc = vgui.Create("DPanel", p)
				pc:SetPaintedManually(true)
				pc:SetDrawBackground(false)
				pc:Dock(FILL)

					local avi = self:Avatar("", 64 * ss, pc)
					avi:Dock(LEFT)
					avi:DockMargin(0, 0, m2, 0)

					local nick = self:QuickLabel("", "{prefix}Large", styl.text, pc)
					nick:Dock(TOP)

					local steamid = self:QuickLabel("", "{prefix}Medium", styl.text, pc)
					steamid:Dock(TOP)

			local lbl = self:QuickLabel(SH_REPORTS:L("comment") .. ":", "{prefix}Large", styl.text, body)
			lbl:SetContentAlignment(7)
			lbl:Dock(FILL)
			lbl:DockMargin(0, m, 0, 0)

				local comment = self:QuickEntry("", lbl)
				comment:SetValue(c or "")
				comment:SetMultiline(true)
				comment:Dock(FILL)
				comment:DockMargin(0, lbl:GetTall() + m2, 0, 0)

			local btns = vgui.Create("DPanel", body)
			btns:SetDrawBackground(false)
			btns:Dock(BOTTOM)
			btns:DockMargin(0, m, 0, 0)

				local submit = self:QuickButton(SH_REPORTS:L("submit_report"), function()
					local name, steamid = target:GetSelected()
					if (!steamid) then
						self:Notify(SH_REPORTS:L("select_player_first"), nil, styl.failure, frame)
						return
					end

					local _, rid = reason:GetSelected()
					if (!rid) then
						self:Notify(SH_REPORTS:L("select_reason_first"), nil, styl.failure, frame)
						return
					end
					
					-- Yetkili şikayeti kontrolü
					local reasonData = self.ReportReasons[rid]
					if type(reasonData) == "table" and reasonData.disabled then
						self:Notify("Bu kategori için rapor oluşturamazsınız. Discord üzerinden ticket açın.", nil, styl.failure, frame)
						return
					end

					easynet.SendToServer("SH_REPORTS.NewReport", {
						reported_name = name,
						reported_id = steamid,
						reason_id = rid,
						comment = comment:GetValue():sub(1, self.MaxCommentLength),
					})

					frame:Close()
				end, btns)
				submit:Dock(RIGHT)

			-- cbs
			-- Sebep seçimi callback'i
			reason.OnSelect = function(me, index, value, data)
				-- Yetkili şikayeti kontrolü
				local reasonData = self.ReportReasons[data]
				if type(reasonData) == "table" and reasonData.discord_redirect then
					-- Açıklama alanını Discord mesajıyla doldur
					comment:SetValue(reasonData.discord_message or "")
					comment:SetEnabled(false)
					
					-- Submit butonunu devre dışı görünsün
					submit:SetText("Discord'a Git")
					submit.DoClick = function()
						gui.OpenURL("https://discord.gg/basodark")
						frame:Close()
					end
				else
					-- Normal davranış
					comment:SetValue(c or "")
					comment:SetEnabled(true)
					
					-- Submit butonunu normale döndür
					submit:SetText(SH_REPORTS:L("submit_report"))
					submit.DoClick = function()
						local name, steamid = target:GetSelected()
						if (!steamid) then
							self:Notify(SH_REPORTS:L("select_player_first"), nil, styl.failure, frame)
							return
						end

						local _, rid = reason:GetSelected()
						if (!rid) then
							self:Notify(SH_REPORTS:L("select_reason_first"), nil, styl.failure, frame)
							return
						end
						
						-- Yetkili şikayeti kontrolü
						local reasonData = self.ReportReasons[rid]
						if type(reasonData) == "table" and reasonData.disabled then
							self:Notify("Bu kategori için rapor oluşturamazsınız. Discord üzerinden ticket açın.", nil, styl.failure, frame)
							return
						end

						easynet.SendToServer("SH_REPORTS.NewReport", {
							reported_name = name,
							reported_id = steamid,
							reason_id = rid,
							comment = comment:GetValue():sub(1, self.MaxCommentLength),
						})

						frame:Close()
					end
				end
				
				-- ReasonAutoTarget kontrolü (RDM, RDA vs)
				if (d) then
					local reasonText = value
					-- Eski sistemle uyumluluk için kontrol
					if type(self.ReportReasons[1]) == "table" then
						for k, v in pairs(self.ReportReasons) do
							if v.reason == value then
								reasonText = v.reason
								break
							end
						end
					end
					
					local k = self.ReasonAutoTarget[reasonText]
					if (!k) then
						return end

					local p = d["last" .. k]
					if (IsValid(p)) then
						local i
						for k, v in pairs (target.Choices) do
							if (v == p:Nick()) then
								i = k
								break
							end
						end

						if (i) then
							target:ChooseOption(p:Nick(), i)
						end
					end
				end
			end
			
			target.OnSelect = function(me, index, value, data)
				pc:SetPaintedManually(false)
				pc:SetAlpha(0)
				pc:AlphaTo(255, 0.2)

				avi:SetVisible(data ~= "0")
				avi:SetSteamID(data)
				nick:SetText(value)
				steamid:SetText(data ~= "0" and util.SteamIDFrom64(data) or "")
				steamid:InvalidateParent(true)
			end

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end

easynet.Callback("SH_REPORTS.QuickReport", function(data)
	SH_REPORTS:ShowMakeReports(data.comment, data)
end)