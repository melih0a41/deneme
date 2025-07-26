function Corporate_Takeover:RegisterLang(name, short, lang)
    Corporate_Takeover.Language[short] = {
        name = name,
        short = short,
        lang = lang
    }
end

function Corporate_Takeover:Lang(str)
    local lang = Corporate_Takeover.Language[Corporate_Takeover.Config.Language]
    if(!lang) then
        print("CTO ERROR: Language "..Corporate_Takeover.Config.Language.." doesnt seem to exist!")
        return str
    end
    lang = lang.lang

    lang = lang[str]

    if(lang) then
        return lang
    end

    return "#"..str
end

local path = "corporate_takeover/language/"
local files, _ = file.Find(path .. "*", "LUA")

for _, filename in ipairs(files) do
    if string.EndsWith(filename, ".lua") then
        if(SERVER) then
            AddCSLuaFile(path..filename)
            include(path..filename)
        else
            include(path..filename)
        end
    end
end