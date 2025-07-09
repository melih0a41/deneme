/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}

function zmlab2.MiniGame.StartRandom(Machine)

	local GameIDs = {}
	for k,v in pairs(zmlab2.MiniGame.List) do
		if v.IgnoreRandom then continue end
		table.insert(GameIDs,k)
	end

    zmlab2.MiniGame.Start(Machine,GameIDs[math.random(#GameIDs)])
end

util.AddNetworkString("zmlab2.MiniGame.GameID")
function zmlab2.MiniGame.Start(Machine,GameID)
    zclib.Debug("zmlab2.MiniGame.Start")

    zclib.Sound.EmitFromEntity("error", Machine)

	Machine.GameID = GameID

	// Send net message to tell nearby clients about the GameID
	net.Start("zmlab2.MiniGame.GameID")
        net.WriteEntity(Machine)
        net.WriteString(GameID)
	net.Broadcast()

    Machine.MiniGame_InitialTime = CurTime()

    // Create fail timer
    zmlab2.MiniGame.FailTimer(Machine)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

// Creates a timer after which the mini game is failed
function zmlab2.MiniGame.FailTimer(Machine)
    zclib.Debug("zmlab2.MiniGame.FailTimer")

	// If someone already responded to the mini game then stop
    if IsValid(Machine.MiniGame_Responder) then return end

	// If the error doesent get adressed till this time then the machine gonna start burning
    Machine:SetErrorStart(CurTime())

    local GAME = zmlab2.MiniGame.List[Machine.GameID]
	if GAME.SkipFailTimer then return end

    local timerid = "zmlab2_MiniGame_" .. Machine:EntIndex()
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid, zmlab2.config.MiniGame.RespondTime, 1,function()
        if IsValid(Machine) then

            GAME:OnFinish(Machine, Machine.MiniGame_Responder, false)
            zmlab2.MiniGame.Result(Machine,false)
        end
    end)
end

util.AddNetworkString("zmlab2_MiniGame")

function zmlab2.MiniGame.Respond(Machine, ply)
    zclib.Debug("zmlab2.MiniGame.Respond")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

    // If someone already responded to the mini game then stop
    if IsValid(Machine.MiniGame_Responder) then return end

    // Restart fail timer
    zmlab2.MiniGame.FailTimer(Machine)

    Machine.MiniGame_Responder = ply
	ply.zmlab2_ResponseStart = CurTime()

	zmlab2.MiniGame.List[Machine.GameID]:OnStart(Machine,ply)

    net.Start("zmlab2_MiniGame")
	net.WriteString(Machine.GameID)
    net.WriteEntity(Machine)
    net.Send(ply)
end

net.Receive("zmlab2_MiniGame", function(len, ply)
    zclib.Debug_Net("zmlab2_MiniGame", len)
    if zclib.Player.Timeout(nil,ply) == true then return end

	local GameID = net.ReadString()
    local Machine = net.ReadEntity()
    local Result = net.ReadBool()
    if not IsValid(Machine) then return end

    if zmlab2.Player.CanInteract(ply, Machine) == false then return end
    if zclib.util.InDistance(ply:GetPos(), Machine:GetPos(), 1000) == false then return end

    if ply ~= Machine.MiniGame_Responder then return end

	if ply.zmlab2_ResponseStart then
		local ResponseTime =  CurTime() - ply.zmlab2_ResponseStart
		if ResponseTime < 1 && GameId != "quicktime" && GameId != "hoseon" then
			-- print()
			-- MsgC(Color(55, 128, 218), "[Zero´s Methlab 2]   -> ", Color(255, 255, 255), "MiniGame response time less then 1 second, potential ",Color(255,0,0),"Cheater",Color(255,255,255),"???\n")
			-- MsgC(Color(55, 128, 218), "   Entity            -> ", Color(255, 255, 255), tostring(Machine) .. "\n")
			-- MsgC(Color(55, 128, 218), "   Player            -> ", Color(255, 255, 255), tostring(ply) .. "\n")
			-- MsgC(Color(55, 128, 218), "   SteamID           -> ", Color(255, 255, 255), tostring(ply:SteamID()) .. "\n")
			-- MsgC(Color(55, 128, 218), "   SteamID64         -> ", Color(255, 255, 255), tostring(ply:SteamID64()) .. "\n")
			-- MsgC(Color(55, 128, 218), "   Response Time     -> ", Color(255, 255, 255), tostring(ResponseTime) .. "\n")
			-- MsgC(Color(55, 128, 218), "   Response Started  -> ", Color(255, 255, 255), tostring(ply.zmlab2_ResponseStart) .. "\n")
			-- MsgC(Color(55, 128, 218), "   Response Received -> ", Color(255, 255, 255), tostring(CurTime()) .. "\n")
			-- print()
		end
	end

	zmlab2.MiniGame.List[ GameID ]:OnFinish(Machine, ply, Result)

    zmlab2.MiniGame.Result(Machine,Result)
end)

function zmlab2.MiniGame.Result(Machine,Result)
    zclib.Debug("zmlab2.MiniGame.Result: " .. tostring(Result))

	// Kill the automatic fail timer since we got a result
    zclib.Timer.Remove("zmlab2_MiniGame_" .. Machine:EntIndex())

    if Result then
        zmlab2.MiniGame.Reward(Machine)
    else
        zmlab2.MiniGame.Punishment(Machine,Machine:GetMethType())
    end

    // If the machine got a process start var then offset it by the time that passe
    if Machine.SetProcessStart and Machine.MiniGame_InitialTime then
        local passed = math.Clamp(CurTime() - Machine.MiniGame_InitialTime,0,1000)
        Machine:SetProcessStart(math.Round(Machine:GetProcessStart() + passed))
    end

    hook.Run("zmlab2_MiniGame.Result", Machine, Result)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    zmlab2.MiniGame.Reset(Machine)

    Machine:OnMiniGameComplete(Result)
end

function zmlab2.MiniGame.Reset(Machine)
    zclib.Debug("zmlab2.MiniGame.Reset")
	Machine.GameID = nil
    Machine.MiniGame_Responder = nil
    Machine:SetErrorStart(-1)
end

function zmlab2.MiniGame.Reward(Machine)
    zclib.Sound.EmitFromEntity("lox_loaded", Machine)

    // Increase the quality
    local qual = math.Clamp(Machine:GetMethQuality() + zmlab2.MiniGame.GetReward(Machine),5,100)
    Machine:SetMethQuality(qual)
end

local function RollDice(chance)
    local pool = {}

    for i = 1, chance do
        table.insert(pool, true)
    end

    for i = 1, 100 - chance do
        table.insert(pool, false)
    end

    pool = zclib.table.randomize(pool)

    return table.Random(pool)
end

// Here we give the machine/player a diffrent punishment depending on Meth Difficulty
function zmlab2.MiniGame.Punishment(Machine, MethType)
    zclib.Sound.EmitFromEntity("minigame_fail", Machine)

    local Difficulty = zmlab2.Meth.GetDifficulty(MethType)

    // Reduce Quality
    local qual = math.Clamp(Machine:GetMethQuality() - zmlab2.MiniGame.GetPenalty(Machine),5,100)
    Machine:SetMethQuality(qual)
    zclib.Debug("QualityUpdate: " .. tostring(qual))

    // Pollute it!
    if Difficulty >= zmlab2.config.MiniGame.Punishment.Pollu_Difficulty and RollDice(zmlab2.config.MiniGame.Punishment.Pollu_Chance) then
        // Create big amount of pollution
        zmlab2.PollutionSystem.AddPollution(Machine:GetPos(),zmlab2.config.MiniGame.Punishment.Pollu_Amount)
        zclib.Sound.EmitFromPosition(Machine:GetPos(), "gas_buff")
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

    // Burn it!
    if Difficulty >= zmlab2.config.MiniGame.Punishment.Fire_Difficulty and RollDice(zmlab2.config.MiniGame.Punishment.Fire_Chance) then
        zclib.Fire.Ignite(Machine,zmlab2.config.MiniGame.Punishment.Fire_Duration,1)
        zmlab2.Damage.InflictBurn(Machine, 10)
    end

    // Explode it!
    if Difficulty >= zmlab2.config.MiniGame.Punishment.Explo_Difficulty and RollDice(zmlab2.config.MiniGame.Punishment.Explo_Chance) then
        zmlab2.Damage.InflictBurn(Machine, 25)

        zclib.Damage.Explosion(Machine,Machine:GetPos(), 150, DMG_BLAST, 15)

        local ed_explo = EffectData()
        ed_explo:SetOrigin( Machine:GetPos() )
        util.Effect( "HelicopterMegaBomb", ed_explo )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        zclib.Sound.EmitFromPosition(Machine:GetPos(),"machine_explode")

        -- Machine:SetNoDraw(true)
        -- SafeRemoveEntityDelayed(Machine,0.1)
        Machine:Remove()
    end
end
