/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.Player = zmlab2.Player or {}

function zmlab2.Player.IsMethCook(ply)
    if BaseWars then return true end
	if zmlab2.config.Jobs == nil then return true end
	if table.Count(zmlab2.config.Jobs) <= 0 then return true end

	if zmlab2.config.Jobs[zclib.Player.GetJob(ply)] then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function zmlab2.Player.IsMethSeller(ply)
    if BaseWars then return true end
	if zmlab2.config.SellJobs == nil then return true end
	if table.Count(zmlab2.config.SellJobs) <= 0 then return true end

	if zmlab2.config.SellJobs[zclib.Player.GetJob(ply)] then
		return true
	else
		return false
	end
end

// Returns the dropoff point if the player has one assigned
function zmlab2.Player.GetDropoff(ply)
	return ply.zmlab2_Dropoff
end

// Does the player has meth?
function zmlab2.Player.HasMeth(ply)
	if (ply.zmlab2_MethList and #ply.zmlab2_MethList > 0) then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function zmlab2.Player.OnMeth(ply)
	if ply.zmlab2_MethDuration and ply.zmlab2_MethStart and (ply.zmlab2_MethDuration + ply.zmlab2_MethStart) > CurTime() then
		return true
	else
		return false
	end
end

// Checks if the player is allowed to interact with the entity
function zmlab2.Player.CanInteract(ply, ent)
    if zmlab2.Player.IsMethCook(ply) == false then
        zclib.Notify(ply, zmlab2.language["Interaction_Fail_Job"], 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

        return false
    end

    if zmlab2.config.SharedEquipment == true then
        return true
    else
        // Is the entity a public entity?
        if ent.IsPublic == true then return true end

		if FPP and FPP.plyCanTouchEnt(ply, ent, "Physgun") then
			return true
		end

        if zclib.Player.IsOwner(ply, ent) then
            return true
        else
            zclib.Notify(ply, zmlab2.language["YouDontOwnThis"], 1)

            return false
        end
    end
end
