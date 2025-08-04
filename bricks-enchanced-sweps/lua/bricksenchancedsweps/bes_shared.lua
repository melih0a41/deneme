BES.FText = {}
BES.FText.Nothing = {
    "Nothing to see here...",
    "uWu whats this?"
}

hook.Add( "Initialize", "BES_Initialize_SWEPs", function()
    table.insert( GAMEMODE.Config.DefaultWeapons, "dsr_keys" )
end )