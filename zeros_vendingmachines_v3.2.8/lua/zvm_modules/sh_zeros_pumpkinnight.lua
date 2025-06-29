/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Zeros PumpkinNight
// https://www.gmodstore.com/market/view/6690
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.Definition.Add("zpn_slapper_default", {
	BlockItemCheck = function(other, Machine)
		if other.GotPlace then return true end
	end,
})

zvm.Definition.Add("zpn_slapper_candy", {
	BlockItemCheck = function(other, Machine)
		if other.GotPlace then return true end
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

zvm.Definition.Add("zpn_slapper_fire", {
	BlockItemCheck = function(other, Machine)
		if other.GotPlace then return true end
	end,
})

zclib.Snapshoter.SetPath("zpn_slapper_default", function(ItemData) return "zpn/zpn_slapper_default" end)
zclib.Snapshoter.SetPath("zpn_slapper_candy", function(ItemData) return "zpn/zpn_slapper_candy" end)
zclib.Snapshoter.SetPath("zpn_slapper_fire", function(ItemData) return "zpn/zpn_slapper_fire" end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
