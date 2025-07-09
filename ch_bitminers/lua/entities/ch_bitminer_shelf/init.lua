AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/bitminers/rack/rack.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()
	
	self.ConnectedEntity = nil -- no power cords connected
	self.IsPluggedIn = false
	
	-- Set default values
	self:SetHealth( CH_Bitminers.Config.ShelfHealth )
	self:SetMaxHealth( CH_Bitminers.Config.ShelfHealth )
	
	self:SetMinersInstalled( 1 )
	self:SetMinersAllowed( 4 )
	
	self:SetUPSInstalled( 1 )
	self:SetFansInstalled( 0 )
	self:SetTemperature( CH_Bitminers.Config.ShelfStartTemperature )
	self:SetBitcoinsMined( 0 )
	
	self:SetWattsRequired( CH_Bitminers.Config.WattsRequiredPerMiner )
	self:SetWattsGenerated( 0 )
	
	self:SetRGBInstalled( false )
	self.RGBLightsOn = false
	
	self:SetHasPower( false )
	self:SetIsMining( false )
	
	self:SetIsHacked( false )
	
	-- Create sound
	self.ShelfMiningSound = CreateSound( self, "ambient/machines/air_conditioner_loop_1.wav" )
	self.ShelfMiningSound:SetSoundLevel( CH_Bitminers.Config.ShelfMiningSoundLevel )
	
	-- Initialize bodygroups and skin
	self:SetBodygroup( self:GetMinersInstalled(), 1 ) -- Miners
	self:SetBodygroup( 17, 1 ) -- UPS's
	self:SetBodygroup( 18, 0 ) -- Fans
	
	self:SetSkin( 0 ) -- 1: white 2: on 3: rgb
	
	-- Start temperature & cooling systems
	self:Temperature()
	
	-- Set DarkRP owner
	self:CPPISetOwner( self:Getowning_ent() )
	
	-- Add entity to active entities table
	CH_Bitminers.SpawnedEntities[ self ] = true
	
	-- Prediction exploit patch
	self.LastEarnTime = 0
	
	-- Set the index to 0 before checking if integration is enabled
	self:SetCryptoIntegrationIndex( 0 )
	if CH_Bitminers.Config.IntegrateCryptoCurrencies and CH_CryptoCurrencies then
		-- We need to find out at what index the bitcoin (BTC) crypto is located at from the Crypto addon.
		-- To do so we look into the table of crypto's and find the prefix, and thus save the index.
		for index, crypto in ipairs( CH_CryptoCurrencies.Cryptos ) do
			if crypto.Currency == CH_Bitminers.Config.DefaultCryptoToMine then
				self:SetCryptoIntegrationIndex( index )
				break
			end
		end
	end
end

function ENT:StartMining()
	if timer.Exists( "bitminer_mining_".. self:EntIndex() ) then
		timer.Remove( "bitminer_mining_".. self:EntIndex() )
	end
	
	local mine_interval = CH_Bitminers.Config.MineMoneyInterval[ self:GetMinersInstalled() ] or 16
	local owner = self:CPPIGetOwner()
	
	if CH_Bitminers.Config.ShelfMiningSoundLevel > 0 then
		self.ShelfMiningSound:Play()
	end
	
	timer.Create( "bitminer_mining_".. self:EntIndex(), mine_interval, 0, function()
		if not IsValid( self ) then
			return
		end
		
		if not self:GetHasPower() then
			self:StopMining()
			return
		end
		
		if not self:GetIsMining() then
			self:StopMining()
			return
		end
		
		-- Adding bitcoins to the shelf (check if at max)
		if self:GetBitcoinsMined() >= CH_Bitminers.Config.MaxBitcoinsMined  then
			return
		end
		
		-- Don't generate any bitcoins if generated watts is under required amount.
		if self:GetWattsGenerated() < self:GetWattsRequired() then
			return
		end
		
		-- Prediction exploit patch
		if os.time() < ( self.LastEarnTime + mine_interval ) then
			print( "tried mining faster" )
			return
		end
		self.LastEarnTime = os.time()
		
		-- Update bitcoins if there's enough watts generated and everything else is good
		local to_earn = self:GetBitcoinsMined() + owner:CH_Bitminers_BitcoinsMinedPerInterval( self:GetCryptoIntegrationIndex() )
		
		self:SetBitcoinsMined( math.Clamp( to_earn, 0, CH_Bitminers.Config.MaxBitcoinsMined ) )
	end )
