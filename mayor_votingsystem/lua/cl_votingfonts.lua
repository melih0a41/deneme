--MayorVoting System Fonts - Modern & Enhanced
local function LoadMayorVotingFonts()
    if VOTING.FontsLoaded then return end
    
    -- Ana başlık için büyük ve etkileyici font
    surface.CreateFont("VotingTitleFont", {
        font = "DermaLarge", 
        size = 42, 
        weight = 800, 
        antialias = true, 
        bold = true,
        shadow = true,
        outline = true
    })
    
    -- Oyuncu isimleri için modern font
    surface.CreateFont("VotingPlayerNameFont", {
        font = "DermaDefault", 
        size = 26, 
        weight = 700, 
        antialias = true, 
        bold = true,
        shadow = true
    })
    
    -- Oy sayıları için büyük ve belirgin font
    surface.CreateFont("VotingCountFont", {
        font = "DermaLarge", 
        size = 48, 
        weight = 900, 
        antialias = true, 
        bold = true,
        shadow = true,
        outline = true
    })
    
    -- Kazanan başkan için özel font
    surface.CreateFont("VotingWinnerFont", {
        font = "DermaLarge", 
        size = 38, 
        weight = 800, 
        antialias = true, 
        bold = true,
        shadow = true,
        outline = true
    })
    
    -- Bildirimler için font
    surface.CreateFont("VotingNoticeFont", {
        font = "DermaDefault", 
        size = 20, 
        weight = 600, 
        antialias = true, 
        bold = true,
        shadow = true
    })
    
    -- Geri sayım için font
    surface.CreateFont("VotingTimerFont", {
        font = "DermaDefaultBold", 
        size = 32, 
        weight = 700, 
        antialias = true, 
        bold = true,
        shadow = true
    })
    
    -- Alt yazılar için font
    surface.CreateFont("VotingSubtitleFont", {
        font = "DermaDefault", 
        size = 18, 
        weight = 500, 
        antialias = true,
        shadow = true
    })
    
    VOTING.FontsLoaded = true
    print("[VOTING] Modern fonts loaded successfully!")
end

LoadMayorVotingFonts()
hook.Add("InitPostEntity", "VOTING_InitPostLoadFonts", LoadMayorVotingFonts)