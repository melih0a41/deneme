/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end

-- MySQL optimizasyon önerileri
hook.Add("DatabaseInitialized", "zlm_MySQLOptimize", function()
    if MySQLite and MySQLite.isMySQL and MySQLite.isMySQL() then
        -- Index önerileri
        local queries = {
            -- DarkRP player tablosu için index
            "CREATE INDEX IF NOT EXISTS idx_darkrp_player_uid ON darkrp_player(uid);",
            "CREATE INDEX IF NOT EXISTS idx_darkrp_player_rpname ON darkrp_player(rpname);",
            
            -- DarkRP door tablosu için index
            "CREATE INDEX IF NOT EXISTS idx_darkrp_door_map ON darkrp_door(map);",
            
            -- Eğer ZLM kendi tabloları varsa
            "CREATE INDEX IF NOT EXISTS idx_zlm_player_stats ON zlm_player_stats(steamid);",
        }
        
        for _, query in ipairs(queries) do
            MySQLite.query(query, function()
                print("[ZLM] MySQL Index created/verified")
            end, function(err)
                print("[ZLM] MySQL Index error: " .. err)
            end)
        end
    end
end)

-- Connection pooling için tavsiye
if SERVER then
    print([[
    [ZLM MySQL Optimization]
    Please add these settings to your MySQL configuration:
    
    max_connections = 200
    innodb_buffer_pool_size = 1G
    query_cache_size = 64M
    query_cache_limit = 2M
    ]])
end