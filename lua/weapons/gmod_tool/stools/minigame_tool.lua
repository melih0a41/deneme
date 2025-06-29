--[[--------------------------------------------
            Minigame Tool Assistant
--------------------------------------------]]--

TOOL.Name = "Minigame Tool Assistant"
TOOL.Category = "Minigames"

if CLIENT then
    TOOL.Information = {
        { name = "left" },
        { name = "right" },
        { name = "reload" }
    }

    language.Add("tool.minigame_tool.name", "Minigame Tool Assistant")
    language.Add("tool.minigame_tool.desc", Minigames.GetPhrase("tool.desc"))
    language.Add("tool.minigame_tool.left", Minigames.GetPhrase("tool.left"))
    language.Add("tool.minigame_tool.right", Minigames.GetPhrase("tool.right"))
    language.Add("tool.minigame_tool.reload", Minigames.GetPhrase("tool.reload"))
end

--[[----------------------------
       Main Script To Send
----------------------------]]--

function TOOL:LeftClick( trace )
    local owner = self:GetOwner()

    if ( CLIENT ) then return false end
    if not ( Minigames.IsAllowed(owner) ) then return end

    return Minigames.RunEvent.LeftClick(trace, owner)
end


function TOOL:RightClick( trace )
    local owner = self:GetOwner()

    if ( CLIENT ) then return false end
    if not ( Minigames.IsAllowed(owner) ) then return end

    net.Start("Minigames.SetupMenu")
    net.Send(owner)
end


local First = true
function TOOL:Reload( trace )
    local owner = self:GetOwner()

    -- if ( CLIENT ) then return false end
    if not ( Minigames.IsAllowed(owner) ) then return end

    if First and game.SinglePlayer() then
        Minigames.BroadcastMessage( Minigames.GetPhrase("tool.singleplayer") )
        First = false
    end

    Minigames.RunEvent.Reload(trace, owner)
end


function TOOL:Think()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()

    if not ( Minigames.IsAllowed(owner) ) then return end
    --if ( Minigames.ActiveGames[ owner ] ) then return end

    Minigames.RunEvent.Think(trace, owner)
end


function TOOL:Deploy()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()

    if not ( Minigames.IsAllowed(owner) ) then return end

    Minigames.RunEvent.Deploy(trace, owner)
end

function TOOL:Holster()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()

    if not ( Minigames.IsAllowed(owner) ) then return end
    local GameToSpawn = owner:GetInfo("minigames_game")

    if Minigames.Games[ GameToSpawn ] then
        Minigames.Games[ GameToSpawn ]:RollUp( owner, trace )
    end
end

function TOOL:DrawHUD()
    local owner = self:GetOwner()
    if not ( Minigames.IsAllowed(owner) ) then return end

    Minigames.RunEvent.DrawHUD()
end