end

function ENT:StopMining()
	-- Remove mining timer until started again
	if timer.Exists( "bitminer_mining_".. self:EntIndex() ) then
		timer.Remove( "bitminer_mining_".. self:EntIndex() )
	end
	
	-- Stop sounds
	if self.ShelfMiningSound then
		self.ShelfMiningSound:Stop()
	end
end

function ENT:Temperature()
	timer.Create( "bitminer_temperature_".. self:EntIndex(), CH_Bitminers.Config.TemperatureInterval, 0, function()
		if not IsValid( self ) then
			return
		end

		-- Support for boost upgrades (set temp to 0 at all times when boost active)
		if CH_BoostUpgrades and CH_BoostUpgrades.BitminersInstantCoolBoost then
			self:SetTemperature( 0 )
			return
		end
		
		-- If not mining/does not have power, then we can cooldown the miners
		if not self:GetHasPower() or not self:GetIsMining() then
			local temp_to_take = CH_Bitminers.Config.TempToTakeWhenOff
			
			self:SetTemperature( math.Clamp( self:GetTemperature() - temp_to_take, 0, 100 ) )
			return
		end
		
		-- If temperature is at 100, start overheating the mining shelf
		if self:GetTemperature() >= 100 then
			local health_to_take = 4 - self:GetFansInstalled()

			self:SetHealth( self:Health() - health_to_take )
			
			if self:Health() <= 0 then
				self:Destruct()
			end
			
			return
		end
		
		-- Temperature system (as long as it's not overheating or turned off)
		local new_temp = 0
		
		local temp_to_add = CH_Bitminers.Config.TempToAddPerMiner * self:GetMinersInstalled()
		local temp_to_take = 0
		
		-- Cooldown based on how good the fan system is
		if self:GetFansInstalled() > 0 then
			temp_to_take = CH_Bitminers.Config.TempToTakePerCooling * self:GetFansInstalled()
		end
		
		temp_to_add = temp_to_add - temp_to_take
		new_temp = self:GetTemperature() + temp_to_add
		
		self:SetTemperature( math.Clamp( new_temp, 0, 100 ) )
		
		-- Notify owner of overheating if enabled
		if CH_Bitminers.Config.NotifyOwnerOverheating then
			if self:GetTemperature() >= 100 then
				local owner = self:CPPIGetOwner()
				
				CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Your bitmining shelf is overheating!" ) )
			end
		end
	end )	
end

function ENT:Use( ply )
	local cur_time = CurTime()
	if ( ply.LastUsed or 0 ) > cur_time then
		return
	end
	ply.LastUsed = cur_time + 2

	local tr = self:WorldToLocal( ply:GetEyeTrace().HitPos ) 

	if self.IsBeingHacked then
		return
	end
	
	local owner = self:CPPIGetOwner()

	-- If the bitminer is not hacked, only allow the owner to access it.
	if not self:GetIsHacked() then -- if not hacked
		if ply != owner then -- person trying to access is not owner
			CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "Only the owner of this bitminer can access it!" ) )
			return
		end
	end

	-- Eject bitminer
	if CH_Bitminers.Config.EnableEjectingBitminers then
		if tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.eject_bitminer_btn_one, CH_Bitminers.Config.ScreenPositions.eject_bitminer_btn_two ) then
			-- Don't allow if not turned on!
			if not self:GetIsMining() then
				return
			end

			self:EjectBitminer( ply )
			return
		end
	end
	
	-- If hacked or owner then allow access
	if tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.power_btn_one, CH_Bitminers.Config.ScreenPositions.power_btn_two ) then
		if self:GetHasPower() then -- power source is connected
			if not self:GetIsMining() then
				self:PowerOn()
				
				CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "You have powered on your bitminers!" ) )
			end
		else
			CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "Your bitminer has no active power source." ) )
		end
	elseif tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.power_btn_small_one, CH_Bitminers.Config.ScreenPositions.power_btn_small_two ) then
		if self:GetIsMining() then
			self:PowerOff()
			
			CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "You have shut down your bitminers!" ) )
		end
	elseif tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.withdraw_one, CH_Bitminers.Config.ScreenPositions.withdraw_two ) then
		-- Don't allow if not turned on!
		if not self:GetIsMining() then
			return
		end

		self:WithdrawMoney( ply, false )
	elseif tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.change_mined_crypto_btn_one, CH_Bitminers.Config.ScreenPositions.change_mined_crypto_btn_two ) then
		-- Don't allow if not turned on!
		if not self:GetIsMining() then
			return
		end

		net.Start( "CH_BITMINERS_CryptoOptions" )
			net.WriteEntity( self )
		net.Send( ply )
	elseif tr:WithinAABox( CH_Bitminers.Config.ScreenPositions.rgb_btn_one, CH_Bitminers.Config.ScreenPositions.rgb_btn_two ) then
		-- Don't allow if not turned on!
		if not self:GetIsMining() then
			return
		end
		
		if self:GetRGBInstalled() then
			if not self.RGBLightsOn then
				self:SetSkin( 4 )
				self.RGBLightsOn = true
				self:SetRGBEnabled( true )
			else
				self:SetSkin( 3 )
				self.RGBLightsOn = false
				self:SetRGBEnabled( false )
			end
		else
			CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "You need to install an RGB upgrade to enable this!" ) )
		end
	end
