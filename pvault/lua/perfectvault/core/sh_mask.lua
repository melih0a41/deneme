if CLIENT then
	perfectVault.Core.HasMask = perfectVault.Core.HasMask or {}
	perfectVault.Core.MaskOn = perfectVault.Core.MaskOn or {}

	net.Receive("pvault_update_mask", function()
		local ply = net.ReadEntity()
		local bool = net.ReadBool() -- Has mask
		local bool2 = net.ReadBool() -- Wearing mask

		perfectVault.Core.HasMask[ply:SteamID64()] = bool
		perfectVault.Core.MaskOn[ply:SteamID64()] = bool2
	end)

	hook.Add("PostDrawHUD", "pvault_mask_hud", function()
		if not perfectVault.Core.HasMask[LocalPlayer():SteamID64()] then return end

		draw.RoundedBox(0, ScrW()-200, ScrH()/2+50, 200, 115, Color(0, 0, 0, 200))
		draw.RoundedBox(0, ScrW()-200, ScrH()/2+50, 200, 20, Color(0, 0, 0, 200))

		if perfectVault.Core.MaskOn[LocalPlayer():SteamID64()] then
			draw.SimpleText(perfectVault.Translation.Mask.HoldingEquipped, "_pvault30", ScrW()-100, ScrH()/2+100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(string.format(perfectVault.Translation.Mask.Unequip, perfectVault.Config.ButtonToMaskOnString), "_pvault30", ScrW()-100, ScrH()/2+100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(perfectVault.Translation.Mask.HoldingUnequipped, "_pvault30", ScrW()-100, ScrH()/2+100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(string.format(perfectVault.Translation.Mask.Equip, perfectVault.Config.ButtonToMaskOnString), "_pvault30", ScrW()-100, ScrH()/2+100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
		draw.SimpleText(string.format(perfectVault.Translation.Mask.Drop, perfectVault.Config.ButtonToMaskDropString), "_pvault30", ScrW()-100, ScrH()/2+130, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end)

	hook.Add("PostPlayerDraw", "pvault_masks", function(ply)
		if ply == LocalPlayer() then return end

		if not perfectVault.Core.HasMask[ply:SteamID64()] then if ply.pault_mask then ply.pault_mask:Remove() ply.pault_mask = nil end return end
		if not perfectVault.Core.MaskOn[ply:SteamID64()] then if ply.pault_mask then ply.pault_mask:Remove() ply.pault_mask = nil end return end

		if not IsValid(ply) then if ply.pault_mask then ply.pault_mask:Remove() ply.pault_mask = nil end return end
		if not ply:Alive()  then if ply.pault_mask then ply.pault_mask:Remove() ply.pault_mask = nil end return end

		if LocalPlayer():GetPos():Distance( ply:GetPos() ) > 750 then if ply.pault_mask then ply.pault_mask:Remove() ply.pault_mask = nil end return end
	
	
		if not ply.pault_mask then
			if perfectVault.Config.HalloweenModels then
				ply.pault_mask = ClientsideModel("models/freeman/vault/owain_pumpkin.mdl")
				ply.pault_mask:SetBodygroup(1, math.random(0, 2))
			else
				ply.pault_mask = ClientsideModel("models/freeman/vault/owain_hockeymask.mdl")
				local plyClr = ply:GetPlayerColor()
				local clr = Color(255*plyClr[1], 255*plyClr[2], 255*plyClr[3])
				ply.pault_mask:SetColor(clr)
			end

			ply.pault_mask:SetParent(ply)
		end
	
	 	local ang = ply:GetAngles()
	 	local pos
	 	if ply:LookupBone("ValveBiped.Bip01_Head1") then
	 		b_pos, b_ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
	 		pos = b_pos + (b_ang:Right()*1)

			if perfectVault.Config.HalloweenModels then
				pos = pos + (b_ang:Forward()*4.5)
			end

	 		ang = b_ang
	 		ang:RotateAroundAxis(ang:Up(), 90)
	 		ang:RotateAroundAxis(ang:Forward(), -90)
	 		ang:RotateAroundAxis(ang:Right(), 195)
	 	else 
	 		pos = ply:GetPos() + Vector(0, 0, 120)
	 		ang:RotateAroundAxis(ang:Up(), 90)
	 		ang:RotateAroundAxis(ang:Forward(), -90)
	 		ang:RotateAroundAxis(ang:Right(), 195)
	 	end
	 	ply.pault_mask:SetPos(pos)
	 	ply.pault_mask:SetAngles(ang)
	end)
end

if SERVER then
	perfectVault.Core.HasMask = perfectVault.Core.HasMask or {}
	perfectVault.Core.MaskOn = perfectVault.Core.MaskOn or {}


	hook.Add("PlayerButtonDown", "pvault_mask", function(ply, key)
		if key == perfectVault.Config.ButtonToMaskOn then
			if not ply.pvault_equip_cooldown then ply.pvault_equip_cooldown = CurTime() end
			if not perfectVault.Core.HasMask[ply:SteamID64()] then return end
			if ply.pvault_equip_cooldown > CurTime() then return end
			ply.pvault_equip_cooldown = CurTime() + 2
	
			perfectVault.Core.MaskOn[ply:SteamID64()] = !perfectVault.Core.MaskOn[ply:SteamID64()]

			net.Start("pvault_update_mask")
				net.WriteEntity(ply)
				net.WriteBool(perfectVault.Core.HasMask[ply:SteamID64()])
				net.WriteBool(perfectVault.Core.MaskOn[ply:SteamID64()])
			net.Broadcast()

		elseif key == perfectVault.Config.ButtonToMaskDrop then
			if not ply.pvault_equip_cooldown then ply.pvault_equip_cooldown = CurTime() end
			if not perfectVault.Core.HasMask[ply:SteamID64()] then return end
			if ply.pvault_equip_cooldown > CurTime() then return end
			ply.pvault_equip_cooldown = CurTime() + 2


			perfectVault.Core.HasMask[ply:SteamID64()] = false
			perfectVault.Core.MaskOn[ply:SteamID64()] = false

			net.Start("pvault_update_mask")
				net.WriteEntity(ply)
				net.WriteBool(false)
				net.WriteBool(false)
			net.Broadcast()

			local mask = ents.Create("pvault_mask")
			mask:SetPos(ply:EyePos()+(ply:GetAimVector()*30))
			local ang = ply:EyeAngles()
 			ang:RotateAroundAxis( ang:Up(), 90 )
 			ang:RotateAroundAxis( ang:Forward(), 90 )
	
			mask:SetAngles(ang)
			mask:Spawn()
	
			local phys = mask:GetPhysicsObject()
			if (!IsValid(phys)) then mask:Remove() return end
		end
	end)


	hook.Add("PlayerDeath", "pvault_losemask", function(ply)
		if perfectVault.Config.LoseMaskOnDeath then
			if not perfectVault.Core.HasMask[ply:SteamID64()] then return end
			perfectVault.Core.HasMask[ply:SteamID64()] = false
			perfectVault.Core.MaskOn[ply:SteamID64()] = false
			
			net.Start("pvault_update_mask")
				net.WriteEntity(ply)
				net.WriteBool(false)
				net.WriteBool(false)
			net.Broadcast()
		end
	end)
end

local plyMeta = FindMetaTable("Player")

function plyMeta:MaskedName()
	if perfectVault.Core.MaskOn[self:SteamID64()] then
		return perfectVault.Translation.Mask.MaskName
	else
		return self:Nick()
	end
end