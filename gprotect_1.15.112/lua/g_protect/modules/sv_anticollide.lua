gProtect = gProtect or {}
gProtect.RegisteredCollide = gProtect.RegisteredCollide or {}

local cfg = gProtect.getConfig(nil, "anticollide")
local blacklist = gProtect.getConfig("blacklist", "general")
local collidedCounter = {}
local timeout = {}

hook.Add("playerBoughtCustomEntity", "gP:AntiColliderDarkRP", function(ply, enttable, ent)
	if cfg.enabled and cfg.protectDarkRPEntities > -1 then
		if !IsValid(ent) then return end
		local oldfunc = ent.PhysicsCollide
		local collThreshold = tonumber(cfg.specificEntities[ent:GetClass()] or cfg.DRPentitiesThreshold or 0)
		if collThreshold <= 0 then return end
		ent.PhysicsCollide = function(...)
			if isfunction(oldfunc) then oldfunc(...) end

			if cfg.enabled and cfg.protectDarkRPEntities > -1 then
				local args = {...}

				local collider = args[2].HitEntity

				if IsValid(collider) and IsValid(ent) then
					if cfg.DRPentitiesException == 1 then
						if gProtect.GetOwner(ent) ~= gProtect.GetOwner(collider) then return end
					elseif cfg.DRPentitiesException == 2 then
						if !IsValid(gProtect.GetOwner(collider)) then return end
					end

					if !timeout[ent] then timeout[ent] = CurTime() end
					collidedCounter[ent] = collidedCounter[ent] or 0
					collidedCounter[ent] = collidedCounter[ent] + 1
					if collidedCounter[ent] > collThreshold then
						hook.Run("gP:CollidedTooMuch", ply, ent)

						if cfg.notifyStaff then gProtect.NotifyStaff(ply, "colliding-too-much", 3, ent:GetClass(), collidedCounter[ent]) end
						timer.Simple(0, function()
							if !IsValid(ent) then return end

							if cfg.protectDarkRPEntities == 1 then
								gProtect.GhostHandler(ent, true, true, nil, true)

								timer.Simple(3, function()
									if !IsValid(ent) then return end
									gProtect.GhostHandler(ent, false, true, nil, true)
								end)
							elseif cfg.protectDarkRPEntities == 2 then
								local phys = ent:GetPhysicsObject()
								if IsValid(phys) then
									phys:EnableMotion(false)
								end
							elseif cfg.protectDarkRPEntities == 3 then
								ent:Remove()
							elseif cfg.protectDarkRPEntities == 4 then
								ent:Remove()

								if IsValid(ply) and !ent.refunded then
									ent.refunded = true
									ply:addMoney(enttable.price)
								end
							end
						end)
					end
					
					if CurTime() - timeout[ent] >= 1 then
						collidedCounter[ent] = 0
						timeout[ent] = nil
					end
				end
			end
		end
	end
end)

