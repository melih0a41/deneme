function gScooters:CanAfford(pPlayer, iPrice)
    return pPlayer:canAfford(iPrice)
end

function gScooters:ModifyMoney(pPlayer, iAmount)
    return pPlayer:addMoney(iAmount)
end

function gScooters:GetMoney(pPlayer)
    return pPlayer:getDarkRPVar("money")
end

function gScooters:SetVehicleOwner(eVehicle, pPlayer)
    eVehicle:keysOwn(pPlayer)
end

function gScooters:LockVehicle(eVehicle)
    eVehicle:keysLock()
end



