/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.Mixer = zmlab2.Mixer or {}

// Checks if the player is allowed to create this methtype
function zmlab2.Mixer.MethTypeCheck(ply,methtype)
    local MethData = zmlab2.config.MethTypes[methtype]
    if MethData == nil then return false end
    if MethData.rank and istable(MethData.rank) and table.Count(MethData.rank) > 0 and zclib.Player.RankCheck(ply,MethData.rank) == false then return false end
    if MethData.job and istable(MethData.job) and table.Count(MethData.job) > 0 and MethData.job[zclib.Player.GetJob(ply)] == nil then return false end
    if MethData.customcheck and MethData.customcheck(ply) == false then return false end

    return true
end

function zmlab2.Mixer.GetLiquidColor(Mixer)
    local col
    local state = Mixer:GetProcessState()
    local MethType = Mixer:GetMethType()
    /*
        < 2 = Yellow
        2 = Acid Yellow
        2 - 3 > Acid Yellow to meth color half way
        8 > 9 half color to final color
    */
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

    if state < 2 then
        col = zmlab2.colors["mixer_liquid01"]
    elseif state == 2 then

        col = zmlab2.colors["mixer_liquid02"]

    elseif state == 3 then

        local mix_start = Mixer:GetProcessStart()
        local time_fract = (1 / zmlab2.Meth.GetMixTime(MethType)) * (CurTime() - mix_start)

        local midColor = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))

        col = zclib.util.LerpColor(time_fract, zmlab2.colors["mixer_liquid02"], midColor)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    elseif state > 3 and state < 8 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

        col = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))

    else
        local midColor = zclib.util.LerpColor(0.5, zmlab2.colors["mixer_liquid02"], zmlab2.Meth.GetColor(MethType))

        local vent_start = Mixer:GetProcessStart()
        local time_fract = (1 / zmlab2.Meth.GetVentTime(MethType)) * (CurTime() - vent_start)
        col = zclib.util.LerpColor(time_fract, midColor, zmlab2.Meth.GetColor(MethType))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

        local qual_fact = (1 / 100) * Mixer:GetMethQuality()
        local h, s, v = ColorToHSV(col)
        col = HSVToColor(h, s * qual_fact, v)

        local fract = (1 / 4) * (state - 3)
        col = zclib.util.LerpColor(fract, midColor, col)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    return col
end
