/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local Home = {}

Home.ID = 1
Home.Name = OnePrint:L( "Home" )

local matHappy = Material( "materials/oneprint/happy.png", "smooth" )
local matSad = Material( "materials/oneprint/sad.png", "smooth" )
local matUser = Material( "materials/oneprint/user.png", "smooth" )
local matRepair = Material( "materials/oneprint/repair.png", "smooth" )
local matFlame = Material( "materials/oneprint/flame.png", "smooth" )
local matCancel = Material( "materials/oneprint/cancel.png", "smooth" )

local tLogActions = {
    [ 0 ] = {
        str = OnePrint.Lang.Logs[ 0 ],
        color = OnePrint:C( 5 )
    },
    [ 1 ] = {
        str = OnePrint.Lang.Logs[ 1 ],
        color = OnePrint:C( 4 )
    },
    [ 2 ] = {
        str = OnePrint.Lang.Logs[ 2 ],
        color = OnePrint:C( 3 )
    },
    [ 3 ] = {
        str = OnePrint.Lang.Logs[ 3 ],
        color = OnePrint:C( 3 )
    },
    [ 4 ] = {
        str = OnePrint.Lang.Logs[ 4 ],
        color = OnePrint:C( 4 )
    },
}

local tHeader = {
    {
        name = string.upper( OnePrint:L( "Money" ) ),
        bMoney = true,
        func = function( ePrinter )
            ePrinter.fLerpMoney = ( ePrinter.fLerpMoney or 0 )
            ePrinter.fLerpMoney = Lerp( RealFrameTime() * 4, ePrinter.fLerpMoney, ePrinter:GetMoney() )
            return OnePrint:FormatMoney( math.Round( ePrinter.fLerpMoney ) )
        end,
    },
    {
        name = string.upper( OnePrint:L( "Income" ) ),
        bIncome = true,
        func = function( ePrinter )
            return "+" .. OnePrint:FormatMoney( ePrinter:GetTotalIncome() )
        end
    },
    {
        name = string.upper( OnePrint:L( "Temperature" ) ),
        bTemperature = true,
        func = function( ePrinter )
            ePrinter.fLerpTemperature = ( ePrinter.fLerpTemperature or 0 )
            ePrinter.fLerpTemperature = Lerp( RealFrameTime() * 4, ePrinter.fLerpTemperature, ePrinter:GetTemperature() )

            return string.Comma( math.Round( ePrinter.fLerpTemperature ) ) .. "°C"
        end
    },
    {
        name = string.upper( OnePrint:L( "CPU" ) ),
        func = function( ePrinter )
            return string.Comma( ( ePrinter:GetServers() * OnePrint.ServerFreq ) + ( ePrinter:GetOverclocking() * OnePrint.OCFreq ) ) .. " GHz"
        end,
        func2 = function( ePrinter )
            return ( ePrinter:GetServers() * OnePrint.ServerFreq ) .. " (+" .. ( ePrinter:GetOverclocking() * OnePrint.OCFreq ) .. ") Ghz"
        end
    }
}

