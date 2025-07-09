/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}
zmlab2.MiniGame.List = zmlab2.MiniGame.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

/*
	Registers a new minigame
*/
function zmlab2.MiniGame.Register(id,data)
	data.GameID = id
	zmlab2.MiniGame.List[id] = data
end

function zmlab2.MiniGame.GetPenalty(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Penalty)
end

function zmlab2.MiniGame.GetReward(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Reward)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf
