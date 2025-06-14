-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local bypassSpamBlockEnts = {
	["gmod_wire_expression2"] = true
}

local function EntitySpawnControl(ply, spawnHook, arg2)
	
	if !ply:z_anticrashGetCanSpawnGlobal() or !ply:z_anticrashGetCanSpawn(spawnHook) then
		return false
	end

	if isstring(arg2) and SH_ANTICRASH.SETTINGS.BLOCKEDENTITIES[arg2] then
		return false
	end
	
	if SH_ANTICRASH.SETTINGS.BLOCKSPAMMERS then
		
		if istable(arg2) and isentity(arg2.Entity) and bypassSpamBlockEnts[arg2.Entity:GetClass()] then return end
	
		local lastSpawn = ply.__lastSpawnedTime or 0
		local interval = CurTime() - lastSpawn
		local isAdvDupe = (ply.AdvDupe2 or {}).Pasting
		
		if interval > 0.001 and interval < SH_ANTICRASH.SETTINGS.BLOCKSPAMMERDELAY and !isAdvDupe then
			return false
		end
		
	end

end

for i=1, #SH_ANTICRASH.VARS.HOOKS.SPAWN do
	
	local spawnHook = SH_ANTICRASH.VARS.HOOKS.SPAWN[i]
	
	hook.Add(spawnHook,"sv_anticrash_EntitySpawnControl",function(ply, arg2)
	
		return EntitySpawnControl(ply, spawnHook, arg2)
		
	end)
	
end

local FaultyNPCs = {
	["npc_stalker"] = true,
	["npc_clawscanner"] = true,
	["npc_cscanner"] = true
}

local function ControlNPCSpawns(ply, npc_type, weapon )
	
	if SH_ANTICRASH.SETTINGS.FIXNPCSEGMENTATIONCRASH then
		if FaultyNPCs[npc_type] then
			return false
		end
	end

end
hook.Add("PlayerSpawnNPC","sv_anticrash_ControlNPCSpawns",ControlNPCSpawns)

local function ControlObjectSpawns(ply, model, skin)

	if SH_ANTICRASH.SETTINGS.BLOCKINVALIDMODELS then
		if !util.IsValidModel(model) then
			return false
		end
	end
	
end
hook.Add("PlayerSpawnObject","sv_anticrash_ControlObjectSpawns",ControlObjectSpawns)


util.AddNetworkString("sv_anticrash_SetCanSpawnGlobal")
local function SetCanSpawnGlobal(len, ply)
	
	if !SH_ANTICRASH.HasAccess(ply,"users") then return end
	
	local target = net.ReadEntity()
	local enabled = net.ReadBool()
	
	if IsValid(target) and target:IsPlayer() then
		target:z_anticrashSetCanSpawnGlobal(enabled)
	end
		
	local plyFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
	local targetFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(target)
	
	local consolePrint = "##enabledSpawningCapabilities"
	local plyPrint = "##youEnabledSpawnAbility"
	local targetPrint = "#enabledSpawnAbility"
	
	if !enabled then
		consolePrint = "##disabledSpawningCapabilities"
		plyPrint = "##youDisabledSpawnAbility"
		targetPrint = "#disabledSpawnAbility"
	end
	
	SH_ANTICRASH.UTILS.LOG.Print(consolePrint.." %"..plyFormat.." %"..targetFormat)
	SH_ANTICRASH.UTILS.LOG.ChatPrint(target,ply:Nick().." "..targetPrint)
		
	if ply ~= target then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,plyPrint.." %"..target:Nick())
	end

end
net.Receive("sv_anticrash_SetCanSpawnGlobal",SetCanSpawnGlobal)