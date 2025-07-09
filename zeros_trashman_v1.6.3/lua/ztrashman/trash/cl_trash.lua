/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if SERVER then return end
ztm = ztm or {}
ztm.Trash = ztm.Trash or {}

function ztm.Trash.Initialize(Trash)
	zclib.EntityTracker.Add(Trash)
end

function ztm.Trash.Draw(Trash)
	if zclib.Convar.Get("zclib_cl_drawui") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), Trash:GetPos(), 500) and ztm.Player.IsTrashman(LocalPlayer()) then
		ztm.HUD.DrawTrash(Trash:GetTrash(),Trash:GetPos() + Vector(0, 0, 50))
	end
end

function ztm.Trash.OnRemove(Trash)
	ztm.Effects.Trash(Trash:GetPos(), nil)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

local function HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "ztm_trashspawner" and tool.Name == "#TrashSpawner" then
			return true
		else
			return false
		end
	else
		return false
	end
end

zclib.Hook.Add("PostDrawTranslucentRenderables", "ztm_trashspawner", function()
	if HasToolActive() then
		local tr = LocalPlayer():GetEyeTrace()

		if tr.Hit and not IsValid(tr.Entity) and zclib.util.InDistance(tr.HitPos, LocalPlayer():GetPos(), 300) then
			render.SetColorMaterial()
			render.DrawWireframeSphere(tr.HitPos, 1, 4, 4, ztm.default_colors["white01"], false)
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080
local Trash_Hints = {}

net.Receive("ztm_trash_showall", function(len)
	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	if positions then
		Trash_Hints = positions

		zclib.Hook.Remove("HUDPaint", "ztm_TrashHints")
		zclib.Hook.Add("HUDPaint", "ztm_TrashHints", function()
			if Trash_Hints and table.Count(Trash_Hints) > 0 then
				for k, v in pairs(Trash_Hints) do
					if v then
						local pos = v:ToScreen()
						local size = 10
						surface.SetDrawColor(ztm.default_colors["red02"])
						surface.DrawRect(pos.x - (size * wMod) / 2, pos.y - (size * hMod) / 2, size * wMod, size * hMod)
					end
				end
			end
		end)
	end
end)

net.Receive("ztm_trash_hideall", function(len)
	Trash_Hints = {}
	zclib.Hook.Remove("HUDPaint", "ztm_TrashHints")
end)
