--[[------------------------------------------------
                Minigame Leaderboard
------------------------------------------------]]--

AddCSLuaFile()

ENT.PrintName = "Minigame Leaderboard"
ENT.Category = "Minigame Tool Assistant"

ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PlayerList = {}


-- START OF CONFIGURATION

local NetworkingScoreSize = 11 -- https://wiki.facepunch.com/gmod/net.WriteInt

local ColorBackground = Color(0, 0, 0, 250)
local ColorHeader = Color(133, 2, 2, 250)
local TextPlayer, TextKill

if ( CLIENT ) then
    TextPlayer = string.upper( language.GetPhrase("player"):sub(1, 1) ) .. language.GetPhrase("player"):sub(2)
    TextKill = string.upper( language.GetPhrase("playerlist_score"):sub(1, 1) ) .. language.GetPhrase("playerlist_score"):sub(2)
end

-- END OF CONFIGURATION

if ( SERVER ) then
    util.AddNetworkString("Minigames.Leaderboard.Player")
    util.AddNetworkString("Minigames.Leaderboard.PlayerList")
    util.AddNetworkString("Minigames.Leaderboard.Score")
end


--[[------------------------------------------------
                    Functions
------------------------------------------------]]--

local MinBounds = Vector(-512, -512, -512)
local MaxBounds = -MinBounds

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Int", 0, "Wide")
    self:NetworkVar("Int", 1, "Tall")

    self:NetworkVar("Bool", 0, "TimeEnabled")
    self:NetworkVar("Int", 2, "Time")
end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")

    if ( CLIENT ) then
        self:SetRenderBounds(MinBounds, MaxBounds)
    end
end

function ENT:AddPlayer(ply)
    if not IsValid(ply) then return end

    if self.PlayerList[ply] then return end
    table.insert(self.PlayerList, {ply, 0})

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.Player")
        net.WriteEntity(self)
        net.WritePlayer(ply)
        net.WriteBool(true)
    net.Broadcast()
end

function ENT:RemovePlayer(ply)
    if not IsValid(ply) then return end

    for i, v in ipairs(self.PlayerList) do
        if v[1] == ply then
            table.remove(self.PlayerList, i)
            break
        end
    end

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.Player")
        net.WriteEntity(self)
        net.WritePlayer(ply)
        net.WriteBool(false)
    net.Broadcast()
end

function ENT:ResetPlayerList()
    self.PlayerList = {}

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.PlayerList")
        net.WriteEntity(self)
    net.Broadcast()
end




--[[------------------------------------------------
                        Score
------------------------------------------------]]--

function ENT:SortPlayerList()
    table.sort(self.PlayerList, function(a, b)
        return a[2] > b[2]
    end)
end

function ENT:AddPlayerPoint(ply, amount)
    amount = amount or 1

    for i, v in ipairs(self.PlayerList) do
        if v[1] == ply then
            self.PlayerList[i][2] = self.PlayerList[i][2] + amount
            break
        end
    end
    self:SortPlayerList()

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.Score")
        net.WriteEntity(self)
        net.WritePlayer(ply)
        net.WriteInt(amount, NetworkingScoreSize)
    net.Broadcast()
end

function ENT:RemovePlayerPoint(ply, amount)
    amount = math.abs(amount or 1)

    for i, v in ipairs(self.PlayerList) do
        if v[1] == ply then
            self.PlayerList[i][2] = self.PlayerList[i][2] - amount
            break
        end
    end

    self:SortPlayerList()

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.Score")
        net.WriteEntity(self)
        net.WritePlayer(ply)
        net.WriteInt(-amount, NetworkingScoreSize)
    net.Broadcast()
end

function ENT:SetPlayerPoint(ply, amount)
    amount = amount or 0

    for i, v in ipairs(self.PlayerList) do -- im not sorry for this
        if v[1] == ply then
            self.PlayerList[i][2] = amount
            break
        end
    end

    self:SortPlayerList()

    if ( CLIENT ) then return end

    net.Start("Minigames.Leaderboard.Score")
        net.WriteEntity(self)
        net.WritePlayer(ply)
        net.WriteInt(amount, 32)
    net.Broadcast()
end

