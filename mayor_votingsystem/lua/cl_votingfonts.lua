--MayorVoting System Fonts
local function LoadMayorVotingFonts()
    if VOTING.FontsLoaded then return end
    -- İsimler için kullanılan fontun boyutunu artırdık (örneğin 24).
    surface.CreateFont("Bebas24Font", {font = "Tahoma", size= 24, weight = 700, antialias = true, bold = true } ) -- Boyut artırıldı
    surface.CreateFont("Bebas40Font", {font = "Tahoma", size= 34, weight = 700, antialias = true, bold = true } )
    surface.CreateFont("Bebas70Font", {font = "Tahoma", size= 60, weight = 700, antialias = true, bold = true } ) --Font used for titles

    surface.CreateFont("OpenSans18Font", {font = "Tahoma", size= 16, weight = 500, antialias = true } ) --Font used for vote ticker
    VOTING.FontsLoaded = true
end
LoadMayorVotingFonts()
hook.Add("InitPostEntity", "VOTING_InitPostLoadFonts", LoadMayorVotingFonts)