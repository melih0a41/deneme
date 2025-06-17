/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local LockScreen = {}

LockScreen.ID = 0
LockScreen.Name = "Lockscreen"

local matCode = Material( "materials/oneprint/code.png", "smooth" )
local matLock = Material( "materials/oneprint/lock.png", "smooth" )
local matArrow = Material( "materials/oneprint/arrow.png", "smooth" )

--[[

    LockScreen.Run

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

function LockScreen.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

    if not dBase.eEntity or not IsValid( dBase.eEntity ) or ( dBase.eEntity:GetClass() ~= "oneprint" ) then
        return
    end

    dBase.ActiveTab = vgui.Create( "DPanel", dBase )
    dBase.ActiveTab:SetSize( dBase:GetWide(), dBase:GetTall() )

    local tCol = OnePrint:C( 5 )

    function dBase.ActiveTab:Paint( iW, iH )
        surface.SetDrawColor( tCol )
        surface.SetMaterial( matLock )
        surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .48 ), ( iH * .06 ), ( iH * .06 ), 0 )
    end

    -- Community logo
    if OnePrint.Cfg.CommunityLogo then
        local dLogo = vgui.Create( "DHTML", dBase.ActiveTab )
        dLogo:SetSize( ( dBase:GetTall() * .2 ), ( dBase:GetTall() * .2 ) )
        dLogo:SetPos( ( dBase:GetWide() * .5 ) - ( dLogo:GetWide() * .5 ), ( dBase:GetTall() * .12 ) - ( dLogo:GetTall() * .5 ) )
        dLogo:SetMouseInputEnabled( false )
        dLogo:SetHTML( "<style> body, html { height: 100%; margin: 0; } .icon { background-image: url(" .. OnePrint.Cfg.CommunityLogo .. "); height: 100%; background-position: center; background-repeat: no-repeat; background-size: cover; overflow: hidden;} </style> <body> <div class=\"icon\"></div> </body>" )

        local matGradientDown = Material( "vgui/gradient-d" )

        function dLogo:PaintOver( iW, iH )
            surface.SetDrawColor( OnePrint:C( 0 ) )

            surface.SetMaterial( matGradientDown )
            surface.DrawTexturedRect( 0, 0, iW, iH )
        end
    end

    -- Hack
    if LocalPlayer():OP_IsHaxor() or ( OnePrint.Cfg.HackingOwnedPrinter and ( dBase.eEntity:GetOwnerObject() == LocalPlayer() ) ) then
        local dHack = vgui.Create( "DButton", dBase.ActiveTab )
        dHack:SetSize( ( dBase:GetTall() * .05 ), ( dBase:GetTall() * .05 ) )
        dHack:SetText( "" )
        dHack:AlignRight( OnePrint.iMargin )
        dHack:AlignTop( OnePrint.iMargin )
        dHack.tColor = OnePrint:C( 1 )

        function dHack:Paint( iW, iH )
            surface.SetDrawColor( self.tColor )
            surface.SetMaterial( matCode )
            surface.DrawTexturedRect( 0, 0, iW, iH , 0 )
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        function dHack:OnCursorEntered()
            self.tColor = OnePrint:C( 5 )
        end

        function dHack:OnCursorExited()
            self.tColor = OnePrint:C( 2 )
        end

        function dHack:DoClick()
            OnePrint:SetTab( dBase, 4 )
        end
    end

    -- Unlock
    local dUnlock = vgui.Create( "DPanel", dBase.ActiveTab )
    dUnlock:SetSize( ( dBase:GetWide() * .7 ), ( dBase:GetTall() * .12 ) )
    dUnlock:AlignLeft( ( dBase:GetWide() * .5 ) - ( dUnlock:GetWide() * .5 ) )
    dUnlock:AlignBottom( OnePrint.iMargin * 4 )
    dUnlock.fLerp = 0
    dUnlock.fLerpTo = 0

    local sUnlockText = string.upper( OnePrint:L( "Scroll to unlock" ) )
    local iLen = string.len( sUnlockText )

    surface.SetFont( "OnePrint.4" )
    local iTextW, iTextH = surface.GetTextSize( sUnlockText )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    local tText = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

    for i = 1, iLen do
        tText[ i ] = {
            iX = ( i * ( iTextW + 50 ) / iLen ),
            sChar = string.sub( sUnlockText, i, i ),
            iAlpha = 255
        }
    end

    function dUnlock:OnCursorEntered()
        if not OnePrint.Cfg.CanUsePrinter["*"] then
            if not OnePrint.Cfg.CanUsePrinter[team.GetName(LocalPlayer():Team())] then return end
        end

        self.fLerpTo = self:GetWide()
    end

    function dUnlock:OnCursorExited()
        self.fLerpTo = 0
    end

    function dUnlock:Paint( iW, iH )
        self.fLerp = Lerp( RealFrameTime() * 3, self.fLerp, self.fLerpTo )

        if ( self.fLerp >= ( iW * .95 ) ) then
            if dBase.eEntity:CanPlayerUse( LocalPlayer() ) then
                OnePrint:SetTab( dBase, 1, true )
                OnePrint:Play2DSound( "oneprint/unlock.mp3" )
            else
                tCol = OnePrint:C( 4 )
            end
        else
            tCol = OnePrint:C( 5 )
        end

        surface.SetDrawColor( ColorAlpha( tCol, 255 - ( self.fLerp * 255 / iW ) ) )
        surface.SetMaterial( matArrow )
        surface.DrawTexturedRectRotated( ( iH * .32 ) + ( self.fLerp * .93 ), ( iH * .5 ), ( iH * .5 ), ( iH * .5 ), 0 )

        for k, v in pairs( tText ) do
            v.iAlpha = ( v.iX * 255 / ( self.fLerp * ( iTextW * .5 ) ) )
            
            draw.SimpleText( v.sChar, "OnePrint.4", v.iX + ( iW * .5 ) - ( iTextW * .5 ) - 30, ( iH * .5 ), ColorAlpha( tCol, v.iAlpha ), 1, 1 )
        end
    end
end

OnePrint:RegisterTab( LockScreen )
