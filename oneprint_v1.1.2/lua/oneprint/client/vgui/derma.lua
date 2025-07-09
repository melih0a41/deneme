/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

--[[

    OnePrint:DrawContainer

]]--

function OnePrint:DrawContainer( dPanel, iRoundness, sTitle )
    dPanel.fLerpDarken = ( dPanel.fLerpDarken or 100 )
    if dPanel.Depressed then
        dPanel.fLerpDarken = Lerp( RealFrameTime() * 10, dPanel.fLerpDarken, 140 )
    elseif dPanel.Hovered then
        dPanel.fLerpDarken = Lerp( RealFrameTime() * 10, dPanel.fLerpDarken, 120 )
    else
        dPanel.fLerpDarken = Lerp( RealFrameTime() * 10, dPanel.fLerpDarken, 100 )
    end

    local tCol = OnePrint:DarkenColor( OnePrint:C( 1 ), dPanel.fLerpDarken )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

    draw.RoundedBox( OnePrint.iRoundness, 0, 0, dPanel:GetWide(), dPanel:GetTall(), tCol )

    if sTitle then
        draw.SimpleText( sTitle, "OnePrint.5", ( OnePrint.iMargin * .5 ), 5, OnePrint:C( 2 ), 0, 3 )
    end
end

--[[

    TODO : OnePrint:Notify

]]--

local tNotifTypes = {
    [ 0 ] = {
        color = OnePrint:C( 6 ),
        mat = Material( "materials/oneprint/lamp.png", "smooth" ),
    },
    [ 1 ] = {
        color = OnePrint:C( 4 ),
        mat = Material( "materials/oneprint/cancel.png", "smooth" ),
    },
}

function OnePrint:Notify( ePrinter, sText, iType, iTime )
    if not ePrinter or not IsValid( ePrinter ) or not ePrinter.dPrinter or not IsValid( ePrinter.dPrinter ) then
        return
    end

    local iType = ( iType or 0 )
    if not tNotifTypes[ iType ] then
        iType = 0
    end

    timer.Destroy( "OnePrint_NotifTimer" )

    if ePrinter.dNotif and IsValid( ePrinter.dNotif ) then
        ePrinter.dNotif:Update( sText, iType )
    else
        local iImgH = ( ePrinter.dPrinter:GetTall() * .032 )

        local dNotif = vgui.Create( "DLabel", ePrinter.dPrinter )
        dNotif:SetFont( "OnePrint.5" )
	    dNotif:SetContentAlignment( 4 )
	    dNotif:SetTextInset( iImgH + ( OnePrint.iMargin * 1.75 ), 2 )
        dNotif:SetTextColor( OnePrint:C( 5 ) )
	    dNotif:SetSize( 0, iImgH + ( OnePrint.iMargin ) )
        dNotif:SetZPos( 100 )
        dNotif:SetPos( ( ePrinter.dPrinter:GetWide() * .5 ) - ( dNotif:GetWide() * .5 ), -dNotif:GetTall() )

        dNotif.bBlank = true
        dNotif.mat = tNotifTypes[ iType ].mat
        dNotif.color = tNotifTypes[ iType ].color

        ePrinter.dNotif = dNotif

        function dNotif:Paint( iW, iH )
            surface.SetDrawColor( OnePrint:C( 0 ) )
            surface.DrawRect( 0, 0, iW, iH )

            surface.SetDrawColor( self.color )
            surface.DrawRect( 0, 0, iH, iH )
            surface.DrawRect( 0, ( iH - 2 ), iW, 2 )
            
            surface.SetMaterial( self.mat )
            surface.SetDrawColor( ColorAlpha( color_black, 150 ) )
            surface.DrawTexturedRectRotated( ( OnePrint.iMargin * .5 ) + ( iImgH * .5 ) + 2, ( iH * .5 ) + 2, iImgH, iImgH, 0 )

            surface.SetDrawColor( color_white )
            surface.DrawTexturedRectRotated( ( OnePrint.iMargin * .5 ) + ( iImgH * .5 ), ( iH * .5 ), iImgH, iImgH, 0 )
        end

        function dNotif:Update( sText, iType )
            if sText then
                surface.SetFont( self:GetFont() )
                local iTextW, iTextH = surface.GetTextSize( sText )

                self:SetText( sText )
                self:SetWide( iTextW + ( OnePrint.iMargin * 3 ) + 16 )

                if self.bBlank then
                    self:SetPos( ( self:GetParent():GetWide() * .5 ) - ( self:GetWide() * .5 ), 0 )
                    self.bBlank = nil
                end

                self:MoveTo( ( self:GetParent():GetWide() * .5 ) - ( self:GetWide() * .5 ), ( OnePrint.iMargin * 2 ), .2, 0, .5 )

                self.mat = tNotifTypes[ iType ].mat
                self.color = tNotifTypes[ iType ].color
            end
        end

        dNotif:Update( sText, iType )
    end

    timer.Create( "OnePrint_NotifTimer", ( iTime or 3 ), 1, function()
        if not ePrinter or not IsValid( ePrinter ) then
            return
        end

        if ePrinter.dNotif and IsValid( ePrinter.dNotif ) then
            ePrinter.dNotif:AlphaTo( 0, .2, 0, function()
                if ePrinter.dNotif and IsValid( ePrinter.dNotif ) then
                    ePrinter.dNotif:Remove()
                end
            end )
        end
    end )