--[[
local KnownClasses = {
    ["player"] = "Player",
    ["minigame_bigsquare"] = "Minigame",
    ["minigame_boxgame"] = "Minigame",
    ["minigame_npc"] = "MG Bot",
    ["minigame_prop"] = "Minigame",
    ["mingiame_smallquare"] = "Minigame",
    ["minigame_square_base"] = "Minigame",
    ["minigame_square"] = "Minigame",
    ["minigame_trigger"] = "Trigger",
}

function TOOL:DrawToolScreen(width, height)
    local owner = self:GetOwner()
    if not ( Minigames.IsAllowed(owner) ) then return end

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, width, height)

    for i = 1, 50 do
        surface.SetDrawColor(35, 67, 131, 255 - (i * 6))
        surface.DrawRect(4 + ( 6 * i), 8, 4, height / 3.5)
    end

    -- title
    draw.SimpleText("Minigame Tool", "DermaLarge", width / 2, 10, color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText("Assistant", "DermaLarge", width / 2, 40, color_white, TEXT_ALIGN_CENTER)

    -- Has minigame

    if Minigames.ActiveGames[ owner ] then
        local trace = owner:GetEyeTrace()
        local target = trace.Entity
        local targetname = IsValid(target) and target:IsPlayer() and target:Nick() or KnownClasses[ target:GetClass() ] or "None"

        draw.SimpleText("Target: " .. targetname, "DermaLarge", 4, 90, color_white, TEXT_ALIGN_LEFT)

        if IsValid(target) and target:IsPlayer() then
            draw.SimpleText("In game: " .. tostring(target:GetNWBool("Minigames.InGame", false)), "DermaLarge", 4, 140, color_white, TEXT_ALIGN_LEFT)

            if target:GetNWBool("Minigames.InGame", false) then
                draw.SimpleText("Owner:", "DermaLarge", 4, 170, color_white, TEXT_ALIGN_LEFT)
                draw.SimpleText(target:GetNWEntity("Minigames.Owner", NULL):Nick(), "DermaLarge", 4, 200, color_white, TEXT_ALIGN_LEFT)
            end
        end
    else
        draw.SimpleText("No Minigame", "DermaLarge", width / 2, height / 2, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("available", "DermaLarge", width / 2, height / 2 + 30, color_white, TEXT_ALIGN_CENTER)
    end
end
--]]

--[[----------------------------
           Roll Up Event
----------------------------]]--

if SERVER then

    hook.Add("PlayerSwitchWeapon", "Minigame.RollUp", function(owner, old, new)
        if not IsValid( old ) then return end
        if new ~= "gmod_tool" then return end

        if ( Minigames.IsAllowed(owner) ) then
            local oldweapon = old:GetClass()
            local newweapon = new:GetClass()
            local GameToSpawn = owner:GetInfo("minigames_game")
            local CurrentTool = owner:GetInfo("gmod_toolmode")

            if ( oldweapon == "gmod_tool" ) and ( oldweapon ~= newweapon ) and ( CurrentTool == "minigame_tool" ) then
                if Minigames.Games[ GameToSpawn ] then
                    Minigames.Games[ GameToSpawn ]:RollUp( owner, owner:GetEyeTrace() )
                end

                net.Start("Minigames.ToolRollUp")
                    net.WriteString( GameToSpawn )
                net.Send(owner)
            end
        end
    end)

    hook.Add("DoPlayerDeath", "Minigames.RollUpOnDeath", function(ply)
        local TheWeapon = ply:GetActiveWeapon()
        local WeaponClass = IsValid(TheWeapon) and TheWeapon:GetClass() or nil

        if WeaponClass and ( WeaponClass == "gmod_tool" ) and ( ply:GetInfo("gmod_toolmode") == "minigame_tool" ) then
            local GameToSpawn = ply:GetInfo("minigames_game")

            if Minigames.Games[ GameToSpawn ] then
                Minigames.Games[ GameToSpawn ]:RollUp( ply, ply:GetEyeTrace() )
            end

            net.Start("Minigames.ToolRollUp")
                net.WriteString( GameToSpawn )
            net.Send(ply)
        end
    end)

else

    net.Receive("Minigames.ToolRollUp", function()
        local GameToSpawn = net.ReadString()
        if not Minigames.Games[ GameToSpawn ] then return end

        local owner = LocalPlayer()

        Minigames.Games[ GameToSpawn ]:RollUp( owner, owner:GetEyeTrace() )
    end)

    cvars.AddChangeCallback("gmod_toolmode", function(_, old)
        if old == "minigame_tool" then
            local Minigame = GetConVar("minigames_game"):GetString()
            if Minigames.Games[ Minigame ] then
                Minigames.Games[ Minigame ]:RollUp( LocalPlayer(), LocalPlayer():GetEyeTrace() )
            end
        end
    end, "Minigames.RollUp.OnToolChange")

    cvars.AddChangeCallback("minigames_game", function(convar, old)
        if ( convar == "minigames_game" ) and Minigames.Games[ old ] then
            Minigames.Games[ old ]:RollUp( LocalPlayer(), LocalPlayer():GetEyeTrace() )
        end
    end, "Minigames.RollUp.OnGameChange")
end