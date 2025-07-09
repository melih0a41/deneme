/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.TrashCollector = ztm.TrashCollector or {}

function ztm.TrashCollector.Initialize(swep)
    swep:SetHoldType(swep.HoldType)

    swep.LastTrashHit = 1
    swep.LastTrash = 0
    swep.TrashIncrease = false
end

function ztm.TrashCollector.Primary(swep)

    local m_owner = swep:GetOwner()
    if not IsValid(m_owner) then return end

    zclib.NetEvent.Create("ztm_trashcollector_primary_fx", {m_owner})

    m_owner:EmitSound("ztm_airburst")

    local tr = m_owner:GetEyeTrace()

    if tr.Hit and zclib.util.InDistance(tr.HitPos, m_owner:GetPos(), 200) and IsValid(tr.Entity) then
        if tr.Entity:GetClass() == "ztm_leafpile"  then
            ztm.Leafpile.Explode(tr.Entity,m_owner)
        else
            if ztm.config.TrashSWEP.allow_physmanipulation == false then return end

            local phys = tr.Entity:GetPhysicsObject()


            if IsValid(phys) and phys:IsMoveable() and phys:GetMass() < 100 then

                local dir = tr.Entity:GetPos() - m_owner:GetPos()
                phys:ApplyForceCenter( (phys:GetMass() * (3 * m_owner.ztm_data.lvl)) * dir )
            end

        end
    end
end

function ztm.TrashCollector.Secondary(swep)
    if swep:GetTrash() >= ztm.config.TrashSWEP.level[swep:GetPlayerLevel()].inv_cap then return end

    local m_owner = swep:GetOwner()
    if not IsValid(m_owner) then return end

    local tr = m_owner:GetEyeTrace()
    if tr.Hit and zclib.util.InDistance(tr.HitPos, m_owner:GetPos(), 200) then
        for k, v in pairs(ents.FindInSphere(tr.HitPos, 25)) do
            if IsValid(v) and ztm.TrashCollector.CollectCheck(swep, v, m_owner) then break end
        end
    end
end

function ztm.TrashCollector.CollectCheck(swep,ent,ply)
    local _class = ent:GetClass()

    // Collect trash ent
    if _class == "ztm_trash" and ent:GetTrash() > 0  then

        // Custom Hook
        hook.Run("ztm_OnTrashCollect" ,ply, ent:GetTrash())

        ztm.TrashCollector.XP(ply,ent:GetTrash())
        swep:SetTrash(swep:GetTrash() + ent:GetTrash())
        SafeRemoveEntity( ent )
        return true
    end

    // Collect trash from trashcan
    if ent:IsPlayer() == false and ent:GetNWInt("ztm_trash",0) > 0  then

        // Custom Hook
        hook.Run("ztm_OnTrashCollect" ,ply, 1)

        ztm.TrashCollector.XP(ply,1)

        swep:SetTrash(swep:GetTrash() + 1)
        ent:SetNWInt("ztm_trash", math.Clamp(ent:GetNWInt("ztm_trash",0) - 1,0,9999))
        return true
    end

    // Collect trash from manhole
    if _class == "ztm_manhole" and ent:GetTrash() > 0 and ent:GetIsClosed() == false  then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        // Custom Hook
        hook.Run("ztm_OnTrashCollect" ,ply, 1)

        ztm.TrashCollector.XP(ply,1)

        swep:SetTrash(swep:GetTrash() + 1)

        ent:SetTrash(ent:GetTrash() - 1)

        return true
    end

    // Collect trash from player
    if ent:IsPlayer() and ent:Alive() and ent ~= ply and ent:GetNWInt("ztm_trash",0) > 0  then

        // Custom Hook
        hook.Run("ztm_OnTrashCollect" ,ply, 1)

        ztm.TrashCollector.XP(ply,1)

        swep:SetTrash(swep:GetTrash() + 1)

        ent:SetNWInt("ztm_trash",math.Clamp(ent:GetNWInt("ztm_trash",0) - 1,0,ztm.config.PlayerTrash.Limit))
        return true
    end

    // Collect trash from trashbag
    if _class == "ztm_trashbag"  then

        // We need to delay it a bit to avoid having people exploit the bag using Xenin or ItemStore pickup
        timer.Simple(0.1,function()
            if IsValid(swep) and IsValid(ent) then
                swep:SetTrash(swep:GetTrash() + 1)
                ent:SetTrash(ent:GetTrash() - 1)

                if ent:GetTrash() <= 0 then
                    // Remove trashbag
                    SafeRemoveEntity( ent )
                    zclib.Debug("Trashbag removed!")
                end
            end
        end)

        return true
    end

    // Collect any other type of entity as trash
    if ztm.config.TrashClass && ztm.config.TrashClass[_class] and ztm.config.TrashClass[_class].CanCollect(ply,ent) then

        swep:SetTrash(swep:GetTrash() + ztm.config.TrashClass[_class].Trash(ply,ent))

        ztm.config.TrashClass[_class].OnCollect(ply,ent)

        SafeRemoveEntity(ent)
        return true
    end

    return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ztm.TrashCollector.CollectTrash(swep)
    swep:SetIsCollectingTrash(true)

    -- This collects the trash from the pile we are looking at,
    ztm.TrashCollector.Secondary(swep)
    local _trash = swep:GetTrash()

    if _trash > swep.LastTrash then
        swep.TrashIncrease = true
    else
        swep.TrashIncrease = false
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    swep.LastTrash = _trash
    local m_owner = swep:GetOwner()
    if not IsValid(m_owner) then return end

    if swep.TrashIncrease then
        m_owner:GetViewModel():SetBodygroup(0, 1)
    else
        m_owner:GetViewModel():SetBodygroup(0, 0)
    end

    swep:SetLast_Secondary(CurTime())
    swep.LastTrashHit = CurTime() + ztm.config.TrashSWEP.level[swep:GetPlayerLevel()].secondary_interval
