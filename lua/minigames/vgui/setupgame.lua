--[[--------------------------------------------
              Minigame Setup Menu
--------------------------------------------]]--

local PlayersLastSizeX, PlayersLastSizeY = 0, 0
local PlayersLastPosX, PlayersLastPosY = 0, 0
local SubLastSizeX, SubLastSizeY = 0, 0
local LastSizeX, LastSizeY = 0, 0
local LastPosX, LastPosY = 0, 0
local IsMinized = false
local Changed = false

local PLAYER_OWNER = 1
local PLAYER_INGAME = 2
local PLAYER_INGAME_OTHER = 3
local PLAYER_NOT_INGAME = 4

local Grayest = Color(170, 170, 170, 40)

--[[----------------------------
           Reward Menu
----------------------------]]--

local PANEL = {}

function PANEL:Init()
    local TargetWidth = math.max(ScrW() * 0.2, 240)

    self.PlayerList = vgui.Create("Minigames.PlayerList")
    self.PlayerList:Center()
    self.PlayerList:SetX(20)

    self.PlayerList.PlayersCanHearOwner:SetDisabled( Minigames.GetOwnerGame(LocalPlayer()) == nil )
    self.PlayerList.MuteAllPlayers:SetDisabled( Minigames.GetOwnerGame(LocalPlayer()) == nil )
    self.PlayerList.PlayersCanHearThemselves:SetDisabled( Minigames.GetOwnerGame(LocalPlayer()) == nil )

    if Changed then
        self:SetPos(LastPosX, LastPosY)
        self:SetSize(LastSizeX, LastSizeY)
        self.PlayerList:SetPos(PlayersLastPosX, PlayersLastPosY)
        self.PlayerList:SetSize(PlayersLastSizeX, PlayersLastSizeY)

        RestoreCursorPosition()
    else
        self:SetSize(TargetWidth, ScrH() * 0.92)
        self:Center()
        self:SetX(ScrW() - self:GetWide() - 20)
    end

    self:SetDraggable(true)
    self:SetMinWidth(TargetWidth)
    self:SetMinHeight(300)
    self:SetSizable(true)
    self:SetTitle("Minigame Setup Menu")
    self:MakePopup()

    self.btnMinim:SetEnabled(true)
    self.btnMinim.DoClick = function(SubSelf)
        if IsMinized then return end

        self:SetSizable(false)
        SubLastSizeX, SubLastSizeY = self:GetSize()
        self:SetSize(TargetWidth, 24)
        self.ToggleGame:SetVisible(false)
        self.HorizontalLine2:SetVisible(false)

        IsMinized = true
    end

    self.btnMaxim:SetEnabled(true)
    self.btnMaxim.DoClick = function(SubSelf)
        if SubLastSizeX ~= 0 and SubLastSizeY ~= 0 then
            self:SetSizable(true)
            self:SetSize(SubLastSizeX, SubLastSizeY)
            self.ToggleGame:SetVisible(true)
            self.HorizontalLine2:SetVisible(true)

            IsMinized = false
        end
    end

    self.Paint = Minigames.Paint

    self.RewardConfigPanel = self:Add("Minigames.RewardConfig")
    self.RewardConfigPanel:Dock(TOP)
    self.RewardConfigPanel:DockMargin(5, 5, 5, 5)
    self.RewardConfigPanel:SetTall(170)

    local HorizontalLine = self:Add("Panel")
    HorizontalLine:Dock(TOP)
    HorizontalLine:DockMargin(4, 4, 4, 4)
    HorizontalLine:SetTall(1)
    HorizontalLine.Paint = function(_, w, h)
        surface.SetDrawColor(Grayest)
        surface.DrawRect(0, 0, w, h)
    end

    self.GameConfigPanel = self:Add("Minigames.GameConfig")
    self.GameConfigPanel:Dock(FILL)
    self.GameConfigPanel.Container:Dock(FILL)
    self.GameConfigPanel:PostInit()
    self.GameConfigPanel:SetGameID( GetConVar("minigames_game"):GetString() )

    self.ToggleGame = self:Add("Minigames.ToggleGame")
    self.ToggleGame:Dock(BOTTOM)
    self.ToggleGame:DockMargin(5, 5, 5, 5)
    self.ToggleGame:SetTall(32)

    self.HorizontalLine2 = self:Add("Panel")
    self.HorizontalLine2:Dock(BOTTOM)
    self.HorizontalLine2:DockMargin(4, 4, 4, 4)
    self.HorizontalLine2:SetTall(1)
    self.HorizontalLine2.Paint = function(_, w, h)
        surface.SetDrawColor(Grayest)
        surface.DrawRect(0, 0, w, h)
    end

    self.OnSizeChanged = function(_, w, h)
        LastSizeX, LastSizeY = w, h
    end

    self.OnRemove = function()
        self.GameConfigPanel:SaveScroll()
    end

    self.OnClose = function()
        self.RewardConfigPanel:ClosePopUp()
        LastPosX, LastPosY = self:GetPos()
        LastSizeX, LastSizeY = self:GetSize()
        PlayersLastPosX, PlayersLastPosY = self.PlayerList:GetPos()
        PlayersLastSizeX, PlayersLastSizeY = self.PlayerList:GetSize()
        self.PlayerList:Close()

        Changed = true
    end

    -- Menu is minimized
    if IsMinized then
        self.ToggleGame:SetVisible(false)
        self.HorizontalLine2:SetVisible(false)
    end