local tMenuButtons = {
    {
        name = string.upper( OnePrint:L( "Shop" ) ),
        icon = Material( "materials/oneprint/shop.png", "smooth" ),
        func = function( dBase )
            OnePrint:SetTab( dBase, 2, true )
            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    },
    {
        name = string.upper( OnePrint:L( "Users" ) ),
        icon = Material( "materials/oneprint/user.png", "smooth" ),
        bUsers = true,
        func = function( dBase )
            OnePrint:SetTab( dBase, 3, true )
            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    },
    {
        name = string.upper( OnePrint:L( "Lights" ) ),
        icon = Material( "materials/oneprint/light.png", "smooth" ),
        func = function( dBase )
            local tLights = {
                [ 1 ] = { name = OnePrint:L( "Blue" ), color = OnePrint:C( 2 ) },
                [ 2 ] = { name = OnePrint:L( "White" ), color = OnePrint:C( 2 ) },
                [ 3 ] = { name = OnePrint:L( "Red" ), color = OnePrint:C( 2 ) },
                [ 4 ] = { name = OnePrint:L( "Green" ), color = OnePrint:C( 2 ) },
            }
            for iColor, v in ipairs( tLights ) do
                v.func = function( dPopup )
                    net.Start( "OnePrintNW" )
                        net.WriteUInt( 9, 4 )
                        net.WriteUInt( iColor, 2 )
                        net.WriteEntity( dBase.eEntity )
                    net.SendToServer()

                    if IsValid( dPopup ) then
                        dPopup:Remove()
                    end

                    OnePrint:Notify( dBase.eEntity, string.format( OnePrint:L( "Light color applied : %s" ), v.name ), 0, 3 )
                    OnePrint:Play2DSound( "oneprint/notify.mp3" )
                end
            end

            OnePrint:CreatePopup( dBase.ActiveTab, string.upper( OnePrint:L( "Change light" ) ), OnePrint:L( "Choose a new light color" ), tLights )
            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    },
    {
        name = string.upper( OnePrint:L( "Lock" ) ),
        icon = Material( "materials/oneprint/lock.png", "smooth" ),
        func = function( dBase )
            OnePrint:CreatePopup( dBase.ActiveTab, string.upper( OnePrint:L( "Lock printer" ) ), OnePrint:L( "Are you sure?" ), {
                { name = OnePrint:L( "Yes" ), color = OnePrint:C( 4 ), func = function( dPopup )
                    OnePrint:SetTab( dBase, 0, true )
                    OnePrint:Play2DSound( "oneprint/lock.mp3" )
                end },
                { name = OnePrint:L( "No" ), color = OnePrint:C( 2 ), func = function( dPopup )
                    if IsValid( dPopup ) then
                        dPopup:Remove()
                    end

                    OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
                end }
            }, OnePrint:C( 4 ) )

            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    },
    {
        name = string.upper( OnePrint:L( "Freeze" ) ),
        icon = Material( "materials/oneprint/freeze.png", "smooth" ),
        bFreeze = true,
        func = function( dBase, dButton )
            if dBase.eEntity and IsValid( dBase.eEntity ) then
                net.Start( "OnePrintNW" )
                    net.WriteUInt( 5, 4 )
                    net.WriteEntity( dBase.eEntity )
                net.SendToServer()

                if dButton and IsValid( dButton ) then
                    timer.Simple( .3, function()
                        if dButton and IsValid( dButton ) and dBase and dBase.eEntity and IsValid( dBase.eEntity ) then
                            if dBase.eEntity:GetFrozen() then
                                dButton:SetText( string.upper( OnePrint:L( "Unfreeze" ) ) )
                                OnePrint:Notify( dBase.eEntity, OnePrint:L( "You froze this printer" ), 1, 3 )
                            else
                                dButton:SetText( string.upper( OnePrint:L( "Freeze" ) ) )
                                OnePrint:Notify( dBase.eEntity, OnePrint:L( "You unfroze this printer" ), 0, 3 )
                            end
                        end
                    end )
                end

                OnePrint:Play2DSound( "oneprint/notify.mp3" )
            end
        end
    },
    {
        name = string.upper( OnePrint:L( "Start" ) ),
        icon = Material( "materials/oneprint/start.png", "smooth" ),
        bStart = true,
        func = function( dBase, dButton )
            if dBase.eEntity and IsValid( dBase.eEntity ) then
                net.Start( "OnePrintNW" )
                    net.WriteUInt( 3, 4 )
                    net.WriteEntity( dBase.eEntity )
                net.SendToServer()

                if dButton and IsValid( dButton ) then
                    timer.Simple( .3, function()
                        if dButton and IsValid( dButton ) and dBase and dBase.eEntity and IsValid( dBase.eEntity ) then
                            if ( dBase.eEntity:GetServers() == 0 ) then
                                OnePrint:Notify( dBase.eEntity, OnePrint:L( "You must buy a server before" ), 1, 3 )
                                return
                            end

                            if dBase.eEntity:GetPowered() then
                                dButton:SetText( string.upper( OnePrint:L( "Stop" ) ) )
                                dButton.icon = Material( "materials/oneprint/stop.png", "smooth" )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

                                OnePrint:Notify( dBase.eEntity, OnePrint:L( "You started this printer" ), 0, 3 )
                            else
                                dButton:SetText( string.upper( OnePrint:L( "Start" ) ) )
                                dButton.icon = Material( "materials/oneprint/start.png", "smooth" )

                                OnePrint:Notify( dBase.eEntity, OnePrint:L( "You stopped this printer" ), 1, 3 )
                            end
                        end
                    end )

                    OnePrint:Play2DSound( "oneprint/notify.mp3" )
                end
            end
        end
    }
}

if ( OnePrint.Cfg.MaxUsers <= 0 ) then
    for k, v in ipairs( tMenuButtons ) do
        if v.bUsers then
            tMenuButtons[ k ] = nil
            break
        end
    end
end

--[[

    drawPrinterUsers

]]--

