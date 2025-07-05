/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
zpiz.Player = zpiz.Player or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

// Does the player have the correctjob
function zpiz.Player.IsPizzaChef(ply)
	if zpiz.config.Jobs and table.Count(zpiz.config.Jobs) > 0 then
		if zpiz.config.Jobs[zclib.Player.GetJob(ply)] then
			return true
		else
			return false
		end
	else
		return true
	end
end

function zpiz.Player.CanInteract(ply,ent)
	if zpiz.Player.IsPizzaChef(ply) == false then return false end
	if zpiz.config.EquipmentSharing then return true end
	if ent.IsPublicEntity then return true end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599

	if zclib.Player.IsOwner(ply, ent) then
		return true
	else
		return false
	end
end

function zpiz.Player.GetNearPizzaChef(ent)
	local cook = false
	// 872185854
	for k, v in pairs(zclib.Player.List) do
		if not IsValid(v) then continue end
		if not v:IsPlayer() then continue end
		if not v:Alive() then continue end
		if zclib.util.InDistance(v:GetPos(), ent:GetPos(), 300) == false then continue end
		if zpiz.Player.CanInteract(v,ent) then
			cook = v
			break
		end
	end
	return cook
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

// Returns how many valid ingredients the player has currently spawned
function zpiz.Player.ReachedIngredientLimit(ply)
	ply.zpiz_SpawnedIngredients = ply.zpiz_SpawnedIngredients or {}

	local count = 0
	for k,v in pairs(ply.zpiz_SpawnedIngredients) do
		if IsValid(v) then
			count = count + 1
		end
	end
	return count >= zpiz.config.Ingredient.Limit
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599
