--[[--------------------------------------------
            Minigame Module - Owner
--------------------------------------------]]--

MinigameObject.__Owner = NULL
MinigameObject.__OwnerID = ""

if SERVER then
    util.AddNetworkString("Minigames.OwnerToolTip")
end

--[[----------------------------
        Trigger Functions
----------------------------]]--

function MinigameObject:GetOwner()
    return self.__Owner
end

function MinigameObject:GetOwnerID()
    return self.__OwnerID
end

function MinigameObject:GetOwnerName()
    return self.__Owner:Nick()
end

function MinigameObject:SetOwner(Owner)
    self:Checker(Owner, "player", 1)

    Owner:SetNWBool("Minigames.HasGame", true)

    self.__Owner = Owner
    self.__OwnerID = Owner:SteamID()

    self.SetOwner = nil
end

function MinigameObject:SendToolTip(msg, notify, length)
    if CLIENT then return end

    self:Checker(msg, "string/table", 1)
    local arg = ""

    if istable(msg) then
        arg = msg[2]
        msg = msg[1]
    end

    net.Start("Minigames.OwnerToolTip")
        net.WriteString(msg)
        net.WriteUInt(notify or 0, 3)
        net.WriteFloat(length or 5)
        net.WriteString(arg)
    net.Send(self:GetOwner())
end

if CLIENT then
    net.Receive("Minigames.OwnerToolTip", function()
        local phrase = Minigames.GetPhrase(net.ReadString())
        local notify = net.ReadUInt(3)
        local length = net.ReadFloat()
        local arg = net.ReadString()

        if arg ~= "" then
            phrase = string.format(phrase, arg)
        end

        notification.AddLegacy(phrase, notify, length)
        surface.PlaySound( "buttons/lightswitch2.wav" )
    end)
end