end

vgui.Register("Minigames.SetupMenu", PANEL, "DFrame")

--[[----------------------------
           Networking
----------------------------]]--

local MinigameSetupMenu
net.Receive("Minigames.SetupMenu", function()
    if IsValid(MinigameSetupMenu) then return end

    MinigameSetupMenu = vgui.Create("Minigames.SetupMenu")
end)

net.Receive("Minigames.BroadcastGameJoin", function()
    local State = net.ReadBool()
    if IsValid(MinigameSetupMenu) then
        MinigameSetupMenu.PlayerList.BroadcastGameJoin:SetEnabled(not State)
    end
end)

--[[----------------------------
              Hooks
----------------------------]]--

hook.Add("Minigames.TogglePlayer", "Minigames.UpdateState", function(ply, Owner, State)
    if IsValid(MinigameSetupMenu) and IsValid(ply) then
        local TargetState = ply == Owner and PLAYER_OWNER or PLAYER_NOT_INGAME
        if State then
            if Owner == LocalPlayer() then
                TargetState = PLAYER_INGAME
            else
                TargetState = PLAYER_INGAME_OTHER
            end
        end
        MinigameSetupMenu.PlayerList.PlayerLinkedToPanel[ply].State = TargetState
    end
end)

hook.Add("Minigames.RewardAdded", "Minigames.UpdateReward", function(Owner, Reward)
    if Owner ~= LocalPlayer() then return end

    if IsValid(MinigameSetupMenu) then
        MinigameSetupMenu.RewardConfigPanel:AddReward(Reward)
    end
end)

hook.Add("Minigames.RewardRemoved", "Minigames.UpdateReward", function(Owner, Index)
    if Owner ~= LocalPlayer() then return end

    if IsValid(MinigameSetupMenu) then
        MinigameSetupMenu.RewardConfigPanel.Container:Clear()
        MinigameSetupMenu.RewardConfigPanel:AddAllRewards()
    end
end)

hook.Add("Minigames.GameStart", "Minigames.GameStart", function(Owner, GameScript)
    if Owner ~= LocalPlayer() then return end

    if IsValid(MinigameSetupMenu) then
        MinigameSetupMenu.PlayerList.BroadcastGameJoin:SetEnabled(false)
    end
end)

hook.Add("Minigames.GameStop", "Minigames.GameStop", function(Owner, GameScript)
    if Owner ~= LocalPlayer() then return end

    if IsValid(MinigameSetupMenu) and GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL) == NULL then
        MinigameSetupMenu.PlayerList.BroadcastGameJoin:SetEnabled(true)
    end
end)