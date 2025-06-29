--[[--------------------------------------------
                Language Module
--------------------------------------------]]--

local Directory = "minigames/languages/"
do
    local languages = file.Find( Directory .. "*", "LUA" )
    for _, v in ipairs( languages ) do
        if ( v == "__language.lua" ) then continue end

        if string.EndsWith( v, ".lua" ) then

            if SERVER then
                Minigames.SendCS( Directory .. v)
            end
            Minigames.AddInc( Directory .. v)

        end
    end
end

function Minigames.GetPhrase(phrase)
    return Minigames.Language[ Minigames.Config["MainLang"] ] and Minigames.Language[ Minigames.Config["MainLang"] ][phrase] or Minigames.Language["english"][phrase] or phrase
end