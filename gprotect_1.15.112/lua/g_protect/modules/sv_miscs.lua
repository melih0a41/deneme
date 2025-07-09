gProtect = gProtect or {}

local cfg, ghostingEnabled = gProtect.getConfig(nil, "miscs"), gProtect.getConfig("enabled", "ghosting")
local blacklist = gProtect.getConfig("blacklist", "general")

local propEnts = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

gProtect.HandleMiscToolGun = function(ply, tr, tool)
	if cfg.enabled then
		if tool == "fading_door" and IsValid(tr.Entity) and blacklist[tr.Entity:GetClass()] then
			if cfg.FadingDoorLag then
				local physics = tr.Entity:GetPhysicsObject()
				
				if IsValid(physics) then
					physics:EnableMotion(false)
				end
			end
			
			if cfg.blacklistedFadingDoorMats_punishment > 0 then
				local toolgun = ply:GetTool(tool)
				if cfg.blacklistedFadingDoorMats[toolgun:GetClientInfo("mat")] then 
					if cfg.blacklistedFadingDoorMats_punishment == 1 then
						gProtect.NotifyStaff(ply, "attempted-blacklistedmaterial")
					elseif cfg.blacklistedFadingDoorMats_punishment == 2 then
						slib.punish(ply, 1, gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "attempted-blacklistedmaterial", ply:Nick()))
					elseif cfg.blacklistedFadingDoorMats_punishment == 3 then
						slib.punish(ply, 2, gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "attempted-blacklistedmaterial", ply:Nick()))
					end
				return false end
			end
		end

		if cfg.precisionMoveFix and tool == "precision" then
			local plyTool = ply:GetTool()

			if plyTool.Name == "#Precision" then
				local cur_mode = plyTool:GetClientNumber("mode")

				if cur_mode == 3 then
					plyTool.gPOldToggleColor = plyTool.gPOldToggleColor or plyTool.ToggleColor
					plyTool.gPOldThink = plyTool.gPOldThink or plyTool.Think
					plyTool.gPOldDoMove = plyTool.gPOldDoMove or plyTool.DoMove

					plyTool.Think = function()
						if cfg.precisionMoveFix then
							local mode = plyTool:GetClientNumber("mode")

							if mode == 3 then return end // Prevent following entity realtime.
						end

						plyTool.gPOldThink(plyTool)
					end

					plyTool.DoMove = function()
						plyTool.gPOldDoMove(plyTool)

						if !cfg.precisionMoveFix then return end
						
						if ghostingEnabled and plyTool.GetPhys then
							local Phys1 = plyTool:GetPhys(1)
							local Phys1_ent = IsValid(Phys1) and Phys1:GetEntity()
							
							local oldCollision = Phys1:IsCollisionEnabled()

							Phys1:EnableCollisions(false)

							timer.Simple(0, function()
								local ghosted

								if IsValid(Phys1_ent) then
									if gProtect.GhostHandler(Phys1_ent, false) then
										ghosted = true
									end
								end

								if ghosted then
									if plyTool and plyTool.SetStage then
										plyTool:SetStage(0)
									end
								end

								Phys1:EnableCollisions(oldCollision)
							end)
						end
					end

					plyTool.ToggleColor = function(...)
						if SERVER and cfg.precisionMoveFix then return end // Realm mismatch to fix bugged if ghosted.

						plyTool.gPOldToggleColor(...)
					end
				end
			end
		end
	end
	
	return true
end

hook.Add("PhysgunDrop", "gP:MiscDisableMotion", function(ply, ent)
	if cfg.enabled and cfg.DisableMotion and IsValid(ent) and cfg.DisableMotionEntities[ent:GetClass()] then
		local physics = ent:GetPhysicsObject()

		if IsValid(physics) then
			physics:EnableMotion(false)
		end
	end
end)

hook.Add("OnEntityCreated", "gP:MiscHandeler", function(ent) 
	if cfg.enabled and cfg.DisableMotion and IsValid(ent) and cfg.DisableMotionEntities[ent:GetClass()] then
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			
			local physics = ent:GetPhysicsObject()

			if IsValid(physics) then
				physics:EnableMotion(false)
			end
		end)
	end
end)

