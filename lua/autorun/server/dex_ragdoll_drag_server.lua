local playerDragData = {}

util.AddNetworkString("dex_RagdollDragSync")

local function SendRagdollData(ply)
    local ragdollData = {}
    
    for _, targetPly in ipairs(player.GetAll()) do
        if IsValid(targetPly.Ragdoll) and targetPly.IsInRagdoll then
            ragdollData[targetPly.Ragdoll:EntIndex()] = {
                owner = targetPly:EntIndex(),
                ownerName = targetPly:Name()
            }
        end
    end
    
    net.Start("dex_RagdollDragSync")
    net.WriteTable(ragdollData)
    net.Send(ply)
end

hook.Add("PlayerUse", "dex_RagdollDragSystem", function(ply, ent)
    if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
        local ragdollOwner = nil
        for _, targetPly in ipairs(player.GetAll()) do
            if targetPly.Ragdoll == ent and targetPly.IsInRagdoll then
                ragdollOwner = targetPly
                break
            end
        end
        
        if not ragdollOwner then return end

        local startPos = ply:GetShootPos()
        local aimVec = ply:GetAimVector()
        
        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + aimVec * 150,
            filter = function(testEnt)
                return testEnt == ent
            end
        })

        if tr.Hit and tr.Entity == ent then
            local bestBone = 0
            local bestDist = math.huge
            
            for i = 0, ent:GetPhysicsObjectCount() - 1 do
                local phys = ent:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local bonePos = phys:GetPos()
                    local dist = bonePos:Distance(tr.HitPos)
                    if dist < bestDist then
                        bestDist = dist
                        bestBone = i
                    end
                end
            end
            
            playerDragData[ply] = {
                Entity = ent,
                OffPos = ent:WorldToLocal(tr.HitPos),
                Fraction = tr.Fraction,
                BoneIndex = bestBone,
                StartTime = CurTime(),
                RagdollOwner = ragdollOwner
            }

            return false
        end
    end
end)

hook.Add("Think", "dex_RagdollDragThink", function()
    for ply, dragData in pairs(playerDragData) do
        if IsValid(ply) and IsValid(dragData.Entity) and ply:KeyDown(IN_USE) then
            local stillValid = false
            if IsValid(dragData.RagdollOwner) and dragData.RagdollOwner.IsInRagdoll and dragData.RagdollOwner.Ragdoll == dragData.Entity then
                stillValid = true
            end

            if not stillValid then
                playerDragData[ply] = nil
                continue
            end

            local startPos = ply:GetShootPos()
            local aimVec = ply:GetAimVector()
            local distance = startPos:Distance(dragData.Entity:GetPos())

            if distance > 150 * 2 then
                playerDragData[ply] = nil
                continue
            end

            local phys = dragData.Entity:GetPhysicsObjectNum(dragData.BoneIndex)
            if IsValid(phys) then
                local targetPos = startPos + aimVec * 150 * dragData.Fraction
                local currentPos = dragData.Entity:LocalToWorld(dragData.OffPos)
                local diff = targetPos - currentPos

                local force = (diff:GetNormalized() * math.min(1, diff:Length() / 100) * 800 - phys:GetVelocity()) * phys:GetMass()

                phys:ApplyForceOffset(force, currentPos)
                phys:AddAngleVelocity(-phys:GetAngleVelocity() / 6)

                for i = 0, dragData.Entity:GetPhysicsObjectCount() - 1 do
                    if i ~= dragData.BoneIndex then
                        local otherPhys = dragData.Entity:GetPhysicsObjectNum(i)
                        if IsValid(otherPhys) then
                            otherPhys:AddAngleVelocity(-otherPhys:GetAngleVelocity() / 8)
                        end
                    end
                end
            end
        else
            playerDragData[ply] = nil
        end
    end
end)

hook.Add("PlayerDisconnected", "dex_RagdollDragCleanup", function(ply)
    playerDragData[ply] = nil
end)

hook.Add("PlayerInitialSpawn", "dex_RagdollDragNetworkInit", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            SendRagdollData(ply)
        end
    end)
end)

hook.Add("PlayerSpawn", "dex_RagdollDragNetworkUpdate", function(ply)
    timer.Simple(0.5, function()
        for _, targetPly in ipairs(player.GetAll()) do
            SendRagdollData(targetPly)
        end
    end)
end)

timer.Create("dex_RagdollDragNetworkTimer", 2, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        SendRagdollData(ply)
    end
end)

hook.Add("PlayerDisconnected", "dex_RagdollDragNetworkCleanup", function(ply)
    timer.Simple(0.1, function()
        for _, targetPly in ipairs(player.GetAll()) do
            SendRagdollData(targetPly)
        end
    end)
end)

function IsPlayerDraggingRagdoll(ply)
    return playerDragData[ply] ~= nil
end

function StopPlayerRagdollDrag(ply)
    playerDragData[ply] = nil
end

function GetPlayerDraggedRagdoll(ply)
    local dragData = playerDragData[ply]
    return dragData and dragData.Entity or nil
end