-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

if SH_ANTICRASH.SETTINGS.PHYSPERFMODE == false then return end

if SERVER then

	local defaultPerf = {
		LookAheadTimeObjectsVsObject = 0.5,
		LookAheadTimeObjectsVsWorld	= 1,
		MaxAngularVelocity = 7272.7275390625,
		MaxCollisionChecksPerTimestep = 50000,
		MaxCollisionsPerObjectPerTimestep = 10,
		MaxFrictionMass	= 2500,
		MaxVelocity	= 4000,
		MinFrictionMass	= 10
	}

	local customPerf = {
		LookAheadTimeObjectsVsObject = 0.5,
		LookAheadTimeObjectsVsWorld	= 1,
		MaxAngularVelocity = 7000,
		MaxCollisionChecksPerTimestep = 15000,
		MaxCollisionsPerObjectPerTimestep = 1,
		MaxFrictionMass	= 2500,
		MaxVelocity	= 4000,
		MinFrictionMass	= 10
	}

	timer.Simple(0, function()
		physenv.SetPerformanceSettings(customPerf)
	end)
	
end

if CLIENT then

	local defaultPerf = {
		LookAheadTimeObjectsVsObject = 0.5,
		LookAheadTimeObjectsVsWorld	= 1,
		MaxAngularVelocity = 3636.3637695313,
		MaxCollisionChecksPerTimestep =	250,
		MaxCollisionsPerObjectPerTimestep = 6,
		MaxFrictionMass	= 2500,
		MaxVelocity	= 2000,
		MinFrictionMass	= 10
	}
	
	local customPerf = {
		LookAheadTimeObjectsVsObject = 0.5,
		LookAheadTimeObjectsVsWorld	= 1,
		MaxAngularVelocity = 3600,
		MaxCollisionChecksPerTimestep =	200,
		MaxCollisionsPerObjectPerTimestep = 1,
		MaxFrictionMass	= 2500,
		MaxVelocity	= 2000,
		MinFrictionMass	= 10
	}
	
	local function InitPostEntity()
		physenv.SetPerformanceSettings(customPerf)
	end
	hook.Add( "InitPostEntity", "z_anticrash_InitPostEntityPhys", InitPostEntity)

end