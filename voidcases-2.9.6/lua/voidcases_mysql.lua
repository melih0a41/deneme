////////////////////
//  MySQL Config  //
////////////////////

local auth = {
    host = "localhost",
    username = "username",
    password = "password",
    database = "database",
    port = 3306,
    useMySQL = false, -- Set to true if you want to use MySQL
}

-- Do not touch anything under this line!
hook.Add("VoidLib.SQLLibInitialized", "VoidLib.SQLLibLoaded", function ()
    VoidLib.SQL:Auth(auth.host, auth.username, auth.password, auth.database, auth.port, auth.useMySQL)
end)