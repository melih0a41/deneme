hook.Add("canDropWeapon", "SV_DoNotDropGasolinePistol", function(ply, weapon)
    if not IsValid(weapon) then return end
    if weapon:GetClass() == "weapon_gasolinepistol" then
        return false
    end
end)