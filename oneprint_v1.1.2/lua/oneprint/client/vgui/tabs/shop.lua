/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local Shop = {}

Shop.ID = 2
Shop.Name = "Shop"

local matShop = Material( "materials/oneprint/shop.png", "smooth" )

--[[

    formatUpgrades

]]--

local tMutators = {
    [ "income" ] = {
        string.upper( OnePrint:L( "Income" ) ),
        function( i )
            return "+" .. OnePrint:FormatMoney( i )
        end,
        function( i, eEnt )
            return OnePrint:FormatMoney( i * eEnt:GetServers() )
        end
    },
    [ "incomeP" ] = {
        string.upper( OnePrint:L( "Income" ) ),
        function( i )
            return "+" .. string.Comma( i ) .. "%"
        end,
        function( i, eEnt )
            return "+" .. string.Comma( i * eEnt:GetOverclocking() ) .. "%"
        end
    },
    [ "maxHealth" ] = {
        string.upper( OnePrint:L( "Max health" ) ),
        function( i )
            return "+" .. i .. "HP"
        end,
        function( i, eEnt )
            return "+" .. ( i * eEnt:GetDefense() ) .. "HP"
        end
    },
    [ "power" ] = {
        string.upper( OnePrint:L( "Max power" ) ),
        function( i )
            return "+" .. i
        end,
        function( i, eEnt )
            return ( eEnt:GetMaxPower() )
        end
    },
    [ "heat" ] = {
        string.upper( OnePrint:L( "Max temperature" ) ),
        function( i )
            return ( i >= 0 and "+" or "" ) .. i .. "°C"
        end,
        function( i, eEnt )
            return eEnt:GetMaxTemperature() .. "°C"
        end
    },
    [ "watercooling" ] = {
        string.upper( OnePrint:L( "Max watercooling" ) ),
        function( i )
            return "+" .. i
        end,
        function( i, eEnt )
            return ( eEnt:GetMaxWatercooling() )
        end
    },
    [ "overclocking" ] = {
        string.upper( OnePrint:L( "Max overclocking" ) ),
        function( i )
            return "+" .. i
        end,
        function( i, eEnt )
            return ( eEnt:GetMaxOverclocking() )
        end
    },
    [ "security" ] = {
        string.upper( OnePrint:L( "Hacking difficulty" ) ),
        function( i )
            return "+" .. i
        end,
        function( i, eEnt )
            return ( i * eEnt:GetSecurity() )
        end
    },
    [ "maxSecurity" ] = {
        string.upper( OnePrint:L( "Max security" ) ),
        function( i )
            return "+" .. i
        end,
        function( i, eEnt )
            return eEnt:GetMaxSecurity()
        end
    },
    [ "hackNotify" ] = {
        string.upper( OnePrint:L( "Hacking notification" ) ),
        function( i )
            return string.upper( OnePrint:L( "Installation" ) )
        end,
        function( i, eEnt )
            return ( eEnt:GetHackNotif() and string.upper( OnePrint:L( "Installed" ) ) or string.upper( OnePrint:L( "Not installed" ) ) )
        end
    },
    [ "lowHPNotify" ] = {
        string.upper( OnePrint:L( "Low HP notification" ) ),
        function( i )
            return string.upper( OnePrint:L( "Installation" ) )
        end,
        function( i, eEnt )
            return ( eEnt:GetLowHPNotif() and string.upper( OnePrint:L( "Installed" ) ) or string.upper( OnePrint:L( "Not installed" ) ) )
        end
    },
    [ "silencer" ] = {
        string.upper( OnePrint:L( "Noise reduction" ) ),
        function( i )
            return "-" .. ( i * 10 ) .. "dB"
        end,
        function( i, eEnt )
            return "-" .. ( ( i * eEnt:GetSilencer() ) * 10 ) .. "dB"
        end
    },
    [ "maxSilencer" ] = {
        string.upper( OnePrint:L( "Max silencer" ) ),
        function( i )
            return "+" .. i end,
        function( i, eEnt )
            return ( eEnt:GetMaxSilencer() )
        end
    },
}

