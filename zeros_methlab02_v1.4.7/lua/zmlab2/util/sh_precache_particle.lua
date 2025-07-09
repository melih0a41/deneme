/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

game.AddParticles("particles/zmlab2_fx.pcf")
PrecacheParticleSystem("zmlab2_cleaning")
PrecacheParticleSystem("zmlab2_methsludge_fill")
PrecacheParticleSystem("zmlab2_poison_gas")
PrecacheParticleSystem("zmlab2_vent_clean")
PrecacheParticleSystem("zmlab2_vent_poision")
PrecacheParticleSystem("zmlab2_methylamin_fill")
PrecacheParticleSystem("zmlab2_aluminium_fill")
PrecacheParticleSystem("zmlab2_acid_fill")
PrecacheParticleSystem("zmlab2_acid_explo")
PrecacheParticleSystem("zmlab2_aluminium_explo")
PrecacheParticleSystem("zmlab2_methylamine_explo")
PrecacheParticleSystem("zmlab2_lox_explo")
PrecacheParticleSystem("zmlab2_frozen_gas")
PrecacheParticleSystem("zmlab2_purchase")
PrecacheParticleSystem("zmlab2_filter_exhaust")
PrecacheParticleSystem("zmlab2_extinguish")

for k, v in pairs(zmlab2.config.MethTypes) do
    if v.visuals then
        if v.visuals.effect then
            PrecacheParticleSystem(v.visuals.effect)
        end

        if v.visuals.effect_breaking then
            PrecacheParticleSystem(v.visuals.effect_breaking)
        end

        if v.visuals.effect_filling then
            PrecacheParticleSystem(v.visuals.effect_filling)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        if v.visuals.effect_exploding then
            PrecacheParticleSystem(v.visuals.effect_exploding)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

        if v.visuals.effect_mixer_liquid then
            PrecacheParticleSystem(v.visuals.effect_mixer_liquid)
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

        if v.visuals.effect_mixer_exhaust then
            PrecacheParticleSystem(v.visuals.effect_mixer_exhaust)
        end
    end
end
