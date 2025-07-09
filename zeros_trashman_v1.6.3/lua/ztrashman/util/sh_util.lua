/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ztm = ztm or {}
ztm.util = ztm.util or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ztm.Print(msg)
	print("[Zero´s Trashman] " .. msg)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

if (CLIENT) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function ztm.util.UpdateEntityVisuals(ent)
		if zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1000) then

			local curDraw = CurTime()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then
				//print("Entity: " .. ent:EntIndex() .. " , Call UpdateVisuals() at " .. math.Round(CurTime()))

				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end
end
