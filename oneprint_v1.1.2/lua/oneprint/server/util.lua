/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

--[[

	OnePrint:Notify

]]--

local tNotify = {
    [ "DarkRP" ] = function( pPlayer, sNotify, iType, iTime )
       	DarkRP.notify( pPlayer, ( iType or 0 ), ( iTime or 1 ), sNotify )
    end,
    [ "Nutscript" ] = function( pPlayer, sNotify, iType, iTime )
		nut.util.notify( sNotify, pPlayer )
    end,
    [ "Helix" ] = function( pPlayer, sNotify, iType, iTime )
		pPlayer:Notify( sNotify )
    end
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

function OnePrint:Notify( pPlayer, sNotify, iType, iTime )
	if DarkRP then
        return tNotify[ "DarkRP" ]( pPlayer, sNotify, iType, iTime )
    elseif nut then
        return tAddMoney[ "Nutscript" ]( pPlayer, sNotify, iType, iTime )
    elseif ( ix and ix.currency ) then
        return tAddMoney[ "Helix" ]( pPlayer, sNotify, iType, iTime )
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- bff8dd755dec0cda0569e2c732230354a5153d153214953e6ab76f0272049b75
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

	pPlayer:ChatPrint( sNotify )
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

--[[

	OnePrint:AddMoney

]]--

local tAddMoney = {
    [ "DarkRP" ] = function( pPlayer, iMoney )
       	pPlayer:addMoney( iMoney )
    end,
    [ "Nutscript" ] = function( pPlayer, iMoney )
        pPlayer:getChar():giveMoney( iMoney )
    end,
    [ "Helix" ] = function( pPlayer, iMoney )
        local iWallet = ( pPlayer:GetCharacter():GetMoney() or 0 )
		pPlayer:GetCharacter():SetMoney( iWallet + iMoney )
    end
}

function OnePrint:AddMoney( pPlayer, iMoney )
	if DarkRP then
        return tAddMoney[ "DarkRP" ]( pPlayer, iMoney )
    elseif nut then
        return tAddMoney[ "Nutscript" ]( pPlayer, iMoney )
    elseif ( ix and ix.currency ) then
        return tAddMoney[ "Helix" ]( pPlayer, iMoney )
	end
end
