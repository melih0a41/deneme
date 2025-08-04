local replacementWeapons = { 
    ["keys"] = "dsr_keys"
}

local function TakeSWEPs( ply )
    timer.Simple( 0.1, function()
        if( not IsValid( ply ) ) then return end

        for k, v in pairs( replacementWeapons ) do
            if( ply:HasWeapon( k ) ) then
                ply:StripWeapon( k )
            end
        end
    end )
end
hook.Add( "PlayerLoadout", "BES_PlayerLoadout_TakeSWEPs", TakeSWEPs )

hook.Add( "CanPlayerSuicide", "BESHooks_CanPlayerSuicide_Prevent", function( ply )
    if( ply:GetNWBool( "BES_CUFFED", false ) or ply:GetNWBool( "BES_TASERED", false ) ) then
        return false
    end
end )