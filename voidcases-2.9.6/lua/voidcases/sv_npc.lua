function VoidCases.LoadNPCs()
    if not VoidCases.Config.NPCModel then
        hook.Add("VoidCases_ConfigLoaded", "VoidCases_LoadNPCs", function()
            VoidCases.LoadNPCs()
hook.Remove("VoidCases_ConfigLoaded", "VoidCases_LoadNPCs")
        end)

        return
    end

    local npcFile = file.Read("voidcases_npc.json", "DATA")
    if not npcFile then return end

    local npcData = util.JSONToTable(npcFile)
    local npcList = npcData[game.GetMap()]

    if not npcList then return end

    for _, data in ipairs(npcList) do
        local npc = ents.Create("voidcases_npc")
        npc:SetPos(data.pos)
        npc:SetAngles(data.angles)
        npc:Spawn()
    end
end

function VoidCases.SaveNPCs()
    local npcFile = file.Read("voidcases_npc.json", "DATA")
    local map = game.GetMap()
    local npcList = {}
    npcList[map] = {}

    if npcFile then
        local existingNPCList = util.JSONToTable(npcFile)

        for _, data in ipairs(existingNPCList) do
            table.insert(npcList[map], data)
        end
    end

    local localNPCs = ents.FindByClass("voidcases_npc")

    for _, npc in ipairs(localNPCs) do
        table.insert(npcList[map], {pos = npc:GetPos(), angles = npc:GetAngles()})
    end

    local npcData = util.TableToJSON(npcList)
    file.Write("voidcases_npc.json", npcData)
end

concommand.Add("voidcases_savenpc", function(ply)
    if not CAMI.PlayerHasAccess(ply, "VoidCases_EditSettings") then
        VoidLib.Notify(ply, "NO PERMISSION", "You need the permission voidcases_editsettings to save NPCs!", VoidUI.Colors.Red, 4)
        return
    end

    VoidCases.SaveNPCs()
    VoidLib.Notify(ply, "SUCCESS", "You successfully saved all VoidCases NPCs!", VoidUI.Colors.Green, 3)
end)
