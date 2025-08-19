CreateConVar('graffiti_admins_only', 0, FCVAR_NONE, nil, 0, 1)
CreateConVar('graffiti_can_sounds', 1, FCVAR_NONE, nil, 0, 1)
CreateConVar('graffiti_can_particle', 1, FCVAR_NONE, nil, 0, 1)
CreateConVar('graffiti_explosion', 0, FCVAR_NONE, nil, 0, 1)
CreateConVar('graffiti_max_distance', 140, FCVAR_NONE, nil, 140, 100000)

concommand.Add('graffiti_clear', function(ply, cmd, args)
    if (SERVER) and (ply:IsAdmin()) and (ply:IsValid()) then
        for i, ply in ipairs(player.GetAll()) do
            ply:ConCommand('r_cleardecals')
        end
    end
end)

concommand.Add('graffiti_delete_settings', function(ply, cmd, args)
    if (ply:IsValid()) then
        if (tostring(file.Find('graffiti-swep/graffiti-settings.txt', 'DATA')[1]) == 'graffiti-settings.txt') then
            file.Delete('graffiti-swep/graffiti-settings.txt')
        end
        if (tostring(file.Find('graffiti-swep/graffiti-settings-client.txt', 'DATA')[1]) == 'graffiti-settings-client.txt') then
            file.Delete('graffiti-swep/graffiti-settings-client.txt')
        end
        if (ply:IsSuperAdmin()) and (tostring(file.Find('graffiti-swep/graffiti-settings-server.txt', 'DATA')[1]) == 'graffiti-settings-server.txt') then
            file.Delete('graffiti-swep/graffiti-settings-server.txt')
        end
        print('[graffiti-swep] Settings deleted!')
    end
end)

-- cvars.AddChangeCallback('graffiti_can_particle', function(convar_name, value_old, value_new)
--     if (game.SinglePlayer() == false) then
--         for i, ply in ipairs(player.GetAll()) do
--             if (value_new == '1.00') then
--                 ply:SendLua('LocalPlayer():SetNWBool("GraffitiCanParticle", true)')
--             elseif (value_new == '0.00') then
--                 ply:SendLua('LocalPlayer():SetNWBool("GraffitiCanParticle", false)')
--             end
--         end
--     end
-- end)