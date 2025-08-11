local entBagPos = {
	["pvault_door"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_floordoor"] = function(ent) return ent:GetPos()+(ent:GetForward()*60) + (ent:GetUp()*20) end,
	["pvault_standalone_small"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_standalone_large"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_standalone_tall"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_wall_large"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_wall_small"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end,
	["pvault_wall_tall"] = function(ent) return ent:GetPos()+(ent:GetForward()*40) end
}
-- Vault functions
function perfectVault.Core.RobEnt(ent, ply)
	if not ent:GetRobable() then return end
	if not ent.doorUsable then return end
	if ent:GetAlarm() then return end
	if ent:GetMoneybags() < tonumber(ent.data.general.minBags) then
		perfectVault.Core.Msg(perfectVault.Translation.Chat.NoBags, ply) return
	end

	if player.GetCount() < tonumber(ent.data.general.plyNeeded) then
		perfectVault.Core.Msg(perfectVault.Translation.Vault.NoPlayers, ply) return
	end

	local cops = 0
	for k, v in pairs(player.GetAll()) do
		if v:isCP() then cops = cops + 1 continue end
		if perfectVault.Config.Government[v:Team()] then cops = cops + 1 continue end
	end

	if player.GetCount()*tonumber(ent.data.general.neededCops) > cops then
		perfectVault.Core.Msg(perfectVault.Translation.Chat.NoGovernment, ply) return
	end

	if perfectVault.Config.AllowAnyoneToRob then
		if perfectVault.Config.Government[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	else
		if not perfectVault.Config.Criminals[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	end

	if ent:GetLocked() then
		if ent.data.general.lockpick then
			perfectVault.Core.Msg(perfectVault.Translation.Chat.Locked, ply)
		else
			net.Start("pvault_ui")
				net.WriteEntity(ent)
			net.Send(ply)
			perfectVault.Core.OpenedUI[ply:SteamID64()] = CurTime() + 6
		end
	else
		local count = ent:GetMoneybags()
		ent:SetMoneybags(count-1)
		timer.Simple(0.1, function()
			if not IsValid(ent) then return end
			net.Start("pvault_vault_updatebags")
				net.WriteEntity(ent)
			net.Broadcast()
		end)

		local bag = ents.Create("pvault_moneybag")
		bag:SetPos(entBagPos[ent:GetClass()] and entBagPos[ent:GetClass()](ent) or ent:GetPos())
		bag.cooldown = CurTime()+2
		bag:Spawn()
		bag:SetValue(math.random(tonumber(ent.data.bag.minOutput), tonumber(ent.data.bag.maxOutput)))

		if count - 1 <= 0 then
			ent:Lock()
			ent:SetRobable(false)
			ent:RobberyCooldown()
			timer.Remove("pvault_opentimeleft_"..ent:EntIndex())
		end
	end
end

function perfectVault.Core.Msg(msg, ply)
	net.Start("pvault_msg")
		net.WriteString(msg)
	if not ply then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

perfectVault.Core.ActiveBags = perfectVault.Core.ActiveBags or {}

net.Receive("pvault_lockpick_pass", function(_, ply)
	if not perfectVault.Core.OpenedUI[ply:SteamID64()] then return end
	if perfectVault.Core.OpenedUI[ply:SteamID64()] + 300 < CurTime() then return end -- This makes is so that the user cannot open the vault if they have not opened the UI in 5 minutes.
	if perfectVault.Core.OpenedUI[ply:SteamID64()] > CurTime() then perfectVault.Core.Msg(perfectVault.Translation.Chat.PotentialExploiting, ply) return end

	if perfectVault.Config.AllowAnyoneToRob then
		if perfectVault.Config.Government[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	else
		if not perfectVault.Config.Criminals[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	end

	local vault = net.ReadEntity()
	if vault:GetAlarm() then return end
	if not vault:GetRobable() then return end
	if vault:GetPos():Distance(ply:GetPos()) > 300 then perfectVault.Core.Msg(perfectVault.Translation.Chat.TooFarAway, ply) return end
	vault:Unlock()
	if vault.data.alarm.alert then
		for k, v in pairs(player.GetAll()) do
			if not v:isCP() and not perfectVault.Config.Government[v:Team()] then continue end
			perfectVault.Core.Msg(perfectVault.Translation.Chat.NotifyGoverment, v)
		end
	end

	if vault.data.other.wanted then
		if vault.data.other.smartWant then
			for k, v in pairs(player.GetAll()) do
				if perfectVault.Config.AllowAnyoneToRob then
					if perfectVault.Config.Government[ply:Team()] then continue end
				else
					if not perfectVault.Config.Criminals[ply:Team()] then continue end
				end

				if vault:GetPos():Distance(v:GetPos()) < 1000 then
					v:wanted(nil, vault.data.other.wantedReason)
				end
			end
		else
			ply:wanted(nil, vault.data.other.wantedReason)
		end
	end

	hook.Run("pVaultVaultCracked", vault, ply)
end)

net.Receive("pvault_lockpick_fail", function(_, ply)
	if not perfectVault.Core.OpenedUI[ply:SteamID64()] then return end
	if perfectVault.Core.OpenedUI[ply:SteamID64()] + 300 < CurTime() then return end -- This makes is so that the user cannot open the vault if they have not opened the UI in 5 minutes.

	if perfectVault.Config.AllowAnyoneToRob then
		if perfectVault.Config.Government[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	else
		if not perfectVault.Config.Criminals[ply:Team()] then perfectVault.Core.Msg(perfectVault.Translation.Chat.WrongJob, ply) return end
	end

	local vault = net.ReadEntity()
	if not vault:GetLocked() then return end
	if not vault:GetRobable() then return end
	if vault:GetPos():Distance(ply:GetPos()) > 300 then perfectVault.Core.Msg(perfectVault.Translation.Chat.TooFarAway, ply) return end
	if tobool(vault.data.alarm.failTrigger) then
		vault:AlarmOn()

		if tobool(vault.data.alarm.alert) then
			for k, v in pairs(player.GetAll()) do
				if not v:isCP() and not perfectVault.Config.Government[v:Team()] then continue end
				perfectVault.Core.Msg(perfectVault.Translation.Chat.AlarmTriggered, v)
			end
		end

		timer.Simple(vault.data.alarm.lasts, function()
			if not IsValid(vault) then return end
			vault:SetRobable(true)
		end)
	end
	if tobool(vault.data.other.failCooldown) then
		vault:RobberyCooldown()
	end

	hook.Run("pVaultVaultCrackFailed", vault, ply)
end)

net.Receive("pvault_ui_makeoffer", function(_, ply)
	if perfectVault.Config.AllowAnyoneToRob then
		if perfectVault.Config.Government[ply:Team()] then return end
	else
		if not perfectVault.Config.Criminals[ply:Team()] then return end
	end

	local npc = net.ReadEntity()
	if npc:GetPos():Distance(ply:GetPos()) > 300 then return end
	if npc:GetClass() != "pvault_npc" then return end
	if npc:GetHolding() <= 0 then return end
	local offer = net.ReadFloat()
	if offer > 1 then return end
	if offer < 0 then return end
	if offer == (0/0) then return end

	if offer < npc.cutWanted then
		if tobool(npc.data.snitch.snitch) then
			local c = math.random(tonumber(npc.data.snitch.minChance), tonumber(npc.data.snitch.maxChance))
			local f = math.random(100)
			if c > f then
				perfectVault.Core.Msg(perfectVault.Translation.Chat.UndercutNegative, ply)
				ply:wanted(nil, perfectVault.Translation.Chat.RobbingTheBankReason, 120)
				return
			end
		end
		perfectVault.Core.Msg(perfectVault.Translation.NPC.CutTooSmall, ply)
		return
	end

	perfectVault.Core.Msg(perfectVault.Translation.NPC.FairOffer, ply)
	perfectVault.Core.Msg(string.format(perfectVault.Translation.NPC.BusinessDone, DarkRP.formatMoney(math.Round(npc:GetHolding()*(1-offer)))), ply)

	ply:addMoney(npc:GetHolding()*(1-offer))

	hook.Run("pVaultMoneyCleaned", ply, npc:GetHolding()*(1-offer))
	npc:SetHolding(0)
	npc.cutWanted = math.random(npc.data.cut.minCut, npc.data.cut.maxCut)/100
end)

hook.Add("PlayerButtonDown", "pvault_throw", function(ply, key)
	if key == perfectVault.Config.ButtonToThrowBag then
		if not ply.pvault_throw_cooldown then ply.pvault_throw_cooldown = CurTime() end
		if not perfectVault.Core.ActiveBags[ply:SteamID64()] then return end
		if #perfectVault.Core.ActiveBags[ply:SteamID64()] <= 0 then return end
		if ply.pvault_throw_cooldown > CurTime() then return end

		ply.pvault_throw_cooldown = CurTime() + 2

		local bagData = perfectVault.Core.ActiveBags[ply:SteamID64()][#perfectVault.Core.ActiveBags[ply:SteamID64()]]
		table.remove(perfectVault.Core.ActiveBags[ply:SteamID64()])

		net.Start("pvault_update_ply_bags")
			net.WriteEntity(ply)
			net.WriteInt(#perfectVault.Core.ActiveBags[ply:SteamID64()], 32)
		net.Broadcast()

		if #perfectVault.Core.ActiveBags[ply:SteamID64()] <= 0 then
			if perfectVault.Config.MoneybagWalkSpeed then
				ply:SetWalkSpeed(ply.pv_walkSpeed)
			end
			if perfectVault.Config.MoneybagRunSpeed then
				ply:SetRunSpeed(ply.pv_runSpeed)
			end
		end

		local bag = ents.Create("pvault_moneybag")
		bag:SetPos(ply:EyePos()+(ply:GetAimVector()*30))
		local ang = ply:EyeAngles()
 		ang:RotateAroundAxis( ang:Up(), 90 )
 		ang:RotateAroundAxis( ang:Forward(), 90 )

		bag:SetAngles(ang)
		bag:Spawn()
		bag:SetValue(bagData.amount)
		bag:SetColor(bagData.color)
		bag.thrower = ply
		bag.cooldown = CurTime()+2

		local phys = bag:GetPhysicsObject()
		if (!IsValid(phys)) then bag:Remove() return end

		local velocity = ply:GetAimVector()
		velocity = velocity * 10000
		velocity = velocity + (VectorRand()*1000)
		phys:ApplyForceCenter(velocity)

	end
end)

hook.Add("PlayerInitialSpawn", "pvault_newjoin", function(ply)
	for k, v in pairs(perfectVault.Core.ActiveBags) do
		if #v > 0 then
			net.Start("pvault_update_ply_bags")
				net.WriteEntity(player.GetBySteamID64(k))
				net.WriteInt(#v, 32)
			net.Send(ply)
		end
	end

	net.Start("pvault_update_ply_bags")
		net.WriteEntity(ply)
		net.WriteInt(0, 32)
	net.Broadcast()
end)

hook.Add("PlayerDeath", "pvault_resetbags", function(ply)
	if perfectVault.Config.DropBagsOnDeath then
		if not perfectVault.Core.ActiveBags[ply:SteamID64()] then return end
		for k, v in pairs(perfectVault.Core.ActiveBags[ply:SteamID64()]) do
			local bag = ents.Create("pvault_moneybag")
			bag:SetPos(ply:GetPos() + Vector(0, 0, math.random(0, 60)))
			local ang = Angle(0, 0, 0)
			bag:SetAngles(ang)
			bag:Spawn()
			bag:SetValue(v.amount)
			bag:SetColor(v.color)
			bag.cooldown = CurTime()+2
		end

		perfectVault.Core.ActiveBags[ply:SteamID64()] = nil
		net.Start("pvault_update_ply_bags")
			net.WriteEntity(ply)
			net.WriteInt(0, 32)
		net.Broadcast()
	end
	if perfectVault.Config.MoneybagWalkSpeed then
		if ply.pv_walkSpeed then
			ply:SetWalkSpeed(ply.pv_walkSpeed)
		end
	end
	if perfectVault.Config.MoneybagRunSpeed then
		if ply.pv_runSpeed then
			ply:SetRunSpeed(ply.pv_runSpeed)
		end
	end
end)

hook.Add("OnPlayerChangedTeam", "pvault_resetbags", function(ply)
	if perfectVault.Config.DropBagsOnDeath then
		if not perfectVault.Core.ActiveBags[ply:SteamID64()] then return end
		for k, v in pairs(perfectVault.Core.ActiveBags[ply:SteamID64()]) do
			local bag = ents.Create("pvault_moneybag")
			bag:SetPos(ply:GetPos() + Vector(0, 0, math.random(0, 60)))
			local ang = Angle(0, 0, 0)
			bag:SetAngles(ang)
			bag:Spawn()
			bag:SetValue(v.amount)
			bag:SetColor(v.color)
			bag.cooldown = CurTime()+2
		end

		perfectVault.Core.ActiveBags[ply:SteamID64()] = nil
		net.Start("pvault_update_ply_bags")
			net.WriteEntity(ply)
			net.WriteInt(0, 32)
		net.Broadcast()
	end
	if perfectVault.Config.MoneybagWalkSpeed then
		if ply.pv_walkSpeed then
			ply:SetWalkSpeed(ply.pv_walkSpeed)
		end
	end
	if perfectVault.Config.MoneybagRunSpeed then
		if ply.pv_runSpeed then
			ply:SetRunSpeed(ply.pv_runSpeed)
		end
	end
end)

hook.Add("PlayerDisconnected", "pvault_leave", function(ply)
	perfectVault.Core.ActiveBags[ply:SteamID64()] = nil
	net.Start("pvault_update_id_bags")
		net.WriteString(ply:SteamID64())
		net.WriteInt(0, 32)
	net.Broadcast()
end)