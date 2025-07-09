/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

OnePrint = OnePrint or {}

local tLoad = {
    sh = function( sFilePath )
        if SERVER then
            AddCSLuaFile( "oneprint/" .. sFilePath )
            include( "oneprint/" .. sFilePath )
        end
        if CLIENT then
            include( "oneprint/" .. sFilePath )
        end
    end,
    sv = function( sFilePath )
        if SERVER then
            include( "oneprint/" .. sFilePath )
        end
    end,
    cl = function( sFilePath )
        if SERVER then
            AddCSLuaFile( "oneprint/" .. sFilePath )
        end
        if CLIENT then
            include( "oneprint/" .. sFilePath )
        end
    end
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

--[[

    loadTabs

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

local function loadTabs()
    local tFiles, _ = file.Find( "oneprint/client/vgui/tabs/*", "LUA")

    if ( #tFiles >= 1 ) then
        for k, v in pairs( tFiles ) do
            tLoad.cl( "client/vgui/tabs/" .. v )
        end
    end
end

--[[

    OnGamemodeLoaded

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

hook.Add( "OnGamemodeLoaded", "OnePrint_OnGamemodeLoaded", function()
    tLoad.sh( "config.lua" )
    tLoad.sh( "shared/i18n/" .. ( OnePrint.Cfg.Language or "en" ) .. ".lua" )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

    tLoad.sh( "shared/util.lua" )
    tLoad.sh( "shared/init.lua" )
    tLoad.sh( "shared/player.lua" )    

    tLoad.sv( "server/util.lua" )
    tLoad.sv( "server/init.lua" )
    tLoad.sv( "server/hooks.lua" )

    tLoad.cl( "client/init.lua" )
    tLoad.cl( "client/vgui/3d2dvgui.lua" )
    tLoad.cl( "client/vgui/derma.lua" )

    loadTabs()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    hook.Run( "OnePrint_OnLoaded" )
    print( "-------------------------\n[OnePrint] Script loaded\n-------------------------\n" )

    tLoad = nil
    loadTabs = nil

    hook.Remove( "OnGamemodeLoaded", "OnePrint_OnGamemodeLoaded" )
end )
