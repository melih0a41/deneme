/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

local mPlayer = FindMetaTable( "Player" )

--[[

    mPlayer:OP_CanAfford
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

]]--

function mPlayer:OP_CanAfford(iPrice)
    return (self:OP_GetMoney() >= iPrice)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

--[[

    mPlayer:OP_GetMoney

]]--

local tWallet = {
    [ "DarkRP" ] = function( pPlayer )
        return ( pPlayer:getDarkRPVar( "money" ) or 0 )
    end,
    [ "Nutscript" ] = function( pPlayer )
        return ( pPlayer:getChar():getMoney() or 0 )
    end,
    [ "Helix" ] = function( pPlayer )
        return ( pPlayer:GetCharacter():GetMoney() or 0 )
    end
}

function mPlayer:OP_GetMoney()
    if DarkRP then
        return tWallet[ "DarkRP" ]( self )
    elseif nut then
        return tWallet[ "Nutscript" ]( self )
    elseif ( ix and ix.currency ) then
        return tWallet[ "Helix" ]( self )
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    return 0
end

--[[

    mPlayer:OP_IsHaxor
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function mPlayer:OP_IsHaxor()
    if not OnePrint.Cfg.HackingEnabled then
        return false
    end

    if not OnePrint.Cfg.HackingJobs or ( istable( OnePrint.Cfg.HackingJobs ) and table.IsEmpty( OnePrint.Cfg.HackingJobs ) ) then
        return true
    end

    return OnePrint.Cfg.HackingJobs[ team.GetName( self:Team() ) ]
end
