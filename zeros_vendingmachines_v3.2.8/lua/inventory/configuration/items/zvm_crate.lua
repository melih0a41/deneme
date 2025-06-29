/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_vendingmachine/zvm_package.mdl")
//ITEM:SetDescription("Holds Items from a Vendingmachine.")

ITEM:SetDescription(function(self, tbl)
	local data = tbl.data
	local _content = data.Content
	local desc = ""
	for k, v in pairs(_content) do
		desc = desc .. v.name .. ", "
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

	return  desc
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	zvm.Player.AddPackage(ply,ent)

	ent.Content = {}
	table.CopyFromTo(data.Content, ent.Content)
	zclib.Player.SetOwner(ent, ply)
end)

function ITEM:GetData(ent)
	return {
		Content = ent.Content,
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	return "Vendingmachine Package"
end

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end

ITEM:Register("zvm_crate")
