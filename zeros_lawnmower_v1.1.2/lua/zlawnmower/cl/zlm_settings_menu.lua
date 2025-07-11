/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not CLIENT then return end
local Created = false

CreateConVar("zlm_cl_vfx_updateinterval", "0.1", {FCVAR_ARCHIVE})
CreateConVar("zlm_cl_vfx_updatedistance", "750", {FCVAR_ARCHIVE})
CreateConVar("zlm_cl_vfx_modelcount", "200", {FCVAR_ARCHIVE})
CreateConVar("zlm_cl_sfx_volume", "0.5", {FCVAR_ARCHIVE})



local function zlm_OptionPanel(name, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	panel:SetSize(250 , 40 + (35 * table.Count(cmds)))
	panel.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zlm.default_colors["grey02"])
	end

	local title = vgui.Create("DLabel", panel)
	title:SetPos(10, 2.5)
	title:SetText(name)
	title:SetFont("zlm_settings_font01")
	title:SetSize(panel:GetWide(), 30)
	title:SetTextColor(zlm.default_colors["green01"])

	for k, v in pairs(cmds) do
		if v.class == "DNumSlider" then

			local item = vgui.Create("DNumSlider", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText(v.name)
			item:SetMin(v.min)
			item:SetMax(v.max)
			item:SetDecimals(v.decimal)
			item:SetDefaultValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
			item:ResetToDefaultValue()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

			item.OnValueChanged = function(self, val)

				if (not Created) then
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
				end
			end)
		elseif v.class == "DCheckBoxLabel" then

			local item = vgui.Create("DCheckBoxLabel", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( v.name )
			item:SetConVar( v.cmd )
			item:SetValue(0)
			item.OnChange = function(self, val)

				if (not Created) then
					if ((bVal and 1 or 0) == cvars.Number(v.cmd)) then return end
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(GetConVar(v.cmd):GetInt())
				end
			end)
		elseif v.class == "DButton" then
			local item = vgui.Create("DButton", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( "" )
			item.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zlm.default_colors["grey03"])
				draw.SimpleText(v.name, "zlm_settings_font02", w / 2, h / 2, zlm.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if s.Hovered then
					draw.RoundedBox(5, 0, 0, w, h, zlm.default_colors["white02"])
				end
			end
			item.DoClick = function()

				if zlm.f.IsAdmin(LocalPlayer()) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

				LocalPlayer():EmitSound("zlm_ui_click")

				if v.notify then

					notification.AddLegacy(  v.notify, NOTIFY_GENERIC, 2 )
				end
				LocalPlayer():ConCommand( v.cmd )

			end
		end
	end

	CPanel:AddPanel(panel)
end


local function zlawnmower_settings(CPanel)
	Created = true
	CPanel:AddControl("Header", {
		Text = "Client Settings",
		Description = ""
	})

	zlm_OptionPanel("Grass",CPanel,{
		[1] = {name = "Update Interval",class = "DNumSlider", cmd = "zlm_cl_vfx_updateinterval",min = 0.1,max = 5,decimal = 1},
		[2] = {name = "Update Distance",class = "DNumSlider", cmd = "zlm_cl_vfx_updatedistance",min = 500,max = 3000,decimal = 0},
		[3] = {name = "Model Count",class = "DNumSlider", cmd = "zlm_cl_vfx_modelcount",min = 15,max = 500,decimal = 0},
	})

	zlm_OptionPanel("SFX",CPanel,{
		[1] = {name = "Volume",class = "DNumSlider", cmd = "zlm_cl_sfx_volume",min = 0,max = 1,decimal = 2},

	})

	timer.Simple(0.2, function()
		Created = false
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

local function zlawnmower_admin_settings(CPanel)

	CPanel:AddControl("Header", {
		Text = "Admin Settings",
		Description = ""
	})

	zlm_OptionPanel("NPC",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zlm_save_buyernpc"},
		[2] = {name = "Remove",class = "DButton", cmd = "zlm_remove_buyernpc"},
	})

	zlm_OptionPanel("Grass Spots",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zlm_save_grassspots"},
		[2] = {name = "Remove",class = "DButton", cmd = "zlm_remove_grassspots"},
	})

	zlm_OptionPanel("Vehicle Spawns",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zlm_save_vehiclespawn"},
		[2] = {name = "Remove",class = "DButton", cmd = "zlm_remove_vehiclespawn"},
	})


	zlm_OptionPanel("Lawnmower/Trailer",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zlm_save_lawnmower"},
		[2] = {name = "Remove",class = "DButton", cmd = "zlm_remove_lawnmower"},
	})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	zlm_OptionPanel("GrassPress",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zlm_save_grasspress"},
		[2] = {name = "Remove",class = "DButton", cmd = "zlm_remove_grasspress"},
	})

end


hook.Add( "PopulateToolMenu", "PopulatezlmMenus", function()
	spawnmenu.AddToolMenuOption( "Options", "LawnMower", "zlm_Settings", "Client Settings", "", "", zlawnmower_settings )
	spawnmenu.AddToolMenuOption("Options", "LawnMower", "zlm_Admin_Settings", "Admin Settings", "", "", zlawnmower_admin_settings)
end )

hook.Add( "AddToolMenuCategories", "CreatezlmCategories", function()
	spawnmenu.AddToolCategory( "Options", "LawnMower", "LawnMower" );
end )
