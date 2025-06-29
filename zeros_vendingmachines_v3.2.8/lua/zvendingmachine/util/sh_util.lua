/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.util = zvm.util or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zvm.Print(msg)
	print("[Zeros Vendingmachine] " .. msg)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

function zvm.Warning(ply,msg)
	if CLIENT then
		notification.AddLegacy(msg, NOTIFY_ERROR, 2)
		surface.PlaySound("buttons/combine_button_locked.wav")
	else
		zclib.Notify(ply,msg, 1)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

// Returns the value of the first valid key which is found in the table, returns default otherwhise
function zvm.util.GetFirstValidRank(ply,_table,default)
	local val
	if xAdmin then
		for k, v in pairs(_table) do
			if ply:IsUserGroup(k) then
				val = v
				break
			end
		end
	else
		val = _table[zclib.Player.GetRank(ply)]
	end

	if val == nil then val = default end
	return val
end

/*
	Precaches any of the model replacements
*/
if SERVER then
	timer.Simple(2, function()
		for k, v in pairs(zvm.config.PredefinedModels) do
			if v then
				util.PrecacheModel(v)
			end
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff
