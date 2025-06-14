-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local function NotififyPlayers(ply,count,countStr,actionStr,noFoundStr)
	
	if count > 0 then
	
		local actionStr = actionStr or "##removedAllEntName"
		local plyFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
		local plyNick = SH_ANTICRASH.UTILS.LOG.GetNick(ply)
		
		SH_ANTICRASH.UTILS.LOG.ServerPrint(actionStr.." %"..plyFormat.." %"..countStr.." %"..count)
		SH_ANTICRASH.UTILS.LOG.ChatPrintAll(actionStr.." %"..plyNick.." %"..countStr.." %"..count) 
		
	else
		noFoundStr = noFoundStr or ("##noEntNameFound %"..countStr)
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,noFoundStr)
		
		if !IsValid(ply) then
			SH_ANTICRASH.UTILS.LOG.ServerPrint(noFoundStr)
		end
		
	end
	
end

local cleanupAlliases = {
	["props"] = {
		["duplicates"] = true,
		["AdvDupe2"] = true
	}
}

function SV_ANTICRASH.DefaultCleanup(p,cleanupType)

	local cleanupList = cleanup.GetList()
	local totalCount = 0
	
	for key, ply in pairs( cleanupList ) do

		for type, typeTbl in pairs( ply ) do

			if type == cleanupType or (cleanupAlliases[cleanupType] or {})[type] then

				for _, ent in pairs( typeTbl ) do
				
					if IsValid(ent) then
						ent:Remove()
						totalCount = totalCount + 1
					end
					
				end
				
				table.Empty( typeTbl )
				
			end

		end

	end
	
	NotififyPlayers(p,totalCount,'$'..cleanupType)
	
end

local cleanupFuncTbl = {
	
	["resetmap"] = function(ply)
	
		SV_ANTICRASH.CleanMap(true,true)
	
		local str = "#resetTheMap"
		
		SH_ANTICRASH.UTILS.LOG.PlyPrint(ply,str)
		
		local plyNick = SH_ANTICRASH.UTILS.LOG.GetNick(ply)
		SH_ANTICRASH.UTILS.LOG.ChatPrintAll(plyNick.." "..str)
		
	end,
	
	["removeall"] = function(ply)
		local _, count = SV_ANTICRASH.RemoveEntities(true,true)
		NotififyPlayers(ply,count,"#entitiesLowCase",nil,"#noEntitiesFound")
	end,
	
	["freezeall"] = function(ply)
		local count = SV_ANTICRASH.FreezeEntities(true)
		NotififyPlayers(ply,count,"#entitiesLowCase","##freezeAllEnts","#noUnfrozenEntsFound")
	end,
	
	["nocollideall"] = function(ply)
		local count = SV_ANTICRASH.NoCollideEntities(true)
		NotififyPlayers(ply,count,"#entitiesLowCase","##noCollideAllEnts","#noUnCollidedEntsFound")
	end

}
SV_ANTICRASH.CMD.RegisterCMD("resetmap","#resetMap",cleanupFuncTbl.resetmap)
SV_ANTICRASH.CMD.RegisterCMD("removeall","#removeEntities",cleanupFuncTbl.removeall)
SV_ANTICRASH.CMD.RegisterCMD("freezeall","#freezeEntities",cleanupFuncTbl.freezeall)
SV_ANTICRASH.CMD.RegisterCMD("nocollideall","#noCollideEntities",cleanupFuncTbl.nocollideall)

util.AddNetworkString("sv_anticrash_GlobalCleanup")
local function GlobalCleanup(len, ply)
	
	if !SH_ANTICRASH.HasAccess(ply,"global") then return end

	local cleanupType = net.ReadString()
	
	-- Someone reported an error here (very strange)
	if !SH_ANTICRASH.VARS.CLEANUP.TYPESBYKEY[cleanupType] then
		local errorStr = "ERROR GlobalCleanup type '"..cleanupType.."' not found!"
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,errorStr)
		SH_ANTICRASH.UTILS.LOG.ServerPrint(errorStr)
		return
	end
	
	local isDefault = SH_ANTICRASH.VARS.CLEANUP.TYPESBYKEY[cleanupType].isDefault
	
	if isDefault then
		SV_ANTICRASH.DefaultCleanup(ply,cleanupType)
	else
		cleanupFuncTbl[cleanupType](ply)
	end

end
net.Receive("sv_anticrash_GlobalCleanup",GlobalCleanup)