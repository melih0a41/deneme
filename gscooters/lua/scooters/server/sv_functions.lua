local sMap = string.lower(game.GetMap())

if not (file.Exists("gscooters/", "DATA")) then file.CreateDir("gscooters/") end
if not (file.Exists("gscooters/maps", "DATA")) then file.CreateDir("gscooters/maps", "DATA") end

local tVehicleTable = list.Get("Vehicles")[gScooters.ScooterClass]

function gScooters:CreateScooter(vPos, aAngle)    
    local eScooter = ents.Create("prop_vehicle_jeep")
    if not IsValid(eScooter) then return end

    eScooter:SetModel(tVehicleTable.Model)
	

    eScooter:SetVehicleClass(gScooters.ScooterClass)
    for iK, iKV in pairs(tVehicleTable.KeyValues) do
        eScooter:SetKeyValue(iK, iKV)
    end

    eScooter:SetPos(vPos)
    eScooter:SetAngles(aAngle)
	eScooter.GC_OriginalSpawnPos = vPos
    eScooter.GC_OriginalSpawnAng = aAngle
    eScooter:Spawn()
    eScooter:Activate()

    eScooter.OriginalPos = vPos
    eScooter.OriginalAngle = aAngle

    local tParams = eScooter:GetVehicleParams()
    tParams.engine.horsepower = tParams.engine.horsepower + (gScooters.Config.Scooter and gScooters.Config.Scooter.AddedPower or 0)
    eScooter:SetVehicleParams(tParams)
     
    if VC and not SVMOD then
        eScooter:VC_fuelSetMax(eScooter, 500)
    end

    if gScooters.Config.UIisEnabled then
        timer.Simple(2, function()
            if IsValid(eScooter) then
                -- eScooter:GetPhysicsObject():EnableMotion(false)
            end
        end)
    end
    
    return eScooter
end


hook.Add("OnEntityCreated", "gScooters.Hook.ScooterCreated", function(eEnt)
    timer.Simple(0, function()
        if IsValid(eEnt) and eEnt:IsVehicle() and eEnt:GetModel() == tVehicleTable.Model then
            if DarkRP then
                eEnt:setKeysNonOwnable(true)
            end
        
            eEnt.gScooter = gScooters.Config.UIisEnabled -- This prevents people from accessing UI
            eEnt.GC_Enterable = false

            if VC and not SVMOD then
                eEnt:VC_setHornCustom("")
            end
        end
    end)
end)

function gScooters:ChatMessage(sMessage, pPlayer)
    net.Start("gScooters.Net.ChatMessage")
    net.WriteString(sMessage)
    net.Send(pPlayer)
end

gScooters.PlayerBlacklists = {}

function gScooters:BillPlayer(pPlayer, iTime)
    local iPrice = math.Round((iTime/60)*gScooters.Config.RentalRate, 2) 

    if gScooters:CanAfford(pPlayer, iPrice) then
        gScooters:ChatMessage(string.format(gScooters:GetPhrase("charge"), gScooters:FormatMoney(iPrice)), pPlayer)

        gScooters:ModifyMoney(pPlayer, -1 * iPrice)
    else
        gScooters:ModifyMoney(pPlayer, -1 * gScooters:GetMoney(pPlayer))

        gScooters:ChatMessage(gScooters:GetPhrase("blacklist"), pPlayer)

        gScooters.PlayerBlacklists[pPlayer:SteamID64()] = CurTime()
    end
end