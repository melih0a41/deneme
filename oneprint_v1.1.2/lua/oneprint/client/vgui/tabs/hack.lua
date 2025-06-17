/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local Hack = {}

Hack.ID = 4
Hack.Name = OnePrint:L( "Hack" )

local matLock = Material( "materials/oneprint/lock.png", "smooth" )
local matCircle = Material( "materials/oneprint/hack_circleoutline.png", "smooth" )
local matCircle2 = Material( "materials/oneprint/circle_full.png", "smooth" )
local matTarget = Material( "materials/oneprint/hack_target.png", "smooth" )
local matPoint = Material( "materials/oneprint/hack_point.png", "smooth" )

--[[

    randomString

]]--

local function randomString( iLen )
    if not iLen or not isnumber( iLen ) or ( iLen < 1 ) then
        iLen = 1
    end

    local sRandString = ""
    for i = 1, iLen do
        sRandString = sRandString .. string.char( math.random( 42, 126 ) )
    end

    return sRandString
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

--[[

    Hack.Run

]]--

function Hack.Run( dBase )
    if not dBase or not IsValid( dBase ) then
        return
    end

    if not dBase.eEntity or not IsValid( dBase.eEntity ) or ( dBase.eEntity:GetClass() ~= "oneprint" ) then
        return
    end

    dBase.ActiveTab = vgui.Create( "DPanel", dBase )
    dBase.ActiveTab:SetSize( dBase:GetWide(), dBase:GetTall() )
    dBase.ActiveTab.Paint = nil

    -- Hack
    local dLock = vgui.Create( "DButton", dBase.ActiveTab )
    dLock:SetSize( ( dBase:GetTall() * .05 ), ( dBase:GetTall() * .05 ) )
    dLock:SetText( "" )
    dLock:AlignRight( OnePrint.iMargin )
    dLock:AlignTop( OnePrint.iMargin )
    dLock.tColor = OnePrint:C( 1 )

    function dLock:Paint( iW, iH )
        surface.SetDrawColor( self.tColor )
        surface.SetMaterial( matLock )
        surface.DrawTexturedRect( 0, 0, iW, iH , 0 )
    end

    function dLock:OnCursorEntered()
        self.tColor = OnePrint:C( 5 )
    end

    function dLock:OnCursorExited()
        self.tColor = OnePrint:C( 2 )
    end

    function dLock:DoClick()
        OnePrint:SetTab( dBase, 0 )
    end

    local dHack = vgui.Create( "DButton", dBase.ActiveTab )
    dHack:SetSize( ( dBase:GetTall() * .5 ), ( dBase:GetTall() * .5 ) )
    dHack:SetPos( ( dBase:GetWide() * .5 ) - ( dHack:GetWide() * .5 ), ( dBase:GetTall() * .5 ) - ( dHack:GetTall() * .5 ) )
    dHack:SetText( string.upper( OnePrint:L( "Hack" ) ) )
    dHack:SetFont( "OnePrint.1" )
    dHack:SetTextInset( 0, 4 )
    dHack:SetTextColor( OnePrint:C( 5 ) )

    function dHack:Start()
        self.iStep = 0
        self.iMaxSteps = ( dBase.eEntity:GetSecurity() + 1 )
        self.iCur = 0
        self.bRight = true
        self.iGoal = math.random( ( 8 + OnePrint.Cfg.HackingErrorMargin ), ( 352 - OnePrint.Cfg.HackingErrorMargin ) )
        self.iSpeed = math.random( OnePrint.Cfg.HackingSpeedMin, OnePrint.Cfg.HackingSpeedMax )
        self.fLerpSpeed = 0
        self.bStarted = true

        self:SetText( math.Round( self.iStep * 100 / self.iMaxSteps ) .. "%" )
    end

    function dHack:Stop()
        self:SetDisabled( true )
        self.bStarted = nil 
        
        if self.bSuccess then
            self:SetText( string.upper( OnePrint:L( "Success" ) ) .. " !" )
            self.tColor = OnePrint:C( 3 )
        else
            self:SetText( string.upper( OnePrint:L( "Fail" ) ) )
            self.tColor = OnePrint:C( 4 )
        end

        self:SetTextColor( self.tColor )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

        timer.Simple( 1, function()
            if not dHack or not IsValid( dHack ) then
                return
            end

            if IsValid( self ) and self.bSuccess then
                if dBase and dBase.eEntity then
                    OnePrint:SetTab( dBase, dBase.eEntity:GetCurrentTab() )
                end
            else
                if dBase and IsValid( dBase ) then
                    OnePrint:SetTab( dBase, 0 )
                end
            end
        end )
    end

    function dHack:Verify()
        if self.bValid then
            self.iStep = ( self.iStep + 1 )

            if ( self.iStep >= self.iMaxSteps ) then
                net.Start( "OnePrintNW" )
                    net.WriteUInt( 8, 4 )
                    net.WriteEntity( dBase.eEntity )
                net.SendToServer()

                self.bSuccess = true
                self:Stop()

                return
            end

            self:SetText( math.Round( self.iStep * 100 / self.iMaxSteps ) .. "%" )

            self.bRight = not self.bRight
            self.iSpeed = math.random( OnePrint.Cfg.HackingSpeedMin, OnePrint.Cfg.HackingSpeedMax )
            self.iGoal = math.random( ( 8 + OnePrint.Cfg.HackingErrorMargin ), ( 352 - OnePrint.Cfg.HackingErrorMargin ) )
        else
            self:Stop()
        end
    end

    function dHack:DoClick()
        local iTime = ( self.fNextOccur or 0 ) - CurTime()
        if ( iTime < 0 ) then
            if not self.bStarted then
                self:Start()
                return
            end

            self:Verify()
            self.fNextOccur = ( CurTime() + .2 )
        end
    end

    function dHack:Think()
        if not self.bStarted then
            return
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        if self.bRight then
            self.iCur = ( self.iCur + self.iSpeed )
            if ( self.iCur > 360 ) then
                self.iCur = 0
            end
        else
            self.iCur = ( self.iCur - self.iSpeed )
            if ( self.iCur < 0 ) then
                self.iCur = 360
            end
        end

        local iMin, iMax = math.min( self.iCur, self.iGoal ), math.max( self.iCur, self.iGoal )
        if ( ( iMax - iMin ) < ( 16 + OnePrint.Cfg.HackingErrorMargin ) ) then
            self.bValid = true
        else
            self.bValid = nil
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

    dHack.fLerpH = 0
    dHack.fLerpHTo = ( dHack:GetTall() * .75 )

    dHack.fLerpProgress = 0
    dHack.tColor = OnePrint:C( 2 )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- bff8dd755dec0cda0569e2c732230354a5153d153214953e6ab76f0272049b75

    local iDelay = .16
    local iLastOccur = -iDelay
    local sPassword = randomString( 24 )

    function dHack:Paint( iW, iH )
        self.fLerpH = Lerp( RealFrameTime() * 6, self.fLerpH, self.fLerpHTo )

        local tColor = ( self.bValid and OnePrint:C( 6 ) or self.tColor )

        if self.iStep and self.iMaxSteps then
            self.fLerpProgress = Lerp( RealFrameTime() * 6, self.fLerpProgress, ( self.iStep * self.fLerpH ) / self.iMaxSteps )
        end

        if ( self.fLerpProgress > 0 ) then
            surface.SetDrawColor( OnePrint:C( 1 ) )
            surface.SetMaterial( matCircle2 )
            surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), self.fLerpProgress, self.fLerpProgress, 0 )
        end

        surface.SetDrawColor( tColor )
        surface.SetMaterial( matCircle )
        surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), self.fLerpH, self.fLerpH, ( CurTime() * 10 ) % 360 )

        if self.bStarted then
            surface.SetDrawColor( tColor )
            surface.SetMaterial( matTarget )
            surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), self.fLerpH, self.fLerpH, self.iGoal )

            surface.SetDrawColor( tColor )
            surface.SetMaterial( matPoint )
            surface.DrawTexturedRectRotated( ( iW * .5 ), ( iH * .5 ), self.fLerpH, self.fLerpH, self.iCur )

            if self.Hovered then
            	if ( ( CurTime() - iLastOccur ) > iDelay ) then
                    sPassword = randomString( math.random( 32, 48 ) )
                    iLastOccur = CurTime()
                end

                draw.SimpleText( sPassword, "OnePrint.4", ( iW * .5 ), ( - 100 ), OnePrint:C( 2 ), 1, 1 )

                draw.SimpleText( string.upper( OnePrint:L( "Step" ) ) .. " " ..( self.iStep + 1 ) .. "/" .. self.iMaxSteps, "OnePrint.5", ( iW * .5 ), ( iH + 100 ), OnePrint:C( 2 ), 1, 1 )
            end
        end
    end

    function dHack:OnCursorEntered()
        if self:GetDisabled() then
            return
        end

        self.tColor = OnePrint:C( 5 )
        self:SetTextColor( self.tColor )
        self:SetFont( "OnePrint.1" )

        self.fLerpHTo = self:GetTall()
    end

    function dHack:OnCursorExited()
        if self:GetDisabled() then
            return
        end

        self.tColor = OnePrint:C( 2 )
        self:SetTextColor( self.tColor )
        self:SetFont( "OnePrint.5" )

        self.fLerpHTo = ( self:GetTall() * .75 )
    end
end

OnePrint:RegisterTab( Hack )
