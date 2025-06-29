/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Jetpack script
//https://steamcommunity.com/sharedfiles/filedetails/?id=931376012&searchtext=jetpack
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zvm.AllowedItems.Add("sent_jetpack") // Has CustomData
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.Definition.Add("sent_jetpack", {
	OnItemDataCatch = function(data, ent)
		data.color = ent:GetColor()
		data.GoneApeshit = ent:GetGoneApeshit()
		data.InfiniteFuel = ent:GetInfiniteFuel()
		data.Fuel = ent:GetFuel()
		data.MaxFuel = ent:GetMaxFuel()
		data.FuelDrain = ent:GetFuelDrain()
		data.FuelRecharge = ent:GetFuelRecharge()
		data.AirResistance = ent:GetAirResistance()
		data.JetpackSpeed = ent:GetJetpackSpeed()
		data.JetpackStrafeSpeed = ent:GetJetpackStrafeSpeed()
		data.JetpackVelocity = ent:GetJetpackVelocity()
		data.JetpackStrafeVelocity = ent:GetJetpackStrafeVelocity()
	end,
	OnItemDataApplyPreSpawn = function(data, ent)
		ent:SetSlotName("sent_jetpack")
	end,
	OnItemDataApply = function(data, ent)
		if data.color then
			ent:SetColor(data.color)
		end

		ent:SetGoneApeshit(data.GoneApeshit)
		ent:SetInfiniteFuel(data.InfiniteFuel)
		ent:SetFuel(data.Fuel)
		ent:SetMaxFuel(data.MaxFuel)
		ent:SetFuelDrain(data.FuelDrain)
		ent:SetFuelRecharge(data.FuelRecharge)
		ent:SetAirResistance(data.AirResistance)
		ent:SetJetpackSpeed(data.JetpackSpeed)
		ent:SetJetpackStrafeSpeed(data.JetpackStrafeSpeed)
		ent:SetJetpackVelocity(data.JetpackVelocity)
		ent:SetJetpackStrafeVelocity(data.JetpackStrafeVelocity)
	end,
	BlockItemCheck = function(other, Machine) return other:GetActive() end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.Snapshoter.SetPath("sent_jetpack",function(ItemData)
    if ItemData.model_color then
        return "jetpack/" .. ItemData.class .. "_" .. ItemData.model_color.r .. "_" .. ItemData.model_color.g .. "_" .. ItemData.model_color.b
    end
end)
