local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.onoff = false
end

function PANEL:DoClick()
	self:Toggle()
end

function PANEL:Toggle()
	self:SetToggle(!self:GetToggle())
end

function PANEL:GetToggle()
	return self.onoff
end

function PANEL:SetToggle(tog)
	self.onoff = tog
end

function PANEL:Paint()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(50, 50, 50))
	if self.onoff then
		draw.SimpleText("X", "_pvault30", self:GetWide()/2, self:GetTall()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
vgui.Register('pvault_check_box', PANEL, 'DButton')

perfectVault.UI.ConfigMenu = nil
perfectVault.UI.CurrentConfigSettings = perfectVault.UI.CurrentConfigSettings or {}
perfectVault.UI.CurrentConfigSettings.entity = perfectVault.UI.CurrentConfigSettings.entity or nil
perfectVault.UI.CurrentConfigSettings.settings = perfectVault.UI.CurrentConfigSettings.settings or {}
function perfectVault.UI.Config()
	if IsValid(perfectVault.UI.ConfigMenu) then perfectVault.UI.ConfigMenu:Show() return end

	local populateConfigOptions
	local completeConfig

	perfectVault.UI.ConfigMenu = vgui.Create("DFrame")
	perfectVault.UI.ConfigMenu:SetSize(ScrH()*0.6, ScrH()*0.8)
	perfectVault.UI.ConfigMenu:Center()
	perfectVault.UI.ConfigMenu:MakePopup()
	perfectVault.UI.ConfigMenu:SetTitle("")
	perfectVault.UI.ConfigMenu:ShowCloseButton(false)
	perfectVault.UI.ConfigMenu.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.RoundedBox(0, 0, 0, w, 25, Color(0, 0, 0, 200))
	end
	
	local close = vgui.Create("DButton", perfectVault.UI.ConfigMenu)
	close:SetSize(25, 25)
	close:SetPos(perfectVault.UI.ConfigMenu:GetWide()-25, 0)
	close.DoClick = function()
		--perfectVault.UI.ConfigMenu:Close()
		perfectVault.UI.ConfigMenu:Hide()
	end
	close:SetText("")
	close.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.SimpleText("X", "_pvault_derma_smaller", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local shell = vgui.Create("DScrollPanel", perfectVault.UI.ConfigMenu)
	shell:SetSize(perfectVault.UI.ConfigMenu:GetWide()-10, perfectVault.UI.ConfigMenu:GetTall()-35)
	shell:SetPos(5, 30)
	shell:DockMargin(0, 5, 0, 5)
	shell.Paint = function() end
	local sbar = shell:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 100))
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 150))
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 200))
	end
	
		local header = vgui.Create("DPanel", shell)
		header:SetSize(shell:GetWide(), 120)
		header:Dock(TOP)
		header.Paint = function(self, w, h)
			draw.SimpleText(perfectVault.Translation.Config.EntitySetup, "_pvault_derma", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(perfectVault.Translation.Config.EntitySetupDesc, "_pvault_derma_smaller", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		local entity = vgui.Create("DPanel", shell)
		entity:SetSize(shell:GetWide(), 105)
		entity:Dock(TOP)
		entity.Paint = function(self, w, h)
			--draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
			draw.RoundedBox(0, 0, 0, w, 2, Color(255, 255, 255))
			draw.SimpleText(perfectVault.Translation.Config.EntitySpawn, "_pvault50", w/2, -5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
			draw.SimpleText(perfectVault.Translation.Config.EntitySpawnDesc, "_pvault40", w/2, 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
		end

		local entityInput = vgui.Create("DComboBox", entity)
		entityInput:SetPos(shell:GetWide()*0.2, 75)
		entityInput:SetSize(shell:GetWide()*0.6, 25)
		entityInput:SetValue("Select an object to config")
		for k, v in pairs(perfectVault.Core.Entites) do
			entityInput:AddChoice(perfectVault.Translation.Config.EntityClassNames[k] or k, k)
		end
		entityInput.OnSelect = function(self, index, value)
			local name, value = self:GetSelected()
			populateConfigOptions(value)
		end
	

		local optionsCache
		local panelsToDelete = {}
		function populateConfigOptions(class)
			optionsCache = {}
			if not perfectVault.Core.Entites[class] then return end

			for k, v in pairs(panelsToDelete) do
				v:Remove()
			end

			for k, v in pairs(perfectVault.Core.GetEntityConfigOptions(class)) do
				local settingHeader = vgui.Create("DCollapsibleCategory", shell)
				settingHeader:SetSize(shell:GetWide(), 68 + (table.Count(v)*95))
				settingHeader:SetLabel("")
				settingHeader:SetExpanded(0)
				settingHeader:Dock(TOP)
				settingHeader.Header:SetSize(shell:GetWide(), 70)
				settingHeader.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, 2, Color(255, 255, 255))
					draw.RoundedBox(0, w*0.2, 70, w*0.6, 2, Color(255, 255, 255))
					draw.SimpleText(perfectVault.Translation.Config.RegisteredConfigs[k].title, "_pvault50", w/2, -2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
					draw.SimpleText(perfectVault.Translation.Config.RegisteredConfigs[k].desc, "_pvault30", w/2, 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
				end

				table.insert(panelsToDelete, settingHeader)
				optionsCache[k] = {}
				for n, m in pairs(v) do
					local setting = vgui.Create("DPanel", settingHeader)
					setting:SetSize(settingHeader:GetWide(), 95)
					setting:Dock(TOP)
					setting.Paint = function(self, w, h)
						draw.SimpleText(perfectVault.Translation.Config.RegisteredConfigs[k].options[n].title..(m.r and string.format(perfectVault.Translation.Config.Requires, perfectVault.Translation.Config.RegisteredConfigs[k].options[m.r].title) or ""), "_pvault40", 5, 0, Color(255, 255, 255), TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT)
						draw.SimpleText(perfectVault.Translation.Config.RegisteredConfigs[k].options[n].desc, "_pvault30", 5, 35, Color(255, 255, 255), TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT)
					end
					if m.t == "num" then
						setting.input = vgui.Create("DTextEntry", setting)
						setting.input:SetPos(5, 65)
						setting.input:SetSize(50, 25)
						setting.input:SetText(m.d)
						setting.input:SetNumeric(true)
						setting.input.Paint = function(self, w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
							self:DrawTextEntryText(Color(255, 255, 255), Color(0, 178, 238), Color(255, 255, 255))
						end
					elseif m.t == "string" then
						setting.input = vgui.Create("DTextEntry", setting)
						setting.input:SetPos(5, 65)
						setting.input:SetSize(shell:GetWide()*0.5, 25)
						setting.input:SetText(m.d)
						setting.input.Paint = function(self, w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
							self:DrawTextEntryText(Color(255, 255, 255), Color(0, 178, 238), Color(255, 255, 255))
						end
					elseif m.t == "bool" then
						setting.input = vgui.Create("pvault_check_box", setting)
						setting.input:SetPos(5, 65)
						setting.input:SetSize(25, 25)
						setting.input:SetToggle(m.d)
					end

					optionsCache[k][n] = setting
				end
			end


			completeConfig = vgui.Create("DButton", shell)
			completeConfig:SetSize(shell:GetWide(), 60)
			completeConfig:Dock(TOP)
			completeConfig:SetText("")
			completeConfig.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
				draw.SimpleText(perfectVault.Translation.Config.ApplyChanges, "_pvault50", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			table.insert(panelsToDelete, completeConfig)
			completeConfig.DoClick = function()
				local name, value = entityInput:GetSelected()
				perfectVault.UI.CurrentConfigSettings.entity = value
				perfectVault.UI.CurrentConfigSettings.settings = {}
				for k, v in pairs(perfectVault.Core.GetEntityConfigOptions(perfectVault.UI.CurrentConfigSettings.entity)) do
					perfectVault.UI.CurrentConfigSettings.settings[k] = {}
					for n, m in pairs(v) do
						if m.t == "num" then
							perfectVault.UI.CurrentConfigSettings.settings[k][n] = (not (optionsCache[k][n].input:GetText() == "") and optionsCache[k][n].input:GetText()) or v.d
						elseif m.t == "string" then
							perfectVault.UI.CurrentConfigSettings.settings[k][n] = (not (optionsCache[k][n].input:GetText() == "") and optionsCache[k][n].input:GetText()) or v.d
						elseif m.t == "bool" then
							perfectVault.UI.CurrentConfigSettings.settings[k][n] = optionsCache[k][n].input:GetToggle()
						end
					end
				end
				perfectVault.Core.Msg("Config saved, please place an entity with the selected settings!")
				--perfectVault.UI.ConfigMenu:Close()
				perfectVault.UI.ConfigMenu:Hide()
			end
		end
end