function ENT:ResetPlayerPoint(ply)
    self:SetPlayerPoint(ply, 0)
end




--[[------------------------------------------------
                     Networking
------------------------------------------------]]--

if ( CLIENT ) then
    net.Receive("Minigames.Leaderboard.Player", function()
        local Leaderboard = net.ReadEntity()
        local ply = net.ReadPlayer()
        local IsJoining = net.ReadBool()

        if not IsValid(Leaderboard) then return end

        if IsJoining then
            Leaderboard:AddPlayer(ply)
        else
            Leaderboard:RemovePlayer(ply)
        end
    end)

    net.Receive("Minigames.Leaderboard.PlayerList", function()
        local Leaderboard = net.ReadEntity()

        if not IsValid(Leaderboard) then return end

        Leaderboard:ResetPlayerList()
    end)

    net.Receive("Minigames.Leaderboard.Score", function()
        local Leaderboard = net.ReadEntity()
        local ply = net.ReadPlayer()
        local amount = net.ReadInt(NetworkingScoreSize)

        if not IsValid(Leaderboard) then return end

        Leaderboard:AddPlayerPoint(ply, amount)
    end)
end




--[[------------------------------------------------
                       Drawing
------------------------------------------------]]--

if ( CLIENT ) then
    function ENT:GetTimeFormat()
        local Time = self:GetTime()
        local Minutes = math.floor(Time / 60)
        local Seconds = Time % 60

        return string.format("%01d:%02d", Minutes, Seconds)
    end

    function ENT:Draw()
        -- self:DrawModel()

        local Pos = self:GetPos()
        local Ang = self:GetAngles()

        -- Pos.z = Pos.z + self:GetTall()
        -- Pos.x = Pos.x - self:GetWide()
        Pos = Pos - self:GetRight() * self:GetTall()
        Pos = Pos - self:GetForward() * self:GetWide()

        local TimeEnabled = self:GetTimeEnabled()
        local TotalTall = self:GetTall() * 2 - (TimeEnabled and 72 or 64)
        local DoubleWide = self:GetWide() * 2

        local PosY = 64 + (TimeEnabled and 32 or 0)

        -- Front
        cam.Start3D2D(Pos, Ang, 1)
            draw.RoundedBox(16, 0, 0, DoubleWide, self:GetTall() * 2, ColorBackground)

            -- Header
            draw.RoundedBox(16, 8, 8, DoubleWide - 16, 50, ColorHeader)
            draw.SimpleText(Minigames.GetPhrase("deathmatch.leaderboard"), "DermaLarge", self:GetWide(), 16, color_white, TEXT_ALIGN_CENTER)

            if TimeEnabled then
                draw.SimpleText(self:GetTimeFormat(), "DermaLarge", self:GetWide(), 60, color_white, TEXT_ALIGN_CENTER)
            end

            -- Sub header
            draw.RoundedBox(0, 8, PosY, DoubleWide - 16, 2, color_white)
            draw.SimpleText(TextPlayer, "DermaLarge", 16, PosY, color_white, TEXT_ALIGN_LEFT)
            draw.SimpleText(TextKill, "DermaLarge", DoubleWide - 16, PosY, color_white, TEXT_ALIGN_RIGHT)
            draw.RoundedBox(0, 8, PosY + 32, DoubleWide - 16, 2, color_white)

            for i, tbl in ipairs(self.PlayerList) do
                local TargetPosY = 32 * i + (TimeEnabled and 100 or 72)

                -- Overflow
                if (TargetPosY > TotalTall) then
                    draw.SimpleText(Minigames.StringFormat(Minigames.GetPhrase("deathmatch.leaderboard.andmore"), #self.PlayerList - i + 1), "DermaLarge", self:GetWide(), TargetPosY, color_white, TEXT_ALIGN_CENTER)
                    break
                end

                draw.SimpleText(tbl[1]:Nick(), "DermaLarge", 16, TargetPosY, color_white, TEXT_ALIGN_LEFT)
                draw.SimpleText(tbl[2], "DermaLarge", DoubleWide - 16, TargetPosY, color_white, TEXT_ALIGN_RIGHT)
            end
        cam.End3D2D()
    end
end