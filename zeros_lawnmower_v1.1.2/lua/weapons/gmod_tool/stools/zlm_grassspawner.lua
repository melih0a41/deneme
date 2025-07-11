/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

AddCSLuaFile()
TOOL.Category = "Zeros LawnMower"
TOOL.Name = "#GrassSpawner"
TOOL.Command = nil
TOOL.ClientConVar["amount"] = 25
TOOL.ClientConVar["radius"] = 200
TOOL.ClientConVar["model"] = "models/zerochain/props_lawnmower/zlm_grasscluster01.mdl"
TOOL.ClientConVar["random"] = 1

if (CLIENT) then
	language.Add("tool.zlm_grassspawner.name", "Zeros LawnMower - Grass Spawner")
	language.Add("tool.zlm_grassspawner.desc", "Creates a Grass Spot.")
	language.Add("tool.zlm_grassspawner.0", "LeftClick: Creates a Grass Spot.")
end


// Creates the Prop list for selection
local zero = { grass_rx = 0, grass_ry = 0, grass_rz = 0 }
for k, v in pairs(zlm.Grass) do
	list.Set( "GrassModels", v.model, zero )
end

function TOOL:CalculateGrassPositions(HitPos)

	local GrassPositions = {}

	local g_rad = math.Clamp(self:GetClientNumber("radius", 100),10,500)
	local grassCount = self:GetClientNumber("amount", 100)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	local function pointInCircle(r)
		r = math.sqrt(math.random()) * r
		local theta = math.random() * 2 * math.pi
		local x = HitPos.x + r * math.cos(theta)
		local y = HitPos.y + r * math.sin(theta)
		local aPos = Vector(1, 0, 0) * x + Vector(0, 1, 0) * y
		local fPos = Vector(aPos.x,aPos.y,HitPos.z)

		table.insert(GrassPositions, fPos)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

	for i = 1, grassCount do
		pointInCircle(g_rad)
	end

	return GrassPositions
end

function TOOL:LeftClick(trace)
	local trEnt = trace.Entity
	if (trEnt:IsPlayer()) then return false end
	if (CLIENT) then return end
	if zlm.f.IsAdmin(self:GetOwner()) == false then return end

	if (trEnt:GetClass() == "worldspawn") then

		local GrassPositions = self:CalculateGrassPositions(trace.HitPos)

		//Get the grass id from the selected model and send it with the Add_GrassSpot function
		local random = tonumber(self:GetClientInfo( "random" ))
		local id
		local model = "models/zerochain/props_lawnmower/zlm_grasscluster01.mdl"

		if self:GetClientInfo( "model" ) then
			model = self:GetClientInfo( "model" )
		end

		if random == 0 then

			for k, v in pairs(zlm.Grass) do
				if v.model == model then
					id = v.id
					break
				end
			end

			if id == nil then
				return true
			end

			zlm.f.Debug("Selected ID: " .. id)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

		local g_rad = math.Clamp(self:GetClientNumber("radius", 100),10,500)

		for k, v in pairs(GrassPositions) do
			//debugoverlay.Sphere( v + Vector(0,0,g_rad), 5, 1, Color( 255, 0, 0 ),true )
			//debugoverlay.Sphere( v - Vector(0,0,g_rad), 5, 1, Color( 0, 255, 0 ),true )
			local tr = util.TraceLine( {
				start = v + Vector(0,0,g_rad),
				endpos = v - Vector(0,0,g_rad),
				filter = function( ent ) if ( ent:GetClass() == "worldspawn" ) then return true end end
			} )

			if random == 1 then
				id = zlm.Grass[math.random(#zlm.Grass)].id
			end
			zlm.f.Add_GrassSpot(tr.HitPos,id)
		end

		zlm.f.Send_GrassSpots_ToClient(self:GetOwner())

		return true
	else
		return false
	end
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end

	zlm.f.Remove_GrassSpot(trace.HitPos,self:GetClientNumber("radius", 100))

	zlm.f.Send_GrassSpots_ToClient(self:GetOwner())
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

function TOOL:Deploy()
end

function TOOL:Holster()
end

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
function TOOL.BuildCPanel(CPanel)
	if CLIENT then
		CPanel:AddControl("Header", {
			Text = "#tool.zlm_grassspawner.name",
			Description = ""
		})

		zlm_OptionPanel("Grass",CPanel,{
			[1] = {name = "Grass Amount",class = "DNumSlider", cmd = "zlm_grassspawner_amount",min = 3,max = 150,decimal = 0},
			[2] = {name = "Grass Radius",class = "DNumSlider", cmd = "zlm_grassspawner_radius",min = 20,max = 500,decimal = 0},
			[3] = {name = "Random",class = "DCheckBoxLabel", cmd = "zlm_grassspawner_random"},
			[4] = {name = "Save",class = "DButton", cmd = "zlm_save_grassspots"},
			[5] = {name = "Remove",class = "DButton", cmd = "zlm_remove_grassspots"},
		})
	end
	CPanel:AddControl( "PropSelect", { Label = "Grass Types", ConVar = "zlm_grassspawner_model", Height = 0, Models = list.Get( "GrassModels" ) } )
end




hook.Add("PostDrawTranslucentRenderables", "a_zlm_PostDrawTranslucentRenderables_grassspawner", function()
	if zlm.f.ToolGun_HasToolActive() then
		local tr = LocalPlayer():GetEyeTrace()
		local tool = LocalPlayer():GetTool()

		if tool and tr.Hit and tr.HitPos then
			render.SetColorMaterial()
			render.DrawWireframeSphere(tr.HitPos, tool:GetClientNumber("radius", 100), 12, 12, zlm.default_colors["white01"], false)

			render.SetColorMaterial()
			render.DrawSphere(tr.HitPos, tool:GetClientNumber("radius", 100), 12, 12, zlm.default_colors["green05"])
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813
