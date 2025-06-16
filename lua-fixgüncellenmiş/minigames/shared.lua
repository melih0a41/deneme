--[[--------------------------------------------
                Minigame Shared
--------------------------------------------]]--

function Minigames.IsAllowed(ply, action)
    action = action or "basic"
    ply = CLIENT and LocalPlayer() or ply
    if not IsValid(ply) then return false end

    if ply:IsListenServerHost() then return true end

    -- Rate limiting check
    if SERVER and Minigames.CheckRateLimit and (action == "network" or action == "create_game") then
        if not Minigames.CheckRateLimit(ply, action, 5, 10) then
            return false
        end
    end

    if Minigames.Config["UseFunction"] then
        return Minigames.Config["AllowUserFunction"](ply) == true
    end

    return Minigames.Config["AllowUserGroup"][ply:GetUserGroup()] == true
end

function Minigames.StringFormat(phrase, ...)
    local output = phrase

    for i, arg in ipairs({...}) do
        if not isnumber(arg) and IsValid( arg ) and ( arg:IsPlayer() ) then
            output = output:gsub("%%ply", arg:Nick(), 1)
            continue
        end

        output = output:gsub("%%str", arg, 1)
    end

    return output
end

--[[----------------------------
           Load Folders
----------------------------]]--

if SERVER then
    Minigames.SendCS("minigames/enum.lua")
end
Minigames.AddInc("minigames/enum.lua")

function Minigames.AddFilesDir(Dir, Index, OnlyCS)
    Dir = "minigames/" .. Dir

    local FullPath = Dir .. "/*"
    local Files, _ = file.Find(FullPath, "LUA")

    if Index then
        if SERVER then
            Minigames.AddInc(Dir .. "/" .. Index .. ".lua")
            Minigames.SendCS(Dir .. "/" .. Index .. ".lua")
        else
            Minigames.AddInc(Dir .. "/" .. Index .. ".lua")
        end
    end

    for _, File in ipairs(Files) do
        if ( not OnlyCS ) and ( File == Index .. ".lua" ) then continue end

        if SERVER then
            if not OnlyCS then
                Minigames.AddInc(Dir .. "/" .. File)
            end
            Minigames.SendCS(Dir .. "/" .. File)
        else
            Minigames.AddInc(Dir .. "/" .. File)
        end
    end
end

function Minigames.AddGamesFiles()
    print("[Minigames] Gamebase dosyaları yükleniyor...")
    
    -- 1. ÖNCELİK: Base dosyasını yükle
    if SERVER then
        Minigames.SendCS("minigames/games/gamebase/base.lua")
    end
    Minigames.AddInc("minigames/games/gamebase/base.lua")
    
    -- 2. MinigameObject kontrol
    timer.Simple(0.1, function()
        if not MinigameObject then
            error("[Minigames] HATA: MinigameObject yüklenemedi!")
        else
            print("[Minigames] MinigameObject başarıyla yüklendi")
        end
    end)
    
    -- 3. Gamebase modüllerini sıralı yükle
    local gamebaseModules = {
        "customvar.lua",
        "owner.lua", 
        "config.lua",
        "network.lua",
        "entity.lua",     -- Kritik: Entity sistemi
        "trigger.lua",
        "timer.lua",
        "hook.lua",
        "sound.lua",
        "voice.lua",
        "player.lua",
        "playerlist.lua",
        "bot.lua",
        "reward.lua"
    }
    
    for i, module in ipairs(gamebaseModules) do
        local fullPath = "minigames/games/gamebase/" .. module
        
        if SERVER then
            Minigames.SendCS(fullPath)
        end
        Minigames.AddInc(fullPath)
        
        -- Entity.lua özel kontrolü
        if module == "entity.lua" then
            timer.Simple(0.2, function()
                if MinigameObject and MinigameObject.CreateEntity then
                    print("[Minigames] ✓ Entity sistemi başarılı!")
                else
                    print("[Minigames] ✗ Entity sistemi başarısız!")
                    -- Acil düzeltme
                    if MinigameObject then
                        MinigameObject.__Entities = {}
                        MinigameObject.__EntitiesAlias = {}
                        function MinigameObject:CreateEntity(Class, AliasTable)
                            local ent = ents.Create(Class)
                            if IsValid(ent) and self.GetOwner then
                                ent:Setowning_ent(self:GetOwner())
                            end
                            self.__Entities[ent] = true
                            return ent
                        end
                        print("[Minigames] Acil entity sistemi eklendi!")
                    end
                end
            end)
        end
    end
    
    -- 4. Oyun dosyalarını yükle
    local gameFiles = file.Find("minigames/games/*.lua", "LUA")
    for _, gameFile in ipairs(gameFiles) do
        if SERVER then
            Minigames.SendCS("minigames/games/" .. gameFile)
        end
        Minigames.AddInc("minigames/games/" .. gameFile)
    end
    
    print("[Minigames] Tüm dosyalar yüklendi!")
