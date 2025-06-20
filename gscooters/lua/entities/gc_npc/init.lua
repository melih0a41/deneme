AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include("shared.lua")

local tCooldowns = {}
local iTimeout = 0.5
local function GC_SpamCheck(sNetMessage, pPlayer)
    tCooldowns[pPlayer] = tCooldowns[pPlayer] or {}
    tCooldowns[pPlayer][sNetMessage] = tCooldowns[pPlayer][sNetMessage] or nil

    if not tCooldowns[pPlayer][sNetMessage] then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    end
    
    if CurTime() - tCooldowns[pPlayer][sNetMessage] >= iTimeout then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    else
		return false
    end
end

function ENT:Initialize()
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
end

function ENT:Use(pPlayer)
	if not GC_SpamCheck("GC_NPC", pPlayer) then return end

    if pPlayer:Team() == TEAM_MARTI then -- Use = true
        pPlayer.GC_LastUse = {CurTime(), self}

        net.Start("gScooters.Net.OpenRetrieverUI")
        net.Send(pPlayer)
    else
        gScooters:ChatMessage(gScooters:GetPhrase("wrong_job"), pPlayer)
    end
end
