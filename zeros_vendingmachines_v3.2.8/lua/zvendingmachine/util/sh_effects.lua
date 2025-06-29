/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.NetEvent.AddDefinition("zvm_machine_output", {
    [1] = {
        type = "entity"
    }
}, function(received)
    local ent = received[1]
    if not IsValid(ent) then return end
    zclib.Animation.Play(ent, "output", 1)
    ent:EmitSound("zvm_output_product")
end)