local function drawPrinterUsers( dBase, dMenu )
    if not dBase or not dBase.ActiveTab or not IsValid( dBase.ActiveTab ) then
        return
    end

    local ePrinter = dBase.eEntity
    if not ePrinter or not IsValid( ePrinter ) then
        return
    end

    dMenu.bDrawUsers = true 

    if dMenu.dLayout and IsValid( dMenu.dLayout ) then
        dMenu.dLayout:Remove()
        dMenu.dLayout = nil
    end

    dMenu.sTitle = string.upper( OnePrint:L( "Users" ) )

    local sOwner = "[N/A]"
    local tUsers = {}

    if ePrinter:GetOwnerObject() and IsValid( ePrinter:GetOwnerObject() ) then
        tUsers[ 1 ] = ePrinter:GetOwnerObject():Name()
    end

    for k, v in pairs( ePrinter:GetUsers() ) do
        if IsValid( v ) then
            table.insert( tUsers, v:Name() )
        end
    end

    if ePrinter.GetOwnerObject and IsValid( ePrinter:GetOwnerObject() ) then
        sOwner = ePrinter:GetOwnerObject():Name()
    end

    function dMenu:Paint( iW, iH )
        OnePrint:DrawContainer( self, nil, self.sTitle )
        
        surface.SetMaterial( matUser )

        for k, v in ipairs( tUsers ) do
            if ( k == 1 ) then
                surface.SetDrawColor( OnePrint:C( 3 ) )
            else
                surface.SetDrawColor( OnePrint:C( 2 ) )
            end
            local iY = ( iH * .15 ) + ( ( iH * .1 ) * ( k - 1 ) )

            surface.DrawTexturedRectRotated( ( iH * .06 ), iY, ( iH * .08 ), ( iH * .08 ), 0 )
            draw.SimpleText( sOwner, "OnePrint.5", ( iH * .12 ), iY, OnePrint:C( 5 ), 0, 1 )
        end
    end
    
    return dMenu
end

--[[

    drawPrinterMenu

]]--

local function drawPrinterMenu( dBase, dMenu )
    if not dBase or not dBase.ActiveTab or not IsValid( dBase.ActiveTab ) then
        return
    end

    local ePrinter = dBase.eEntity
    if not ePrinter or not IsValid( ePrinter ) then
        return
    end

    dMenu.bDrawUsers = nil
    dMenu.sTitle = string.upper( OnePrint:L( "Menu" ) )

    function dMenu:Paint( iW, iH )
        OnePrint:DrawContainer( self, nil, self.sTitle )
    end

    dMenu.dLayout = vgui.Create( "DIconLayout", dMenu )
    local dLayout = dMenu.dLayout
    dLayout:SetSize( dMenu:GetWide() - 20, ( dMenu:GetTall() * .9 ) )
    dLayout:SetPos( ( OnePrint.iMargin * .5 ), ( dMenu:GetTall() - dLayout:GetTall() ) )

    for k, v in SortedPairs( tMenuButtons ) do
        local dBtn = dLayout:Add( "DButton" )
        dBtn:SetSize( dLayout:GetWide(), ( dLayout:GetTall() * .12 ) )
        dBtn:SetText( v.name )
        dBtn:SetFont( "OnePrint.5" )
        dBtn:SetContentAlignment( 4 )

        if v.icon then
            dBtn.icon = v.icon
        end

        if v.bStart then
            if ePrinter:GetPowered() then
                dBtn:SetText( string.upper( OnePrint:L( "Stop" ) ) )
                dBtn.icon = Material( "materials/oneprint/stop.png", "smooth" )
            else
                dBtn:SetText( string.upper( OnePrint:L( "Start" ) ) )
                dBtn.icon = Material( "materials/oneprint/start.png", "smooth" )
            end
        end

        if v.bFreeze then
            if ePrinter:GetFrozen() then
                dBtn:SetText( string.upper( OnePrint:L( "Unfreeze" ) ) )
            else
                dBtn:SetText( string.upper( OnePrint:L( "Freeze" ) ) )
            end
        end

        dBtn:SetTextColor( OnePrint:C( 5 ) )
        dBtn.tCol = OnePrint:C( 2 )
        dBtn.fLerp = 0

        function dBtn:Paint( iW, iH )
            if self.Hovered then
                self.tCol = OnePrint:C( 6 )
                self.fLerp = Lerp( RealFrameTime() * 6, self.fLerp, ( OnePrint.iMargin * .3 ) )
            else
                self.tCol = OnePrint:C( 5 )
                self.fLerp = Lerp( RealFrameTime() * 6, self.fLerp, -( OnePrint.iMargin * .3 ) )
            end

            if ( self.fLerp > 1 ) then
                surface.SetDrawColor( self.tCol )
                surface.DrawRect( 0, 0, self.fLerp, iH )
            end

            self:SetTextInset( ( self.fLerp + ( OnePrint.iMargin * .5 ) ), 2 )

            if self.icon then
                surface.SetDrawColor( self.tCol )
                surface.SetMaterial( self.icon )
                surface.DrawTexturedRectRotated( ( iW - ( iH * .32 ) ), ( iH * .5 ), ( iH * .64 ), ( iH * .64 ), 0 )
            end

            self:SetTextColor( self.tCol )
        end

        function dBtn:DoClick()
            if v.func and dBase and IsValid( dBase ) then
                v.func( dBase, self )
            end
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

--[[

    drawArc
    credits : Kruzgi

]]--

