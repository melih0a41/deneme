hook.Add("PlayerSpawn", "ResetVapeVars", function(ply)
    -- Can reset
    ply.extraHeal = 0
    ply.medVapeTimer = false
    ply.OriginalMaxHealth = nil
    ply:SetMaxHealth(100)

    -- Armor reset
    ply.extraArmor = 0
    ply.OriginalMaxArmor = nil
    ply.TargetMaxArmor = nil
    ply:SetArmor(0)
end)

hook.Add("OnPlayerChangedTeam", "ResetVapeVarsOnJobChange", function(ply, oldTeam, newTeam)
    -- Can reset
    ply.extraHeal = 0
    ply.medVapeTimer = false
    ply.OriginalMaxHealth = nil
    ply:SetMaxHealth(100)

    -- Armor reset
    ply.extraArmor = 0
    ply.OriginalMaxArmor = nil
    ply.TargetMaxArmor = nil
    ply:SetArmor(0)
end)