end

function ztm.TrashCollector.XP(ply, trash)

    if ply.ztm_data.lvl >= table.Count(ztm.config.TrashSWEP.level) then return end

    local xp = trash * ztm.config.TrashSWEP.xp_per_kg
    xp = ztm.config.TrashSWEP.xp_modify(ply, xp)
    ztm.Data.AddXP(ply, xp)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d



// Drop Trashbag
function ztm.TrashCollector.DropTrashbag(ply,key)
    if key == KEY_R and IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ztm_trashcollector" then

        local swep = ply:GetActiveWeapon()
        local _trash = swep:GetTrash()

        if _trash > 0 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

            local tr = ply:GetEyeTrace()

            if tr.Hit and tr.HitSky == false and zclib.util.InDistance(ply:GetPos(), tr.HitPos, 500) then

                if IsValid(tr.Entity) and tr.Entity:GetClass() == "ztm_trashbag" and tr.Entity:GetTrash() < ztm.config.Trashbags.capacity then

                    local trashbag_trash = tr.Entity:GetTrash()

                    local _freespace = ztm.config.Trashbags.capacity - trashbag_trash

                    _trash = math.Clamp(_trash,0,_freespace)

                    tr.Entity:SetTrash(tr.Entity:GetTrash() + _trash)
                    swep:SetTrash(swep:GetTrash() - _trash)

                else
                    if ztm.Trashbag.GetCountByPlayer(ply) >= ztm.config.Trashbags.limit then
                        zclib.Notify(ply, ztm.language.General["TrashbagLimit"], 1)
                        return
                    end

                    if _trash > ztm.config.Trashbags.capacity then

                        ztm.Trashbag.Create(tr.HitPos + Vector(0,0,20),ztm.config.Trashbags.capacity,ply)
                        swep:SetTrash(_trash - ztm.config.Trashbags.capacity)
                    else

                        ztm.Trashbag.Create(tr.HitPos + Vector(0,0,20),_trash,ply)
                        swep:SetTrash(0)
                    end
                end

            end
        end
    end
end

zclib.Hook.Add("PlayerButtonDown", "ztm_DropTrash", function(ply, key)
    ztm.TrashCollector.DropTrashbag(ply,key)
end)

zclib.Hook.Add("canDropWeapon", "ztm_canDropWeapon", function(ply,swep)
    if IsValid(swep) and swep:GetClass() == "ztm_trashcollector" then
        return false
    end
end)
