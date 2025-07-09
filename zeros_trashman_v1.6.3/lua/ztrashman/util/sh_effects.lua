/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ztm = ztm or {}
ztm.Effects = ztm.Effects or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

local effects = {"ztm_trash_break01","ztm_trash_break02","ztm_trash_break03"}
function ztm.Effects.Trash(pos,ent)
	zclib.Effect.ParticleEffect(effects[ math.random( #effects ) ],pos, angle_zero, ent or Entity(1))
	if IsValid(ent) then ent:EmitSound("ztm_trash_break") end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

zclib.NetEvent.AddDefinition("ztm_leafpile_fx", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	if zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1500) == false then return end
	ent:EmitSound("ztm_leafpile_explode01")
	zclib.Effect.ParticleEffect("ztm_leafpile_explode", ent:GetPos(), ent:GetAngles(), ent)
end)

zclib.NetEvent.AddDefinition("ztm_trashcollector_primary_fx", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local SwepOwner = received[1]
	if not IsValid(SwepOwner) then return end
	if zclib.util.InDistance(LocalPlayer():GetPos(), SwepOwner:GetPos(), 500) == false then return end
	local swep = SwepOwner:GetActiveWeapon()
	if not IsValid(swep) then return end
	if swep:GetClass() ~= "ztm_trashcollector" then return end

	if LocalPlayer() == SwepOwner then
		local ve = GetViewEntity()

		if ve:GetClass() ~= "player" then
			zclib.Effect.ParticleEffectAttach("ztm_air_burst", PATTACH_POINT_FOLLOW, swep, 1)
		end
	else
		zclib.Effect.ParticleEffectAttach("ztm_air_burst", PATTACH_POINT_FOLLOW, swep, 1)
	end
end)
