/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}

if SERVER then
	concommand.Add("zlm_debug_grasspile_add", function(ply, cmd, args)
		if IsValid(ply) and zlm.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			local trEntity = tr.Entity

			if IsValid(trEntity) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

				if trEntity:GetClass() == "zlm_unload" then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

					trEntity:SetGrassCount(math.Clamp(trEntity:GetGrassCount() + 100, 0, 1000))
					print("Grass: " .. trEntity:GetGrassCount())

				elseif trEntity:GetClass() == "zlm_grasspress" then
					zlm.f.AddGrass(trEntity,100)
				end
			end
		end
	end)

	concommand.Add("zlm_debug_tractor_vcmod_reducefuel", function(ply, cmd, args)
		if IsValid(ply) and zlm.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			local trEntity = tr.Entity

			if IsValid(trEntity) and trEntity:GetClass() == "prop_vehicle_jeep" then
				trEntity:VC_fuelSet(15)
				print(trEntity:VC_fuelGet())
			end
		end
	end)

	concommand.Add("zlm_debug_grasspile_remove", function(ply, cmd, args)
		if IsValid(ply) and zlm.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()
			local trEntity = tr.Entity

			if IsValid(trEntity) and (trEntity:GetClass() == "zlm_unload" or trEntity:GetClass() == "zlm_grasspress")  then
				trEntity:SetGrassCount(math.Clamp(trEntity:GetGrassCount() - 100, 0, 1000))
				print("Grass: " .. trEntity:GetGrassCount())
			end
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

	concommand.Add( "zlm_debug_SendGrassSpotToPlayers", function( ply, cmd, args )
	    if IsValid(ply) and zlm.f.IsAdmin(ply) then
	        zlm.f.Send_GrassSpots_ToClient(ply)
	    end
	end )

	concommand.Add( "zlm_debug_RefreshAllGrass", function( ply, cmd, args )
	    if IsValid(ply) and zlm.f.IsAdmin(ply) then
	        for k, v in pairs(zlm_GrassSpots) do
	            if v.mowed then
	                zlm.f.Refresh_GrassSpot(k)
	                v.mowed = false
	            end
	        end
	    end
	end )
end