local function formatUpgrades( sID, bValue, bTotal, eEnt )
    if not OnePrint.Upgrade[ sID ] then
        return ""
    end

    local sVal = ""

    if bTotal then
        for k, v in SortedPairs( OnePrint.Upgrade[ sID ].mutators ) do
            if tMutators[ k ] and tMutators[ k ][ 3 ] then
                sVal = sVal .. tMutators[ k ][ 3 ]( v, eEnt ) .. "__,"
            end
        end

        return sVal
    end

    if bValue then
        local i = 0
        local iMutatorCount = table.Count( OnePrint.Upgrade[ sID ].mutators )

        for k, v in SortedPairs( OnePrint.Upgrade[ sID ].mutators ) do
            i = ( i + 1 )
            if tMutators[ k ] and tMutators[ k ][ 2 ] then
                sVal = sVal .. tMutators[ k ][ 2 ]( v ) .. ( ( i == iMutatorCount ) and "" or "__," )
            end
        end

        return sVal
    end

    for k, v in SortedPairs( OnePrint.Upgrade[ sID ].mutators ) do
        if tMutators[ k ] and tMutators[ k ][ 1 ] then
            sVal = sVal .. tMutators[ k ][ 1 ] .. "\n"
        end
    end

    return sVal
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

-- Upgrades

