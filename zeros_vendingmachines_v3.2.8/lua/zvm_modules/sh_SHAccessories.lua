/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//SHAccessories

zvm.Definition.Add("sh_accessory", {
	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if IsValid(ply) then
			zvm.SHAccessories.GiveItem(ply, itemdata.extraData.itemid)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

		return true
	end,
	BlockItem = function(ply, Machine, itemdata, ItemID)
		local c_ProductAmount = Machine.BuyList[ ItemID ] or 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff
		
		if c_ProductAmount == 1 then
			zvm.Warning(ply, zvm.language.General[ "BuyLimitReached" ])

			return true
		end
	end
})

if CLIENT then return end
zvm = zvm or {}
zvm.SHAccessories = zvm.SHAccessories or {}

zclib.Hook.Add("PlayerSay", "zvm_PlayerSay_shaccessories", function(ply, text)

    // Adds SH Accessories Item to Vendingmachine
    if string.sub(string.lower(text), 1, 23) == "!zvm_shaccessories_add_" then
        local text_tbl = string.Split( text, "_" )
        local itemid = text_tbl[4]

        zvm.SHAccessories.AddItem(ply,itemid)
    end
end)

function zvm.SHAccessories.AddItem(ply, hatid)

    if zclib.Player.IsAdmin(ply) == false then
        zclib.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        return
    end

    local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

    if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zvm_machine" then

        local Machine = tr.Entity

        if Machine:GetPublicMachine() == false then return end
        if zvm.Machine.ReachedItemLimit(Machine) then return end
        if Machine:GetAllowCollisionInput() == false then return end

        local acc = SH_ACC:GetAccessory(hatid)
        table.insert(Machine.Products,{
            class = "sh_accessory",
            name = acc.name,
            price = 500,
            model = acc.mdl,
            extraData = {itemid = acc.id},
            entData = {},
            amount = 1,
        })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        // Updates the machine interface for the user which is editing it
        zvm.Machine.UpdateMachineData(Machine,ply)
    end
end

function zvm.SHAccessories.GiveItem(ply, hatid)

    if not IsValid(ply) then return end

    local acc = SH_ACC:GetAccessory(hatid)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

    if not acc then
        return
    end

    if ply:SH_HasAccessory(hatid) then
        print("Zeros Vendingmachine Package: " .. ply:Nick() .. " <" .. ply:SteamID() .. "> already has '" .. hatid .. "' accessory!")
        return
    end

    if ply:SH_AddAccessory(hatid) then
        print("Zeros Vendingmachine Package: " .. "Successfully given " .. ply:Nick() .. " <" .. ply:SteamID() .. "> the '" .. hatid .. "' accessory!")
    else
        print("Zeros Vendingmachine Package: " .. "Failed to give " .. ply:Nick() .. " <" .. ply:SteamID() .. "> the '" .. hatid .. "' accessory!")
    end
end
