/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ztm = ztm or {}
ztm.Player = ztm.Player or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ztm.Player.IsTrashman(ply)
	if ztm.config.Jobs == nil then return true end
	if table.Count(ztm.config.Jobs) <= 0 then return true end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

	if ztm.config.Jobs[zclib.Player.GetJob(ply)] then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

/*
	Returns the players trash sell multiplicator according to his rank
*/
function ztm.Player.GetTrashSellMultiplicator(ply)
	if not IsValid(ply) then return 1 end
	local rank = zclib.Player.GetRank(ply)
	if not rank then return 1 end

	if ztm.config.MoneyxRank[rank] then
		return ztm.config.MoneyxRank[rank]
	else
		if ztm.config.MoneyxRank["default"] then
			return ztm.config.MoneyxRank["default"]
		else
			return 1
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
