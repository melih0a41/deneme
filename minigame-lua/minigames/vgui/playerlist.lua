--[[--------------------------------------------
              Minigame Setup Menu
--------------------------------------------]]--

local Background = Color(30, 30, 30, 180)
local Grayest = Color(170, 170, 170, 40)

local PLAYER_OWNER = 1
local PLAYER_INGAME = 2
local PLAYER_INGAME_OTHER = 3
local PLAYER_NOT_INGAME = 4

local PlayerPaintColor = {
    [PLAYER_OWNER]          = Color(0, 140, 140, 215),
    [PLAYER_INGAME]         = Color(0, 200, 0, 215),
    [PLAYER_INGAME_OTHER]   = Color(140, 140, 0, 215),
    [PLAYER_NOT_INGAME]     = Color(100, 100, 100, 215),
}

local PlayerButtonPaint = function(self, w, h)
    draw.RoundedBox( 4, 0, 0, w, h, Background )
    draw.RoundedBox( 4, 0, 0, 16, h, PlayerPaintColor[self.State] )
end


local ButtonStyleBackground = Color(58, 58, 58, 150)
local ButtonStyleDisabled = Color(0, 0, 0, 100)
local BlackBackground = Color(0, 0, 0, 40)

local ShadingColor = {}
for i = 1, 16 do
    ShadingColor[i] = Color(0, 158, 185, (i * 160) / 16)
end

local ButtonPaint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self:IsEnabled() and ButtonStyleBackground or ButtonStyleDisabled)

    if self:IsEnabled() then
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, BlackBackground)

            for i = 1, 16 do
                draw.RoundedBox(0, 0, h + i - 16, w, 1, ShadingColor[i])
            end
        end
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
    end
end

local PlayersCanHeardOwner = CreateClientConVar("minigames_playerscanhearowner", "1", true, false, "Can players hear the owner of the minigame?")
local MuteAllPlayers = CreateClientConVar("minigames_muteallplayers", "0", true, false, "Mute all players in the minigame?")
local PlayersCanHeardThemselves = CreateClientConVar("minigames_playerscanhearthemselves", "1", true, false, "Can players hear themselves?")

--[[----------------------------
       Player Action Enum
----------------------------]]--

local PlayerListAction = {
    ADD = 1,
    REMOVE = 2,
    TOGGLE = 3,
    SENDTOGAME = 4,
    SENDTOOLDPOS = 5,
    SENDTOSPAWN = 6,
    MUTE = 7,
    UNMUTE = 8
}

local function DoPlayerListAction(ply, action)
    net.Start("Minigames.DoPlayerListAction")
        net.WritePlayer(ply)
        net.WriteUInt(action, 4)
    net.SendToServer()
end

--[[----------------------------
        Player Menu List
----------------------------]]--

local PlayerContextMenu = nil

local PANEL = {}

function PANEL:AddPlayer(ply, parent)
    local PlayerItem = vgui.Create("DButton", parent or nil)
    PlayerItem.ply = ply
    PlayerItem.PlayerName = ply:Nick()
    PlayerItem:SetText(PlayerItem.PlayerName)
    PlayerItem:SetFont("Minigames.Text")
    PlayerItem:SetTextColor(color_white)

    local State = ply == LocalPlayer() and PLAYER_OWNER or PLAYER_NOT_INGAME
    local InGame, Owner = Minigames.PlayerInGame(ply)
    if InGame then
        if Owner == LocalPlayer() then
            State = PLAYER_INGAME
        elseif ply == LocalPlayer() then
            State = PLAYER_OWNER
        else
            State = PLAYER_INGAME_OTHER
        end
    end

    PlayerItem.State = State
    PlayerItem.Paint = PlayerButtonPaint

    PlayerItem.DoClick = function()
        DoPlayerListAction(ply, PlayerListAction.TOGGLE)
    end
    PlayerItem.DoRightClick = function()
        if not IsValid(PlayerContextMenu) then
            PlayerContextMenu = DermaMenu()

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.add"), function()
                DoPlayerListAction(ply, PlayerListAction.ADD)
            end):SetIcon("icon16/add.png")

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.remove"), function()
                DoPlayerListAction(ply, PlayerListAction.REMOVE)
            end):SetIcon("icon16/delete.png")

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.toggle"), function()
                DoPlayerListAction(ply, PlayerListAction.TOGGLE)
            end):SetIcon("icon16/arrow_switch.png")

            PlayerContextMenu:AddSpacer()

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.sendtogame"), function()
                DoPlayerListAction(ply, PlayerListAction.SENDTOGAME)
            end):SetIcon("icon16/world_go.png")

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.sendtooldpos"), function()
                DoPlayerListAction(ply, PlayerListAction.SENDTOOLDPOS)
            end):SetIcon("icon16/world.png")

            PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.sendtospawn"), function()
                DoPlayerListAction(ply, PlayerListAction.SENDTOSPAWN)
            end):SetIcon("icon16/world_link.png")

            PlayerContextMenu:AddSpacer()

            if PlayerItem.State == PLAYER_INGAME then
                PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.mute"), function()
                    DoPlayerListAction(ply, PlayerListAction.MUTE)
                end):SetIcon("icon16/sound_mute.png")

                PlayerContextMenu:AddOption(Minigames.GetPhrase("playerlist.unmute"), function()
                    DoPlayerListAction(ply, PlayerListAction.UNMUTE)
                end):SetIcon("icon16/sound.png")
            end

        end

        PlayerContextMenu:Open()
    end

    return PlayerItem
end

function PANEL:Init()
    self.PlayerLinkedToPanel = {}

    self:SetSize(ScrW() * 0.2, ScrH() * 0.3)
    self:SetSizable(true)
    self:SetDraggable(true)
    self:ShowCloseButton(false)

    self:SetTitle(Minigames.GetPhrase("setupmenu.players"))

    self:SetMinWidth(200)
    self:SetMinHeight(63)

    self.LocalOwner = self:AddPlayer(LocalPlayer(), self)
    self.LocalOwner:Dock(TOP)
    self.LocalOwner:DockMargin(3, 3, 3, 3)
    self.LocalOwner:SetTall(24)

    self.PlayerLinkedToPanel[LocalPlayer()] = self.LocalOwner

    self.PlayersCanHearOwner = self:Add("DCheckBoxLabel")
    self.PlayersCanHearOwner:Dock(TOP)
    self.PlayersCanHearOwner:DockMargin(3, 3, 3, 3)
    self.PlayersCanHearOwner:SetTall(24)
    self.PlayersCanHearOwner:SetText(Minigames.GetPhrase("playerlist.hearowner"))
    self.PlayersCanHearOwner:SetValue(PlayersCanHeardOwner:GetBool())

    self.PlayersCanHearOwner.OnChange = function(_, value)
        PlayersCanHeardOwner:SetBool(value)
    end

    self.MuteAllPlayers = self:Add("DCheckBoxLabel")
    self.MuteAllPlayers:Dock(TOP)
    self.MuteAllPlayers:DockMargin(3, 3, 3, 3)
    self.MuteAllPlayers:SetTall(24)
    self.MuteAllPlayers:SetText(Minigames.GetPhrase("playerlist.muteall"))
    self.MuteAllPlayers:SetValue(MuteAllPlayers:GetBool())

    self.MuteAllPlayers.OnChange = function(_, value)
        MuteAllPlayers:SetBool(value)
    end

    self.PlayersCanHearThemselves = self:Add("DCheckBoxLabel")
    self.PlayersCanHearThemselves:Dock(TOP)
    self.PlayersCanHearThemselves:DockMargin(3, 3, 3, 3)
    self.PlayersCanHearThemselves:SetTall(24)
    self.PlayersCanHearThemselves:SetText(Minigames.GetPhrase("playerlist.hearself"))
    self.PlayersCanHearThemselves:SetValue(PlayersCanHeardThemselves:GetBool())

    self.PlayersCanHearThemselves.OnChange = function(_, value)
        PlayersCanHeardThemselves:SetBool(value)
    end

    if engine.ActiveGamemode() ~= "darkrp" then
        self.PlayersCanHearThemselves:Hide()
    end

    self.BroadcastGameJoin = self:Add("DButton")
    self.BroadcastGameJoin:Dock(TOP)
    self.BroadcastGameJoin:DockMargin(3, 3, 3, 3)
    self.BroadcastGameJoin:SetTall(24)
    self.BroadcastGameJoin:SetText(Minigames.GetPhrase("playerlist.broadcast"))
    self.BroadcastGameJoin:SetTextColor(color_white)
    self.BroadcastGameJoin.DoClick = function()
        if not Minigames.IsAllowed() then return end
        if GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL) ~= NULL then return end

        net.Start("Minigames.BroadcastGameJoin")
        net.SendToServer()
    end

    local BroadcastCanBeEnabled = (
        Minigames.GetOwnerGame( LocalPlayer() ) ~= nil and
        not Minigames.GetOwnerGame( LocalPlayer() ):IsActive() or
        GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL) ~= NULL
    )

    self.BroadcastGameJoin:SetEnabled(BroadcastCanBeEnabled)
    self.BroadcastGameJoin.Paint = ButtonPaint

    local HorizontalLine = self:Add("Panel")
    HorizontalLine:Dock(TOP)
    HorizontalLine:DockMargin(4, 4, 4, 4)
    HorizontalLine:SetTall(1)
    HorizontalLine.Paint = function(_, w, h)
        surface.SetDrawColor(Grayest)
        surface.DrawRect(0, 0, w, h)
    end

    self.PlayerList = self:Add("DScrollPanel")
    self.PlayerList:Dock(FILL)
    self.PlayerList.Paint = nil
    self.PlayerList.VBar.Paint = nil

    local Players = player.GetAll()
    table.sort(Players, function(a, b) return a:Nick() < b:Nick() end)

    for _, ply in ipairs(Players) do
        if ply == LocalPlayer() then continue end

        local PlayerItem = self:AddPlayer(ply, self.PlayerList)
        PlayerItem:Dock(TOP)
        PlayerItem:DockMargin(3, 3, 3, 3)
        PlayerItem:SetTall(24)

        self.PlayerLinkedToPanel[ply] = PlayerItem
    end
end

PANEL.Paint = Minigames.Paint


vgui.Register("Minigames.PlayerList", PANEL, "DFrame")