end

function ENT:StartTouch( ent )
	if ent:IsPlayer() then
		return
	end
	
	local cur_time = CurTime()
	if ( ent.LastTouch or 0 ) > cur_time then
		return
	end
	ent.LastTouch = cur_time + 2
	
	local owner = self:CPPIGetOwner()
	
	if ent:GetClass() == "ch_bitminer_upgrade_miner" then
		if self:GetMinersInstalled() == 16 then
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "You've reached the maximum amount of miners installed at once." ) )
			return
		elseif self:GetMinersInstalled() == owner:CH_BITMINERS_GetMaxMiners() then
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "You've reached the maximum amount of miners based on your current rank." ) )
			return
		elseif self:GetMinersInstalled() >= self:GetMinersAllowed() then
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "You've reached the maximum amount of miners installed at once." ) )
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Upgrade with another UPS to install more miners." ) )
			return
		end
		
		self:AddBitminer()
		
		SafeRemoveEntityDelayed( ent, 0 )
	elseif ent:GetClass() == "ch_bitminer_upgrade_ups" then
		if self:GetMinersAllowed() >= 16 then
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "You've reached the maximum amount of UPS upgrades for this mining shelf!" ) )
			return
		end
		
		self:SetMinersAllowed( self:GetMinersAllowed() + 4 )
		self:SetBodygroup( 17, self:GetMinersAllowed() / 4 )
		
		self:SetUPSInstalled( self:GetUPSInstalled() + 1 )
		
		SafeRemoveEntityDelayed( ent, 0 )
	elseif ent:GetClass() == "ch_bitminer_upgrade_cooling1" or ent:GetClass() == "ch_bitminer_upgrade_cooling2" or ent:GetClass() == "ch_bitminer_upgrade_cooling3" then
		if self:GetFansInstalled() >= 3 then
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "You've reached the highest level of ventilation on your miner." ) )
			return
		end

		if self:GetFansInstalled() < ent.CoolingLevel then
			self:SetFansInstalled( ent.CoolingLevel )
		
			self:SetBodygroup( 18, self:GetFansInstalled() )
		
			SafeRemoveEntityDelayed( ent, 0 )
		else
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Your miner has a better ventilation system installed!" ) )
			return
		end
	elseif ent:GetClass() == "ch_bitminer_upgrade_rgb" then
		if not self:GetRGBInstalled() then
			self:SetRGBInstalled( true )
			
			if self:GetHasPower() and self:GetIsMining() then
				self:SetSkin( 3 )
			else
				self:SetSkin( 2 )
			end
			
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "RGB upgrade has been successfully installed!" ) )
			
			SafeRemoveEntityDelayed( ent, 0 )
			
			-- GIVE XP SUPPORT
			owner:CH_Bitminers_RewardXP( CH_Bitminers.Config.InstallRGBXPAmount )
		else
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Your shelf already has RGB lights installed!" ) )
		end
	end
