--[[
	Set lockpick time for ATM machine
--]]
function CH_ATM.LockpickTimeATM( ply, ent )
	if ent:GetClass() == "ch_atm" then
		return CH_ATM.Config.HackingTime
	end
end
hook.Add( "lockpickTime", "CH_ATM.LockpickTimeATM", CH_ATM.LockpickTimeATM )

--[[
	Allow lockpick to be used on ATM entity
--]]
function CH_ATM.CanLockpickATM( ply, ent, trace )
	if ent:GetClass() == "ch_atm" then
		-- Check if there are enough players on the server to hack
		if player.GetCount() < CH_ATM.Config.HackingPlayersRequired then
			CH_ATM.NotifyPlayer( ply, CH_ATM.Config.HackingPlayersRequired .." ".. CH_ATM.LangString( "players required to hack ATM's." ) )
			return false
		end
		
		-- Check if there are enough cops on the server
		if CH_ATM.GetAmountOfCops() < CH_ATM.Config.HackingPoliceOfficersRequired then
			CH_ATM.NotifyPlayer( ply, CH_ATM.Config.HackingPoliceOfficersRequired .." ".. CH_ATM.LangString( "police officers required to hack ATM's." ) )
			return false
		end
		
		-- Team restrictions
		if not ply:CH_ATM_CanRobATM() then
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You are not allowed to rob the bank with your current team!" ) )
			return false
		end
		
		-- Cooldown restriction
		if ent:GetIsHackCooldown() then
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You cannot lockpick this ATM at the moment." ) )
			return false
		end
		
		-- Player cooldown
		local cur_time = CurTime()
		
		if ply.CH_ATM_LockpickCooldown and ply.CH_ATM_LockpickCooldown > cur_time then
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Please wait" ) .." ".. string.ToMinutesSeconds( math.Round( ply.CH_ATM_LockpickCooldown - cur_time ) ) .. " ".. CH_ATM.LangString( "before lockpicking another ATM." ) )
			return false
		end
		
		-- Already lockpicking
		if ply.CH_ATM_IsLockpickingATM then
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You are already lockpicking an ATM." ) )
			return false
		end
		
		return true
	end
end
hook.Add( "canLockpick", "CH_ATM.CanLockpickATM", CH_ATM.CanLockpickATM )

--[[
	Lockpick started on ATM
--]]
CH_ATM.AlarmSound = nil

function CH_ATM.StartLockpickATM( ply, ent, trace )
	if ent:GetClass() == "ch_atm" then
		-- Change var on ATM to be IsBeingHacked
		ent:SetIsBeingHacked( true )
		
		-- Start RGB lights
		CH_ATM.ToggleRGBLights( ent )
		
		-- Set variable on player that they are lockpicking now
		ply.CH_ATM_IsLockpickingATM = true
		ply.CH_ATM_EntityBeingLockpicked = ent
		
		-- Sound the alarm
		if CH_ATM.Config.EmitSoundOnHacking then
			local filter = RecipientFilter()
			filter:AddAllPlayers()
			
			CH_ATM.AlarmSound = CreateSound( ent, CH_ATM.Config.TheAlarmSound, filter )
			CH_ATM.AlarmSound:SetSoundLevel( CH_ATM.Config.AlarmSoundVolume )
			CH_ATM.AlarmSound:Play()
		end
		
		-- Notify police
		for k, cop in ipairs( player.GetAll() ) do
			if cop:CH_ATM_IsPoliceJob() then
				CH_ATM.NotifyPlayer( cop, CH_ATM.LangString( "Someone is hacking an ATM. It has been marked on your map!" ) )
			end
		end
		
		-- Make player wanted
		if CH_ATM.Config.MakePlayerWantedOnHack then
			ply:wanted( ply, "ATM Hacking", CH_ATM.Config.PlayerWantedTime )
		end
	end
end
hook.Add( "lockpickStarted", "CH_ATM.StartLockpickATM", CH_ATM.StartLockpickATM )

