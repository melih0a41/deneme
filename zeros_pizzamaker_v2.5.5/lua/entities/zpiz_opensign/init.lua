/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

function ENT:Initialize()
	zpiz.Sign.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

function ENT:AcceptInput(input, activator, caller, data)
	if string.lower(input) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zpiz.Sign.OnUse(self, activator)
	end
end

function ENT:OnTakeDamage(dmg)
	zpiz.Sign.TakeDamage(self, dmg)
end

function ENT:OnRemove()
	zpiz.Sign.OnRemove(self)
end