hook.Add("gP:CanEnableMotion", "gP:PreventEnableMotion", function(phys, bool)
	if IsValid(phys) then
		local ent = phys:GetEntity()
		if bool and IsValid(ent) and cfg.enabled and cfg.DisableMotion and cfg.DisableMotionEntities[ent:GetClass()] then
			return false
		end
	end
end)

hook.Add("CanPlayerUnfreeze", "gP:StopMotion", function(ply, ent)
	if cfg.enabled and cfg.DisableMotion and cfg.DisableMotionEntities[ent:GetClass()] then
		return false
	end
end)

hook.Add("PlayerSpawnProp", "gP:PreventSpawningTooClose", function(ply, model)
	if cfg.enabled then
		if cfg.preventSpawnNearbyPlayer <= 0 then return nil end
		local vStart = ply:GetShootPos()
		local vForward = ply:GetAimVector()

		local trace = {}
		trace.start = vStart
		trace.endpos = vStart + ( vForward * 2048 )
		trace.filter = ply

		local tr = util.TraceLine( trace )

		local sphere = ents.FindInSphere(tr.HitPos, cfg.preventSpawnNearbyPlayer)
		
		for k,v in pairs(sphere) do
			if IsValid(v) and v:IsPlayer() then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "spawn-to-close"), ply) return false end
		end
	end

	return nil
end)

hook.Add("playerBoughtCustomEntity", "gP:HandleOwnershipForcing", function(ply, enttbl, ent, price)
	if !IsValid(ent) then return end
	
	if cfg.DRPEntForceOwnership[ent:GetClass()] then
		gProtect.SetOwner(ply, ent)

		if ent.Getowning_ent then
			ent:Setowning_ent(ply)
		end
	end

	if cfg.DRPMaxObstructsOnPurchaseEnts then
		local obscurants = gProtect.obscureDetection(ent)

		local hits = 0

		if obscurants and istable(obscurants) then
			for k,v in ipairs(obscurants) do
				if cfg.DRPObstructsFilter == 1 then
					if v.DarkRPItem then
						hits = hits + 1
					end
				elseif cfg.DRPObstructsFilter == 2 then
					if propEnts[v:GetClass()] then
						hits = hits + 1
					end
				end
			end
		end

		if hits >= cfg.DRPMaxObstructsOnPurchaseEnts then
			ent:Remove()
			ply:addMoney(price)
			slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "too_many_obstructs_purchase"), ply)
		end
	end
end)

hook.Add("gP:NumpadRegistered", "gP:FadingDoorStopper", function(name, func)
	if name == "Fading Door onUp" or name == "Fading Door onDown" then
		local function newfunc(ply, ent)
			if cfg.preventFadingDoorAbuse and IsValid(ent) and ent.fadeActive then
				local obscurants = gProtect.obscureDetection(ent)
				local prevent = false

				if obscurants and istable(obscurants) then
					for k,v in pairs(obscurants) do
						if v:IsPlayer() then prevent = true break end
					end
				end

				if prevent then return end
			end

			func(ply, ent)

			if IsValid(ent) then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
			end
		end

		return newfunc
	end
end)

local setTimer = cfg.ClearDecals

local function gPClearDecals()
	if !cfg.enabled or !cfg.ClearDecals then return end
	if setTimer <= 0 then return end
	
	for k,v in pairs ( player.GetAll() ) do
		v:ConCommand( "r_cleardecals" )
	end
		
	if setTimer ~= cfg.ClearDecals then
		setTimer = cfg.ClearDecals
		timer.Adjust( "gP:onclearDecalsTimer", setTimer, 0, function()
			gPClearDecals()
		end)
	end
end

timer.Create("gP:onclearDecalsTimer", isnumber(setTimer) and setTimer or 120, 0, function()
	gPClearDecals()
end )

hook.Add("gP:ConfigUpdated", "gP:UpdateMiscs", function(updated)
	if updated ~= "miscs" and updated ~= "general" and update ~= "ghosting" then return end
	cfg = gProtect.getConfig(nil, "miscs")
	blacklist = gProtect.getConfig("blacklist", "general")
	ghostingEnabled = gProtect.getConfig("enabled", "ghosting")
end)