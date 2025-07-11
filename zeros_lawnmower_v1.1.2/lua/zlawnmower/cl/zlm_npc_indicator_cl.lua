/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if SERVER then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

local icon_enabled = false
local icon_pos = Vector(0,0,0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

local zlm_LastThink = -1

hook.Add("Think", "a_zlm_Think_Indicator", function()
	if zlm_LastThink < CurTime() then

		if LocalPlayer():GetNWBool("zlm_InTractor") then

			if LocalPlayer():GetNWBool("zlm_HasTrailer") then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

				for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), zlm.config.NPC.SellDistance)) do
					if IsValid(v) and v:GetClass() == "zlm_buyer_npc" then
						icon_enabled = true
						icon_pos = v:GetPos() + v:GetUp() * 55
						break
					end
				end
			else
				icon_enabled = false
			end
		else
			icon_enabled = false
		end

		zlm_LastThink = CurTime() + 1
	end
end)

function zlm.f.SellIndicator()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and icon_enabled and zlm.f.InDistance(icon_pos, LocalPlayer():GetPos(), zlm.config.NPC.SellDistance) then
		local pos = icon_pos:ToScreen()
		draw.DrawText(zlm.language.General["SellGrass"] .. ": [ " .. string.upper(language.GetPhrase(input.GetKeyName(zlm.config.LawnMower.Keys.Unload))) .. " ]", "zlm_font01", pos.x, pos.y + 5, zlm.default_colors["white01"], TEXT_ALIGN_CENTER)
	end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

hook.Add("HUDPaint", "a_zlm_HUDPaint_SellIndicator", zlm.f.SellIndicator)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