end

if SERVER then
    Minigames.SendCS("minigames/cl_init.lua")
else
    Minigames.AddInc("minigames/cl_init.lua")
end
Minigames.AddFilesDir("vgui", nil, true)
Minigames.AddGamesFiles()
Minigames.AddFilesDir("rewards", "rewardbase")

--[[----------------------------
           Refresh Files
----------------------------]]--

if SERVER then
    net.Receive("Minigames.RefreshFiles", function(_, ply)
        if not Minigames.IsAllowed(ply) then return end

        Minigames.Games = {}
        Minigames.ClearRewards()

        Minigames.SendCS("minigames/cl_init.lua")
        Minigames.AddFilesDir("vgui", nil, true)
        Minigames.AddGamesFiles()
        Minigames.AddFilesDir("rewards", "rewardbase")

        net.Start("Minigames.RefreshFiles")
        net.Broadcast()
    end)
else
    net.Receive("Minigames.RefreshFiles", function()
        Minigames.Games = {}
        Minigames.ClearRewards()

        Minigames.AddInc("minigames/enum.lua")
        Minigames.AddInc("minigames/cl_init.lua")
        Minigames.AddFilesDir("vgui", nil, true)
        Minigames.AddGamesFiles()
        Minigames.AddFilesDir("rewards", "rewardbase")
    end)
end


concommand.Add("minigames_reload", function(ply)
    if SERVER then
        Minigames.Games = {}
        Minigames.ClearRewards()

        Minigames.SendCS("minigames/enum.lua")
        Minigames.AddInc("minigames/enum.lua")
        Minigames.SendCS("minigames/cl_init.lua")
        Minigames.AddFilesDir("vgui", nil, true)
        Minigames.AddGamesFiles()
        Minigames.AddFilesDir("rewards", "rewardbase")

        net.Start("Minigames.RefreshFiles")
        net.Broadcast()
    else
        if not Minigames.IsAllowed() then return end

        net.Start("Minigames.RefreshFiles")
        net.SendToServer()
    end
end)

--[[----------------------------
            Tool Events
----------------------------]]--

function Minigames.RunEvent.Reload(trace, owner)
    if not Minigames.IsAllowed(owner) then return end
    if not Minigames.ActiveGames[ owner ] then return end

    return Minigames.ActiveGames[ owner ]:Reload( trace, owner )
end


function Minigames.RunEvent.Think(trace, owner)
    if not Minigames.IsAllowed(owner) then return end

    local GameToSpawn = owner:GetInfo("minigames_game")
    if ( Minigames.Games[ GameToSpawn ] == nil ) then return end

    Minigames.Games[ GameToSpawn ]:Think( trace, owner )
end

function Minigames.RunEvent.Deploy(trace, owner)
    if not Minigames.IsAllowed(owner) then return end

    local GameToSpawn = owner:GetInfo("minigames_game")
    if Minigames.Games[ GameToSpawn ] == nil then return end

    Minigames.Games[ GameToSpawn ]:Deploy( trace, owner )
end

function Minigames.RunEvent.RollUp(trace, owner)
    if not Minigames.IsAllowed(owner) then return end

    local GameToSpawn = owner:GetInfo("minigames_game")
    if Minigames.Games[ GameToSpawn ] == nil then return end

    Minigames.Games[ GameToSpawn ]:RollUp( trace, owner )
end

function Minigames.RunEvent.DrawHUD()
    local owner = LocalPlayer()
    if not Minigames.IsAllowed(owner) then return end

    local GameToSpawn = owner:GetInfo("minigames_game")
    if Minigames.Games[ GameToSpawn ] == nil then return end
    if Minigames.Games[ GameToSpawn ].DrawHUD == nil then return end

    Minigames.Games[ GameToSpawn ]:DrawHUD()
end

--[[----------------------------
          Util Functions
----------------------------]]--

function Minigames.GetOwnerGame( owner )
    return Minigames.ActiveGames[ owner ]
end

function Minigames.PlayerInGame( ply )
    return ply:GetNWBool("Minigames.InGame", false), ply:GetNWEntity("Minigames.Owner", NULL)
end

function Minigames.PlayerIsPlaying( ply )
    local InGame, Owner = Minigames.PlayerInGame( ply )

    return ( InGame == true ) and IsValid( Owner )
end