--[[
	Successfully or unsuccessfully lockpicked an ATM
--]]
function CH_ATM.SuccessfullyLockpickATM( ply, success, ent )
	if ent:GetClass() == "ch_atm" then
		if success then
			-- Variables
			local hack_reward = math.random( CH_ATM.Config.MoneyRewardForHackingMin, CH_ATM.Config.MoneyRewardForHackingMax )
			local to_take_per_player = math.Round( hack_reward / player.GetCount() )
			local interest_to_take = CH_ATM.Config.InterestToTakeForHacking
			
			-- Give hacker some money and notify him
			CH_ATM.AddMoney( ply, hack_reward )
			
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have successfully lockpicked the ATM and have stolen" ) .." ".. CH_ATM.FormatMoney( hack_reward ) )
			
			-- XP support
			CH_ATM.GiveXP( ply, CH_ATM.Config.SuccessfulHackXP, "XP rewarded" )
			
			-- Take money and interest from all players (minus robber) and notify (amount is split by total reward and amount of players)
			if CH_ATM.Config.TakeMoneyFromOnlinePlayers then
				for k, victim in ipairs( player.GetHumans() ) do
					if ply != victim then
						CH_ATM.TakeMoneyFromBankAccount( victim, to_take_per_player )
						
						CH_ATM.NotifyPlayer( victim, CH_ATM.LangString( "A bank ATM has been robbed and the robber got away with" ) .. " ".. CH_ATM.FormatMoney( to_take_per_player ) .." ".. CH_ATM.LangString( "from your account." ) )
						
						-- bLogs support
						hook.Run( "CH_ATM_bLogs_TakeMoney", to_take_per_player, victim, "Taken due to a successful hack." )
						
						-- Decrease interest for all online players
						if interest_to_take > 0 then
							CH_ATM.DecreaseInterestRate( victim, interest_to_take )
						end
					end
				end
			end
			
			-- Set hack entity to nil
			ply.CH_ATM_EntityBeingLockpicked = nil
		else
			-- Notify player
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have failed lockpicking the ATM!" ) )
		end
		
		-- Check if ATM ent is still valid
		if IsValid( ent ) then
			-- Toggle RGB lights off
			CH_ATM.ToggleRGBLights( ent )
			
			-- Set no longer being hacked
			ent:SetIsBeingHacked( false )
			
			-- If ATM hacking cooldown is enabled
			if CH_ATM.Config.ATMHackCooldownTime > 0 then
				-- Change color on ATM
				ent:SetBodygroup( 1, 1 )
			
				CH_ATM.ChangeATMColor( ent, CH_ATM.Config.OutOfOrderColor, 0 )
			
				-- Set cooldown var on atm ent
				ent:SetIsHackCooldown( true )
				
				-- Network cooldown timer for the ATM
				net.Start( "CH_ATM_Net_RestartHackCooldownTimer" )
					net.WriteEntity( ent )
				net.Broadcast()
				
				-- Start timer to remove cooldown
				timer.Simple( CH_ATM.Config.ATMHackCooldownTime, function()
					if IsValid( ent ) then
						ent:SetIsHackCooldown( false )
						
						-- Change color after cooldown time based on configs
						if not CH_ATM.Config.EnableInactiveColor then
							ent:SetBodygroup( 1, 0 )
						else
							CH_ATM.ChangeATMColor( ent, CH_ATM.Config.InactiveColor, 0 )
						end
					end
				end )
			end
		end
		
		-- Stop the alarm sound
		if CH_ATM.AlarmSound then
			CH_ATM.AlarmSound:Stop()
			CH_ATM.AlarmSound = nil
		end
		
		-- Set cooldown variable on player
		ply.CH_ATM_LockpickCooldown = CurTime() + CH_ATM.Config.PlayerHackingCooldownTime
		
		-- Set variable on player that they are no longer lockpicking
		ply.CH_ATM_IsLockpickingATM = false
		
		-- Unwanted if enabled
		if CH_ATM.Config.UnwantedAfterHacking then
			ply:unWanted( ply )
		end
		
		-- Return true to override default behaviour, which is opening the (fading) door.
		return true
	end
end
hook.Add( "onLockpickCompleted", "CH_ATM.SuccessfullyLockpickATM", CH_ATM.SuccessfullyLockpickATM )

