////////////////////////////////
//                            //
//     Corporate Takeover     //
//     By KiwontaTv & Ian     //
//                            //
//           04/2025          //
//                            //
//     STEAM_0:0:178850058    //
//     STEAM_0:1:153915274    //
//                            //
//        Configuration       //
//                            //
////////////////////////////////
// This is a somewhat complicated config section. It involves advanced lua knowledge. If you don't know what you're doing, leave it as is.

//
// Levels
//

// How much XP is needed for each worker level [default: ((10 + level) * level) * 33]
Corporate_Takeover.Config.XPNeededForWorkerLevel = function(level)
    return ((10 + level) * level) * 33
end

// How much XP is needed for each company level [default: (10 + level) * level) * 66]
Corporate_Takeover.Config.XPNeededForCorpLevel = function(level)
    return ((10 + level) * level) * 66
end