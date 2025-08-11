net.Receive("pvault_msg", function()
	perfectVault.Core.Msg(net.ReadString())
end)

perfectVault.Core.Msg = function(msg)
	chat.AddText(perfectVault.Config.PrefixColor, perfectVault.Config.Prefix..": ", Color( 255, 255, 255 ), msg)
end


if not file.Exists("pvault_data", "DATA") then
	file.CreateDir("pvault_data")
	file.CreateDir("pvault_data/ui")
end	

perfectVault.Icons = {}
perfectVault.Icons[1] = {name = "money-bag",  mat = Material("pvault/money-bag.png")}
perfectVault.Icons[2] = {name = "padlock", mat = Material("pvault/padlock.png")}
perfectVault.Icons[3] = {name = "police", mat = Material("pvault/police.png")}
perfectVault.Icons[4] = {name = "alarm", mat = Material("pvault/alarm.png")}


perfectVault.Core.ActiveBags = perfectVault.Core.ActiveBags or {}
net.Receive("pvault_update_ply_bags", function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	local count = net.ReadInt(32)

	if not ply:SteamID64() then return end
	perfectVault.Core.ActiveBags[ply:SteamID64()] = count
end)
net.Receive("pvault_update_id_bags", function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	local count = net.ReadInt(32)
	if not count then return end
	
	perfectVault.Core.ActiveBags[ply] = count
end)

hook.Add("PostPlayerDraw", "pvault_back_bags", function(ply)
	if ply == LocalPlayer() then return end
	if not perfectVault.Core.ActiveBags then perfectVault.Core.ActiveBags = {} end
	if !perfectVault.Core.ActiveBags[ply:SteamID64()] then if ply.pvault_bag then ply.pvault_bag:Remove() ply.pvault_bag = nil end return end
	if perfectVault.Core.ActiveBags[ply:SteamID64()] <= 0 then if ply.pvault_bag then ply.pvault_bag:Remove() ply.pvault_bag = nil end return end
	if !IsValid(ply) then if ply.pvault_bag then ply.pvault_bag:Remove() ply.pvault_bag = nil end return end
	if !ply:Alive()  then if ply.pvault_bag then ply.pvault_bag:Remove() ply.pvault_bag = nil end return end
	if LocalPlayer():GetPos():Distance( ply:GetPos() ) > 750 then if ply.pvault_bag then ply.pvault_bag:Remove() ply.pvault_bag = nil end return end


	if !ply.pvault_bag then
		ply.pvault_bag = ClientsideModel("models/freeman/duffel_bag.mdl")
		local plyClr = ply:GetPlayerColor()
		local clr = Color(255*plyClr[1], 255*plyClr[2], 255*plyClr[3])
		ply.pvault_bag:SetColor(clr)
		ply.pvault_bag:SetModelScale(ply.pvault_bag:GetModelScale()*0.9, 0)
		ply.pvault_bag:SetParent(ply)
	end

 	local ang = ply:GetAngles()
 	local pos
 	if ply:LookupBone("ValveBiped.Bip01_Spine") then
 		b_pos, b_ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Spine"))
 		pos = b_pos + (b_ang:Right()*8) + (b_ang:Forward()*6) + (b_ang:Up())
 		ang = b_ang
 		ang:RotateAroundAxis(ang:Up(), 90)
 		ang:RotateAroundAxis(ang:Forward(), 25)
 		ang:RotateAroundAxis(ang:Right(), 90)
 	else 
 		pos = ply:GetPos() + Vector(0, 0, 40) + (ang:Forward()*-13)
 		ang:RotateAroundAxis(ang:Up(), 90)
 		ang:RotateAroundAxis(ang:Forward(), -90)
 		ang:RotateAroundAxis(ang:Up(), 25)
 	end
 	ply.pvault_bag:SetPos(pos)
 	ply.pvault_bag:SetAngles(ang)
end)

