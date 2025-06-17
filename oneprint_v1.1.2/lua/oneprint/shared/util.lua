/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

--[[

    OnePrint:L

]]--

function OnePrint:L( sLangString )
    return OnePrint.Lang[ sLangString ]
end

--[[
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

    OnePrint:C
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

]]--

function OnePrint:C( iColorIndex )
    return OnePrint.Cfg.Colors[ iColorIndex ]
end

--[[

    OnePrint:FormatMoney
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67

]]--

local tMoneyFormatting = {
    [ "DarkRP" ] = function( iMoney )
        return DarkRP.formatMoney( iMoney )
    end,
    [ "Nutscript" ] = function( iMoney )
        local sMoney = nut.currency.get( iMoney )
        local tSplit = string.Split( sMoney, " " )

        return tSplit[ 1 ] or sMoney
    end,
    [ "Helix" ] = function( iMoney )
        return ix.currency.Get( iMoney )
    end
}

function OnePrint:FormatMoney( iMoney )
    if DarkRP then
        return tMoneyFormatting[ "DarkRP" ]( iMoney )
    end

    if ( nut and nut.currency ) then
        return tMoneyFormatting[ "Nutscript" ]( iMoney )
    end

    if ( ix and ix.currency ) then
        return tMoneyFormatting[ "Helix" ]( iMoney )
    end

    return ( "$" .. string.Comma( iMoney ) )
end