end

function ENT:WithdrawMoney( ply, remotely )
	if self:GetBitcoinsMined() > 0 then
		if CH_Bitminers.Config.IntegrateCryptoCurrencies then
			if not CH_CryptoCurrencies then
				CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "Payout failed! Cryptocurrencies by Crap-Head has been enabled but is not installed!" ) )
				return
			end
			
			-- Cryptocurrencies by Crap-Head is installed. Continue below.
			self:WithdrawInCrypto( ply )
		else
			sound.Play( "buttons/lever8.wav", self:GetPos() )
			
			local bitcoin_rate = CH_Bitminers.Config.BitcoinRate
			local money_to_withdraw = math.Round( self:GetBitcoinsMined() * bitcoin_rate )
			
			-- Support for Boost Upgrades (double payout boost)
			if CH_BoostUpgrades and CH_BoostUpgrades.BitminersDoublePayout then
				money_to_withdraw = money_to_withdraw * 1
			end
			
			-- Exchange bitcoins to money
			self:SetBitcoinsMined( 0 )
			ply:addMoney( money_to_withdraw )

			CH_Bitminers.NotifyPlayer( ply, DarkRP.formatMoney( money_to_withdraw ).." ".. CH_Bitminers.LangString( "has been withdrawn from the bitminer!" ) )
			
			-- bLogs support
			hook.Run( "CH_BITMINER_PlayerWithdrawMoney", ply, money_to_withdraw )
			
			if remotely then
				-- bLogs support
				hook.Run( "CH_BITMINER_DLC_PlayerWithdrawRemotely", ply, money_to_withdraw )
			end
		end
		
		-- GIVE XP SUPPORT
		ply:CH_Bitminers_RewardXP( CH_Bitminers.Config.WithdrawXPAmount )
	else
		CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "You have no bitcoins to exchange!" ) )
	end
end

function ENT:WithdrawInCrypto( ply )
	local bitcoins = math.Round( self:GetBitcoinsMined(), 7 )
	
	-- Support for Boost Upgrades (double payout boost)
	if CH_BoostUpgrades and CH_BoostUpgrades.BitminersDoublePayout then
		bitcoins = bitcoins * 2
	end
	
	self:SetBitcoinsMined( 0 )
	
	local crypto_table = CH_CryptoCurrencies.Cryptos[ self:GetCryptoIntegrationIndex() ]
	local crypto_prefix = crypto_table.Currency
	local crypto_name = crypto_table.Name
	
	CH_Bitminers.NotifyPlayer( ply, bitcoins .." ".. crypto_name .." ".. CH_Bitminers.LangString( "has been withdrawn from the bitminer!" ) )
	CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "They have been added to your crypto wallet." ) )
	
	-- bLogs support
	hook.Run( "CH_BITMINER_PlayerWithdrawMoneyCrypto", ply, bitcoins, crypto_name )
	
	-- Add the crypto to the player
	CH_CryptoCurrencies.GiveCrypto( ply, crypto_prefix, bitcoins )
end

function ENT:PowerOn()
	self:SetIsMining( true )
	self:ResetSequence( "on" )
	
	if self:GetRGBInstalled() then
		self:SetSkin( 3 )
	else
		self:SetSkin( 1 )
	end
	
	self:StartMining()
end