hook.Add("PostDrawHUD", "pvault_bag_hud", function()
	if not perfectVault.Core.ActiveBags[LocalPlayer():SteamID64()] then return end
	if perfectVault.Core.ActiveBags[LocalPlayer():SteamID64()] <= 0 then return end
	draw.RoundedBox(0, ScrW()-200, ScrH()/2-50, 200, 85, Color(0, 0, 0, 200))
	draw.RoundedBox(0, ScrW()-200, ScrH()/2-50, 200, 20, Color(0, 0, 0, 200))
	draw.SimpleText(string.format(perfectVault.Translation.HUD.Holding, perfectVault.Core.ActiveBags[LocalPlayer():SteamID64()], perfectVault.Config.MaxBagCarry), "_pvault30", ScrW()-100, ScrH()/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(string.format(perfectVault.Translation.HUD.Throw, perfectVault.Config.ButtonToThrowBagString), "_pvault30", ScrW()-100, ScrH()/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end)


net.Receive("pvault_ply_leave", function()
	local tar = net.ReadEntity()
	if tar.pvault_bag then tar.pvault_bag:Remove() tar.pvault_bag = nil end
end)

net.Receive("pvault_vault_updatebags", function()
	local vault = net.ReadEntity()
	local room = vault.room or vault
	if not IsValid(vault) then return end
	if not IsValid(room) then return end
	if not vault.data then return end
	for i=0, tonumber(vault.data.general.bagCount) do
		if i > vault:GetMoneybags() then
			room:SetBodygroup(i, 0)
		else
			room:SetBodygroup(i, 1)
		end
	end
end)

local stencilcolor = Color(255,255,255,1)
local positions = {
	["pvault_door"] = function(ent)
		local angle = ent:GetAngles()
		angle:RotateAroundAxis(angle:Right(), -90)

		cam.Start3D2D(ent:GetPos()-(ent:GetForward()*-1.5), angle, 0.5)
			draw.RoundedBox(0,-75, -60, 160, 120, stencilcolor)
		cam.End3D2D()
	end,
	["pvault_floordoor"] = function(ent)
		local angle = ent:GetAngles()

		cam.Start3D2D(ent:GetPos() + (ent:GetUp()*0.85), angle, 0.3)
			draw.RoundedBox(0, -60, -60, 120, 120, stencilcolor)
		cam.End3D2D()
	end,
	["pvault_wall_large"] = function(ent)
		local angle = ent:GetAngles()
		angle:RotateAroundAxis(angle:Right(), 90)

		cam.Start3D2D(ent:GetPos()-(ent:GetForward()*-16.3), angle, 0.5)
			draw.RoundedBox(0, -32, -32, 65, 65, stencilcolor)
		cam.End3D2D()
	end,
	["pvault_wall_small"] = function(ent)
		local angle = ent:GetAngles()
		angle:RotateAroundAxis(angle:Right(), 90)

		cam.Start3D2D(ent:GetPos()-(ent:GetForward()*-9.3), angle, 0.5)
			draw.RoundedBox(0, -16, -16, 32, 32, stencilcolor)
		cam.End3D2D()
	end,
	["pvault_wall_tall"] = function(ent)
		local angle = ent:GetAngles()
		angle:RotateAroundAxis(angle:Right(), 90)

		cam.Start3D2D(ent:GetPos()-(ent:GetForward()*-10.1), angle, 0.5)
			draw.RoundedBox(0, -68, -18, 136, 36, stencilcolor)
		cam.End3D2D()
	end
}

-- huge credit to CodeBlue for helping me out with this, he's a true good guy
hook.Add("PreDrawTranslucentRenderables", "pvault_stencils", function(depth, skybox)
	if skybox or depth then return end
	for k, v in pairs(perfectVault.Walls) do
		if not IsValid(v) then continue end

		local screenpos = v:GetPos():ToScreen()
		if !screenpos.visible then
			continue
		end

		render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(44)
			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilFailOperation(STENCIL_ZERO)
			render.SetStencilZFailOperation(STENCIL_ZERO)

			positions[v:GetClass()](v)
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.DepthRange(0, 0.9)
			if not IsValid(v.room) then
				v:Initialize()
			end
			v.room:DrawModel()

		render.SetStencilEnable(false)
		render.DepthRange(0, 1)
		render.ClearStencil()
	end
end)
