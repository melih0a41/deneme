/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.CustomEntity = zvm.CustomEntity or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

concommand.Add("zvm_customentity_add", function(ply, cmd, args)
    if IsValid(ply) then

        local entclass = args[1]
        if entclass == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        zvm.CustomEntity.AddItem(ply, entclass)
    end
end)


function zvm.CustomEntity.AddItem(ply, entclass)

    if zclib.Player.IsAdmin(ply) == false then
        return
    end

    local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zvm_machine" then

        local Machine = tr.Entity

        if Machine:GetPublicMachine() == false then return end
        if zvm.Machine.ReachedItemLimit(Machine) then return end
        if Machine:GetAllowCollisionInput() == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

        local ent = ents.Create(entclass)
        if not IsValid(ent) then
            zclib.Notify(ply, "InValid entity class!", 1)
            return
        end
        ent:SetPos(tr.HitPos)
        ent:Spawn()
        ent:Activate()

        zvm.Machine.AddProduct(Machine, ent)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        zclib.Notify(ply, "Added " .. entclass .. "!", 0)
    end
end
