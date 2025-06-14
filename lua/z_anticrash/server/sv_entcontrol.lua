-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SV_ANTICRASH.RemoveEntitiesFrom(ply)

	local entTbl = ents.GetAll()
	local count = 0
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		
		if ent:z_anticrashIsValidEnt() and ent:z_anticrashGetCreator() == ply then
			SafeRemoveEntity(ent)
			count = count + 1
		end
		
	end
	
	return count

end

function SV_ANTICRASH.FreezeEntitiesFrom(ply)

	local entTbl = ents.GetAll()
	local count = 0
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		
		if ent:z_anticrashIsValidEnt() and SH_ANTICRASH.CanFreeze(ent) and ent:z_anticrashGetCreator() == ply then
		
			if SV_ANTICRASH.UTILS.FreezeEntity(ent, true) then
				count = count + 1
			end
			
		end
		
	end
	
	return count

end

local ghostClassAllowed = {
	["prop_physics"] = true
}

function SV_ANTICRASH.SetGhostEntity(ent,bool)

	if !ghostClassAllowed[ent:GetClass()] then return end
	
	local col = ent:GetColor()
	
	if bool and !ent.__isGhosted then
		
		ent.__oldRenderMode = ent:GetRenderMode()
		ent.__oldColGroup = ent:GetCollisionGroup()
		ent.__isGhosted = true
		
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ent:DrawShadow(false)
		ent:SetColor(Color(col.r,col.g,col.b,150))
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
		-- Stacker color compatibility
		timer.Simple(0,function()
			if IsValid(ent) and ent.__isGhosted then
				local col = ent:GetColor()
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
				ent:SetColor(Color(col.r,col.g,col.b,150))
			end
		end)
	
	elseif !bool and ent.__isGhosted then
		
		ent.__isGhosted = false
		
		ent:SetRenderMode(ent.__oldRenderMode or RENDERMODE_NORMAL)
		ent:DrawShadow(true)
		ent:SetColor(Color(col.r,col.g,col.b,255))
		ent:SetCollisionGroup(ent.__oldColGroup or COLLISION_GROUP_NONE)
	end
	
end

function SV_ANTICRASH.SetPlayerCanSpawnEntities(ply,spawnHook,bool)
	
	spawnHook = spawnHook or '*'
	
	ply:z_anticrashSetCanSpawn(spawnHook,bool)

end

local function PrintResult(ply,target,count,plyTxt,targTxt,consoleTxt)
	
	if count == 0 then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,target:Nick().." #hasNoEntities")
		return
	end
	
	local plyFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
	local targetFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(target)
	
	SH_ANTICRASH.UTILS.LOG.Print(consoleTxt.." %"..plyFormat.." %"..count.." %"..targetFormat)
	SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,plyTxt.." %"..count.." %"..target:Nick())
	
	if ply ~= target then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(target,ply:Nick().." "..targTxt)
	end
	
end

util.AddNetworkString("sv_anticrash_RemoveEntitiesFrom")
local function RemoveEntitiesFrom(len, ply)
	
	if !SH_ANTICRASH.HasAccess(ply,"users") then return end
	
	local target = net.ReadEntity()
	
	if !IsValid(target) then return end
	
	local count = SV_ANTICRASH.RemoveEntitiesFrom(target)
	
	PrintResult(ply,target,count,"##youRemovedFrom","#removedYourObjects","##removedEntitiesFrom")

end
net.Receive("sv_anticrash_RemoveEntitiesFrom",RemoveEntitiesFrom)

util.AddNetworkString("sv_anticrash_FreezeEntitiesFrom")
local function FreezeEntitiesFrom(len, ply)
	
	if !SH_ANTICRASH.HasAccess(ply,"users") then return end
	
	local target = net.ReadEntity()
	
	if !IsValid(target) then return end
	
	local count = SV_ANTICRASH.FreezeEntitiesFrom(target)
	
	PrintResult(ply,target,count,"##youFrozeFrom","#frozeYourObjects","##frozeEntitiesFrom")

end
net.Receive("sv_anticrash_FreezeEntitiesFrom",FreezeEntitiesFrom)
