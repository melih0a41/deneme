/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

OnePrint.GSmartWatch = {}

local GSWApp = {}

GSWApp.ID = "app_oneprint"
GSWApp.Name = "OnePrint"
GSWApp.Icon = Material( "materials/oneprint/oneprint_gsw.png", "smooth" )
GSWApp.ShowTime = true

--[[

    GSWApp:RunApp

]]--

function GSWApp.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- bff8dd755dec0cda0569e2c732230354a5153d153214953e6ab76f0272049b75

    dBase.RunningApp = vgui.Create( "DPanel", dBase )
    dBase.RunningApp:SetSize( dBase:GetWide(), dBase:GetTall() )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

    function dBase.RunningApp:RefreshPrinterData()
        if not self.iSelected or not OnePrint.GSmartWatch[ self.iSelected ] then
            if not OnePrint.GSmartWatch[ 1 ] then
                self.iSelected = nil
                return
            end

            self.iSelected = 1
        end

        self.iMoney = ( OnePrint.GSmartWatch[ self.iSelected ].money or 0 )
        self.iHealth = ( OnePrint.GSmartWatch[ self.iSelected ].health or 0 )
        self.iTemperature = ( OnePrint.GSmartWatch[ self.iSelected ].temperature or 0 )

        self.iMaxPrinters = table.Count( OnePrint.GSmartWatch )
        self.iBarW = ( ( self:GetWide() * .6 ) / self.iMaxPrinters )
    end

    dBase.RunningApp:RefreshPrinterData()

    local fLerpScroll = 0
    local fLerpMoney = 0

    function dBase.RunningApp:Paint( iW, iH )
        GSmartWatch:SetStencil()

        if self.iSelected then
            draw.SimpleText( "OnePrint [" .. self.iSelected .. "]", "GSmartWatch.48", ( iW * .5 ), ( iH * .3 ), color_white, 1, 1 )

            if OnePrint.GSmartWatch[ 2 ] then
                fLerpScroll = Lerp( RealFrameTime() * 6, fLerpScroll, ( self.iBarW * ( self.iSelected - 1 ) ) )

                draw.RoundedBox( 0, ( iW * .2 ), ( iH * .4 ), ( iW * .6 ), 8, OnePrint:C( 0 ) )
                draw.RoundedBox( 0, ( iW * .2 ) + fLerpScroll, ( iH * .4 ), self.iBarW, 8, OnePrint:C( 2 ) )
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            fLerpMoney = Lerp( RealFrameTime() * 6, fLerpMoney, self.iMoney )
            draw.SimpleText( OnePrint:FormatMoney( math.Round( fLerpMoney ) ), "GSmartWatch.64", ( iW * .5 ), ( iH * .53 ), OnePrint:C( 6 ), 1, 1 )

            draw.SimpleText( self.iHealth .. "HP, " .. self.iTemperature .. "°C", "GSmartWatch.48", ( iW * .5 ), ( iH * .7 ), OnePrint:C( 5 ), 1, 1 )
        else
            draw.SimpleText( "No printer found..", "GSmartWatch.32", ( iW * .5 ), ( iH * .5 ), color_white, 1, 1 )
        end

        draw.SimpleText( "LMB: UPDATE", "GSmartWatch.32", ( iW * .5 ), ( iH * .8 ), OnePrint:C( 2 ), 1, 1 )

        render.SetStencilEnable( false )
    end
end

--[[

    GSWApp.OnUse

]]--

function GSWApp.OnUse( dBase, sBind )
    if not dBase or not IsValid( dBase ) then
        return
    end

    local dParent = dBase.RunningApp
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

    if ( sBind == "+attack" ) then
        if dParent and IsValid( dParent ) then
            net.Start( "OnePrintNW" )
                net.WriteUInt( 10, 4 )
            net.SendToServer()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

            timer.Simple( .3, function()
                if dParent and IsValid( dParent ) and dParent.RefreshPrinterData then
                    dParent:RefreshPrinterData()
                end
            end )
        end

    elseif ( sBind == "invnext" ) then
        dParent.iSelected = ( dParent.iSelected or 1 )
        local iNew = ( dParent.iSelected - 1 )
        dParent.iSelected = OnePrint.GSmartWatch[ iNew ] and iNew or table.Count( OnePrint.GSmartWatch )

        if dParent.RefreshPrinterData then
            dBase.RunningApp:RefreshPrinterData()
        end

    elseif ( sBind == "invprev" ) then
        dParent.iSelected = ( dParent.iSelected or 1 )
        local iNew = ( dParent.iSelected + 1 )
        dParent.iSelected = OnePrint.GSmartWatch[ iNew ] and iNew or 1

        if dParent.RefreshPrinterData then
            dBase.RunningApp:RefreshPrinterData()
        end

    elseif ( sBind == "+attack2" ) then
        GSmartWatch:RunApp( "app_myapps" )
    end
end

GSmartWatch:RegisterApp( GSWApp )
GSWApp = nil
