/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.TentDoor = zmlab2.TentDoor or {}

function zmlab2.TentDoor.Initialize(TentDoor)
    TentDoor:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    TentDoor:UseClientSideAnimation()
    TentDoor:SetUseType(SIMPLE_USE)
    TentDoor:SetTrigger(true)
    TentDoor:DrawShadow(false)
    local phys = TentDoor:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    TentDoor.PhysgunDisabled = true
end

function zmlab2.TentDoor.CanInteract(TentDoor, ply)
    if TentDoor:GetIsPublic() == true then return false end

    if TentDoor:OnLockButton(ply) == false then return end

    if TentDoor:GetNextInteraction() > CurTime() then return end

    if zmlab2.config.SharedEquipment == true then
        return true
    else
        if FPP and FPP.plyCanTouchEnt(ply, TentDoor, "Physgun") then
            return true
        end

        if zclib.Player.IsOwner(ply, TentDoor) then
            return true
        else
            zclib.Notify(ply, zmlab2.language["YouDontOwnThis"], 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            return false
        end
    end
end

function zmlab2.TentDoor.OnUse(TentDoor, ply)
    if zmlab2.TentDoor.CanInteract(TentDoor, ply) ~= true then return end
    TentDoor:EmitSound("zmlab2_ui_click")
    TentDoor:SetIsLocked(not TentDoor:GetIsLocked())

    if TentDoor:GetIsLocked() then
        TentDoor:SetCollisionGroup(COLLISION_GROUP_NONE)
        TentDoor:SetTrigger(false)
    else
        TentDoor:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        TentDoor:SetTrigger(true)
    end
end


////////////////////////////////////////////
/////////// Lockpick Feature ///////////////
////////////////////////////////////////////
local function CanLockPick(ent, ply)
    if zmlab2.config.Lockpick == nil then return false end
    if zmlab2.config.Lockpick.Enabled ~= true then return false end
    if not IsValid(ent) then return false end
    if ent:GetClass() ~= "zmlab2_tent_door" then return false end
    if ent:GetIsLocked() == false then return false end
    if not IsValid(ply) then return false end
    if ply:IsPlayer() == false then return false end
    if ply:Alive() == false then return false end

    return true
end
zclib.Hook.Add("canLockpick", "zmlab2_TentDoor", function(ply, ent)
    if CanLockPick(ent,ply) then
        return true
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

zclib.Hook.Add("lockpickTime", "zmlab2_TentDoor", function(ply, ent)
    if CanLockPick(ent,ply) then
        return zmlab2.config.Lockpick.Duration
    end
end)

zclib.Hook.Add("onLockpickCompleted", "zmlab2_TentDoor", function(ply, success, ent)
    if CanLockPick(ent,ply) and success then

        ent:SetNextInteraction(CurTime() + 10)

        ent:EmitSound("zmlab2_ui_click")
        ent:SetIsLocked(false)
        ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        ent:SetTrigger(true)

        if zmlab2.config.Lockpick.Wanted_enabled == true then
            zclib.Police.MakeWanted(ply,zmlab2.config.Lockpick.Wanted_msg,zmlab2.config.Lockpick.Wanted_time)
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf



////////////////////////////////////////////
/////////// DoorRam Feature ////////////////
////////////////////////////////////////////
zclib.Hook.Add("canDoorRam", "zmlab2_TentDoor", function(ply,trace, ent)
    if CanLockPick(ent,ply) then
        return true
    end
end)

zclib.Hook.Add("onDoorRamUsed", "zmlab2_TentDoor", function(success, ply, trace)
    if CanLockPick(trace.Entity,ply) and success then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

        trace.Entity:SetNextInteraction(CurTime() + 10)

        trace.Entity:EmitSound("zmlab2_ui_click")
        trace.Entity:SetIsLocked(false)
        trace.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        trace.Entity:SetTrigger(true)

        if zmlab2.config.Lockpick.Wanted_enabled == true then

			local PreventWanted = hook.Run("zmlab2_OnWanted",ply,"Lockpicking!")
			if not PreventWanted then
            	zclib.Police.MakeWanted(ply,zmlab2.config.Lockpick.Wanted_msg,zmlab2.config.Lockpick.Wanted_time)
			end
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
