--[[--------------------------------------------
               Minigame Client-Side
--------------------------------------------]]--

Minigames.GameData = Minigames.GameData or {}
Minigames.BackgroundMusic = Minigames.BackgroundMusic or nil

CreateClientConVar("minigames_game", "none", true, true, "What game do you want to spawn?")
CreateClientConVar("minigames_prerender", 0, true, true, "(DEV) Pre-render the game")

local CYAN = Color(74, 158, 197)
local mat_BlurScreen = Material( "pp/blurscreen" )

--[[----------------------------
              Fonts
----------------------------]]--

local FontTable = {
    font = "Tahoma",
    antialias = true,
    size = 24,
}
surface.CreateFont("Minigames.Title", FontTable)

FontTable.size = 20
surface.CreateFont("Minigames.Title2", FontTable)

FontTable.size = 18
surface.CreateFont("Minigames.SubTitle", FontTable)

FontTable.size = 16
FontTable.font = "Arial"
surface.CreateFont("Minigames.Text", FontTable)

FontTable.size = 16
FontTable.font = "Courier New"
FontTable.antialias = true
surface.CreateFont("Minigames.Text.Mono", FontTable)


--[[----------------------------
          Draw Functions
----------------------------]]--

local ScreenSizeW, ScreenSizeH = ScrW(), ScrH()
function Minigames.BlurMenu( panel )
    local x, y = panel:LocalToScreen( 0, 0 )

    surface.SetDrawColor( color_white )
    surface.SetMaterial( mat_BlurScreen )

    for i = 2, 4 do
        mat_BlurScreen:SetFloat( "$blur", i )
        mat_BlurScreen:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScreenSizeW, ScreenSizeH )
    end
end

local DarkBlack = Color(0, 0, 0, 200)
local DarkestBlack = Color(0, 0, 0, 230)
function Minigames.Paint(self, w, h)
    RememberCursorPosition()

    if Minigames.Config["BlurVGUI"] then
        Minigames.BlurMenu(self)
    end

    -- surface.SetDrawColor( DarkestBlack )
    draw.RoundedBox( 4, 0, 0, w, h, DarkestBlack )
    draw.RoundedBoxEx( 4, 0, 0, w, 24, DarkBlack, true, true, h < 30 , h < 30  )

    if h < 30 then return end

    surface.SetDrawColor( color_white )
    draw.NoTexture()
    surface.DrawPoly({
        { x = w - 5, y = h },
        { x = w, y = h - 5 },
        { x = w, y = h }
    })

    surface.DrawPoly({
        { x = w - 9, y = h },
        { x = w - 12, y = h },
        { x = w, y = h - 12 },
        { x = w, y = h - 9 }
    })
end


--[[----------------------------
        Network Functions
----------------------------]]--

function Minigames.ReceiveMessage()
    local msg = net.ReadString()
    local prefix = net.ReadString()

    chat.AddText(color_white, "[", CYAN, prefix, color_white, "] ", msg)
end

function Minigames.ReceiveToolTip()
    local GameID = net.ReadString()

    notification.AddLegacy( Minigames.GetPhrase(GameID .. ".tip"), NOTIFY_HINT, 6 )
    surface.PlaySound( "buttons/lightswitch2.wav" )
end

net.Receive("Minigames.Message", Minigames.ReceiveMessage)
net.Receive("Minigames.ToolTip", Minigames.ReceiveToolTip)