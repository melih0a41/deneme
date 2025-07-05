/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed

function ENT:Initialize()
	zpiz.CustomerTable.Initialize(self)
end

function ENT:OnRemove()
	zpiz.CustomerTable.OnRemove(self)
end

function ENT:StartTouch(other)
	zpiz.CustomerTable.Touch(self, other)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599
