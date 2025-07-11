-- ConVar Cache Sistemi
local ConVarCache = {}
local ConVarCacheTime = 0

local function GetCachedConVar(name)
    local ct = CurTime()
    if ConVarCacheTime < ct then
        ConVarCache = {
            mult_movespeed = ArcCW.ConVars["mult_movespeed"]:GetFloat(),
            mult_movespeedads = ArcCW.ConVars["mult_movespeedads"]:GetFloat(),
            mult_movespeedfire = ArcCW.ConVars["mult_movespeedfire"]:GetFloat(),
            aimassist = ArcCW.ConVars["aimassist"]:GetBool(),
            aimassist_cone = ArcCW.ConVars["aimassist_cone"]:GetFloat(),
            aimassist_distance = ArcCW.ConVars["aimassist_distance"]:GetFloat(),
            aimassist_intensity = ArcCW.ConVars["aimassist_intensity"]:GetFloat(),
            aimassist_head = ArcCW.ConVars["aimassist_head"]:GetBool()
        }
        ConVarCacheTime = ct + 0.5 -- 0.5 saniyede bir güncelle
    end
    return ConVarCache[name]
end

-- Oyuncu bazlı cache
local PlayerSpeedCache = {}
local PlayerSpeedCacheTime = {}

function ArcCW.Move(ply, mv, cmd)
    local wpn = ply:GetActiveWeapon()
    if !wpn.ArcCW then return end

    local plyIndex = ply:EntIndex()
    local ct = CurTime()
    
    -- Speed cache kontrolü
    if PlayerSpeedCacheTime[plyIndex] and PlayerSpeedCacheTime[plyIndex] > ct then
        local cached = PlayerSpeedCache[plyIndex]
        mv:SetMaxSpeed(cached.speed)
        mv:SetMaxClientSpeed(cached.speed)
        ply.ArcCW_LastTickSpeedMult = cached.mult
        return
    end

    local s = 1
    
    -- Buff'ları cache'le
    local speedMult = wpn.SpeedMult
    local buffSpeedMult = wpn:GetBuff_Mult("Mult_SpeedMult")
    local buffMoveSpeed = wpn:GetBuff_Mult("Mult_MoveSpeed")
    
    local sm = Lerp(GetCachedConVar("mult_movespeed"), 1, math.Clamp(speedMult * buffSpeedMult * buffMoveSpeed, 0, 1))
    s = s * sm

    local basespd = math.min(
        (Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(),
        mv:GetMaxClientSpeed()
    )

    local state = wpn:GetNWState()
    local blocksprint = false

    -- State kontrollerini optimize et
    if state == ArcCW.STATE_SIGHTS or wpn:GetTriggerDelta() > 0 or state == ArcCW.STATE_CUSTOMIZE then
        blocksprint = true
        local sightedMult = wpn:GetBuff("SightedSpeedMult") * wpn:GetBuff_Mult("Mult_SightedMoveSpeed")
        s = s * Lerp(GetCachedConVar("mult_movespeedads") * (1-wpn:GetSightDelta()), 1, math.Clamp(sightedMult, 0, 1))
    else
        local shottime = wpn:GetNextPrimaryFireSlowdown() - ct
        if shottime > 0 or wpn:GetGrenadePrimed() then
            blocksprint = !wpn:CanShootWhileSprint()
            
            if shottime > 0 then
                local shootmove = Lerp(GetCachedConVar("mult_movespeedfire"), 1, math.Clamp(wpn:GetBuff("ShootSpeedMult"), 0.0001, 1))
                s = s * shootmove
            else
                local delay = wpn:GetFiringDelay()
                local aftershottime = -shottime / delay
                local shotdelta = math.Clamp(1 - aftershottime, 0, 1)
                local shootmove = Lerp(GetCachedConVar("mult_movespeedfire"), 1, math.Clamp(wpn:GetBuff("ShootSpeedMult"), 0.0001, 1))
                s = s * Lerp(shotdelta, 1, shootmove)
            end
        end
    end

    if blocksprint then
        basespd = math.min(basespd, ply:GetWalkSpeed())
    end

    if wpn:GetInBipod() then
        s = 0.0001
    end

    local finalSpeed = basespd * s
    
    -- Cache'e kaydet
    PlayerSpeedCache[plyIndex] = {
        speed = finalSpeed,
        mult = s
    }
    PlayerSpeedCacheTime[plyIndex] = ct + 0.033 -- 1 tick

    mv:SetMaxSpeed(finalSpeed)
    mv:SetMaxClientSpeed(finalSpeed)
    ply.ArcCW_LastTickSpeedMult = s
end

hook.Add("SetupMove", "ArcCW_SetupMove", ArcCW.Move)

-- CLIENT SIDE OPTIMIZATIONS
if CLIENT then
    local limy_p = 45
    local limy_n = -45
    local limp_p = 30
    local limp_n = -30

    function ArcCW.CreateMove(cmd)
        local ply = LocalPlayer()
        local wpn = ply:GetActiveWeapon()

        if !wpn.ArcCW then return end

        -- Bipod angle limiting
        if wpn:GetInBipod() and wpn:GetBipodAngle() then
            local bipang = wpn:GetBipodAngle()
            local ang = cmd:GetViewAngles()

            local dy = math.AngleDifference(ang.y, bipang.y)
            local dp = math.AngleDifference(ang.p, bipang.p)

            -- Optimize clamping
            ang.y = bipang.y + math.Clamp(dy, limy_n, limy_p)
            ang.p = bipang.p + math.Clamp(dp, limp_n, limp_p)

            cmd:SetViewAngles(ang)
        end
    end

    hook.Add("CreateMove", "ArcCW_CreateMove", ArcCW.CreateMove)
end

-- Aim assist target cache
local AATargetCache = {}
local AATargetCacheTime = {}

local function tgt_pos(ent, head)
    if !IsValid(ent) then return vector_origin end
    
    -- Cache target positions
    local entIndex = ent:EntIndex()
    local ct = CurTime()
    
    if AATargetCache[entIndex] and AATargetCacheTime[entIndex] > ct then
        return AATargetCache[entIndex]
    end
    
    local pos = ent:WorldSpaceCenter()
    
    if head then
        local attachment = ent:LookupAttachment("eyes")
        if attachment and attachment > 0 then
            local data = ent:GetAttachment(attachment)
            if data then pos = data.Pos end
        end
    else
        local mins, maxs = ent:WorldSpaceAABB()
        pos.z = pos.z + (maxs.z - mins.z) * 0.2
    end
    
    AATargetCache[entIndex] = pos
    AATargetCacheTime[entIndex] = ct + 0.1
    
    return pos
end

local lst = SysTime()
local aimAssistCounter = 0

function ArcCW.StartCommand(ply, ucmd)
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) or !wep.ArcCW then return end
    
    -- Sprint interrupt for runaway burst
    if ply:Alive() and wep:GetBurstCount() > 0 
            and ucmd:KeyDown(IN_SPEED) and wep:GetCurrentFiremode().RunawayBurst
            and !wep:CanShootWhileSprint() then
        ucmd:SetButtons(ucmd:GetButtons() - IN_SPEED)
    end

    -- Holster code
    local holsterTime = wep:GetHolster_Time()
    if holsterTime != 0 and holsterTime <= CurTime() and IsValid(wep:GetHolster_Entity()) then
        wep:SetHolster_Time(-math.huge)
        ucmd:SelectWeapon(wep:GetHolster_Entity())
    end

    -- CLIENT SIDE ONLY
    if CLIENT then
        local ct = CurTime()
        
        -- Aim assist - reduce frequency
        aimAssistCounter = aimAssistCounter + 1
        if aimAssistCounter % 3 == 0 then -- Her 3 frame'de bir
            local hasAimAssist = wep:GetBuff("AimAssist", true) or (GetCachedConVar("aimassist") and ply:GetInfoNum("arccw_aimassist_cl", 0) == 1)
            
            if hasAimAssist and wep:GetState() ~= ArcCW.STATE_CUSTOMIZE and wep:GetState() ~= ArcCW.STATE_SPRINT then
                local cone = wep:GetBuff("AimAssist", true) and wep:GetBuff("AimAssist_Cone") or GetCachedConVar("aimassist_cone")
                local dist = wep:GetBuff("AimAssist", true) and wep:GetBuff("AimAssist_Distance") or GetCachedConVar("aimassist_distance")
                local inte = wep:GetBuff("AimAssist", true) and wep:GetBuff("AimAssist_Intensity") or GetCachedConVar("aimassist_intensity")
                local head = wep:GetBuff("AimAssist", true) and wep:GetBuff("AimAssist_Head") or GetCachedConVar("aimassist_head")

                local tgt = ply.ArcCW_AATarget
                
                -- Target validation
                if IsValid(tgt) then
                    local tgtPos = tgt_pos(tgt, head)
                    if (tgtPos - ply:EyePos()):Cross(ply:EyeAngles():Forward()):Length() > cone * 2 then
                        ply.ArcCW_AATarget = nil
                    end
                end

                -- Target seeking - optimize with distance check first
                tgt = ply.ArcCW_AATarget
                if !IsValid(tgt) or (tgt.Health and tgt:Health() <= 0) then
                    local eyePos = ply:EyePos()
                    local eyeForward = ply:EyeAngles():Forward()
                    local min_diff
                    ply.ArcCW_AATarget = nil
                    
                    -- First filter by distance
                    for _, ent in ipairs(ents.FindInSphere(eyePos, dist)) do
                        if ent == ply or (!ent:IsNPC() and !ent:IsNextBot() and !ent:IsPlayer()) or (ent.Health and ent:Health() <= 0) then continue end
                        if ent:IsPlayer() and ent:Team() ~= TEAM_UNASSIGNED and ent:Team() == ply:Team() then continue end
                        
                        -- Quick cone check
                        local toEnt = (ent:GetPos() - eyePos):GetNormalized()
                        if toEnt:Dot(eyeForward) < math.cos(math.rad(cone)) then continue end
                        
                        -- Line of sight check
                        local tgtPos = tgt_pos(ent, head)
                        local tr = util.QuickTrace(eyePos, tgtPos - eyePos, ply)
                        if tr.Entity ~= ent then continue end
                        
                        local diff = (tgtPos - eyePos):Cross(eyeForward):Length()
                        if !ply.ArcCW_AATarget or diff < min_diff then
                            ply.ArcCW_AATarget = ent
                            min_diff = diff
                        end
                    end
                end

                -- Apply aim assist
                tgt = ply.ArcCW_AATarget
                if IsValid(tgt) then
                    local ang = ucmd:GetViewAngles()
                    local pos = tgt_pos(tgt, head)
                    local tgt_ang = (pos - ply:EyePos()):Angle()
                    local ang_diff = (pos - ply:EyePos()):Cross(ply:EyeAngles():Forward()):Length()
                    
                    if ang_diff > 0.1 then
                        ang = LerpAngle(math.Clamp(inte / ang_diff, 0, 1), ang, tgt_ang)
                        ucmd:SetViewAngles(ang)
                    end
                end
            end
        end

        -- Recoil processing
        local ang2 = ucmd:GetViewAngles()
        local ft = (SysTime() - lst) * GetConVar("host_timescale"):GetFloat()

        if wep.RecoilAmount > 0 or wep.RecoilAmountSide > 0 then
            local recoil = Angle()
            recoil = recoil + (wep:GetBuff_Override("Override_RecoilDirection") or wep.RecoilDirection) * wep.RecoilAmount
            recoil = recoil + (wep:GetBuff_Override("Override_RecoilDirectionSide") or wep.RecoilDirectionSide) * wep.RecoilAmountSide
            ang2 = ang2 - (recoil * ft * 30)
            ucmd:SetViewAngles(ang2)

            -- Recoil recovery
            wep.RecoilAmount = math.max(0, wep.RecoilAmount - ft * 20 * wep.RecoilAmount)
            wep.RecoilAmountSide = math.max(0, wep.RecoilAmountSide - ft * 20 * wep.RecoilAmountSide)
        end
        
        lst = SysTime()
    end
end

hook.Add("StartCommand", "ArcCW_StartCommand", ArcCW.StartCommand)

-- Cache cleanup
timer.Create("ArcCW_CacheCleanup", 5, 0, function()
    -- Clean invalid player caches
    for k, v in pairs(PlayerSpeedCache) do
        if !IsValid(Player(k)) then
            PlayerSpeedCache[k] = nil
            PlayerSpeedCacheTime[k] = nil
        end
    end
    
    -- Clean target position cache
    for k, v in pairs(AATargetCache) do
        if !IsValid(Entity(k)) then
            AATargetCache[k] = nil
            AATargetCacheTime[k] = nil
        end
    end
end)