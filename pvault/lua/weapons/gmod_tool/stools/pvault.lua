TOOL.Category = "pVault"
TOOL.Name = "#tool.pvault.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
} 

local currentEnt
local trace
local plyAngle
local rotation = 0
local offset = {
	["pvault_standalone_small"] = function(ent) return Vector(0, 0, 10.5) end,
	["pvault_standalone_large"] = function(ent) return Vector(0, 0, 19) end,
	["pvault_standalone_tall"] = function(ent) return Vector(0, 0, 37) end,
	["pvault_wall_large"] = function(ent) return ent:GetForward()*-15 end,
	["pvault_wall_small"] = function(ent) return ent:GetForward()*-8 end,
	["pvault_wall_tall"] = function(ent) return ent:GetForward()*-9 end,
	["pvault_stack_gold"] = function(ent) return Vector(0, 0, 0.5) end,
}

if CLIENT then
	language.Add("tool.pvault.name", "Enitity Creation")
	language.Add("tool.pvault.desc", "Used to place all pVault entities.")

    language.Add("tool.pvault.left", "Place the configured entity.")
    language.Add("tool.pvault.right", "Open the menu to configure an entity.")
    language.Add("tool.pvault.reload", "Remove the entity permanently (Concomand: pvault_remove_ent)")
end


local cooldown = 0
function TOOL:LeftClick(trace)
	if SERVER then return end
	if not perfectVault.Core.Access(LocalPlayer()) then return end
	if not perfectVault.UI.CurrentConfigSettings.entity then
		perfectVault.Core.Msg(perfectVault.Translation.ToolGun.NoEntity)
		return
	end

	if cooldown > CurTime() then return end
	cooldown = CurTime() + 1

	plyAngle = LocalPlayer():GetAngles()
	net.Start("pvault_config_create_entity")
		net.WriteString(perfectVault.UI.CurrentConfigSettings.entity)
		net.WriteTable(perfectVault.UI.CurrentConfigSettings.settings)
		net.WriteVector(trace.HitPos + plyAngle:Forward() + plyAngle:Up() + (offset[perfectVault.UI.CurrentConfigSettings.entity] and offset[perfectVault.UI.CurrentConfigSettings.entity](currentEnt) or Vector(0, 0, 0)))
		net.WriteAngle(Angle(0, math.Round(plyAngle.y/10)*10 + 180, plyAngle.z))
	net.SendToServer()
end

function TOOL:RightClick(trace)
	if SERVER then return end
	if not perfectVault.Core.Access(LocalPlayer()) then return end
	if cooldown > CurTime() then return end
	cooldown = CurTime() + 1
	perfectVault.UI.Config()
end

function TOOL:Reload(trace)
	if CLIENT then return end
	if not perfectVault.Core.Access(self:GetOwner()) then return end
	local entity = trace.Entity
	if not entity.DatabaseID then return end
	perfectVault.Database.DeleteEntityByID(entity.DatabaseID)
	entity:Remove()
end

concommand.Add("pvault_remove_ent", function(ply)
	if CLIENT then return end
	if not perfectVault.Core.Access(ply) then return end
	local entity = ply:GetEyeTrace().Entity
	if not entity.DatabaseID then return end
	perfectVault.Database.DeleteEntityByID(entity.DatabaseID)
	entity:Remove()
end)

function TOOL:Think()
	if SERVER then return end
	if not perfectVault.Core.Access(LocalPlayer()) then return end
	if not perfectVault.UI.CurrentConfigSettings.entity then return end

	if not IsValid(currentEnt) then
		currentEnt = ents.CreateClientProp()
		currentEnt:SetModel(perfectVault.Core.Entites[perfectVault.UI.CurrentConfigSettings.entity].model)
		currentEnt:Spawn()
	end
	if not (currentEnt:GetModel() == perfectVault.Core.Entites[perfectVault.UI.CurrentConfigSettings.entity].model) then
		currentEnt:SetModel(perfectVault.Core.Entites[perfectVault.UI.CurrentConfigSettings.entity].model)
	end
	trace = LocalPlayer():GetEyeTrace()
	plyAngle = LocalPlayer():GetAngles()
	currentEnt:SetPos(trace.HitPos + plyAngle:Forward() + plyAngle:Up() + (offset[perfectVault.UI.CurrentConfigSettings.entity] and offset[perfectVault.UI.CurrentConfigSettings.entity](currentEnt) or Vector(0, 0, 0)))
	currentEnt:SetAngles(Angle(0, math.Round(plyAngle.y/10)*10 + 180, plyAngle.z))
end

function TOOL:Holster()
	if currentEnt then
		currentEnt:Remove()
		currentEnt = nil
	end
end

local darBack = Color(0, 0, 0, 240)
local red = Color(200, 0, 0)
function TOOL:DrawHUD()
	if not FPP then return end
	
	local ent = self.Owner:GetEyeTrace().Entity
	if not IsValid(ent) then return end
	if not perfectVault.Core.Entites[ent:GetClass()] then return end
	if FPP.canTouchEnt(self.Owner:GetEyeTrace().Entity, "Toolgun") then return end
	
	draw.RoundedBox(0, 0, ScrH()*0.5-50, ScrW(), 100, darBack)
	draw.SimpleText(perfectVault.Translation.ToolGun.DeletePermissions, "_pvault_derma_small", ScrW()*0.5, ScrH()*0.5, red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(perfectVault.Translation.ToolGun.FPPCheck, "_pvault_derma_smaller", ScrW()*0.5, ScrH()*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end