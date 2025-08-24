local sanity = 100
local redFadeAlpha = 0
local nextSoundTime = 0
local lastSanity = 100
local sanityPulse = 0
local sanityShake = 0
local bloodActive = false
local bloodPhaseEnd = 0

-- ====================================================

net.Receive("dex_UpdateSanity", function()
    lastSanity = sanity
    sanity = net.ReadInt(8)
end)

net.Receive("dex_PlaySanitySounds", function()
    if CurTime() < nextSoundTime then return end
    nextSoundTime = CurTime() + math.random(8, 15)

    local sounds = {
        "ambient/voices/whisper1.wav",
        "ambient/voices/whisper2.wav",
    }

    surface.PlaySound(table.Random(sounds))
end)

-- ====================================================

local function CreateBloodEffect(target)
    if not bloodActive then return end
        
    local throatPos = target:GetPos() + target:GetRight() * 0 + Vector(0, 0, 62)
    local emitter = ParticleEmitter(throatPos)
    
    for i = 1, math.random(1, 2) do
        local particle = emitter:Add("effects/blood_core", throatPos)
        if particle then
            local dir = (target:GetForward() * 0.7 + target:GetRight() * 0.2 + Vector(0, 0, -0.3)):GetNormalized()
            particle:SetVelocity(dir * math.Rand(50, 120))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.8, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(4, 8))
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(180, 0, 0)
            particle:SetGravity(Vector(0, 0, -200))
            particle:SetAirResistance(20)
        end
    end
    
    emitter:Finish()
end

local function UpdateBloodCycle()
    if CurTime() > bloodPhaseEnd then
        bloodActive = not bloodActive
        bloodPhaseEnd = CurTime() + (bloodActive and 5 or 60)
        
        if bloodActive then
            local target = LocalPlayer()
            local effectdata = EffectData()
            effectdata:SetOrigin(target:GetPos() + Vector(0, 0, 62))
            effectdata:SetNormal(target:GetRight())
            effectdata:SetMagnitude(3)
            effectdata:SetScale(2)
            util.Effect("BloodImpact", effectdata)
        end
    end
end

-- ====================================================

hook.Add("Think", "dex_SanityBloodCycle", function()
    if not DEX_CONFIG.SanityEnableEffects then return end
    if not DEX_CONFIG.IsSerialKiller(LocalPlayer()) then return end
    if sanity <= (DEX_CONFIG.SanityCritical or 20) then
        UpdateBloodCycle()
    else
        bloodActive = false
        bloodPhaseEnd = 0
    end
end)

hook.Add("HUDPaint", "dex_DrawSanityEffects", function()
    if not DEX_CONFIG.SanityEnableEffects then return end
    if not DEX_CONFIG.IsSerialKiller(LocalPlayer()) then return end

    sanityPulse = math.Approach(sanityPulse, 0, FrameTime() * 0.5)
    sanityShake = math.Approach(sanityShake, 0, FrameTime() * 10)
    
    if lastSanity > sanity then
        sanityPulse = 1
        sanityShake = math.min(sanityShake + 0.5, 5)
    end

    if sanity <= 20 then
        for _, ent in ipairs(ents.FindInSphere(LocalPlayer():GetPos(), 300)) do
            if ent:IsPlayer() and ent ~= LocalPlayer() and (ent:Alive() or not ent:IsPlayer()) then
                CreateBloodEffect(ent)
            end
        end
    end
end)

local colorModifyTab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0,
}

hook.Add("RenderScreenspaceEffects", "dex_SanityScreenEffects", function()
    if not DEX_CONFIG.SanityEnableEffects then return end
    if not DEX_CONFIG.IsSerialKiller(LocalPlayer()) then return end
    
    if sanity < 70 then
        colorModifyTab["$pp_colour_addr"] = math.Clamp((70 - sanity) * 0.005, 0, 0.1)
        colorModifyTab["$pp_colour_brightness"] = math.Clamp((70 - sanity) * -0.005, -0.2, 0)
        colorModifyTab["$pp_colour_contrast"] = 1 + (70 - sanity) * 0.005
        colorModifyTab["$pp_colour_colour"] = 1 - (70 - sanity) * 0.01
        colorModifyTab["$pp_colour_mulr"] = math.Clamp((70 - sanity) * 0.01, 0, 0.5)

        DrawColorModify(colorModifyTab)
        
        if sanity < 40 then
            DrawMotionBlur(0.2, 0.4, 0.01)
        end
    end
end)