local tUpgrades = {
    [ 1 ] = {
        mat = Material( "materials/oneprint/upgrades/server.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetServers() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxServers() end,
    },
    [ 2 ] = {
        mat = Material( "materials/oneprint/upgrades/defense.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetDefense() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxDefense() end,
    },
    [ 3 ] = {
        mat = Material( "materials/oneprint/upgrades/watercooling.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetWatercooling() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxWatercooling() end,
    },
    [ 4 ] = {
        mat = Material( "materials/oneprint/upgrades/power.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetPower() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxPower() end,
    },
    [ 5 ] = {
        mat = Material( "materials/oneprint/upgrades/overclocking.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetOverclocking() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxOverclocking() end,
    },
    [ 6 ] = {
        mat = Material( "materials/oneprint/code.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetSecurity() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxSecurity() end,
    },
    [ 7 ] = {
        mat = Material( "materials/oneprint/upgrades/silencer.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetSilencer() end,
        iMax = function( dBase ) return dBase.eEntity:GetMaxSilencer() end,
    },
    [ 8 ] = {
        mat = Material( "materials/oneprint/upgrades/notif_hack.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetHackNotif() and 1 or 0 end,
        iMax = function( dBase ) return 1 end,
    },
    [ 9 ] = {
        mat = Material( "materials/oneprint/upgrades/notif_lowhp.png", "smooth" ),
        iCur = function( dBase ) return dBase.eEntity:GetLowHPNotif() and 1 or 0 end,
        iMax = function( dBase ) return 1 end,
    },
}

--[[

    Shop.Run

]]--

function Shop.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end

    if not dBase.eEntity or not IsValid( dBase.eEntity ) or ( dBase.eEntity:GetClass() ~= "oneprint" ) then
        return
    end

    dBase.ActiveTab = vgui.Create( "DPanel", dBase )
    dBase.ActiveTab:SetSize( dBase:GetWide(), dBase:GetTall() )
    dBase.ActiveTab.Paint = nil

    local iSubTitleMargin = ( dBase:GetTall() * .01 )

    local dHeader = vgui.Create( "OnePrintTitle", dBase.ActiveTab )
    dHeader:SetSize( dBase:GetWide() - ( OnePrint.iMargin * 2 ), ( dBase:GetTall() * .09 ) )
    dHeader:SetPos( OnePrint.iMargin, OnePrint.iMargin )
    dHeader:SetHeader( string.upper( OnePrint:L( "Shop" ) ), matShop )

    -- Info
    local dInfo = vgui.Create( "DPanel", dBase.ActiveTab )
    dInfo:SetSize( dHeader:GetWide(), ( dBase.ActiveTab:GetTall() * .56 ) )
    dInfo:SetPos( OnePrint.iMargin, ( OnePrint.iMargin * 2 ) + dHeader:GetTall() )

    dInfo.iUpgrade = 1
    dInfo.iCur = 0
    dInfo.iMax = 0
    dInfo.sTitle = ""
    dInfo.sLocked = string.upper( "Upgrade locked" )
    dInfo.fLerpMat = dInfo.iImgH

    local iImgH = ( dBase:GetTall() * .1 )
    dInfo.iImgH = iImgH - ( iSubTitleMargin * 4 )

    function dInfo:Paint( iW, iH )
        draw.RoundedBox( OnePrint.iRoundness, 0, 0, iW, iH, OnePrint:C( 1 ) )

        if self.bLocked then
            draw.SimpleText( self.sLocked, "OnePrint.3", ( iW * .5 ), ( iH * .5 ), OnePrint:C( 2 ), 1, 1 )
            return
        end
    
        if tUpgrades[ self.iUpgrade ].mat then
            draw.RoundedBox( OnePrint.iRoundness, OnePrint.iMargin, OnePrint.iMargin, iImgH, iImgH, OnePrint:C( 0 ) )

            self.fLerpMat = Lerp( RealFrameTime() * 6, self.fLerpMat, self.iImgH )

            surface.SetDrawColor( OnePrint:C( 5 ) )
            surface.SetMaterial( tUpgrades[ self.iUpgrade ].mat )
            surface.DrawTexturedRectRotated( OnePrint.iMargin + ( iImgH * .5 ), OnePrint.iMargin + ( iImgH * .5 ), self.fLerpMat, self.fLerpMat, 0 )
        end

        draw.SimpleText( self.sTitle, "OnePrint.3", iImgH + ( OnePrint.iMargin * 2 ), ( OnePrint.iMargin - 6 ), OnePrint:C( 5 ), 0, 3 )

        local sText = self.iCur .. "/" .. self.iMax
        surface.SetFont( "OnePrint.2" )
        
        local iTextW, iTextH = surface.GetTextSize( sText )
        draw.SimpleText( sText, "OnePrint.2", iImgH + ( OnePrint.iMargin * 2 ), iImgH + ( OnePrint.iMargin * 2 ), OnePrint:C( 5 ), 0, 4 )

        local iBarW = ( iW - iTextW - ( OnePrint.iMargin * 4 ) - iImgH )
        local iSBarW = ( iBarW / self.iMax ) + ( 6 / self.iMax )

        for i = 1, self.iMax do
            surface.SetDrawColor( OnePrint:C( ( i <= self.iCur ) and 3 or 2 ) )
            surface.DrawRect( ( ( i - 1 ) * iSBarW  ) + iTextW + ( OnePrint.iMargin * 3 ) + iImgH, ( iImgH - 2 ) + iSubTitleMargin, iSBarW - 6, 4 )
        end
    end

    -- Infos
    function dInfo:ShowDetails( iUpgrade, bDisableStartAnim )
        self.iCur = tUpgrades[ iUpgrade ].iCur( dBase )
        self.iMax = tUpgrades[ iUpgrade ].iMax( dBase )
        self.iUpgrade = iUpgrade

        self.sTitle = string.upper( OnePrint.Upgrade[ iUpgrade ].name )
        self.bLocked = ( ( dInfo.iCur + dInfo.iMax ) == 0 ) 
        self.bLimitReached = ( dInfo.iCur >= dInfo.iMax )
        self.bAffordable = LocalPlayer():OP_CanAfford( OnePrint.Upgrade[ dInfo.iUpgrade ].price )

        self.fLerpMat = ( self.iImgH + OnePrint.iMargin )

        if self.bLocked then
            if self.dLabel and IsValid( self.dLabel ) then  
                self.dLabel:SetVisible( false )
            end
            if self.dBuy and IsValid( self.dBuy ) then  
                self.dBuy:SetVisible( false )
            end

            return 
        end

        if self.dLabel and IsValid( self.dLabel ) then
            self.dLabel:SetText( formatUpgrades( iUpgrade ) )
        end

        self.dLabel:SetVisible( true )
        self.dBuy:SetVisible( true )

        local tSplit = string.Split( formatUpgrades( iUpgrade, true ), "__," )
        local tTotal = string.Split( formatUpgrades( iUpgrade, false, true, dBase.eEntity ), "__," )

        local sUpgrade = string.upper( OnePrint:L( "Upgrade" ) )
        local sCurrent = string.upper( OnePrint:L( "Current" ) )

        function self.dLabel:Paint( iW, iH )
            draw.SimpleText( sUpgrade, "OnePrint.5", ( iW * .75 ), 0, OnePrint:C( 2 ), 2, 4 )
            for k, v in pairs( tSplit ) do
                draw.SimpleText( dInfo.bLimitReached and OnePrint:L( "N/A" ) or v, "OnePrint.5", ( iW * .75 ), ( ( iH * .95 ) * k ) - 8, OnePrint:DarkenColor( OnePrint:C( 6 ), 50 ), 2, 1 )    
            end

            draw.SimpleText( sCurrent, "OnePrint.5", iW, 0, OnePrint:C( 2 ), 2, 4 )    
            for k, v in pairs( tTotal ) do
                draw.SimpleText( v, "OnePrint.5", iW, ( ( iH * .95 ) * k ) - 8, OnePrint:C( 6 ), 2, 1 )    
            end
        end

        if self.dBuy and IsValid( self.dBuy ) then
            self.dBuy:SetText( self.bLimitReached and "" or OnePrint:FormatMoney( OnePrint.Upgrade[ iUpgrade ].price ) )
            self.dBuy:SizeToContents()
            self.dBuy:SetWide( self.dBuy:GetWide() + OnePrint.iMargin )
            self.dBuy:AlignRight( OnePrint.iMargin )
            self.dBuy:AlignBottom( OnePrint.iMargin )
        end
    end

    dInfo.dLabel = vgui.Create( "DLabel", dInfo )
    dInfo.dLabel:SetText( "" )
    dInfo.dLabel:SetFont( "OnePrint.5" )
    dInfo.dLabel:SetTextColor( OnePrint:C( 5 ) )
    dInfo.dLabel:SetContentAlignment( 7 )
    dInfo.dLabel:SizeToContents()
    dInfo.dLabel:SetWide( dInfo:GetWide() - ( OnePrint.iMargin * 2 ) )
    dInfo.dLabel:SetPos( OnePrint.iMargin, ( dBase:GetTall() * .19 ) )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

    if OnePrint.Cfg.CanUpgradeAll then
        dInfo.dBuyAll = vgui.Create( "DButton", dInfo )        
        dInfo.dBuyAll:SetText( "Upgrade" )
        dInfo.dBuyAll:SetFont( "OnePrint.3" )
        dInfo.dBuyAll:SetTextColor( OnePrint:C( 5 ) )
        dInfo.dBuyAll:SizeToContents()
        dInfo.dBuyAll:SetWide( dInfo.dBuyAll:GetWide() + OnePrint.iMargin )
        dInfo.dBuyAll:AlignRight( OnePrint.iMargin + 220 )
        dInfo.dBuyAll:AlignBottom( OnePrint.iMargin )
        dInfo.dBuyAll.tCol = OnePrint:C( 3 )
        dInfo.dBuyAll.fLerpTextX = 0
        dInfo.dBuyAll.fLerpBoxH = ( OnePrint.iMargin * .25 )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        function dInfo.dBuyAll:Paint( iW, iH )
            if dInfo.bAffordable and not dInfo.bLocked and not dInfo.bLimitReached then
                self.tCol = OnePrint:C( 3 )
            else
                self.tCol = OnePrint:C( 2 )
            end

            if dInfo.bLocked then
                self.sText = nil
            else
                self.sText = string.upper( OnePrint:L( dInfo.bAffordable and "Upgrade All" or "Not enough money" ) )
            end

            if dInfo.bLimitReached then
                self.sText = ""
                self:SetTextColor( OnePrint:C( 0 ) )
            else
                self:SetTextColor( OnePrint:C( 5 ) )
            end

            if not dInfo.bLocked and dInfo.bLimitReached then
                self.fLerpTextX = Lerp( RealFrameTime() * 6, self.fLerpTextX, iW + OnePrint.iMargin )

                if not self.bLimit then
                    self.bLimit = true
                    self:SetText( "" )
                end
            else
                self.fLerpTextX = Lerp( RealFrameTime() * 6, self.fLerpTextX, 0 )

                local upgradeNeeded = 0
                
                local iCur, iMax
                if tUpgrades && tUpgrades[dInfo.iUpgrade] then
                    if tUpgrades[dInfo.iUpgrade]["iCur"] && tUpgrades[dInfo.iUpgrade]["iMax"] then
                        iCur = tUpgrades[dInfo.iUpgrade]["iCur"](dBase)
                        iMax = tUpgrades[dInfo.iUpgrade]["iMax"](dBase)

                        upgradeNeeded = iMax - iCur
                    end
                end

                if self.bLimit then
                    self.bLimit = nil
                end

                self:SetText( OnePrint:FormatMoney( OnePrint.Upgrade[ dInfo.iUpgrade ].price * upgradeNeeded ) )

                self.fLerpBoxH = Lerp( RealFrameTime() * 12, self.fLerpBoxH, self.Hovered and iH or ( OnePrint.iMargin * .25 ) )

                surface.SetDrawColor( self.tCol )
                surface.DrawRect( 0, ( iH - self.fLerpBoxH ), iW, self.fLerpBoxH )
            end

            if self.sText then
                draw.SimpleText( self.sText, "OnePrint.4", - OnePrint.iMargin + self.fLerpTextX, iH + OnePrint.iMargin, OnePrint:C( 2 ), 2, 4 )
            end
        end

        function dInfo.dBuyAll:DoClick()
            if dBase and dBase.eEntity and IsValid( dBase.eEntity ) and dBase.eEntity:CanUpgrade( dInfo.iUpgrade ) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

                local upgradeNeeded = 0
                
                local iCur, iMax
                if tUpgrades && tUpgrades[dInfo.iUpgrade] then
                    if tUpgrades[dInfo.iUpgrade]["iCur"] && tUpgrades[dInfo.iUpgrade]["iMax"] then
                        iCur = tUpgrades[dInfo.iUpgrade]["iCur"](dBase)
                        iMax = tUpgrades[dInfo.iUpgrade]["iMax"](dBase)

                        upgradeNeeded = iMax - iCur
                    end
                end

                if LocalPlayer():OP_CanAfford( OnePrint.Upgrade[ dInfo.iUpgrade ].price * iMax ) then
                    net.Start( "OnePrintNW" )
                        net.WriteUInt( 11, 4 )
                        net.WriteUInt( dInfo.iUpgrade, 4 )
                        net.WriteEntity( dBase.eEntity )
                        net.WriteUInt( upgradeNeeded, 12 )
                    net.SendToServer()

                    OnePrint:Notify( dBase.eEntity, string.format( OnePrint:L( "%s upgrade installed" ), OnePrint.Upgrade[ dInfo.iUpgrade ].name ), 0, 3 )

                    timer.Simple( .3, function()
                        if dInfo and IsValid( dInfo ) and dInfo.iUpgrade then
                            dInfo:ShowDetails( dInfo.iUpgrade )
                        end
                    end )
                else
                    OnePrint:Notify( dBase.eEntity, OnePrint:L( "Not enough money" ), 1, 3 )
                end

                OnePrint:Play2DSound( "oneprint/notify.mp3" )
            else
                OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
            end
        end
    end

    dInfo.dBuy = vgui.Create( "DButton", dInfo )        
    dInfo.dBuy:SetText( "" )
    dInfo.dBuy:SetFont( "OnePrint.3" )
    dInfo.dBuy:SetTextColor( OnePrint:C( 5 ) )
    dInfo.dBuy:SizeToContents()
    dInfo.dBuy:SetWide( dInfo.dBuy:GetWide() + OnePrint.iMargin )
    dInfo.dBuy:AlignRight( OnePrint.iMargin )
    dInfo.dBuy:AlignBottom( OnePrint.iMargin )
    dInfo.dBuy.tCol = OnePrint:C( 3 )
    dInfo.dBuy.fLerpTextX = 0
    dInfo.dBuy.fLerpBoxH = ( OnePrint.iMargin * .25 )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

    function dInfo.dBuy:Paint( iW, iH )
        if dInfo.bAffordable and not dInfo.bLocked and not dInfo.bLimitReached then
            self.tCol = OnePrint:C( 3 )
        else
            self.tCol = OnePrint:C( 2 )
        end

        if dInfo.bLocked then
            self.sText = nil
        else
            self.sText = string.upper( OnePrint:L( dInfo.bAffordable and "Upgrade" or "Not enough money" ) )
        end

        if dInfo.bLimitReached then
            self.sText = string.upper( OnePrint:L( "Limit reached" ) )
            self:SetTextColor( OnePrint:C( 0 ) )
        else
            self:SetTextColor( OnePrint:C( 5 ) )
        end

        if not dInfo.bLocked and dInfo.bLimitReached then
            self.fLerpTextX = Lerp( RealFrameTime() * 6, self.fLerpTextX, iW + OnePrint.iMargin )

            if not self.bLimit then
                self.bLimit = true
                self:SetText( "" )
            end
        else
            self.fLerpTextX = Lerp( RealFrameTime() * 6, self.fLerpTextX, 0 )

            if self.bLimit then
                self.bLimit = nil
                self:SetText( OnePrint:FormatMoney( OnePrint.Upgrade[ dInfo.iUpgrade ].price ) )
            end

            self.fLerpBoxH = Lerp( RealFrameTime() * 12, self.fLerpBoxH, self.Hovered and iH or ( OnePrint.iMargin * .25 ) )

            surface.SetDrawColor( self.tCol )
            surface.DrawRect( 0, ( iH - self.fLerpBoxH ), iW, self.fLerpBoxH )
        end

        if self.sText then
            draw.SimpleText( self.sText, "OnePrint.4", - OnePrint.iMargin + self.fLerpTextX, iH + OnePrint.iMargin, OnePrint:C( 2 ), 2, 4 )
        end
    end

    function dInfo.dBuy:DoClick()
        if dBase and dBase.eEntity and IsValid( dBase.eEntity ) and dBase.eEntity:CanUpgrade( dInfo.iUpgrade ) then
            if LocalPlayer():OP_CanAfford( OnePrint.Upgrade[ dInfo.iUpgrade ].price ) then
                net.Start( "OnePrintNW" )
                    net.WriteUInt( 2, 4 )
                    net.WriteUInt( dInfo.iUpgrade, 4 )
                    net.WriteEntity( dBase.eEntity )
                net.SendToServer()

                OnePrint:Notify( dBase.eEntity, string.format( OnePrint:L( "%s upgrade installed" ), OnePrint.Upgrade[ dInfo.iUpgrade ].name ), 0, 3 )

                timer.Simple( .3, function()
                    if dInfo and IsValid( dInfo ) and dInfo.iUpgrade then
                        dInfo:ShowDetails( dInfo.iUpgrade )
                    end
                end )
            else
                OnePrint:Notify( dBase.eEntity, OnePrint:L( "Not enough money" ), 1, 3 )
            end

            OnePrint:Play2DSound( "oneprint/notify.mp3" )
        else
            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )
        end
    end

    -- Layout
    local dLayout = vgui.Create( "DIconLayout", dBase.ActiveTab )
    dLayout:SetSize( dHeader:GetWide(), ( dBase.ActiveTab:GetTall() - dHeader:GetTall() - dInfo:GetTall() - ( OnePrint.iMargin * 3 ) ) )
    dLayout:SetPos( OnePrint.iMargin, ( OnePrint.iMargin * 3 ) + dHeader:GetTall() + dInfo:GetTall() )
    dLayout:SetSpaceX( OnePrint.iMargin )
    dLayout:SetSpaceY( OnePrint.iMargin )

    -- Buttons
    local iColumns = 5
    local iLines = 2

    for k, v in ipairs( tUpgrades ) do
        local dContainer = dLayout:Add( "DButton" )
        dContainer:SetText( "" )
        dContainer:SetSize( ( dLayout:GetWide() / iColumns ) - dLayout:GetSpaceX() + ( OnePrint.iMargin * .2 ), ( dLayout:GetTall() / iLines ) - dLayout:GetSpaceY() )
        dContainer.bLocked = false 

        local iScale = math.min( dContainer:GetWide(), dContainer:GetTall() )
        dContainer.fLerpScale = 0

        local sLocked = string.upper( OnePrint:L( "Locked" ) )

        function dContainer:Paint( iW, iH )
            OnePrint:DrawContainer( self, OnePrint.iRoundness  )

            local bSelected = ( dInfo.iUpgrade == k )
            if bSelected then
                surface.SetDrawColor( OnePrint:C( self.bLocked and 2 or 6 ) )
                self.fLerpScale = Lerp( RealFrameTime() * 2, self.fLerpScale, iScale - ( OnePrint.iMargin * 3 ) )
            else
                surface.SetDrawColor( OnePrint:C( 2 ) )
                self.fLerpScale = Lerp( RealFrameTime() * 2, self.fLerpScale, iScale - ( OnePrint.iMargin * ( self.Hovered and 3 or 4 ) ) )
            end

            if v.mat then
                surface.SetMaterial( v.mat )
                surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), self.fLerpScale, self.fLerpScale, 0 )
            end

            local iCur, iMax = v.iCur( dBase ), v.iMax( dBase )
            if ( iCur == iMax ) and ( iMax == 0 ) then
                self.bLocked = true
                draw.SimpleText( sLocked, "OnePrint.5", ( iW * .5 ), ( iH * .5 ), OnePrint:C( 4 ), 1, 1 )
            else
                self.bLocked = nil
                draw.SimpleText( iCur .. "/" .. iMax, "OnePrint.5", iW - ( OnePrint.iMargin * .5 ), iH, OnePrint:C( bSelected and 6 or 2 ), 2, 4 )
            end
        end

        function dContainer:DoClick()
            dInfo:ShowDetails( k )
            OnePrint:Play2DSound( "oneprint/keypress_standard.mp3" )

            self.fLerpScale = iScale - ( OnePrint.iMargin * 2.5 )
        end
    end

    dInfo:ShowDetails( 1, true )
end

OnePrint:RegisterTab( Shop )