hook.Add("PlayerSpawnedProp", "gP:AntiColliderProp", function(ply, _, ent)
	if cfg.enabled and cfg.protectSpawnedProps > -1 then
		if !IsValid(ent) then return end
		
		local collThreshold = tonumber(cfg.specificEntities[ent:GetClass()] or cfg.propsThreshold or 0)
		if collThreshold <= 0 then return end

		ent:AddCallback( "PhysicsCollide", function(collider, data)
			if cfg.enabled and IsValid(collider) then
				local obstructs = gProtect.obscureDetection(collider)
				local colliders = {}
				
				local owner = gProtect.GetOwner(collider)
					
				if IsValid(owner) and cfg.playerPropAction > -1 and owner == gProtect.GetOwner(data.HitEntity) then
					owner.gp_curCollissions = owner.gp_curCollissions or 0
					owner.gp_curCollissions = owner.gp_curCollissions + 1

					owner.gp_curCollTimeout = owner.gp_curCollTimeout or CurTime() + 1

					if CurTime() >= owner.gp_curCollTimeout then
						owner.gp_curCollissions = 1
						owner.gp_curCollTimeout = CurTime() + 1
					end

					if owner.gp_curCollissions > cfg.playerPropThreshold then
						local owned_ents = gProtect.GetOwnedEnts(owner)

						hook.Run("gP:CollidedTooMuch", ply, ent)

						if cfg.notifyStaff then gProtect.NotifyStaff(ply, "props-colliding-too-much", 3, owner.gp_curCollissions) end

						timer.Simple(0, function()
							if cfg.playerPropAction == 1 then
								for k,v in pairs(owned_ents) do
									gProtect.GhostHandler(k, true, nil, nil, true)
								end
							elseif cfg.playerPropAction == 2 then
								for k,v in pairs(owned_ents) do
									if !IsValid(k) then continue end
									local phys = k:GetPhysicsObject()
									if IsValid(phys) then
										phys:EnableMotion(false)
									end
								end
							elseif cfg.playerPropAction == 3 then						
								for k,v in pairs(owned_ents) do
									if !IsValid(k) then continue end
									k:Remove()
								end
							elseif cfg.playerPropAction == 4 then
								for k,v in pairs(owned_ents) do
									gProtect.GhostHandler(k, true, true, nil, true)
								end

								timer.Simple(3, function()
									for k,v in pairs(owned_ents) do
										gProtect.GhostHandler(k, false, true, nil, true)
									end
								end)
							end
						end)

						owner.gp_curCollissions = 1
					end
				end

				if cfg.protectSpawnedProps > -1 then
					if cfg.propsException == 1 then
						for k,v in ipairs(obstructs) do
							if owner == gProtect.GetOwner(v) then table.insert(colliders, v) end
						end
					elseif cfg.propsException == 2 then
						for k,v in ipairs(obstructs) do
							if IsValid(gProtect.GetOwner(v)) then table.insert(colliders, v) end
						end
					else
						colliders = obstructs
					end

					table.insert(colliders, collider)

					if !timeout[collider] then timeout[collider] = CurTime() end
					collidedCounter[collider] = collidedCounter[collider] or 0
					collidedCounter[collider] = collidedCounter[collider] + 1
					if collidedCounter[collider] > collThreshold then
						hook.Run("gP:CollidedTooMuch", ply, ent)
						
						if cfg.notifyStaff then gProtect.NotifyStaff(ply, "colliding-too-much", 3, collider:GetClass(), collidedCounter[collider]) end

						timer.Simple(0, function()
							if !IsValid(collider) then return end

							if cfg.protectSpawnedProps == 1 then
								for k,v in ipairs(colliders) do
									if !IsValid(v) or !IsValid(v:GetPhysicsObject()) or v:IsPlayer() then continue end

									gProtect.GhostHandler(v, true, nil, nil, true)
								end
							elseif cfg.protectSpawnedProps == 2 then
								for k,v in ipairs(colliders) do
									local phys = v:GetPhysicsObject()
									if IsValid(phys) then
										phys:EnableMotion(false)
									end
								end
							elseif cfg.protectSpawnedProps == 3 then						
								for k,v in ipairs(colliders) do
									v:Remove()
								end
							elseif cfg.protectSpawnedProps == 4 then
								for k,v in ipairs(colliders) do
									if !IsValid(v) or !IsValid(v:GetPhysicsObject()) or v:IsPlayer() then continue end

									gProtect.GhostHandler(v, true, true, nil, true)

									timer.Simple(3, function()
										for k,v in ipairs(colliders) do
											if !IsValid(v) or !IsValid(v:GetPhysicsObject()) or v:IsPlayer() then continue end

											gProtect.GhostHandler(v, false, true, nil, true)
										end
									end)
								end
							end
						end)
					end
					
					if CurTime() - timeout[collider] >= 1 then
						collidedCounter[collider] = 0
						timeout[collider] = nil
					end
				end
			end
		end )
	end
end)

local registerSENT = function(ply, ent)
	if cfg.enabled and cfg.protectSpawnedEntities > -1 then
		if !IsValid(ent) or gProtect.RegisteredCollide[ent] then return end

		local class = ent:GetClass()

		if gProtect.PropClasses[class] then return end

		gProtect.RegisteredCollide[ent] = true

		local oldfunc = ent.PhysicsCollide
		local collThreshold = tonumber(cfg.specificEntities[class] or cfg.entitiesThreshold or 0)
		if collThreshold <= 0 then return end

		ent.PhysicsCollide = function(...)
			if isfunction(oldfunc) then oldfunc(...) end
			
			if cfg.enabled and cfg.protectSpawnedEntities > -1 then
				local args = {...}

				local collider = args[2].HitEntity

				if IsValid(collider) and IsValid(ent) then					
					if cfg.entitiesException == 1 then
						if gProtect.GetOwner(ent) ~= gProtect.GetOwner(collider) then return end
					elseif cfg.entitiesException == 2 then
						if !IsValid(gProtect.GetOwner(collider)) then return end
					end

					if !timeout[ent] then timeout[ent] = CurTime() end
					collidedCounter[ent] = collidedCounter[ent] or 0
					collidedCounter[ent] = collidedCounter[ent] + 1

					if collidedCounter[ent] > collThreshold then
						hook.Run("gP:CollidedTooMuch", ply, ent)

						if cfg.notifyStaff then gProtect.NotifyStaff(ply, "colliding-too-much", 3, class, collidedCounter[ent]) end
						timer.Simple(0, function()
							if !IsValid(ent) then return end

							if cfg.protectSpawnedEntities == 1 then
								gProtect.GhostHandler(ent, true, nil, nil, true)
							elseif cfg.protectSpawnedEntities == 2 then
								local phys = ent:GetPhysicsObject()
								if IsValid(phys) then
									phys:EnableMotion(false)
								end
							elseif cfg.protectSpawnedEntities == 3 then
								ent:Remove()
							end
						end)
					end

					if CurTime() - timeout[ent] >= 1 then
						collidedCounter[ent] = 0
						timeout[ent] = nil
					end
				end
			end
		end
	end
end

hook.Add("gP:UndoAdded", "gP:AntiColliderToolgun", registerSENT)
hook.Add("PlayerSpawnedSENT", "gP:AntiColliderEntities", registerSENT)

hook.Add("gP:ConfigUpdated", "gP:UpdateAntiCollide", function(updated)
	if updated ~= "anticollide" and updated ~= "general" then return end
	blacklist = gProtect.getConfig("blacklist", "general")
	cfg = gProtect.getConfig(nil, "anticollide")
end)