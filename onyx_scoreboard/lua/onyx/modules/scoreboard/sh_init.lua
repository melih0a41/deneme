--[[

Author: tochnonement
Email: tochnonement@gmail.com

28/02/2024

--]]

onyx:Addon('scoreboard', {
    color = Color(65, 162, 211),
    author = 'tochnonement',
    version = '1.1.2',
    licensee = '76561198307194389'
})

----------------------------------------------------------------

onyx.Include('sv_sql.lua')
onyx.IncludeFolder('onyx/modules/scoreboard/languages/')
onyx.IncludeFolder('onyx/modules/scoreboard/core/', true)
onyx.IncludeFolder('onyx/modules/scoreboard/cfg/', true)
onyx.IncludeFolder('onyx/modules/scoreboard/ui/')

onyx.scoreboard:Print('Finished loading.')