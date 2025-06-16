--[[--------------------------------------------
             Minigames Addon (v2.1.0)
             Fixed and Optimized Version
--------------------------------------------]]--

if SERVER then
    resource.AddWorkshop("2991932872")
end

Minigames = Minigames or {}
Minigames.Language = Minigames.Language or {}
Minigames.Config = Minigames.Config or {}
Minigames.RunEvent = Minigames.RunEvent or {}
Minigames.ActiveGames = Minigames.ActiveGames or {}
Minigames.Games = Minigames.Games or {}

-- Constants
Minigames.DefaultUIntSize = 8
Minigames.MAX_ENTITIES_PER_GAME = 250 -- Reduced from 500
Minigames.VERSION = "2.1.0"

-- Color constants
local COLORS = {
    WHITE = Color(240, 240, 240),
    CYAN = Color(148, 245, 229),
    YELLOW = Color(228, 215, 104)
}

-- Safe console output
local function SafeMsgC(...)
    if MsgC then
        MsgC(...)
    end
end

Minigames.DefaultUIntSize = 8

local CYAN = Color(148, 245, 229)
local WHITE = Color(240, 240, 240)
local YELLOW = Color(228, 215, 104)
local realm = SERVER and CYAN or YELLOW

MsgC( WHITE, "===============================================", "\n" )
MsgC( WHITE, "===============", CYAN, " Minigames Tools ", WHITE, "===============", "\n" )
MsgC( WHITE, "===============================================", "\n" )

--[[----------------------------
          Pre Functions
----------------------------]]--

function Minigames.SendCS(File)
    if CLIENT then return end

    AddCSLuaFile(File)
    MsgC(WHITE, "[Minigames] Added CS:  ", CYAN, File, "\n")
end

function Minigames.AddInc(File)
    MsgC(WHITE, "[Minigames] Included:  ", realm, File, "\n")
    return include(File)
end


--[[----------------------------
        Throw Error (v2)
----------------------------]]--

local isstring = isstring
local isnumber = isnumber
local istable = istable
local isbool = isbool
local IsValid = IsValid
local isvector = isvector
local isangle = isangle
local isfunction = isfunction

local VERIFICATION_TYPE = {
    ["string"] = isstring,
    ["number"] = isnumber,
    ["table"] = istable,
    ["bool"] = isbool,
    ["boolean"] = isbool,
    ["player"] = function(v) return IsValid(v) and v:IsPlayer() end,
    ["mg_npc"] = function(v) return IsValid(v) and v:GetClass() == "minigame_npc" end,
    ["entity"] = IsValid,
    ["vector"] = isvector,
    ["angle"] = isangle,
    ["function"] = isfunction
}

local FuncMatchRegEx = {
    "Gemini:(.*)%(",
    "(.*)%.(.*)%(",
    "(.*)%(",
    "self:(.*)%("
}

local LuaRun = {
    ["@lua_run"] = true, -- Server
    ["@LuaCmd"] = true -- Client
}

function Minigames.ThrowError(Message, Value, Expected, OneMore)
    local Data = debug.getinfo(3 + (OneMore and 2 or 0)) or debug.getinfo(2)

    local FilePath = LuaRun[ Data["source"] ] and "Console" or "lua/" .. string.match(Data["source"], "lua/(.*)")
    local File = ( FilePath == "Console" ) and "Console" or file.Read(FilePath, "GAME")
    
    -- FIX: File nil kontrolü
    if not File then 
        error("\n[Minigames Error] " .. Message .. "\nValue: " .. tostring(Value) .. "\nExpected: " .. Expected)
        return 
    end
    
    local Line = string.Trim( string.Explode("\n", File)[Data["currentline"]] )

    local ErrorLine = "\t\t" .. Data["currentline"]
    local ErrorPath = "\t" .. FilePath
    local ErrorFunc = nil
    local ErrorArg = "\t" .. ( isstring(Value) and "\"" or "" ) .. tostring(Value) .. ( isstring(Value) and "\"" or "" ) .. " (" .. type(Value) .. ")"

    for _, regex in ipairs(FuncMatchRegEx) do
        ErrorFunc = string.match(Line, regex)
        if ErrorFunc then break end
    end

    ErrorFunc = "\t" .. (ErrorFunc or "Unknown") .. "(...)"
    Expected = "\t" .. Expected

    error("\n" .. string.format([[
========  Minigames ThrowError  ========
- Error found in: %s
- In the line: %s
- In the function: %s

- Argument: %s
- Expected: %s

- Error Message: %s
  
========  Minigames ThrowError  ========]], ErrorPath, ErrorLine, ErrorFunc, ErrorArg, Expected, Message))
end

function Minigames.Checker(...)
    local InfoTable = {...}

    if not istable(InfoTable) then
        Minigames.ThrowError([[The first argument of Checker() must be a table.]], InfoTable, "table")
    elseif ( #InfoTable ~= 3 ) then
        Minigames.ThrowError([[The first argument of Checker() must have at least 3 values.]], InfoTable, "table")
    end

    local ValueToCheck = InfoTable[1]
    local ExpectedType = string.lower(InfoTable[2])
    local ArgumentPos = InfoTable[3]

    local ExpectedTypes = string.Explode("/", ExpectedType)

    if #ExpectedTypes > 1 then
        for _, Type in ipairs(ExpectedTypes) do
            if not VERIFICATION_TYPE[ Type ] then
                Minigames.ThrowError([[The second argument of Checker() must be a valid type.]], ExpectedType, "ExpectedType")
            end
        end
    else
        if not VERIFICATION_TYPE[ ExpectedType ] then
            Minigames.ThrowError([[The second argument of Checker() must be a valid type.]], ExpectedType, "a valid type")
        end
    end

    if not isnumber(ArgumentPos) then
        Minigames.ThrowError([[The third argument of Checker() must be a number.]], ArgumentPos, "number")
    end

    local LuaDataInfo = debug.getinfo(3)

    if #ExpectedTypes > 1 then
        local Found = false
        for _, Type in ipairs(ExpectedTypes) do
            if VERIFICATION_TYPE[ Type ](ValueToCheck) then
                Found = true
                break
            end
        end

        if not Found then
            local Phrase = "The " .. string.CardinalToOrdinal(ArgumentPos) .. " argument of the function " .. ( LuaDataInfo["name"] or "Console" ) .. "() must be a valid value."
            Minigames.ThrowError(Phrase, ValueToCheck, ExpectedType, true)
        end
    else
        if not VERIFICATION_TYPE[ ExpectedType ](ValueToCheck) then
            local Phrase = "The " .. string.CardinalToOrdinal(ArgumentPos) .. " argument of the function " .. ( LuaDataInfo["name"] or "Console" ) .. "() must be a " .. ExpectedType .. "."
            Minigames.ThrowError(Phrase, ValueToCheck, ExpectedType, true)
        end
    end

    if ExpectedType == "string" and ( ValueToCheck == "" ) then
        local Phrase = "The " .. string.CardinalToOrdinal(ArgumentPos) .. " argument of the function " .. LuaDataInfo["name"] .. "() must not be empty."
        Minigames.ThrowError(Phrase, ValueToCheck, ExpectedType, true)
    end
end

--[[----------------------------
        Performance Monitoring
----------------------------]]--

if SERVER then
    Minigames.PerformanceStats = {
        gamesCreated = 0,
        entitiesCreated = 0,
        playersInGames = 0,
        lastCleanup = CurTime()
    }
    
    -- Cleanup function
    local function PerformanceCleanup()
        local currentTime = CurTime()
        
        if currentTime - Minigames.PerformanceStats.lastCleanup > 300 then
            local cleaned = 0
            
            for owner, game in pairs(Minigames.ActiveGames) do
                if not IsValid(owner) then
                    if game and game.SafeRemoveActiveGame then
                        game:SafeRemoveActiveGame()
                    end
                    Minigames.ActiveGames[owner] = nil
                    cleaned = cleaned + 1
                end
            end
            
            Minigames.PerformanceStats.lastCleanup = currentTime
        end
    end
    
    timer.Create("Minigames.PerformanceCleanup", 60, 0, PerformanceCleanup)
end

--[[----------------------------
        Load All files
----------------------------]]--

if SERVER then
    Minigames.SendCS("minigames/configuration.lua")
    Minigames.SendCS("minigames/languages/__language.lua")
    Minigames.SendCS("minigames/enum.lua")
    Minigames.SendCS("minigames/shared.lua")
    Minigames.SendCS("minigames/cl_init.lua")

    Minigames.AddInc("minigames/configuration.lua")
    Minigames.AddInc("minigames/languages/__language.lua")
    Minigames.AddInc("minigames/enum.lua")
    Minigames.AddInc("minigames/shared.lua")
    Minigames.AddInc("minigames/init.lua")
else
    Minigames.AddInc("minigames/configuration.lua")
    Minigames.AddInc("minigames/languages/__language.lua")
    Minigames.AddInc("minigames/enum.lua")
    Minigames.AddInc("minigames/shared.lua")
end

-- 76561198307194389