end

--[[

    OnePrint:CreatePopup

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

local matAlert = Material( "materials/oneprint/alert.png", "smooth" )

function OnePrint:CreatePopup( dParent, sTitle, sDescription, tChoices, tBgColor )
    if not dParent or not IsValid( dParent ) then
        return
    end

    if dParent.dPopup and IsValid( dParent.dPopup ) then
        dParent.dPopup:Remove()
    end

    dParent.dPopup = vgui.Create( "DPanel", dParent )
    dParent.dPopup:SetAlpha( 0 )
    dParent.dPopup:AlphaTo( 255, 1, 0 )
    dParent.dPopup:SetSize( ( dParent:GetWide() * .6 ), ( dParent:GetTall() * .3 ) )
    dParent.dPopup:Center()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

    dParent.dPopup.fLerpIcon = 0
    dParent.dPopup.iHeaderH = ( dParent.dPopup:GetTall() * .7 )
    dParent.dPopup.fLerpPoly = dParent.dPopup.iHeaderH
    dParent.dPopup.tCol = ( tBgColor or OnePrint:C( 6 ) )
    dParent.dPopup.tPolyCol = OnePrint:DarkenColor( dParent.dPopup.tCol, 80 )

    local tPoly = {
        { x = 0, y = dParent.dPopup.iHeaderH },
        { x = dParent.dPopup:GetWide(), y = dParent.dPopup.iHeaderH },
        { x = dParent.dPopup:GetWide(), y = dParent.dPopup.iHeaderH },
    }

    function dParent.dPopup:Paint( iW, iH )
        self.fLerpIcon = Lerp( RealFrameTime() * 4, self.fLerpIcon, ( self.iHeaderH * .4 ) )

        self.fLerpPoly = Lerp( RealFrameTime() * 2, self.fLerpPoly, OnePrint.iRoundness )
        tPoly[ 2 ].y = self.fLerpPoly
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

        -- Shadow
        DisableClipping( true )
            draw.RoundedBox( OnePrint.iRoundness, 8, 8, iW, iH, ColorAlpha( color_black, 70 ) )
        DisableClipping( false )

        -- Header
        draw.RoundedBoxEx( OnePrint.iRoundness, 0, 0, iW, self.iHeaderH, self.tCol, true, true, false, false )

    	surface.SetDrawColor( self.tPolyCol )
	    draw.NoTexture()
    	surface.DrawPoly( tPoly )

        -- Content
        if sTitle then
            draw.SimpleText( sTitle, "OnePrint.3", ( iW * .5 ), ( self.iHeaderH * .65 ), OnePrint:C( 5 ), 1, 1 )
        end

        surface.SetDrawColor( color_white )
        surface.SetMaterial( matAlert )
        surface.DrawTexturedRectRotated( ( iW * .5 ), ( self.iHeaderH * .25 ), self.fLerpIcon, self.fLerpIcon, 0 )

        -- Footer
        draw.RoundedBoxEx( OnePrint.iRoundness, 0, self.iHeaderH, iW, ( iH - self.iHeaderH ), OnePrint:C( 5 ), false, false, true, true )
    end

    local dClose = vgui.Create( "DButton", dParent.dPopup )
    dClose:SetSize( 48, 48 )
    dClose:AlignTop( ( dParent.dPopup:GetTall() * .01 ) )
    dClose:AlignRight( ( dParent.dPopup:GetTall() * .01 ) )
    dClose:SetFont( "OnePrint.6" )
    dClose:SetTextColor( OnePrint:C( 5 ) )
    dClose:SetText( "✖" )
    dClose.Paint = nil

    function dClose:OnCursorEntered()
        self:SetFont( "OnePrint.4" )
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    function dClose:OnCursorExited()
        self:SetFont( "OnePrint.6" )
    end

    function dClose:DoClick()
        if dParent and dParent.dPopup and IsValid( dParent.dPopup ) then
            dParent.dPopup:Remove()
        end
    end

    if sDescription then
        local dDescription = vgui.Create( "DLabel", dParent.dPopup )
        dDescription:SetText( sDescription )
        dDescription:SetFont( "OnePrint.6" )
        dDescription:SetTextColor( OnePrint:C( 5 ) )
        dDescription:SetContentAlignment( 5 )
        dDescription:SetSize( dParent.dPopup:GetWide() - 10, dParent.dPopup:GetTall() * .2 )
        dDescription:SetPos( 5, dParent.dPopup.iHeaderH - dDescription:GetTall() )
    end

    local dChoices = vgui.Create( "DIconLayout", dParent.dPopup )
    dChoices:SetSize( ( dParent.dPopup:GetWide() * .93 ), ( ( dParent.dPopup:GetTall() - dParent.dPopup.iHeaderH ) * .6 ) )
    dChoices:AlignLeft( ( dParent.dPopup:GetWide() * .5 ) - ( dChoices:GetWide() * .5 ) )
    dChoices:AlignBottom( ( dChoices:GetTall() * .3 ) )
    dChoices:SetSpaceX( dChoices:GetTall() * .1 )

    for _, v in ipairs( tChoices ) do
        local dBtn = dChoices:Add( "DButton" ) 
        dBtn:SetSize( dChoices:GetWide() / #tChoices - dChoices:GetSpaceX(), dChoices:GetTall() )
        dBtn:SetText( v.name )
        dBtn:SetFont( "OnePrint.5" )
        dBtn:SetTextColor( OnePrint:C( 5 ) )
        dBtn:SetTextInset( 0, 2 )
        dBtn.tColor = ( v.color or color_black )
        dBtn.tDarkColor = OnePrint:DarkenColor( dBtn.tColor, 60 )
        dBtn.fLerpH = 0

        function dBtn:DoClick()
            if v.func and isfunction( v.func ) then
                v.func( dParent.dPopup )
            end
        end

        function dBtn:Paint( iW, iH )
            surface.SetDrawColor( self.Hovered and self.tDarkColor or self.tColor )
            surface.DrawRect( 0, 0, iW, iH )
        end
    end

    return dParent.dPopup
end

--[[

    OnePrint:DarkenColor

]]--

function OnePrint:DarkenColor( tC, i )
    return Color( tC.r * ( i * .01 ), tC.g * ( i * .01 ), tC.b * ( i * .01 ), ( tC.a or 255 ) )
end

--[[

    OnePrintTitle

]]--

local OPTitle = {}

function OPTitle:Paint( iW, iH )
end

function OPTitle:SetHeader( sHeaderText, matShop )
    self.dHome = vgui.Create( "DButton", self )
    self.dHome:SetSize( ( self:GetWide() * .3 ), self:GetTall() )
    self.dHome:AlignRight( 0 )
    self.dHome:SetText( string.upper( OnePrint.Lang[ "Home" ] ) )
    self.dHome:SetTextColor( OnePrint:C( 5 ) )
    self.dHome:SetContentAlignment( 4 )
    self.dHome:SetTextInset( ( OnePrint.iMargin * .5 ), ( OnePrint.iMargin * .7 ) )
    self.dHome:SetFont( "OnePrint.3" )
    self.dHome.sTitle = string.upper( OnePrint.Lang[ "Return" ] .. " " .. OnePrint.Lang[ "Home" ] )

    function self.dHome:Paint( iW, iH )
        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle )
        draw.RoundedBox( OnePrint.iRoundness, 0, iH - OnePrint.iRoundness, iW, OnePrint.iRoundness, OnePrint:C( 6 ) )
    end

    function self.dHome:DoClick()
        OnePrint:SetTab( self:GetParent():GetParent():GetParent(), 1, true )
        OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
    end

    self.dTitle = vgui.Create( "DLabel", self )
    self.dTitle:SetSize( self:GetWide() - self.dHome:GetWide() - OnePrint.iMargin, self.dHome:GetTall() )
    self.dTitle:SetText( sHeaderText )
    self.dTitle:SetTextColor( OnePrint:C( 2 ) )
    self.dTitle:SetContentAlignment( 4 )
    self.dTitle:SetTextInset( ( self.dHome:GetTall() * .5 ) + ( OnePrint.iMargin * .5 ), ( OnePrint.iMargin * .2 ) )
    self.dTitle:SetFont( "OnePrint.3" )

    function self.dTitle:Paint( iW, iH )
        surface.SetDrawColor( OnePrint:C( 2 ) )
        surface.DrawRect( 0, ( iH - ( iH * .1 ) ), iW, ( iH * .1 ) )
        surface.SetMaterial( matShop )
        surface.DrawTexturedRectRotated( ( iH * .25 ), ( iH * .5 ), ( iH * .4 ), ( iH * .4 ), 0 )
    end
end

vgui.Register( "OnePrintTitle", OPTitle, "DPanel" )                                                                                                                                                                                                                                                                                                                                                                                                                                                 -- 76561198307194389
