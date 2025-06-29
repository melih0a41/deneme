--[[--------------------------------------------
            Minigame Module - Util
--------------------------------------------]]--

if SERVER then
    util.AddNetworkString("Minigames.PlaySound")
    util.AddNetworkString("Minigames.PlayWorldSound")
end

local MUSIC_PLAY = 1
local MUSIC_STOP = 2
local MUSIC_STOPALL = 3

local DefaultUInt = 2

--[[----------------------------
            PlaySound
----------------------------]]--

function MinigameObject:PlaySound(Targets, Snd)
    if CLIENT then return end

    Targets = ( IsValid(Targets) and Targets:IsPlayer() ) and {Targets} or Targets

    self:Checker(Targets, "table", 1)
    self:Checker(Snd, "string", 2)

    net.Start("Minigames.PlaySound")
        net.WriteString(Snd)
    net.Send(Targets)
end

net.Receive("Minigames.PlaySound", function()
    surface.PlaySound(net.ReadString())
end)

function MinigameObject:PlayGameStartSound()
    local Players = self:GetPlayers(true)
    table.insert(Players, self:GetOwner())

    self:PlaySound(Players, Minigames.Config["OnBeginGameSound"])
end

function MinigameObject:PlayGameEndSound()
    local Players = self:GetPlayers(true)
    table.insert(Players, self:GetOwner())

    self:PlaySound(Players, Minigames.Config["OnStopGameSound"])
end


--[[----------------------------
        Background Music
----------------------------]]--

MinigameObject.__LoadedSounds = {}
MinigameObject.__CurrentSound = nil

function MinigameObject:PlayWorldSound( FileName, IsLoop, Targets )
    if SERVER then
        net.Start("Minigames.PlayWorldSound")
            net.WritePlayer(self:GetOwner())
            net.WriteUInt(MUSIC_PLAY, DefaultUInt)
            net.WriteString(FileName)
            net.WriteBool(IsLoop or false)

        if IsValid(Targets) then
            net.Send(Targets)
        else
            Targets = self:GetPlayers(true)
            table.insert(Targets, self:GetOwner())
            net.Send(Targets)
        end

        return
    end

    sound.PlayFile(FileName, "noplay", function( WorldSound, ErrorID, ErrorName )
        if IsValid(WorldSound) then
            self.__LoadedSounds[FileName] = WorldSound

            if IsValid(self.__CurrentSound) then
                self.__CurrentSound:Stop()
            end

            self.__CurrentSound = WorldSound

            WorldSound:Play()
            WorldSound:SetVolume( Minigames.Config["PlayMusicVolume"] )
            WorldSound:SetTime(0)

            if IsLoop then
                WorldSound:EnableLooping(true)
            end
        else
            Minigames.ThrowError("There was a problem playing the sound file", ErrorID, ErrorName)
        end
    end)
end

function MinigameObject:StopWorldSound( FileName )
    if SERVER then
        net.Start("Minigames.PlayWorldSound")
            net.WritePlayer(self:GetOwner())
            net.WriteUInt(MUSIC_STOP, DefaultUInt)
            net.WriteString(FileName)
        net.Broadcast()

        return
    end

    if FileName == nil and IsValid(self.__CurrentSound) then
        self.__CurrentSound:Stop()
        self.__CurrentSound = nil
    end

    if self.__LoadedSounds[FileName] then
        self.__LoadedSounds[FileName]:Stop()
        self.__LoadedSounds[FileName] = nil
    end
end

function MinigameObject:StopAllWorldSounds(Target)
    if SERVER then
        net.Start("Minigames.PlayWorldSound")
            net.WritePlayer(self:GetOwner())
            net.WriteUInt(MUSIC_STOPALL, DefaultUInt)
        if istable(Target) or ( isentity(Target) and Target:IsPlayer() ) then
            net.Send(Target)
        else
            net.Broadcast()
        end

        return
    end

    if IsValid(self.__CurrentSound) then
        self.__CurrentSound:Stop()
        self.__CurrentSound = nil
    end

    for _, Sound in pairs(self.__LoadedSounds) do
        if IsValid(Sound) then
            Sound:Stop()
        end
    end

    self.__LoadedSounds = {}
end

if CLIENT then
    net.Receive("Minigames.PlayWorldSound", function()
        local Owner = net.ReadPlayer()
        local GameScript = Minigames.GetOwnerGame(Owner)

        if not istable(GameScript) then return end

        local Action = net.ReadUInt(DefaultUInt)
        local FileName = net.ReadString()

        if Action == MUSIC_PLAY then
            GameScript:PlayWorldSound(FileName, net.ReadBool())
        elseif Action == MUSIC_STOP then
            GameScript:StopWorldSound(FileName)
        elseif Action == MUSIC_STOPALL then
            GameScript:StopAllWorldSounds()
        end
    end)
end