/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/*
	Remove the entity tablet before adding the TFA gun
*/
hook.Add("zvm_PreCreateProduct","zvm_PreCreateProduct_FixTFA",function(ItemData)
	if string.sub(ItemData.class,1,4) == "tfa_" then
		ItemData.entdata = nil
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

/*
	Remove the entity table before spawning the TFA gun
*/
hook.Add("zvm_SkipEntityTableOnSpawn","zvm_SkipEntityTableOnSpawn_FixTFA",function(ItemData)
	if string.sub(ItemData.class,1,4) == "tfa_" then
		return true
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
