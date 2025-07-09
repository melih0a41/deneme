/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local LockScreen = {}
LockScreen.ID = 3

local matUsers = Material( "materials/oneprint/user.png", "smooth" )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- bff8dd755dec0cda0569e2c732230354a5153d153214953e6ab76f0272049b75

--[[

    LockScreen.Run

]]--

function LockScreen.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end

    local ePrinter = dBase.eEntity
    if not ePrinter or not IsValid( ePrinter ) or ( ePrinter:GetClass() ~= "oneprint" ) then
        return
    end

    dBase.ActiveTab = vgui.Create( "DPanel", dBase )
    dBase.ActiveTab:SetSize( dBase:GetWide(), dBase:GetTall() )
    dBase.ActiveTab.Paint = nil

    local iSubTitleMargin = ( dBase:GetTall() * .01 )

    local dHeader = vgui.Create( "OnePrintTitle", dBase.ActiveTab )
    dHeader:SetSize( dBase:GetWide() - ( OnePrint.iMargin * 2 ), ( dBase:GetTall() * .09 ) )
    dHeader:SetPos( OnePrint.iMargin, OnePrint.iMargin )
    dHeader:SetHeader( string.upper( OnePrint:L( "Users" ) ), matUsers )

    -- All users
    local dAddUser = vgui.Create( "DPanel", dBase.ActiveTab )
    dAddUser:SetSize( dBase:GetWide() - ( OnePrint.iMargin * 2 ), ( dBase:GetTall() - dHeader:GetTall() - ( OnePrint.iMargin * 4 ) ) * .5 )
    dAddUser:SetPos( OnePrint.iMargin, dHeader:GetTall() + ( OnePrint.iMargin * 2 ) )
    dAddUser.iLayoutTall = ( dAddUser:GetTall() - ( OnePrint.iMargin * 4 ) - 10 )

    dAddUser.dLayout = vgui.Create( "DIconLayout", dAddUser )
    dAddUser.dLayout:SetSize( dAddUser:GetWide() - ( OnePrint.iMargin * 2 ), dAddUser.iLayoutTall )
    dAddUser.dLayout:SetPos( OnePrint.iMargin, ( OnePrint.iMargin * 3 ) )
    dAddUser.dLayout:SetSpaceX( 8 )
    dAddUser.dLayout:SetSpaceY( 8 )

    local iPlyPerPage = 8
    local iCurPage = 1

    local tPages = { [ 1 ] = {} }
    local tUsers = {}

    for _, pPlayer in ipairs( player.GetAll() ) do
        if ( pPlayer == ePrinter:GetOwnerObject() ) then
            continue
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        if ( table.Count( tPages[ #tPages ] ) >= iPlyPerPage ) then
            tPages[ #tPages + 1 ] = tPages[ #tPages + 1 ] or {}
        end

        table.insert( tPages[ #tPages ], pPlayer )
    end

    function dAddUser:BuildList( iPage )
        tUsers = ePrinter:GetUsers()
        local iPage = ( tPages[ ( iPage or 1 ) ] and iPage or 1 )

        self.dLayout:Clear()

        for k, v in ipairs( tPages[ iPage ] ) do
            local dPlayer = self.dLayout:Add( "DButton" )
            dPlayer:SetSize( self.dLayout:GetWide(), ( self.iLayoutTall / iPlyPerPage ) - self.dLayout:GetSpaceY() )
            dPlayer:SetText( v:Name() )
            dPlayer:SetFont( "OnePrint.5" )
            dPlayer:SetContentAlignment( 4 )
            dPlayer.fLerpBoxW = 0

            if ePrinter:GetOwnerObject() == v then
                dPlayer.bIsOwner = true
                dPlayer:SetTextColor( OnePrint:C( 2 ) )
            end

            if table.HasValue( tUsers, v ) then
                dPlayer.bIsUser = true
                dPlayer:SetTextColor( OnePrint:C( 2 ) )
            else
                dPlayer.fLerpBoxW = 0
                dPlayer:SetTextColor( OnePrint:C( 5 ) )
            end

            function dPlayer:Paint( iW, iH )
                if self.bIsUser then
                    draw.SimpleText( string.upper( OnePrint:L( "Added" ) ), "OnePrint.6", iW, ( iH * .5 ), self:GetTextColor(), 2, 1 )
                    return
                end

                self.fLerpBoxW = Lerp( RealFrameTime() * 6, self.fLerpBoxW, self.Hovered and ( iH * .25 ) or 0 )

                if ( self.fLerpBoxW > .1 ) then
                    self:SetTextInset( ( self.fLerpBoxW * 2.5 ), 2 )

                    surface.SetDrawColor( OnePrint:C( 6 ) )
                    surface.DrawRect( 0, 0, self.fLerpBoxW, iH )
                end
            end

            function dPlayer:OnCursorEntered()
                if self.bIsUser or self.bIsOwner then
                    return
                end

                self:SetTextColor( OnePrint:C( 6 ) )
                self:SetFont( "OnePrint.4" )
            end

            function dPlayer:OnCursorExited()
                if self.bIsUser or self.bIsOwner then
                    return
                end

                self:SetTextColor( OnePrint:C( 5 ) )
                self:SetFont( "OnePrint.5" )
            end

            function dPlayer:DoClick()
                if self.bIsUser or self.bIsOwner then
                    return
                end

                OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )

                local sName = v:Name()
                sName = ( string.len( sName ) > 15 ) and ( string.sub( sName, 1, 15 ) .. "..." ) or sName

                OnePrint:CreatePopup( dBase.ActiveTab, string.upper( OnePrint:L( "Add user" ) ) .. " [" .. sName .. "]", OnePrint:L( "Are you sure?" ), {
                    { name = OnePrint:L( "Yes" ), color = OnePrint:C( 3 ), func = function( dPopup )
                        net.Start( "OnePrintNW" )
                            net.WriteUInt( 6, 4 )
                            net.WriteEntity( ePrinter )
                            net.WriteEntity( v )
                        net.SendToServer()

                        if IsValid( dPopup ) then
                            dPopup:Remove()
                        end

                        OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )

                        timer.Simple( .25, function()
                            if dAddUser and IsValid( dAddUser ) then
                                dAddUser:BuildList( 1 )
                                if dBase.ActiveTab.dCurUsers and IsValid( dBase.ActiveTab.dCurUsers ) then
                                    dBase.ActiveTab.dCurUsers:UpdateUsers()
                                end
                            end
                        end )
                    end },
                    { name = OnePrint:L( "No" ), color = OnePrint:C( 2 ), func = function( dPopup )
                        if IsValid( dPopup ) then
                            dPopup:Remove()
                        end

                        OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
                    end },
                } )
            end
        end
    end
    
    function dAddUser:Paint( iW, iH )
        OnePrint:DrawContainer( self, nil, string.upper( OnePrint:L( "Add user" ) ) )
    end

    dAddUser:BuildList( 1 )

    -- Pages
    local dPagesLayout = vgui.Create( "DIconLayout", dAddUser )
    dPagesLayout:SetTall( dBase:GetTall() * .05 )
    dPagesLayout:SetWide( dPagesLayout:GetTall() * table.Count( tPages ) )
    dPagesLayout:AlignLeft( ( dAddUser:GetWide() * .5 ) - ( dPagesLayout:GetWide() * .5 ) )
    dPagesLayout:AlignBottom( OnePrint.iMargin * .5 )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    for k, v in ipairs( tPages ) do
        local dPage = dPagesLayout:Add( "DButton" )
        dPage:SetText( k )
        dPage:SetFont( "OnePrint.5" )
        dPage:SetTextColor( OnePrint:C( 2 ) )
        dPage:SetContentAlignment( 2 )
        dPage:SetSize( dPagesLayout:GetTall(), dPagesLayout:GetTall() )
        dPage.iPageID = k

        function dPage:Paint( iW, iH )
            if ( iCurPage == self.iPageID ) then
                surface.SetDrawColor( self:GetTextColor() )
                surface.DrawRect( ( iW * .5 ) - 10, ( iH - 2 ), 20, 2 )
            end
        end

        function dPage:OnCursorEntered()
            self:SetTextColor( OnePrint:C( 5 ) )
            self:SetFont( "OnePrint.4" )
        end

        function dPage:OnCursorExited()
            self:SetTextColor( OnePrint:C( 2 ) )
            self:SetFont( "OnePrint.5" )
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        function dPage:DoClick()
            iCurPage = self.iPageID
            dAddUser:BuildList( iCurPage )

            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    end

    -- Current users
    dBase.ActiveTab.dCurUsers = vgui.Create( "DPanel", dBase.ActiveTab )
    dBase.ActiveTab.dCurUsers:SetSize( dAddUser:GetWide(), dBase.ActiveTab:GetTall() - dAddUser:GetTall() - dHeader:GetTall() - ( OnePrint.iMargin * 4 ) )
    dBase.ActiveTab.dCurUsers:AlignLeft( OnePrint.iMargin )
    dBase.ActiveTab.dCurUsers:AlignBottom( OnePrint.iMargin )
    dBase.ActiveTab.dCurUsers.iLayoutTall = ( dAddUser:GetTall() - ( OnePrint.iMargin * 4 ) - 10 )

    function dBase.ActiveTab.dCurUsers:Paint( iW, iH )
        OnePrint:DrawContainer( self, nil, string.upper( OnePrint:L( "Manage users" ) ) )
    end

    function dBase.ActiveTab.dCurUsers:UpdateUsers()
        self.dLayout:Clear()

        local dOwner = self.dLayout:Add( "DButton" )
        dOwner:SetSize( self.dLayout:GetWide(), ( self.iLayoutTall / iPlyPerPage ) - self.dLayout:GetSpaceY() )
        dOwner:SetText( ePrinter:GetOwnerObject():Name() )
        dOwner:SetFont( "OnePrint.5" )
        dOwner:SetContentAlignment( 4 )
        dOwner:SetTextColor( OnePrint:C( 2 ) )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        function dOwner:Paint( iW, iH )
            draw.SimpleText( string.upper( OnePrint:L( "Owner" ) ), "OnePrint.6", iW, ( iH * .5 ), self:GetTextColor(), 2, 1 )
        end

        for _, v in ipairs( ePrinter:GetUsers() ) do
            if not v or not IsValid( v ) then
                continue
            end

            local dPlayer = self.dLayout:Add( "DButton" )
            dPlayer:SetSize( self.dLayout:GetWide(), ( self.iLayoutTall / iPlyPerPage ) - self.dLayout:GetSpaceY() )
            dPlayer:SetText( v:Name() )
            dPlayer:SetFont( "OnePrint.5" )
            dPlayer:SetContentAlignment( 4 )
            dPlayer.fLerpBoxW = 0

            function dPlayer:Paint( iW, iH )
                self.fLerpBoxW = Lerp( RealFrameTime() * 6, self.fLerpBoxW, ( self.Hovered and ( iH * .25 ) or 0 ) )

                if ( self.fLerpBoxW > .1 ) then
                    self:SetTextInset( ( self.fLerpBoxW * 2.5 ), 2 )
                    draw.RoundedBox( 0, 0, 0, self.fLerpBoxW, iH, self:GetTextColor() )
                end

                draw.SimpleText( string.upper( OnePrint:L( "Owner" ) ), "OnePrint.6", iW, ( iH * .5 ), self:GetTextColor(), 2, 1 )
            end

            function dPlayer:OnCursorEntered()
                self:SetTextColor( OnePrint:C( 4 ) )
                self:SetFont( "OnePrint.4" )
            end

            function dPlayer:OnCursorExited()
                self:SetTextColor( OnePrint:C( 5 ) )
                self:SetFont( "OnePrint.5" )
            end

            function dPlayer:DoClick()
                local sName = v:Name()
                sName = ( string.len( sName ) > 15 ) and ( string.sub( sName, 1, 15 ) .. "..." ) or sName

                OnePrint:CreatePopup( dBase.ActiveTab, string.upper( OnePrint:L( "Remove user" ) ) .. " [" .. sName .. "]", OnePrint:L( "Are you sure?" ), {
                    { name = OnePrint:L( "Yes" ), color = OnePrint:C( 4 ), func = function( dPopup )
                        net.Start( "OnePrintNW" )
                            net.WriteUInt( 7, 4 )
                            net.WriteEntity( ePrinter )
                            net.WriteEntity( v )
                        net.SendToServer()

                        if IsValid( dPopup ) then
                            dPopup:Remove()
                        end

                        timer.Simple( .25, function()
                            if dBase.ActiveTab.dCurUsers and IsValid( dBase.ActiveTab.dCurUsers ) then
                                dAddUser:BuildList( iCurPage )
                                dBase.ActiveTab.dCurUsers:UpdateUsers()
                            end
                        end )
                    end },
                    { name = OnePrint:L( "No" ), color = OnePrint:C( 2 ), func = function( dPopup )
                        if IsValid( dPopup ) then
                            dPopup:Remove()
                        end
                    end },
                }, OnePrint:C( 4 ) )
            end
        end
    end

    dBase.ActiveTab.dCurUsers.dLayout = vgui.Create( "DIconLayout", dBase.ActiveTab.dCurUsers )
    dBase.ActiveTab.dCurUsers.dLayout:SetSize( dBase.ActiveTab.dCurUsers:GetWide() - ( OnePrint.iMargin * 2 ), dBase.ActiveTab.dCurUsers.iLayoutTall )
    dBase.ActiveTab.dCurUsers.dLayout:SetPos( OnePrint.iMargin, ( OnePrint.iMargin * 3 ) )
    dBase.ActiveTab.dCurUsers.dLayout:SetSpaceX( 8 )
    dBase.ActiveTab.dCurUsers.dLayout:SetSpaceY( 8 )

    dBase.ActiveTab.dCurUsers:UpdateUsers()
end

OnePrint:RegisterTab( LockScreen )
