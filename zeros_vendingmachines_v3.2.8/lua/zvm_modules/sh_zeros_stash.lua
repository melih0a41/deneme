/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Zeros Secret Stash
// https://www.gmodstore.com/market/view/717344124917481473
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zvm.AllowedItems.Add("zss_mine") // Has CustomData
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosSecretStash", function(cEnt, ItemData)
	if zss and ItemData.class == "zss_mine" then
		cEnt:SetSkin(1)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
