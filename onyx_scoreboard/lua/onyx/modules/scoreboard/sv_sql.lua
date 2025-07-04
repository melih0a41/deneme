--[[

Author: tochnonement
Email: tochnonement@gmail.com

28/02/2024

--]]

onyx.scoreboard:Print('Loaded SQL configuration.')

local MySQL = {Credentials = {}}

-- Enable MySQL
-- (requires `mysqloo` module and mysql database)
MySQL.Enabled = false

-- MySQL Credentials
MySQL.Credentials.Hostname  = 'localhost'
MySQL.Credentials.Username  = 'username'
MySQL.Credentials.Password  = 'password'
MySQL.Credentials.Schema    = 'example'
MySQL.Credentials.Port      = 3306

--[[------------------------------
DO NOT TOUCH STUFF BELOW
--------------------------------]]
onyx.scoreboard:SetupDatabase(MySQL.Enabled, MySQL.Credentials)