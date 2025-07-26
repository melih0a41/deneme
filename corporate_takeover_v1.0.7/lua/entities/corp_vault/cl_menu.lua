local materials = {
    Material("materials/corporate_takeover/cto_upgrade.png"),
    Material("materials/corporate_takeover/cto_lock_closed.png"),
    Material("materials/corporate_takeover/cto_lock_open.png")
}

local function VaultMenu(CorpID, ent)
	local Corp = Corporate_Takeover.Corps[CorpID]
	if(!Corp) then return false end
	local owner = player.GetBySteamID(Corp.owner)
	if(!owner || !IsValid(owner) || owner != LocalPlayer()) then return false end
	if(!ent || !IsValid(ent)) then return false end

	local w, h = ScrW() * 0.15, ScrH() * 0.25

	local main = vgui.Create("cto_main")
	main:SetSize(w, h)
	main:Center()
	main:SetWindowTitle(Corporate_Takeover:Lang("vault"))
	function main:Think()
		Corp = Corporate_Takeover.Corps[CorpID]
		if(!Corp) then
			if(IsValid(self)) then
				self:Remove()
			end
			return false
		end
	end

	local moneybox = vgui.Create("cto_bar", main)
	moneybox:Dock(TOP)
	moneybox:SetTall(Corporate_Takeover.Scale(40))
	moneybox:DockMargin(0, 0, 0, 0)
	function moneybox:FormatText(text)
		return DarkRP.formatMoney(text)
	end
	function moneybox:FetchValues()
		self:UpdateValues(Corp.money, Corp.maxMoney)
	end

	-- Door
	local text = Corporate_Takeover:Lang("open_vault")

	local state = ent:GetDoorOpen()
	if(state) then
		text = Corporate_Takeover:Lang("close_vault")
	end

	local dismantle = vgui.Create("cto_button", main)
	dismantle:Dock(BOTTOM)
	dismantle:SetText(Corporate_Takeover:Lang("dismantle_vault"))
	dismantle:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	dismantle:DangerTheme()
	function dismantle:DoClick()
		net.Start("cto_dismantleDesk")
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end


	-- Upgrade
	local lang = Corporate_Takeover:Lang("upgrade_vault")
	local upgrade = vgui.Create("cto_button", main)
	upgrade:Dock(BOTTOM)
	upgrade:SetText("")
	upgrade:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	function upgrade:DoClick()
		-- Düzeltildi: Bu buton artık kasayı genişletme (Expand) işlemini tetikliyor.
		net.Start("cto_ExpandVault")
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
	function upgrade:PaintOver(w, h)
		local vault = Corp.maxMoney
		local Cost = math.Round(vault * Corporate_Takeover.Config.VaultExpansionPercent)

		draw.SimpleText(lang.." ("..DarkRP.formatMoney(Cost)..")", "cto_20", w/2, h / 2, self:IsHovered() and Corporate_Takeover.Config.Colors.Green or Corporate_Takeover.Config.Colors.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	local door = vgui.Create("cto_button", main)
	door:Dock(FILL)
	door:SetText(text)
	door:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	function door:DoClick()
		-- Düzeltildi: Bu buton artık kapıyı açma/kapama (Toggle) işlemini tetikliyor.
		net.Start("cto_ToggleVaultDoor")
		net.SendToServer()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
end

net.Receive("cto_OpenVaultMenu", function()
	local CorpID, ent = net.ReadUInt(8), net.ReadEntity()
	VaultMenu(CorpID, ent)
end)