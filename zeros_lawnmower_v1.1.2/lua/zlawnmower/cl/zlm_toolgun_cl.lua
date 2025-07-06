/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if SERVER then return end
local wMod = ScrW() / 1920
local hMod = ScrH() / 1080
zlm = zlm or {}
zlm.f = zlm.f or {}

function zlm.f.ToolGun_HasToolActive()
    local ply = LocalPlayer()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

    if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
        local tool = ply:GetTool()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "zlm_grassspawner" and tool.Name == "#GrassSpawner" then
            return true
        else
            return false
        end
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

local iconSize = 10


function zlm.f.ToolGun_GrassIndicator2d()
    if zlm.f.ToolGun_HasToolActive() then
        local plyPos = LocalPlayer():GetPos()

        for k, v in pairs(zlm_GrassSpots) do
            local pos = v.pos:ToScreen()

            if zlm.f.InDistance(plyPos, v.pos, 100) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

            local size = iconSize
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            surface.SetDrawColor(zlm.default_colors["green04"])
            surface.DrawRect(pos.x - (size * wMod) / 2, pos.y - (size * hMod) / 2, size * wMod, size * hMod)
        end
    end
end

hook.Add("HUDPaint", "a_zlm_HUDPaint_ToolGun", zlm.f.ToolGun_GrassIndicator2d)
