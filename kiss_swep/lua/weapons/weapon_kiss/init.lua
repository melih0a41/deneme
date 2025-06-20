AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "positions.lua" )
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.HoldType = "magic"
local KissLength = SWEP.KissLength
local SoundDelay = math.random( 0.5, 2 )
local saydirlove = 0
local saydirlove2 = 0
local sounds = {
"kiss/1.mp3",
"kiss/2.mp3",
"kiss/3.wav",
"kiss/4.wav",
"kiss/5.wav",
"kiss/6.wav",
"kiss/7.wav",
"kiss/8.wav",
"kiss/9.wav",
"kiss/10.wav",
"kiss/11.wav",
"kiss/12.wav",
"kiss/13.wav",
"kiss/14.wav",
"kiss/15.wav",
"kiss/16.wav",
}

local sounds3 = {
	"bot/whoo2.wav",
	"bot/whoo.wav",
	"bot/whoa.wav",
	"bot/oh_my_god.wav",
	"bot/oh_yea.wav",
	"bot/oh_yea2.wav",
	"bot/very_nice.wav",
}

local InProgress = false

concommand.Add( SWEP.PRIMARYPW, function( ply, cmd, args )

	if !ply or !ply:IsValid() then return end

	if not ply:HasWeapon( "weapon_kiss" ) then return end
	InProgress = true

	local plyAttacker = ply
	local plyAttackerPos = plyAttacker:GetPos()
	
	local plyVictim = plyAttacker:GetEyeTrace().Entity
	if !plyVictim or plyVictim == nil or !plyVictim:IsValid() then return end
	local plyVictimPos = plyVictim:GetPos()
	local VictimType = 1
	if plyVictim:IsNPC() then
		VictimType = 2
	elseif plyVictim:GetClass() == "prop_ragdoll" then
		VictimType = 3
	end
	plyAttacker.Kissing = true
	
	plyAttacker:StripWeapons()
	plyAttacker:Spectate( OBS_MODE_CHASE )
	if VictimType == 1 and plyVictim and plyVictim:IsValid() then
		plyVictim:StripWeapons()
		plyVictim:Spectate( OBS_MODE_CHASE )
		plyVictim.Kissing = true
	end
	
	local basepos = plyAttacker:GetPos() + Vector(0,0,20)
	local traceda = {}
	traceda.start = basepos
	traceda.endpos = basepos - Vector(0,0,1000)
	traceda.filter = {plyVictim, plyAttacker}
	local trace = util.TraceLine(traceda)
	basepos = trace.HitPos or basepos

	local ragVictim = NULL
	if VictimType == 3 then
		ragVictim = plyVictim
	else
		ragVictim = ents.Create("prop_ragdoll")
		ragVictim:SetModel( plyVictim:GetModel() )
		ragVictim:SetPos( plyVictimPos )
		ragVictim:Spawn()
		ragVictim:Activate()
	end
	
	ragVictim:SetCollisionGroup(kiss_set_collide)

	local modelbilgisi2 = ragVictim:GetModel()
	local str5 = string.Replace( modelbilgisi2, "/", "." ) 
	local str6 = string.Replace( str5, "_", "." ) 
	str7 = string.Replace( str6, ".", "q" ) 
	
	if (_G[str7]) then
	str7 = _G[str7]
	end
	
	if (_G[str7.."_victimAng"] and _G[str7.."_victimPos"]) then
	else
	str7 = "default"
	end

	local tablosaydir1 = table.Count( _G[str7.."_victimPos"] ) 
	local tablosaydirs1 = table.Count( _G[str7.."_Space"] ) 
	for i = 1, tablosaydir1 do
		local phys = ragVictim:GetPhysicsObjectNum(i)
		if phys and phys:IsValid() then
			phys:EnableCollisions( true )
			phys:EnableMotion( false )
			phys:SetPos( basepos + _G[str7.."_victimPos"][i] )
			phys:SetAngles( _G[str7.."_victimAng"][i] )
			if i==_G[str7.."_Head"] then phys:EnableMotion(true) end
			for is = 1, tablosaydirs1 do
			if i==_G[str7.."_Space"][is] then phys:EnableMotion(true) end
			end
		end
	end
	
	local ragAttacker = ents.Create("prop_ragdoll")
	ragAttacker:SetModel( plyAttacker:GetModel() )
	ragAttacker:SetPos( plyVictimPos )
	ragAttacker:Spawn()
	ragAttacker:Activate()
	ragAttacker:SetCollisionGroup(kiss_set_collide)
	
	local modelbilgisi1 = ragAttacker:GetModel()
	local str2 = string.Replace( modelbilgisi1, "/", "." ) 
	local str3 = string.Replace( str2, "_", "." ) 
	local str4 = string.Replace( str3, ".", "q" ) 
	
	if (_G[str4]) then
	str4 = _G[str4]
	end
	
	if (_G[str4.."_attackerAng"] and _G[str4.."_attackerPos"]) then
	else
	str4 = "default"
	end

	
	local tablosaydir2 = table.Count( _G[str4.."_attackerPos"] ) 
	local tablosaydirs2 = table.Count( _G[str4.."_Space"] ) 
	for i = 1, tablosaydir2 do
		local phys = ragAttacker:GetPhysicsObjectNum(i)
		if phys and phys:IsValid() then
			phys:SetPos( basepos + _G[str4.."_attackerPos"][i] )
			phys:SetAngles( _G[str4.."_attackerAng"][i] )
			phys:EnableCollisions( false )
			phys:EnableMotion( false )
			if i==_G[str4.."_Head"] then phys:EnableMotion(true) end
			for is = 1, tablosaydirs2 do
			if i==_G[str4.."_Space"][is] then phys:EnableMotion(true) end
			end
		end
	end

	plyAttacker:SpectateEntity( ragAttacker )
	if VictimType == 1 then
		plyVictim:SpectateEntity( ragVictim )
	elseif VictimType == 2 then
		plyVictim:SetPos( plyVictimPos + Vector(5000,5000,0) )
	elseif VictimType == 3 then
		
	end
local pozisyon = plyAttacker:GetPos() + _G[str4.."_attackerPos"][_G[str4.."_Head"]] - Vector(5,2,45)
local love = ents.Create( "prop_dynamic" )
love:SetModel( "models/neptunia/effects/raburabu_1.mdl" )
love:SetPos( pozisyon )
love:SetAngles(Angle(90,90,90))
love:Spawn()
util.SpriteTrail( love, 0, Color(255,255,255,255), false, 20, 0, 10, 0.1, "trails/love.vmt" ) 
local pozisyon2 = plyAttacker:GetPos() + _G[str4.."_attackerPos"][_G[str4.."_Head"]] - Vector(5,-7,55)
local love2 = ents.Create( "prop_dynamic" )
love2:SetModel( "models/neptunia/effects/raburabu_2.mdl" )
love2:SetPos( pozisyon2 )
love2:SetAngles(Angle(90,90,90))
love2:SetMaterial("models/effects/vol_light001",false)
love2:Spawn()
util.SpriteTrail( love2, 0, Color(255,255,255,255), false, 20, 0, 10, 0.1, "trails/love.vmt" ) 

	local lovestring = "love"..math.random(1337)
		timer.Create( lovestring, 0.05, 0, function()
		if (saydirlove <= 4) then
		love:SetMaterial("",false)	
		saydirlove = saydirlove + 0.1
		love:SetPos( pozisyon + Vector(0,0,saydirlove) )
		elseif (saydirlove <= 8) then
		love:SetMaterial("models/effects/vol_light001",false)
		love2:SetMaterial("",false)
		saydirlove2 = saydirlove2 + 0.1
		saydirlove = saydirlove + 0.1
		love2:SetPos( pozisyon2 + Vector(0,0,saydirlove2) )
		elseif(saydirlove <= 12) then
		love2:SetMaterial("models/effects/vol_light001",false)
		saydirlove2 = 0
		saydirlove = 0
	end
		end)
		 
	--Baslatan kisinin kafa oynatma sistemi akustik (:
	local thrustTimerString = "KissThrust"..math.random(1337)
	local phys = ragAttacker:GetPhysicsObjectNum( _G[str4.."_Head"] )
	local phys2 = ragAttacker:GetPhysicsObjectNum( _G[str4.."_LeftArm"] )
	local phys3 = ragAttacker:GetPhysicsObjectNum( _G[str4.."_LeftHand"] )
	if phys and phys:IsValid() then
		saydir2 = 1
		saydir1 = 1
		local kafasalla1 = _G[str4.."_attackerAng"][_G[str4.."_Head"]]
		local elsalla1 = _G[str4.."_attackerAng"][_G[str4.."_LeftArm"]]
		timer.Create( thrustTimerString, 0.02, 0, function()
			phys:EnableMotion( true )
			phys:EnableCollisions( true )
			phys2:EnableMotion( true )
			phys2:EnableCollisions( true )
			phys3:EnableMotion( true )
			phys3:EnableCollisions( true )
			if (saydir2 >= 10) then
			saydir1 = 2
			saydir2 = 1
			elseif (saydir2 >= 4) then
			phys:SetAngles( Angle(kafasalla1.p + saydir1 , kafasalla1.y - saydir1, kafasalla1.r - saydir1))
			phys2:SetAngles( Angle(elsalla1.p + saydir1 , elsalla1.y, elsalla1.r - saydir1))
			saydir1 = saydir1 - 1 /7
			saydir2 = saydir2 + 1 /7
			else
			phys:SetAngles( Angle(kafasalla1.p + saydir1 , kafasalla1.y - saydir1, kafasalla1.r - saydir1))
			phys2:SetAngles( Angle(elsalla1.p + saydir1 , elsalla1.y, elsalla1.r - saydir1))
			saydir1 = saydir1 + 1 /7
			saydir2 = saydir2 + 1 /7
			end
			phys:EnableMotion( false )
			phys2:EnableMotion( false )
			phys3:EnableMotion( false )
		end )
	end 
	  
		--Buda karsi tarafin kafa oynatma sistemi..
		local thrustTimerString2 = "Kiss2Thrust"..math.random(1337)
	local physs = ragVictim:GetPhysicsObjectNum( _G[str7.."_Head"]  )
		local physs2 = ragVictim:GetPhysicsObjectNum( _G[str7.."_LeftArm"] )
	local physs3 = ragVictim:GetPhysicsObjectNum( _G[str7.."_LeftHand"] )
	if physs and physs:IsValid() then
		saydir3 = 1
		saydir4 = 1
		local kafasalla2 = _G[str7.."_victimAng"][_G[str7.."_Head"]]
		local elsalla2 = _G[str7.."_victimAng"][_G[str7.."_LeftArm"]]
		timer.Create( thrustTimerString2, 0.02, 0, function()
		physs:EnableMotion( true )
		physs:EnableCollisions( true )
			physs2:EnableMotion( true )
			physs2:EnableCollisions( true )
			physs3:EnableMotion( true )
			physs3:EnableCollisions( true )
			if (saydir4 >= 14) then
			saydir4 = 2
			saydir3 = 1 
			elseif (saydir4 >= 7) then
			physs:SetAngles( Angle(kafasalla2.p + saydir3 , kafasalla2.y - saydir3, kafasalla2.r - saydir3))
			physs2:SetAngles( Angle(elsalla2.p + saydir3 , elsalla2.y, elsalla2.r - saydir3))
			saydir3 = saydir3 - 1 /7
			saydir4 = saydir4 + 1 /7
			else
			physs:SetAngles( Angle(kafasalla2.p + saydir3 , kafasalla2.y - saydir3, kafasalla2.r - saydir3))
			physs2:SetAngles( Angle(elsalla2.p + saydir3 , elsalla2.y, elsalla2.r - saydir3))
			saydir3 = saydir3 + 1 /7
			saydir4 = saydir4 + 1 /7
			end
			physs:EnableMotion( false )
			physs:EnableMotion( false )
			physs2:EnableMotion( false )
			physs3:EnableMotion( false )
			
		end )
	end
	
		--Donma sorunu için yapıldı.
		local thrustTimerString3 = "Kiss3Thrust"..math.random(1337)
		timer.Create( thrustTimerString3, 0.1, 0, function()
			ragAttacker:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ragVictim:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ragVictim:SetCollisionGroup(COLLISION_GROUP_NONE)
			ragAttacker:SetCollisionGroup(COLLISION_GROUP_NONE)
		end )

	
	
	
	local soundTimerString = "EmitKissSounds"..math.random(1337)
	timer.Create( soundTimerString, SoundDelay, 0, function()
		ragVictim:EmitSound( sounds[math.random(#sounds)] )
	end )
	
	timer.Simple( KissLength, function()
	
		if plyAttacker and plyAttacker:IsValid() then
			plyAttacker:UnSpectate()
			plyAttacker:Spawn()
			plyAttacker:SetPos( plyAttackerPos )
			plyAttacker.Kissing = false
			timer.Simple( 0.1, function() plyAttacker:Give( "weapon_kiss" ) end )
		end
		if plyVictim and plyVictim:IsValid() then
			if VictimType == 1 then
				plyVictim:UnSpectate()
				plyVictim:Spawn()
				plyVictim:SetPos( plyVictimPos )
				plyVictim.Kissing = false
			elseif VictimType == 2 then
				plyVictim:SetPos( plyVictimPos )
			elseif VictimType == 3 then
				for i = 1, tablosaydir1 do
					local phys = ragVictim:GetPhysicsObjectNum(i)
					if phys and phys:IsValid() then
						phys:EnableMotion( true )
					end
				end
			end
		end
		
		ragAttacker:EmitSound( sounds3[math.random(#sounds3)] )
		ragVictim:SetCollisionGroup(COLLISION_GROUP_NONE)
		ragAttacker:SetCollisionGroup(COLLISION_GROUP_NONE)
		SafeRemoveEntity( ragAttacker )
		if VictimType != 3 then SafeRemoveEntity( ragVictim ) end
		ragVictim:EmitSound("bot/null.wav")
		timer.Destroy( soundTimerString )
		timer.Destroy( thrustTimerString )
		timer.Destroy( thrustTimerString2 )
		timer.Destroy( thrustTimerString3 )
		timer.Destroy( lovestring )
		love:Remove()
		love2:Remove()
	
	end )

end )
hook.Add( "CanPlayerSuicide", "KISSSWEP.CanPlayerSuicide", function( ply )
	if ply.Kissing then
		return false
	end
end )
