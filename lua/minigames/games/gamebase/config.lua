--[[--------------------------------------------
            Minigame Module - Config
--------------------------------------------]]--

local ConfigCvarCache = {}

MinigameObject.Config = {}
MinigameObject.ConfigKeys = {}
MinigameObject.ConfigEnums = {}
MinigameObject.ListenerConfig = {}

if SERVER then
    util.AddNetworkString("Minigames.ListenConfig")
end

--[[----------------------------
        Config Functions
----------------------------]]--

function MinigameObject:AddConfig(Name, Config)
    self:Checker(Name, "string", 1)
    self:Checker(Config, "table", 2)

    Name = string.lower( Name )

    Config["type"] = Config["type"]
            or isbool( Config["def"] ) and "boolean"
            or isnumber( Config["def"] ) and "number"
            or istable( Config["def"] ) and "table"
            or nil

    if Config["type"] == "number" then
        Config["dec"] = Config["dec"] or 0

        self.ConfigKeys[ Name ] = function(Val)
            Val = tonumber( Val )

            Val = math.Clamp( Val, Config["min"], Config["max"] )
            Val = math.Round( Val, Config["dec"] )

            return Val
        end
    elseif Config["type"] == "boolean" then
        self.ConfigKeys[ Name ] = function(v)
            return v == 1
        end
    elseif Config["type"] == "table" then
        if not table.IsSequential( Config["def"] ) then
            self.ThrowError("You cannot use a table that is not sequential for the config.", Config["def"], "sequential table")
        end

        self.ConfigKeys[ Name ] = function(v)
            return v -- lmao
        end
    else
        self.ThrowError("You cannot use another type than 'number' or 'boolean' for the config.", Config["type"], "number/boolean/table")
    end

    local Position = table.insert( self.Config, {["Name"] = Name, ["Config"] = Config} )

    return self.Config[ Position ]
end

function MinigameObject:AddHeader(Name)
    self:Checker(Name, "string", 1)

    local Position = table.insert( self.Config, {["Name"] = Name, ["Header"] = true} )

    return self.Config[ Position ]
end

function MinigameObject:GetAllConfig()
    return table.Copy(self.Config)
end

function MinigameObject:GetOwnerConfig(Info)
    self:Checker(Info, "string", 1)
    Info = string.lower( Info )

    local TargetPlayer = SERVER and self:GetOwner() or LocalPlayer()

    local ConvarData = TargetPlayer:GetInfoNum( "minigames_" .. self:GetGameID() .. "_" .. Info, -1 )
    if self.ConfigKeys[ Info ] then
        ConvarData = self.ConfigKeys[ Info ]( ConvarData )
    end

    return ConvarData
end

function MinigameObject:GetConfigCvar(Info)
    self:Checker(Info, "string", 1)
    local CvarName = "minigames_" .. self:GetGameID() .. "_" .. Info

    if ConfigCvarCache[ CvarName ] then
        return ConfigCvarCache[ CvarName ]
    end

    local Cvar = GetConVar( CvarName )

    ConfigCvarCache[ CvarName ] = Cvar

    return Cvar
end

if ( CLIENT ) then

    function MinigameObject:ListenToConfig(Info)
        self:Checker(Info, "string", 1)
        Info = string.lower( Info )

        cvars.AddChangeCallback( "minigames_" .. self:GetGameID() .. "_" .. Info, function()
            if not Minigames.IsAllowed() then return end

            net.Start("Minigames.ListenConfig")
                net.WriteString( Info )
            net.SendToServer()
        end, "Minigames.Config." .. self:GetGameID() .. "." .. Info )
    end

elseif ( SERVER ) then

    function MinigameObject:ListenToConfig(Info, Func)
        self:Checker(Info, "string", 1)
        self:Checker(Func, "function", 2)

        Info = string.lower( Info )
        self.ListenerConfig[ Info ] = Func
    end

    net.Receive("Minigames.ListenConfig", function(_, ply)
        if not Minigames.IsAllowed(ply) then return end

        local GameScript = Minigames.ActiveGames[ ply ]
        if not GameScript then return end

        local InfoName = net.ReadString()
        local NewValue = GameScript:GetOwnerConfig( InfoName )

        if GameScript.ListenerConfig[ InfoName ] then
            GameScript.ListenerConfig[ InfoName ]( GameScript, NewValue )
        end
    end)

end

MinigameObject.GetOwnerInfo = MinigameObject.GetOwnerConfig