function drawArc( iX, iY, iW, iH, iAng, tCol, iX2, iY2 )
    for i = 0, iAng do
        local iCos = math.cos( math.rad( i ) )
        local iSin = math.sin( math.rad( i ) )

        draw.NoTexture()
        surface.SetDrawColor( tCol )
        surface.DrawTexturedRectRotated( iX + ( iY2 * iSin - iX2 * iCos ), iY + ( iY2 * iCos + iX2 * iSin ), iW, iH, i )
    end
end

--[[

    Home.Run

]]--

function Home.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end

    if not dBase.eEntity or not IsValid( dBase.eEntity ) or ( dBase.eEntity:GetClass() ~= "oneprint" ) then
        return
    end

    local ePrinter = dBase.eEntity
    if not ePrinter or not IsValid( ePrinter ) then
        return
    end

    dBase.ActiveTab = vgui.Create( "DPanel", dBase )
    dBase.ActiveTab:SetSize( dBase:GetWide(), dBase:GetTall() )
    dBase.ActiveTab.Paint = nil

    local dHeader = vgui.Create( "DPanel", dBase.ActiveTab )
    dHeader:SetSize( dBase.ActiveTab:GetWide() - ( OnePrint.iMargin * 2 ), ( dBase.ActiveTab:GetTall() * .12 ) )
    dHeader:AlignLeft( OnePrint.iMargin )
    dHeader:AlignTop( OnePrint.iMargin )
    dHeader.fNextOccur = ePrinter:GetNextOccur()
    dHeader.fThinkDelay = OnePrint.Cfg.MoneyDelay
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

    local iSplit = ( dHeader:GetWide() / #tHeader )
    local iLeftW = ( dHeader:GetWide() * .65 )
    local iSubTitleMargin = ( dBase:GetTall() * .01 )
    local iBarW = ( iSplit - ( iSubTitleMargin * 2 ) )
    local iTempW = ( iBarW * .5 )
    local iDamageTemp = OnePrint.Cfg.DamageTemperature
    local fLerpMoneyBar = 0

    function dHeader:Paint( iW, iH )
        OnePrint:DrawContainer( self, nil, nil )

        if not IsValid( ePrinter ) then
            return
        end

        local bPowered = ePrinter:GetPowered()
        local iMoney = ePrinter:GetMoney()
        local iStorage = ePrinter:GetStorage()

        local fCurTime = CurTime()

        for k, v in ipairs( tHeader ) do
            local iX = ( iSplit * ( k - 1 ) )

            draw.SimpleText( v.name, "OnePrint.5", iX + iSubTitleMargin, ( iH * .23 ), OnePrint:C( 2 ), 0, 1 )
            draw.SimpleText( v.func( ePrinter ), "OnePrint.3", iX + iSubTitleMargin, ( iH * .51 ), OnePrint:C( 5 ), 0, 1 )

            if v.func2 then
                draw.SimpleText( v.func2( ePrinter ), "OnePrint.6", iX + iSubTitleMargin, ( iH * .76 ), OnePrint:C( 3 ), 0, 1 )
            end

            if ( k ~= #tHeader ) then
                draw.RoundedBox( ( iH * .01 ), iX + iSplit, ( iH * .15 ), ( iH * .02 ), ( iH * .7 ), OnePrint:C( 2 ) )
            end

            if v.bMoney then
                local iProgressW = ( iMoney * iBarW / iStorage )
                if ( iProgressW ~= iProgressW ) then
                    iProgressW = 0
                end

                fLerpMoneyBar = Lerp( RealFrameTime() * 6, fLerpMoneyBar, iProgressW )

                surface.SetDrawColor( OnePrint:C( 2 ) )
                surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iBarW, ( OnePrint.iMargin * .4 ) )

                if bPowered and ( iMoney >= iStorage ) then
                    if ( ( math.floor( fCurTime ) % 2 ) == 0 ) then
                        surface.SetDrawColor( OnePrint:C( 4 ) )
                        surface.SetMaterial( matCancel )
                        surface.DrawTexturedRect( iX + iBarW - ( iH * .25 ) + iSubTitleMargin, ( iH * .23 ) - 10, ( iH * .25 ), ( iH * .25 ) )
                    end

                    surface.SetDrawColor( OnePrint:C( 4 ) )
                    surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), ( ( iProgressW > iBarW ) and iBarW or fLerpMoneyBar ), ( OnePrint.iMargin * .4 ) )
                else
                    if ( fLerpMoneyBar > 1 ) then
                        surface.SetDrawColor( OnePrint:C( 3 ) )
                        surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), fLerpMoneyBar, ( OnePrint.iMargin * .4 ) )
                    end
                end
            end

            if v.bIncome then
                surface.SetDrawColor( OnePrint:C( 2 ) )
                surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iBarW, ( OnePrint.iMargin * .4 ) )

                if bPowered and ( ePrinter:GetServers() > 0 ) then
                    local fNextOccur = ePrinter:GetNextOccur()
	                local fTime = ( fNextOccur - fCurTime )
                    local iProgressW = iBarW - ( ( fTime * iBarW  ) / self.fThinkDelay )

                    if ( fTime > 0 ) then
                        draw.SimpleText( string.format( OnePrint:L( "In %s" ), ( math.floor( fTime ) + 1 ) ), "OnePrint.6", iX + iSplit - iSubTitleMargin, ( iH * .62 ), OnePrint:C( 2 ), 2, 1 )
                    end

                    if ( iProgressW > iBarW ) then
                        iProgressW = iBarW
                    end

                    surface.SetDrawColor( OnePrint:C( ( iMoney < iStorage ) and 3 or 4 ) )
                    surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iProgressW, ( OnePrint.iMargin * .4 ) )
                end
            end

            if v.bTemperature then
                local iTemp = ePrinter:GetTemperature()
                local iProgressW = ( iTemp * iBarW / ( iDamageTemp * 2 ) )

                if bPowered then
                    local iRPM = math.Round( iTemp * 4000 / iDamageTemp )
                    iRPM = ( ( iRPM > 4000 ) and 4000 or iRPM )

                    draw.SimpleText( iRPM .. " RPM", "OnePrint.6", iX + iSplit - iSubTitleMargin, ( iH * .62 ), OnePrint:C( 2 ), 2, 1 )                    
                end

                surface.SetDrawColor( OnePrint:C( 2 ) )
                surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iBarW, ( OnePrint.iMargin * .4 ) )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- bff8dd755dec0cda0569e2c732230354a5153d153214953e6ab76f0272049b75

                if ( iTemp >= iDamageTemp ) then
                    if ( ( math.floor( fCurTime ) % 2 ) == 0 ) then
                        surface.SetDrawColor( OnePrint:C( 4 ) )
                        surface.SetMaterial( matFlame )
                        surface.DrawTexturedRect( iX + iBarW - ( iH * .25 ) + iSubTitleMargin, ( iH * .23 ) - 10, ( iH * .25 ), ( iH * .25 ) )
                    end

                    local iW = ( iProgressW > iBarW ) and iBarW or iProgressW
                    
                    surface.SetDrawColor( OnePrint:C( 4 ) )
                    surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iW, ( OnePrint.iMargin * .4 ) )
                    surface.DrawRect( iX + iSubTitleMargin + iTempW - 4, ( iH * .76 ) - ( OnePrint.iMargin * .4 ), 4, ( OnePrint.iMargin * .4 ) )
                else
                    surface.SetDrawColor( OnePrint:C( 0 ) )
                    surface.DrawRect( iX + iSubTitleMargin + iTempW, ( iH * .76 ), iTempW, ( OnePrint.iMargin * .4 ), OnePrint:C( 0 ) )

                    surface.SetDrawColor( OnePrint:C( 3 ) )
                    surface.DrawRect( iX + iSubTitleMargin, ( iH * .76 ), iProgressW, ( OnePrint.iMargin * .4 ) )
                end
            end
        end
    end

    local dWithdraw = vgui.Create( "DButton", dBase.ActiveTab )
    dWithdraw:SetSize( iLeftW, ( dBase.ActiveTab:GetTall() * .09 ) )
    dWithdraw:AlignLeft( OnePrint.iMargin )
    dWithdraw:AlignTop( ( OnePrint.iMargin * 2 ) + dHeader:GetTall() )
    dWithdraw:SetText( string.upper( OnePrint:L( "Withdraw" ) ) )
    dWithdraw:SetTextColor( OnePrint:C( 5 ) )
    dWithdraw:SetContentAlignment( 4 )
    dWithdraw:SetTextInset( iSubTitleMargin, iSubTitleMargin * 1.5 )
    dWithdraw:SetFont( "OnePrint.3" )
    dWithdraw.sTitle = string.upper( OnePrint:L( "Withdraw" ).. " " .. OnePrint:L( "Money" ) )

    function dWithdraw:Paint( iW, iH )
        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle, iSubTitleMargin )

        surface.SetDrawColor( OnePrint:C( 6 ) )
        surface.DrawRect( 0, iH - ( OnePrint.iMargin * .4 ), iW, ( OnePrint.iMargin * .4 ) )
    end

    local dIncomeHistory = vgui.Create( "DPanel", dBase.ActiveTab )
    dIncomeHistory:SetSize( iLeftW, ( dBase.ActiveTab:GetTall() * .3 ) )
    dIncomeHistory:AlignLeft( OnePrint.iMargin )
    dIncomeHistory:AlignTop( ( OnePrint.iMargin * 3 ) + dHeader:GetTall() + dWithdraw:GetTall() )
    dIncomeHistory.sTitle = string.upper( OnePrint:L( "Income history" ) )

    local tIncome = ePrinter:GetIncomeLogs()
    local tIcomeLerp = {}

    for i = 1, OnePrint.Cfg.MaxIncomeHistory do
        tIcomeLerp[ i ] = 0
    end

    local iMaxIncome = 0
    local iTotalIncome = 0

    local iGraphX, iGraphY = ( dIncomeHistory:GetWide() * .12 ), ( dIncomeHistory:GetTall() * .37 )
    local iGraphW, iGraphH = ( dIncomeHistory:GetWide() * .83 ), ( dIncomeHistory:GetTall() * .54 )
    local iBarW = ( iGraphW / OnePrint.Cfg.MaxIncomeHistory )

    function dIncomeHistory:GetTotalIncome( tIncome )
        local iTotal = 0
        for _, v in pairs( tIncome ) do
            iTotal = ( iTotal + v )
        end

        return iTotal
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

    local sUpdateText = string.format( OnePrint:L( "Update every %s sec." ), OnePrint.Cfg.IncomeHistoryDelay )

    function dIncomeHistory:Paint( iW, iH )
        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle, iSubTitleMargin )

        if not IsValid( ePrinter ) then
            return
        end

        draw.SimpleText( OnePrint:FormatMoney( iTotalIncome ), "OnePrint.3", iSubTitleMargin, ( iH * .1 ), OnePrint:C( 5 ), 0, 3 )
        draw.SimpleText( sUpdateText, "OnePrint.6", iGraphX + iGraphW, iGraphY, OnePrint:C( 2 ), 2, 4 )

        surface.SetDrawColor( OnePrint:C( 2 ) )
        for i = 0, 4 do
            surface.DrawLine( iGraphX, iGraphY + ( iGraphH / 4 * i ), iGraphX + iGraphW, iGraphY + ( iGraphH / 4 * i ) )
            draw.SimpleText( math.Round( ( ( iMaxIncome / 4 ) * i ) * .001, 1 ) .. "k", "OnePrint.6", iGraphX - ( iW * .01 ), iGraphY + iGraphH - ( iGraphH / 4 * ( i ) ), OnePrint:C( 2 ), 2, 1 )
        end

        tIncome = ePrinter:GetIncomeLogs()
        if ( #tIncome > 0 ) then
            iMaxIncome = math.max( unpack( tIncome ) )
            iTotalIncome = self:GetTotalIncome( tIncome )
        end

        for k, v in ipairs( tIncome ) do
            if v > 0 then
                local iBarH = ( v * iGraphH / iMaxIncome )
                local iBarX = iGraphX + ( iBarW * ( k - 1 ) ) + ( iBarW * .4 )

                tIcomeLerp[ k ] = Lerp( RealFrameTime() * 6, tIcomeLerp[ k ], iBarH )

                surface.SetDrawColor( OnePrint:C( 6 ) )
                surface.DrawRect( iBarX, ( iGraphY + iGraphH - tIcomeLerp[ k ] ), ( iH * .032 ), tIcomeLerp[ k ] )
            end
        end
    end

    local tActionLogs = {}
    local iActionLogs = 0
    local iLogH = 0
    local iLogY = 0

    local dActivityHistory = vgui.Create( "DPanel", dBase.ActiveTab )
    dActivityHistory:SetSize( iLeftW, ( dBase:GetTall() - dIncomeHistory:GetTall() - dHeader:GetTall() - dWithdraw:GetTall() ) - ( OnePrint.iMargin * 5 ) )
    dActivityHistory:AlignLeft( OnePrint.iMargin )
    dActivityHistory:AlignTop( dBase:GetTall() - dActivityHistory:GetTall() - OnePrint.iMargin )
    dActivityHistory.sTitle = string.upper( OnePrint:L( "Activity history" ) )

    function dActivityHistory:UpdateLogs()
        if not IsValid( ePrinter ) then
            return
        end

        tActionLogs = ePrinter:GetActionLogs()
        iActionLogs = table.Count( tActionLogs or {} )

        iLogH = ( dActivityHistory:GetTall() - ( OnePrint.iMargin * 2 ) - iSubTitleMargin) / OnePrint.Cfg.MaxActionsHistory
        iLogY = ( ( iSubTitleMargin * 1.5 ) + OnePrint.iMargin ) + ( iLogH * iActionLogs )
    end

    dActivityHistory:UpdateLogs()

    function dActivityHistory:Paint( iW, iH )
        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle, iSubTitleMargin )

        if tActionLogs then
            for k, v in ipairs( tActionLogs ) do
                if not v[ 1 ] or not tLogActions[ v[ 1 ] ] then
                    continue
                end

                local iY = iLogY - ( iLogH * ( k - 1 ) ) + 5
                local sVal = string.format( tLogActions[ v[ 1 ] ].str, v[ 3 ], string.Comma( v[ 4 ] or "" ), string.Comma( v[ 5 ] or "" ) )

                draw.RoundedBox( ( iH * .005 ), iSubTitleMargin, iY - ( iH * .07 ), ( iH * .01 ), ( iH * .06 ), OnePrint:C( 2 ) )

                draw.SimpleText( sVal, "OnePrint.6", iSubTitleMargin + ( iW * .02 ), iY, tLogActions[ v[ 1 ] ].color, 0, 4 )
                draw.SimpleText( os.date( "%Hh%M", v[ 2 ] ), "OnePrint.6", iW - iSubTitleMargin, iY, OnePrint:C( 2 ), 2, 4 )
            end
        end
    end

    local dHealth = vgui.Create( "DPanel", dBase.ActiveTab )
    dHealth:SetSize( dBase:GetWide() - iLeftW - ( OnePrint.iMargin * 3 ), ( dBase:GetTall() * .24 ) )
    dHealth:SetPos( iLeftW + ( OnePrint.iMargin * 2 ), ( OnePrint.iMargin * 2 ) + dHeader:GetTall() )
    dHealth.sTitle = string.upper( OnePrint:L( "Condition" ) )
    dHealth.fLerpCondition = 0

    local tColor = OnePrint:C( 3 )
    local matIcon = matHappy

    function dHealth:Paint( iW, iH )
        if not IsValid( ePrinter ) then
            return
        end

        local iHealth = ePrinter:Health()
        local iMaxHealth = ePrinter:GetMaxHealth()

        if ( ePrinter:GetCondition() <= OnePrint.Cfg.CrititalCondition ) then
            tColor = OnePrint:C( 4 )
            matIcon = matSad
        else
            tColor = OnePrint:C( 3 )
            matIcon = matHappy
        end

        self.fLerpCondition = Lerp( RealFrameTime() * 6, self.fLerpCondition, ( iHealth * 100 / iMaxHealth ) )

        local iArcHealth = ( 180 - ( ( self.fLerpCondition * 180 ) / 99 ) )
        if iArcHealth > 180 then iArcHealth = 180 end

        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle, iSubTitleMargin )

        drawArc( ( iW * .5 ), ( iH * .7 ), ( iH * .04 ), ( iH * .1 ), 180, tColor, -( iH * .45 ), 0 )
        drawArc( ( iW * .5 ), ( iH * .7 ), ( iH * .05 ), ( iH * .1 ), iArcHealth, OnePrint:C( 2 ), -( iH * .45 ), 0 )

        draw.SimpleText( "0%", "OnePrint.6", ( iW * .12 ), ( iH * .9 ), OnePrint:C( 2 ), 0, 4 )
        draw.SimpleText( math.Round( self.fLerpCondition ) .. "%", "OnePrint.3", ( iW * .5 ), ( iH * .7 ), OnePrint:C( 5 ), 1, 1 )
        draw.SimpleText( iHealth .. "/" .. iMaxHealth, "OnePrint.6", ( OnePrint.iMargin * .5 ), ( iH * .12 ), OnePrint:C( 2 ), 0, 3 )
        draw.SimpleText( "100%", "OnePrint.6", ( iW * .88 ), ( iH * .9 ), OnePrint:C( 2 ), 2, 4 )

        surface.SetDrawColor( tColor )
        surface.SetMaterial( matIcon )
        surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .48 ), ( iH * .18 ), ( iH * .18 ), 0 )
    end

    local dRepair = vgui.Create( "DButton", dHealth )
    dRepair:SetSize( ( dBase:GetTall() * .04 ), ( dBase:GetTall() * .04 ) )
    dRepair:AlignRight( iSubTitleMargin )
    dRepair:AlignTop( iSubTitleMargin )
    dRepair:SetText( "" )
    dRepair.fLerp = 0
    dRepair.tCol = OnePrint:C( 2 )

    function dRepair:Paint( iW, iH )
        if not IsValid( ePrinter ) or ( ePrinter:Health() == ePrinter:GetMaxHealth() ) then
            return
        end

        if self.Hovered then
            self.tCol = OnePrint:C( 6 )
            self.fLerp = Lerp( RealFrameTime() * 6, self.fLerp, -180 )
        else
            self.tCol = ( OnePrint:C( 2 ) )
            self.fLerp = Lerp( RealFrameTime() * 6, self.fLerp, 0 )
        end

        surface.SetDrawColor( self.tCol )
        surface.SetMaterial( matRepair )
        surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), iW - iSubTitleMargin, iH - iSubTitleMargin, self.fLerp )
    end

    function dRepair:DoClick()
        if not IsValid( ePrinter ) or ( ePrinter:Health() == ePrinter:GetMaxHealth() ) then
            return
        end

        if self.dPopup and IsValid( self.dPopup ) then
            self.dPopup:Remove()
            self.dPopup = nil

            return
        end

    	local iHPPercent = ( ePrinter:Health() * 100 / ePrinter:GetMaxHealth() )
        local iRepairPrice = OnePrint.Cfg.RepairPrice - math.ceil( OnePrint.Cfg.RepairPrice * iHPPercent / 100 )

        OnePrint:CreatePopup( dBase.ActiveTab, string.upper( OnePrint:L( "Repair" ) ) .. " [" .. OnePrint:FormatMoney( iRepairPrice ) .. "]", OnePrint:L( "Are you sure?" ), {
            { name = OnePrint:L( "Yes" ), color = OnePrint:C( 3 ), func = function( dPopup )
                if IsValid( dPopup ) then
                    dPopup:Remove()
                end

                OnePrint:Play2DSound( "oneprint/notify.mp3" )

                if not LocalPlayer():OP_CanAfford( iRepairPrice ) then
                    OnePrint:Notify( dBase.eEntity, OnePrint:L( "Not enough money" ), 1, 3 )

                    return
                end

                net.Start( "OnePrintNW" )
                    net.WriteUInt( 4, 4 )
                    net.WriteEntity( ePrinter )
                net.SendToServer()

                OnePrint:Notify( dBase.eEntity, string.format( OnePrint:L( "You paid %s to repair this printer" ), OnePrint:FormatMoney( iRepairPrice ) ), 0, 3 )

                timer.Simple( .3, function()
                    if dActivityHistory and IsValid( dActivityHistory ) then
                        dActivityHistory:UpdateLogs()
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

        OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
    end

    local dMenu = vgui.Create( "DButton", dBase.ActiveTab )
    dMenu:SetSize( dBase:GetWide() - iLeftW - ( OnePrint.iMargin * 3 ), ( dBase:GetTall() * .09 ) )
    dMenu:SetPos( iLeftW + ( OnePrint.iMargin * 2 ), ( OnePrint.iMargin * 3 ) + dHeader:GetTall() + dHealth:GetTall() )
    dMenu:SetText( string.upper( OnePrint:L( "Users" ) ) )
    dMenu:SetTextColor( OnePrint:C( 5 ) )
    dMenu:SetContentAlignment( 4 )
    dMenu:SetTextInset( iSubTitleMargin, ( iSubTitleMargin * 1.5 ) )
    dMenu:SetFont( "OnePrint.3" )
    dMenu.sTitle = string.upper( OnePrint:L( "Show" ) .. " " .. OnePrint:L( "Users" ) )

    function dMenu:Paint( iW, iH )
        OnePrint:DrawContainer( self, OnePrint.iRoundness, self.sTitle, iSubTitleMargin )

        surface.SetDrawColor( OnePrint:C( 6 ) )
        surface.DrawRect( 0, iH - ( OnePrint.iMargin * .4 ), iW, ( OnePrint.iMargin * .4 ) )
    end

    local dLast = vgui.Create( "DPanel", dBase.ActiveTab )
    dLast:SetSize( dBase:GetWide() - iLeftW - ( OnePrint.iMargin * 3 ), dBase:GetTall() - dMenu:GetTall() - dHealth:GetTall() - dHeader:GetTall() - ( OnePrint.iMargin * 5 ) )
    dLast:SetPos( iLeftW + ( OnePrint.iMargin * 2 ), dBase:GetTall() - dLast:GetTall() - OnePrint.iMargin )

    drawPrinterMenu( dBase, dLast )

    function dMenu:DoClick()
        if dLast.bDrawUsers then
            drawPrinterMenu( dBase, dLast )
            dMenu:SetText( string.upper( OnePrint:L( "Users" ) ) )
            dMenu.sTitle = string.upper( OnePrint:L( "Show" ) .. " " .. OnePrint:L( "Users" ) )
        else
            drawPrinterUsers( dBase, dLast )
            dMenu:SetText( string.upper( OnePrint:L( "Menu" ) ) )
            dMenu.sTitle = string.upper( OnePrint:L( "Show" ) .. " " .. OnePrint:L( "Menu" ) )
        end

        OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
    end

    function dWithdraw:DoClick()
        if not ePrinter or not IsValid( ePrinter ) then
            return
        end

        local iMoney = ePrinter:GetMoney()
        if ( iMoney <= 0 ) then
            OnePrint:Notify( dBase.eEntity, OnePrint:L( "This printer is empty" ), 1, 3 )
            OnePrint:Play2DSound( "oneprint/notify.mp3" )

            return
        end

        net.Start( "OnePrintNW" )
            net.WriteUInt( 1, 4 )
            net.WriteEntity( ePrinter )
        net.SendToServer()

        timer.Simple( .3, function()
            if dActivityHistory and IsValid( dActivityHistory ) then
                dActivityHistory:UpdateLogs()
            end
        end )

        OnePrint:Notify( dBase.eEntity, string.format( OnePrint:L( "You withdrew %s" ), OnePrint:FormatMoney( iMoney ) ), 0, 2 )
        OnePrint:Play2DSound( "oneprint/notify.mp3" )
    end
end

OnePrint:RegisterTab( Home )
