AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
 
include("shared.lua");

function ENT:Initialize ( )
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:DrawShadow(true);
	self:SetUseType(SIMPLE_USE);
end

function ENT:AcceptInput( input, activator, caller )  
     if input == "Use" && activator:IsPlayer() then 
		SendUserMessage("VOTING_Confirm", activator)
     end  
end

function ENT:PhysgunPickup(ply, ent)
	return ply:IsSuperAdmin()
end

function ENT:CanTool(ply, trace, tool, ent)
	if ply:IsSuperAdmin() and tool == "remover" then
		self.CanRemove = true
		VOTING.Database.ClearNPC()
		VOTING.SendDarkRPNotice(ply, 2, 4, "NPC data has been cleared from this map.") 
		return true
	end
	return false
end

