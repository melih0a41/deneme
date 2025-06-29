/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.CustomWeapons = zvm.CustomWeapons or {}

zclib.Hook.Add("PlayerSay", "zvm_PlayerSay_customweapons", function(ply, text)

    if string.sub(string.lower(text), 1, 23) == "!zvm_customweapons_add_" then

        local itemid = string.sub(string.lower(text), 24, string.len(text))
        zvm.CustomWeapons.AddItem(ply,itemid)
    end
end)

concommand.Add("zvm_customweapons_add", function(ply, cmd, args)
    if IsValid(ply) then

        local swepclass = args[1]
        if swepclass == nil then return end

        zvm.CustomWeapons.AddItem(ply, swepclass)
    end
end)


function zvm.CustomWeapons.AddItem(ply, weaponclass)

    if zclib.Player.IsAdmin(ply) == false then
        return
    end

    local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

    if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zvm_machine" then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

        local Machine = tr.Entity

        if Machine:GetPublicMachine() == false then return end
        if zvm.Machine.ReachedItemLimit(Machine) then return end
        if Machine:GetAllowCollisionInput() == false then return end

        local swep = weapons.Get( weaponclass )

        if not swep then
            zclib.Notify(ply, "InValid SWEP or the weapon class could not be found!", 1)
            return
        end

        table.insert(Machine.Products,{
            class = weaponclass,
            name = swep.PrintName,
            price = 500,
            model = swep.WorldModel,
            extraData = {},
            insta_pickup = true, // This tells the package that this swep should be given to the player instead of dropping it
            amount = 1,
        })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

        // Updates the machine interface for the user which is editing it
        zvm.Machine.UpdateMachineData(Machine,ply)
    end
end
