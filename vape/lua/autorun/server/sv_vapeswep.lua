-- DOSYA: addons/vape/lua/autorun/server/sv_vapeswep.lua (1. KOD)

util.AddNetworkString("Vape")
util.AddNetworkString("VapeArm")
util.AddNetworkString("VapeTalking")
util.AddNetworkString("VapeUpdateServer")
util.AddNetworkString("DragonVapeIgnite")

local GLOBAL_MAX_HEALTH_CAP = 250
local GLOBAL_MAX_ARMOR_CAP = 300

net.Receive("VapeUpdateServer", function(len, ply)
    if not IsValid(ply) or not ply:Alive() or not IsValid(ply:GetActiveWeapon()) then return end
    if string.sub(ply:GetActiveWeapon():GetClass(), 1, 11) ~= "weapon_vape" then return end
    local vapeID = net.ReadUInt(8)
    VapeUpdate(ply, vapeID)
end)

function VapeUpdate(ply, vapeID)
    -- Rate limiting - spam koruması
    if (ply.lastVapeUpdate or 0) > CurTime() - 0.05 then return end
    ply.lastVapeUpdate = CurTime()
    
    ply.vapeCount = ply.vapeCount or 0
    ply.cantStartVape = ply.cantStartVape or false
    ply.medVapeTimer = ply.medVapeTimer or false
    ply.lastVapeID = ply.lastVapeID or nil

    if ply.vapeCount > 3 and not ply.cantStartVape then
        if vapeID ~= ply.lastVapeID then
            if ply.lastVapeID == 31 or ply.lastVapeID == 34 then
                if ply.OriginalMaxHealth then ply:SetMaxHealth(ply.OriginalMaxHealth); ply.OriginalMaxHealth = nil; end
            end
            if ply.lastVapeID == 32 or ply.lastVapeID == 34 then
                if ply.VapeArmorMax then ply.VapeArmorStart = nil; ply.VapeArmorMax = nil; end
            end
            ply.medVapeTimer = false
            ply.lastVapeID = vapeID
        end
        if vapeID == 3 then
            if ply.medVapeTimer then ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth())) end
            ply.medVapeTimer = not ply.medVapeTimer
        elseif vapeID == 31 then
            if not ply.OriginalMaxHealth then ply.OriginalMaxHealth = ply:GetMaxHealth(); ply:SetMaxHealth(math.min(ply.OriginalMaxHealth + 50, GLOBAL_MAX_HEALTH_CAP)) end
            if ply.medVapeTimer then ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth())) end
            ply.medVapeTimer = not ply.medVapeTimer
        elseif vapeID == 32 then
            if not ply.VapeArmorMax then ply.VapeArmorStart = ply:Armor(); ply.VapeArmorMax = math.min(ply.VapeArmorStart + 50, GLOBAL_MAX_ARMOR_CAP) end
            if ply.medVapeTimer then ply:SetArmor(math.min(ply:Armor() + 1, ply.VapeArmorMax)) end
            ply.medVapeTimer = not ply.medVapeTimer
        elseif vapeID == 34 then
            if not ply.OriginalMaxHealth then ply.OriginalMaxHealth = ply:GetMaxHealth(); ply:SetMaxHealth(math.min(ply.OriginalMaxHealth + 50, GLOBAL_MAX_HEALTH_CAP)) end
            if not ply.VapeArmorMax then ply.VapeArmorStart = ply:Armor(); ply.VapeArmorMax = math.min(ply.VapeArmorStart + 50, GLOBAL_MAX_ARMOR_CAP) end
            if ply.medVapeTimer then
                if ply:Health() < ply:GetMaxHealth() then ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth())) end
                if ply:Armor() < ply.VapeArmorMax then ply:SetArmor(math.min(ply:Armor() + 1, ply.VapeArmorMax)) end
            end
            ply.medVapeTimer = not ply.medVapeTimer
        end
        if not ply.VapeDizzy then
            ply.VapeDizzy = true
            ply.OriginalWalkSpeed = ply:GetWalkSpeed()
            ply.OriginalRunSpeed = ply:GetRunSpeed()
            ply:SetWalkSpeed(100)
            ply:SetRunSpeed(150)
            local dizzyTimerName = "VapeDizzyEffect_" .. ply:SteamID()
            timer.Create(dizzyTimerName, 0.5, 30, function()
                if not IsValid(ply) then timer.Remove(dizzyTimerName) return end
                ply:SendLua("util.ScreenShake(LocalPlayer():GetPos(), 3, 1, 0.5, 500)")
                ply:ViewPunch(Angle(math.random(-1, 1), math.random(-2, 2), 0))
            end)
            timer.Simple(15, function()
                if IsValid(ply) then
                    if ply.OriginalWalkSpeed and ply.OriginalRunSpeed then ply:SetWalkSpeed(ply.OriginalWalkSpeed); ply:SetRunSpeed(ply.OriginalRunSpeed) end
                    ply.OriginalWalkSpeed, ply.OriginalRunSpeed, ply.VapeDizzy = nil, nil, false
                end
            end)
        end
    end
    if vapeID == 4 then SetVapeHelium(ply, math.min(100, (ply.vapeHelium or 0)+1.5)) end
    if vapeID == 5 then ply:SendLua("vapeHallucinogen=(vapeHallucinogen or 0)+3") end
    ply.vapeID = vapeID
    ply.vapeCount = ply.vapeCount + 1
    if ply.vapeCount == 1 then
        ply.vapeArm = true
        net.Start("VapeArm"); net.WriteEntity(ply); net.WriteBool(true); net.SendPVS(ply:EyePos())
    end
    if ply.vapeCount >= 50 then ply.cantStartVape = true; ReleaseVape(ply) end
