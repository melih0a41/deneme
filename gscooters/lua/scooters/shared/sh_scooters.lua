gScooters.ScooterClass = "gscooter_electric"

gScooters.Bones = {
    ["ValveBiped.Bip01_Pelvis"] = Angle(0, 0, 10),
    ["ValveBiped.Bip01_Spine1"] = Angle(0, 10, 0),
    ["ValveBiped.Bip01_L_Thigh"] = Angle(-12, 70, 0),
    ["ValveBiped.Bip01_R_Thigh"] = Angle(15, 95, 0),
    ["ValveBiped.Bip01_L_Calf"] = Angle(0, -35, -10),
    ["ValveBiped.Bip01_R_Calf"] = Angle(0, -50, -10),
    ["ValveBiped.Bip01_L_Foot"] = Angle(0, 10, 0),
    ["ValveBiped.Bip01_R_Foot"] = Angle(25, -10, 0),
    ["ValveBiped.Bip01_L_UpperArm"] = Angle(0, 20, 0),
    ["ValveBiped.Bip01_R_UpperArm"] = Angle(0, 25, 0),
    ["ValveBiped.Bip01_L_Forearm"] = Angle(0, -50, 25),
    ["ValveBiped.Bip01_R_Forearm"] = Angle(0, -50, -25),
    ["ValveBiped.Bip01_L_Hand"] = Angle(20, 0, 35),
    ["ValveBiped.Bip01_R_Hand"] = Angle(20, 0, -25)
}

local tScooter = {
	Name =	"gScooter Electric",
	Class = "prop_vehicle_jeep",
	Category = "gScooters",

	Author = "ItzDannio25",
	Information = "",
	Model =	"models/dannio/gscooters.mdl",

	KeyValues = {				
		vehiclescript =	"scripts/vehicles/dannio/gscooters.txt"
	}
}

list.Set("Vehicles", gScooters.ScooterClass, tScooter)

function gScooters:GetPhrase(sPhrase)
    return gScooters.Language[sPhrase] or "Language Error!"
end

local function GC_AttachCurrency(str) -- Completely taken from the DarkRP team                          ad5bc2e066fcd4695f5419fe126f29017883f120d6f9ddaf626e263b05ab77bf
    gScooters.Config.CurrencyOnLeft = gScooters.Config.CurrencyOnLeft or true
    gScooters.Config.CurrencySymbol = gScooters.Config.CurrencySymbol or "₺"

    return gScooters.Config.CurrencyOnLeft and gScooters.Config.CurrencySymbol .. str or str .. gScooters.Config.CurrencySymbol
end

function gScooters:FormatMoney(n, alwaysdecimal)
    if not isnumber(n) then return "nil" end

    if alwaysdecimal then
        n = math.Round(n)
    end

    if not n then return GC_AttachCurrency("0") end

    if n >= 1e14 then return GC_AttachCurrency(tostring(n)) end
    if n <= -1e14 then return "-" .. GC_AttachCurrency(tostring(math.abs(n))) end

    local negative = n < 0

    n = tostring(math.abs(n))
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n + 1

    for i = dp - 4, 1, -3 do
        n = n:sub(1, i) .. sep .. n:sub(i + 1)
    end

    return (negative and "-" or "") .. GC_AttachCurrency(n)
end

GC_RACK = 1
GC_NPC = 2