--[[
	Reward some jobs for killing active hackers
--]]
function CH_ATM.RewardKillingHackers( hacker, inflictor, attacker )
    local is_hacking = IsValid( hacker.CH_ATM_EntityBeingLockpicked )
    local hacked_atm = hacker.CH_ATM_EntityBeingLockpicked -- ATM'yi kaydet

    if is_hacking then
        -- Önce ATM'yi resetle
        hook.Run( "onLockpickCompleted", hacker, false, hacked_atm )
        
        if attacker and attacker:IsPlayer() and IsValid( attacker ) then
            if attacker:CH_ATM_IsPoliceJob() then
                CH_ATM.AddMoney( attacker, CH_ATM.Config.KillHackerReward )
                CH_ATM.NotifyPlayer( attacker, CH_ATM.FormatMoney( CH_ATM.Config.KillHackerReward ) .." ".. CH_ATM.LangString( "rewarded for stopping an ATM hacker!" ) )
                
                local amount = math.random( CH_ATM.Config.KillingHackerMinXP, CH_ATM.Config.KillingHackerMaxXP )
                CH_ATM.GiveXP( attacker, amount, "XP rewarded" )
                
                hacker.CH_ATM_EntityBeingLockpicked = nil
            end
        end
    end
end
hook.Add( "PlayerDeath", "CH_ATM.RewardKillingHackers", CH_ATM.RewardKillingHackers )

--[[
	Reward cops for arresting active hackers
--]]
function CH_ATM.RewardArrestingHacker( hacker, time, arrester )
	local is_hacking = IsValid( hacker.CH_ATM_EntityBeingLockpicked )

	if is_hacking then
		if arrester and arrester:IsPlayer() and IsValid( arrester ) then
			-- Reward money to the killer.
			if arrester:CH_ATM_IsPoliceJob() then
				-- call lockpick complete (failed) hook
				hook.Run( "onLockpickCompleted", hacker, false, hacker.CH_ATM_EntityBeingLockpicked )
				
				-- Reward cop
				CH_ATM.AddMoney( arrester, CH_ATM.Config.ArrestHackerReward )
				
				-- Notify player
				CH_ATM.NotifyPlayer( arrester, CH_ATM.FormatMoney( CH_ATM.Config.ArrestHackerReward ) .." ".. CH_ATM.LangString( "rewarded for stopping an ATM hacker!" ) )
				
				-- XP reward support
				local amount = math.random( CH_ATM.Config.ArrestingHackerMinXP, CH_ATM.Config.ArrestingHackerMaxXP )
				CH_ATM.GiveXP( arrester, amount, "XP rewarded" )
				
				-- Set hack entity to nil
				hacker.CH_ATM_EntityBeingLockpicked = nil
			end
		end
	end
end
hook.Add( "playerArrested", "CH_ATM.RewardArrestingHacker", CH_ATM.RewardArrestingHacker )

-- Oyuncu disconnect olduğunda ATM hack durumunu resetle
hook.Add( "PlayerDisconnected", "CH_ATM.ResetHackOnDisconnect", function( ply )
    if IsValid( ply.CH_ATM_EntityBeingLockpicked ) then
        local atm = ply.CH_ATM_EntityBeingLockpicked
        
        -- Toggle RGB lights off
        CH_ATM.ToggleRGBLights( atm )
        
        -- Set no longer being hacked
        atm:SetIsBeingHacked( false )
        
        -- Stop the alarm sound
        if CH_ATM.AlarmSound then
            CH_ATM.AlarmSound:Stop()
            CH_ATM.AlarmSound = nil
        end
        
        -- Cooldown işlemleri
        if CH_ATM.Config.ATMHackCooldownTime > 0 then
            atm:SetBodygroup( 1, 1 )
            CH_ATM.ChangeATMColor( atm, CH_ATM.Config.OutOfOrderColor, 0 )
            atm:SetIsHackCooldown( true )
            
            net.Start( "CH_ATM_Net_RestartHackCooldownTimer" )
                net.WriteEntity( atm )
            net.Broadcast()
            
            timer.Simple( CH_ATM.Config.ATMHackCooldownTime, function()
                if IsValid( atm ) then
                    atm:SetIsHackCooldown( false )
                    
                    if not CH_ATM.Config.EnableInactiveColor then
                        atm:SetBodygroup( 1, 0 )
                    else
                        CH_ATM.ChangeATMColor( atm, CH_ATM.Config.InactiveColor, 0 )
                    end
                end
            end )
        end
        
        ply.CH_ATM_EntityBeingLockpicked = nil
        ply.CH_ATM_IsLockpickingATM = false
    end
end )