end

hook.Add("KeyRelease","DoVapeHook",function(ply, key)
    if key == IN_ATTACK then ReleaseVape(ply); ply.cantStartVape=false; end
end)

function ReleaseVape(ply)
    if not ply.vapeCount then ply.vapeCount = 0 end
    if IsValid(ply:GetActiveWeapon()) and string.sub(ply:GetActiveWeapon():GetClass(), 1, 11) == "weapon_vape" then
        if ply.vapeCount >= 5 then
            net.Start("Vape")
            net.WriteEntity(ply)
            net.WriteUInt(ply.vapeCount, 8)
            net.WriteUInt((ply.vapeID or 1) + (ply:GetActiveWeapon().juiceID or 0), 8)
            if (ply.vapeID == 2) or (ply.vapeID == 6) then net.Broadcast() else net.SendPVS(ply:EyePos()) end
        end
    end
    if ply.vapeArm then
        ply.vapeArm = false
        net.Start("VapeArm"); net.WriteEntity(ply); net.WriteBool(false); net.Broadcast()
    end
    ply.vapeCount=0
end

timer.Create("VapeHeliumUpdater",0.2,0,function()
    for k,v in pairs(player.GetAll()) do
        if not (IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetClass() == "weapon_vape_helium" and v.vapeArm) then
            SetVapeHelium(v, math.max(0, (v.vapeHelium or 0) - 2))
        end
    end
end)

function SetVapeHelium(ply, helium)
    if ply.vapeHelium ~= helium then
        local grav = Lerp(helium/100, 1, -0.15)
        if grav < 0 and ply:OnGround() then ply:SetPos(ply:GetPos()+Vector(0,0,1)) end
        ply:SetGravity(grav)
        ply.vapeHelium = helium
        ply:SendLua("vapeHelium="..tostring(helium))
        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_vape_helium" then
            ply:GetActiveWeapon().SoundPitchMod=helium
            ply:SendLua("Entity("..tostring(ply:GetActiveWeapon():EntIndex())..").SoundPitchMod="..tostring(helium))
        end
    end
end

net.Receive("DragonVapeIgnite", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ply:HasWeapon("weapon_vape_dragon") or not ent:IsSolid() or ent:GetPos():Distance(ply:GetPos()) > 500 then return end
    ent:Ignite(10,0)
end)