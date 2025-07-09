/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

AddCSLuaFile()
include("sh_ztm_config.lua")
AddCSLuaFile("sh_ztm_config.lua")

TOOL.Category = "Zeros Trashman"
TOOL.Name = "#TrashSpawner"
TOOL.Command = nil


if (CLIENT) then
	language.Add("tool.ztm_trashspawner.name", "Zeros Trashman - Trash Spawner")
	language.Add("tool.ztm_trashspawner.desc", "LeftClick: Creates a Trash Spawnpoint. \nRightClick: Removes a Trash Spawnpoint.")
	language.Add("tool.ztm_trashspawner.0", "LeftClick: Creates a Trash Spawn.")
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function TOOL:LeftClick(trace)
	local trEnt = trace.Entity

	if trEnt:IsPlayer() then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

	if (CLIENT) then return end
	if (trEnt:GetClass() == "worldspawn") or trEnt == Entity(0) then

		if trace.Hit and trace.HitPos and zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	       ztm.Trash.AddSpawnPos(trace.HitPos,self:GetOwner())
	    end

		return true
	else
		return false
	end
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

	if trace.Hit and trace.HitPos then

		if zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) then

	       ztm.Trash.RemoveSpawnPos(trace.HitPos,self:GetOwner())
	    end

		return true
	else
		return false
	end
end

function TOOL:Deploy()
	if SERVER then
		if zclib.Player.IsAdmin(self:GetOwner()) == false then return end

		ztm.Trash.ShowAll(self:GetOwner())
	end
end

function TOOL:Holster()
	if SERVER then
		ztm.Trash.HideAll(self:GetOwner())
	end
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.ztm_trashspawner.name",
		Description = "#tool.ztm_trashspawner.desc"
	})

	CPanel:AddControl("label", {
		Text = "Saves all the Trash points that are currently on the Map"
	})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	CPanel:Button("Save Trash points", "ztm_trash_save")

	CPanel:AddControl("label", {
		Text = " "
	})
	CPanel:AddControl("label", {
		Text = "Removes all the Trash points that are currently on the Map"
	})

	CPanel:Button("Remove all Trash points", "ztm_trash_remove")
end
