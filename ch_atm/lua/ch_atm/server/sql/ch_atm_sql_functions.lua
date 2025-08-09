CH_ATM.SQL = CH_ATM.SQL or {}

--[[
	Configure your SQL details
--]]
CH_ATM.SQL.UseMySQLOO = false

CH_ATM.SQL.Host = ""
CH_ATM.SQL.Username = ""
CH_ATM.SQL.Password = ""
CH_ATM.SQL.Database = ""
CH_ATM.SQL.Port = 3306

--[[
	Require mysqloo if enabled, connect to database and add the sqlquery and create table functions.
	
	Or else just create query and create table functions for sqlite 
--]]
local function CH_ATM_CreateSQLTables()
	CH_ATM.SQL.CreateTables( "ch_atm_accounts", [[
		amount INT(11) NOT NULL,
		level INT(11) NOT NULL,
		steamid VARCHAR(20) NOT NULL PRIMARY KEY,
		nick VARCHAR(45) NOT NULL
	]] )
	
	CH_ATM.SQL.CreateTables( "ch_atm_transactions", [[
		action VARCHAR(10) NOT NULL,
		amount INT(11) NOT NULL,
		timestamp TIMESTAMP NOT NULL,
		steamid VARCHAR(20) NOT NULL
	]] )
	
	timer.Simple( 5, function()
		CH_ATM.AlterSQLToAddNick()
	end )
end

if CH_ATM.SQL.UseMySQLOO then
    require( "mysqloo" )
	
	-- Setup the sql connection
    CH_ATM.SQL.DB = mysqloo.connect( CH_ATM.SQL.Host, CH_ATM.SQL.Username, CH_ATM.SQL.Password, CH_ATM.SQL.Database, CH_ATM.SQL.Port )
	
	-- What to do if successfully connected
    CH_ATM.SQL.DB.onConnected = function() 
        print( "[CH ATM MySQL] Database has connected!" ) 
        CH_ATM_CreateSQLTables()
    end
	
	-- Print error to console if we fail
    CH_ATM.SQL.DB.onConnectionFailed = function( db, err )
		print( "[CH ATM MySQL] Connection to database failed! Error: " .. err )
	end
	
	-- Connect
    CH_ATM.SQL.DB:connect()
    
	-- Here's our MySQL query function
    function CH_ATM.SQL.Query( query, func, singleRow )
        local query = CH_ATM.SQL.DB:query( query )
		
        if func then
            function query:onSuccess( data ) 
                if singleRow then
                    data = data[1]
                end
    
                func( data ) 
            end
        end
		
        function query:onError( err )
			print( "[CH ATM MySQL] An error occured while executing the query: " .. err )
		end
		
        query:start()
    end

    function CH_ATM.SQL.CreateTables( tableName, sqlLiteQuery, mySqlQuery )
        CH_ATM.SQL.Query( "CREATE TABLE IF NOT EXISTS " .. tableName .. " ( " .. ( mySqlQuery or sqlLiteQuery ) .. " );" )
        print( "[CH ATM MySQL] " .. tableName .. " table validated!" )
    end    
else
    function CH_ATM.SQL.Query( querystr, func, singleRow )
        local query
        if not singleRow then
            query = sql.Query( querystr )
        else
            query = sql.QueryRow( querystr, 1 )
        end
        
        if query == false then
            print( "[CH ATM SQLite] ERROR", sql.LastError() )
        elseif func then
            func( query )
        end
    end

    function CH_ATM.SQL.CreateTables( tableName, sqlLiteQuery, mySqlQuery )
        if not sql.TableExists( tableName ) then
            CH_ATM.SQL.Query( "CREATE TABLE " .. tableName .. " ( " .. ( sqlLiteQuery or mySqlQuery ) .. " );" )
        end

        print( "[CH ATM SQLite] " .. tableName .. " table validated!" )
    end
	
	CH_ATM_CreateSQLTables()
end

--[[
	Escape function based on sql
--]]
function CH_ATM.SQL.Escape( input )
    return CH_ATM.SQL.UseMySQLOO and CH_ATM.SQL.DB:escape( input ) or SQLStr( input, true )
end