function ENT:PowerOff()
	self:SetIsMining( false )
	self:ResetSequence( "off" )
	
	if self:GetRGBInstalled() then
		self:SetSkin( 2 )
		if self:GetRGBEnabled() then
			self:SetRGBEnabled( false )
		end
	else
		self:SetSkin( 0 )
	end
	
	self:StopMining()
end

function ENT:AddBitminer()
	-- Add another miner to the shelf
	self:SetMinersInstalled( self:GetMinersInstalled() + 1 )
	
	-- Update bodygroup
	self:SetBodygroup( self:GetMinersInstalled(), 1 )
	
	-- Update mine intervals
	self:StartMining()

	-- Update watts required
	self:SetWattsRequired( self:GetWattsRequired() + CH_Bitminers.Config.WattsRequiredPerMiner )
end

function ENT:EjectBitminer( ply )
	-- Only allow to remove bitminer if more than one is installed.
	if self:GetMinersInstalled() <= 1 then
		CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "There has to be more than one bitminer in order to eject it!" ) )
		return
	end
	
	-- Update bodygroup
	self:SetBodygroup( self:GetMinersInstalled(), 0 )
	
	-- Remove miner from the shelf
	self:SetMinersInstalled( self:GetMinersInstalled() - 1 )
	
	-- Update mine intervals
	self:StartMining()
	
	-- Update watts required
	self:SetWattsRequired( self:GetWattsRequired() - CH_Bitminers.Config.WattsRequiredPerMiner )

	-- Spawn bitminer entity next to the player
	local ejected_bitminer = ents.Create( "ch_bitminer_upgrade_miner" )
	ejected_bitminer:SetPos( ply:GetPos() + Vector( 50, 0, 50 ) )
	ejected_bitminer:Spawn()
	
	ejected_bitminer:CPPISetOwner( ply )
	
	CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "You have ejected a bitminer. It has been spawned next to you." ) )
end

function ENT:OnTakeDamage( dmg )
	if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		
		self:SetHealth( ( self:Health() or 100 ) - dmg:GetDamage() )
		if self:Health() <= 0 then                  
			if not IsValid( self ) then
				return
			end
			
			self:Destruct()
		end
		
		self.m_bApplyingDamage = false
	end
end

function ENT:Destruct()
	local owner = self:CPPIGetOwner()

	if CH_Bitminers.Config.ShelfExplosion and not self.IsDestroyed then
		self.IsDestroyed = true
		
		local calculated_damage = 75 + ( self:GetMinersInstalled() * 15 )

		local vPoint = self:GetPos()
		local effect_explode = ents.Create( "env_explosion" )
		if not IsValid( effect_explode ) then return end
		effect_explode:SetPos( vPoint )
		effect_explode:Spawn()
		effect_explode:SetKeyValue( "iMagnitude", calculated_damage )
		effect_explode:Fire( "Explode", 0, 0 )
		
		if CH_Bitminers.Config.CreateFireOnExplode then
			local Fire = ents.Create( "fire" )
			Fire:SetPos( vPoint )
			Fire:SetAngles( Angle( 0, 0, 0 ) )
			Fire:Spawn()
		
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Your bitmining shelf has exploded and caught fire due to taking an excessive amount of damage!" ) )
		else
			CH_Bitminers.NotifyPlayer( owner, CH_Bitminers.LangString( "Your bitmining shelf has exploded due to taking an excessive amount of damage!" ) )
		end
	end

	self:Remove()
end

-- 76561198307194389

function ENT:OnRemove()
	self:StopMining()
	
	-- Remove temperature timer on deletion
	if timer.Exists( "bitminer_temperature_".. self:EntIndex() ) then
		timer.Remove( "bitminer_temperature_".. self:EntIndex() )
	end
	
	-- Unplug from shelf if removed
	if IsValid( self.ConnectedEntity ) then
		self.ConnectedEntity:UnplugCable( self )
	end
	
	-- Remove entity from active entities table
	CH_Bitminers.SpawnedEntities[ self ] = nil
end

function ENT:Think()
    self:NextThink( CurTime() + 0.1 )
	return true
end