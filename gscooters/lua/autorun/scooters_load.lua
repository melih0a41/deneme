gScooters = {}
gScooters.Config = {}

if (SERVER) then
 --   resource.AddWorkshop("2714313734")

    include("scooters/sh_config.lua")
    include("scooters/language/"..gScooters.Config.Language..".lua")
    include("scooters/shared/sh_scooters.lua")
    include("scooters/shared/sh_gamemodefunctions.lua")
    --include("scooters/shared/sh_darkrp.lua")

    include("scooters/server/sv_functions.lua")
    include("scooters/server/sv_hooks.lua")
    include("scooters/server/sv_net.lua")

    AddCSLuaFile("scooters/sh_config.lua")
    AddCSLuaFile("scooters/language/"..gScooters.Config.Language..".lua")
    AddCSLuaFile("scooters/shared/sh_scooters.lua")
    AddCSLuaFile("scooters/shared/sh_gamemodefunctions.lua")
    --AddCSLuaFile("scooters/shared/sh_darkrp.lua")
    
    AddCSLuaFile("scooters/client/cl_font.lua")
    AddCSLuaFile("scooters/client/cl_gui.lua")
    AddCSLuaFile("scooters/client/cl_derma.lua")
    AddCSLuaFile("scooters/client/cl_util.lua")
    AddCSLuaFile("scooters/client/cl_imgui.lua")

else
    include("scooters/sh_config.lua")
    include("scooters/language/"..gScooters.Config.Language..".lua")
    include("scooters/shared/sh_scooters.lua")
    include("scooters/shared/sh_gamemodefunctions.lua")
    --include("scooters/shared/sh_darkrp.lua")

    include("scooters/client/cl_font.lua")
    include("scooters/client/cl_gui.lua")
    include("scooters/client/cl_derma.lua")
    include("scooters/client/cl_util.lua")
    include("scooters/client/cl_imgui.lua")
end

