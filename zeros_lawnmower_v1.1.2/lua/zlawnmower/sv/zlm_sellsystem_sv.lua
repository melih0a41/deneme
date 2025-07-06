/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if (not SERVER) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

zlm = zlm or {}
zlm.f = zlm.f or {}

function zlm.f.CatchClosestNPC(ply)
    local npc
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    for k, v in pairs(zlm_BuyerNPCs) do
        if IsValid(v) and zlm.f.InDistance(ply:GetPos(), v:GetPos(), zlm.config.NPC.SellDistance) then
            npc = v
            break
        end
    end

    return npc
end

function zlm.f.SellGrassRolls(ply,trailer)

    local grassRolls = trailer:GetGrassRolls()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    if grassRolls <= 0 then
        zlm.f.Notify(ply, zlm.language.General["TrailerEmpty"], 1)
        return
    end

    local npc = zlm.f.CatchClosestNPC(ply)

    if IsValid(npc) then

        // This calculates the earning amount according to the player rank
        local earning = zlm.config.NPC.SellPrice[ply:GetUserGroup()]
        if earning == nil then
            earning = zlm.config.NPC.SellPrice["Default"]
        end
        earning = earning * grassRolls

        // Here we add the price multiplier
        earning = earning * ((1 / 100) * npc:GetPriceModifier())

        //Custom Hook
        hook.Run("zlm_OnGrassRollSold", ply, grassRolls,earning,npc)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

        // Here we give the player the money
        zlm.f.GiveMoney(ply, earning)

        // Creates the Sell Effect
        zlm.f.CreateEffectAtPos("zlm_sell", trailer:GetPos())

        local soundData = zlm.f.CatchSound("zlm_selling")
        trailer:EmitSound(soundData.sound, soundData.lvl, soundData.pitch, soundData.volume, CHAN_STATIC)

        trailer:SetGrassRolls(0)

        zlm.f.Notify(ply, "+" .. earning .. zlm.config.Currency, 0)
    else
        zlm.f.Notify(ply, zlm.language.General["NoBuyerNPCFound"], 1)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813
