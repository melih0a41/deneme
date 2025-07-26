////////////////////////////////
//                            //
//     Corporate Takeover     //
//     By KiwontaTv & Ian     //
//                            //
//           04/2025          //
//                            //
//     STEAM_0:0:178850058    //
//     STEAM_0:1:153915274    //
//                            //
//        Configuration       //
//                            //
////////////////////////////////

print("Loading Corporate Takeover...")

// Table structure
Corporate_Takeover = Corporate_Takeover || {} // Base addon

Corporate_Takeover.Language = Corporate_Takeover.Language || {} // Language

Corporate_Takeover.Config = Corporate_Takeover.Config || {} // Config
Corporate_Takeover.Config.Colors = Corporate_Takeover.Config.Colors || {} // Colors
Corporate_Takeover.Config.Sounds = Corporate_Takeover.Config.Sounds || {} // Sounds

Corporate_Takeover.Corps = Corporate_Takeover.Corps || {} // Corporations
Corporate_Takeover.Desks = Corporate_Takeover.Desks || {} // Desks
Corporate_Takeover.Researches = Corporate_Takeover.Researches || {} // Researches

Corporate_Takeover.InitialSpawnCache = Corporate_Takeover.InitialSpawnCache || {} // First time connected players cache

Corporate_Takeover.Version = "1.0"

local files = {
    -- Server
    {
        "sh/sh_lang.lua",
        "sh/sh_adddesks.lua",

        "config/sh_config.lua",
        "config/sh_expert.lua",
        "config/sh_desks.lua",
        "config/sh_npcs.lua",

        "sv/sv_network.lua",
        "sv/sv_util.lua",
        "sv/sv_init.lua",
        "sh/sh_init.lua",
    },

    -- Client
    {
        "sh/sh_lang.lua",
        "sh/sh_adddesks.lua",

        "config/sh_config.lua",
        "config/sh_expert.lua",
        "config/sh_desks.lua",
        "config/sh_npcs.lua",

        "cl/cl_init.lua",
        "cl/cl_fonts.lua",
        "cl/cl_worker_menu.lua",

        "vgui/cl_vgui_bar.lua",
        "vgui/cl_vgui_button.lua",
        "vgui/cl_vgui_main.lua",
        "vgui/cl_vgui_textentry.lua",

        "sh/sh_init.lua",
    }
}

for k, _files in ipairs(files) do
    for _, v in ipairs(_files) do
        if(k == 1 && SERVER) then
            include("corporate_takeover/"..v)
        end

        if(k == 2) then
            if(SERVER) then
                AddCSLuaFile("corporate_takeover/"..v)
            else
                include("corporate_takeover/"..v)
            end
        end
    end
end

print("Successfully loaded Corporate Takeover v"..Corporate_Takeover.Version)