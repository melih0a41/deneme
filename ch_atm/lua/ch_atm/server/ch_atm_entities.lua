local map = string.lower( game.GetMap() )

function CH_ATM.SpawnEntities()
	-- Spawn ATM's
	for k, v in ipairs( file.Find( "craphead_scripts/ch_atm/entities/".. map .."/atm/atm_*.json", "DATA" ) ) do
		local PositionFile = file.Read( "craphead_scripts/ch_atm/entities/".. map .."/atm/".. v, "DATA" )

		local Pos = util.JSONToTable( PositionFile )
		local TheVector = Vector( Pos.EntityVector.x, Pos.EntityVector.y, Pos.EntityVector.z )
		local TheAngle = Angle( Pos.EntityAngles.x, Pos.EntityAngles.y, Pos.EntityAngles.z )

		local ATM = ents.Create( "ch_atm" )
		ATM:SetPos( TheVector )
		ATM:SetAngles( TheAngle )
		ATM:Spawn()
	end
	
	-- Spawn leaderboards
	for k, v in ipairs( file.Find( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards/board_*.json", "DATA" ) ) do
		local pos_file = file.Read( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards/".. v, "DATA" )
		local file_table = util.JSONToTable( pos_file )
		
		-- Spawn entity
		local leaderboard = ents.Create( "ch_atm_leaderboard" )
		leaderboard:SetPos( file_table.EntityVector )
		leaderboard:SetAngles( file_table.EntityAngles )
		leaderboard:Spawn()
	end
end

local function CH_ATM_SaveATMEntities( ply, cmd, args )
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	local auto_increment_id = 0
	
	for k, v in ipairs( file.Find( "craphead_scripts/ch_atm/entities/".. map .."/atm/atm_*.json", "DATA" ) ) do
		file.Delete( "craphead_scripts/ch_atm/entities/".. map .."/atm/".. v )
	end
	
	for k, ent in ipairs( ents.FindByClass( "ch_atm" ) ) do
		if ent.CH_ATM_NoSave then
			continue
		end

		local Entity_Position = {
			EntityVector = {
				x = ent:GetPos().x,
				y = ent:GetPos().y,
				z = ent:GetPos().z,
			},
			EntityAngles = {
				x = ent:GetAngles().x,
				y = ent:GetAngles().y,
				z = ent:GetAngles().z,
			},
		}
		
		auto_increment_id = auto_increment_id + 1
		
		file.Write( "craphead_scripts/ch_atm/entities/".. map .."/atm/atm_".. auto_increment_id ..".json", util.TableToJSON( Entity_Position ), "DATA" )
	end

	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "All ATM's have been saved to the map!" ) )
end
concommand.Add( "ch_atm_saveall", CH_ATM_SaveATMEntities )

--[[
	Save leaderboards function
--]]
local function CH_Mining_SaveLeaderboards( ply, cmd, args )
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	local auto_increment_id = 0
	
	for k, v in ipairs( file.Find( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards/board_*.json", "DATA" ) ) do
		file.Delete( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards/".. v )
	end
	
	for k, ent in ipairs( ents.FindByClass( "ch_atm_leaderboard" ) ) do
		local ent_table = {
			EntityVector = ent:GetPos(),
			EntityAngles = ent:GetAngles(),
		}
		
		auto_increment_id = auto_increment_id + 1
		
		file.Write( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards/board_".. auto_increment_id ..".json", util.TableToJSON( ent_table ), "DATA" )
	end

	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "All leaderboards have been saved to the map!" ) )
end
concommand.Add( "ch_atm_save_leaderboards", CH_Mining_SaveLeaderboards )